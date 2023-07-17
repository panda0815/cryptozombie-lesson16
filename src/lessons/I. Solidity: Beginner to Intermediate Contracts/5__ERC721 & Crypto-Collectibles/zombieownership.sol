pragma solidity >=0.5.0 <0.6.0;

import "./zombieattack.sol";
import "./erc721.sol";
import "./safemath.sol";

// @title a smart contract of zombie games
// @author drwise
// @dev Compliant with OpenZeppelin's implementation of the ERC721 spec draft

contract ZombieOwnership is ZombieAttack, ERC721 {

  using SafeMath for uint256;

  // Add mapping for zombie transfers based on owner address
  mapping (uint => address) zombieApprovals;

  function balanceOf(address _owner) external view returns (uint256) {
    // Returns zombie count balance
    return ownerZombieCount[_owner];
  }

  function ownerOf(uint256 _tokenId) external view returns (address) {
    // Returns tokenID to owner of zombie
    return zombieToOwner[_tokenId];
  }

  function _transfer(address _from, address _to, uint256 _tokenId) private {
    // Transfer zombie count to new owner
    ownerZombieCount[_to] = ownerZombieCount[_to].add(1);
    ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].sub(1);
    zombieToOwner[_tokenId] = _to;
    emit Transfer(_from, _to, _tokenId);
  }

  function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
    // Verify only the owner can transfer before calling transfer
    require (zombieToOwner[_tokenId] == msg.sender || zombieApprovals[_tokenId] == msg.sender);
    _transfer(_from, _to, _tokenId);
  }

  function approve(address _approved, uint256 _tokenId) external payable onlyOwnerOf(_tokenId) {
    // Approve transfer and emit event
    zombieApprovals[_tokenId] = _approved;
    emit Approval(msg.sender, _approved, _tokenId);
  }

}
