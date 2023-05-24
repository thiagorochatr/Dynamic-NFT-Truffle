// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";

contract dNFTS is
    ERC721,
    Ownable,
    AutomationCompatibleInterface
{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    uint256 public interval;
    bool public isOn;

    enum TimeType {
        number1,
        number2,
        number3
    }

    struct DayAttribute {
        TimeType timeType;
        uint256 lastChange;
    }

    string private constant number1 =
        "QmUsGbDcKRMwnspBtehy2Y92ac2FeiTCw4bFVNFLsFWgrd";
    string private constant number2 =
        "QmZYNYCeZSB2Jh8wDaJyn9ucWYw34k1TSXcYeRmzoUZwgY";
    string private constant number3 =
        "QmV8toy6zN73tXjCce4XyCoYK2vGGtGwVJFmT277wnHkCS";

    mapping(uint256 => DayAttribute) dayAttributes;
    uint256[] listTokens;

    constructor() ERC721("dNFTS", "NFT") {
        //Start Counter by 1
        _tokenIdCounter.increment();

        interval = 2 minutes;
        isOn = true;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://gateway.pinata.cloud/ipfs/";
    }

    function safeMint(address to) external onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        listTokens.push(tokenId);
        dayAttributes[tokenId] = DayAttribute(TimeType.number1, block.timestamp);
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        _requireMinted(_tokenId);
        string memory base = _baseURI();

        if (dayAttributes[_tokenId].timeType == TimeType.number1) {
            return string(abi.encodePacked(base, number1));
        } else if (dayAttributes[_tokenId].timeType == TimeType.number2) {
            return string(abi.encodePacked(base, number2));
        } else {
            return string(abi.encodePacked(base, number3));
        }
    }

    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        override
        returns (
            bool upkeepNeeded,
            bytes memory performData
        )
    {
        if (!isOn) {
            return (false, "");
        }
        for (uint256 i = 0; i < listTokens.length; i++) {
            uint256 tokenId = listTokens[i];
            if((block.timestamp - dayAttributes[tokenId].lastChange) > interval) {
                return (true, "");
            }
        }
        return (false, "");
    }

    function performUpkeep(
        bytes calldata /* performData */
    ) external override {
        if (isOn) {
            for (uint256 i = 0; i < listTokens.length; i++) {
                uint256 tokenId = listTokens[i];
                if (
                    (block.timestamp - dayAttributes[tokenId].lastChange) >
                    interval
                ) {
                    updateToken(tokenId);
                }
            }
        }
    }

    function setVariables(uint256 _interval, bool _status) external onlyOwner {
        interval = _interval;
        isOn = _status;
    }

    function updateToken(uint256 tokenId) private {
        if (dayAttributes[tokenId].timeType == TimeType.number3) {
            dayAttributes[tokenId].timeType = TimeType.number1;
        } else {
            dayAttributes[tokenId].timeType = TimeType(uint8(dayAttributes[tokenId].timeType) + uint8(1));
        }
        dayAttributes[tokenId].lastChange = block.timestamp;
    }
}