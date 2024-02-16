// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import "@fhenixprotocol/contracts/FHE.sol";
import "./test/IEncryptedERC20.sol";
import "@fhenixprotocol/contracts/access/Permissioned.sol";

contract EncryptedPairEuint8 is Permissioned {
    // using FHE for euint32;
    // IERC20 public token0;
    IEncryptedERC20 public token0;
    // IERC20 public token1;
    IEncryptedERC20 public token1;
    // address public  factory;
    address public factory;

    // uint256 public reserve0;
    euint8 public reserve0;
    // uint256 public reserve1;
    euint8 public reserve1; 

    // uint public totalSupply;
    euint8 public totalSupply;
    // mapping(address => uint256) public balanceOf;
    mapping(address => euint8) private balances;

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

    function _mint(address _to, euint8 _amount) private {
        balances[_to] = FHE.add(balances[_to],_amount);
        totalSupply = FHE.add(totalSupply,_amount);
    }

    function _burn(address _from, euint8 _amount) private {
        balances[_from] = FHE.sub(balances[_from],_amount);
        totalSupply = FHE.sub(totalSupply,_amount);
    }

    function _update(euint8 _reserve0, euint8 _reserve1) private {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }

    function swap(address _tokenIn, inEuint8 calldata _amountIn) public returns (euint8 amountOut){
        require(
            _tokenIn == address(token0) || _tokenIn == address(token1),
            "invalid token"
        );

        bool isToken0 = _tokenIn == address(token0);
        (IEncryptedERC20 tokenIn, IEncryptedERC20 tokenOut, euint8 reserveIn, euint8 reserveOut) = isToken0
            ? (token0, token1, reserve0, reserve1)
            : (token1, token0, reserve1, reserve0);

        euint8 amountIn = FHE.asEuint8(_amountIn);

        FHE.req(FHE.ne(amountIn,FHE.asEuint8(0)));

        bool k = tokenIn.transferFrom(msg.sender, address(this), FHE.asEuint32(amountIn));
        require(k);

        // euint32 amountInWithFee = FHE.div(FHE.mul(amountIn, FHE.asEuint32(997)), FHE.asEuint32(1000));

        // amountOut = FHE.div(FHE.mul(reserveOut,amountInWithFee), FHE.add(reserveIn, amountInWithFee));

        // amountOut = FHE.div(FHE.mul(reserveOut, amountIn), FHE.add(reserveIn, amountIn));
        // FHE.req(FHE.gt(amountOut,FHE.asEuint8(0)));

        // bool t = tokenOut.transfer(msg.sender, FHE.asEuint32(amountOut));
        // require(t);

        // _update(FHE.asEuint8(token0.EuintbalanceOf(address(this))),FHE.asEuint8(token1.EuintbalanceOf(address(this))));
    }

    function addLiquidity(inEuint8 calldata _amount0,inEuint8 calldata _amount1) external returns(euint8 shares) {
        euint8 amount0 = FHE.asEuint8(_amount0);
        euint8 amount1 = FHE.asEuint8(_amount1);

        bool t0 = token0.transferFrom(msg.sender, address(this), FHE.asEuint32(amount0));
        bool t1 = token1.transferFrom(msg.sender, address(this), FHE.asEuint32(amount1));

        require(t0 && t1);

        if (FHE.decrypt(FHE.or(FHE.gt(reserve0,FHE.asEuint8(0)), FHE.gt(reserve1,FHE.asEuint8(0))))) {
            FHE.req(FHE.eq(FHE.mul(reserve0, amount0),FHE.mul(reserve1,amount1)));
        }

        if (FHE.decrypt(FHE.eq(totalSupply,FHE.asEuint8(0)))) {
            shares = FHE.asEuint8(_sqrt(FHE.mul(amount0,amount1)));
        }
        else {
            euint8 x = FHE.div(FHE.mul(amount0,totalSupply),reserve0);
            euint8 y = FHE.div(FHE.mul(amount1,totalSupply),reserve1);

            shares = _min(x, y);
        }

        FHE.req(FHE.gt(shares,FHE.asEuint8(0)));

        _mint(msg.sender, shares);

        _update(FHE.asEuint8(token0.EuintbalanceOf(address(this))), FHE.asEuint8(token1.EuintbalanceOf(address(this))));
    
        return shares;
    }

    
    function removeLiquidity(
            inEuint8 calldata _shares
    ) external returns (euint8 amount0, euint8 amount1) {

        euint8 shares = FHE.asEuint8(_shares);
    
        euint8 bal0 = FHE.asEuint8(token0.EuintbalanceOf(address(this)));
        euint8 bal1 = FHE.asEuint8(token1.EuintbalanceOf(address(this)));

        FHE.req(FHE.and(FHE.ne(bal0,FHE.asEuint8(0)),FHE.ne(bal1,FHE.asEuint8(0))));

        // amount0 = (_shares * bal0) / totalSupply;
        amount0 = FHE.div(FHE.mul(shares, bal0),totalSupply);
       
        // // amount1 = (_shares * bal1) / totalSupply;
        amount1 = FHE.div(FHE.mul(shares, bal1),totalSupply);
       
        // // require(amount0 > 0 && amount1 > 0, "amount0 or amount1 = 0");
        FHE.req(FHE.and(FHE.gt(amount0,FHE.asEuint8(0)),FHE.gt(amount1,FHE.asEuint8(0))));

        // // // _burn(msg.sender, _shares);
        _burn(msg.sender, shares);
       
        // // // _update(bal0 - amount0, bal1 - amount1);
        _update(FHE.sub(bal0,amount0), FHE.sub(bal1,amount1));

        FHE.req(FHE.gt(FHE.asEuint32(amount0),FHE.asEuint32(0)));

        bool t = token0.transfer(msg.sender, FHE.asEuint32(amount0));
        // bool t2 = token1.transfer(msg.sender, FHE.asEuint32(amount1));

        // require(t && t2);
    }

    function _sqrt(euint8 a) private pure returns (uint z) {
        uint256 y = FHE.decrypt(a); 
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

    function _min(euint8 x, euint8 y) private pure returns (euint8) {
        if (FHE.decrypt(FHE.lte(x, y))) {
            return x;
        }
        else {
            return y;
        }
    }
}