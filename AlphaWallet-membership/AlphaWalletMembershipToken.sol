contract Proxy {
    function transferFrom(address from, address to, uint tokens) external returns (bool success){}
}

//ERC20 compat but implemented functions do nothing
contract AlphaWalletDiscover {
    
    modifier authorised {
        require(msg.sender == paymaster || msg.sender == admin);
        _;
    }
    
    address payable admin;
    address paymaster;
    uint public decimals = 0;
    string public symbol = "ALP";
    string public name = "AlphaWallet Discover";

    constructor(address payable assignedAdmin, address assignedPaymaster) public {
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
        address user, 
        uint[] memory amount
    ) public authorised returns(bool) {
        //Discover allows an AlphaWallet user to recieve a small airdrop of a particular token service
        //Example: user wants to discover Compound, we airdrop cDAI and they have the cards automatically show up in their wallet
        for(uint i = 0; i < services.length; i++) {
            Proxy proxy = Proxy(services[i]);
            //Either all tokens are sent or none are sent 
            require(proxy.transferFrom(admin, user, amount[i]));
        }
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
