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
private class Box_TestEnterprisePost {

    static testMethod void myUnitTest() {
    	
    	User user = [SELECT Id, Reseller_ID__c FROM User WHERE IsActive = true AND Reseller_ID__c != null LIMIT 1];
    	
    	String email = (Math.random() * 1000000000000000000L).intValue() + '@rocks.com';
    	String externalAccountId = String.valueOf((Math.random() * 1000000000000000000L).intValue());
    	Integer resellerId = user.Reseller_ID__c.intValue();  //(Math.random() * 1000000000000000000L).intValue();
    	Integer seats = 10;
    	
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
    	settings.Opportunity_Deal_Reg_Record_Type_ID__c = UserInfo.getOrganizationId() == '00DJ00000007nut' ? '012J0000000CogB' : '012600000009X6c';    
    	insert settings;	
    	
    	// Create payload
    	Box_SalesTransaction st = new Box_SalesTransaction();
    	st.partner_id = String.valueOf(resellerId);
    	st.external_account_id = externalAccountId;
    	st.external_contact_id = '7654';
    	st.state = Box_TransactionState.initiate;
    	st.last_transaction_id = 'tid';
    	st.debug_mode = false;
    	Box_Enterprise e = new Box_Enterprise();
    	e.account_type = 'enterprise';
    	e.name = 'Coke';
    	e.space_amount = String.valueOf(10);
    	e.seats = String.valueOf(10);    	
    	e.active_status = 'active';
    	e.billing_cycle = 'monthly';
    	e.deal_status = 'live_deal';
    	e.hide_add_user_ui = false;
    	e.is_silent_mode = false;
    	st.enterprise = e;
    	Box_User u = new Box_User();
    	u.name = 'Johnny';
    	u.login = email;
    	u.phone_number = '4155155151';
    	st.enterprise.administered_by = u;    	
    	String payload = JSON.serialize(st.convertToBasicSalesTransaction());
    	
        Account a = new Account();
        a.Name = 'Dave\'s BBQ';
        a.RecordTypeId = Box_CustomSettings.getAccountRecordTypeId();
        insert a;                
        
        Account partner = new Account();
        partner.Name = 'ATT';
        partner.Reseller_ID__c = resellerId;
        partner.RecordTypeId = Box_CustomSettings.getPartnerResellerRecordTypeId();
        partner.Partner_Price_Per_Seat_Business__c = 15.00;
        partner.Partner_Price_Per_Seat_Enterprise__c = 25.00;
        partner.Partner_Price_Per_Seat_Unlimited__c = 35.00;
		insert partner;
		
		Box_AccountPartnerKeyFactory.upsertPartnerKey(externalAccountId, a.Id);
        
        Contact c = new Contact();
        c.FirstName = 'David';
        c.LastName = 'Liu';
        c.AccountId = a.Id;
        c.Email = email;
        insert c;
        
		Opportunity dealReg = new Opportunity();
		dealReg.Name = a.Name;
		dealReg.AccountId = a.Id;
		dealReg.CloseDate = Date.today();
		dealReg.Amount = 100;
		dealReg.StageName = 'Prospecting';
        dealReg.Line_of_Business_1__c = 'Buying Box is Great!';
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
        
        // Test.setMock(HttpCalloutMock.class, new Box_TestMockResponse(JSON.serialize(st.enterprise)));
        
        req.requestURI = '/services/apexrest/1.0/enterprises/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(payload);
        RestContext.request = req;
        RestContext.response = res;
        Box_EnterpriseRest.doPost();
        System.debug(res.responseBody.toString());
        Box_BasicSalesTransaction bst = (Box_BasicSalesTransaction)JSON.deserialize(res.responseBody.toString(), Box_BasicSalesTransaction.class);		
		System.assert(bst.enterprise_id != null);
		
		// Postitive test - suspend
		st.state = Box_TransactionState.suspend;
		payload = JSON.serialize(st.convertToBasicSalesTransaction());
		req.requestBody = Blob.valueOf(payload);
        Box_EnterpriseRest.doPost();
		
        // Negative test - improper URI
        req.requestURI = 'blah';
        try { 
            Box_EnterpriseRest.doPost();
        } catch (Exception ex) {} 
        req.requestURI = '/services/apexrest/1.0/enterprises/';

        // Negative test - can't deserialize improper JSON
        try { 
            payload = JSON.serialize('blah234');
            req.requestBody = Blob.valueOf(payload);
            Box_EnterpriseRest.doPost();
        } catch (Exception ex) {} 

        // Negative test - can't find tenant from bad enterprise id
        payload = JSON.serialize(st.convertToBasicSalesTransaction());
        try { 
            req.requestBody = Blob.valueOf(payload);
            req.requestURI = '/services/apexrest/1.0/enterprises/' + 'XXX';
            Box_EnterpriseRest.doPost();
        } catch (Exception ex) {} 

        // Negative test - no deal reg
        try {
			st.external_account_id = st.external_account_id + 'z';
			payload = JSON.serialize(st.convertToBasicSalesTransaction());
			req.requestBody = Blob.valueOf(payload);
	        Box_EnterpriseRest.doPost();
        } catch (Exception ex) {}
        
        // Negative test - bad json
        try { 
			payload = JSON.serialize(st.convertToBasicSalesTransaction()) + 'z';
			req.requestBody = Blob.valueOf(payload);
	        Box_EnterpriseRest.doPost();
		} catch (Exception ex) {} 
    }

}