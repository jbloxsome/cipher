import { ethers } from "hardhat";
import { expect } from "chai";
import { deployCipherVault, deployERC20Token } from "./utils";

describe("CipherVault", () => {
  let accounts: ethers.Signer[];
  let vault: ethers.Contract;
  let vaultAddress: string;
  let erc20: string;

  before(async () => {
    // deploy the CipherVault contract
    vault = await deployCipherVault();
    // get the address of the vault
    vaultAddress = await vault.getAddress();
    // ERC20 token
    erc20 = await deployERC20Token();
    // get accounts
    accounts = await ethers.getSigners();
  });

  it("vault is deployed with a valid eth address", async () => {
    const address = await vault.getAddress();
    expect(ethers.isAddress(address)).to.be.true;
  });

  describe("happy paths", () => {
    describe("ether deposits", () => {
      it("users can deposit ether", async () => {
        // send 1 ether for accounts[0] to vault
        await expect(
          vault.connect(accounts[0]).depositEther({
            value: ethers.parseEther("1"),
          })
        ).to.not.be.reverted;
      });

      it("vault contract ether is 1", async () => {
        // check vault balance is 1 ether
        await expect(
          ethers.provider.getBalance(vaultAddress)
        ).to.eventually.equal(ethers.parseEther("1"));
      });

      it("user's balance is 1", async () => {
        await expect(
          vault.getEtherBalance(accounts[0].address)
        ).to.eventually.equal(ethers.parseEther("1"));
      });
    });

    describe("ERC20 deposits", () => {
      it("users can deposit ERC20 tokens", async () => {
        // Allow vault to spend 1 token from accounts[0]
        const erc20Contract = await ethers.getContractAt("ERC20", erc20);

        await expect(
          erc20Contract
            .connect(accounts[0])
            .approve(vaultAddress, ethers.parseEther("1"))
        ).to.not.be.reverted;

        // Deposit 1 token
        await expect(
          vault.connect(accounts[0]).depositToken(erc20, ethers.parseEther("1"))
        ).to.not.be.reverted;
      });

      it("vault contract ERC20 balance is 1", async () => {
        // get ERC20 token contract
        const erc20Contract = await ethers.getContractAt("ERC20", erc20);

        // check vault balance is 1 ERC20 token
        await expect(erc20Contract.balanceOf(vaultAddress)).to.eventually.equal(
          ethers.parseEther("1")
        );
      });

      it("user's balance is 1", async () => {
        await expect(
          vault.getTokenBalance(erc20, accounts[0].address)
        ).to.eventually.equal(ethers.parseEther("1"));
      });
    });

    describe("ether transfers", () => {
      it("users can some or all of their balance to another user", async () => {
        // send 0.5 ether from accounts[0] to accounts[1]
        await expect(
          vault
            .connect(accounts[0])
            .transferEther(accounts[1].address, ethers.parseEther("0.5"))
        ).to.not.be.reverted;
      });

      it("accounts[0] balance is 0.5 ether", async () => {
        await expect(
          vault.getEtherBalance(accounts[0].address)
        ).to.eventually.equal(ethers.parseEther("0.5"));
      });

      it("accounts[1] balance is 0.5 ether", async () => {
        await expect(
          vault.getEtherBalance(accounts[1].address)
        ).to.eventually.equal(ethers.parseEther("0.5"));
      });
    });

    describe("ERC20 transfers", () => {
      it("users can some or all of their balance to another user", async () => {
        // send 0.5 ERC20 token from accounts[0] to accounts[1]
        await expect(
          vault
            .connect(accounts[0])
            .transferToken(erc20, accounts[1].address, ethers.parseEther("0.5"))
        ).to.not.be.reverted;
      });

      it("vault contract ERC20 balance is 1", async () => {
        // get ERC20 token contract
        const erc20Contract = await ethers.getContractAt("ERC20", erc20);

        // check vault balance is 1 ERC20 token
        await expect(erc20Contract.balanceOf(vaultAddress)).to.eventually.equal(
          ethers.parseEther("1")
        );
      });

      it("accounts[0] balance is 0.5 ERC20 token", async () => {
        await expect(
          vault.getTokenBalance(erc20, accounts[0].address)
        ).to.eventually.equal(ethers.parseEther("0.5"));
      });

      it("accounts[1] balance is 0.5 ERC20 token", async () => {
        await expect(
          vault.getTokenBalance(erc20, accounts[1].address)
        ).to.eventually.equal(ethers.parseEther("0.5"));
      });
    });

    describe("ether withdrawals", async () => {
      it("users can withdraw some or all of their balance", async () => {
        // withdraw 0.5 ether from accounts[0]
        await expect(
          vault.connect(accounts[0]).withdrawEther(ethers.parseEther("0.5"))
        ).to.not.be.reverted;
      });

      it("accounts[0] balance in the vault is 0 ether", async () => {
        await expect(
          vault.getEtherBalance(accounts[0].address)
        ).to.eventually.equal(ethers.parseEther("0"));
      });

      it("vault contract ether is 0.5", async () => {
        // check vault balance is 0.5 ether
        await expect(
          ethers.provider.getBalance(vaultAddress)
        ).to.eventually.equal(ethers.parseEther("0.5"));
      });

      it("accounts[0] native balance is 0.5 ether greater", async () => {
        await expect(
          ethers.provider.getBalance(accounts[0].address)
        ).to.eventually.equal(
          ethers.parseEther("9999") + ethers.parseEther("0.5")
        );
      });
    });

    describe("ERC20 withdrawals", async () => {
      it("users can withdraw some or all of their balance", async () => {
        // withdraw 0.5 ERC20 token from accounts[0]
        await expect(
          vault
            .connect(accounts[0])
            .withdrawToken(erc20, ethers.parseEther("0.5"))
        ).to.not.be.reverted;
      });

      it("accounts[0] balance in the vault is 0 ERC20 token", async () => {
        await expect(
          vault.getTokenBalance(erc20, accounts[0].address)
        ).to.eventually.equal(ethers.parseEther("0"));
      });

      it("vault contract ERC20 balance is 0.5", async () => {
        // get ERC20 token contract
        const erc20Contract = await ethers.getContractAt("ERC20", erc20);

        // check vault balance is 0.5 ERC20 token
        await expect(erc20Contract.balanceOf(vaultAddress)).to.eventually.equal(
          ethers.parseEther("0.5")
        );
      });

      it("accounts[0] native ERC20 balance is 0.5 greater", async () => {
        // get ERC20 token contract
        const erc20Contract = await ethers.getContractAt("ERC20", erc20);

        await expect(
          erc20Contract.balanceOf(accounts[0].address)
        ).to.eventually.equal(
          ethers.parseEther("999999") + ethers.parseEther("0.5")
        );
      });
    });
  });

  describe("unhappy paths", () => {
    describe("ether deposits", () => {
      it("users cannot deposit ether if they send 0 ether", async () => {
        await expect(
          vault.connect(accounts[0]).depositEther({
            value: ethers.parseEther("0"),
          })
        ).to.be.revertedWith("Deposit amount must be greater than zero");
      });
    });

    describe("ERC20 deposits", () => {
      it("users cannot deposit ERC20 tokens if they send 0 tokens", async () => {
        await expect(
          vault.connect(accounts[0]).depositToken(erc20, ethers.parseEther("0"))
        ).to.be.revertedWith("Deposit amount must be greater than zero");
      });

      it("users cannot deposit ERC20 tokens if they send more than their balance", async () => {
        await expect(
          vault
            .connect(accounts[0])
            .depositToken(erc20, ethers.parseEther("1000"))
        ).to.be.revertedWith("Insufficient token balance");
      });
    });
  });

  describe("malicious paths", () => {
    describe("logic errors", () => {
      it("should not allow zero ether deposits", async function () {
        await expect(
          vault.depositEther({ value: ethers.parseEther("0") })
        ).to.be.revertedWith("Deposit amount must be greater than zero");
      });

      it("should not allow zero token deposits", async function () {
        await expect(
          vault.depositToken(erc20, ethers.parseEther("0"))
        ).to.be.revertedWith("Deposit amount must be greater than zero");
      });

      it("should not allow zero ether transfers", async function () {
        await expect(
          vault.transferEther(accounts[1].address, ethers.parseEther("0"))
        ).to.be.revertedWith("Transfer amount must be greater than zero");
      });

      it("should not allow zero token transfers", async function () {
        await expect(
          vault.transferToken(
            erc20,
            accounts[1].address,
            ethers.parseEther("0")
          )
        ).to.be.revertedWith("Transfer amount must be greater than zero");
      });

      it("should not allow ether transfers to the zero address", async function () {
        await expect(
          vault.transferEther(ethers.ZeroAddress, ethers.parseEther("1"))
        ).to.be.revertedWith("Cannot transfer to the zero address");
      });

      it("should not allow token transfers to the zero address", async function () {
        await expect(
          vault.transferToken(erc20, ethers.ZeroAddress, ethers.parseEther("1"))
        ).to.be.revertedWith("Cannot transfer to the zero address");
      });

      it("should not allow ether transfers to the vault address", async function () {
        await expect(
          vault.transferEther(vaultAddress, ethers.parseEther("1"))
        ).to.be.revertedWith("Cannot transfer to the vault address");
      });

      it("should not allow token transfers to the vault address", async function () {
        await expect(
          vault.transferToken(erc20, vaultAddress, ethers.parseEther("1"))
        ).to.be.revertedWith("Cannot transfer to the vault address");
      });

      it("should not allow ether transfers greater than caller's balance", async function () {
        await expect(
          vault.transferEther(accounts[1].address, ethers.parseEther("10000"))
        ).to.be.revertedWith("Insufficient ether balance");
      });

      it("should not allow token transfers greater than caller's balance", async function () {
        await expect(
          vault.transferToken(
            erc20,
            accounts[1].address,
            ethers.parseEther("10000")
          )
        ).to.be.revertedWith("Insufficient token balance");
      });
    });
  });

  describe("edge cases", () => {});
});
