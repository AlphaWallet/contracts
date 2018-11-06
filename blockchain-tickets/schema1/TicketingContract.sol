pragma solidity ^0.4.17;
contract TicketPro
{
    mapping(address => uint256[]) inventory;
    address organiser;
    address paymaster;
    string public name;
    string public symbol;
    uint8 public constant decimals = 0; //no decimals as tickets cannot be split

    event Transfer(address indexed _to, uint256[] _indices);
    event TransferFrom(address indexed _from, address indexed _to, uint256[] _indices);
    event Trade(address indexed seller, uint256[] indices, uint8 v, bytes32 r, bytes32 s);
    event PassTo(uint256[] indices, uint8 v, bytes32 r, bytes32 s, address indexed recipient);

    modifier organiserOnly()
    {
        if(msg.sender != organiser) revert();
        else _;
    }

    modifier payMasterOnly()
    {
        if(msg.sender != paymaster) revert();
        else _;
    }

    function() public { revert(); } //should not send any ether directly


    constructor (
        uint256[] tickets,
        string nameOfContract,
        string symbolForContract,
        address organiserAddr,
        address paymasterAddr,
        address recipientAddr) public
    {
        name = nameOfContract;
        symbol = symbolForContract;
        organiser = organiserAddr;
        paymaster = paymasterAddr;
        inventory[recipientAddr] = tickets;
    }

    function getDecimals() public pure returns(uint)
    {
        return decimals;
    }

    // example: 0, [3, 4], 27, "0x9CAF1C785074F5948310CD1AA44CE2EFDA0AB19C308307610D7BA2C74604AE98", "0x23D8D97AB44A2389043ECB3C1FB29C40EC702282DB6EE1D2B2204F8954E4B451"
    // price is encoded in the server and the msg.value is added to the message digest,
    // if the message digest is thus invalid then either the price or something else in the message is invalid
    function trade(uint256 expiry,
                   uint256[] indices,
                   uint8 v,
                   bytes32 r,
                   bytes32 s) public payable
    {
        //checks expiry timestamp,
        //if fake timestamp is added then message verification will fail
        require(expiry > block.timestamp || expiry == 0);

        bytes32 message = encodeMessage(msg.value, expiry, indices);
        address seller = ecrecover(message, v, r, s);

        for(uint i = 0; i < indices.length; i++)
        { // transfer each individual tickets in the ask order
            uint256 index = indices[i];
            assert(inventory[seller][index] != uint256(0)); // 0 means ticket gone.
            inventory[msg.sender].push(inventory[seller][index]);
            // 0 means ticket gone.
            delete inventory[seller][index];
        }
        seller.transfer(msg.value);

        emit Trade(seller, indices, v, r, s);
    }

    function loadNewTickets(uint256[] tickets) public
    {
        require(msg.sender == organiser);
        for(uint i = 0; i < tickets.length; i++)
        {
            inventory[organiser].push(tickets[i]);
        }
    }

    function passTo(uint256 expiry,
                    uint256[] indices,
                    uint8 v,
                    bytes32 r,
                    bytes32 s,
                    address recipient) public payMasterOnly
    {
        require(expiry > block.timestamp || expiry == 0);
        bytes32 message = encodeMessage(0, expiry, indices);
        address giver = ecrecover(message, v, r, s);
        for(uint i = 0; i < indices.length; i++)
        {
            uint256 index = indices[i];
            //needs to use revert as all changes should be reversed
            //if the user doesnt't hold all the tickets
            assert(inventory[giver][index] != uint256(0));
            uint256 ticket = inventory[giver][index];
            inventory[recipient].push(ticket);
            delete inventory[giver][index];
        }

        emit PassTo(indices, v, r, s, recipient);
    }

    // although not in the parameter list, contractAddress will be
    // included in the message to be signed as well
    function encodeMessage(uint value, uint expiry, uint256[] indices)
        internal view returns (bytes32)
    {
        bytes memory message = new bytes(84 + indices.length * 2);
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

        // including contractAddress in the message to be signed.
        for(i = 0; i < 20; i++)
        {
            message[64 + i] = byte(bytes20(bytes20(contractAddress) << (8 * i)));
        }

        for (i = 0; i < indices.length; i++)
        {
            // convert int[] to bytes
            message[84 + i * 2 ] = byte(indices[i] >> 8);
            message[84 + i * 2 + 1] = byte(indices[i]);
        }

        return keccak256(message);
    }

    function name() public view returns(string)
    {
        return name;
    }

    function symbol() public view returns(string)
    {
        return symbol;
    }

    function balanceOf(address _owner) public view returns (uint256[])
    {
        return inventory[_owner];
    }

    function myBalance() public view returns(uint256[]){
        return inventory[msg.sender];
    }

    function transfer(address _to, uint256[] indices) public
    {
        for(uint i = 0; i < indices.length; i++)
        {
            uint index = uint(indices[i]);
            assert(inventory[msg.sender][index] != uint256(0));
            //pushes each element with ordering
            inventory[_to].push(inventory[msg.sender][index]);
            delete inventory[msg.sender][index];
        }
        emit Transfer(_to, indices);
    }

    function transferFrom(address _from, address _to, uint256[] indices)
        organiserOnly public
    {
        for(uint i = 0; i < indices.length; i++)
        {
            uint index = uint(indices[i]);
            assert(inventory[_from][index] != uint256(0));
            //pushes each element with ordering
            inventory[_to].push(inventory[msg.sender][index]);
            delete inventory[_from][index];
        }

        emit TransferFrom(_from, _to, indices);
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
