pragma solidity ^0.4.17;
contract ERC875Interface {
    function trade(uint256 expiry, uint16[] ticketIndices, uint8 v, bytes32 r, bytes32 s) public payable;
    function loadNewTickets(bytes32[] tickets) public;
    function passTo(uint256 expiry, uint16[] ticketIndices, uint8 v, bytes32 r, bytes32 s, address recipient) public;
    function name() public view returns(string);
    function symbol() public view returns(string);
    function getAmountTransferred() public view returns (uint);
    function balanceOf(address _owner) public view returns (bytes32[]);
    function myBalance() public view returns(bytes32[]);
    function transfer(address _to, uint16[] ticketIndices) public;
    function transferFrom(address _from, address _to, uint16[] ticketIndices) public;
    function approve(address _approved, uint16[] ticketIndices) public;
    function checkAllowed(address owner, address proxy) public view returns (uint16[] ticketIndices);
    function endContract() public;
    function contractType() public pure returns (string);
    function getContractAddress() public view returns(address);

    event Transfer(address indexed _to, uint16[] _indices);
    event TransferFrom(address indexed _from, address indexed _to, uint16[] _indices);
    event Trade(address indexed seller, uint16[] ticketIndices, uint8 v, bytes32 r, bytes32 s);
    event PassTo(uint16[] ticketIndices, uint8 v, bytes32 r, bytes32 s, address indexed recipient);
    event Approval(address indexed owner, address indexed _approved, uint indexed ticketCount);
}