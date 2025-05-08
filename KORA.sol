// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./OFT.sol";
import "./Ownable.sol";

contract KORA is OFT, Ownable {
    bool public mintingLocked = false;

    struct Lock {
        uint256 amount;
        uint256 unlockTime;
    }

    mapping(address => Lock[]) public locks;

    constructor(address _lzEndpoint) OFT("Kora Net", "KORA", _lzEndpoint) {
        _mint(msg.sender, 1_500_000_000 * 10 ** decimals);
        mintingLocked = true;
    }

    
    function lock(address user, uint256 amount, uint256 unlockTime) public onlyOwner {
        require(unlockTime > block.timestamp, "Time error");
        _transfer(user, address(this), amount);
        locks[user].push(Lock(amount, unlockTime));
    }

    
    function unlock() public {
        uint256 unlocked = 0;
        Lock[] storage userLocks = locks[msg.sender];
        for (uint256 i = 0; i < userLocks.length;) {
            if (block.timestamp >= userLocks[i].unlockTime) {
                unlocked += userLocks[i].amount;
                userLocks[i] = userLocks[userLocks.length - 1];
                userLocks.pop();
            } else {
                unchecked { ++i; }
            }
        }
        require(unlocked > 0, "Nothing to unlock");
        _transfer(address(this), msg.sender, unlocked);
    }

    function getLocks(address user) external view returns (Lock[] memory) {
        return locks[user];
    }


    function renounceEverything() external onlyOwner {
        mintingLocked = true;
        renounceOwnership();
    }
}