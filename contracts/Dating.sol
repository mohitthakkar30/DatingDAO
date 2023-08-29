// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Dating is ERC20 {
    struct Message {
        string to;
        string message;
    }

    struct Notification {
        string user;
        string friend;
        string typeOfRequest;
    }

    struct User {
        string username;
        uint256 age;
        string gender;
        string profilePic;
        bytes32 password;
        bool isCommited;
        uint256 likes;
    }

    address internal owner;
    string[] public userNames;
    mapping(string => User[]) public users;
    mapping(string => Notification[]) internal notifications;
    mapping(string => Message[]) internal messages;
    mapping(string => string[]) internal friends;
    mapping(string => string[]) internal likedBy;
    mapping(string => bool) internal isUser;
    string public handSomeGuy;
    uint256 public handSomeLikes = 0;
    string public sexyChick;
    uint256 public sexyChickLikes = 0;
    bool public isLoggedIn = false;
    string public loggedInUserName;
    event liked(string by, string to);
    event newUser(string name);
    event newHandsome(string name);
    event newSexyChick(string name);

    constructor() ERC20("DATE", "DATE") {
        owner = payable(msg.sender);
        _mint(msg.sender, 100000);
    }

    function isCommited() public view returns (bool) {
        return users[loggedInUserName][0].isCommited;
    }

    function setCommited() public {
        users[loggedInUserName][0].isCommited = !(
            users[loggedInUserName][0].isCommited
        );
    }

    function _mintNewUserReward() internal {
        _mint(block.coinbase, 1000);
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal override {
        _mintNewUserReward();
        super._transfer(from, to, value);
    }

    function getLoggedInUser() public view returns (User memory) {
        return users[loggedInUserName][0];
    }

    function createUser(
        string memory _name,
        uint256 _age,
        string memory _gender,
        string memory _profilePic,
        string memory _password
    ) public returns (User memory) {
        require(!isUser[_name], "User with username already found");
        require(!isLoggedIn, "you are already logged In");
        users[_name].push(
            User(
                _name,
                _age,
                _gender,
                _profilePic,
                keccak256(abi.encode(_password)),
                false,
                0
            )
        );
        _transfer(owner, msg.sender, 500);
        userNames.push(_name);
        emit newUser(_name);
        isUser[_name] = !isUser[_name];
        return users[_name][0];
    }

    function logIn(
        string memory _name,
        string memory _password
    ) public returns (bool) {
        require(!isLoggedIn, "you are already logged In");
        require(isUser[_name], "user not found");
        require(
            users[_name][0].password == keccak256(abi.encode(_password)),
            "message"
        );
        isLoggedIn = true;
        loggedInUserName = _name;
        return true;
    }

    function logOut() public returns (bool) {
        require(isLoggedIn, "you are already logged out");
        isLoggedIn = false;
        loggedInUserName = "";
        loggedInUserName;
        return true;
    }
}
