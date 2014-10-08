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
private class Territory_TestAssignment {

	private static final String ENTRY_METHOD_COUNTRY = 'Country';
	private static final String ENTRY_METHOD_CONTACT_METHOD_GROUPING = 'Contact Method Grouping'; 
	private static final String ENTRY_METHOD_MAX_EMPLOYEES = 'Max Employee Size'; 
	
	private static final String ENTRY_VALUE_DEFAULT = '<< Default Assignment Rule >>';
	private static final String ENTRY_VALUE_WEB_TRIAL = 'Web Trial CC-Required';

	private static final String FREEMIUM = 'Freemium SDRs';
	private static final String INBOUND = 'Inbound SDRs';
	private static final String DIRECT_MARKETING = 'Direct Marketing SDRs';
	private static final String AUSSIE_BDR = 'Aussie BDRs';
	private static final String EMEA_CORP = 'EMEA - Corporate';
	private static final String EMEA_NATIONAL = 'EMEA - Nationals';

    static testMethod void myUnitTest() {
    	
    	User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    	System.runAs (thisUser) {
	        // Set up teams
	        List<Territory_Team__c> teams = new List<Territory_Team__c>();
	        
	        Territory_Team__c freemiumAndDirectMarketingSdrs = new Territory_Team__c();
	        freemiumAndDirectMarketingSdrs.Name = FREEMIUM + ' & ' + DIRECT_MARKETING;
			teams.add(freemiumAndDirectMarketingSdrs);
	        
	        Territory_Team__c inboundSdrs = new Territory_Team__c();
	        inboundSdrs.Name = INBOUND;
			teams.add(inboundSdrs);
			
			Territory_Team__c aussieBdrs = new Territory_Team__c();
	        aussieBdrs.Name = AUSSIE_BDR;
			teams.add(aussieBdrs);
			
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
	        	// Double team membership
	        	if (team.Name.contains(' & ')) {
	        		List<String> names = team.Name.split(' & ');
	        		role.Role_Name__c = names[0];
	        		roles.add(role);
	        		Territory_Team_Member_Role__c role2 = role.clone();
	        		role2.Role_Name__c = names[1];
	        		roles.add(role2);	
	    		// Normal team membership
	        	} else {
	        		role.Role_Name__c = team.Name;
	        		roles.add(role);
	        	}        	
	        }        
	        insert roles;
	        
	        // Delete roles
	        List<UserRole> oldRoles = [SELECT Id FROM UserRole WHERE PortalType = 'None'];
	        Integer iteration = 0;
	        for (UserRole r : oldRoles) {
	        	r.Name = 'zzzzzzzzzzzzzzzzzzzzzz' + iteration;
	        	r.DeveloperName = 'zzzzzzzzzzzzzzzzzzz'  + iteration;
	        	iteration++;
	        }
	        update oldRoles;
	        
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
	        	        
	        
	        /*
	        // Eventley bs
	        List<eventforce__TimezoneOffset__c> timezones = new List<eventforce__TimezoneOffset__c>();
	        
	        eventforce__TimezoneOffset__c denver = new eventforce__TimezoneOffset__c();
	        denver.Name = 'America/Denver';
	        denver.eventforce__Offset__c = 60;
	        timezones.add(denver);
	        
	        eventforce__TimezoneOffset__c la = new eventforce__TimezoneOffset__c();
	        la.Name = 'America/Los_Angeles';
	        la.eventforce__Offset__c = 60;
	        timezones.add(la);
	        
	        eventforce__TimezoneOffset__c ny = new eventforce__TimezoneOffset__c();
	        ny.Name = 'America/New_York';
	        ny.eventforce__Offset__c = 60;
	        timezones.add(ny);
	        
	        eventforce__TimezoneOffset__c panama = new eventforce__TimezoneOffset__c();
	        panama.Name = 'America/Panama';
	        panama.eventforce__Offset__c = 60;
	        timezones.add(panama);
	        
	        eventforce__TimezoneOffset__c london = new eventforce__TimezoneOffset__c();
	        london.Name = 'Europe/London';
	        london.eventforce__Offset__c = 60;
	        timezones.add(london);
	        
	        eventforce__TimezoneOffset__c gmt = new eventforce__TimezoneOffset__c();
	        gmt.Name = 'GMT';
	        gmt.eventforce__Offset__c = 60;
	        timezones.add(gmt);
	        
	        insert timezones;
	        */
	        
	        
	        // Delete all users
	        List<User> oldUsers = [SELECT Id FROM User WHERE Remove_From_All_Lead_Assignment_Queues__c = false AND IsActive = true];
	        for (User u : oldUsers) {
	        	u.Remove_From_All_Lead_Assignment_Queues__c = true;
	        }
	        update oldUsers;
	        
	        // Set up users
	        List<User> users = new List<User>();
	        for (UserRole role : userRoles) {
	        	for (Integer i = 0; i < 50; i++) {
	        		User user = new User();
	        		String s = String.valueOf((Math.random() * 10000000).intValue());
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
	        // Black hole user
	        User blackHoleUser = new User();
	        String bh = 'BLACK HOLE';        
			blackHoleUser.LastName = bh;
			blackHoleUser.Alias = 'bh';
			blackHoleUser.Email = 'blackhole@box.com';
			blackHoleUser.EmailEncodingKey = 'UTF-8';
			blackHoleUser.ProfileId = '00e60000000nlAt';
			blackHoleUser.Username = 'blackholebhbhbhbhbhbh@box.com';
			blackHoleUser.TimeZoneSidKey = 'America/Los_Angeles'; 
			blackHoleUser.LocaleSidKey = 'en_US';
			blackHoleUser.LanguageLocaleKey = 'en_US';
			blackHoleUser.IsActive = true;
			users.add(blackHoleUser);                       
	        // QA user
	        User qaUser = new User();
	        String q = 'QA';        
			qaUser.LastName = q;
			qaUser.Alias = q;
			qaUser.Email = q + '@box.com';
			qaUser.EmailEncodingKey = 'UTF-8';
			qaUser.ProfileId = '00e60000000nlAt';
			qaUser.Username = q + 'qaqaqaqaqaqaqaqa@box.com';
			qaUser.TimeZoneSidKey = 'America/Los_Angeles'; 
			qaUser.LocaleSidKey = 'en_US';
			qaUser.LanguageLocaleKey = 'en_US';
			qaUser.IsActive = true;
			users.add(qaUser);
			// BD user
			User bdUser = new User();
	        String b = 'BD';        
			bdUser.LastName = b;
			bdUser.Alias = b;
			bdUser.Email = b + '@box.com';
			bdUser.EmailEncodingKey = 'UTF-8';
			bdUser.ProfileId = '00e60000000nlAt';
			bdUser.Username = b + 'bdbdbdbdbdbdbdbd@box.com';
			bdUser.TimeZoneSidKey = 'America/Los_Angeles'; 
			bdUser.LocaleSidKey = 'en_US';
			bdUser.LanguageLocaleKey = 'en_US';
			bdUser.IsActive = true;
			users.add(bdUser);
			insert users;
			System.debug(System.LoggingLevel.ERROR, 'Territory_TestAssignment: ' + users.size() + ' users inserted.');
			
			// Default web trial queue
			Group defaultWebTrialGroup = new Group();
			defaultWebTrialGroup.Name = 'DEFAULT WEB TRIAL';
			defaultWebTrialGroup.Type = 'Queue';
			insert defaultWebTrialGroup;
			QueueSObject defaultWebTrialQueue = new QueueSObject();
			defaultWebTrialQueue.QueueId = defaultWebTrialGroup.Id;
			defaultWebTrialQueue.SobjectType = 'Lead';
			insert defaultWebTrialQueue;        
	        
	        // Set up assignment rules
	        List<Territory_Stage_1_Assignment_Rule__c> t1Rules = new List<Territory_Stage_1_Assignment_Rule__c>();        
	        Territory_Stage_1_Assignment_Rule__c qaRule = new Territory_Stage_1_Assignment_Rule__c();
	        qaRule.Entry_Method__c = '<< QA Lead >>';
	        qaRule.Entry_Value__c = '<< QA Lead >>';
	        qaRule.Assigned_User__c = qaUser.Id;
	        t1Rules.add(qaRule);
	        
	        Territory_Stage_1_Assignment_Rule__c bdRule = new Territory_Stage_1_Assignment_Rule__c();
	        bdRule.Entry_Method__c = '<< Business Development >>';
	        bdRule.Entry_Value__c = '<< Business Development >>';
	        bdRule.Assigned_User__c = bdUser.Id;
	        t1Rules.add(bdRule);
	        
	        Territory_Stage_1_Assignment_Rule__c blackHoleRule = new Territory_Stage_1_Assignment_Rule__c();
	        blackHoleRule.Entry_Method__c = '<< Black Hole >>';
	        blackHoleRule.Entry_Value__c = '<< Black Hole >>';
	        blackHoleRule.Assigned_User__c = blackHoleUser.Id;
	        t1Rules.add(blackHoleRule);
	        
	        Territory_Stage_1_Assignment_Rule__c aussieRule = new Territory_Stage_1_Assignment_Rule__c();
	        aussieRule.Entry_Method__c = ENTRY_METHOD_COUNTRY;
	        aussieRule.Entry_Value__c = 'Europe';
	        aussieRule.Assigned_Team__c = aussieBdrs.Id;
	        t1Rules.add(aussieRule);
	        
	        Territory_Stage_1_Assignment_Rule__c franceRule = new Territory_Stage_1_Assignment_Rule__c();
	        franceRule.Entry_Method__c = ENTRY_METHOD_COUNTRY;
	        franceRule.Entry_Value__c = 'France';
	        t1Rules.add(franceRule);
	        
	        Territory_Stage_1_Assignment_Rule__c defaultCountryRule = new Territory_Stage_1_Assignment_Rule__c();
	        defaultCountryRule.Entry_Method__c = ENTRY_METHOD_COUNTRY;
	        defaultCountryRule.Entry_Value__c = ENTRY_VALUE_DEFAULT;
	        t1Rules.add(defaultCountryRule);
	        insert t1Rules;
	        
	        // Tier 2
	        List<Territory_Stage_1_Assignment_Rule__c> t2Rules = new List<Territory_Stage_1_Assignment_Rule__c>();        
	        Territory_Stage_1_Assignment_Rule__c defaultWebTrial = new Territory_Stage_1_Assignment_Rule__c();
	        defaultWebTrial.Entry_Method__c = ENTRY_METHOD_CONTACT_METHOD_GROUPING;
	        defaultWebTrial.Entry_Value__c = ENTRY_VALUE_WEB_TRIAL;
	        defaultWebTrial.Parent_Assignment_Rule__c = defaultCountryRule.Id;
	        t2Rules.add(defaultWebTrial);
	        
	        Territory_Stage_1_Assignment_Rule__c inboundRule = new Territory_Stage_1_Assignment_Rule__c();
	        inboundRule.Entry_Method__c = ENTRY_METHOD_CONTACT_METHOD_GROUPING;
	        inboundRule.Entry_Value__c = ENTRY_VALUE_DEFAULT;
	        inboundRule.Assigned_Team__c = inboundSdrs.Id;
	        inboundRule.Parent_Assignment_Rule__c = defaultCountryRule.Id;
	        t2Rules.add(inboundRule);
	        
	        Territory_Stage_1_Assignment_Rule__c franceWebTrialRule = new Territory_Stage_1_Assignment_Rule__c();
	        franceWebTrialRule.Entry_Method__c = ENTRY_METHOD_CONTACT_METHOD_GROUPING;
	        franceWebTrialRule.Entry_Value__c = ENTRY_VALUE_WEB_TRIAL;
	        franceWebTrialRule.Parent_Assignment_Rule__c = franceRule.Id;
	        t2Rules.add(franceWebTrialRule);
	        insert t2Rules;
	        
	        // Tier 3
	        List<Territory_Stage_1_Assignment_Rule__c> t3Rules = new List<Territory_Stage_1_Assignment_Rule__c>();        
	        Territory_Stage_1_Assignment_Rule__c defaultWebTrialSmallEmployeeRule = new Territory_Stage_1_Assignment_Rule__c();
	        defaultWebTrialSmallEmployeeRule.Entry_Method__c = ENTRY_METHOD_MAX_EMPLOYEES;
	        defaultWebTrialSmallEmployeeRule.Entry_Value__c = '5000';
	        defaultWebTrialSmallEmployeeRule.Parent_Assignment_Rule__c = defaultWebTrial.Id;
	        defaultWebTrialSmallEmployeeRule.Assigned_Team__c = freemiumAndDirectMarketingSdrs.Id;
	        t3Rules.add(defaultWebTrialSmallEmployeeRule);
	        
	        Territory_Stage_1_Assignment_Rule__c defaultWebTrialBigEmployeeRule = new Territory_Stage_1_Assignment_Rule__c();
	        defaultWebTrialBigEmployeeRule.Entry_Method__c = ENTRY_METHOD_MAX_EMPLOYEES;
	        defaultWebTrialBigEmployeeRule.Entry_Value__c = 'Unlimited';
	        defaultWebTrialBigEmployeeRule.Parent_Assignment_Rule__c = defaultWebTrial.Id;
	        defaultWebTrialBigEmployeeRule.Assigned_Queue__c = defaultWebTrialQueue.QueueId;
	        t3Rules.add(defaultWebTrialBigEmployeeRule);
	        
	        Territory_Stage_1_Assignment_Rule__c franceWebTrialSmallEmployeeRule = new Territory_Stage_1_Assignment_Rule__c();
	        franceWebTrialSmallEmployeeRule.Entry_Method__c = ENTRY_METHOD_MAX_EMPLOYEES;
	        franceWebTrialSmallEmployeeRule.Entry_Value__c = '5000';
	        franceWebTrialSmallEmployeeRule.Parent_Assignment_Rule__c = franceWebTrialRule.Id;
	        franceWebTrialSmallEmployeeRule.Assigned_Team__c = emeaCorp.Id;
	        t3Rules.add(franceWebTrialSmallEmployeeRule);
	        
	        Territory_Stage_1_Assignment_Rule__c franceWebTrialBigEmployeeRule = new Territory_Stage_1_Assignment_Rule__c();
	        franceWebTrialBigEmployeeRule.Entry_Method__c = ENTRY_METHOD_MAX_EMPLOYEES;
	        franceWebTrialBigEmployeeRule.Entry_Value__c = 'Unlimited';
	        franceWebTrialBigEmployeeRule.Parent_Assignment_Rule__c = franceWebTrialRule.Id;
	        franceWebTrialBigEmployeeRule.Assigned_Team__c = emeaNational.Id;
	        t3Rules.add(franceWebTrialBigEmployeeRule);
	        insert t3Rules;
	        
	        // Custom settings
	        TerritorySettings__c settings = new TerritorySettings__c();
	        settings.Name = 'default';
	        settings.Routed_Leads_History__c = 30;
	        settings.Turn_Off_Stage_1_Assignment__c = false; 
	        insert settings;
	        
	        // Shut off the old bs
	        LeadAssignmentSettings__c oldSettings = new LeadAssignmentSettings__c();
	        oldSettings.name = 'default';        
    		oldSettings.Emergency_Shutoff_Button_for_Auto_Assign__c = true;
    		insert oldSettings;
	        
	        // Drop the fat one
	        test.startTest();
	        
	        // Insert 200 leads
	        List<Lead> leads = new List<Lead>();
	        
	        // These 20 will go to inbound sdrs
	        for (Integer i = 0; i < 20; i++) {
	        	Lead lead = new Lead();
	        	String random = String.valueOf((Math.random() * 10000000).intValue());
	        	lead.LastName = random;
	        	lead.Email = random + '@duck.com';
	        	lead.Company = random;
	        	lead.Trigger_Assignment__c = true;
	        	leads.add(lead);
	        }
	        
	        // These 20 will go to Aussie BDRs
	        for (Integer i = 0; i < 20; i++) {
	        	Lead lead = new Lead();
	        	String random = String.valueOf((Math.random() * 10000000).intValue());
	        	lead.LastName = random;
	        	lead.Email = random + '@duck.com';
	        	lead.Company = random;
	        	lead.Eloqua_Country_Code__c = 'EU';
	        	lead.Country = 'Australia';
	        	lead.Trigger_Assignment__c = true;
	        	leads.add(lead);
	        }
	        
	        // These 40 will go to default web trial small
	        for (Integer i = 0; i < 40; i++) {
	        	Lead lead = new Lead();
	        	String random = String.valueOf((Math.random() * 10000000).intValue());
	        	lead.LastName = random;
	        	lead.Email = random + '@duck.com';
	        	lead.Company = random;
	        	lead.Contact_Method__c = ENTRY_VALUE_WEB_TRIAL;
	        	lead.Employees__c = 5;
	        	lead.Trigger_Assignment__c = true;
	        	leads.add(lead);
	        }
	        
	        // These 30 will go to default web trial big
	        for (Integer i = 0; i < 30; i++) {
	        	Lead lead = new Lead();
	        	String random = String.valueOf((Math.random() * 10000000).intValue());
	        	lead.LastName = random;
	        	lead.Email = random + '@duck.com';
	        	lead.Company = random;
	        	lead.Contact_Method__c = ENTRY_VALUE_WEB_TRIAL;
	        	lead.Employees__c = 7000;
	        	lead.Trigger_Assignment__c = true;
	        	leads.add(lead);
	        }
	        
	        // These 40 will go to france web trial small
	        for (Integer i = 0; i < 40; i++) {
	        	Lead lead = new Lead();
	        	String random = String.valueOf((Math.random() * 10000000).intValue());
	        	lead.LastName = random;
	        	lead.Email = random + '@duck.com';
	        	lead.Company = random;
	        	lead.Eloqua_Country_Code__c = 'FR';
	        	lead.Country = 'France';
	        	lead.Contact_Method__c = ENTRY_VALUE_WEB_TRIAL;
	        	lead.Employees__c = 5;
	        	lead.Trigger_Assignment__c = true;
	        	leads.add(lead);
	        }
	        
	        // These 40 will go to france web trial big
	        for (Integer i = 0; i < 40; i++) {
	        	Lead lead = new Lead();
	        	String random = String.valueOf((Math.random() * 10000000).intValue());
	        	lead.LastName = random;
	        	lead.Email = random + '@duck.com';
	        	lead.Company = random;
	        	lead.Eloqua_Country_Code__c = 'FR';
	        	lead.Country = 'France';
	        	lead.Contact_Method__c = ENTRY_VALUE_WEB_TRIAL;
	        	lead.Employees__c = 7000;
	        	lead.Trigger_Assignment__c = true;
	        	leads.add(lead);
	        }
	        
	        // These 3 will go to QA
	        Lead qa = new Lead();
	        qa.LastName = 'qa';
	        qa.Company = 'qa';
	        qa.Email = 'qa@box.com';
	        qa.Trigger_Assignment__c = true;
	        leads.add(qa);        
	        Lead t = new Lead();
	        t.LastName = 'test';
	        t.Company = 'test';
	        t.Email = 'test@test.com';
	        t.Trigger_Assignment__c = true;
	        leads.add(t);        
	        Lead a = new Lead();
	        a.LastName = 'auto';
	        a.Company = 'auto';
	        a.Email = 'boxautomatedqa@auto.com';
	        a.Trigger_Assignment__c = true;
	        leads.add(a);        
	        
	        // These 3 will go to BD
	        Lead s = new Lead();
	        s.LastName = 'source';
	        s.Company = 'source';
	        s.Source_Detail__c = 'Referral Partner';
	        s.Trigger_Assignment__c = true;
	        leads.add(s);
	        Lead p = new Lead();
	        p.LastName = 'program';
	        p.Company = 'program';
	        p.Partner_program_type__c = 'Consulting';
	        p.Trigger_Assignment__c = true;
	        leads.add(p);
	        Lead sp = new Lead();
	        sp.LastName = 'sp';
	        sp.Company = 'sp';
	        sp.Source_Detail__c = 'Partner Application Form';
	        sp.Partner_program_type__c = 'General Inquiry';
	        sp.Trigger_Assignment__c = true;
	        leads.add(sp);
	        
	        // These 4 will go to black hole
	        for (Integer i = 0; i < 4; i++) {
	        	Lead lead = new Lead();
	        	String r = String.valueOf((Math.random() * 10000000).intValue());
	        	lead.LastName = r;
	        	lead.Email = r + '@duck.com';
	        	lead.Company = r;
	        	lead.Contact_Method__c = ENTRY_VALUE_WEB_TRIAL;
	        	lead.Trigger_Assignment__c = true;
	        	leads.add(lead);
	        }
	        
	        leads.sort();
	        insert leads;             
	        
	        test.stopTest();
	        
	        // Now we assert this shizzle bizzatch
	        Map<Id, Territory_Stage_1_Assignment_Rule__c> rules = new Map<Id, Territory_Stage_1_Assignment_Rule__c>();
	        List<Territory_Stage_1_Assignment_Rule__c> rulesList = [SELECT Id, (SELECT Id FROM Routed_Leads__r) FROM Territory_Stage_1_Assignment_Rule__c];
	        rules.putAll(rulesList);
	        
	        // These should have 3        
	        System.debug(System.LoggingLevel.ERROR, 'Territory_TestAssignment: QA rule has ' + rules.get(qaRule.Id).Routed_Leads__r.size() + ' routed leads. Expecting: 3.');
	        System.assertEquals(rules.get(qaRule.Id).Routed_Leads__r.size(), 3);
	        System.debug(System.LoggingLevel.ERROR, 'Territory_TestAssignment: BD rule has ' + rules.get(bdRule.Id).Routed_Leads__r.size() + ' routed leads. Expecting: 3.');
	        System.assertEquals(rules.get(bdRule.Id).Routed_Leads__r.size(), 3);
	        
	        // These should have 4
	        System.debug(System.LoggingLevel.ERROR, 'Territory_TestAssignment: Black hole rule has ' + rules.get(blackHoleRule.Id).Routed_Leads__r.size() + ' routed leads. Expecting: 4');        
	        System.assertEquals(rules.get(blackHoleRule.Id).Routed_Leads__r.size(), 4);
	        
	        // These should have 20
	        System.debug(System.LoggingLevel.ERROR, 'Territory_TestAssignment: Inbound rule has ' + rules.get(inboundRule.Id).Routed_Leads__r.size() + ' routed leads. Expecting: 20.');
	        System.assertEquals(rules.get(inboundRule.Id).Routed_Leads__r.size(), 20);
	        System.debug(System.LoggingLevel.ERROR, 'Territory_TestAssignment: Aussie rule has ' + rules.get(aussieRule.Id).Routed_Leads__r.size() + ' routed leads. Expecting: 20.');
	        System.assertEquals(rules.get(aussieRule.Id).Routed_Leads__r.size(), 20);
	        
	        // These should have 30
	        System.debug(System.LoggingLevel.ERROR, 'Territory_TestAssignment: Default web trial big has ' + rules.get(defaultWebTrialBigEmployeeRule.Id).Routed_Leads__r.size() + ' routed leads. Expecting: 30.');
	        System.assertEquals(rules.get(defaultWebTrialBigEmployeeRule.Id).Routed_Leads__r.size(), 30);
	        
	        // These should have 40
	        System.debug(System.LoggingLevel.ERROR, 'Territory_TestAssignment: Default web trial small has ' + rules.get(defaultWebTrialSmallEmployeeRule.Id).Routed_Leads__r.size() + ' routed leads. Expecting: 40.');
	        System.assertEquals(rules.get(defaultWebTrialSmallEmployeeRule.Id).Routed_Leads__r.size(), 40);
	        System.debug(System.LoggingLevel.ERROR, 'Territory_TestAssignment: France web trial small has ' + rules.get(franceWebTrialSmallEmployeeRule.Id).Routed_Leads__r.size() + ' routed leads. Expecting: 40.');
	        System.assertEquals(rules.get(franceWebTrialSmallEmployeeRule.Id).Routed_Leads__r.size(), 40);
	        System.debug(System.LoggingLevel.ERROR, 'Territory_TestAssignment: France web trial big has ' + rules.get(franceWebTrialBigEmployeeRule.Id).Routed_Leads__r.size() + ' routed leads. Expecting: 40.');
	        System.assertEquals(rules.get(franceWebTrialBigEmployeeRule.Id).Routed_Leads__r.size(), 40);
	        
	        // Assert distribution equality. Everyone should have less than 1 routed lead since there are 50 users per role and less than 50 routed leads per role
	        List<User> usersList = [SELECT Id, Name, UserRole.Name, LastName, (SELECT Id FROM Routed_Lead__r) FROM User WHERE CreatedDate >= YESTERDAY];
	        System.debug(System.LoggingLevel.ERROR, 'Territory_TestAssignment: ' + usersList.size() + ' users queried.');
	        for (User u : usersList) {
	        	if (u.Routed_Lead__r.size() > 1) {
	        		System.debug(System.LoggingLevel.ERROR, 'Territory_TestAssignment: User ' + u.Name + ' (' + u.UserRole.Name + ') has ' + u.Routed_Lead__r.size() + ' routed leads. Expecting 1 at most.');
	        	}
	        	// These people get 3, 3, 4, and 1 at most leads respectively
	        	if (u.LastName.equals(q)) {
        			System.assertEquals(u.Routed_Lead__r.size(), 3);
	        	} else if (u.LastName.equals(b)) {
	        		System.assertEquals(u.Routed_Lead__r.size(), 3);
	        	} else if (u.LastName.equals(bh)) {
	        		System.assertEquals(u.Routed_Lead__r.size(), 4);
	        	} else {	        			        		  
	        		System.assert(u.Routed_Lead__r.size() <= 1, 'Expected size: <1, Actual size: ' + u.Routed_Lead__r.size());
	        	}
	        }
    	}
    }
}