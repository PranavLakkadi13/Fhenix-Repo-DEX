// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import "@fhenixprotocol/contracts/FHE.sol";

contract TestMath {
    function _sqrt(uint y) private pure returns (uint z) {
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

    function sqrt(euint32 y) private pure returns (euint32 z) {
        if (FHE.decrypt(FHE.gt(y, FHE.asEuint32(3)))) {
            z = y;
            euint32 x = FHE.add(FHE.div(y, FHE.asEuint32(uint256(2))), FHE.asEuint32(uint256(1)));
            while (FHE.decrypt(FHE.lt(x, z))) {
                z = x;
                x = FHE.div(FHE.div(y, FHE.add(x,x)), FHE.asEuint32(uint256(2)));
            }
        }
        else if (FHE.decrypt(FHE.ne(y, FHE.asEuint32(uint256(0))))) {
            z = FHE.asEuint32(uint256(1));
        }
    }

    function getSQRT(inEuint32 calldata num) public pure returns (uint256 x) {
        euint32 y = FHE.asEuint32(num);
        euint32 z = sqrt(y);
        x = FHE.decrypt(z);
    }

}