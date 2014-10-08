/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Territory_TestRouting {
	
	private static final String ENTRY_VALUE_DEFAULT = '<< Default Assignment Rule >>';

	private static final String EMEA_CORP = 'EMEA - Corporate';
	private static final String EMEA_NATIONAL = 'EMEA - Nationals';
	
	private static final String RECORD_TYPE_ZIP = '012600000009YLr';
	private static final String RECORD_TYPE_COUNTRY = '012600000009YLq';

    static testMethod void myUnitTest() {
    	
    	User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    	System.runAs (thisUser) {
	        // Set up teams
	        List<Territory_Team__c> teams = new List<Territory_Team__c>();

			Territory_Team__c emeaCorp = new Territory_Team__c();
	        emeaCorp.Name = EMEA_CORP;
			teams.add(emeaCorp);
			
			Territory_Team__c emeaNational = new Territory_Team__c();
	        emeaNational.Name = EMEA_NATIONAL;
			teams.add(emeaNational);                
	        insert teams;
	        	        
	        // Set up team member roles
	        List<Territory_Team_Member_Role__c> roles = new List<Territory_Team_Member_Role__c>();
	        for (Territory_Team__c team : teams) {
	        	Territory_Team_Member_Role__c role = new Territory_Team_Member_Role__c();
	        	role.Territory_Team__c = team.Id;
        		role.Role_Name__c = team.Name;
        		roles.add(role);
	        }        
	        insert roles;
	        	        
	        // Set up regular roles
	        List<UserRole> userRoles = new List<UserRole>();
	        for (Territory_Team_Member_Role__c role : roles) {
	        	UserRole userRole = new UserRole();
	        	userRole.Name = role.Role_Name__c;
	        	userRole.OpportunityAccessForAccountOwner = 'edit';
	        	userRoles.add(userRole);
	        }
	        insert userRoles;
	        System.debug(System.LoggingLevel.ERROR, 'Territory_TestAssignment: ' + userRoles.size() + ' user roles inserted.');	        
	        
	        // Set up users
	        List<User> users = new List<User>();
            Integer count = 0;
	        for (UserRole role : userRoles) {
	        	for (Integer i = 0; i < 1; i++) {
	        		User user = new User();
	        		String s = 'mnbbgth' + count;
                    count = count + 1;
	        		user.LastName = s;
	        		user.Alias = s;
	        		user.Email = s + '@box.com';
	        		user.EmailEncodingKey = 'UTF-8';
	        		user.ProfileId = '00e60000000nlAt';
	        		user.Username = s + '@boxTERRITORY.com';
	        		user.TimeZoneSidKey = 'America/Los_Angeles'; 
	        		user.LocaleSidKey = 'en_US';
	        		user.LanguageLocaleKey = 'en_US';
	        		user.UserRoleId = role.Id;
	        		user.IsActive = true;
	        		users.add(user);
	        	}
	        }
	        // Default user
	        User defaultUser = new User();
	        String d = 'DEFAULT';        
			defaultUser.LastName = d;
			defaultUser.Alias = 'd';
			defaultUser.Email = 'defzzz@box.com';
			defaultUser.EmailEncodingKey = 'UTF-8';
			defaultUser.ProfileId = '00e60000000nlAt';
			defaultUser.Username = 'ldlquydsfnalk@box.com';
			defaultUser.TimeZoneSidKey = 'America/Los_Angeles'; 
			defaultUser.LocaleSidKey = 'en_US';
			defaultUser.LanguageLocaleKey = 'en_US';
			defaultUser.IsActive = true;
			users.add(defaultUser);                       
			insert users;
			System.debug(System.LoggingLevel.ERROR, 'Territory_TestAssignment: ' + users.size() + ' users inserted.');
			
			// Set up employee segment field mappings
			List<Territory_Employee_Segment_Field_Mapping__c> mappings = new List<Territory_Employee_Segment_Field_Mapping__c>();
			Territory_Employee_Segment_Field_Mapping__c esb = new Territory_Employee_Segment_Field_Mapping__c();
			esb.Name = 'ESB';
			esb.Max_Employee_Segment__c = '20';
			esb.Rep_Field_API_Name__c = 'ESB_Rep__c';
			esb.Team_Field_API_Name__c = 'ESB_Team__c';
			mappings.add(esb);
			
			Territory_Employee_Segment_Field_Mapping__c corp = new Territory_Employee_Segment_Field_Mapping__c();
			corp.Name = 'Corporate';
			corp.Max_Employee_Segment__c = '1000';
			corp.Rep_Field_API_Name__c = 'Corporate_Rep__c';
			corp.Team_Field_API_Name__c = 'Corporate_Team__c';
			mappings.add(corp);
			
			Territory_Employee_Segment_Field_Mapping__c major = new Territory_Employee_Segment_Field_Mapping__c();
			major.Name = 'Major';
			major.Max_Employee_Segment__c = '5000';
			major.Rep_Field_API_Name__c = 'Major_Rep__c';
			major.Team_Field_API_Name__c = 'Major_Team__c';
			mappings.add(major);
			
			Territory_Employee_Segment_Field_Mapping__c nat = new Territory_Employee_Segment_Field_Mapping__c();
			nat.Name = 'National';
			nat.Max_Employee_Segment__c = 'Unlimited';
			nat.Rep_Field_API_Name__c = 'National_Rep__c';
			nat.Team_Field_API_Name__c = 'National_Team__c';
			mappings.add(nat);
			insert mappings;
	        
	        // Set up assignment rules
	        List<Territory_Stage_2_Assignment_Rule__c> t2Rules = new List<Territory_Stage_2_Assignment_Rule__c>();        
	        Territory_Stage_2_Assignment_Rule__c defaultRule = new Territory_Stage_2_Assignment_Rule__c();
	        defaultRule.Active__c = true;
	        defaultRule.RecordTypeId = RECORD_TYPE_COUNTRY;
	        defaultRule.Country__c = ENTRY_VALUE_DEFAULT;
	        defaultRule.ESB_Rep__c = defaultUser.Id;
	        defaultRule.Corporate_Rep__c = defaultUser.Id;
	        defaultRule.Major_Rep__c = defaultUser.Id;
	        defaultRule.National_Rep__c = defaultUser.Id;
	        t2Rules.add(defaultRule);
	        
	        Territory_Stage_2_Assignment_Rule__c emeaRule = new Territory_Stage_2_Assignment_Rule__c();
	        emeaRule.Active__c = true;
	        emeaRule.RecordTypeId = RECORD_TYPE_COUNTRY;
	        emeaRule.Country__c = 'China';
	        emeaRule.ESB_Team__c = emeaCorp.Id;
	        emeaRule.Corporate_Team__c = emeaCorp.Id;
	        emeaRule.Major_Team__c = emeaNational.Id;
	        emeaRule.National_Team__c = emeaNational.Id;
	        t2Rules.add(emeaRule);
	        
	        Territory_Stage_2_Assignment_Rule__c zipRule = new Territory_Stage_2_Assignment_Rule__c();
	        zipRule.Active__c = true;
	        zipRule.RecordTypeId = RECORD_TYPE_ZIP;
	        zipRule.Zip_Code__c = '00000';
	        zipRule.ESB_Rep__c = users[0].Id;
	        zipRule.Corporate_Rep__c = users[0].Id;
	        zipRule.Major_Rep__c = users[0].Id;
	        zipRule.National_Rep__c = users[0].Id;
	        t2Rules.add(zipRule);
	        insert t2Rules;	       
	        
	        // Custom settings
	        TerritorySettings__c settings = new TerritorySettings__c();
	        settings.Name = 'default';
	        settings.Routed_Leads_History__c = 30;
	        settings.Turn_Off_Stage_1_Assignment__c = false; 
	        settings.Lead_Converted_Status__c = 'Qualified - New Opportunity';
	        insert settings;
	        
	        // Drop the fat one
	        test.startTest();
	        
	        // Insert 200 leads
	        List<Lead> leads = new List<Lead>();
	        
	        // Dupe lead
        	Lead lead1 = new Lead();
        	String random = String.valueOf((Math.random() * 10000000).intValue());
        	lead1.LastName = random;
        	lead1.Email = random + '@duck.com';
        	lead1.Company = random;
        	lead1.Number_of_Users__c = 1;
        	lead1.Employees__c = 1;
        	lead1.Competition__c = 'bleh';
        	leads.add(lead1);
        	Account a = new Account();
        	a.Name = 'dupe';
        	insert a;
        	Contact c = new Contact();
        	c.LastName = random;
        	c.AccountId = a.Id;
        	c.Email = random + '@duck.com';
        	insert c;

            test.stopTest();
        	
        	
        	// Missing data
        	Lead lead2 = new Lead();
        	random = String.valueOf((Math.random() * 10000000).intValue());
        	lead2.LastName = random;
        	lead2.Email = random + '@duck.com';
        	lead2.Company = random;
        	lead2.Employees__c = 1;
        	lead2.Competition__c = 'bleh';
        	leads.add(lead2);
        	Lead lead3 = new Lead();
        	random = String.valueOf((Math.random() * 10000000).intValue());
        	lead3.LastName = random;
        	lead3.Email = random + '@duck.com';
        	lead3.Company = random;
        	lead3.Number_of_Users__c = 1;
        	lead3.Business_Web_Trial__c = true;
        	lead3.Employees__c = 1;
        	lead3.Competition__c = 'bleh';
        	leads.add(lead3);
        	
        	// Good leads
        	Lead lead4 = new Lead();
        	random = String.valueOf((Math.random() * 10000000).intValue());
        	lead4.LastName = random;
        	lead4.Email = random + '@duck.com';
        	lead4.Company = random;
        	lead4.Number_of_Users__c = 1;
        	lead4.Employees__c = 1;
        	lead4.Competition__c = 'bleh';
        	lead4.Country = 'China';
        	leads.add(lead4);
        	
        	Lead lead5 = new Lead();
        	random = String.valueOf((Math.random() * 10000000).intValue());
        	lead5.LastName = random;
        	lead5.Email = random + '@duck.com';
        	lead5.Company = random;
        	lead5.Number_of_Users__c = 1;
        	lead5.Employees__c = 1;
        	lead5.Competition__c = 'bleh';
        	lead5.PostalCode = '00000';
        	leads.add(lead5);
        	insert leads;
	        
			Territory_S2AssignLeads assigner = new Territory_S2AssignLeads(leads);
            try {
                assigner.massRoute(false);
            }
            catch (Exception e) {
                //
            }
	        
	        
    	}
    }
}