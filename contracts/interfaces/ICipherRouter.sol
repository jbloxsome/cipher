// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.18;

interface ICipherRouter {
    event AliasRegistered(address indexed user, string alias_);

    function depositEther() external payable;
    function withdrawEther(uint256 amount) external;
    function transferEther(address to, uint256 amount) external;
    function transferEther(string calldata alias_, uint256 amount) external;
    function depositToken(address token, uint256 amount) external;
    function withdrawToken(address token, uint256 amount) external;
    function transferToken(address token, address to, uint256 amount) external;
    function transferToken(address token, string calldata alias_, uint256 amount) external;
    function registerAlias(string calldata alias_) external;
    function updateAlias(string calldata alias_) external;
    function getAlias(address user) external view returns (string memory);
    function vault() external view returns (address);
}