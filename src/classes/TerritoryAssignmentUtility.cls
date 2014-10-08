public class TerritoryAssignmentUtility {
  
	public static string COUNTRY_CANADA = 'Canada';
	public static string COUNTRY_MEXICO = 'Mexico';
	public static string COUNTRY_UNITED_STATES = 'United States';

	public static string SALES_DIVISION_CORPORATE = 'Corporate';
	public static string SALES_DIVISION_MAJOR = 'Major';
	public static string SALES_DIVISION_ESB = 'ESB';
	public static string SALES_DIVISION_MID_MARKET = 'Mid-Market';
	
	public static string ACCOUNT_HIERARCHY_PARENT = 'Parent';
	public static string ACCOUNT_HIERARCHY_HOLDING_COMPANY = 'Holding Company';
	public static string ACCOUNT_HIERARCHY_REFERRAL_RESELLER = 'Referral/Reseller';
	public static string ACCOUNT_HIERARCHY_FEDERAL = 'Federal';
	public static string ACCOUNT_HIERARCHY_SUBSIDIARY = 'Subsidiary';
	public static string ACCOUNT_HIERARCHY_HOLDING_COMPANY_SUBSIDIARY = 'Holding Company Subsidiary';

 
	public static void assignAccounts(Set<Id> accountIds) { 
		
		TerritoryContextControl.preventLooping = true;
		
		if(accountIds==null || accountIds.size()==0){
				return;
		}
		
		if(!TerritoryAssignment.isEnabled()){
			return;
		}

		List <Account> accountList = new List<Account>(); // these are all accounts
		List <Account> processAccountList = new List<Account>(); // these are accounts that can be assigned  
 
		// get all accounts and put in accountMap
		for(Account acct : [Select id, Normalized_Industry__c, Normalized_Employees__c,
									BillingCountry, Account_Hierarchy__c, ParentId, BillingPostalCode,
									Billing_Region__c, Billing_Subregion__c, Billing_Theater__c,
									Territory_Assigned__c, Exclude_from_Territory_Assignment__c, 
									Exclude_from_Territory_Assignment_2__c, Territory__c,  
									Parent_Account_Zip_Postal_Code__c, Parent_Account_Country__c,
									Parent.Territory__c, Parent.OwnerId, Parent.Owner_Active__c,  
									OwnerId    
								from Account 
									where id in: accountIds]){ 
			accountList.add(acct);
						
		}//end-for

		
		// clear flag >> territory assigned = false
		for(Account acct : accountList){
			
			// clear flag for unassigned territory 
			acct.territory_assigned__c=false;
		
			if(acct.Exclude_from_Territory_Assignment__c==false 
				&& acct.Exclude_from_Territory_Assignment_2__c==false){
			
				processAccountList.add(acct);		
			}	
		}
		
		if(processAccountList.size()>0){
			
			// assign territories for children accounts
			assignTerritory(processAccountList);
				
			// use territory zip code to assign accounts to territories
			TerritoryZipCodeRules.assignTerritory(processAccountList);
			
			// use territory assignment rules to assign accounts to territories
	 		TerritoryAssignmentRules.assignTerritory(processAccountList);
	 		
		}
		
		
 		// clear flag >> assign_to_territory__c flag 
		for(Account acct : accountList){
			
			// clear flag for unassigned territory 
			acct.Assign_to_Territory__c=false;

		}//end-for	 
		if (accountList.size()>0){
			update accountList;
		}
 	
	} 	


	/* get parent account owner and territory for subsidiary accounts */
	public static void assignTerritory(List<Account> accountList) { 

		System.debug('>>>>>>>>>>assignTerritory<<<<<<<<<<' );

         
		List <Account> unassignedAccountList = new List<Account>();
		
        if(accountList==null || accountList.size()==0){
        	return;
        }
        
        for(Account acct : accountList){
        	
        	if(!acct.territory_assigned__c 
        		&& acct.Account_Hierarchy__c == ACCOUNT_HIERARCHY_SUBSIDIARY){
        			
        		unassignedAccountList.add(acct);	
        	}
        	
        }
        
		if(unassignedAccountList.size()==0){
			return;
		}

		for(Account acct : unassignedAccountList){
		
			if(acct.ParentId==null){
				continue;				
			}  
   				 
			acct.Territory__c=acct.parent.territory__c;
				
			if(acct.Parent.Owner_Active__c){
						
				acct.OwnerId = acct.parent.ownerid;
			}
				
			acct.territory_assigned__c = true;

		}//end-for
   
		
	}
 		


}