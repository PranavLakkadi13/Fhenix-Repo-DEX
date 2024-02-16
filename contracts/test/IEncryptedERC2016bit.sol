// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@fhenixprotocol/contracts/FHE.sol";
import "@fhenixprotocol/contracts/access/Permissioned.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

interface IEncryptedERC20 {
    // event Transfer(address indexed from, address indexed to);
    // event Approval(address indexed owner, address indexed spender);
    // event Mint(address indexed to, uint32 amount);

    // Returns the name of the token.
    function name() external view returns (string memory) ;

    // Returns the symbol of the token, usually a shorter version of the name.
    function symbol() external view  returns (string memory);

    // Returns the total supply of the token
    function totalSupply() external view returns (uint16) ;

    // Sets the balance of the owner to the given encrypted balance.
    function mint(uint16 mintedAmount) external;

    // Transfers an encrypted amount from the message sender address to the `to` address.
    function transfer(address to, inEuint16 calldata encryptedAmount) external returns (bool);

    // Transfers an amount from the message sender address to the `to` address.
    function transfer(address to, euint16 amount) external returns (bool);

    // Returns the balance of the caller encrypted under the provided external key.
    function balanceOf(
        address wallet,
        Permission calldata permission
    ) external view returns (bytes memory) ;

    function EuintbalanceOf(
        address wallet
    ) external view returns (euint16) ;

    // Sets the `encryptedAmount` as the allowance of `spender` over the caller's tokens.
    function approve(address spender, inEuint16 calldata encryptedAmount) external returns (bool) ;

    // Sets the `amount` as the allowance of `spender` over the caller's tokens.
    function approve(address spender, euint16 amount) external returns (bool) ;

    // Returns the remaining number of tokens that `spender` is allowed to spend
    // on behalf of the caller. The returned ciphertext is under the caller external FHE key.
    function allowance(
        address owner,
        address spender,
        Permission calldata permission
    ) external view returns (bytes memory) ;

    // Transfers `encryptedAmount` tokens using the caller's allowance.
    function transferFrom(address from, address to, inEuint16 calldata encryptedAmount) external returns (bool) ;

    // Transfers `amount` tokens using the caller's allowance.
    function transferFrom(address from, address to, euint16 amount) external returns (bool) ;

}