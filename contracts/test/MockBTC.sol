// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@fhenixprotocol/contracts/FHE.sol";
import "@fhenixprotocol/contracts/access/Permissioned.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract MockBTC is Permissioned, Ownable2Step {
    event Transfer(address indexed from, address indexed to);
    event Approval(address indexed owner, address indexed spender);
    event Mint(address indexed to, uint32 amount);

    uint32 private _totalSupply;
    string private _name;
    string private _symbol;

    // A mapping from address to an encrypted balance.
    mapping(address => euint32) internal balances;

    // A mapping of the form mapping(owner => mapping(spender => allowance)).
    mapping(address => mapping(address => euint32)) internal allowances;

    constructor(string memory name_, string memory symbol_) Ownable(msg.sender) {
        _name = name_;
        _symbol = symbol_;
    }

    // Returns the name of the token.
    function name() public view virtual returns (string memory) {
        return _name;
    }

    // Returns the symbol of the token, usually a shorter version of the name.
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    // Returns the total supply of the token
    function totalSupply() public view virtual returns (uint32) {
        return _totalSupply;
    }

    // Sets the balance of the owner to the given encrypted balance.
    function mint(uint32 mintedAmount) public virtual  {
        balances[msg.sender] = FHE.add(balances[msg.sender], FHE.asEuint32(mintedAmount)); // overflow impossible because of next line
        _totalSupply = _totalSupply + mintedAmount;
        emit Mint(msg.sender, mintedAmount);
    }

    // Transfers an encrypted amount from the message sender address to the `to` address.
    function transfer(address to, inEuint32 calldata encryptedAmount) public returns (bool) {
        transfer(to, FHE.asEuint32(encryptedAmount));
        return true;
    }

    // Transfers an amount from the message sender address to the `to` address.
    function transfer(address to, euint32 amount) public returns (bool) {
        // makes sure the owner has enough tokens
        ebool canTransfer = FHE.lte(amount, balances[msg.sender]);
        _transfer(msg.sender, to, amount, canTransfer);
        return true;
    }

    // Returns the balance of the caller encrypted under the provided public key.
    function balanceOf(
        address wallet,
        Permission calldata permission
    ) public view virtual onlySender(permission) returns (bytes memory) {
            return FHE.sealoutput(balances[wallet], permission.publicKey);
    }

    function EuintbalanceOf(
        address wallet
    ) public view virtual returns (euint32) {
            return balances[wallet];
    }

    // Sets the `encryptedAmount` as the allowance of `spender` over the caller's tokens.
    function approve(address spender, inEuint32 calldata encryptedAmount) public returns (bool) {
        approve(spender, FHE.asEuint32(encryptedAmount));
        return true;
    }

    // Sets the `amount` as the allowance of `spender` over the caller's tokens.
    function approve(address spender, euint32 amount) public returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        emit Approval(owner, spender);
        return true;
    }

    // Returns the remaining number of tokens that `spender` is allowed to spend
    // on behalf of the caller. The returned ciphertext is under the caller public FHE key.
    function allowance(
        address owner,
        address spender,
        Permission calldata permission
    ) public view onlySender(permission) returns (bytes memory) {
        require(owner == msg.sender || spender == msg.sender);
        return FHE.sealoutput(_allowance(owner, spender), permission.publicKey);
    }

    // Transfers `encryptedAmount` tokens using the caller's allowance.
    function transferFrom(address from, address to, inEuint32 calldata encryptedAmount) public returns (bool) {
        transferFrom(from, to, FHE.asEuint32(encryptedAmount));
        return true;
    }

    // Transfers `amount` tokens using the caller's allowance.
    function transferFrom(address from, address to, euint32 amount) public returns (bool) {
        address spender = msg.sender;
        ebool isTransferable = _updateAllowance(from, spender, amount);
        _transfer(from, to, amount, isTransferable);
        return true;
    }

    function _approve(address owner, address spender, euint32 amount) internal {
        allowances[owner][spender] = amount;
    }

    function _allowance(address owner, address spender) internal view returns (euint32) {
        if (FHE.isInitialized(allowances[owner][spender])) {
            return allowances[owner][spender];
        } else {
            return FHE.asEuint32(0);
        }
    }

    function _updateAllowance(address owner, address spender, euint32 amount) internal returns (ebool) {
        euint32 currentAllowance = _allowance(owner, spender);
        // makes sure the allowance suffices
        ebool allowedTransfer = FHE.lte(amount, currentAllowance);
        // makes sure the owner has enough tokens
        ebool canTransfer = FHE.lte(amount, balances[owner]);
        ebool isTransferable = FHE.and(canTransfer, allowedTransfer);
        _approve(owner, spender, FHE.select(isTransferable, currentAllowance - amount, currentAllowance));
        return isTransferable;
    }

    // Transfers an encrypted amount.
    function _transfer(address from, address to, euint32 amount, ebool isTransferable) internal {
        // Add to the balance of `to` and subract from the balance of `from`.
        balances[to] = balances[to] + FHE.select(isTransferable, amount, FHE.asEuint32(0));
        balances[from] = balances[from] - FHE.select(isTransferable, amount, FHE.asEuint32(0));
        emit Transfer(from, to);
    }
}