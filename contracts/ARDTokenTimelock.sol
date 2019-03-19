pragma solidity ^0.5.2;

import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title ARDTokenTimelock
 * @dev ARDTokenTimelock is a token holder contract that will allow a
 * beneficiary to extract the ARD tokens after a given release time
 */
contract ARDTokenTimelock is Ownable{
    using SafeERC20 for IERC20;

    event BeneficiaryChanged(address newBeneficiary);

    // ERC20 basic token contract being held
    IERC20 private _token;

    // beneficiary of tokens after they are released
    address private _beneficiary;

    // timestamp when token release is enabled
    uint256 private _releaseTime;

    constructor (IERC20 token, address beneficiary, uint256 releaseTime) public {
        require(beneficiary != address(0));
        require(releaseTime > block.timestamp);
        _token = token;
        _beneficiary = beneficiary;
        _releaseTime = releaseTime;
    }

    /**
     * @return the token being held.
     */
    function token() public view returns (IERC20) {
        return _token;
    }

    /**
     * @return the beneficiary of the tokens.
     */
    function beneficiary() public view returns (address) {
        return _beneficiary;
    }

    /**
     * Changes beneficiary address
     */
    function changeBeneficiary(address newBeneficiary) public onlyOwner{
        require(newBeneficiary != address(0));
        _beneficiary = newBeneficiary;
        emit BeneficiaryChanged(newBeneficiary);
    }

    /**
     * @return the time when the tokens are released.
     */
    function releaseTime() public view returns (uint256) {
        return _releaseTime;
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function release() public {
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp >= _releaseTime);

        uint256 amount = _token.balanceOf(address(this));
        require(amount > 0);

        _token.safeTransfer(_beneficiary, amount);
    }
}
