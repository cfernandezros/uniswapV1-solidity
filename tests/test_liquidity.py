import brownie

def test_liquidity(accounts, exchange, token):
    assert exchange.getReserves() == 0

    # First liquidity provider adding liquidity (accounts[0]) with a price ratio
    # of 1000000000 gwei to 200 token:
    token.approve(exchange.address, 200, {'from': accounts[0]})
    exchange.addLiquidity(1, 200, {'from': accounts[0], 'value': 1000000000})

    assert exchange.getReserves() == 200
    assert exchange.totalSupply() == 1000000000
    assert exchange.balanceOf(accounts[0]) == 1000000000

    # Second liquidity provider adding liquidity (accounts[1]) in a very different rate
    # than first provider (they are giving the token a much lower price: 100 gwei to 100 token):
    token.approve(accounts[0], 100, {'from': accounts[0]})
    token.transferFrom(accounts[0], accounts[1], 100, {'from': accounts[0]})
    token.approve(exchange.address, 100, {'from': accounts[1]})
    exchange.addLiquidity(1, 100, {'from': accounts[1], 'value': 100})

    assert exchange.getReserves() == 200
    assert exchange.totalSupply() == 1000000100
    assert exchange.balanceOf(accounts[1]) == 100

    # Second liquidity provider trying to remove their liquidity (accounts[1]) get their
    # transaction reverted because they gave the token a much lower price in terms of eth:
    with brownie.reverts():
        exchange.removeLiquidity(100, 1, 1, {'from': accounts[1]})

    assert exchange.getReserves() == 200
    assert exchange.totalSupply() == 1000000100
