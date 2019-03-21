pragma solidity 0.4.24;


import "./Ownable.sol";


/**
 * @title Whitelist
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.
 * @dev This simplifies the implementation of "user permissions".
 */
contract Whitelist is Ownable {
    
    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressRemoved(address addr);

    /**
    * @dev Throws if called by any account that's not whitelisted.
    */
    modifier onlyWhitelisted(address _addr) {
        require(boolStorage[keccak256(abi.encodePacked("whitelist", _addr))], "Only whitelisted address can perform that acction");
        _;
    }

    /**
    * @dev add an address to the whitelist
    * @param addr address
    * @return true if the address was added to the whitelist, false if the address was already in the whitelist 
    */
    function addAddressToWhitelist(address addr) public onlyOwner returns(bool success) {
        if (!boolStorage[keccak256(abi.encodePacked("whitelist", addr))]) {
            boolStorage[keccak256(abi.encodePacked("whitelist", addr))] = true;
            emit WhitelistedAddressAdded(addr);
            success = true; 
        }
    }

    /**
    * @dev add addresses to the whitelist
    * @param addrs addresses
    * @return true if at least one address was added to the whitelist, 
    * false if all addresses were already in the whitelist  
    */
    function addAddressesToWhitelist(address[] memory addrs) public onlyOwner returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addAddressToWhitelist(addrs[i])) {
                success = true;
            }
        }
    }

    /**
    * @dev remove an address from the whitelist
    * @param addr address
    * @return true if the address was removed from the whitelist, 
    * false if the address wasn't in the whitelist in the first place 
    */
    function removeAddressFromWhitelist(address addr) public onlyOwner returns(bool success) {
        if (boolStorage[keccak256(abi.encodePacked("whitelist", addr))]) {
            boolStorage[keccak256(abi.encodePacked("whitelist", addr))] = false;
            emit WhitelistedAddressRemoved(addr);
            success = true;
        }
    }

    /**
    * @dev remove addresses from the whitelist
    * @param addrs addresses
    * @return true if at least one address was removed from the whitelist, 
    * false if all addresses weren't in the whitelist in the first place
    */
    function removeAddressesFromWhitelist(address[] memory addrs) public onlyOwner returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if(removeAddressFromWhitelist(addrs[i])) {
                success = true;
            }
        }
    }

    /**
    * @dev checks if address is whitelisted
    * @param addr address
    * @return true if address is whitelisted, false if not
    */
    function isWhitelisted(address addr) public view returns(bool whitelisted) {
        if (boolStorage[keccak256(abi.encodePacked("whitelist", addr))]) {
            whitelisted = true;
        } else {
            whitelisted = false;
        }
    }
}
