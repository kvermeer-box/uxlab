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
private class Box_TestDealRegGet {

    static testMethod void myUnitTest() {
    	
    	// Put in custom settings
    	PRM_Settings__c settings = new PRM_Settings__c();
    	settings.Name = 'default';
    	settings.Automatically_Provision_Enterprises__c = false;
    	settings.Automatically_Update_Enterprises__c = true;
    	settings.Box_API_Domain__c = 'https://dev-git.external.inside-box.net/api/';
    	settings.Box_API_Key__c = '6duwdr46mf1dk0nlfr1vtnyqesgs9wzb';
    	settings.Box_API_Version__c = '2.0';
    	settings.Box_Authentication_Token__c = 'vxwvjnb7yca38hgu5f8tik27iylb5sao';
    	settings.Default_Extended_Trial_Length__c = 30;
    	settings.Default_Trial_Length__c = 14;
    	settings.Error_Notification_List__c = 'dliu@box.com;vintage@box.com';
    	settings.Opportunity_Deal_Reg_Record_Type_ID__c = UserInfo.getOrganizationId().contains('00DJ00000007nut') ? '012J0000000CogB' : '012600000009X6c';    
    	insert settings;	
    	
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
        
        Opportunity dealReg = new Opportunity();
		dealReg.Name = a.Name;
		dealReg.AccountId = a.Id;
		dealReg.CloseDate = Date.today();
		dealReg.Amount = 100;
		dealReg.StageName = 'Prospecting';
		dealReg.RecordTypeId = Box_CustomSettings.getOpportunityPartnerRecordTypeId();
		dealReg.Deal_Reg_Approval_Status__c = 'Approved';
		insert dealReg;
		
		OpportunityContactRole ocr = new OpportunityContactRole();
		ocr.ContactId = c.Id;
		ocr.OpportunityId = dealReg.Id;
		ocr.IsPrimary = true;
		insert ocr;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/1.0/dealreg?customer_contact_email=' + EncodingUtil.urlEncode(c.Email, 'UTF-8');
        req.httpMethod = 'GET';
        req.addParameter('customer_contact_email', c.Email);
        RestContext.request = req;
        RestContext.response = res;
        Box_DealRegRest.doGet(); 
        Box_BasicDealReg bdr = (Box_BasicDealReg)JSON.deserialize(res.responseBody.toString(), Box_BasicDealReg.class); 
        System.assert(bdr.customer_contact_email.equals(c.Email));
        
        // Negative test - no enterprise
		try {
			req.requestURI = '/services/apexrest/1.0/dealreg?id=' + EncodingUtil.urlEncode(c.Email, 'UTF-8');
	        Box_EnterpriseRest.doGet();
		} catch (Exception ex) {}
    }
}