//mainnet: 0xA66A3F08068174e8F005112A8b2c7A507a822335

// ["0x474d542b330000000000000000000000020b5b23d4704d415249524e04050001",
// "0x474d542b330000000000000000000000020b5b23d4704d415249524e04050002",
// "0x474d542b330000000000000000000000010a5b291a70504f4c53454e0f050001",
// "0x474d542b330000000000000000000000010a5b291a70504f4c53454e0f050002",
// "0x474d542b330000000000000000000000020b5b2944a052555345475911050001",
// "0x474d542b330000000000000000000000020b5b2944a052555345475911050002",
// "0x474d542b33000000000000000000000006055b3fae205735335735343a050001",
// "0x474d542b33000000000000000000000006055b3fae205735335735343a050002",
// "0x474d542b330000000000000000000000020b5b4a01e04c36314c36323f050001",
// "0x474d542b330000000000000000000000020b5b4a01e04c36314c36323f050002",
// "0x474d542b33000000000000000000000001075b2282f05255534b534101050001",
// "0x474d542b33000000000000000000000001075b2282f05255534b534101050002",
// "0x474d542b33000000000000000000000001075b2282f05255534b534101050003",
// "0x474d542b33000000000000000000000001075b2282f05255534b534101050004",
// "0x474d542b33000000000000000000000001075b2282f05255534b534101050005",
// "0x474d542b33000000000000000000000001075b2282f05255534b534101050006",
// "0x474d542b33000000000000000000000001075b2282f05255534b534101050007",
// "0x474d542b33000000000000000000000001075b2282f05255534b534101050008",
// "0x474d542b33000000000000000000000001075b2282f05255534b534101050009",
// "0x474d542b33000000000000000000000001075b2282f05255534b53410105000a",
// "0x474d542b33000000000000000000000001075b2282f05255534b53410105000b",
// "0x474d542b33000000000000000000000001075b2282f05255534b53410105000c",
// "0x474d542b33000000000000000000000001075b2282f05255534b53410105000d",
// "0x474d542b33000000000000000000000001075b2282f05255534b53410105000e",
// "0x474d542b33000000000000000000000001075b2282f05255534b53410105000f",
// "0x474d542b33000000000000000000000001075b2282f05255534b534101050010",
// "0x474d542b33000000000000000000000001075b2282f05255534b534101050011",
// "0x474d542b33000000000000000000000001075b2282f05255534b534101050012",
// "0x474d542b33000000000000000000000001075b2282f05255534b534101050013",
// "0x474d542b33000000000000000000000001075b2282f05255534b534101050014"],
// "FIFA WC2018",
// "SHANKAI",
// "0x0D590124d2fAaBbbdFa5561ccBf778914a50BCca",
// "0xFE6d4bC2De2D0b0E6FE47f08A28Ed52F9d052A02",
// "0x2e558Bc42E2e37aB638daebA5CD1062e5b9923De"

pragma solidity ^0.4.17;
contract TicketPro
{
    mapping(address => uint256[]) inventory;
    address organiser;
    address paymaster;
    string public name;
    string public symbol;
    uint8 public constant decimals = 0; //no decimals as tickets cannot be split

    event Transfer(address indexed _to, uint256[] tickets);
    event TransferFrom(address indexed _from, address indexed _to, uint256[] tickets);
    event Trade(address indexed seller, uint256[] tickets, uint8 v, bytes32 r, bytes32 s);
    event PassTo(uint256[] tickets, uint8 v, bytes32 r, bytes32 s, address indexed recipient);

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

    // example: 0, [0x9CAF1C785074F5948310CD1AA44CE2EFDA0AB19C308307610D7BA2C74604AE98], 27, "0x9CAF1C785074F5948310CD1AA44CE2EFDA0AB19C308307610D7BA2C74604AE98", "0x23D8D97AB44A2389043ECB3C1FB29C40EC702282DB6EE1D2B2204F8954E4B451"
    // price is encoded in the server and the msg.value is added to the message digest,
    // if the message digest is thus invalid then either the price or something else in the message is invalid
    function trade(uint256 expiry,
                   uint256[] tickets,
                   uint8 v,
                   bytes32 r,
                   bytes32 s) public payable
    {
        //checks expiry timestamp,
        //if fake timestamp is added then message verification will fail
        require(expiry > block.timestamp || expiry == 0);

        bytes32 message = encodeMessage(msg.value, expiry, tickets);
        address seller = ecrecover(message, v, r, s);

        //increment sellers tickets to make sure they have them
        for(uint i = 0; i < tickets.length; i++)
        {
            bool found = false;
            for(uint j = 0; j < tickets.length; j++)
            {
                if(inventory[seller][j] == tickets[i])
                {
                    found = true;
                    inventory[msg.sender].push(inventory[seller][j]);
                    delete inventory[seller][j];
                    break;
                }
            }
            //if any ticket up for sale is not found, revert state
            //assert will revert all changes back to pre transaction
            assert(found);
        }
        emit Trade(seller, tickets, v, r, s);
    }

    function loadNewTickets(uint256[] tickets) public
    {
        require(msg.sender == organiser);
        for(uint i = 0; i < tickets.length; i++)
        {
            inventory[organiser].push(tickets[i]);
        }
    }

    //for new tickets to be created and given over
    function passTo(uint256 expiry,
                    uint256[] tickets,
                    uint8 v,
                    bytes32 r,
                    bytes32 s,
                    address recipient) public
    {
        require(msg.sender == paymaster);
        require(expiry > block.timestamp || expiry == 0);
        bytes32 message = encodeMessage(0, expiry, tickets);
        address giver = ecrecover(message, v, r, s);
        //only the organiser can authorise this
        require(giver == organiser);
        for(uint i = 0; i < tickets.length; i++)
        {
            inventory[recipient].push(tickets[i]);
        }
        emit PassTo(tickets, v, r, s, recipient);
    }

    //when a user sends a ticket to another but the gas is covered by the payment server
    function passToOnBehalfOfUser(uint256 expiry,
                    uint256[] tickets,
                    uint8 v,
                    bytes32 r,
                    bytes32 s,
                    address recipient) public
    {
        require(msg.sender == paymaster);
        require(expiry > block.timestamp || expiry == 0);
        bytes32 message = encodeMessage(0, expiry, tickets);
        address giver = ecrecover(message, v, r, s);
        //increment givers tickets to make sure they have them
        for(uint i = 0; i < tickets.length; i++)
        {
            bool found = false;
            for(uint j = 0; j < tickets.length; j++)
            {
                if(inventory[giver][j] == tickets[i])
                {
                    found = true;
                    break;
                }
            }
            //if any ticket up for sale is not found, revert state
            //assert will revert all changes back to pre transaction
            assert(found);
            inventory[recipient].push(tickets[i]);
            delete inventory[giver][i];
        }
        emit PassTo(tickets, v, r, s, recipient);
    }

    //must also sign in the contractAddress
    function encodeMessage(uint value, uint expiry, uint256[] tickets)
        internal view returns (bytes32)
    {
        //32 bytes per ticket, must be * 32
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
            // convert uint256[] to bytes
            // TODO need clarification with Weiwu
            message[84 + i * 32 ] = byte(tickets[i] >> 256);
            //message[84 + i * 32 + 1] = byte(tickets[i]);
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

    function transfer(address _to, uint256[] tickets) public
    {
        //increment sellers tickets to make sure they have them
        for(uint i = 0; i < tickets.length; i++)
        {
            bool found = false;
            for(uint j = 0; j < tickets.length; j++)
            {
                if(inventory[msg.sender][j] == tickets[i])
                {
                    found = true;
                    break;
                }
            }
            //if any ticket up for sale is not found, revert state
            //assert will revert all changes back to pre transaction
            assert(found);
            inventory[_to].push(tickets[i]);
            delete inventory[msg.sender][i];
        }
        emit Transfer(_to, tickets);
    }

    function transferFrom(address _from, address _to, uint256[] tickets) public
    {
        require(msg.sender == organiser);
        //increment sellers tickets to make sure they have them
        for(uint i = 0; i < tickets.length; i++)
        {
            bool found = false;
            for(uint j = 0; j < tickets.length; j++)
            {
                if(inventory[_from][j] == tickets[i])
                {
                    found = true;
                    break;
                }
            }
            //if any ticket up for sale is not found, revert state
            //assert will revert all changes back to pre transaction
            assert(found);
            inventory[_to].push(tickets[i]);
            delete inventory[_from][i];
        }
        emit TransferFrom(_from, _to, tickets);
    }

    function endContract() public
    {
        require(msg.sender == organiser);
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
