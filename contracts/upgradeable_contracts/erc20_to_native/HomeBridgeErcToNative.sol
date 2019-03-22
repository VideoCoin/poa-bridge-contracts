pragma solidity 0.4.24;
import "../../libraries/SafeMath.sol";
import "../../libraries/Message.sol";
import "../BasicBridge.sol";
import "../../upgradeability/EternalStorage.sol";
import "../../IBlockReward.sol";
import "../../ERC677Receiver.sol";
import "../BasicHomeBridge.sol";
import "../ERC677Bridge.sol";
import "../OverdrawManagement.sol";
import "../Whitelist.sol";

contract HomeBridgeErcToNative is EternalStorage, BasicBridge, BasicHomeBridge, OverdrawManagement, Whitelist {
    using SafeMath for uint256;

    event AmountLimitExceeded(address recipient, uint256 value, bytes32 transactionHash);
    event BridgeFunded(address funder, uint256 value);

    modifier onlyWithinUserLimit(uint _value) {
        require(totalExecutedPerUser(msg.sender) <= userLimit(), "Limit crossed");
        require(_value <= (userLimit().sub(totalExecutedPerUser(msg.sender))), "Limit crossed with current value");
        _;
    }

    /// @notice Fund the bridge. The funds are used for paying out conversions from the ERC20 token
    function () public payable {
        require(msg.value > 0);
        require(msg.data.length == 0);

        emit BridgeFunded(msg.sender, msg.value);
    }

    function initialize (
        address _validatorContract,
        uint256 _dailyLimit,
        uint256 _maxPerTx,
        uint256 _minPerTx,
        uint256 _homeGasPrice,
        uint256 _requiredBlockConfirmations,
        uint256 _foreignDailyLimit,
        uint256 _foreignMaxPerTx,
        address _owner
    ) public returns(bool)
    {
        require(!isInitialized());
        require(_validatorContract != address(0) && isContract(_validatorContract));
        require(_requiredBlockConfirmations > 0);
        require(_minPerTx > 0 && _maxPerTx > _minPerTx && _dailyLimit > _maxPerTx);
        require(_foreignMaxPerTx < _foreignDailyLimit);
        require(_owner != address(0));
        addressStorage[keccak256(abi.encodePacked("validatorContract"))] = _validatorContract;
        uintStorage[keccak256(abi.encodePacked("deployedAtBlock"))] = block.number;
        uintStorage[keccak256(abi.encodePacked("dailyLimit"))] = _dailyLimit;
        uintStorage[keccak256(abi.encodePacked("maxPerTx"))] = _maxPerTx;
        uintStorage[keccak256(abi.encodePacked("minPerTx"))] = _minPerTx;
        uintStorage[keccak256(abi.encodePacked("gasPrice"))] = _homeGasPrice;
        uintStorage[keccak256(abi.encodePacked("requiredBlockConfirmations"))] = _requiredBlockConfirmations;
        uintStorage[keccak256(abi.encodePacked("executionDailyLimit"))] = _foreignDailyLimit;
        uintStorage[keccak256(abi.encodePacked("executionMaxPerTx"))] = _foreignMaxPerTx;
        uintStorage[keccak256(abi.encodePacked("limitPerUser"))] = 1e20;
        uintStorage[keccak256(abi.encodePacked("userDailyLimit"))] = 1e19;
        setOwner(_owner);
        setInitialize(true);

        return isInitialized();
    }

    function withdrawAll() public onlyOwner {
        uint256 balance = address(this).balance;
        msg.sender.transfer(balance);
    }

    function fundRecipient(address _recipient, uint amount) public onlyOwner {
        _recipient.transfer(amount);
    }

    function getBridgeMode() public pure returns(bytes4 _data) {
        return bytes4(keccak256(abi.encodePacked("erc-to-native-core")));
    }

    function totalBurntCoins() public view returns(uint256) {
        return uintStorage[keccak256(abi.encodePacked("totalBurntCoins"))];
    }

    /// @notice Transfer coins.
    function onExecuteAffirmation(address _recipient, uint256 _value) internal onlyWithinUserLimit(_value) onlyWhitelisted(_recipient) returns(bool) {
        require(_value <= address(this).balance);

        setTotalExecutedPerDay(getCurrentDay(), totalExecutedPerDay(getCurrentDay()).add(_value));
        setTotalExecutedPerUser(_recipient, totalExecutedPerUser(_recipient).add(_value));
        setTotalExecutedPerDayPerUser(getCurrentDay(), _recipient, totalExecutedPerDayPerUser(getCurrentDay(), _recipient).add(_value));

        _recipient.transfer(_value);

        return true;
    }

    function fireEventOnTokenTransfer(address _from, uint256 _value) internal {
        emit UserRequestForSignature(_from, _value);
    }

    function affirmationWithinLimits(uint256 _amount) internal view returns(bool) {
        return withinExecutionLimit(_amount);
    }

    function onFailedAffirmation(address _recipient, uint256 _value, bytes32 _txHash) internal {
        address recipient;
        uint256 value;
        (recipient, value) = txAboveLimits(_txHash);
        require(recipient == address(0) && value == 0);
        setOutOfLimitAmount(outOfLimitAmount().add(_value));
        setTxAboveLimits(_recipient, _value, _txHash);
        emit AmountLimitExceeded(_recipient, _value, _txHash);
    }
}
