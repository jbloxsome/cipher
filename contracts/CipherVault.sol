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

    /**
     * @dev Deposit ether to the vault
     */   
    function depositEther() external payable override nonReentrant {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        _etherBalances[msg.sender] += msg.value;
        emit EtherDeposited(msg.sender, msg.value);
    }

    /**
     * @dev Withdraw ether from the vault
     * @param amount Amount of ether to withdraw
     */
    function withdrawEther(uint256 amount) external override nonReentrant {
        require(amount > 0, "Withdraw amount must be greater than zero");
        require(_etherBalances[msg.sender] >= amount, "Insufficient ether balance");
        _etherBalances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit EtherWithdrawn(msg.sender, amount);
    }

    /**
     * @dev Transfer ether to another address
     * @param to Address to transfer ether to
     * @param amount Amount of ether to transfer
     */
    function transferEther(address to, uint256 amount) external override nonReentrant {
        require(to != address(0), "Cannot transfer to the zero address");
        require(to != address(this), "Cannot transfer to the vault address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_etherBalances[msg.sender] >= amount, "Insufficient ether balance");
        _etherBalances[msg.sender] -= amount;
        _etherBalances[to] += amount;
        emit EtherTransferred(msg.sender, to, amount);
    }

    /**
     * @dev Get ether balance of an address
     * @param user Address of the user
     * @return Ether balance of the user
     */
    function getEtherBalance(address user) external view override returns (uint256) {
        return _etherBalances[user];
    }

    /**
     * @dev Deposit token to the vault
     * @param token Address of the token
     * @param amount Amount of token to deposit
     */
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

    /**
     * @dev Withdraw token from the vault
     * @param token Address of the token
     * @param amount Amount of token to withdraw
     */
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

    /**
     * @dev Transfer token to another address
     * @param token Address of the token
     * @param to Address to transfer token to
     * @param amount Amount of token to transfer
     */
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

    /**
     * @dev Get token balance of an address
     * @param token Address of the token
     * @param user Address of the user
     * @return Token balance of the user
     */
    function getTokenBalance(address token, address user) external view override returns (uint256) {
        return _tokenBalances[user][token];
    }
}
