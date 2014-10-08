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
@isTest(SeeAllData=true)
private class LeadAssignmentTestClass2 {
/*
    static testMethod void myUnitTest() {
    	
    	test.startTest();
    	
    	LeadAssignmentSettings__c oldSettings = LeadAssignmentSettings__c.getInstance('default');  
    	if (oldSettings != null) { 
			delete oldSettings;
			System.debug(System.LoggingLevel.ERROR, 'LeadAssignmentTestClass2: Old settings deleted.'); 
		}      
    	
    	LeadAssignmentSettings__c newSettings = new LeadAssignmentSettings__c();
    	newSettings.Name = 'default';
    	newSettings.Routing_Auto_Assign_Owner_Ids__c = '005600000018aQl;00560000001HWN1;00560000001HN53;00560000001uPgI;00560000001IQCx;';
    	newSettings.FCCRM_Auto_assignment_Rules__c = true;
    	newSettings.Emergency_Shutoff_Button_for_Auto_Assign__c = false;
    	
    	newSettings.Default_Lead_Converted_Status__c = 'Qualified - New Opportunity';
    	newSettings.Limits_Max_Routed_Leads_Audit_Days__c = 30;
    	
    	newSettings.Type_Web_Trial_CMMR_Values__c = 'Web Trial;';
    	newSettings.Type_Freemium_CMMR_Values__c = 'Freemium;Lead Gen Activity;';
    	newSettings.Segment_BD_Partner_Program_Values__c = 'Consulting;General Inquiry;Alliance;';
    	newSettings.Segment_BD_Source_Detail_Values__c = 'Referral Partner;';
    	newSettings.Segment_OBR_Major_CMMR_Values__c = 'LeadGen for Major';
    	newSettings.Segment_OBR_Enterprise_CMMR_Values__c = 'LeadGen for Enterprise';
    	newSettings.Segment_Test_Email_Values__c = 'test@;@box.com;@box.net;boxinternalqa;boxstresslive;boxautomatedqa;';
    	newSettings.Segment_International_Country_Codes__c = 'GB;FR;DE;IT;ES;EU;';
    	
    	newSettings.Segment_Corporate_Max_Employees__c = 500;
    	newSettings.Segment_Majors_Max_Employees__c = 5000;
    	newSettings.Tier_C1_Max_Users__c = 5;
    	newSettings.Tier_C2_Max_Users__c = 25;
    	newSettings.Tier_C3_Max_Users__c = 75;
    	newSettings.Tier_C4_Max_Users__c = 300;
    	newSettings.Tier_M1_Max_Users__c = 25;
    	newSettings.Tier_M2_Max_Users__c = 100;
    	newSettings.Tier_Corp_Min_Employees_Boost__c = 100;
    	newSettings.Tier_Corp_Job_Title_Boost_Wildcards__c = 'CEO;CFO;CTO;CIO;COO;CMO;CSO;IT,Dir;Chief,Officer;';
    	
    	newSettings.Routing_Internal_QA_User_Id__c = '005600000018aQl'; 
    	newSettings.Routing_Business_Development_User_Id__c = '00560000001H6hF';
    	newSettings.Routing_International_User_Id__c = '00560000001Huf4';
    	newSettings.Routing_OBR_Major_Role_Identifier__c = 'OBR - NATAM - Major';
    	newSettings.Routing_OBR_Ent_Role_Identifier__c = 'OBR - NATAM - Enterprise';
    	newSettings.Routing_Corporate_Role_Identifier__c = ' AE - NATAM - Corporate';
    	newSettings.Routing_Major_Role_Identifier__c = 'AE - NATAM - Major';
    	newSettings.Routing_Enterprise_Default_User_Id__c = '00560000001HN53';
    	newSettings.Routing_Sales_Ops_Default_User_Id__c = '00560000001HN53';
    	newSettings.Routing_SDR_Role_Identifier__c = 'SDR';
    	
    	newSettings.Ramping_Corporate_Web_Trial_Buckets__c = '0/24;182/64;274/12;';
    	newSettings.Ramping_Corporate_Freemium_Buckets__c = '0/69;182/31;274/0;';
    	newSettings.Ramping_Corporate_Inbound_Buckets__c = '0/3;182/25;274/72;';
    	newSettings.Ramping_Major_Web_Trial_Buckets__c = null;
    	newSettings.Ramping_Major_Freemium_Buckets__c = null;
    	newSettings.Ramping_Major_Inbound_Buckets__c = null;
    	
    	newSettings.Email_Assignment_Rules_Template_Id__c = '00X60000000wM3X';
    	newSettings.Access_Profile_Ids__c = '00e60000000in6T;00e60000000ilfb;00e60000000nlAt;00e60000000idKG;00e60000000imTb;00e60000000idJS;00e60000000inBY;00e60000000inKk;00e60000000inDy';
    	newSettings.Access_Role_Ids__c = null;
    	newSettings.Access_User_Ids__c = null;
    	insert newSettings;
    	System.debug(System.LoggingLevel.ERROR, 'LeadAssignmentTestClass2: New settings inserted.');
    	        
    	// Test 1: Major Inbound
        Lead l = new Lead();
        l.Employees__c = 600;
        l.Contact_Method__c = 'Event';   
        l.Email = 'beepbeep@boopboop.com';  
        l.Upsell_Opportunity__c = true;
        l.Purchase_Time_Frame__c = '< 1 month';
        l.Title = 'CEO';
        l.About_the_Company__c = 'a';
        l.Number_of_Users__c = 120;
        l.Scope_of_Deployment__c = 's';
        l.Number_of_Upsell_Users__c = 10;
        l.FirstName = 'Lo';
        l.LastName = 'Mac';
        l.Company = 'Co Fosho';
        l.Country = 'United States';
        insert l;        
        LeadAssignment.routeLeadWebService(l.Id, UserInfo.getUserId());
        LeadAssignment.determineHowToRouteLead();
        LeadAssignment.assignLeadSegmentForAssignmentRules();
        LeadAssignment.clearVariables();
        LeadAssignment.routeLeadApex(l, UserInfo.getUserId());
        LeadAssignment.clearVariables();               

		LeadAssignment.lead = l;
		l.Email = 'test@test.com';			
		LeadAssignment.assignLeadSegmentForAssignmentRules();
		
		l.Partner_program_type__c = 'Consulting';
		LeadAssignment.assignLeadSegmentForAssignmentRules();
		
		l.Source_Detail__c = 'hi2u';
		LeadAssignment.assignLeadSegmentForAssignmentRules();
		
		l.Contact_Method__c = 'LeadGen for Major';
		LeadAssignment.assignLeadSegmentForAssignmentRules();
		
		l.Contact_Method__c = 'LeadGen for Enterprise';
		LeadAssignment.assignLeadSegmentForAssignmentRules();
		
		Routed_Lead__c r = [SELECT Id FROM Routed_Lead__c WHERE Account__c != null AND Lead__c = null LIMIT 1];
		r.Undo_Reason__c = 'weeeee!';
		update r; 
		LeadAssignment.rerouteInQueue(r.Id);
 
 		test.stopTest();
    }
    */
 	
}