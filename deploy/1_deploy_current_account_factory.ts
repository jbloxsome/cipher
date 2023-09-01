import { ethers, upgrades } from "hardhat";
import * as fs from "fs";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deployCurrentAccountController: DeployFunction = async (
  hre: HardhatRuntimeEnvironment
) => {
  // load deployment data from file
  const deployments = require("../deployments.json");

  // only run if deployment doesn't already exist for the current network
  if (
    !deployments.deployments.network[hre.network.name][
      "CurrentAccountUpgradeableController"
    ]
  ) {
    const CurrentAccountUpgradeableController = await ethers.getContractFactory(
      "CurrentAccountUpgradeableController"
    );

    const currentAccountUpgradeableController = await upgrades.deployProxy(
      CurrentAccountUpgradeableController
    );

    await currentAccountUpgradeableController.waitForDeployment();

    const address = await currentAccountUpgradeableController.getAddress();

    console.log("CurrentAccountUpgradeableController deployed to:", address);

    deployments.deployments.network[hre.network.name][
      "CurrentAccountUpgradeableController"
    ] = {
      success: true,
      address: address,
      timestamp: Date.now(),
    };

    // write deployment to file
    fs.writeFileSync(
      "./deployments.json",
      JSON.stringify(deployments, null, 2)
    );
  }
};

export default deployCurrentAccountController;
