// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/ICipherRouter.sol";
import "./interfaces/ICipherVault.sol";

contract CipherRouter is ICipherRouter, ReentrancyGuard {
    // Address of the vault
    address public immutable vault;
    // Mapping from alias to address
    mapping(string => address) private _aliases;
    // Reverse mapping from address to alias
    mapping(address => string) private _reverseAliases;

    constructor(address vault_) {
        require(vault_ != address(0), "Vault address cannot be zero");
        vault = vault_;
    }

    /**
     * @dev Deposit ether to the vault
     */
    function depositEther() external payable override nonReentrant {
        ICipherVault(vault).depositEther{value: msg.value}();
    }

    /**
     * @dev Withdraw ether from the vault
     * @param amount Amount of ether to withdraw
     */
    function withdrawEther(uint256 amount) external override nonReentrant {
        ICipherVault(vault).withdrawEther(amount);
    }

    /**
     * @dev Transfer ether to another address
     * @param to Address to transfer ether to
     * @param amount Amount of ether to transfer
     */
    function transferEther(address to, uint256 amount) external override nonReentrant {
        ICipherVault(vault).transferEther(to, amount);
    }

    /**
     * @dev Transfer ether to another address using the alias
     * @param alias_ Alias of the address
     * @param amount Amount of ether to transfer
     */
    function transferEther(string calldata alias_, uint256 amount) external override nonReentrant {
        address to = _aliases[alias_];
        require(to != address(0), "Alias not registered");
        ICipherVault(vault).transferEther(to, amount);
    }

    /**
     * @dev Deposit token to the vault
     * @param token Address of the token
     * @param amount Amount of token to deposit
     */
    function depositToken(address token, uint256 amount) external override nonReentrant {
        ICipherVault(vault).depositToken(token, amount);
    }

    /**
     * @dev Withdraw token from the vault
     * @param token Address of the token
     * @param amount Amount of token to withdraw
     */
    function withdrawToken(address token, uint256 amount) external override nonReentrant {
        ICipherVault(vault).withdrawToken(token, amount);
    }

    /**
     * @dev Transfer token to another address
     * @param token Address of the token
     * @param to Address to transfer token to
     * @param amount Amount of token to transfer
     */
    function transferToken(address token, address to, uint256 amount) external override nonReentrant {
        ICipherVault(vault).transferToken(token, to, amount);
    }

    /**
     * @dev Transfer token to another address using the alias
     * @param token Address of the token
     * @param alias_ Alias of the address
     * @param amount Amount of token to transfer
     */
    function transferToken(address token, string calldata alias_, uint256 amount) external override nonReentrant {
        address to = _aliases[alias_];
        require(to != address(0), "Alias not registered");
        ICipherVault(vault).transferToken(token, to, amount);
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
