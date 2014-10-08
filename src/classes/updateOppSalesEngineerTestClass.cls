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
private class updateOppSalesEngineerTestClass {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        List<User> users = [SELECT Id FROM User WHERE IsActive = true];
        
        Account a = new Account();
        a.Name = 'Test';
        a.BillingCountry = 'United States';
        a.OwnerId = users[0].Id;
        a.BillingCountry = 'United States';
        insert a;
        
        Contact c = new Contact();
        c.AccountId = a.Id;
        c.LastName = 'Test';
        insert c;
        
        Opportunity o = new Opportunity();
        o.Name = 'Test';
        o.StageName = 'Test';
        o.AccountId = a.Id;
        o.CloseDate = Date.Today();
        insert o;
        System.assert(o.Sales_Engineer_Lookup__c == null);
        
        Sales_Request__c s = new Sales_Request__c();
        s.RecordTypeId = '012600000009VN9';
        s.Dominator__c = a.OwnerId;
        s.Opportunity__c = o.Id;
        s.Request_Type__c = 'Test';
        s.Engagement_Type__c = 'Test';
        s.Additional_Context__c = 'Test';
        s.Market_Segment__c = 'Test';
        s.Severity__c = 'Test';
        insert s;
        
        // Standard case: Insert
        Opportunity insertOppResult = [SELECT Id, Sales_Engineer_Lookup__c FROM Opportunity WHERE Id = :o.Id];
        System.assert(insertOppResult.Sales_Engineer_Lookup__c != null);
        System.assert(insertOppResult.Sales_Engineer_Lookup__c == a.OwnerId);    
                
        s.Dominator__c = users[1].Id;
        update s;        
        
        // Negative case
        Opportunity negativeOppResult = [SELECT Id, Sales_Engineer_Lookup__c FROM Opportunity WHERE Id = :o.Id];
        System.assert(negativeOppResult.Sales_Engineer_Lookup__c != users[1].Id);
                
        o.Sales_Engineer_Lookup__c = null;
        update o;
        
        s.Dominator__c = users[2].Id;
        update s;
        
        // Standard case: Update
        Opportunity updateOppResult = [SELECT Id, Sales_Engineer_Lookup__c FROM Opportunity WHERE Id = :o.Id];
        System.assert(updateOppResult.Sales_Engineer_Lookup__c == users[2].Id);                   
    }
}