// "TokenScript Plaza", "Web3 Street", "Sydney", "NSW", "TKS", "TokenScript Test Tokens"
//Mainnet: 0xFd838c7A0c32D68533ec713Ed631B6B7C8720cED
//Ropsten: 0x3c22BeB7427A57Ab7d532a974F4bBaD7969CAaD3
//Rinkeby: 0x4A60c0bf93b2b3a3D20720a773E5Da8C80C427ac
//Kovan: 0x5bD04312e79392F042eC730961d107482D3EF19f
//Goerli: 0x0C18E83E7D07E2188496467c4102D6D79Dcf1BD1

pragma solidity ^0.4.25;
contract TokenScriptTest
{
    string public name;
    uint8 public constant decimals = 0; //no decimals as tickets cannot be split
    string public state;
    string public locality;
    string public street;
    string public building;
    string public symbol;
    uint256[] public dummyBalance;

    function() payable public { revert(); } //should not send any ether directly

    constructor (
        string buildingName,
        string streetName,
        string localityName,
        string stateName,
        string symbolName,
        string contractName) public
    {
        building = buildingName;
        street = streetName;
        locality = localityName;
        state = stateName;
        symbol = symbolName;
        name = contractName;
        dummyBalance.push(0x474D542B33000000000000000000000001075B2282F05255534B534101050002);
        dummyBalance.push(0x474D542B33000000000000000000000001075B2282F05255534B534101050001);
    }

    function getStreet(uint256 tokenId) public view returns(string)
    {
        return street;
    }
    
    function isExpired(uint256 tokenId) public view returns(bool) {
        return false; 
    }

    function getBuildingName(uint256 tokenId) public view returns(string)
    {
        return building;
    }

    function getState(uint256 tokenId) public view returns(string)
    {
        return state;
    }

    function getLocality(uint256 tokenId) public view returns(string)
    {
        return locality;
    }

    function getDecimals() public pure returns(uint)
    {
        return decimals;
    }

    function name() public view returns(string)
    {
        return name;
    }

    function getSymbol() public view returns(string)
    {
        return symbol;
    }

    //for testing, user can get back a dummy balance to test with
    function balanceOf(address _owner) public view returns (uint256[])
    {
        return dummyBalance;
    }

    function isStormBirdContract() public pure returns (bool)
    {
        return true;
    }

}

