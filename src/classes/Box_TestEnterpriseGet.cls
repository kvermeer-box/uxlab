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
private class Box_TestEnterpriseGet {

    static testMethod void myUnitTest() {
    	
        Account a = new Account();
        a.Name = 'Dave\'s BBQ';
        a.RecordTypeId = Box_CustomSettings.getAccountRecordTypeId();
        insert a;
        
        Contact c = new Contact();
        c.FirstName = 'David';
        c.LastName = 'Liu';
        c.AccountId = a.Id;
        c.Email = 'dliu@davesbbq.com';
        insert c;
        
        Tenant__c t = new Tenant__c();
        t.Name = a.Name;
        t.Account__c = a.Id;
        t.Admin__c = c.Id;
        insert t;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/1.0/enterprises?email=' + EncodingUtil.urlEncode(c.Email, 'UTF-8');
        req.httpMethod = 'GET';
        req.addParameter('email', c.Email);
        RestContext.request = req;
        RestContext.response = res;
        Box_EnterpriseRest.doGet();
        Box_BasicSalesTransaction bst = (Box_BasicSalesTransaction)JSON.deserialize(res.responseBody.toString(), Box_BasicSalesTransaction.class);
        
        System.assert(bst.user_login.equals(c.Email));
        
        // Negative test - no enterprise
		try {
			req.requestURI = '/services/apexrest/1.0/enterprises?id=' + EncodingUtil.urlEncode(c.Email, 'UTF-8');
	        Box_EnterpriseRest.doGet();
		} catch (Exception ex) {}
    }
}