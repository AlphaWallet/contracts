//magic link encoding 0x04
//send any native currency to this contract and use the contract balance to move the funds
//Ropsten: 0x9d928a678eeaaEfA19eF73E5368830b3476C0678
pragma solidity 0.5.1;
contract NativeCryptoDispensary {

    bytes8 public requiredPrefix = "XDAIDROP";
    address payable approvedSigner;
    uint32[] nonces;
    address approvedPaymaster;

    constructor(address paymaster, address payable signer) public {
        approvedPaymaster = paymaster;
        approvedSigner = signer;
    }

    function() payable external {
        //allow deposits
        require(msg.sender == approvedPaymaster);
    }

    function dropCurrency(
        uint32 nonce,
        uint32 amount,
        uint32 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s,
        address payable receiver
    ) public {
        //stop people from stealing drops by enforcing a paymaster to use it
        require(msg.sender == approvedPaymaster);
        require(block.timestamp < expiry);
        checkIfNonceUsed(nonce);
        //message is signed with szabo price
        bytes32 message = formMessage(nonce, amount, expiry, address(this));
        require(ecrecover(message, v, r, s) == approvedSigner);
        nonces.push(nonce);
        //price is signed as szabo units
        uint256 weiValue = uint256(amount) * (1 szabo); //need to cast to uint256 otherwise value is corrupted
        receiver.transfer(weiValue);
    }

    function formMessage(
        uint32 nonce,
        uint32 amount,
        uint32 expiry,
        address contractAddress
    ) internal view returns(bytes32) {
        bytes memory message = new bytes(40);
        for(uint i = 0; i < 8; i++) {
            message[i] = byte(bytes8(requiredPrefix << (8 * i)));
        }
        for(uint i = 0; i < 4; i++) {
            message[i + 8] = byte(bytes4(nonce << (8 * i)));
        }
        for(uint i = 0; i < 4; i++) {
            message[i + 12] = byte(bytes4(amount << (8 * i)));
        }
        for(uint i = 0; i < 4; i++) {
            message[i + 16] = byte(bytes4(expiry << (8 * i)));
        }
        for(uint i = 0; i < 20; i++) {
            message[i + 20] = byte(bytes20(contractAddress) << (8 * i));
        }
        return keccak256(message);
    }

    function checkIfNonceUsed(uint32 nonce) internal view {
        for(uint i = 0; i < nonces.length; i++) {
            require(nonces[i] != nonce);
        }
    }

    function withdraw(uint value) public {
        require(msg.sender == approvedSigner);
        approvedSigner.transfer(value);
    }

}
