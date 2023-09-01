// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.18;

interface ICipherVault {
    event EtherDeposited(address indexed user, uint256 amount);
    event EtherWithdrawn(address indexed user, uint256 amount);
    event EtherTransferred(address indexed from, address indexed to, uint256 amount);
    
    event TokenDeposited(address indexed user, address indexed token, uint256 amount);
    event TokenWithdrawn(address indexed user, address indexed token, uint256 amount);
    event TokenTransferred(address indexed from, address indexed to, address indexed token, uint256 amount);
    
    function depositEther() external payable;
    function withdrawEther(uint256 amount) external;
    function transferEther(address to, uint256 amount) external;
    function getEtherBalance(address user) external view returns (uint256);
    
    function depositToken(address token, uint256 amount) external;
    function withdrawToken(address token, uint256 amount) external;
    function transferToken(address token, address user, uint256 amount) external;
    function getTokenBalance(address token, address user) external view returns (uint256);
}
