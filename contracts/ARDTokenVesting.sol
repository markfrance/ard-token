pragma solidity ^0.5.2;

import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

/**
 * @title ARDTokenVesting
 * @dev A token holder contract that can release its ARD token balance gradually like a
 * typical vesting scheme. startVesting() function needs to be called by owner to set start time.
*/
contract ARDTokenVesting is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event TokensReleased(address token, uint256 amount);
    event BeneficiaryChanged(address newBeneficiary);

    // beneficiary of tokens after they are released
    address private _beneficiary;

    // Durations and timestamps are expressed in UNIX time, the same units as block.timestamp.
    uint256 private _start;
    uint256 private _duration;
    bool private _hasStarted;

    mapping (address => uint256) private _released;

    modifier hasVestingStarted() {
        require(_hasStarted);
        _;
    }

    /**
     * @dev Creates a vesting contract that vests its balance of any ERC20 token to the
     * beneficiary, gradually in a linear fashion until start + duration. By then all
     * of the balance will have vested.
     * @param beneficiary address of the beneficiary to whom vested tokens are transferred
     * @param duration duration in seconds of the period in which the tokens will vest
    */
    constructor (address beneficiary,  uint256 duration) public {
        require(beneficiary != address(0));
        require(duration > 0);

        _beneficiary = beneficiary;
        _duration = duration;
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
     * Starts the token vesting process.
     */
    function startVesting() public onlyOwner () {
        require(!_hasStarted);
        _start = now;
        _hasStarted = true;
    }

    /**
     * @return the start time of the token vesting.
     */
    function start() public view returns (uint256) {
        return _start;
    }

    /**
     * @return the duration of the token vesting.
     */
    function duration() public view returns (uint256) {
        return _duration;
    }


    /**
     * @return the amount of the token released.
     */
    function released(address token) public view returns (uint256) {
        return _released[token];
    }

    /**
     * @notice Transfers vested tokens to beneficiary.
     * @param token ERC20 token which is being vested
     */
    function release(IERC20 token) public hasVestingStarted{
        uint256 unreleased = _releasableAmount(token);

        require(unreleased > 0);

        _released[address(token)] = _released[address(token)].add(unreleased);

        token.safeTransfer(_beneficiary, unreleased);

        emit TokensReleased(address(token), unreleased);
    }

    /**
     * @dev Calculates the amount that has already vested but hasn't been released yet.
     * @param token ERC20 token which is being vested
     */
    function _releasableAmount(IERC20 token) private view returns (uint256) {
        return _vestedAmount(token).sub(_released[address(token)]);
    }

    /**
     * @dev Calculates the amount that has already vested.
     * @param token ERC20 token which is being vested
     */
    function _vestedAmount(IERC20 token) private view returns (uint256) {
        uint256 currentBalance = token.balanceOf(address(this));
        uint256 totalBalance = currentBalance.add(_released[address(token)]);

        if (block.timestamp >= _start.add(_duration)) {
            return totalBalance;
        } else {
            return totalBalance.mul(block.timestamp.sub(_start)).div(_duration);
        }
    }
}
