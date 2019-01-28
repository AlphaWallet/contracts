//magic link encoding 0x04
//send dai to this contract and use the contract balance to move the funds
pragma solidity 0.5.1;
contract NativeCryptoDispensary {

    string public requiredPrefix = "XDAIDROP";
    address payable approvedSigner;
    uint[] nonces;
    address approvedPaymaster;
    
    constructor(address paymaster, address payable signer) public {
        approvedPaymaster = paymaster;
        approvedSigner = signer;
    }
    
    function dropCurrency(
        uint nonce, 
        uint amount,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s,
        address payable reciever
    ) public {
        //stop people from stealing drops by enforcing a paymaster to use it
        require(msg.sender == approvedPaymaster);
        require(block.timestamp < expiry);
        checkIfNonceUsed(nonce);
        bytes32 message = keccak256(abi.encodePacked(requiredPrefix, nonce, amount, expiry, this));
        require(ecrecover(message, v, r, s) == approvedSigner);
        //price is signed as szabo units 
        reciever.transfer(amount * (1 szabo));
    }
    
    function checkIfNonceUsed(uint nonce) internal view {
        for(uint i = 0; i < nonces.length; i++) {
            if(nonces[i] == nonce) {
                revert();
            }
        }
    }
    
    function withdraw(uint value) public {
        require(msg.sender == approvedSigner);
        approvedSigner.transfer(value);
    }
    
}
