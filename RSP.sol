// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract RSP {
    enum Move {
        rock,
        scissors,
        paper
    }

    address[] public players;
    mapping(address => Move) moves;
    mapping(address => bytes32) commitments;
    mapping(address => bool) reveals;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not an owner");
        _;
    }

    modifier onlyPlayer() {
        require(commitments[msg.sender] != 0x0, "the sender is not a player");
        _;
    }

    modifier allCommited() {
        require(
            commitments[players[0]] != 0x0 && commitments[players[1]] != 0x0,
            "not enough players"
        );
        _;
    }

    modifier allRevealed() {
        require(
            reveals[players[0]] && reveals[players[1]],
            "not all players have revealed their moves"
        );
        _;
    }

    function commit(bytes32 commitment) public {
        require(players.length < 2, "the game has already started");
        require(
            commitments[msg.sender] == 0x0,
            "the player is already a participant"
        );
        commitments[msg.sender] = commitment;
        players.push(msg.sender);
    }

    function reveal(
        uint8 move,
        string memory secret
    ) public onlyPlayer allCommited {
        require(!reveals[msg.sender], "the player has already revealed");
        require(0 <= move && move <= 2, "wrong move");
        require(
            keccak256(abi.encode(move, secret)) == commitments[msg.sender],
            "your input does not match your commitment"
        );
        moves[msg.sender] = RSP.Move(move);
        reveals[msg.sender] = true;
    }

    function getResult()
        public
        view
        allCommited
        allRevealed
        returns (address winner)
    {
        if (moves[players[0]] == moves[players[1]]) {
            return address(0x0);
        }

        if (
            (moves[players[0]] == Move.rock &&
                moves[players[1]] == Move.scissors) ||
            (moves[players[0]] == Move.scissors &&
                moves[players[1]] == Move.paper) ||
            (moves[players[0]] == Move.paper && moves[players[1]] == Move.rock)
        ) {
            return players[0];
        }

        return players[1];
    }

    function resetGame() public onlyOwner {
        require(players.length > 0, "the game hasn't started yet");
        commitments[players[0]] = 0x0;
        commitments[players[1]] = 0x0;
        reveals[players[0]] = false;
        reveals[players[1]] = false;
        delete players;
    }
}
