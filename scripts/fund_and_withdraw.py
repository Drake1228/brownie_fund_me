from typing import AsyncContextManager
from brownie import FundME
from scripts.helpful_scripts import get_account


def fund():
    fund_me = FundME[-1]
    account = get_account()
    entrance_fee = fund_me.getEntranceFee()
    print(entrance_fee)
    print("Funfing...")
    fund_me.fund({"from": account, "value": entrance_fee})


def withdraw():
    fund_me = FundME[-1]
    account = get_account()
    fund_me.withdraw({"from": account})


def main():
    fund()
    withdraw()
