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
private class Box_TestSyncingEnterprise {

    static testMethod void myUnitTest() {
        String email = (Math.random() * 1000000000000000000L).intValue() + '@box.com';
    	Integer seats = 10;
    	
        Account a = new Account();
        a.Name = 'Dave\'s BBQ';
        a.RecordTypeId = Box_CustomSettings.getAccountRecordTypeId();
        insert a;
        
        Contact c = new Contact();
        c.FirstName = 'David';
        c.LastName = 'Liu';
        c.AccountId = a.Id;
        c.Email = email;
        insert c;
		
		Tenant__c t = new Tenant__c();
		t.Name = a.Name;
		t.Account__c = a.Id;
		t.Admin__c = c.Id;
		t.Enterprise_ID_Tenant__c = '12345';
		insert t;
		
		// Create
		Box_SyncingEnterprise.futureCreate(t.Id);
		
		// Edit
		Box_SyncingEnterprise.futureEdit(t.Id);
		
		// Read
		Box_SyncingEnterprise.readFromId(t.Id);
		
		// Constructor
		Box_SyncingEnterprise b = new Box_SyncingEnterprise(t);
		
		// Destroy
		b.destroy();
    }
}