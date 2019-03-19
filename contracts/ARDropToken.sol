pragma solidity ^0.5.2;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";

contract ARDropToken is ERC20, ERC20Detailed{

	constructor
	(
		string memory _name, 
		string memory _symbol, 
		uint8 _decimals, 
		uint256 _supply
	)
	    ERC20Detailed(_name, _symbol, _decimals)
	    public 
	{
		_totalSupply = _supply.mul(uint256(10) ** _decimals);
		
		//Exchange fund (Vesting contract released at 0.001 per day) - 45%
		_balances[0x6942Ca6a3785aac528fF2D34401A21B46e468278] = _totalSupply.mul(45) / 100;
		//Airdrop bounty and marketing - 45%
		_balances[0x46A71118576D76065717cb0bb2f8bfAB59f2AeEE] = _totalSupply.mul(45) / 100;
		//Team (Timelock contract, released after 3 months)- 5%
		_balances[0xAc5194c61452301FeD40930eF1d6A01586D9A78a] = _totalSupply.mul(5) / 100;
		//Working capital - 5%
		_balances[0x2a83Dfa1D1ca45308875eEa26ea5E096570c2f7b] = _totalSupply.mul(5) / 100;

	}
}