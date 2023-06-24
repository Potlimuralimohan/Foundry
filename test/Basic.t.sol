//SPDX-Licence-Identifier:MIT

pragma solidity ^0.8.0;

import {Test,console} from "lib/forge-std/src/Test.sol";

contract FundMeTest is Test{
    uint256 number=1;
    function setUp() external {
        number=2;
    }

    function testDemo() public{
        console.log(number);
        console.log("Hello!");
        assertEq(number,2);
    }
}