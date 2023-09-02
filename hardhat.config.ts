import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-ethers";
import "@nomicfoundation/hardhat-chai-matchers";
import "@openzeppelin/hardhat-upgrades";
import "hardhat-deploy";
import "hardhat-gas-reporter";
import * as dotenv from "dotenv";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.18",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    },
  },
  gasReporter: {
    enabled: true,
    gasPrice: 20,
    currency: "USD",
  },
  networks: {
    hardhat: {
      gasPrice: 0,
      initialBaseFeePerGas: 0,
    },
    mumbai: {
      url: "https://polygon-mumbai.g.alchemy.com/v2/kQoPdLfLKNZPzVEu7PkVg1-a-m0PqY2W",
      chainId: 80001,
      accounts: {
        mnemonic: `${process.env.DEPLOY_ACCOUNT_MNEMONIC}`,
      },
    },
  },
};

export default config;
