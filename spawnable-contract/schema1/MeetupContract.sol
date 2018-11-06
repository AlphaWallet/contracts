// [1,2], "0xEdd6D7ba0FF9f4bC501a12529cb736CA76A4fe7e", "0xEdd6D7ba0FF9f4bC501a12529cb736CA76A4fe7e", "0xEdd6D7ba0FF9f4bC501a12529cb736CA76A4fe7e", "test info", "test info", "test info", "test info", "test info"
pragma solidity ^0.4.17;
contract TicketPro
{
    mapping(address => uint256[]) inventory;
	uint256[] spawnedTickets;
    mapping(bytes32 => bool) signatureChecked;
    address organiser;
    address paymaster;
    uint numOfTransfers = 0;
    string public name;
    uint8 public constant decimals = 0; //no decimals as tickets cannot be split
    bool isExpired;
    string state;
    string street;
    string building;
    string symbol;
    bytes4 balHash = bytes4(keccak256('balanceOf(address)'));
    bytes4 tradeHash = bytes4(keccak256('trade(uint256,uint256[],uint8,bytes32,bytes32)'));
    bytes4 passToHash = bytes4(keccak256('passTo(uint256,uint256[],uint8,bytes32,bytes32,address)'));
    bytes4 spawnPassToHash = bytes4(keccak256('spawnPassTo(uint256,uint256[],uint8,bytes32,bytes32,address)'));

    event Transfer(address indexed _to, uint256 count);
    event TransferFrom(address indexed _from, address indexed _to, uint256 count);
    event Trade(address indexed seller, uint256[] ticketIndices, uint8 v, bytes32 r, bytes32 s);
    event PassTo(uint256[] ticketIndices, uint8 v, bytes32 r, bytes32 s, address indexed recipient);

    modifier organiserOnly()
    {
        require(msg.sender == organiser);
        _;
    }

    modifier payMasterOnly()
    {
        require(msg.sender == paymaster);
        _;
    }

    function() payable public { revert(); } //should not send any ether directly

    constructor (
        uint256[] tickets,
        address organiserAddr,
        address paymasterAddr,
        address recipientAddr,
        string streetName,
        string buildingName,
        string stateName,
        string symbolName,
        string contractName) public
    {
        organiser = organiserAddr;
        paymaster = paymasterAddr;
        inventory[recipientAddr] = tickets;
        street = streetName;
        building = buildingName;
        state = stateName;
        symbol = symbolName;
        name = contractName;
    }

    function supportsInterface(bytes4 interfaceID) external view returns (bool)
    {
        if(interfaceID == balHash
        || interfaceID == tradeHash
        || interfaceID == passToHash
        || interfaceID == spawnPassToHash) return true;
        return false;
    }

    function expired(uint256 tokenId) public view returns(bool)
    {
        return true;
    }

    function getStreet(uint256 tokenId) public view returns(string)
    {
        return street;
    }

    function getBuilding(uint256 tokenId) public view returns(string)
    {
        return building;
    }

    function getState(uint256 tokenId) public view returns(string)
    {
        return state;
    }

    function setExpired(uint256[] tokenIds) public organiserOnly
    {
        isExpired = true;
    }

    function setStreet(uint256[] tokenIds, string streetName) public view organiserOnly returns(string)
    {
        street = streetName;
    }

    function setBuilding(uint256[] tokenIds, string buildingName) public view organiserOnly returns(string)
    {
        building = buildingName;
    }

    function setState(uint256[] tokenIds, string stateName) public view organiserOnly returns(string)
    {
        state = stateName;
    }

    // example: 0, [3, 4], 27, "0x9CAF1C785074F5948310CD1AA44CE2EFDA0AB19C308307610D7BA2C74604AE98", "0x23D8D97AB44A2389043ECB3C1FB29C40EC702282DB6EE1D2B2204F8954E4B451"
    // price is encoded in the server and the msg.value is added to the message digest,
    // if the message digest is thus invalid then either the price or something else in the message is invalid
    function trade(uint256 expiry,
                   uint256[] ticketIndices,
                   uint8 v,
                   bytes32 r,
                   bytes32 s) public payable
    {
        //checks expiry timestamp,
        //if fake timestamp is added then message verification will fail
        require(expiry > block.timestamp || expiry == 0);

        bytes32 message = encodeMessage(msg.value, expiry, ticketIndices);
        address seller = ecrecover(message, v, r, s);

        for(uint i = 0; i < ticketIndices.length; i++)
        { // transfer each individual tickets in the ask order
            uint256 index = ticketIndices[i];
            assert(inventory[seller][index] != uint256(0)); // 0 means ticket gone.
            inventory[msg.sender].push(inventory[seller][index]);
            // 0 means ticket gone.
            delete inventory[seller][index];
        }
        seller.transfer(msg.value);

        emit Trade(seller, ticketIndices, v, r, s);
    }

    function loadNewTickets(uint256[] tickets) public organiserOnly
    {
        for(uint i = 0; i < tickets.length; i++)
        {
            inventory[organiser].push(tickets[i]);
        }
    }

    //for new tickets to be created and given over
    //this requires a special magic link format with tokenids inside rather than indicies
    function spawnPassTo(uint256 expiry,
                    uint256[] tickets,
                    uint8 v,
                    bytes32 r,
                    bytes32 s,
                    address recipient) public
    {
        require(expiry > block.timestamp || expiry == 0);
        bytes32 message = encodeMessageSpawnable(0, expiry, tickets);
        address giver = ecrecover(message, v, r, s);
        //only the organiser can authorise this
        require(giver == organiser);
        require(!signatureChecked[s]);
        for(uint i = 0; i < tickets.length; i++)
        {
            inventory[recipient].push(tickets[i]);
		        spawnedTickets.push(tickets[i]);
        }
    }

	  //check if a spawnable ticket that created in a magic link is redeemed
    function spawned(uint256 ticket) public view returns (bool)
    {
        for(uint i = 0; i < spawnedTickets.length; i++)
        {
            if(spawnedTickets[i] == ticket)
            {
                return true;
            }
        }
        return false;
    }

    function passTo(uint256 expiry,
                    uint256[] ticketIndices,
                    uint8 v,
                    bytes32 r,
                    bytes32 s,
                    address recipient) public payMasterOnly
    {
        require(expiry > block.timestamp || expiry == 0);
        bytes32 message = encodeMessage(0, expiry, ticketIndices);
        address giver = ecrecover(message, v, r, s);
        for(uint i = 0; i < ticketIndices.length; i++)
        {
            uint256 index = ticketIndices[i];
            //needs to use revert as all changes should be reversed
            //if the user doesnt't hold all the tickets
            assert(inventory[giver][index] != uint256(0));
            uint256 ticket = inventory[giver][index];
            inventory[recipient].push(ticket);
            delete inventory[giver][index];
        }

        emit PassTo(ticketIndices, v, r, s, recipient);
    }

    function encodeMessage(uint value, uint expiry, uint256[] ticketIndices)
        internal view returns (bytes32)
    {
        bytes memory message = new bytes(84 + ticketIndices.length * 2);
        address contractAddress = getContractAddress();
        for (uint i = 0; i < 32; i++)
        {   // convert bytes32 to bytes[32]
            // this adds the price to the message
            message[i] = byte(bytes32(value << (8 * i)));
        }

        for (i = 0; i < 32; i++)
        {
            message[i + 32] = byte(bytes32(expiry << (8 * i)));
        }

        for(i = 0; i < 20; i++)
        {
            message[64 + i] = byte(bytes20(bytes20(contractAddress) << (8 * i)));
        }

        for (i = 0; i < ticketIndices.length; i++)
        {
            // convert int[] to bytes
            message[84 + i * 2 ] = byte(ticketIndices[i] >> 8);
            message[84 + i * 2 + 1] = byte(ticketIndices[i]);
        }

        return keccak256(message);
    }

    function encodeMessageSpawnable(uint value, uint expiry, uint256[] tickets)
        internal view returns (bytes32)
    {
        bytes memory message = new bytes(84 + tickets.length * 32);
        address contractAddress = getContractAddress();
        for (uint i = 0; i < 32; i++)
        {   // convert bytes32 to bytes[32]
            // this adds the price to the message
            message[i] = byte(bytes32(value << (8 * i)));
        }

        for (i = 0; i < 32; i++)
        {
            message[i + 32] = byte(bytes32(expiry << (8 * i)));
        }

        for(i = 0; i < 20; i++)
        {
            message[64 + i] = byte(bytes20(bytes20(contractAddress) << (8 * i)));
        }

        for (i = 0; i < tickets.length; i++)
        {
            message[84 + i * 32 +31] = byte(tickets[i]);
            // convert uint256[] to bytes
            for (uint j = 1; j < 32; j++)
            {
                message[84 + i * 32 + 31 - j] = byte(tickets[i] = tickets[i] >> 8);
            }
        }
        return keccak256(message);
    }

    function getSymbol() public view returns(string)
    {
        return symbol;
    }

    function getAmountTransferred() public view returns (uint)
    {
        return numOfTransfers;
    }

    function balanceOf(address _owner) public view returns (uint256[])
    {
        return inventory[_owner];
    }

    function myBalance() public view returns(uint256[])
    {
        return inventory[msg.sender];
    }

    function transfer(address _to, uint256[] ticketIndices) public
    {
        for(uint i = 0; i < ticketIndices.length; i++)
        {
            uint index = uint(ticketIndices[i]);
            assert(inventory[msg.sender][index] != uint256(0));
            //pushes each element with ordering
            inventory[_to].push(inventory[msg.sender][index]);
            delete inventory[msg.sender][index];
        }
        emit Transfer(_to, ticketIndices.length);
    }

    function transferFrom(address _from, address _to, uint256[] ticketIndices)
        organiserOnly public
    {
        for(uint i = 0; i < ticketIndices.length; i++)
        {
            uint index = uint(ticketIndices[i]);
            assert(inventory[_from][index] != uint256(0));
            //pushes each element with ordering
            inventory[_to].push(inventory[msg.sender][index]);
            delete inventory[_from][index];
        }

        emit TransferFrom(_from, _to, ticketIndices.length);
    }

    function endContract() public organiserOnly
    {
        selfdestruct(organiser);
    }

    function isStormBirdContract() public pure returns (bool)
    {
        return true;
    }

    function getContractAddress() public view returns(address)
    {
        return this;
    }

}
