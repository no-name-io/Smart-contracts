// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC721_1 {
    event Transfer(address indexed from, address indexed to, uint indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns(uint);

    function ownerOf(uint tokenId) external view returns(address);

    // function safeTransferFrom(
    //     address from,
    //     address to,
    //     uint tokenId
    // ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes calldata data
    ) external;

    function transferFrom(
        address from,
        address to,
        uint tokenId
    ) external;

    function approve(
        address to,
        uint tokenId
    ) external;

    function setApprovalForAll(
        address operator,
        bool approved
    ) external;

    function getApproved(
        uint tokenId
    ) external view returns(address);

    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns(bool);


    function addBlockedTokens(address to, uint amount, uint _pool) external;
    function removeBlockedTokens(address to, uint _pool) external;
    function removeBlockedTokens_return(uint _pool) external;

}

interface IERC721_2 {
    event Transfer(address indexed from, address indexed to, uint indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns(uint);

    function ownerOf(uint tokenId) external view returns(address);

    // function safeTransferFrom(
    //     address from,
    //     address to,
    //     uint tokenId
    // ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes calldata data
    ) external;

    function transferFrom(
        address from,
        address to,
        uint tokenId
    ) external;

    function approve(
        address to,
        uint tokenId
    ) external;

    function setApprovalForAll(
        address operator,
        bool approved
    ) external;

    function getApproved(
        uint tokenId
    ) external view returns(address);

    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns(bool);


    function safeMint(address to, uint tokenID) external;

}

interface IERC20 {
    function name() external view returns(string memory);

    function symbol() external view returns(string memory);

    function decimals() external pure returns(uint); // 0

    function totalSupply() external view returns(uint);

    function balanceOf(address account) external view returns(uint);

    function transfer(address to, uint amount) external;

    function allowance(address _owner, address spender) external view returns(uint);

    function approve(address spender, uint amount) external;

    function transferFrom(address sender, address recipient, uint amount) external;

    event Transfer(address indexed from, address indexed to, uint amount);

    event Approve(address indexed owner, address indexed to, uint amount);
}





contract MShop {
    IERC20 public token;
    IERC721_1 public token_nft;
    IERC721_2 public token_nft_2;
    address payable public owner;

    event Sold(uint _amount, address indexed _seller);
    event PoolOver(uint _poolId);

    
    uint public nft_count = 0;  
    //0xa580581985371A34F8C638e4Dd2B6759536a348A
    constructor() {
        token = IERC20(address(0x3355df6D4c9C3035724Fd0e3914dE96A5a83aaf4));
        token_nft = IERC721_1(address(0x9473d96867f06382b35c6e1b787Abf8AC03ffE5F));
        token_nft_2 = IERC721_2(address(0x048CD475dA2A18cFC2f74Ab5a474FF13959970e9));
        owner = payable(msg.sender);
    }



    uint public pool_id = 0;

    struct Partner {
        address user;
        uint investment;
        uint NFT_ID;
        uint NFT_count;
    }

    struct PrePool {
        uint id;
        uint startTime;
        uint greenTime;
        uint yellowTime;
        uint time_range_yellow;  
        address[] users;
        mapping(address => uint) AddressToNFTcount;
        uint greenZone;
        uint yellowZone;
		uint nftStakeNeed; 
    }


    struct Pool {
        uint id;
        mapping(address => Partner) arrayOfPartners;
        mapping(uint => address) IdToAddressPartner;
        address[] media;
        uint mediaComission;
        uint partnersCount;
        uint amountUSDTOfPool;
        uint maxAmountOfPool; 
        bool poolEnd;
		uint maxInvest;
		uint minInvest;
		uint commission;
		uint nftStakeNeed;
    }


    struct EndedPool {
        uint id;
        IERC20 token;
        bool claimstage;
        uint changerate;
        mapping(uint => uint) NFTtoCoins;
        mapping(uint => address) usedNft;
    }
    

    mapping(uint => Pool) public pools;
    mapping(uint => PrePool) public prePools;
    mapping(uint => EndedPool) public endedPools;

    mapping(address => uint) public R_points;
    mapping(address => address) public refFather;

    struct additionalInfo{
        uint poolID;
        uint coins;
        address creator;
    }

    mapping(uint=>additionalInfo) public NFTInfos;  ///tokenId to additionalInfos


    
    function createPrePool(uint _startTime,uint _greenTime,uint _yellowTime,uint _greenZone,uint  _yellowZone,uint _nftStakeNeed) external {
        require(msg.sender == owner, "not an owner!");
        PrePool storage pool = prePools[pool_id];
        pool.id =pool_id;
        pool.startTime = _startTime;
        pool.greenTime = _greenTime;
        pool.yellowTime = _yellowTime;
        pool.time_range_yellow = 14400;  
        //address[] storage new_adr_arr;
        //pool.users = new_adr_arr;
        pool.greenZone = _greenZone;
        pool.yellowZone = _yellowZone;
		pool.nftStakeNeed = _nftStakeNeed; 
        pool_id++;
    }
	

    function createPool(uint _pool_id, uint _max,uint _minInvest,uint _maxInvest,uint _commission,uint _mediaComission, address[] memory _media) external {
        require(msg.sender == owner, "not an owner!");
        Pool storage pool = pools[_pool_id];
        pool.id =_pool_id;
        pool.partnersCount=uint(0);
        pool.amountUSDTOfPool=uint(0);
        pool.maxAmountOfPool=_max;
        pool.poolEnd=false;
		pool.maxInvest = _maxInvest;
		pool.minInvest = _minInvest;
		pool.commission = _commission;
		pool.mediaComission = _mediaComission;		
		pool.media = _media;	
    }
	
    function change_commission(uint _poolId,uint _commission)  external {
        require(msg.sender == owner, "not an owner!");
		Pool storage pool = pools[_poolId];
		pool.commission = _commission;		
    }

    function change_reffather(address user,address father)  external {
        require(msg.sender == owner, "not an owner!");
		refFather[user]=father;		
    }

    function get_user_stacked_NFT_count(uint _poolId, address _adr) public view returns (uint){
		PrePool storage pool = prePools[_poolId];
		uint sum =pool.AddressToNFTcount[_adr];
        return sum;	
    }

     function is_used_var_address(address _user, address[] memory _array_users) public pure returns (bool){
        for (uint i = 0; i < _array_users.length; i++) {
            if (_array_users[i]==_user){
                return true;
            }
        }        
        return false;
    }


    function get_user_board(uint _poolId) public view returns (address[] memory,uint[] memory){
		PrePool storage pool = prePools[_poolId];
        // create address arr -> R_points arr
        uint[] memory R_balance = new uint[](pool.users.length);
        for (uint i = 0; i < pool.users.length; i++) {
            R_balance[i] = pool.AddressToNFTcount[pool.users[i]]*300 + R_points[pool.users[i]];
        }
        address[] memory used_address = new address[](pool.users.length);
        uint count_used_address = 0;

        uint[] memory new_balance = new uint[](pool.users.length);
        address[] memory new_address = new address[](pool.users.length);
        address minimum_adr = pool.users[0];
        uint minimum_sum = R_balance[0];        

        for (uint i = 0; i < pool.users.length; i++) {
            // find new minimum
            for (uint j = 0; j < pool.users.length; j++) {
                if (is_used_var_address(pool.users[j],used_address)==false){
                    minimum_adr = pool.users[j];
                    minimum_sum = R_balance[j]; 
                }
            }
            for (uint j = 0; j < pool.users.length; j++) {
                if (is_used_var_address(pool.users[j],used_address)==false){
                    if (R_balance[j]<minimum_sum){
                    minimum_adr = pool.users[j];
                    minimum_sum = R_balance[j];                         
                    }
                }            
        
            }
            used_address[count_used_address]=minimum_adr;
            new_address[count_used_address]=minimum_adr;
            new_balance[count_used_address]=minimum_sum;
            count_used_address=count_used_address+1;       
        }
        return (new_address,new_balance);
        
    }


    function get_user_place_in_arr(address user, address[] memory _arr) public pure returns (uint){
        for (uint i = 0; i < _arr.length; i++) {
            if (user==_arr[i]){
                return _arr.length-i;
            }
        }
        return 0;

    }


    function get_user_can_invest(uint _poolId, address user) public view returns (bool){
        uint time_inv_start = 0;
        uint time_inv_end = 0;
        (time_inv_start,time_inv_end)=get_user_can_invest_time(_poolId, user);
        uint now_time=block.timestamp;
        if ( now_time>=time_inv_start && now_time<time_inv_end){
            return true;
        }
        return false;
    }


    function get_user_can_invest_time(uint _poolId, address user) public view returns (uint,uint){
		PrePool storage pool = prePools[_poolId];
        uint[] memory new_balance = new uint[](pool.users.length);
        address[] memory new_address = new address[](pool.users.length);        
        (new_address,new_balance)=get_user_board(_poolId); 
        uint place =get_user_place_in_arr(user,new_address);
        if (place ==0){
            return (0,0);
        }
        if (place<=pool.greenZone){
            return (pool.greenTime,pool.yellowTime);
        }
        if (place>pool.greenZone && place<=pool.yellowZone+pool.greenZone){
            uint his_yellow_time_start = pool.yellowTime + ((pool.time_range_yellow)*(place-pool.greenZone))-pool.time_range_yellow; 
            uint his_yellow_time_end = pool.yellowTime + ((pool.time_range_yellow)*(place-pool.greenZone));      
            return (his_yellow_time_start,his_yellow_time_end);
        }
        return (0,0);
    } 

    function get_user_in_zone(uint _poolId, address user) public view returns (uint){
		PrePool storage pool = prePools[_poolId];
        uint[] memory new_balance = new uint[](pool.users.length);
        address[] memory new_address = new address[](pool.users.length);        
        (new_address,new_balance)=get_user_board(_poolId); 
        uint place =get_user_place_in_arr(user,new_address);
        if (place ==0){
            return (0);
        }
        if (place<=pool.greenZone){
            return (1);
        }
        if (place>pool.greenZone && place<=pool.yellowZone+pool.greenZone){  
            return (2);
        }
        return (0);
    } 


    function stackeNFTprePool(uint _poolId, uint _NFTcount) public  {
        PrePool storage pool = prePools[_poolId];
        require( pool.startTime < block.timestamp,"Stack stage not started!");
        require( pool.greenTime > block.timestamp,"Stack stage ended!");
        uint countNFT=token_nft.balanceOf(msg.sender);
		require(countNFT>=_NFTcount,"Wrong amount of NFT!");
		require(pool.nftStakeNeed<=_NFTcount,"Wrong amount of NFT!");	  
        token_nft.removeBlockedTokens(msg.sender, _poolId);           
        token_nft.addBlockedTokens(msg.sender, _NFTcount, _poolId);
        if (is_used_var_address(msg.sender, pool.users)==false){
            pool.users.push(msg.sender);
        }
        pool.AddressToNFTcount[msg.sender] =_NFTcount; 
    }



    function addFundsPool(uint _amount,address _user,uint _poolId) private returns (Partner memory){
        Pool storage pool = pools[_poolId];
        if (pool.arrayOfPartners[_user].investment==uint(0)) {
            pool.IdToAddressPartner[pool.partnersCount]=_user;
            pool.partnersCount+=1;
            nft_count+=1;
            uint NFT_id = nft_count;
            token_nft_2.safeMint(_user,NFT_id);
            pool.arrayOfPartners[_user]=Partner(_user,_amount,NFT_id,0); 
        }
        else {
			require(_amount+pool.arrayOfPartners[_user].investment<pool.maxInvest,"Wrong amount USD!");
            pool.arrayOfPartners[_user].investment += _amount;
        }
        pool.amountUSDTOfPool=pool.amountUSDTOfPool + _amount;

        return pool.arrayOfPartners[_user];
    } 


    function Invest(uint _amountToSell, uint _poolId, address _refFather) external {
        require(
            token_nft.balanceOf(msg.sender) >= 1,
            "Get NFT first!"
        );
        require( msg.sender!=_refFather,"Referal error!");
        if (refFather[msg.sender]==address(0)){
            refFather[msg.sender]=_refFather;
        }
        address true_referal = _refFather;
        if (refFather[msg.sender]!=_refFather){
            true_referal = refFather[msg.sender];
        }
        require( get_user_can_invest(_poolId,msg.sender),"You can`t invest now!");
        Pool storage pool = pools[_poolId];
		uint _amount = _amountToSell;
		uint commission=_amountToSell/100*pool.commission;

        require(
            _amountToSell > 0 &&
            token.balanceOf(msg.sender) >= _amountToSell,
            "incorrect amount!"
        );
        uint _amountAll= _amountToSell + commission;
        uint allowance = token.allowance(msg.sender, address(this));
        require(allowance >= _amountAll, "check allowance!");
        require(pool.poolEnd!=true, "Pool is Ended");          
        require(_amount>0 && pool.maxAmountOfPool-pool.amountUSDTOfPool>=_amount,"Wrong amount!");
		require(_amount>=pool.minInvest && _amount<=pool.maxInvest,"Wrong amount!");		
		if (pool.arrayOfPartners[msg.sender].investment!=uint(0)){
		    require(_amount+pool.arrayOfPartners[msg.sender].investment<=pool.maxInvest,"Wrong amount!");	
		}
        token.transferFrom(msg.sender, address(this), _amountToSell);
        uint ref_father_coms=_amountToSell*150/10000;
        uint rf_media = get_user_place_in_arr(true_referal, pool.media);
        if (rf_media!=0) {
            uint media_coms=_amountToSell*pool.mediaComission/100;
            commission = commission - ref_father_coms - media_coms;
            token.transferFrom(msg.sender, true_referal, media_coms);       
        }
        else{
            commission = commission - ref_father_coms;          
        }
        token.transferFrom(msg.sender, true_referal, ref_father_coms);
        token.transferFrom(msg.sender, owner, commission);
        addFundsPool(_amountToSell,msg.sender,_poolId);
        emit Sold(_amountToSell, msg.sender);
        if (pool.maxAmountOfPool==pool.amountUSDTOfPool) {
            end_pool(_poolId,false);}
    }    

    function getMeInPool(uint _poolId, address user) public view returns (Partner memory){
      return pools[_poolId].arrayOfPartners[user];
    }

    function getInfobyNFT(uint _tokenId) public view returns (uint ,uint, address){
      additionalInfo memory info = NFTInfos[ _tokenId];
      return (info.poolID,
        info.coins,
        info.creator);
    }

    function addAdditionalInfo(uint _tokenID,uint _poolId,uint _coins, address _creator) private {
        additionalInfo storage info = NFTInfos[ _tokenID];
        info.poolID = _poolId;
        info.coins = _coins;
        info.creator = _creator;
    }

    function getAllPartnersFromPool(uint _poolId) public view returns (Partner[] memory){
        Pool storage pool = pools[_poolId];
        address[] memory ret = new address[](pool.partnersCount);
        Partner[] memory ret2 = new Partner[](pool.partnersCount);
        for (uint i = 0; i < pool.partnersCount; i++) {
            ret[i] = pool.IdToAddressPartner[i];
        }
        for (uint i = 0; i < pool.partnersCount; i++) {
            ret2[i] = pool.arrayOfPartners[ret[i]];
        }
        return ret2;
    }


	function end_pool_by_admin(uint _poolId, bool _is_return) external {
        require(msg.sender == owner, "not an owner!");
        end_pool(_poolId, _is_return);
    }
	
	function end_pool(uint _poolId, bool _is_return) private{
		Pool storage pool = pools[_poolId];
        PrePool storage pool_rpe = prePools[_poolId];
        require(pool.poolEnd!=true, "Pool is Ended");    		
		pool.poolEnd=true;
		//token.transferFrom(address(this), msg.sender, pool.amountUSDTOfPool);
        
        Partner[] memory arraypartners = getAllPartnersFromPool(_poolId);
        if  (_is_return){
            token_nft.removeBlockedTokens_return(_poolId); 
            for (uint i = 0; i < pool.partnersCount; i++) {
                //token.transferFrom(address(this), users[i].user, users[i].investment);
                token.transfer( arraypartners[i].user, arraypartners[i].investment);
                R_points[arraypartners[i].user]=R_points[arraypartners[i].user]+5;   
                }	

            }
        else {
            token.transfer( msg.sender, pool.amountUSDTOfPool);
            EndedPool storage poolEnded = endedPools[_poolId];
            poolEnded.claimstage = false;
            poolEnded.id = _poolId;  
            for (uint i = 0; i < arraypartners.length; i++) {
                poolEnded.NFTtoCoins[arraypartners[i].NFT_ID] = arraypartners[i].investment;
                addAdditionalInfo(arraypartners[i].NFT_ID,_poolId,arraypartners[i].investment,arraypartners[i].user);  
                R_points[arraypartners[i].user]=R_points[arraypartners[i].user]+50;
            }


        /////

            for (uint i = 0; i < pool_rpe.users.length; i++) 
            {
                if (getMeInPool(_poolId,pool_rpe.users[i]).user==address(0))
                {
                  if (get_user_in_zone(_poolId,pool_rpe.users[i])!=0){
                     R_points[arraypartners[i].user]=R_points[arraypartners[i].user]+5;                      
                  } 
                  token_nft.removeBlockedTokens(arraypartners[i].user,_poolId); 
                }
            }
        }
		emit PoolOver(_poolId);
    }



    function change_endedPoolToken(address _adr, uint _poolID, uint _changerate)  external {
        require(msg.sender == owner, "not an owner!");
		EndedPool storage pool = endedPools[_poolID];
		pool.token = IERC20(_adr);
        pool.claimstage = true;	
        pool.changerate =  _changerate;
		Partner[] memory users = getAllPartnersFromPool(_poolID);   
        for (uint i = 0; i < users.length; i++) {
            token_nft.removeBlockedTokens(users[i].user,_poolID); 
        }             	
    }

    function Claim(uint _NFT_ID) external {
        uint poolID;
        uint amount;
        address creator;
        (poolID, amount,creator)= getInfobyNFT(_NFT_ID) ;
        EndedPool storage pool = endedPools[poolID];
        require(
        token_nft_2.ownerOf(_NFT_ID)==msg.sender,
            "You must be owner of NFT!"
        );
        require(
            pool.claimstage == true,
            "Claim is not available"
        );
        require(
            pool.usedNft[_NFT_ID] == address(0),
            "NFT already used"
        );
        token_nft_2.transferFrom(msg.sender, address(this), _NFT_ID);

        uint token_amount = amount/1000000*pool.changerate;
        pool.token.transfer(msg.sender, token_amount);
        pool.usedNft[_NFT_ID] = msg.sender;
    } 		

}