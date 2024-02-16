// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import "@fhenixprotocol/contracts/FHE.sol";
import "./test/IEncryptedERC20.sol";
import "@fhenixprotocol/contracts/access/Permissioned.sol";
import {FHE, euint32, inEuint8} from "@fhenixprotocol/contracts/FHE.sol";

contract EncryptedPair is Permissioned {
    // using FHE for euint32;
    // IERC20 public token0;
    IEncryptedERC20 public token0;
    // IERC20 public token1;
    IEncryptedERC20 public token1;
    // address public  factory;
    address public factory;

    // uint256 public reserve0;
    euint32 public reserve0;
    // uint256 public reserve1;
    euint32 public reserve1; 

    // uint public totalSupply;
    euint32 public totalSupply;
    // mapping(address => uint256) public balanceOf;
    mapping(address => euint32) private balances;

    constructor() {
        factory = msg.sender;
    }

    function balanceOf(
        address wallet,
        Permission calldata permission
    ) public view virtual onlySender(permission) returns (bytes memory) {
            return FHE.sealoutput(balances[wallet], permission.publicKey);
    }

    function initialize(address _token0, address _token1) external {
        require(msg.sender == factory, 'Only Factory can call this'); // sufficient check
        token0 = IEncryptedERC20(_token0);
        token1 = IEncryptedERC20(_token1);
    }

    // function _mint(address _to, uint _amount) private {
    //     balanceOf[_to] += _amount;
    //     totalSupply += _amount;
    // }

    function _mint(address _to, euint32 _amount) private {
        balances[_to] = FHE.add(balances[_to],_amount);
        totalSupply = FHE.add(totalSupply,_amount);
    }

    // function _burn(address _from, uint _amount) private {
    //     balanceOf[_from] -= _amount;
    //     totalSupply -= _amount;
    // }

    function _burn(address _from, euint32 _amount) private {
        balances[_from] = FHE.sub(balances[_from],_amount);
        totalSupply = FHE.sub(totalSupply,_amount);
    }

    // function _update(uint _reserve0, uint _reserve1) private {
    //     reserve0 = _reserve0;
    //     reserve1 = _reserve1;
    // }

    function _update(euint32 _reserve0, euint32 _reserve1) private {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }


    // function swap(address _tokenIn, euint calldata _amountIn) external returns (uint amountOut) {
    //     // euint32 x = TFHE.asEuint32(_amountIn);
    //     // uint32 amountIn = TFHE.decrypt(x);
    //     euint32 x = FHE.asEuint32(_amountIn);
    //     uint256 amountIn = FHE.decrypt(_amountIn);
        
    //     require(
    //         _tokenIn == address(token0) || _tokenIn == address(token1),
    //         "invalid token"
    //     );

    //     require(amountIn > 0, "amount in = 0");

    //     bool isToken0 = _tokenIn == address(token0);
    //     (IERC20 tokenIn, IERC20 tokenOut, uint reserveIn, uint reserveOut) = isToken0
    //         ? (token0, token1, reserve0, reserve1)
    //         : (token1, token0, reserve1, reserve0);

    //     tokenIn.transferFrom(msg.sender, address(this), amountIn);

    //     uint256 amountInWithFee = (amountIn * 997) / 1000;
    //     amountOut = (reserveOut * amountInWithFee) / (reserveIn + amountInWithFee);

    //     tokenOut.transfer(msg.sender, amountOut);

    //     _update(token0.balanceOf(address(this)), token1.balanceOf(address(this)));
    // }

    function swap(address _tokenIn, inEuint32 calldata _amountIn) public returns (euint32 amountOut){
        require(
            _tokenIn == address(token0) || _tokenIn == address(token1),
            "invalid token"
        );

        bool isToken0 = _tokenIn == address(token0);
        (IEncryptedERC20 tokenIn, IEncryptedERC20 tokenOut, euint32 reserveIn, euint32 reserveOut) = isToken0
            ? (token0, token1, reserve0, reserve1)
            : (token1, token0, reserve1, reserve0);

        euint32 amountIn = FHE.asEuint32(_amountIn);

        tokenIn.transferFrom(msg.sender, address(this), amountIn);

        euint32 amountInWithFee = FHE.div(FHE.mul(amountIn, FHE.asEuint32(997)), FHE.asEuint32(1000));

        amountOut = FHE.div(FHE.mul(reserveOut,amountInWithFee), FHE.add(reserveIn, amountInWithFee));

        tokenOut.transfer(msg.sender, amountOut);

        _update(token0.EuintbalanceOf(address(this)),token1.EuintbalanceOf(address(this)));
    }

    // function addLiquidity(inEuint32 calldata _amount0, inEuint32 calldata _amount1) external returns (uint shares) {
    //     // euint32 x = TFHE.asEuint32(_amount0);
    //     // euint32 y = TFHE.asEuint32(_amount1);
    //     // uint32 amount0 = TFHE.decrypt(x);
    //     // uint32 amount1 = TFHE.decrypt(y);

    //     euint32 x = FHE.asEuint32(_amount0);
    //     euint32 y = FHE.asEuint32(_amount1);

    //     // uint256 amount0 = FHE.decrypt(amount0);
    //     // uint256 amount1 = FHE.decrypt(amount0);
        
    //     bool t = token0.transferFrom(msg.sender, address(this), amount0);
    //     bool tt = token1.transferFrom(msg.sender, address(this), amount1);
    //     require(t && tt);

    //     if (reserve0 > 0 || reserve1 > 0) {
    //         require(reserve0 * amount1 == reserve1 * amount0, "x / y != dx / dy");
    //     }

    //     if (totalSupply == 0) {
    //         shares = _sqrt(amount0 * amount1);
    //     } else {
    //         uint256 z = uint256(amount0) * totalSupply / reserve0;
    //         uint256 a = uint256(amount1) * totalSupply / reserve1;
    //         shares = _min(z,a);
    //     }
    //     require(shares > 0, "shares = 0");
    //     _mint(msg.sender, shares);

    //     _update(token0.balanceOf(address(this)), token1.balanceOf(address(this)));
    // }

    function addLiquidity(inEuint32 calldata _amount0,inEuint32 calldata _amount1) external returns(euint32 shares) {
        euint32 amount0 = FHE.asEuint32(_amount0);
        euint32 amount1 = FHE.asEuint32(_amount1);

        bool t0 = token0.transferFrom(msg.sender, address(this), _amount0);
        bool t1 = token1.transferFrom(msg.sender, address(this), _amount1);

        require(t0 && t1);

        // if (FHE.decrypt(FHE.or(FHE.gt(reserve0,FHE.asEuint32(0)), FHE.gt(reserve1,FHE.asEuint32(0))))) {
        //     FHE.req(FHE.eq(FHE.mul(reserve0, amount0),FHE.mul(reserve1,amount1)));
        // }

        // if (FHE.decrypt(FHE.eq(totalSupply,FHE.asEuint32(0)))) {
        //     shares = FHE.asEuint32(_sqrt(FHE.decrypt(FHE.mul(amount0, amount1))));
        // }
        // else {
        //     euint32 x = FHE.div(FHE.mul(amount0,totalSupply),reserve0);
        //     euint32 y = FHE.div(FHE.mul(amount1,totalSupply),reserve1);

        //     shares = _min(x, y);
        // }

        // FHE.req(FHE.gt(shares,FHE.asEuint32(0)));

        // _mint(msg.sender, shares);

        // _update(token0.EuintbalanceOf(address(this)), token1.EuintbalanceOf(address(this)));
    }

    // function removeLiquidity(
    //     inEuint32 calldata _shares
    // ) external returns (uint amount0, uint amount1) {
        
    //     euint32 x = FHE.asEuint32(_shares);

    //     uint256 shares = FHE.decrypt(x);

    //     uint bal0 = token0.balanceOf(address(this));
    //     uint bal1 = token1.balanceOf(address(this));

    //     amount0 = (shares * bal0) / totalSupply;
    //     amount1 = (shares * bal1) / totalSupply;
    //     require(amount0 > 0 && amount1 > 0, "amount0 or amount1 = 0");

    //     _burn(msg.sender, shares);
    //     _update(bal0 - amount0, bal1 - amount1);

    //     token0.transfer(msg.sender, amount0);
    //     token1.transfer(msg.sender, amount1);
    // }

    function removeLiquidity(
            inEuint32 calldata _shares
    ) external returns (euint32 amount0, euint32 amount1) {
    
        euint32 shares = FHE.asEuint32(_shares);

        euint32 bal0 = token0.EuintbalanceOf(address(this));
        euint32 bal1 = token1.EuintbalanceOf(address(this));

        amount0 = FHE.div((FHE.mul(shares,bal0)),totalSupply);
        amount1 = FHE.div((FHE.mul(shares,bal1)),totalSupply);

        FHE.req(FHE.and(FHE.gt(amount0,FHE.asEuint32(0)), FHE.gt(amount1,FHE.asEuint32(0))));

        _burn(msg.sender, shares);
        _update(bal0 - amount0, bal1 - amount1);
        
        token0.transfer(msg.sender, amount0);
        token1.transfer(msg.sender, amount1);
    }

    function _sqrt(uint256 y) private pure returns (uint z) {
        // uint256 y = FHE.decrypt(a); 
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    // function _sqrt(euint32 y) public pure returns (euint32 z) { 
    //     if (FHE.decrypt(FHE.gt(y,FHE.asEuint32(uint256(3))))) {
    //         z = y;
    //         euint32 x = FHE.add((FHE.div(y,FHE.asEuint32(uint256(2)))),FHE.asEuint32(uint256(1)));
    //         while (FHE.decrypt(FHE.lt(x,z))) {
    //             z = x;
    //             x = FHE.div((FHE.div(y,FHE.add(x,x))),FHE.asEuint32(uint256(2)));
    //         }
    //     }
    //     else if (FHE.decrypt(FHE.ne(y,FHE.asEuint32(uint256(0))))) {
    //         z = FHE.asEuint32(uint256(1));
    //     }
    // }

    function _min(euint32 x, euint32 y) private pure returns (euint32) {
        if (FHE.decrypt(FHE.lte(x, y))) {
            return x;
        }
        else {
            return y;
        }
    }
}