import { ethers, upgrades } from "hardhat";

export const deployCipherVault = async () => {
  const CipherVault = await ethers.deployContract("CipherVault", []);

  await CipherVault.waitForDeployment();

  return CipherVault;
};
