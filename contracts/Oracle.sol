// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";

import "./lib/Babylonian.sol";
import "./lib/FixedPoint.sol";
// import "./lib/UniswapV2OracleLibrary.sol";
import "./utils/Epoch.sol";
import "./interfaces/IPair.sol";

/*
   _____ ________________  _____   ________
  / ___// ____/ ____/ __ \/  _/ | / / ____/
  \__ \/ __/ / __/ / / / // //  |/ / / __  
 ___/ / /___/ /___/ /_/ // // /|  / /_/ /  
/____/_____/_____/_____/___/_/ |_/\____/   
*/
// fixed window oracle that recomputes the average price for the entire period once every period
// note that the price average is only guaranteed to be over at least 1 period, but may be over a longer period
contract Oracle is Epoch {
    using FixedPoint for *;
    using SafeMath for uint256;

    /* ========== STATE VARIABLES ========== */

    // uniswap
    address public token0;
    address public token1;
    IPair public pair;

    // oracle
    uint256 public reserve0;
    uint256 public reserve1;
    uint256 public blockTimestampLast;

    uint256 public reserve0CumulativeLast;
    uint256 public reserve1CumulativeLast;

    /* ========== CONSTRUCTOR ========== */

    constructor(
        IPair _pair,
        uint256 _period,
        uint256 _startTime
    ) public Epoch(_period, _startTime, 0) {
        pair = _pair;
        token0 = pair.token0();
        token1 = pair.token1();
        reserve0CumulativeLast = pair.reserve0CumulativeLast(); // fetch the current accumulated price value (1 / 0)
        reserve1CumulativeLast = pair.reserve1CumulativeLast(); // fetch the current accumulated price value (0 / 1)
        (reserve0, reserve1, blockTimestampLast) = pair.getReserves();
        require(reserve0 != 0 && reserve1 != 0, "Oracle: NO_RESERVES"); // ensure that there's liquidity in the pair
    }

    /* ========== MUTABLE FUNCTIONS ========== */

    /** @dev Updates 1-day EMA price from Uniswap.  */
    function update() external checkEpoch {
        (reserve0, reserve1, blockTimestampLast) = pair.getReserves();
        (
            reserve0CumulativeLast,
            reserve0CumulativeLast,
            blockTimestampLast
        ) = pair.currentCumulativePrices();
        emit Updated(reserve0CumulativeLast, reserve0CumulativeLast);
    }

    // note this will always return 0 before update has been called successfully for the first time.
    function consult(address _token, uint256 _amountIn)
        external
        view
        returns (uint256 amountOut)
    {
        if (_token == token0) {
            amountOut = pair.quote(_token, _amountIn, 1);
        } else {
            require(_token == token1, "Oracle: INVALID_TOKEN");
            amountOut = pair.quote(token1, _amountIn, 1);
        }
    }

    function twap(address _token, uint256 _amountIn)
        external
        view
        returns (uint256 _amountOut)
    {
        return pair.current(_token, _amountIn);
    }

    event Updated(uint256 reserve0, uint256 reserve1);
}
