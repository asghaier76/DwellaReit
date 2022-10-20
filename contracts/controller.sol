// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Controller is Ownable { 
    
    // schema of the investor record
    struct InvestorRecord {
        string kycHash;
        bool isApproved;
        bool isActive;
        bool exists;
        investorCategory cat;
    }
    
    mapping (address => InvestorRecord) public registered_investors;
    
    enum investorCategory { CAT_A, CAT_B, CAT_C, CAT_D }
    
    event Investor(address indexed investor, string _kycHash, investorCategory _cat);
    
    event AccountFreeze(address indexed investor, bool isActive);
    
    event KycUpdate(address indexed investor, string kycHash);
    
    event CategoryUpdate(address indexed investor, investorCategory cat);
    
    constructor() {
        
    }
    
    function addRegisteredInvestor(address investorAddress_, string memory kycHash_, investorCategory cat_) public onlyOwner {
        require(registered_investors[investorAddress_].exists == false, "IA 405");
        registered_investors[investorAddress_].kycHash = kycHash_;
        registered_investors[investorAddress_].isActive = true;
        registered_investors[investorAddress_].isApproved = true;
        registered_investors[investorAddress_].exists = true;
        registered_investors[investorAddress_].cat = cat_;
        
        emit Investor(investorAddress_, kycHash_, cat_);
    }
    
    function removeAccount(address investorAddress_) public onlyOwner {
        require(registered_investors[investorAddress_].exists == true, "IA 404");
        delete registered_investors[investorAddress_];
        
        // emit Investor(investorAddress_, 0);
    }
    
    function freezeAccount(address investorAddress_) public onlyOwner{
        require(registered_investors[investorAddress_].exists == true, "IA 404");
        registered_investors[investorAddress_].isActive = false;
        
        emit AccountFreeze(investorAddress_, false);
    }
    
    function unfreezeAccount(address investorAddress_) public onlyOwner{
        require(registered_investors[investorAddress_].exists == true, "IA 404");
        registered_investors[investorAddress_].isActive = true;
        
        emit AccountFreeze(investorAddress_, true);
    }
    
    function updateCategory(address investorAddress_, investorCategory cat_) public onlyOwner{
        require(registered_investors[investorAddress_].exists == true, "IA 404");
        registered_investors[investorAddress_].cat = cat_;
        
        emit CategoryUpdate(investorAddress_, cat_);
    }
    
    function isApprovedInvestor(address investorAddress_) public view returns (bool) {
        return registered_investors[investorAddress_].isApproved;
    }
    
    function updateKyc(address investorAddress_, string memory kycHash_) public onlyOwner {
        require(registered_investors[investorAddress_].exists == true, "IA 404");
        registered_investors[investorAddress_].kycHash = kycHash_;
        
        emit KycUpdate(investorAddress_, kycHash_);
    }
    
}