// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/IncDec.sol";

contract CounterTest is Test {
    IncDec public incdec;

    function setUp()public{
        incdec=new IncDec();
    }
    function testinc() public{
        incdec.inc();
        assertEq(incdec.count(),1);

    }
    function testFaildec()public{
        incdec.dec();
    }
    function testDecUnderflow()public{
        vm.expectRevert(stdError.arithmeticError);
        incdec.dec();

    }
    function testdec()public{
        incdec.inc();
        incdec.inc();
        incdec.dec();
        assertEq(incdec.count(),1);
    }
}
