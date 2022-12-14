// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/*
   _____ ________________  _____   ________
  / ___// ____/ ____/ __ \/  _/ | / / ____/
  \__ \/ __/ / __/ / / / // //  |/ / / __  
 ___/ / /___/ /___/ /_/ // // /|  / /_/ /  
/____/_____/_____/_____/___/_/ |_/\____/   
*/
contract TombTaxOracle is Ownable {
    using SafeMath for uint256;

    IERC20 public tomb;
    IERC20 public wftm;
    address public pair;

    constructor(
        address _tomb,
        address _wftm,
        address _pair
    ) public {
        require(_tomb != address(0), "tomb address cannot be 0");
        require(_wftm != address(0), "wftm address cannot be 0");
        require(_pair != address(0), "pair address cannot be 0");
        tomb = IERC20(_tomb);
        wftm = IERC20(_wftm);
        pair = _pair;
    }

    function consult(address _token) external view returns (uint144 amountOut) {
        require(_token == address(tomb), "token needs to be tomb");
        uint256 tombBalance = tomb.balanceOf(pair);
        uint256 wftmBalance = wftm.balanceOf(pair);
        return uint144(tombBalance.div(wftmBalance));
    }

    function setTomb(address _tomb) external onlyOwner {
        require(_tomb != address(0), "tomb address cannot be 0");
        tomb = IERC20(_tomb);
    }

    function setWftm(address _wftm) external onlyOwner {
        require(_wftm != address(0), "wftm address cannot be 0");
        wftm = IERC20(_wftm);
    }

    function setPair(address _pair) external onlyOwner {
        require(_pair != address(0), "pair address cannot be 0");
        pair = _pair;
    }
}
