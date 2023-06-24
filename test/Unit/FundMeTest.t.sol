//SPDX-Licence-Identifier:MIT

pragma solidity ^0.8.0;

import {Test,console} from "lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
contract FundMeTest is Test{
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE=0.1 ether ;
    uint256  constant STARTING_BALANCE=10 ether;
    uint256 constant GAS_PRICE=1;
    function setUp() external {
        //fundMe=new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe=new DeployFundMe();
        fundMe=deployFundMe.run(); 
        vm.deal(USER,STARTING_BALANCE);
    }

    function testMinumDollarIsFive() public{
        assertEq(fundMe.MINIMUM_USD(),5e18);
    }
    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }
    function testPriceFeedVersionIsAccurate()public{
        uint256 version = fundMe.getVersion();
        assertEq(version,4);
    }
    function testFundFailWithoutEnoughEth()public{
        vm.expectRevert();
        fundMe.fund(); //send 0 value
    }
    function testFundUpdatesFundedDateStructure()public{
        vm.prank(USER);//the next tx will be sent by user
        fundMe.fund{value:SEND_VALUE}();
        uint256 amountFunded=fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded,SEND_VALUE);
    }
    function testAddsFunderToArrayOfFunders() public funded {

        address funder=fundMe.getFunder(0);
        assertEq(funder,USER);
    }
    modifier funded(){
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();
        _;
    }
    function testOnlyOwnerCanWithdraw() public funded{
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();

        
    }
    function testWithDrawWithASingleFunder() public funded{
        //Arrange
        uint256 startingOwnerBalance=fundMe.getOwner().balance;
        uint256 startingFundMeBalance=address(fundMe).balance;

        //Art
        //uint256 gasStart=gasleft();
        //vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        //uint256 gasEnd=gasleft();
        //uint256 gasUsed=(gasStart-gasEnd)*tx.gasprice;
        //console.log(gasUsed); 
        //assert
        uint256 endingOwnerBalance=fundMe.getOwner().balance;
        uint256 endingFundMeBalance=address(fundMe).balance;
        assertEq(endingFundMeBalance,0);
        assertEq(startingFundMeBalance+startingOwnerBalance,endingOwnerBalance);


    }
    function testWithdrawFromMultipleFunders() public funded{
        //Arrange 
        uint160 numberOfFunders=10;
        uint160 startingFunderIndex=1;
        for(uint160 i=startingFunderIndex;i<numberOfFunders;i++){
            //vm.prank new address
            //vm,deal new address
            //address()
            hoax(address(i),SEND_VALUE);
            fundMe.fund{value:SEND_VALUE}();
            //fundMe the FUndMe
        }
        uint256 startingOwnerBalance=fundMe.getOwner().balance;
        uint256 startingFundMeBalance=address(fundMe).balance;
        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        //assert
        assert(address(fundMe).balance ==0);
        assert(startingFundMeBalance+startingOwnerBalance==fundMe.getOwner().balance);

    }
    function testWithdrawFromMultipleFundersCheaper() public funded{
        //Arrange 
        uint160 numberOfFunders=10;
        uint160 startingFunderIndex=1;
        for(uint160 i=startingFunderIndex;i<numberOfFunders;i++){
            //vm.prank new address
            //vm,deal new address
            //address()
            hoax(address(i),SEND_VALUE);
            fundMe.fund{value:SEND_VALUE}();
            //fundMe the FUndMe
        }
        uint256 startingOwnerBalance=fundMe.getOwner().balance;
        uint256 startingFundMeBalance=address(fundMe).balance;
        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();
        //assert
        assert(address(fundMe).balance ==0);
        assert(startingFundMeBalance+startingOwnerBalance==fundMe.getOwner().balance);

    }

}