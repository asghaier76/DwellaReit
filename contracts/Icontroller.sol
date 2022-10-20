// SPDX-License-Identifier: MIT

pragma solidity >= 0.7.4;

interface IController { 
    
    // schema of the investor record
    struct InvestorRecord {
        uint256 kycHash;
        bool isApproved;
        bool isActive;
        investorCategory cat;
    }
    
    enum investorCategory { CAT_A, CAT_B, CAT_C, CAT_D }
    
    function addRegisteredInvestor(address investorAddress_, uint256 kycHash_, investorCategory cat_) external view returns (bool);
    
    function removeAccount(address investorAddress_) external view returns (bool);
    
    function freezeAccount(address investorAddress_) external view returns (bool);
    
    function unfreezeAccount(address investorAddress_) external view returns (bool);
    
    function updateCategory(address investorAddress_, investorCategory cat_) external view returns (bool);
    
    function updateKyc(address investorAddress_, uint256 kycHash_) external view returns (bool);
    
    function isApprovedInvestor(address investorAddress_) external view returns (bool);
    
    event AccountFreeze(address indexed investor, bool isActive);
    
    event KycUpdate(address indexed investor, uint256 kycHash);
    
    event CategoryUpdate(address indexed investor, investorCategory cat);
    
    
}