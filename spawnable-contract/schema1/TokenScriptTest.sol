// "TokenScript Plaza", "Web3 Street", "Sydney", "NSW", "TKS", "TokenScript Test Tokens"
//Mainnet: 0x6a3b2a506f53d737bb5897f9d894075f8f7c931f
//Ropsten: 0x1E8bceEd258ca5C7Ed9f55639aBbd01d3F7d9992
//Rinkeby: 0x52C4E0CC1f8719Db88A3385756150dAE1814E7e0
//Kovan: 0x0C18E83E7D07E2188496467c4102D6D79Dcf1BD1
//Goerli: 0x17734f3709486B1D7015f941C069Cebf8017a833

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
    uint256[5] public dummyBalance= [0x474D32303138303931313139303230312b30383030F05255534B534101050002, 0x474D32303138303931313139303230312b30383030F05255534B534101050002, 0x474D32303138303931313139303230312b30383030F05255534B534101050002, 0x474D32303138303931313139303230312b30383030F05255534B534101050002, 0x474D32303138303931313139303230312b30383030F05255534B534101050002];

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
    }

    function getStreet(uint256 tokenId) public view returns(string)
    {
        return street;
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
    function balanceOf(address _owner) public view returns (uint256[5])
    {
        return dummyBalance;
    }

    function isStormBirdContract() public pure returns (bool)
    {
        return true;
    }

}
