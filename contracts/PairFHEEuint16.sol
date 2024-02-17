// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import "@fhenixprotocol/contracts/FHE.sol";
import "./test/IEncryptedERC2016bit.sol";
import "@fhenixprotocol/contracts/access/Permissioned.sol";

contract EncryptedPairEuint16 is Permissioned {
    // using FHE for euint32;
    // IERC20 public token0;
    IEncryptedERC2016bit public token0;
    // IERC20 public token1;
    IEncryptedERC2016bit public token1;
    // address public  factory;
    address public factory;

    // uint256 public reserve0;
    euint16 public reserve0;
    // uint256 public reserve1;
    euint16 public reserve1; 

    // uint public totalSupply;
    euint16 public totalSupply;
    // mapping(address => uint256) public balanceOf;
    mapping(address => euint16) private balances;

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
        token0 = IEncryptedERC2016bit(_token0);
        token1 = IEncryptedERC2016bit(_token1);
    }

    function _mint(address _to, euint16 _amount) private {
        balances[_to] = FHE.add(balances[_to],_amount);
        totalSupply = FHE.add(totalSupply,_amount);
    }

    function _burn(address _from, euint16 _amount) private {
        balances[_from] = FHE.sub(balances[_from],_amount);
        totalSupply = FHE.sub(totalSupply,_amount);
    }

    function _update(euint16 _reserve0, euint16 _reserve1) private {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }

    function swap(address _tokenIn, inEuint16 calldata _amountIn) public returns (euint16 amountOut){
        require(
            _tokenIn == address(token0) || _tokenIn == address(token1),
            "invalid token"
        );

        bool isToken0 = _tokenIn == address(token0);
        (IEncryptedERC2016bit tokenIn, IEncryptedERC2016bit tokenOut, euint16 reserveIn, euint16 reserveOut) = isToken0
            ? (token0, token1, reserve0, reserve1)
            : (token1, token0, reserve1, reserve0);

        euint16 amountIn = FHE.asEuint16(_amountIn);

        FHE.req(FHE.ne(amountIn,FHE.asEuint16(0)));

        bool k = tokenIn.transferFrom(msg.sender, address(this), amountIn);
        require(k);

        // euint16 amountInWithFee = FHE.div(FHE.mul(amountIn, FHE.asEuint16(997)), FHE.asEuint16(1000));

        // amountOut = FHE.div(FHE.mul(reserveOut,amountInWithFee), FHE.add(reserveIn, amountInWithFee));

        amountOut = FHE.div(FHE.mul(reserveOut, amountIn), FHE.add(reserveIn, amountIn));


        if (FHE.decrypt(FHE.eq(amountOut,FHE.asEuint16(0)))) {
            amountOut = FHE.asEuint16(1);
        }
        
        FHE.req(FHE.gt(amountOut,FHE.asEuint16(0)));

        bool t = tokenOut.transfer(msg.sender,amountOut);
        require(t);

        _update(token0.EuintbalanceOf(address(this)),token1.EuintbalanceOf(address(this)));
    }

    function addLiquidity(inEuint16 calldata _amount0,inEuint16 calldata _amount1) external returns(euint16 shares) {
        euint16 amount0 = FHE.asEuint16(_amount0);
        euint16 amount1 = FHE.asEuint16(_amount1);

        bool t0 = token0.transferFrom(msg.sender, address(this), amount0);
        bool t1 = token1.transferFrom(msg.sender, address(this), amount1);

        require(t0 && t1);

        if (FHE.decrypt(FHE.or(FHE.gt(reserve0,FHE.asEuint16(0)), FHE.gt(reserve1,FHE.asEuint16(0))))) {
            FHE.req(FHE.eq(FHE.mul(reserve0, amount1),FHE.mul(reserve1,amount0)));
        }

        if (FHE.decrypt(FHE.eq(totalSupply,FHE.asEuint16(0)))) {
            shares = FHE.asEuint16(_sqrt(FHE.mul(amount0,amount1)));
        }
        if (FHE.decrypt(FHE.gt(totalSupply,FHE.asEuint16(0)))) {
            euint16 x = FHE.div(FHE.mul(amount0,totalSupply),reserve0);
            euint16 y = FHE.div(FHE.mul(amount1,totalSupply),reserve1);
            // euint16 x = FHE.mul(amount0,FHE.div(totalSupply,reserve0));
            // euint16 y = FHE.mul(amount1,FHE.div(totalSupply,reserve1));

            shares = _min(x, y);
        }

        FHE.req(FHE.gt(shares,FHE.asEuint16(0)));

        _mint(msg.sender, shares);

        _update(token0.EuintbalanceOf(address(this)), token1.EuintbalanceOf(address(this)));
    
        return shares;
    }

    
    function removeLiquidity(
            inEuint16 calldata _shares
    ) external returns (euint16 amount0, euint16 amount1) {

        euint16 shares = FHE.asEuint16(_shares);

        FHE.req(FHE.gte(balances[msg.sender],shares));
    
        euint16 bal0 = token0.EuintbalanceOf(address(this));
        euint16 bal1 = token1.EuintbalanceOf(address(this));

        FHE.req(FHE.and(FHE.ne(bal0,FHE.asEuint16(0)),FHE.ne(bal1,FHE.asEuint16(0))));

        // amount0 = (_shares * bal0) / totalSupply;
        amount0 = FHE.div(FHE.mul(shares, bal0),totalSupply);
       
        // // amount1 = (_shares * bal1) / totalSupply;
        amount1 = FHE.div(FHE.mul(shares, bal1),totalSupply);
       
        // // require(amount0 > 0 && amount1 > 0, "amount0 or amount1 = 0");
        FHE.req(FHE.and(FHE.gt(amount0,FHE.asEuint16(0)),FHE.gt(amount1,FHE.asEuint16(0))));

        // // // _burn(msg.sender, _shares);
        _burn(msg.sender, shares);
       
        // // // _update(bal0 - amount0, bal1 - amount1);
        _update(FHE.sub(bal0,amount0), FHE.sub(bal1,amount1));

        FHE.req(FHE.gt(amount0,FHE.asEuint16(0)));
        FHE.req(FHE.gt(amount1,FHE.asEuint16(0)));

        bool t = token0.transfer(msg.sender, amount0);
        bool t2 = token1.transfer(msg.sender, amount1);

        require(t && t2);
    }

    function _sqrt(euint16 a) private pure returns (uint z) {
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

    function _min(euint16 x, euint16 y) private pure returns (euint16) {
        if (FHE.decrypt(FHE.lte(x, y))) {
            return x;
        }
        else {
            return y;
        }
    }

    function getReserve0() public view returns (uint16) {
        return FHE.decrypt(reserve0);
    }

    function getReserve1() public view returns (uint16) {
        return FHE.decrypt(reserve1);
    }

    function getTotalSupply() public view returns (uint16) {
        return FHE.decrypt(totalSupply);
    }
}