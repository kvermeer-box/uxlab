/**  
 * This class contains utility methods and values for one-off methods needed in the Account trigger.
 *
 * @author Kyle Vermeer <kvermeer@box.com>
 * @author Richard Wu <rwu@box.com>
 * @version 1.0
 *
 * @revision 1.0 Kyle Vermeer 2/26/2014 Inital Documentation
 */
public class AccountTriggerHelper {
   
    private static final String SDR_FIELD_NAME = 'SDR_Lookup__c';
    private static final String OBR_FIELD_NAME = 'OBR_Lookup__c';
    private static final String NIR_FIELD_NAME = 'NIR_Lookup__c';
    
	public static string COUNTRY_CANADA = 'Canada';
	public static string COUNTRY_MEXICO = 'Mexico';
	public static string COUNTRY_UNITED_STATES = 'United States';

	public static string ACCOUNT_HIERARCHY_PARENT = 'Parent';
	public static string ACCOUNT_HIERARCHY_HOLDING_COMPANY = 'Holding Company';
	public static string ACCOUNT_HIERARCHY_REFERRAL_RESELLER = 'Referral/Reseller';
	public static string ACCOUNT_HIERARCHY_FEDERAL = 'Federal';
	public static string ACCOUNT_HIERARCHY_SUBSIDIARY = 'Subsidiary';
	public static string ACCOUNT_HIERARCHY_HOLDING_COMPANY_SUBSIDIARY = 'Holding Company Subsidiary';

    public static string RECORD_TYPE_ID_REFERRAL = '012600000009TYZ'; /* Referral */
    public static string RECORD_TYPE_ID_RESELLER = '012600000009Tjh'; /* Reseller */
    public static string RECORD_TYPE_ID_PARTNER_REFERRER_RESELLER = '012600000009X6b'; /* Partner Referrer/Reseller */
    public static string USER_ROLE_ID_INTERNET2_MANAGER = '00E60000001HaBw'; /* Internet2 Manager Role */
    public static string USER_ROLE_ID_INTERNET2_SUBORDINATE = '00E60000001HaC1';   /* Internet2 Subordinate Role */
    public static string USER_ROLE_ID_FEDERAL = '00E60000001HsiU'; /* Federal */	


    public static void beforeInsert(List<Account> accountList) {

		// populate exclude_from_territory_assignment__c field for specific account types  
		initFields(accountList);
		
		// update billing region, subregion, and theater fields
		// these fields for used for territory assignment
        updateFields(accountList);

    }

    public static void afterInsert(List<Account> accountList) {
	
		// assign territory to account
		assignTerritory(accountList);
		
		// nothing to do - new account has no children accounts or opps

    }

    public static void beforeUpdate(List<Account> accountList,
                                    Map<Id,Account> oldAccountMap) {

		// update billing region, subregion, and theater fields
    	updateFields(accountList);  
                               
    }

    public static void afterUpdate(List<Account> accountList,
                                   Map<Id,Account> oldAccountMap) {

		// assign territory to account 
		assignTerritory(accountList);

        /* update opps */
		updateOpportunities(accountList, oldAccountMap);
		
        /* update child accounts */
		updateChildAccounts(accountList, oldAccountMap);
           
    }



    public static void initFields(List<Account> accountList) {

		for(Account acct: accountList){
        	
        	// exclude partner record type from territory assignment
        	if (acct.RecordTypeId == RECORD_TYPE_ID_PARTNER_REFERRER_RESELLER){
        	  	
        		acct.Exclude_From_Territory_Assignment__c = true;	
        	}	

        }//end-for	

    	
    }


	public static void assignTerritory(List<Account> accountList){

		if(!TerritoryAssignment.isEnabled()){
			return;
		}

		if (TerritoryContextControl.preventLooping) {
			return;
		} 
		
		Set<Id> accountIds = new Set<Id>();
		
		for(Account acct : accountList){

			if(acct.Assign_to_Territory__c){				
				accountIds.add(acct.Id);	
			}
		}
  
		if(accountIds.size()>0){
			TerritoryAssignmentUtility.assignAccounts(accountIds);  
		}	 
	}

 	/* find any children acounts and update them */
    public static void updateChildAccounts(List<Account> accountList, Map<Id,Account> oldAccountMap){

		if(!TerritoryAssignment.isEnabled()){
			return;
		}

		Set<Id> accountIds = new Set<Id>();	
		Map<Id, Account> newAccountMap = new Map<Id, Account>();
		List<Account> childrenAccounts = new List <Account>();
		
		Account oldAccount;
		
		for(Account acct : accountList){
			
			newAccountMap.put(acct.Id, acct);
		
			oldAccount=oldAccountMap.get(acct.Id);
			
			if(oldAccount==null){
				continue;
			}
			
			// propagate territory changes
			if(acct.ownerId != oldAccount.ownerId
				|| acct.Territory__c != oldAccount.Territory__c){
			
				accountIds.add(acct.Id);
			
			}
			
		}

        if (accountIds.size() <= 0) {
            System.debug('No accountIds, returning!');
            return;
        }
		
		Account newAccount;
		// get children accounts for changed accounts
		for(Account childAccount : [Select Id, OwnerId, Territory__c, ParentId 
											From Account 
												where ParentId in : accountIds
													and Account_Hierarchy__c =: ACCOUNT_HIERARCHY_SUBSIDIARY
													and Exclude_from_Territory_Assignment__c = false
													and Exclude_from_Territory_Assignment_2__c = false]){
 
    		newAccount = newAccountMap.get(childAccount.ParentId);
    		if(newAccount==null){
    			continue;
    		}		
			if(newAccount.ownerId != childAccount.ownerId
				||  newAccount.territory__c != childAccount.Territory__c){
 
				
				childAccount.ownerId=newAccount.ownerId;
				childAccount.Territory__c=newAccount.Territory__c;
				
				childrenAccounts.add(childAccount);	
		
			}	 
		}//end-for
		
		// update those children accounts		
		if (childrenAccounts.size()>0){
			update childrenAccounts;
		}
		
    }
  
    public static void updateOpportunities(List<Account> accountList, Map<Id,Account> oldAccountMap) {

 
		if(!TerritoryAssignment.isEnabled()){
			return;
		}

		Set<Id> accountIds = new Set<Id>();

		List<Opportunity> updateOpportunityList = new List<Opportunity>();
		
		
		Account oldAccount;
				
		for(Account acct : accountList){
			
			oldAccount=oldAccountMap.get(acct.Id);
			
			if(oldAccount==null){
				continue;
			}
			
			// propagate territory changes if account owner or territory has changed
			if(acct.ownerId != oldAccount.ownerId
				|| acct.Territory__c != oldAccount.Territory__c){
			
				accountIds.add(acct.Id);
			
			}
			
		} 

        if (accountIds.size() <= 0) {
            System.debug('No accountIds, returning!');
            return;
        }
		
		// get all opportunities
		for(Opportunity opp : [Select o.IsClosed, o.Id, o.Exclude_from_Territory_Assignment__c, 
										o.AccountId, o.ownerId  
									From Opportunity o
										Where AccountId in: accountIds
											and o.IsClosed=false 
											and o.Exclude_from_Territory_Assignment__c=false
											and (o.Holdout_Opp_Expiration__c = null or o.Holdout_Opp_Expiration__c <=: system.today()) ]){		
																				
			updateOpportunityList.add(opp);
		
												
		}//end-for
		
		System.debug('>>>>>updateOpportunityList='+updateOpportunityList);
		
		if(updateOpportunityList.size()>0){
			update updateOpportunityList;
		}
    }
 
    
    /* Update Billing Theater, Region, and Subregion */                     
    public static void updateFields(List<Account> accountList) {
 
        Set<Id> accountIds = new Set <Id>();
        Map<Id, Account> accountMap = new Map<Id, Account>();
        
        Set<String> billingCountryNames = new Set<String>();
        Map<String, Billing_Country__c> billingCountryMap = new Map<String, Billing_Country__c>();
        
        // Get all IDs
        for(Account acct: accountList){
        
          	if(acct.Id!=null){
          		accountIds.add(acct.Id);
          	}
          	
          	if(acct.BillingCountry!=null){
          		billingCountryNames.add(acct.BillingCountry);	
          	}

        }
	
		// Get Billing Country records
		if(billingCountryNames.size()>0){
			for(Billing_Country__c country:[Select b.Name, b.Id, b.Billing_Theater__c, 
													b.Billing_Subregion__c, b.Billing_Region__c 
												From Billing_Country__c b
													Where b.Name in: billingCountryNames]){
			
				billingCountryMap.put(country.Name, country);
														
			}//end-for													
		}
 
      	Billing_Country__c countryRecord;
      
        for(Account acct: accountList){
        	
            countryRecord=null;
                         
			acct.Billing_Region__c = null;
            acct.Billing_Subregion__c = null;
            acct.Billing_Theater__c = null;

			// Use the Billing Country field to populate Billing Region, Billing Subregion, and Billing Theater fields 
 
            if(acct.BillingCountry!=null){
            	countryRecord=billingCountryMap.get(acct.BillingCountry);
            }
                       
            if(countryRecord != null){
 
            	acct.Billing_Region__c  = countryRecord.Billing_Region__c; 
                acct.Billing_Subregion__c = countryRecord.Billing_Subregion__c;   
                acct.Billing_Theater__c = countryRecord.Billing_Theater__c;   
            
            }
 
          	            
        }//end-for
                                                                   
    }
 
 

    /**
     * Given a list of accounts, updates their SDR, OBR,and EIR fields.
     *
     * This method looks at the user role of the current user, then if that role is an
     * SDR, OBR, or EIR, it fills in the appropriate field. Should be called before insert.
     * No DML update.
     *
     * @param {List<Account>} account - List of accounts to be checked
     * @author Kyle Vermeer <kvermeer@box.com>
     * @since 1.0
     */
	public static void populateUserLookups(List<Account> accounts) {
        if (accounts == null || accounts.size() <= 0) { // Check for null or empty input
            System.debug('Provided accounts list empty or null. accounts: ' + accounts);
            return;
        }
        try {
            // Get running user's role
            Id currentUserId = UserInfo.getUserId();
            User currentUser = [SELECT Id, UserRole.Name
                                  FROM User
                                 WHERE Id = :currentUserId
                                   AND isActive = true];
            String currentUserRoleName = currentUser.UserRole.Name;
            if (currentUserRoleName != null) { // Make sure there is a role
                 // Check running user role, set field to update appropriately
                String fieldToUpdate = null;
                if (currentUserRoleName.contains( UserRoleUtils.getSDRRoleIdentifier() ) ) {
                    fieldToUpdate = SDR_FIELD_NAME;
                } else if (currentUserRoleName.contains( UserRoleUtils.getOBRRoleIdentifier() ) ) {
                    fieldToUpdate = OBR_FIELD_NAME;
                } else if (currentUserRoleName.contains( UserRoleUtils.getNIRRoleIdentifier() ) ) {
                    fieldToUpdate = NIR_FIELD_NAME;
                }
                if (fieldToUpdate != null) { // If fieldToUpdate is null, we're done
                    // Update appropriate field for each account
                    for (Account currentAccount: accounts) {
                        currentAccount.put(fieldToUpdate,currentUserId);
                    }
                }
            }
           
        } catch (Exception e) {
            // Log Exception, then add error to accounts
            LoggedException le = new LoggedException(e, 'Trouble updating account user lookups on insert', 'AccountTriggerHelper');
            for (Account currentAccount : accounts) {
                currentAccount.addError('There was an error trying to save this record.  Please contact Sales Systems.');
            }
        }
    }

}