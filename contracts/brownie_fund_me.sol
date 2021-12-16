//SPDX-License-Identifier:MIT

pragma solidity ^0.6.0;

//import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainLink.sol";

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

contract FundME {
    mapping(address => uint256) public AddresstoAmountFunded;
    address public owner;
    address[] public funders;
    AggregatorV3Interface PriceFeed;

    constructor(address _priceFeed) public {
        PriceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    function fund() public payable {
        uint256 minimalUsd = 50 * 10**18;
        require(
            getConversionRate(msg.value) >= minimalUsd,
            "You need to spend more ETH!"
        );
        AddresstoAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        return PriceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        (, int256 answer, , , ) = PriceFeed.latestRoundData();
        return uint256(answer * 10**10);
        //4,581.97256699
    }

    function getConversionRate(uint256 etherAmount)
        public
        view
        returns (uint256)
    {
        uint256 etherprice = getPrice();
        uint256 etherAmountInUsd = etherprice * etherAmount;
        return etherAmountInUsd;
    }

    function getEntranceFee() public view returns (uint256) {
        uint256 minimumlUsd = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return ((minimumlUsd * precision) / price);
    }

    modifier OnlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function withdraw() public payable OnlyOwner {
        payable(msg.sender).transfer(address(this).balance);
        for (uint256 i = 0; i < funders.length; i++) {
            address funder = funders[i];
            AddresstoAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }
}
