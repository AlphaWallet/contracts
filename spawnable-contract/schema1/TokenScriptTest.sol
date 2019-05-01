// "TokenScript Plaza", "Web3 Street", "Sydney", "NSW", "TKS", "TokenScript Test Tokens"
//Mainnet: 0x63cCEF733a093E5Bd773b41C96D3eCE361464942
//Ropsten: 0xFB82A5a2922A249f32222316b9D1F5cbD3838678
//Rinkeby: 0x7c81DF31BB2f54f03A56Ab25c952bF3Fa39bDF46
//Kovan: 0x2B58A9403396463404c2e397DBF37c5EcCAb43e5

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

