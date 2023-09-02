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

    // Mapping from alias to address
    mapping(string => address) private _aliases;

    // Reverse mapping from address to alias
    mapping(address => string) private _reverseAliases;

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
     * @param from Address to transfer ether from
     * @param to Address to transfer ether to
     * @param amount Amount of ether to transfer
     */
    function _transferEther(address from, address to, uint256 amount) internal {
        _etherBalances[from] -= amount;
        _etherBalances[to] += amount;
        emit EtherTransferred(from, to, amount);
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
        _transferEther(msg.sender, to, amount);
    }

    /**
    * @dev Transfer ether to another address using the alias
    * @param alias_ Alias of the address
    * @param amount Amount of ether to transfer
    */
    function transferEther(string calldata alias_, uint256 amount) external override nonReentrant {
        address to = _aliases[alias_];
        require(to != address(0), "Alias not registered");
        _transferEther(msg.sender, to, amount);
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
    function _transferToken(address token, address from, address to, uint256 amount) internal {
        // Update internal state
        _tokenBalances[from][token] -= amount;
        _tokenBalances[to][token] += amount;

        // Emit event
        emit TokenTransferred(from, to, token, amount);
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
        _transferToken(token, msg.sender, to, amount);
    }

    function transferToken(address token, string calldata alias_, uint256 amount) external override nonReentrant {
        address to_ = _aliases[alias_];
        require(to_ != address(0), "Alias not registered");
        _transferToken(token, msg.sender, to_, amount);
    }

    /**
     * @dev Get token balance of an address
     * @param user Address of the user
     * @param token Address of the token
     * @return Token balance of the user
     */
    function getTokenBalance(address user, address token) external view override returns (uint256) {
        return _tokenBalances[user][token];
    }

    /**
     * @dev Register an alias
     * @param alias_ Alias to register
     */
    function registerAlias(string calldata alias_) external override nonReentrant {
        require(_aliases[alias_] == address(0), "Alias already registered");
        _aliases[alias_] = msg.sender;
        _reverseAliases[msg.sender] = alias_;
        emit AliasRegistered(msg.sender, alias_);
    }

    /**
     * @dev Update an alias
     * @param alias_ Alias to update
     */
    function updateAlias(string calldata alias_) external override nonReentrant {
        require(_aliases[alias_] == address(0), "Alias already registered");
        string memory oldAlias = _reverseAliases[msg.sender];
        delete _aliases[oldAlias];
        _aliases[alias_] = msg.sender;
        _reverseAliases[msg.sender] = alias_;
        emit AliasRegistered(msg.sender, alias_);
    }

    /**
     * @dev Get the alias of an address
     * @param user Address to get the alias for
     */
    function getAlias(address user) external view override returns (string memory) {
        return _reverseAliases[user];
    }
}
