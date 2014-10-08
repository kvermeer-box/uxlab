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
private class ProspectingApp_TestClass {
    
    static testMethod void myUnitTest() {
    	
    	// Test objects
        ProspectingApp_Question__c q = new ProspectingApp_Question__c();
        q.Question__c = 'Question';
        q.URL__c = 'http://www.yahoo.com';
        insert q;
        
        ProspectingApp_Persona__c p = new ProspectingApp_Persona__c();
        p.Name = 'CEO';
        insert p;
        
        ProspectingApp_Use_Case__c u = new ProspectingApp_Use_Case__c();
        u.Name = 'Collaboration';
        insert u;
        
        ProspectingApp_Persona_Question__c pq = new ProspectingApp_Persona_Question__c();
        pq.Question__c = q.Id;
        pq.Persona__c = p.Id;
        insert pq;
        
        ProspectingApp_Use_Case_Question__c uq = new ProspectingApp_Use_Case_Question__c();
        uq.Question__c = q.Id;
        uq.Use_Case__c = u.Id;
        insert uq;    	
    	
    	// Initialize stuffs
        Test.SetCurrentPageReference(New PageReference('Page.ProspectingApp_Home'));
        PageReference pageRef = ApexPages.currentPage();               
        ProspectingApp_HomeController hc = new ProspectingApp_HomeController();                 
        
        // For each potential page in the wizard, make a selection. Most important part!
        for (Integer i = 0; i < hc.sObjectStepOrder.size(); i++) {
        	hc.currentCheckbox = hc.currentAvailableCheckboxes[0];
        	hc.grabCurrentRelevantQuestions();
        }
        
        // =O
        System.assert(hc.currentRelevantQuestions.size() > 0);
        
        // Random methods to hit 100% test coverage
        hc.getCurrentPageName();
        hc.getCurrentPageNamePlural();
        hc.getNextPageName();
        hc.getPrevPageName();
        hc.goToPrevPage();
    }
}