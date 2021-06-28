#!/usr/bin/python3

from brownie import Exchange, Token, accounts

def main():
    token = Token.deploy("Prueba", "PRB", 1e21, {'from': accounts[0]})
    pool = Exchange.deploy(token.address, {'from': accounts[0]})
    return pool