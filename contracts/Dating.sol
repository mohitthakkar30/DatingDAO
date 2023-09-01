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

    function sendFriendRequest(
        string memory _to
    ) public returns (Notification[] memory) {
        require(isLoggedIn, "you are already logged In");
        _transfer(msg.sender, owner, 20);
        notifications[_to].push(
            Notification(loggedInUserName, _to, "friend request")
        );
        return notifications[loggedInUserName];
    }

    string[] public friendsRequets;

    function acceptFriendRequest(
        string memory _friend
    ) public returns (Notification[] memory) {
        require(isLoggedIn, "you are already logged out");
        uint256 len = notifications[loggedInUserName].length;
        while (friendsRequets.length > 0) {
            friendsRequets.pop();
        }
        for (uint256 i = 0; i < len; i++) {
            if (
                keccak256(
                    abi.encode(notifications[loggedInUserName][i].user)
                ) == keccak256(abi.encode(_friend))
            ) {
                delete notifications[loggedInUserName][i];
                friends[loggedInUserName].push(_friend);
                friends[_friend].push(loggedInUserName);
            }
        }
        return notifications[loggedInUserName];
    }

    function sendMessage(
        string memory _to,
        string memory _msg
    ) public returns (Message[] memory) {
        uint256 noOfFriends = friends[loggedInUserName].length;
        for (uint256 i = 0; i < noOfFriends; i++) {
            if (
                keccak256(abi.encode(_to)) ==
                keccak256(abi.encode(friends[loggedInUserName][i]))
            ) {
                _transfer(msg.sender, owner, 20);
                messages[loggedInUserName].push(Message(_to, _msg));
                messages[_to].push(Message(loggedInUserName, _msg));
            }
        }
        return messages[loggedInUserName];
    }

    function getAllMessages() public view returns (Message[] memory) {
        return messages[loggedInUserName];
    }

    function getAllNotifications() public view returns (Notification[] memory) {
        return notifications[loggedInUserName];
    }

    function getAllUsers() public view returns (string[] memory) {
        return userNames;
    }
}
