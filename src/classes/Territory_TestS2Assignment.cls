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
private class Territory_TestS2Assignment {	

    static Lead americaLead;
    static Lead defaultLead;

    static testMethod void americaTest() {

        setup();
        // Test
        Territory_S2AssignLeads.routeSingleWebService(americaLead.Id);
        
    }

    static testMethod void defaultTest() {
        setup();
        Territory_S2AssignLeads.routeSingleWebService(defaultLead.Id);
    }

    private static void setup() {
        // Custom settings
        TerritorySettings__c settings = new TerritorySettings__c();
        settings.Name = 'default';
        settings.Routed_Leads_History__c = 30;
        settings.Turn_Off_Stage_1_Assignment__c = true; 
        insert settings;
        
        // Territory Employee Segments
        List<Territory_Employee_Segment_Field_Mapping__c> mappings = new List<Territory_Employee_Segment_Field_Mapping__c>();
        Territory_Employee_Segment_Field_Mapping__c esbMapping = new Territory_Employee_Segment_Field_Mapping__c();
        esbMapping.Name                    = 'ESB';
        esbMapping.Max_Employee_Segment__c = '20';
        esbMapping.Rep_Field_API_Name__c   = 'ESB_Rep__c';
        esbMapping.Team_Field_API_Name__c  = 'ESB_Team__c';
        mappings.add(esbMapping);
        Territory_Employee_Segment_Field_Mapping__c corpMapping = new Territory_Employee_Segment_Field_Mapping__c();
        corpMapping.Name                    = 'Corporate';
        corpMapping.Max_Employee_Segment__c = '1000';
        corpMapping.Rep_Field_API_Name__c   = 'Corporate_Rep__c';
        corpMapping.Team_Field_API_Name__c  = 'Corporate_Team__c';
        mappings.add(corpMapping);
        Territory_Employee_Segment_Field_Mapping__c majorMapping = new Territory_Employee_Segment_Field_Mapping__c();
        majorMapping.Name                    = 'Major';
        majorMapping.Max_Employee_Segment__c = '5000';
        majorMapping.Rep_Field_API_Name__c   = 'Major_Rep__c';
        majorMapping.Team_Field_API_Name__c  = 'Major_Team__c';
        mappings.add(majorMapping);
        Territory_Employee_Segment_Field_Mapping__c natMapping = new Territory_Employee_Segment_Field_Mapping__c();
        natMapping.Name                    = 'National';
        natMapping.Max_Employee_Segment__c = 'Unlimited';
        natMapping.Rep_Field_API_Name__c   = 'National_Rep__c';
        natMapping.Team_Field_API_Name__c  = 'National_Team__c';
        mappings.add(natMapping);
        insert mappings;
        
        // Teams        
        Territory_Team__c corpTeam = new Territory_Team__c();
        corpTeam.Name = 'Corporate Reps';
        insert corpTeam;
        
        // Team member roles
        Territory_Team_Member_Role__c corpRole = new Territory_Team_Member_Role__c();
        corpRole.Territory_Team__c = corpTeam.Id;
        corpRole.Role_Name__c = 'Corp';
        insert corpRole;
        
        // Stage 2 assignment rules
        List<Territory_Stage_2_Assignment_Rule__c> rules = new List<Territory_Stage_2_Assignment_Rule__c>();
        Territory_Stage_2_Assignment_Rule__c blackHoleRule = new Territory_Stage_2_Assignment_Rule__c();
        blackHoleRule.Active__c        = true;
        blackHoleRule.Country__c       = '<< Black Hole >>';
        blackHoleRule.ESB_Rep__c       = UserInfo.getUserId();
        blackHoleRule.Corporate_Rep__c = UserInfo.getUserId();
        blackHoleRule.Major_Rep__c     = UserInfo.getUserId();
        blackHoleRule.National_Rep__c  = UserInfo.getUserId();        
        rules.add(blackHoleRule);
        
        Territory_Stage_2_Assignment_Rule__c noReassignmentRule = new Territory_Stage_2_Assignment_Rule__c();
        noReassignmentRule.Active__c         = true;
        noReassignmentRule.Country__c        = '<< No Reassignment >>';
        noReassignmentRule.ESB_Team__c       = corpTeam.Id;
        noReassignmentRule.Corporate_Team__c = corpTeam.Id;
        noReassignmentRule.Major_Team__c     = corpTeam.Id;
        noReassignmentRule.National_Team__c  = corpTeam.Id;        
        rules.add(noReassignmentRule);
        
        Territory_Stage_2_Assignment_Rule__c dupeContactRule = new Territory_Stage_2_Assignment_Rule__c();
        dupeContactRule.Active__c         = true;
        dupeContactRule.Country__c        = '<< Duplicate Contact >>';
        dupeContactRule.ESB_Team__c       = corpTeam.Id;
        dupeContactRule.Corporate_Team__c = corpTeam.Id;
        dupeContactRule.Major_Team__c     = corpTeam.Id;
        dupeContactRule.National_Team__c  = corpTeam.Id;        
        rules.add(dupeContactRule);
        
        Territory_Stage_2_Assignment_Rule__c inactiveUserRule = new Territory_Stage_2_Assignment_Rule__c();
        inactiveUserRule.Active__c         = true;
        inactiveUserRule.Country__c        = '<< Inactive User in Territory >>';
        inactiveUserRule.ESB_Team__c       = corpTeam.Id;
        inactiveUserRule.Corporate_Team__c = corpTeam.Id;
        inactiveUserRule.Major_Team__c     = corpTeam.Id;
        inactiveUserRule.National_Team__c  = corpTeam.Id;        
        rules.add(inactiveUserRule);
        
        Territory_Stage_2_Assignment_Rule__c americaRule = new Territory_Stage_2_Assignment_Rule__c();
        americaRule.Active__c         = true;
        americaRule.Country__c        = 'America';
        americaRule.ESB_Team__c       = corpTeam.Id;
        americaRule.Corporate_Team__c = corpTeam.Id;
        americaRule.Major_Team__c     = corpTeam.Id;
        americaRule.National_Team__c  = corpTeam.Id;        
        rules.add(americaRule);
        insert rules;
        
        // Accounts
        List<Account> accounts = new List<Account>();
        Account routingAccount = new Account();
        routingAccount.Name = 'Routing Account';
        routingAccount.BillingCountry = 'America';
        routingAccount.NumberOfEmployees = 1001;
        accounts.add(routingAccount);
        
        Account convertToAccount = new Account();
        convertToAccount.Name = 'Convert To Account';
        convertToAccount.BillingCountry = 'America';
        convertToAccount.NumberOfEmployees = 1001;
        accounts.add(convertToAccount);
        
        Account defaultAccount = new Account();
        defaultAccount.Name = 'Default Account';
        defaultAccount.BillingCountry = 'O_o';
        defaultAccount.BillingPostalCode = '00000';
        defaultAccount.NumberOfEmployees = 90;
        accounts.add(defaultAccount);
        insert accounts;
        
        // Lead
        List<Lead> leads = new List<Lead>();
        americaLead = new Lead();
        americaLead.LastName = 'Last';
        americaLead.Company = 'Company';
        americaLead.Territory_Routing_Account__c = routingAccount.Id;
        americaLead.Territory_Convert_to_Account__c = convertToAccount.Id;
        americaLead.Status = 'Pending';
        leads.add(americaLead);
        
        defaultLead = new Lead();
        defaultLead.LastName = 'Last';
        defaultLead.Company = 'Company';
        defaultLead.Territory_Routing_Account__c = defaultAccount.Id;
        defaultLead.Territory_Convert_to_Account__c = convertToAccount.Id;
        defaultLead.Status = 'Pending';
        leads.add(defaultLead);
        insert leads;

        // Call Territory_S2RoutingMethod enums
        Territory_S2RoutingMethod routingMethod = Territory_S2RulesFinder.getLeadRoutingMethod(defaultLead);  
        // Get rule
        if (routingMethod == Territory_S2RoutingMethod.CONTACT) {        
        }
        if (routingMethod == Territory_S2RoutingMethod.ACCOUNT_WITH_REASSIGNMENT) {  
        }
        if (routingMethod == Territory_S2RoutingMethod.ACCOUNT_WITHOUT_REASSIGNMENT) {  
        }
    }
}