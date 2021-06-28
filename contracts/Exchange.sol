//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20 {
  address public token_address;

  constructor(address _token) ERC20("Uniswap V1", "UNI-V1") {
      require(_token != address(0), "invalid token address");

      token_address = _token;
  }

  function getReserves() public view returns (uint256) {
    return IERC20(token_address).balanceOf(address(this));
  }

  function addLiquidity(uint256 min_liquidity, uint256 max_tokens) public payable returns (uint256) {
    uint256 total_liquidity = totalSupply();

    if (total_liquidity > 0) {
      require(min_liquidity > 0, "not enough liquidity!");

      uint256 eth_reserve = address(this).balance - msg.value;
      uint256 token_reserve = getReserves();

      uint256 token_amount = token_reserve * msg.value / eth_reserve;
      uint256 liquidity_minted = total_liquidity * msg.value / eth_reserve;

      require(max_tokens >= token_amount && liquidity_minted >= min_liquidity, "wrong liquidity provider params");
      IERC20 token = IERC20(token_address);
      token.transferFrom(msg.sender, address(this), token_amount);

      _mint(msg.sender, liquidity_minted);
      return liquidity_minted;
    }

    else {
      require(token_address != address(0) && msg.value >= 1000000000);
      uint256 token_amount = max_tokens;
      uint256 liquidity_minted = address(this).balance;

      IERC20 token = IERC20(token_address);
      token.transferFrom(msg.sender, address(this), token_amount);

      _mint(msg.sender, liquidity_minted);
      return liquidity_minted;
    }
  }

  function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens) public returns (uint256, uint256) {
    require(amount > 0 && min_eth > 0 && min_tokens > 0);
    uint256 total_liquidity = totalSupply();
    require(total_liquidity > 0, "liquidity must be positive to remove");

    uint256 token_reserve = getReserves();
    uint256 eth_amount = amount * address(this).balance / total_liquidity;
    uint256 token_amount = amount * token_reserve / total_liquidity;
    require(eth_amount >= min_eth && token_amount >= min_tokens, "wrong liquidity removing params");

    _burn(msg.sender, amount);
    payable(msg.sender).transfer(eth_amount);
    IERC20(token_address).transfer(msg.sender, token_amount);

    return (eth_amount, token_amount);
  }
}