def test_mint(accounts, token):
    assert token.balanceOf(accounts[0]) == 1e21