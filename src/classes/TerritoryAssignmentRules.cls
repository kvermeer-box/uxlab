public class TerritoryAssignmentRules {
    
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
	

	// use territory assignment rules to find territory
	public static void assignTerritory(List<Account> accountList) { 

		System.debug('>>>>>>>applyAssignmentRules<<<<<<<<<<' );

		List<Territory_Assignment_Rule__c> territoryAssignmentRuleList = new List<Territory_Assignment_Rule__c>();
        
		List <Account> unassignedAccountList = new List<Account>();
		
		System.debug('>>>>>>>accountList='+accountList);
		
        for(Account acct : accountList){
        	
        	if(!acct.territory_assigned__c){
        			
        		unassignedAccountList.add(acct);	
        	}
        	
        }
		
		System.debug('>>>>>>>unassignedAccountList='+unassignedAccountList);
		        
		if(unassignedAccountList.size()==0){
			return;
		}
	
		for(Territory_Assignment_Rule__c tar : [Select t.Territory__c, t.Billing_Subregion__c, t.Billing_Region__c, 
															t.Billing_Theater__c, 
															t.Normalized_Industry__c, t.Minimum_Normalized_Employees__c, 
															t.Account_Hierarchy__c, t.Territory__r.Territory_Owner__c, 
															t.Maximum_Normalized_Employees__c, t.Id, 
															t.Territory__r.Territory_Owner_Active__c,
															t.billing_country_name__c  
														From Territory_Assignment_Rule__c t 
															Where Active__c = true
																limit 2000]){
																	
			territoryAssignmentRuleList.add(tar);					

		}//end-for			
		
		if(territoryAssignmentRuleList.size()==0){
			return;
		}
		
		for(Account acct : unassignedAccountList){
			
			System.debug('====================================================');
			
			for(Territory_Assignment_Rule__c tar : territoryAssignmentRuleList){
			
				// check account hierarchy, region, subregion, industry, employee count, theater
			
				System.debug('>>>>>>>>tar='+tar);

				System.debug('>>>>>>>>acct.Account_Hierarchy__c='+acct.Account_Hierarchy__c);				
				if(tar.Account_Hierarchy__c != null){
				
					if(acct.Account_Hierarchy__c==null){
						continue;	
					} else if(acct.Account_Hierarchy__c!=null && acct.Account_Hierarchy__c!=tar.Account_Hierarchy__c){
						continue;	
					}
				}		

				System.debug('>>>>>>>>acct.BillingCountry='+acct.BillingCountry);
				if(tar.Billing_Country_Name__c != null){
				
					if(acct.BillingCountry==null){
						continue;	
					}else if(acct.BillingCountry!=null && acct.BillingCountry!=tar.Billing_Country_Name__c){
						continue;	
					}
				}

				System.debug('>>>>>>>>acct.Billing_Theater__c='+acct.Billing_Theater__c);
				if(tar.Billing_Theater__c != null){
				
					if(acct.Billing_Theater__c==null){
						continue;	
					}else if(acct.Billing_Theater__c!=null && acct.Billing_Theater__c!=tar.Billing_Theater__c){
						continue;	
					}
				}
				
				System.debug('>>>>>>>>acct.Billing_Region__c='+acct.Billing_Region__c);		
				if(tar.Billing_Region__c != null){
				
					if(acct.Billing_Region__c==null){
						continue;	
					} else if(acct.Billing_Region__c!=null && acct.Billing_Region__c!=tar.Billing_Region__c){
						continue;	
					}
				}
				
				System.debug('>>>>>>>>acct.Billing_Subregion__c='+acct.Billing_Subregion__c);	
				if(tar.Billing_Subregion__c != null){
				
					if(acct.Billing_Subregion__c==null){
						continue;
					} else if(acct.Billing_Subregion__c!=null && acct.Billing_Subregion__c!=tar.Billing_Subregion__c){
						continue;	
					}
				}
				
				System.debug('>>>>>>>>acct.Normalized_Industry__c='+acct.Normalized_Industry__c);	
				if(tar.Normalized_Industry__c != null){

					if(acct.Normalized_Industry__c==null){
						continue;
					}else if(acct.Normalized_Industry__c!=null 
						&& tar.Normalized_Industry__c.indexof(acct.Normalized_Industry__c+';')<0){
						continue;	
					}
				}
				
				System.debug('>>>>>>>>acct.Normalized_Employees__c='+acct.Normalized_Employees__c);
				if(tar.Minimum_Normalized_Employees__c != null){
				
					if(acct.Normalized_Employees__c==null){
						continue;	
					}else if(acct.Normalized_Employees__c!=null 
						&& tar.Minimum_Normalized_Employees__c > acct.Normalized_Employees__c){
						continue;	
					}
				}
				
				System.debug('>>>>>>>>acct.Normalized_Employees__c='+acct.Normalized_Employees__c);
				if(tar.Maximum_Normalized_Employees__c != null){
				
					if(acct.Normalized_Employees__c==null){
						continue;	
					}else if(acct.Normalized_Employees__c!=null 
						&& tar.Maximum_Normalized_Employees__c < acct.Normalized_Employees__c){
						continue;	
					}
				}
				
				// this assignment rule applies
				updateTerritory(acct, tar);
		
			}//end-for territory assignemnt rule	
		}//end-for account
		
		System.debug('>>>>>>>accountList='+accountList);
		
	}

	// update account owner and territory from territory assignment rule
	public static void updateTerritory(Account acct, Territory_Assignment_Rule__c assignmentRule) {

		if(acct==null || assignmentRule==null){
			return;
		}	

		if(assignmentRule.Territory__c==null){
			return;
		} 

		acct.territory__c = assignmentRule.Territory__c;
		
		if(assignmentRule.Territory__r.territory_owner__c!=null
			&& assignmentRule.Territory__r.Territory_Owner_Active__c){
				
			acct.ownerid = assignmentRule.Territory__r.territory_owner__c;
			
		}
		
		acct.territory_assigned__c = true;
		
	}	


}