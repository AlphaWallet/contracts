contract Proxy {
    function transferFrom(address from, address to, uint tokens) external returns (bool success){}
}

// Admin account (Trezor): 0xc2667d2B3949D3B11dD273559297BdC84dB1126b
// Paymaster account (attaches Ether): 0x0d590124d2faabbbdfa5561ccbf778914a50bcca
// Deployed on mainnet: 0xaB34A8B5Df7048c971f50dfa38d5e45D50638eC7
//ERC20 compat but implemented functions do nothing
contract AlphaWalletDiscover {
    
    address payable admin;
    address paymaster;
    uint public decimals = 0;
    string public symbol = "ALP";
    string public name = "AlphaWallet Discover";

    constructor(address payable assignedAdmin, address payable assignedPaymaster) public {
        admin = assignedAdmin;
        paymaster = assignedPaymaster;
    }
    
    function() external {
        //contract shouldn't hold or recieve any ether or tokens
        revert();
    }
    
    function balanceOf(address owner) public pure returns(uint) {
        return 1;
    }
    
    //be aware that some services use different decimals for their tokens 
    //admin must approve this contract to move funds
    //can still use this for erc721 tokens, replacing amount for tokenId 
    function discover(
        address[] memory services, 
        address payable user, 
        uint[] memory amounts
    ) public payable returns(bool) {
        require(msg.sender == paymaster || msg.sender == admin);
        //Discover allows an AlphaWallet user to recieve a small airdrop of a particular token service
        //Example: user wants to discover Compound, we airdrop cDAI and they have the cards automatically show up in their wallet
        for(uint i = 0; i < services.length; i++) {
            Proxy proxy = Proxy(services[i]);
            //Either all tokens are sent or none are sent as transferFrom will throw
            //if it fails
            proxy.transferFrom(admin, user, amounts[i]);
        }
        user.transfer(msg.value);
        return true;
    }
    
    function changePaymaster(address newPaymaster) public {
        require(msg.sender == admin);
        paymaster = newPaymaster;
    }
    
    function transfer(address to, uint amount) public pure returns(bool) {
        //do nothing
        return false;
    }
    
    function transferFrom(address to, uint amount) public pure returns(bool) {
        //do nothing
        return false;
    }
    
    function approve(address recipient, uint amount) public pure returns (bool){
        //do nothing
        return false;
    }
    
    function allowance(address tokenOwner, address spender) external pure returns (uint) {
        //do nothing
        return 0;
    }
    
    function totalSupply() external pure returns (uint) {
        //placeholder
        return 9999999;
    }
    
    function terminate() public {
        require(msg.sender == admin);
        //contract holds zero funds 
        //By terminating we do not need to revert allowances granted to this contract
        selfdestruct(admin);
    }
    
}
