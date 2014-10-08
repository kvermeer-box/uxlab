@isTest          
private class TerritoryAssignmentUtility_Test {
   
	private static String TERRITORY_NAME_MID_MARKET = 'Mid-Market Test Territory 1';
	private static String TERRITORY_NAME_ESB 		= 'ESB Test Territory 1';
	private static String TERRITORY_NAME_CORPORATE 	= 'Coroprate Test Territory 1';
	private static String TERRITORY_NAME_MAJOR 		= 'Major Test Territory 1';
	private static String TERRITORY_NAME_ITALY 		= 'Italy Territory';
	private static String TERRITORY_NAME_FRANCE 	= 'France Territory';	
	private static String TERRITORY_NAME_CANADA 	= 'Canada Territory';
	private static String TERRITORY_NAME_MEXICO 	= 'Mexico Territory';
	private static String TERRITORY_NAME_TAIWAN 	= 'Taiwan Territory';
				
	/* create new US Account */	
	/* create new Canada Account */
	/* create new Mexico Account */
	/* create new EMEA Account */
	/* create new APAC Account */

	/* Create Mexican and Canadian accounts to test territory zip code assignment */
	@isTest static void testNA() {

		setupTerritoryData();

		Test.startTest(); 
 
		// ESB Territory Zip Code Lookup
		Account acct1 = new Account (Name='Mexico Account 1', 
										BillingPostalCode = '01000', 
										BillingCountry = 'Mexico', 
										No_Employees__c = 1);
		
 

		insert acct1;
		
		// Mid-Market Territory Zip Code Lookup		
		Account acct2 = new Account (Name='Canada Account 1', 
										BillingPostalCode = 'M3C 0C1', 
										BillingCountry = 'Canada', 
										No_Employees__c = 501);
 
		
		insert acct2;
 

		// Child Mexico
		Account acct3 = new Account (Name='Mexico Account 2', 
										BillingPostalCode = '01000', 
										BillingCountry = 'Mexico', 
										ParentId = acct1.Id,
										No_Employees__c = 51);
		
		insert acct3;


		// Child Canada	
		Account acct4 = new Account (Name='Canada Account 2', 
										BillingPostalCode = 'M3C 0C1', 
										BillingCountry = 'Canada', 
										ParentId = acct2.Id,
										No_Employees__c = 1001);
		insert acct4;
		
		
		// update parent account
		acct1.No_Employees__c = 51;
		acct1.Assign_to_Territory__c = true; 
		update acct1;

		// update parent account
		acct2.No_Employees__c = 501;
		acct2.Assign_to_Territory__c = true; 
		update acct2;
		
		
		Test.stopTest(); 						
		
	}

	/* Create US accounts to test territory zip code assignment */
	@isTest static void testUS() {
 
		setupTerritoryData();
 
		Test.startTest(); 

 

		// Major Territory Zip Code Lookup
		Account acct2 = new Account (Name='Cupertino 95014 Account 1', 
										BillingCity = 'Cupertino', 
										BillingPostalCode = '95014', 
										BillingState = 'CA', 
										BillingCountry = 'United States', 
										No_Employees__c = 1001);
 
		
 
		insert acct2;
		

 		// Create opps
		Opportunity opp1 = new Opportunity(Name='Cupertino 95014 Opp 1', AccountId=acct2.Id, StageName='Prospecting',
                                     Account_Type_Sold__c='Business', CloseDate=Date.today().addDays(10));

		Opportunity opp2 = new Opportunity(Name='Cupertino 95014 Opp 2', AccountId=acct2.Id, StageName='Prospecting',
                                     Account_Type_Sold__c='Business', CloseDate=Date.today().addDays(20));
         
 
		
		//insert opps
		insert opp1;
		insert opp2;
		
	 
	 	// update parent account
		acct2.No_Employees__c = 21;
		acct2.Assign_to_Territory__c = true; 
		update acct2;


	 	// create child account
		Account acct3 = new Account (Name='Cupertino 95014 Account 2', 
										BillingCity = 'Cupertino', 
										BillingPostalCode = '95014', 
										BillingState = 'CA', 
										BillingCountry = 'United States',
										ParentId = acct2.Id,  
										No_Employees__c = 51);
		
		insert acct3;  	 
  
		Opportunity opp3 = new Opportunity(Name='Cupertino Opp 3', AccountId=acct3.Id, StageName='Prospecting',
                                     Account_Type_Sold__c='Business', CloseDate=Date.today().addDays(15));


	 	// update parent account
  		acct2.No_Employees__c = 501;
		acct2.Assign_to_Territory__c = true; 
		update acct2;

 
		Test.stopTest(); 
 
    } 

	/* Create EMEA accounts to test territory assignment rules */
	@isTest static void testEMEA() {
 
		setupTerritoryData();

		Test.startTest(); 
 
		
		// Create Italian account
		Account acct1 = new Account (Name='Italy Account 1', 
										BillingCity = 'Rome', 
										BillingCountry = 'Italy', 
										No_Employees__c = 1);
		
		insert acct1;
		
	 
	 	// Create French account
	 	// It's a parent account
		Account acct2 = new Account (Name='France Account 1', 
										BillingCity = 'Paris', 
										BillingCountry = 'France', 
										No_Employees__c = 1);
		
		insert acct2;		


		// update Italian account
  		acct1.No_Employees__c = 1001;
		acct1.Assign_to_Territory__c = true;
		update acct1; 
 
	 	// create child account
		Account acct3= new Account (Name='France Account 2', 
										BillingCity = 'Paris', 
										BillingCountry = 'France', 
										No_Employees__c = 1,
										parentId=acct2.Id);
		
		insert acct3;  	 
  
		Opportunity opp1 = new Opportunity(Name='France Opp 1', AccountId=acct3.Id, StageName='Prospecting',
                                     Account_Type_Sold__c='Business', CloseDate=Date.today().addDays(5));

		// update French account
		// it's also a parent account
  		acct2.No_Employees__c = 501;
		acct2.Assign_to_Territory__c = true; 
		update acct2;

		
		Test.stopTest(); 
  
    }  

	/* Create APAC accounts to test territory assignment rules */
	@isTest static void testAPAC() {
 
		setupTerritoryData();

		Test.startTest(); 
 
		
		// Create Taiwan account
		Account acct1 = new Account (Name='Taiwan Account 1', 
										BillingCity = 'Taipei', 
										BillingCountry = 'Taiwan, Province of China',
										No_Employees__c = 888);
		
		insert acct1;
 
		
		Test.stopTest(); 
  
    }  

	public static void setupTerritoryData() {
 
		setupBillingCountries(); 
		
		User rep1 = UserTestFactory.buildUserWithProfileAndRole(UserTestFactory.STANDARD_USER_PROFILE.Id, UserTestFactory.HEAD_OF_SALES_ROLE.Id );
		User rep2 = UserTestFactory.buildUserWithProfileAndRole(UserTestFactory.STANDARD_USER_PROFILE.Id, UserTestFactory.HEAD_OF_SALES_ROLE.Id );
		User rep3 = UserTestFactory.buildUserWithProfileAndRole(UserTestFactory.STANDARD_USER_PROFILE.Id, UserTestFactory.HEAD_OF_SALES_ROLE.Id );
		User rep4 = UserTestFactory.buildUserWithProfileAndRole(UserTestFactory.STANDARD_USER_PROFILE.Id, UserTestFactory.HEAD_OF_SALES_ROLE.Id );
		User rep5 = UserTestFactory.buildUserWithProfileAndRole(UserTestFactory.STANDARD_USER_PROFILE.Id, UserTestFactory.HEAD_OF_SALES_ROLE.Id );
		User rep6 = UserTestFactory.buildUserWithProfileAndRole(UserTestFactory.STANDARD_USER_PROFILE.Id, UserTestFactory.HEAD_OF_SALES_ROLE.Id );
		User rep7 = UserTestFactory.buildUserWithProfileAndRole(UserTestFactory.STANDARD_USER_PROFILE.Id, UserTestFactory.HEAD_OF_SALES_ROLE.Id );
		User rep8 = UserTestFactory.buildUserWithProfileAndRole(UserTestFactory.STANDARD_USER_PROFILE.Id, UserTestFactory.HEAD_OF_SALES_ROLE.Id );
		User rep9 = UserTestFactory.buildUserWithProfileAndRole(UserTestFactory.STANDARD_USER_PROFILE.Id, UserTestFactory.HEAD_OF_SALES_ROLE.Id );
					
											
				
		rep1.firstname = 'Test 1';
		rep1.lastname = 'Rep 1';
		
		rep2.firstname = 'Test 2';
		rep2.lastname = 'Rep 2';
		
		rep3.firstname = 'Test 3';
		rep3.lastname = 'Rep 3';
		
		rep4.firstname = 'Test 4';
		rep4.lastname = 'Rep 4';

		rep5.firstname = 'Test 5';
		rep5.lastname = 'Rep 5';

		rep6.firstname = 'Test 6';
		rep6.lastname = 'Rep 6';

		rep7.firstname = 'Test 7';
		rep7.lastname = 'Rep 7';		

		rep8.firstname = 'Test 8';
		rep8.lastname = 'Rep 8';

		rep9.firstname = 'Test 9';
		rep9.lastname = 'Rep 9';
		
		insert rep1;
		insert rep2;
		insert rep3;
		insert rep4;
		insert rep5;
		insert rep6;		
		insert rep7;
		insert rep8;
		insert rep9;
		               
		Territory__c newTerritory = new Territory__c();
		newTerritory.Name = 'global';
		newTerritory.developer_name__c = 'global';
		newTerritory.active__c = true;
		insert newTerritory;
						
		Territory__c newTerritory1 = new Territory__c();
		newTerritory1.Name = TERRITORY_NAME_MID_MARKET;
		newTerritory1.developer_name__c = TERRITORY_NAME_MID_MARKET;
		newTerritory1.parent_territory__c = newTerritory.Id;
		newTerritory1.Active__c = true;
		newTerritory1.territory_owner__c = rep1.Id;
		insert newTerritory1;

		Territory__c newTerritory2 = new Territory__c();
		newTerritory2.Name = TERRITORY_NAME_MAJOR;
		newTerritory2.developer_name__c = TERRITORY_NAME_MAJOR;
		newTerritory2.parent_territory__c = newTerritory.Id;
		newTerritory2.Active__c = true;
		newTerritory2.territory_owner__c = rep2.Id;
		insert newTerritory2;

		Territory__c newTerritory3 = new Territory__c();
		newTerritory3.Name = TERRITORY_NAME_ESB;
		newTerritory3.developer_name__c = TERRITORY_NAME_ESB;
		newTerritory3.parent_territory__c = newTerritory.Id;
		newTerritory3.Active__c = true;
		newTerritory3.territory_owner__c = rep3.Id;
		insert newTerritory3;

		Territory__c newTerritory4 = new Territory__c();
		newTerritory4.Name = TERRITORY_NAME_CORPORATE;
		newTerritory4.developer_name__c = TERRITORY_NAME_CORPORATE;
		newTerritory4.parent_territory__c = newTerritory.Id;
		newTerritory4.Active__c = true;
		newTerritory4.territory_owner__c = rep4.Id;
		insert newTerritory4;

		Territory__c newTerritory5 = new Territory__c();
		newTerritory5.Name = TERRITORY_NAME_ITALY;
		newTerritory5.developer_name__c = TERRITORY_NAME_ITALY;
		newTerritory5.parent_territory__c = newTerritory.Id;
		newTerritory5.Active__c = true;
		newTerritory5.territory_owner__c = rep5.Id;
		insert newTerritory5;		

		Territory__c newTerritory6 = new Territory__c();
		newTerritory6.Name = TERRITORY_NAME_FRANCE;
		newTerritory6.developer_name__c = TERRITORY_NAME_FRANCE;
		newTerritory6.parent_territory__c = newTerritory.Id;
		newTerritory6.Active__c = true;
		newTerritory6.territory_owner__c = rep6.Id;
		insert newTerritory6;											

		Territory__c newTerritory7 = new Territory__c();
		newTerritory7.Name = TERRITORY_NAME_CANADA;
		newTerritory7.developer_name__c = TERRITORY_NAME_CANADA;
		newTerritory7.parent_territory__c = newTerritory.Id;
		newTerritory7.Active__c = true;
		newTerritory7.territory_owner__c = rep7.Id;
		insert newTerritory7;	

		Territory__c newTerritory8 = new Territory__c();
		newTerritory8.Name = TERRITORY_NAME_MEXICO;
		newTerritory8.developer_name__c = TERRITORY_NAME_MEXICO;
		newTerritory8.parent_territory__c = newTerritory.Id;
		newTerritory8.Active__c = true;
		newTerritory8.territory_owner__c = rep8.Id;
		insert newTerritory8;

		Territory__c newTerritory9 = new Territory__c();
		newTerritory9.Name = TERRITORY_NAME_TAIWAN;
		newTerritory9.developer_name__c = TERRITORY_NAME_TAIWAN;
		newTerritory9.parent_territory__c = newTerritory.Id;
		newTerritory9.Active__c = true;
		newTerritory9.territory_owner__c = rep9.Id;
		insert newTerritory9;


		Territory_Assignment_Rule__c territoryAssignmentRule5 = new Territory_Assignment_Rule__c();
    	territoryAssignmentRule5.Territory__c=newTerritory5.Id;
		territoryAssignmentRule5.Minimum_Normalized_Employees__c = 0;
		territoryAssignmentRule5.Maximum_Normalized_Employees__c = 5000;
		territoryAssignmentRule5.Billing_Subregion__c = 'Italy';
		territoryAssignmentRule5.Billing_Region__c = 'Southern';
		territoryAssignmentRule5.Billing_Theater__c = 'EMEA';
		territoryAssignmentRule5.Account_Hierarchy__c = 'Parent';
		territoryAssignmentRule5.active__c = true;
		insert territoryAssignmentRule5;   
		
		Territory_Assignment_Rule__c territoryAssignmentRule6 = new Territory_Assignment_Rule__c();
    	territoryAssignmentRule6.Territory__c=newTerritory6.Id;
		territoryAssignmentRule6.Minimum_Normalized_Employees__c = 0;
		territoryAssignmentRule6.Maximum_Normalized_Employees__c = 5000;
		territoryAssignmentRule6.Normalized_Industry__c = 'Information; Public Administration; Other Services; Manufacturing; Construction; Accommodation and Food Services;';
		territoryAssignmentRule6.Billing_Subregion__c = 'France';
		territoryAssignmentRule6.Billing_Region__c = 'Southern';
		territoryAssignmentRule6.Billing_Theater__c = 'EMEA';
		territoryAssignmentRule6.Account_Hierarchy__c = 'Parent';
		territoryAssignmentRule6.active__c = true;
		insert territoryAssignmentRule6;   		

		Territory_Assignment_Rule__c territoryAssignmentRule9 = new Territory_Assignment_Rule__c();
    	territoryAssignmentRule9.Territory__c=newTerritory9.Id;
		territoryAssignmentRule9.Minimum_Normalized_Employees__c = 0;
		territoryAssignmentRule9.Maximum_Normalized_Employees__c = 5000;
		territoryAssignmentRule9.Account_Hierarchy__c = 'Parent';
		territoryAssignmentRule9.billing_country_name__c = 'Taiwan, Province of China';
		territoryAssignmentRule9.active__c = true;
		insert territoryAssignmentRule9;  


		Territory_Zip_Code__c zip1 = new Territory_Zip_Code__c ();
		
		zip1.Name = '95014';
		zip1.State__c = 'CA';		
		zip1.Area__c  = 'Bay Area';
		zip1.Country__c = 'United States';
		
		zip1.Mid_Market_Territory__c = newTerritory1.id;
		zip1.Mid_Market_Rep__c = rep1.id;
		
		zip1.Major_Territory__c = newTerritory2.id;
		zip1.Major_Rep__c = rep2.id;
		
		zip1.ESB_Territory__c = newTerritory3.id;
		zip1.ESB_Rep__c = rep3.id;

		zip1.Corporate_Territory__c = newTerritory4.id;
		zip1.Corporate_Rep__c = rep4.id;

		insert zip1;

		Territory_Zip_Code__c zip2 = new Territory_Zip_Code__c ();
		
		zip2.Name = '01000';
		zip2.State__c = 'Distrito Federal';		
		zip2.Area__c  = 'Ciudad De Mexico';
		zip2.Country__c = 'Mexico';
		
		zip2.Mid_Market_Territory__c = newTerritory8.id;
		zip2.Mid_Market_Rep__c = rep8.id;
		
		zip2.Major_Territory__c = newTerritory8.id;
		zip2.Major_Rep__c = rep8.id;
		
		zip2.ESB_Territory__c = newTerritory8.id;
		zip2.ESB_Rep__c = rep8.id;

		zip2.Corporate_Territory__c = newTerritory8.id;
		zip2.Corporate_Rep__c = rep8.id;

		insert zip2;


		Territory_Zip_Code__c zip3 = new Territory_Zip_Code__c ();
		
		zip3.Name = 'M3C'; // 'M3C 0C1';
		//zip3.State__c = '';		
		zip3.Area__c  = 'Metropolitan Toronto';
		zip3.Country__c = 'Canada';
		
		zip3.Mid_Market_Territory__c = newTerritory7.id;
		zip3.Mid_Market_Rep__c = rep7.id;
		
		zip3.Major_Territory__c = newTerritory7.id;
		zip3.Major_Rep__c = rep7.id;
		
		zip3.ESB_Territory__c = newTerritory7.id;
		zip3.ESB_Rep__c = rep7.id;

		zip3.Corporate_Territory__c = newTerritory7.id;
		zip3.Corporate_Rep__c = rep7.id;

		insert zip3;
		
	}			

	public static void setupBillingCountries() {
		
  		Billing_Country__c billingCountry1 = new Billing_Country__c();
  		billingCountry1.Name = 'France';
		billingCountry1.Billing_Theater__c = 'EMEA';
        billingCountry1.Billing_Region__c = 'Southern';
        billingCountry1.Billing_Subregion__c = 'France';
        insert billingCountry1;
        
  		Billing_Country__c billingCountry2 = new Billing_Country__c();
  		billingCountry2.Name = 'United States';
		billingCountry2.Billing_Theater__c = 'NA';
        billingCountry2.Billing_Region__c = 'Emerging';
        insert billingCountry2;
        
  		Billing_Country__c billingCountry3 = new Billing_Country__c();
  		billingCountry3.Name = 'Italy';
		billingCountry3.Billing_Theater__c = 'EMEA';
        billingCountry3.Billing_Region__c = 'Southern';
        billingCountry3.Billing_Subregion__c = 'Italy';
        insert billingCountry3;

  		Billing_Country__c billingCountry4 = new Billing_Country__c();
  		billingCountry4.Name = 'Canada';
		billingCountry4.Billing_Theater__c = 'NA';
        billingCountry4.Billing_Region__c = 'Emerging';
        insert billingCountry4;
        
  		Billing_Country__c billingCountry5 = new Billing_Country__c();
  		billingCountry5.Name = 'Mexico';
		billingCountry5.Billing_Theater__c = 'NA';
        billingCountry5.Billing_Region__c = 'Emerging'; 
        insert billingCountry5;

  		Billing_Country__c billingCountry6 = new Billing_Country__c();
  		billingCountry6.Name = 'Taiwan, Province of China';
		billingCountry6.Billing_Theater__c = 'APAC';
        billingCountry6.Billing_Region__c = 'Emerging'; 
        insert billingCountry6;

	}

}