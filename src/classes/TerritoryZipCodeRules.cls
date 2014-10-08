public class TerritoryZipCodeRules {
   
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
 
	// get territory based on zip code and billing country for parent accounts
	public static void assignTerritory(List<Account> accountList) { 

		System.debug('>>>>>>>>>>applyZipCodeAssignmentRules<<<<<<<<<<' );

        Set<String> billingZipCodes = new Set<String>();
        Set<String> billingCountries = new Set<String>();
        Map<String, Territory_Zip_Code__c> territoryZipCodeMap 
        		= new Map<String, Territory_Zip_Code__c>(); //key=zip-country
        
		List <Account> unassignedAccountList = new List<Account>();
		
		Territory_Zip_Code__c lookupTerritoryZipCode;
		String lookupZipCode;
		String billingCountry;
		String billingPostalCode; 
		
        if(accountList==null || accountList.size()==0){
        	return;
        }
        
        for(Account acct : accountList){
        	
        	if(!acct.territory_assigned__c
        		&& acct.Account_Hierarchy__c == ACCOUNT_HIERARCHY_PARENT){
        			
        		unassignedAccountList.add(acct);	
        	}
        	
        }
        
		if(unassignedAccountList.size()==0){
			return;
		}
		
        // get postal code and country
		for(Account acct : unassignedAccountList){
 
			if(acct.BillingCountry==null || acct.BillingPostalCode==null){
				continue;
			}
   
			if(acct.BillingCountry.equalsIgnoreCase(COUNTRY_CANADA)
				&& acct.BillingPostalCode.length()>=3){

            	billingZipCodes.add(acct.BillingPostalCode.substring(0, 3).toUpperCase());
            	billingCountries.add(acct.BillingCountry);

			}else if(acct.BillingCountry.equalsIgnoreCase(COUNTRY_MEXICO)
				&& acct.BillingPostalCode.length()>=5){

            	billingZipCodes.add(acct.BillingPostalCode.substring(0, 5));
            	billingCountries.add(acct.BillingCountry);

			}else if(acct.BillingCountry.equalsIgnoreCase(COUNTRY_UNITED_STATES)
				&& acct.BillingPostalCode.length()>=5){
            	
            	billingZipCodes.add(acct.BillingPostalCode.substring(0, 5));
            	billingCountries.add(acct.BillingCountry);
			}
     
		}
      
		// Get Territory Zip Code records 
        
        if(billingZipCodes.size()>0 && billingCountries.size()>0){
        	
        	for(Territory_Zip_Code__c territoryZipCode : [Select t.Id, t.Name, 
        															t.Mid_Market_Rep__c,  
        															t.Major_Rep__c,   
        															t.ESB_Rep__c, 
        															t.Corporate_Rep__c,
        															t.Mid_Market_Territory__c,  
        															t.Mid_Market_Territory__r.territory_owner__c, 
        															t.Mid_Market_Territory__r.Territory_Owner_Active__c, 
        															t.Major_Territory__c,  
        															t.Major_Territory__r.territory_owner__c,   
        															t.Major_Territory__r.Territory_Owner_Active__c,  
        															t.ESB_Territory__c, 
        															t.ESB_Territory__r.territory_owner__c, 
        															t.ESB_Territory__r.Territory_Owner_Active__c, 
        															t.Corporate_Territory__c, 
        															t.Corporate_Territory__r.territory_owner__c,
        															t.Corporate_Territory__r.Territory_Owner_Active__c,  
        															t.Country__c 
        														From Territory_Zip_Code__c t
        															Where t.Name in :billingZipCodes 
        																and t.Country__c in :billingCountries ]){
        	
        		territoryZipCodeMap.put(territoryZipCode.Name+'-'+territoryZipCode.Country__c , territoryZipCode);
        		
        	}//end-for
        	
			System.debug('>>>>>>>>territoryZipCodeMap='+territoryZipCodeMap);
        }


		
	    for(Account acct: unassignedAccountList){

    		billingCountry = acct.BillingCountry;
	    	billingPostalCode = acct.BillingPostalCode;
 
			lookupZipCode=null;

			if(billingCountry!=null && billingPostalCode!=null){

            	if(billingCountry.equalsIgnoreCase(COUNTRY_CANADA)
            			&& acct.BillingPostalCode.length()>=3){

					lookupZipCode=billingPostalCode.substring(0, 3).toUpperCase();
		
            	}else if(billingCountry.equalsIgnoreCase(COUNTRY_MEXICO)
            				&& acct.BillingPostalCode.length()>=5){

					lookupZipCode=billingPostalCode.substring(0, 5);

            	}else if(billingCountry.equalsIgnoreCase(COUNTRY_UNITED_STATES)
            				&& acct.BillingPostalCode.length()>=5){
					
					lookupZipCode=billingPostalCode.substring(0, 5);
					
            	}
 
            	if(lookupZipCode!=null){

					lookupTerritoryZipCode = territoryZipCodeMap.get(lookupZipCode+'-'+billingCountry);	

					updateTerritory(acct, lookupTerritoryZipCode);
 
            	} 						
			} 
 
	    }//end-for
	    
		System.debug('>>>>>>>accountList='+accountList);
		
	}
	
	// update account owner and territory with territory zip code info
	public static void updateTerritory(Account acct, Territory_Zip_Code__c territoryZipCode) { 

		if(acct==null || territoryZipCode==null){
			return;
		}
		 
			
		if(acct.Normalized_Employees__c==null || acct.Normalized_Employees__c==0){
			return;
		}		

		List<Sales_Division__c> salesDivisions;
		
		
		if(Test.isRunningTest()){
			
			salesDivisions = new List<Sales_Division__c>();
			
			Sales_Division__c sd1 = new Sales_Division__c(Name='Corporate', Minimum_Employees__c=21, Maximum_Employees__c=500);
			Sales_Division__c sd2 = new Sales_Division__c(Name='ESB', Minimum_Employees__c=1, Maximum_Employees__c=20);
			Sales_Division__c sd3 = new Sales_Division__c(Name='Major', Minimum_Employees__c=1001, Maximum_Employees__c=5000);
			Sales_Division__c sd4 = new Sales_Division__c(Name='Mid-Market', Minimum_Employees__c=501, Maximum_Employees__c=1000);
			
			salesDivisions.add(sd1);	
			salesDivisions.add(sd2);
			salesDivisions.add(sd3);
			salesDivisions.add(sd4);
			
		}else{
			
			salesDivisions = Sales_Division__c.getall().values();	
		}
		 
		for(Sales_Division__c sd : salesDivisions){
		
			if(sd.Minimum_Employees__c <= acct.Normalized_Employees__c 
				&& acct.Normalized_Employees__c <= sd.Maximum_Employees__c){

				System.debug('>>>>>>>>>>sd.name='+sd.Name);

				if(SALES_DIVISION_CORPORATE.equalsIgnoreCase(sd.Name)){
					
					acct.Territory__c=territoryZipCode.Corporate_Territory__c;
					
					if(territoryZipCode.Corporate_Territory__r.territory_owner__c!=null
						&& territoryZipCode.Corporate_Territory__r.Territory_Owner_Active__c){
							
						acct.OwnerId = territoryZipCode.Corporate_Territory__r.territory_owner__c;
					
					}
					
					acct.territory_assigned__c = true;
										
				}else if(SALES_DIVISION_ESB.equalsIgnoreCase(sd.Name)){
					
					acct.Territory__c=territoryZipCode.ESB_Territory__c;
					
					if(territoryZipCode.ESB_Territory__r.territory_owner__c!=null
						&& territoryZipCode.ESB_Territory__r.Territory_Owner_Active__c ){
							
						acct.OwnerId = territoryZipCode.ESB_Territory__r.territory_owner__c;
					
					}
					
					acct.territory_assigned__c = true;
					
				} else if(SALES_DIVISION_MAJOR.equalsIgnoreCase(sd.Name)){
					
					acct.Territory__c=territoryZipCode.Major_Territory__c;
					
					if(territoryZipCode.Major_Territory__r.territory_owner__c!=null
						&& territoryZipCode.Major_Territory__r.Territory_Owner_Active__c){
					
						acct.OwnerId = territoryZipCode.Major_Territory__r.territory_owner__c;
					
					}
					
					acct.territory_assigned__c = true;
					
				} else if(SALES_DIVISION_MID_MARKET.equalsIgnoreCase(sd.Name)){
					
					acct.Territory__c=territoryZipCode.Mid_Market_Territory__c;
					
					if(territoryZipCode.Mid_Market_Territory__r.territory_owner__c!=null
						&& territoryZipCode.Mid_Market_Territory__r.Territory_Owner_Active__c){
						acct.OwnerId = territoryZipCode.Mid_Market_Territory__r.territory_owner__c;
					}
					
					acct.territory_assigned__c = true;
					
				}	
			}	
			
		}//end-for
		
		return;
			
	}	
}