import { ethers } from "hardhat";

export const deployERC20Token = async () => {
  const erc20 = await ethers.deployContract("ERC20Test", [
    "Test Token",
    "TST",
    ethers.parseEther("1000000"),
  ]);

  // wait for the transaction to be mined
  const receipt = await erc20.waitForDeployment();

  const address = receipt.getAddress();

  return address;
};
