// SPDX-License-Identifier: MIT

pragma solidity  ^0.8.9;
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract TokenStorage is ERC1155Supply, ERC1155Holder, AccessControl {

    /**
     * @dev Declaration of initial variables.
     * 1. `MODERATOR` - Group of addresses possessing moderator authorization for AccessControl contract
     * 2. `ADMIN_ROLE` - Group of addresses possessing admin authorization
     * 3. `_legalContracts` - Mapping of Token ID to Legal Contract File Hash
     */
    bytes32 public constant MODERATOR = keccak256("MODERATOR");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    
    mapping (string => uint256) _legalContracts;

    /**
     * @dev Declaration of `_tokenID` variable as unique Token ID using Counters library
     */
    using Counters for Counters.Counter;
    Counters.Counter internal _tokenIds;
    uint256 public _tokenID = _tokenIds.current();

    /**
     * @dev Declaring `REToken` struct to store token details and
     * mapping of Token ID to REToken Struct
     */
    struct REToken {
        uint256 maxSupply;
        address owner;
        string valuationReport;
        string legalContract;
        uint256 fee;
        uint256 rate;
    }
    mapping (uint256 => REToken) reToken;

     /**
     * @dev Declaration of new Event to record created token details for new asset
     *
     * @param id - Unique token ID
     * @param maxSupply - Number of tokens for unique token ID
     * @param owner - Asset Owner wallet address
     * @param valuationReport - File Hash of Valuation Report
     * @param legalContract - File Hash of Legal Contract
     */
    event AssetAddedd(uint256 indexed id, uint256 indexed maxSupply, address indexed owner, uint256 fee, uint256 rate, string valuationReport, string legalContract);

     /**
     * @dev Declaration of new Event to record created token details for REToken
     *
     * @param initiator - Wallet Address that invoked the withdrawal process
     * @param recipient - Wallet address which received the USDT
     * @param amount - Total amount of USDT withdrawn
     */
    event TokenWithdrawn(address initiator, address recipient, uint256 amount);

    event ContractWithdraw(address indexed platform, address indexed owner, uint256 amount);


    constructor(string memory uri_) ERC1155(uri_) { 
    }

    function incrementTokenId() internal {
        _tokenIds.increment();
        _tokenID = _tokenIds.current();
    }

     function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, ERC1155Receiver, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

}