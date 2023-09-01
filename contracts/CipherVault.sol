// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/ICipherVault.sol";

contract CipherVault is ICipherVault, ReentrancyGuard {
    // Mapping from owner to ether balance
    mapping(address => uint256) private _etherBalances;

    // Mapping from owner to mapping from token to token balance
    mapping(address => mapping(address => uint256)) private _tokenBalances;

    function depositEther() external payable override nonReentrant {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        _etherBalances[msg.sender] += msg.value;
        emit EtherDeposited(msg.sender, msg.value);
    }

    function withdrawEther(uint256 amount) external override nonReentrant {
        require(amount > 0, "Withdraw amount must be greater than zero");
        require(_etherBalances[msg.sender] >= amount, "Insufficient ether balance");
        _etherBalances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit EtherWithdrawn(msg.sender, amount);
    }

    function transferEther(address to, uint256 amount) external override nonReentrant {
        require(to != address(0), "Cannot transfer to the zero address");
        require(to != address(this), "Cannot transfer to the vault address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_etherBalances[msg.sender] >= amount, "Insufficient ether balance");
        _etherBalances[msg.sender] -= amount;
        _etherBalances[to] += amount;
        emit EtherTransferred(msg.sender, to, amount);
    }

    function getEtherBalance(address user) external view override returns (uint256) {
        return _etherBalances[user];
    }

    function depositToken(address token, uint256 amount) external override nonReentrant {
        require(token != address(0), "Token address cannot be zero");
        require(amount > 0, "Deposit amount must be greater than zero");
        require(IERC20(token).balanceOf(msg.sender) >= amount, "Insufficient token balance");

        // Update internal state
        _tokenBalances[msg.sender][token] += amount;

        // Transfer tokens from user to this contract
        require(IERC20(token).transferFrom(msg.sender, address(this), amount), "Token transfer failed");
        
        // Emit event
        emit TokenDeposited(msg.sender, token, amount);
    }

    function withdrawToken(address token, uint256 amount) external override nonReentrant {
        require(token != address(0), "Token address cannot be zero");
        require(amount > 0, "Withdraw amount must be greater than zero");
        require(_tokenBalances[msg.sender][token] >= amount, "Insufficient token balance");

        // Update internal state
        _tokenBalances[msg.sender][token] -= amount;

        // Transfer tokens from this contract to user
        require(IERC20(token).transfer(msg.sender, amount), "Token transfer failed");

        // Emit event
        emit TokenWithdrawn(msg.sender, token, amount);
    }

    function transferToken(address token, address to, uint256 amount) external override nonReentrant {
        require(to != address(0), "Cannot transfer to the zero address");
        require(to != address(this), "Cannot transfer to the vault address");
        require(token != address(0), "Token address cannot be zero");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_tokenBalances[msg.sender][token] >= amount, "Insufficient token balance");

        // Update internal state
        _tokenBalances[msg.sender][token] -= amount;
        _tokenBalances[to][token] += amount;

        // Emit event
        emit TokenTransferred(msg.sender, to, token, amount);
    }

    function getTokenBalance(address token, address user) external view override returns (uint256) {
        return _tokenBalances[user][token];
    }
}
