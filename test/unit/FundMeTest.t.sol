// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
  FundMe fundMe;

  address USER = makeAddr("johnny");
  uint256 constant SEND_VALUE = 0.1 ether; // 1000000000000000000
  uint256 constant STARTING_BALANCE = 10 ether;
  uint256 constant GAS_PRICE = 1;

  function setUp() external {
    // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    DeployFundMe deployFundMe = new DeployFundMe();
    fundMe = deployFundMe.run();
    vm.deal(USER, STARTING_BALANCE);
  }

  function testMinimumDollarIsFive() public {
    assertEq(fundMe.MINIMUM_USD(), 5e18);
  }

  function testOwnerIsMessageSender() public {
    assertEq(fundMe.getOwner(), msg.sender);
  }

  // What can we do to work with addresses outside our system?
  // 1. Unit
  //    - Testing a specific part of our code
  // 2. Integration
  //    - Testing how our code works with other parts of our code
  // 3. Forked
  //    - Testing our code on a simulated real environment
  // 4. Staging
  //    - Testing our code in a real environment that is not prod

  function testPriceFeedVersionIsAccurate() public {
    uint256 version = fundMe.getVersion();
    // in case of local chain version is 0 else 4
    assertEq(version, block.chainid == 31337 ? 0 : 4);
  }

  function testFundFailsWithoutEnoughEth() public {
    vm.expectRevert(); // hey, we expect a revert
    fundMe.fund();
  }

  function testFundUpdatesFundedDataStructure() public funded{
    // vm.prank(USER); // The next Tx will be send by user
    // fundMe.fund{value: SEND_VALUE}();
    uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
    assertEq(amountFunded, SEND_VALUE);
  }

  function testAddsFunderToArrayOfFunders() public funded {
    // vm.prank(USER); // The next Tx will be send by user
    // fundMe.fund{value: SEND_VALUE}();
    
    address funder = fundMe.getFunder(0);
    assertEq(funder, USER);
  }

  modifier funded() {
    vm.prank(USER); // The next Tx will be send by user
    fundMe.fund{value: SEND_VALUE}();
    _;
  }

  function testOnlyOwnerCanWithdraw() public funded {
    // vm.prank(USER); // The next Tx will be send by user
    // fundMe.fund{value: SEND_VALUE}();

    vm.expectRevert();
    vm.prank(USER);
    fundMe.withdraw();
  }

  function testWithDrawWithASingleFunder() public funded {
    // Arrange
    uint256 startingOwnerBalance = fundMe.getOwner().balance;
    uint256 startingFundMeBalance = address(fundMe).balance;
    
    // Act
    // uint256 gasStart = gasleft();
    // vm.txGasPrice(GAS_PRICE); // by default on anvil local chain 0 gas price incurs
    vm.prank(fundMe.getOwner());
    fundMe.withdraw();

    // uint256 gasEnd = gasleft();
    // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
    // console.log("Gas used: ", gasUsed);

    // Assert
    uint256 endingOwnerBalance = fundMe.getOwner().balance;
    uint256 endingFundMeBalance = address(fundMe).balance;
    assertEq(endingFundMeBalance, 0);
    assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
  }

  function testWithdrawFromMultipleFunders() public funded {
    // Arrange
    uint160 numberOfFunders = 10;
    uint160 startingFunderIndex = 1;
    for(uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
      // vm.prank new address
      // vm.deal new address
      hoax(address(i), SEND_VALUE);
      fundMe.fund{value: SEND_VALUE}();
      // fund the fundMe
    }

    uint256 startingOwnerBalance = fundMe.getOwner().balance;
    uint256 startingFundMeBalance = address(fundMe).balance;

    // Act 
    vm.startPrank(fundMe.getOwner());
    fundMe.withdraw();
    vm.stopPrank();

    // Assert
    uint256 endingFundMeBalance = address(fundMe).balance;
    assertEq(startingOwnerBalance + startingFundMeBalance, fundMe.getOwner().balance);
    assertEq(endingFundMeBalance, 0);
  }

  function testWithdrawFromMultipleFundersCheaper() public funded {
    // Arrange
    uint160 numberOfFunders = 10;
    uint160 startingFunderIndex = 1;
    for(uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
      // vm.prank new address
      // vm.deal new address
      hoax(address(i), SEND_VALUE);
      fundMe.fund{value: SEND_VALUE}();
      // fund the fundMe
    }

    uint256 startingOwnerBalance = fundMe.getOwner().balance;
    uint256 startingFundMeBalance = address(fundMe).balance;

    // Act 
    vm.startPrank(fundMe.getOwner());
    fundMe.cheaperWithdraw();
    vm.stopPrank();

    // Assert
    uint256 endingFundMeBalance = address(fundMe).balance;
    assertEq(startingOwnerBalance + startingFundMeBalance, fundMe.getOwner().balance);
    assertEq(endingFundMeBalance, 0);
  }
}