// SPDX-License-Identifier: MIT

pragma solidity  ^0.8.9;

import "./TokenStorage.sol";
import "./controller.sol";

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract DwellaReit is Pausable, TokenStorage, ReentrancyGuard {
    using Strings for uint256;
    string public symbol;                   // 
    string public name;                     // 
    string public uriPrefix;
    string public uriSuffix;
    string private contractMetadata = 'contract.json';

    address public platform_address;
    
    address controller_contract;
    
    Controller controllerContract;
    
    uint256 public constant MAX_TOKENS_ASSET = 50; 

    event TokenPurchase(address indexed investor, uint256 indexed tokenId, uint256 amount);
/**
     * @dev Set `_address` as `controller_contract` and set external call instance `cantrollerContract`.
     *
     * Can only be called by addresses with ADMIN_ROLE access.
     *
     * @param _address - Controller Contract address
     */  
    function setControllerContract(address _address) external onlyAdmin whenPaused {
        controller_contract = _address;
        controllerContract = Controller(controller_contract);
    }

    function setPlatformAddress(address _address) external onlyAdmin whenPaused {
        platform_address = _address;
    }
    
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        public
        override
    {
        require(controllerContract.isApprovedInvestor(msg.sender) || (from == platform_address && controllerContract.isApprovedInvestor(msg.sender)), "Access Denied: Caller is not approved");
        safeTransferFrom(from,to,id,amount,data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        public
        override
    {
        require(controllerContract.isApprovedInvestor(msg.sender) || (from == platform_address && controllerContract.isApprovedInvestor(msg.sender)), "Access Denied: Caller is not approved");
        safeBatchTransferFrom(from,to,ids,amounts,data);
    }
    
    
    /**
     * @dev Set `_paused` to true or false to pause or unpause the contract by calling
     * PausableUpgradeable _pause or _unpause functions.
     *
     * Can only be called by addresses with ADMIN_ROLE access.
     */
    function pause() external onlyAdmin {
        _pause();
    }
    
    function unpause() external onlyAdmin {
        _unpause();
    }

        /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     */
    function uri(uint256 tokenId) public view override returns (string memory) {
        require(exists(tokenId),"ERC1155Metadata: URI query for nonexistent token");
        return
            bytes(uriPrefix).length > 0
                ? string(abi.encodePacked(uriPrefix, tokenId.toString(), uriSuffix))
                : '';
    }
   
    function contractURI() public view returns (string memory) {
        return string(abi.encodePacked(uriPrefix, contractMetadata));
    }

    function setBaseURI(string memory baseContractURI) external onlyAdmin {
        uriPrefix = baseContractURI;
    }
    
    /**
     * @dev Set platform address and metadata params
     * 
     * Construct ERC1155 token with URI by calling ERC1155 constructor function.
     */    
    constructor(
        address platform_address_,
        string memory name_, 
        string memory symbol_, 
        string memory uriPrefix_, 
        string memory uriSuffix_
        ) TokenStorage(uriPrefix_) {
            platform_address = platform_address_;
            name = name_;
            symbol = symbol_;
            uriPrefix = uriPrefix_;
            uriSuffix = uriSuffix_;
            _setRoleAdmin(ADMIN_ROLE, MODERATOR);
            _setupRole(MODERATOR, msg.sender);
            _setupRole(ADMIN_ROLE, msg.sender); 
    }
    

    /**
     * @dev Throws if called by any account without ADMIN_ROLE access.
     */
    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "Access Denied: Caller is not the Admin");
        _;
    }
    

    /**
     * @dev Series of functions to retrieve token details from main token struct, including
     * Max Supply, Owner Address, Valuation Report, Legal Contract hashes, Service Fee and Token Rate.
     *
     * @param tokenId - Unique token id of token
     */
    function getMaxSupply(uint256 tokenId) external view returns (uint256) {
        REToken memory token = reToken[tokenId];
        return token.maxSupply;
    }

    function getOwner(uint256 tokenId) external view returns (address) {
        REToken memory token = reToken[tokenId];
        return token.owner;
    }

    function getValuationRpt(uint256 tokenId) external view returns (string memory) {
        REToken memory token = reToken[tokenId];
        return token.valuationReport;
    }

    function getLegalContr(uint256 tokenId) external view returns (string memory) {
        REToken memory token = reToken[tokenId];
        return token.legalContract;
    }

    function getFee(uint256 tokenId) public view returns (uint256) {
        REToken memory token = reToken[tokenId];
        return token.fee;
    }

    function getRate(uint256 tokenId) public view returns (uint256) {
        REToken memory token = reToken[tokenId];
        return token.rate;
    }

    /**
     * @dev Creates a token type for an asset with all details for token struct.
     *
     * Can only be called by the current admin.
     * 
     * Emits a {RETokenID} event.
     * Emits two {TransferSingle} events via ERC1155 library.
     *
     * Requirements:
     * - `legalContr` must not have been used for another token ID.
     *
     * @param assetOwner - Asset Owner wallet address
     * @param maxAmt - Max number of tokens for unique token ID
     * @param fee - platform fee that will be deducted upon withdrawing the sale proceedings
     * @param rate - the rate for the a single token sale
     * @param valueRpt - File Hash of Valuation Report
     * @param legalContr - File Hash of Legal Contract
     */
    function newAsset(address assetOwner, uint256 maxAmt, uint256 fee, uint256 rate, string memory valueRpt, string memory legalContr) external onlyAdmin whenNotPaused {
        require(_legalContracts[legalContr] == 0, "This asset has already been tokenized.");
        require(maxAmt <= MAX_TOKENS_ASSET,"Exceeding limit of tokens per asset");

        incrementTokenId();
        
        uint256 newTokenId = _tokenID;

        emit AssetAddedd(newTokenId, maxAmt, assetOwner, fee, rate, valueRpt, legalContr);

        // Creates and updates REToken Struct of unique token ID with token details
        REToken storage token = reToken[_tokenID];
        token.maxSupply = maxAmt;
        token.owner = assetOwner;
        token.valuationReport = valueRpt;
        token.legalContract = legalContr;
        token.fee = fee;
        token.rate = rate;

        _legalContracts[legalContr] = _tokenID;
    }

    function updateAssetRate(uint256 id, uint256 rate) external onlyAdmin {
        require(_tokenID >= id, "Token ID doesn't exist.");

        reToken[id].rate = rate;
    }

    function updateAssetLegalContractHash(uint256 id, string memory legalContr) external onlyAdmin {
        require(_tokenID >= id, "Token ID doesn't exist.");

        reToken[id].legalContract = legalContr;
    }

    function updateAssetValuationReportHash(uint256 id, string memory valueRpt) external onlyAdmin {
        require(_tokenID >= id, "Token ID doesn't exist.");

        reToken[id].valuationReport = valueRpt;
    }

    /**
    * @dev withdraws the contract balance and send it to the withdraw Addresses based on split ratio.
    *
    * Emits a {ContractWithdraw} event.
    */
    // Add param to specify the address of the platform that we want to withdraw to
    function withdraw(uint256 id) external nonReentrant onlyAdmin {
        uint256 balance = address(this).balance;
        REToken storage token = reToken[id];
        uint256 totalFund = (token.rate * token.maxSupply);
        require(balance >= totalFund,"Not enough balance");
        uint256 platformShare = totalFund*token.fee/1000;
        uint256 ownerShare = totalFund - platformShare;

        (bool sentPlatform, ) = payable(platform_address).call{value: platformShare}('');
        (bool sentOwner, ) = payable(token.owner).call{value: ownerShare}('');

        require(sentPlatform && sentOwner, 'Withdraw Failed.');

        emit ContractWithdraw(platform_address, token.owner, totalFund);
    }

    
    /**
     * @dev Withdraws any ERC20 from Contract
     *
     * Can only be called by the current admin.
     * 
     * Emits a {TokenWithdrawn} event.
     *
     * @param _contract - token contact address to withdraw
     * @param _recipient - Wallet address to withdraw token to
     * @param _amount - Amount of ERC20 token to withdraw
     */
    function withdrawToken(address _contract, address _recipient, uint256 _amount) external nonReentrant onlyAdmin {
         IERC20 tokenContract = IERC20(_contract);
        // transfer the token from address of Catbotica address
        uint256 balance = tokenContract.balanceOf(address(this));
        require(balance >= _amount, "Amount of token withdrawn exceed balance.");
        
        emit TokenWithdrawn(msg.sender, _recipient, _amount);
        
        tokenContract.transfer(_recipient, _amount);
    }

    /**
     * @dev mints `tokenAmt` tokens of token type `id` to `investor` by calling ERC1155 mint function.
     * 
     * Requirements:
     * - `id` must be equal or less than current Token ID (exisiting token).
     * - `tokenAmt` * tokenRate must be equal or more than ETH paid.
     * - msg sender should be a registered investor
     * - `tokenAmt` + the current supply of the token doesn't exceed the max supply of the token
     *
     * Emits a {SingleTransfer} event via ERC1155 library.
     * Emits a {TokenPurchase} for the investor address, the token id purchased, and the token amount purchased.
     *
     * @param id - Token ID
     * @param tokenAmt - Number of tokens to purchase
     */
    function buyToken(uint256 id, uint256 tokenAmt) external payable whenNotPaused {
        require(controllerContract.isApprovedInvestor(msg.sender), "Access Denied: Caller is not approved");
        require(_tokenID >= id, "Token ID doesn't exist.");
        REToken memory token = reToken[id];

        require((totalSupply(id) + tokenAmt) <= token.maxSupply, "Number of tokens requested exceed tokens available.");
        
        uint256 rate = token.rate;

        require(msg.value >= tokenAmt*rate, "Insufficient ETH");

        _mint(msg.sender, id, tokenAmt, "");

        emit TokenPurchase(msg.sender, id, tokenAmt);
    }

    /**
     * @dev Function to allow receiving ETH sent to contract
     *
     */
    receive() external payable {}
    
}