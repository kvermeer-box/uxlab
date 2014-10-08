global class AccountTeamUpdate implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {
  

	public static final String USER_PROFILE_ID_SALES 		= '00e60000000idJI';	// 'Box: Sales' 
	public static final String USER_PROFILE_ID_SALES_EMEA 	= '00e60000000iqCA';	// 'Box: Sales (EMEA)' 
	
	public static final String ACCOUNT_TEAM_ROLE_INSIDE_REP 	= 'Inside Rep';
	public static final String ACCOUNT_TEAM_ROLE_OUTBOUND_REP	= 'Outbound Rep';

	public static final String ROW_CAUSE_TEAM = 'Team';

	public static final Integer NORMALIZED_EMPLOYEES_150 = 150;
	public static final String THEATER_NATAM = 'NATAM';
	public static final String SALES_DIVISION_CORPORATE = 'Corporate';
	
 

  	public String query;
        
  	global AccountTeamUpdate() { 
  	
  		/* Select a.Owner.ProfileId, a.Owner.IsActive, a.Owner.Id, a.OwnerId, a.Id From Account a */
  	
  		// get a list of accounts to process
  		// user must be active and be one of the applicable profiles
  		
		if (Test.isRunningTest()) {
	    	query = 'Select a.Owner.ProfileId, a.Owner.IsActive, a.Owner.Id, a.OwnerId, a.Id ' +
	    				' From Account a LIMIT 10';
		}else{
			query = 'Select a.Owner.ProfileId, a.Owner.IsActive, a.Owner.Id, a.OwnerId, a.Id From Account a ' + 
						'Where a.Owner.IsActive = True ' + 
							'and  (a.Owner.ProfileId = \'' + USER_PROFILE_ID_SALES + '\' ' +
										'or  a.Owner.ProfileId = \'' + USER_PROFILE_ID_SALES_EMEA + '\') ' +
							'order by a.Owner.Id';
		}
	
  	}
  
  	global Database.QueryLocator start(Database.BatchableContext BC) {
    	return Database.getQueryLocator(query);
  	}

  	global void execute(Database.BatchableContext BC, List<sObject> scope) {
  	
    	List<Id> accountIds = new List<Id>();
    	List<Id> userIds = new List<Id>();
    	
    	 
    	Account processAccount; 
    	
    	for (sObject currentAccount : scope) {
    	
    		processAccount = (Account)currentAccount;
    		
    		accountIds.add(processAccount.Id);
    		userIds.add(processAccount.OwnerId);
    		
    	}//end-for
      
    	if(accountIds.size()>0){
    		updateAccountTeamMembers(userIds, accountIds);
    		updateAccountShares(userIds, accountIds);
    	}
    	
  	}
  
  	global void finish(Database.BatchableContext BC) {
    	// Nothing to do right now
  	}

  	// SCHEDULABLE

  	global void execute(SchedulableContext sc) {
    	AccountTeamUpdate batchClass = new AccountTeamUpdate();
    	Database.executeBatch(batchClass);
  	}
  	
  	public static void updateAccountTeamMembers(List<Id> ownerIds, List<Id> accountIds){
  	
  		// for user, get account team members
  		// get all accounts and account team members owned by user
 
 
 		Map<Id, Account> accountMap = new Map<Id, Account>();
  		Map<Id, List<UserAccountTeamMember>> userAccountTeamMemberListMap=getUserAccountTeamMemberListMap(ownerIds); 
  		
  		Map<Id, List<AccountTeamMember>> accountTeamMemberListMap = new Map<Id, List<AccountTeamMember>>();	
  			
  		List<AccountTeamMember> deleteAccountTeamMemberList = new List<AccountTeamMember>();
  		List<AccountTeamMember> upsertAccountTeamMemberList = new List<AccountTeamMember>();

		List<UserAccountTeamMember> userAccountTeamMemberList;
		List<AccountTeamMember> accountTeamMemberList;

		for(AccountTeamMember member : [Select a.UserId, a.TeamMemberRole, a.Id, a.AccountId, a.AccountAccessLevel 
											From AccountTeamMember a
												Where AccountId in:accountIds]){
													
 			if(accountTeamMemberListMap.containsKey(member.AccountId)){

 				accountTeamMemberList = accountTeamMemberListMap.get(member.AccountId);	
 			
 			}else{
 				
 				accountTeamMemberList = new List<AccountTeamMember>();

 			}
 			
 			accountTeamMemberList.add(member);
 			accountTeamMemberListMap.put(member.AccountId, accountTeamMemberList);
 												
		}//end-for	

		for(Account acct : [Select a.Owner.ProfileId, a.Owner.IsActive, a.Owner.Id, a.OwnerId, a.Id, 
									a.Normalized_Employees__c, a.Theater__c, a.Sales_Division__c 
										From Account a
											Where Id in: accountIds]){
		
			accountMap.put(acct.Id, acct);
											
		}//end-for	

 		Id ownerId; 
 		AccountTeamMember selectedAccountTeamMember;
 		Account selectedAccount;
 		
 		
 		for(Id accountId : accountIds){
 		
 			 // get account owner
 			 // get account team for account owner
 			 // update account team members : delete or add or update
 			 
 			 ownerId = accountMap.get(accountId).OwnerId;
 			 userAccountTeamMemberList = userAccountTeamMemberListMap.get(ownerId);
 			 accountTeamMemberList = accountTeamMemberListMap.get(accountId);
 			 selectedAccount = accountMap.get(accountId);
 			 
 			 System.debug('>>>>> accountId='+accountId+'<<<<<<<<<');
 			 
 			 // for certain accounts, delete Inside Rep and Outbound rep
 			 // loop through all team members for the account and delete inapppropriate ones
 			 
 			 if(selectedAccount!=null 
 			 		&& selectedAccount.Normalized_Employees__c < NORMALIZED_EMPLOYEES_150
 			 		&& selectedAccount.Theater__c == THEATER_NATAM 
 			 		&& selectedAccount.Sales_Division__c == SALES_DIVISION_CORPORATE){
 			 	
 			 	
 			 	if(accountTeamMemberList!=null){
 			 			
					for(AccountTeamMember currentAccountTeamMember : accountTeamMemberList){
	 	
		 			 	if(currentAccountTeamMember.TeamMemberRole == ACCOUNT_TEAM_ROLE_INSIDE_REP
		 			 		|| currentAccountTeamMember.TeamMemberRole == ACCOUNT_TEAM_ROLE_OUTBOUND_REP){
		 			 
		 			 		deleteAccountTeamMemberList.add(currentAccountTeamMember);	
	 			 		}
		 			 	
		 			}//end-for
 			 	}
	 			 
	 			continue; // go to next account
	 			 
			}//end-if
 			 
 			 
 			 // user (AE) has no account team members, go to next account
 			 if(userAccountTeamMemberList==null || userAccountTeamMemberList.size()==0){
 			 	System.debug('>>>>> user has no account team members');
 			 	continue; // go to next account
 			 }
 			 
 			 System.debug('>>>>> userAccountTeamMemberList='+userAccountTeamMemberList);
 			 System.debug('>>>>> accountTeamMemberList='+accountTeamMemberList);
 			 
 			 // loop through all team members for the AE
 			 for (UserAccountTeamMember currentUserAccountTeamMember  : userAccountTeamMemberList){
 			 
 			 	System.debug('>>>>> currentUserAccountTeamMember='+currentUserAccountTeamMember);
 			 	
 			 	selectedAccountTeamMember=null;
 			 	
 			 	// account has no account team members 
				if(accountTeamMemberList==null || accountTeamMemberList.size()==0){
 			 		
 			 		System.debug('>>>>> account has no account team members');
 			 		
 			 		// add new account team member
 			 		selectedAccountTeamMember = createAccountTeamMember(accountId, currentUserAccountTeamMember);
 			 		upsertAccountTeamMemberList.add(selectedAccountTeamMember);
 			 		
 			 		continue;
 			 	}
 			 	
 			 	// account has account team members
 			 	// update account team members as needed
 			 	
 			 	for(AccountTeamMember currentAccountTeamMember : accountTeamMemberList){
 			 	
 			 		// find same role on account team
 			 		
 			 		if(currentUserAccountTeamMember.TeamMemberRole == currentAccountTeamMember.TeamMemberRole){
 			 			// found user in the same role
 			 			// check user id
 			 			
 			 			System.debug('>>>>> found team member with same role: currentUserAccountTeamMember.TeamMemberRole='+currentUserAccountTeamMember.TeamMemberRole);
 			 			
 			 			if (currentUserAccountTeamMember.UserId == currentAccountTeamMember.UserId){
 			 				// same user id and same team member role
 			 				
 			 				System.debug('>>>>> same user and same role. do nothing');
 			 				
 			 				selectedAccountTeamMember = currentAccountTeamMember;

 			 				
 			 			}else{
 			 				// different user id in the same team role
 			 				// existing team member should be deleted
 			 				deleteAccountTeamMemberList.add(currentAccountTeamMember);	
 			 				
 			 				System.debug('>>>>> delete existing team member.');
 			 				
 			 				// add new account team member
		 					//selectedAccountTeamMember = createAccountTeamMember(accountId, currentUserAccountTeamMember);
		 			 		//upsertAccountTeamMemberList.add(selectedAccountTeamMember);
		 			 		//break;
 			 			}	
 			 			
 			 		}//end-IF
 			 			

 			 	}	//end-for

	 			 // check whether role was found
	 			 if(selectedAccountTeamMember==null){
	 			 		
	 			 	System.debug('>>>>> create new team member');
	 			 		
	 			 	// add new account team member
			 		selectedAccountTeamMember = createAccountTeamMember(accountId, currentUserAccountTeamMember);
			 		upsertAccountTeamMemberList.add(selectedAccountTeamMember);
 			 	}

 			 	
 			 }//end-for

 		}//end-for 	
 		
 		System.debug('>>>>>deleteAccountTeamMemberList='+deleteAccountTeamMemberList);
 		
 		try{
 		
 			if(deleteAccountTeamMemberList.size()>0){
 				delete deleteAccountTeamMemberList;
 			}
 			
 		}catch(Exception e){
 			
			DebugLogger.write('AccountTeamUpdate.updateAccountTeamMembers deleteAccountTeamMemberList', 'e = ' + e); 
			DebugLogger.write('AccountTeamUpdate.updateAccountTeamMembers', 'deleteAccountTeamMemberList = ' + deleteAccountTeamMemberList);  
 		}	
 		
		System.debug('>>>>>upsertAccountTeamMemberList='+upsertAccountTeamMemberList);
		
		try{
 			if(upsertAccountTeamMemberList.size()>0){
 				upsert upsertAccountTeamMemberList;
 			}
		}catch(Exception e){
			
			DebugLogger.write('AccountTeamUpdate.updateAccountTeamMembers upsertAccountTeamMemberList', 'e = ' + e);  
			DebugLogger.write('AccountTeamUpdate.updateAccountTeamMembers', 'upsertAccountTeamMemberList = ' + upsertAccountTeamMemberList);  
			
		}

  	}

  	public static AccountTeamMember createAccountTeamMember(Id accountId, UserAccountTeamMember fromUserAccountTeamMember){
  	
  		AccountTeamMember newAccountTeamMember = new AccountTeamMember();	
		newAccountTeamMember.AccountId = accountId;
		newAccountTeamMember.UserId = fromUserAccountTeamMember.UserId;
		newAccountTeamMember.TeamMemberRole = fromUserAccountTeamMember.TeamMemberRole;
  	
  		return newAccountTeamMember;
  	}
    
  	public static Map<Id, List<UserAccountTeamMember>> getUserAccountTeamMemberListMap(List<Id> ownerIds){
  	
		Map<Id, List<UserAccountTeamMember>> userAccountTeamMemberListMap = new Map<Id, List<UserAccountTeamMember>>();   	
		List<UserAccountTeamMember> userAccountTeamMemberList; 
				
		for(UserAccountTeamMember member : [Select u.UserId, u.TeamMemberRole, u.OwnerId, u.Id, u.ContactAccessLevel, 
								u.CaseAccessLevel, u.AccountAccessLevel, u.OpportunityAccessLevel 
							From UserAccountTeamMember u
								Where OwnerId in: ownerIds
										and (TeamMemberRole =: ACCOUNT_TEAM_ROLE_INSIDE_REP 
												or TeamMemberRole =: ACCOUNT_TEAM_ROLE_OUTBOUND_REP )]){
									
 			if(userAccountTeamMemberListMap.containsKey(member.OwnerId)){

 				userAccountTeamMemberList = userAccountTeamMemberListMap.get(member.OwnerId);	
 			
 			}else{
 				
 				userAccountTeamMemberList = new List<UserAccountTeamMember>();

 			}
 			
 			userAccountTeamMemberList.add(member);
 			userAccountTeamMemberListMap.put(member.OwnerId, userAccountTeamMemberList);
			
		}//end-for
		
		return userAccountTeamMemberListMap;
  	}

  	
  	public static void updateAccountShares(List<Id> ownerIds, List<Id> accountIds){
  	
  		// for user, get account team members
  		// get all accounts and account team members owned by user

 		Map<Id, Account> accountMap = new Map<Id, Account>();
  		Map<Id, List<UserAccountTeamMember>> userAccountTeamMemberListMap=getUserAccountTeamMemberListMap(ownerIds); 

  		List<AccountShare> updateAccountShareList = new List<AccountShare>();

		List<UserAccountTeamMember> userAccountTeamMemberList;
		
		List<AccountShare> accountShareList;
		Map<Id, List<AccountShare>> accountShareListMap = new Map<Id, List<AccountShare>>();
		
		Set<Id> teamMemberUserIds = new Set<Id>();

		for(Account acct : [Select a.Owner.ProfileId, a.Owner.IsActive, a.Owner.Id, a.OwnerId, a.Id 
								From Account a
									Where Id in: accountIds]){
		
			accountMap.put(acct.Id, acct);
											
		}//end-for	
				
		
		for(Id ownerId : ownerIds){
		
			userAccountTeamMemberList=userAccountTeamMemberListMap.get(ownerId);	
			if(userAccountTeamMemberList==null){
				continue;
			}
			for(UserAccountTeamMember member : userAccountTeamMemberList){
				teamMemberUserIds.add(member.userId);	
			}

		}	   
		
		for(AccountShare acctShare : [Select a.UserOrGroupId, a.RowCause, a.Id, a.ContactAccessLevel, a.CaseAccessLevel, 
												a.OpportunityAccessLevel, a.AccountId, a.AccountAccessLevel 
											From AccountShare a
												Where UserOrGroupId in: teamMemberUserIds 
													and AccountId in: accountIds
													and RowCause =: ROW_CAUSE_TEAM]){


			if(accountShareListMap.containsKey(acctShare.AccountId)){

 				accountShareList = accountShareListMap.get(acctShare.AccountId);	
 			
 			}else{
 				
 				accountShareList = new List<AccountShare>();

 			}
 			
 			accountShareList.add(acctShare);
 			accountShareListMap.put(acctShare.AccountId, accountShareList);
	
		}//end-for	
		
		Id ownerId;
 		AccountShare selectedAccountShare;
 		
		// start processing accounts
 		for(Id accountId : accountIds){
 		
 			 // get account owner
 			 // get account team for account owner
 			 // update account team members : delete or add or update
 			 
 			 ownerId = accountMap.get(accountId).OwnerId;
 			 userAccountTeamMemberList = userAccountTeamMemberListMap.get(ownerId);
 			 accountShareList = accountShareListMap.get(accountId);
 			 
 			 // user has no account team members, go to next account
 			 if(userAccountTeamMemberList==null || userAccountTeamMemberList.size()==0){
 			 	System.debug('>>>>>>>user has no account team members');
 			 	continue;
 			 }

			// account has no account share records, go to next account
 			 if(accountShareList==null || accountShareList.size()==0){
 			 	System.debug('>>>>>>>account has no account share records');
 			 	continue;
 			 }

 			 System.debug('>>>>>>>accountShareList='+accountShareList);
 			 System.debug('>>>>>>>userAccountTeamMemberList='+userAccountTeamMemberList);

 			 for (UserAccountTeamMember currentUserAccountTeamMember : userAccountTeamMemberList){
 			 
 			 	selectedAccountShare=null;
 			 	
 			 	for(AccountShare currentAccountShare : accountShareList){
 			 	
 			 		// find same user id 			 		
 			 		if(currentUserAccountTeamMember.UserId == currentAccountShare.UserOrGroupId){
 			 			// found user 
 			 			System.debug('>>>>>User Found currentUserAccountTeamMember.UserId='+currentUserAccountTeamMember.UserId);
 			 			
 			 			System.debug('*** currentUserAccountTeamMember.CaseAccessLevel='+currentUserAccountTeamMember.CaseAccessLevel);
						System.debug('*** currentAccountShare.CaseAccessLevel='+currentAccountShare.CaseAccessLevel);

 			 			System.debug('*** currentUserAccountTeamMember.OpportunityAccessLevel='+currentUserAccountTeamMember.OpportunityAccessLevel);
						System.debug('*** currentAccountShare.OpportunityAccessLevel='+currentAccountShare.OpportunityAccessLevel);
						
 			 			System.debug('*** currentUserAccountTeamMember.AccountAccessLevel='+currentUserAccountTeamMember.AccountAccessLevel);
						System.debug('*** currentAccountShare.AccountAccessLevel='+currentAccountShare.AccountAccessLevel);						
 			 			
 			 			// verify access
 			 			if (currentUserAccountTeamMember.CaseAccessLevel == currentAccountShare.CaseAccessLevel
							&& currentUserAccountTeamMember.OpportunityAccessLevel == currentAccountShare.OpportunityAccessLevel
							&& currentUserAccountTeamMember.AccountAccessLevel == currentAccountShare.AccountAccessLevel){
 			 			
 			 				System.debug('>>>>>Access is SAME <<<<' );
 			 					
						}else{
 			 				
 			 			 
 			 				System.debug('>>>>>Access is different <<<<' );
 			 				
 			 				selectedAccountShare = updateAccountShare(currentAccountShare, currentUserAccountTeamMember); 
 			 				updateAccountShareList.add(selectedAccountShare);
						}
  	
 			 			break;
 			 		}
 			 		
 			 	}	//end-for
 			 	
 			 	
 			 }//end-for

 		}//end-for 	
 		
 		
		System.debug('>>>>>update updateAccountShareList='+updateAccountShareList);
		
		try{
 			if(updateAccountShareList.size()>0){
 				update updateAccountShareList;
 			}
		}catch (Exception e){
			
			DebugLogger.write('AccountTeamUpdate.updateAccountShares', 'e = ' + e);  
			DebugLogger.write('AccountTeamUpdate.updateAccountShares', 'updateAccountShareList = ' + updateAccountShareList);  

		}

   		
  	
  	}    	


  	public static AccountShare updateAccountShare(AccountShare currentAccountShare, UserAccountTeamMember fromUserAccountTeamMember){
  	
		currentAccountShare.CaseAccessLevel = fromUserAccountTeamMember.CaseAccessLevel;
		currentAccountShare.OpportunityAccessLevel = fromUserAccountTeamMember.OpportunityAccessLevel;
		currentAccountShare.AccountAccessLevel = fromUserAccountTeamMember.AccountAccessLevel;

  		System.debug('!!!!! fromUserAccountTeamMember = '+fromUserAccountTeamMember);  	
  		System.debug('!!!!! accountshare updated = '+currentAccountShare);
  		return currentAccountShare;
  	}
  	
}