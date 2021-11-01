// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

abstract contract MasterSaleStorageV1 {
    address public NFT;        // nft contract
    address public UNDERLYING; // underlying,is erc20 contract
    uint256 public PRICE;      // price by UNDERLYING
    uint256 public BEGINSALETIME = 1630425600; // 2021.10.04 00:00:00

    uint256 remain;        // to sale number
    uint256[] public items;       // to sale itmes
    mapping(uint256 => uint256)public itemIndex;  // item index
    mapping(uint256 => uint256)public sold;       // sold tokenId->timestamp
    mapping(address => uint256)public buyer;      // buyer who bought
    uint256 public maxSell; // current to sale
}

contract MasterSale is MasterSaleStorageV1,Initializable,ReentrancyGuardUpgradeable,OwnableUpgradeable,PausableUpgradeable{
    using SafeMath for uint;

    event ItemSold(address indexed who,uint256 tokenId,uint256 value); // event item sold

    function initialize(address _nft, address _underlying,uint256 _price)public initializer{
        __Context_init_unchained();
        __Ownable_init_unchained();
        __Pausable_init_unchained();
        __ReentrancyGuard_init_unchained();
        NFT = _nft;
        UNDERLYING = _underlying;
        PRICE = _price;

        for(uint256 i=1;i<=88;i++){
            items.push(i);
            itemIndex[i] = i;
            remain = remain.add(1);
        }
    }

    function setPrice(uint256 _price) public onlyOwner{
        PRICE = _price;
    }

    function setBeingSaleTime(uint256 _time) public onlyOwner{
        BEGINSALETIME = _time;
    }

    function setMaxSell(uint256 _maxSell) public onlyOwner{
        require(_maxSell <= remain,"maxSell must gt remain");
        maxSell = _maxSell;
    }

    function rand(uint256 _length) private view returns(uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp,msg.sender)));
        return random%_length;
    }

    // sold out
    function _removeItem(uint256 tokenId)internal{
        require(tokenId >0,"wrong tokenId");
        require(itemIndex[tokenId] > 0,"item not found");

        uint256 index = itemIndex[tokenId];
        if(remain == index){
            delete(items[index-1]);
            itemIndex[tokenId] = 0;
        }else{
            items[index-1] = items[remain-1];
            delete(items[remain-1]);
            itemIndex[tokenId] = 0;
            itemIndex[items[index-1]]=index;
        }
        remain = remain.sub(1);
    }

    function buy() public whenNotPaused returns(uint256){
        require(maxSell > 0,"item sold out");
        require(buyer[msg.sender] == 0,"forbidden:repeat buy");
        uint256 tokenId = items[rand(remain)];
        require(tokenId>0 && sold[tokenId]==0,"forbidden");

        SafeERC20.safeTransferFrom(IERC20(UNDERLYING),msg.sender,address(this),PRICE);
        string memory uri = strConcat(strConcat("https://storage.singularity.gold/medal/master/",Strings.toString(tokenId)),"/metadata.json");
        IMasterNFT(NFT).mint(msg.sender,tokenId,uri);
        sold[tokenId] = block.timestamp;
        buyer[msg.sender] = tokenId;
        maxSell = maxSell.sub(1);

        _removeItem(tokenId);
        emit ItemSold(msg.sender,tokenId,PRICE);

        return tokenId;
    }

    function withdrawToken(address _token,address _to,uint _amount)external nonReentrant onlyOwner{
        require(_to!=address(0),"withdrawToken address forbidden");
        SafeERC20.safeTransfer(IERC20(_token),_to,_amount);
    }

    function withdrawNFT(address _to,uint256 tokenId)external nonReentrant onlyOwner{
        require(_to!=address(0),"withdrawNFT address forbidden");
        IERC721(NFT).safeTransferFrom(address(this),_to,tokenId);
    }

    function pause()public onlyOwner{
        _pause();
    }

    function unpause()public onlyOwner{
        _unpause();
    }

    function strConcat(string memory _a, string memory _b) internal pure returns (string memory){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        string memory ret = new string(_ba.length + _bb.length);
        bytes memory bret = bytes(ret);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++)bret[k++] = _ba[i];
        for (uint i = 0; i < _bb.length; i++) bret[k++] = _bb[i];
        return string(ret);
    }
}

interface IMasterNFT{
    function mint(address receiver, uint256 tokenId,string memory _tokenURI) external ;
}