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
private class LeadAssignmentTestClass {

    static testMethod void myUnitTest() {
    	// Test 1: Corporate Web Trial
        Lead l = new Lead();
        l.Employees__c = 120;
        l.Contact_Method__c = 'Business Web Trial';
        l.Email = 'beep@boop.com';
        l.Upsell_Opportunity__c = true;
        l.Purchase_Time_Frame__c = '< 1 month';
        l.Title = 'CEO';
        l.Business_Web_Trial__c = false;
        l.About_the_Company__c = 'a';
        l.Number_of_Users__c = 12;
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
        
        // Test 2: Corporate Freemium
        l.Contact_Method__c = 'Freemium';
        l.Business_Web_Trial__c = false;
        l.Email = 'beepbeep@boop.com';
        update l;        
        LeadAssignment.routeLeadWebService(l.Id, UserInfo.getUserId());
        LeadAssignment.clearVariables();        
        
    }

}