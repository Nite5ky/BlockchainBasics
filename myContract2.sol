// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

contract myContract {

    string myName = "Aakash Yadav";

    function sayMyName() public view returns (string memory) {
        return myName;
    }

    function changeMyName( string memory myNewName ) public returns (string memory) {
        myName = myNewName;

        return myName;
    }
}
