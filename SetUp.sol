// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {NextGenMinterContract} from "../smart-contracts/MinterContract.sol";
import {NextGenCore, ERC721} from "../smart-contracts/NextGenCore.sol";
import {NextGenRandomizerNXT} from "../smart-contracts/RandomizerNXT.sol";
import {NextGenAdmins} from "../smart-contracts/NextGenAdmins.sol";
import {DelegationManagementContract} from "../smart-contracts/NFTdelegation.sol";
import {randomPool} from "../smart-contracts/XRandoms.sol";
import {AttackerContract} from "./AttackerContract.sol";

contract SetUp is Test {
    NextGenMinterContract _NextGenMinterContract;
    NextGenCore _NextGenCore;
    NextGenRandomizerNXT _NextGenRandomizerNXT;
    NextGenAdmins _NextGenAdmins;
    DelegationManagementContract _DelegationManagementContract;
    randomPool _randomPool;
    ERC721 public dummyNft;
    AttackerContract _AttackerContract;

    address public adminCollection1 = address(3);
    address public adminCollection2 = address(4);
    address public adminCollection3 = address(7);
    address public delegateAddress = 0xD7ACd2a9FD159E69Bb102A1ca21C9a3e3A5F771B;

    address public user1 = address(5);
    address public user2 = address(6);

    function setUp() public {
        _DelegationManagementContract = new DelegationManagementContract();
        _randomPool = new randomPool();
        _NextGenAdmins = new NextGenAdmins();
        _NextGenCore = new NextGenCore("Next Gen Core","NEXTGEN",address(_NextGenAdmins));
        _NextGenRandomizerNXT =
            new NextGenRandomizerNXT(address(_randomPool),address(_NextGenAdmins),address(_NextGenCore));
        _NextGenMinterContract =
        new NextGenMinterContract(address(_NextGenCore),address(_DelegationManagementContract),address(_NextGenAdmins));
        dummyNft = new ERC721("Dummy","D");
        _AttackerContract = new AttackerContract(_NextGenMinterContract);
    }

    //////////////////////////////////////////////////////////
    ////////////CREATING  AND SETTING COLLECTIONS ////////////
    //////////////////////////////////////////////////////////

    function test_createCollectionAndSetData() public {
        string[] memory desc = new string[](1);
        desc[0] = "desc";
        //create first collection
        _NextGenCore.createCollection(
            "Test Collection 1",
            "Artist 1",
            "For testing",
            "www.test.com",
            "CCO",
            "https://ipfs.io/ipfs/hash/",
            "",
            desc
        );

        //create second collection
        _NextGenCore.createCollection(
            "Test Collection 2",
            "Artist 2",
            "For testing",
            "www.test.com",
            "CCO",
            "https://ipfs.io/ipfs/hash/",
            "",
            desc
        );

        _NextGenCore.createCollection(
            "Test Collection 3",
            "Artist 3",
            "For testing",
            "www.test.com",
            "CCO",
            "https://ipfs.io/ipfs/hash/",
            "",
            desc
        );

        //add admins to the collection
        _NextGenAdmins.registerCollectionAdmin(1, adminCollection1, true);
        _NextGenAdmins.registerCollectionAdmin(2, adminCollection2, true);
        _NextGenAdmins.registerCollectionAdmin(3, adminCollection3, true);

        //set collection data
        _NextGenCore.setCollectionData(1, adminCollection1, 3, 100, 200);
        _NextGenCore.setCollectionData(2, adminCollection2, 4, 300, 200);
        _NextGenCore.setCollectionData(3, adminCollection3, 30, 100, 200);

        //set minting contract
        _NextGenCore.addMinterContract(address(_NextGenMinterContract));

        //set ramdomizer in both coollection
        _NextGenCore.addRandomizer(1, address(_NextGenRandomizerNXT));
        _NextGenCore.addRandomizer(2, address(_NextGenRandomizerNXT));
        _NextGenCore.addRandomizer(3, address(_NextGenRandomizerNXT));

        // set the collection cost in the minter contract
        _NextGenMinterContract.setCollectionCosts(
            1, //collection id
            1 ether, // _collectionMintCost
            0, // _collectionEndMintCost
            0, // _rate
            0, // _timePeriod
            1, // _salesOptions
            delegateAddress
        );

        _NextGenMinterContract.setCollectionCosts(
            2, //collection id
            1 ether, // _collectionMintCost
            10e17, // _collectionEndMintCost
            10e17, // _rate
            200, // _timePeriod
            2, // _salesOptions
            delegateAddress
        );

        _NextGenMinterContract.setCollectionCosts(
            3, //collection id
            1 ether, // _collectionMintCost
            10e17, // _collectionEndMintCost
            10e6, // _rate
            20, // _timePeriod
            3, // _salesOptions
            delegateAddress
        );

        //set collection phases
        _NextGenMinterContract.setCollectionPhases(
            1, // _collectionID
            0, // _allowlistStartTime
            0, // _allowlistEndTime
            block.timestamp, // _publicStartTime
            block.timestamp + 10 days, // _publicEndTime
            0x8e3c1713145650ce646f7eccd42c4541ecee8f07040fc1ac36fe071bbfebb870 // _merkleRoot
        );

        _NextGenMinterContract.setCollectionPhases(
            2, // _collectionID
            block.timestamp, // _allowlistStartTime
            0, // _allowlistEndTime
            block.timestamp, // _publicStartTime
            block.timestamp + 10 days, // _publicEndTime
            0x8e3c1713145650ce646f7eccd42c4541ecee8f07040fc1ac36fe071bbfebb870 // _merkleRoot
        );

        _NextGenMinterContract.setCollectionPhases(
            3, // _collectionID
            block.timestamp + 1 days, // _allowlistStartTime
            block.timestamp + 1 days, // _allowlistEndTime
            block.timestamp + 1 days, // _publicStartTime
            block.timestamp + 10 days, // _publicEndTime
            0x8e3c1713145650ce646f7eccd42c4541ecee8f07040fc1ac36fe071bbfebb870 // _merkleRoot
        );
    }

    function test_setBurnOrSwapCollection() public {
        test_createCollectionAndSetData();
        _NextGenMinterContract.initializeExternalBurnOrSwap(address(dummyNft), 0, 1, 0, 100, address(0), true);
    }

    function test_setBurnToMintCollection() public {
        test_createCollectionAndSetData();
        _NextGenMinterContract.initializeBurn(1, 3, true);
    }
}
