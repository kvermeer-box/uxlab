/**
 * This class contains unit tests for PartnerEventLog_REST.cls
 * 
 *
 */
@isTest
private class PartnerEventLog_REST_Test {

	static testMethod void testPost() {
		RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        // Create Payload
        Box_PartnerEventLog logObj = new Box_PartnerEventLog();
        logObj.customer_account_name = 'testCaseAcctName';
		logObj.customer_emails = new List<String> {'fakeemail@email.com'};
		logObj.operations = new List<Box_PartnerEventLog.Operation> {new Box_PartnerEventLog.Operation('act', 'seat', 'account')};
		logObj.partner_customer_fields = new List<Box_PartnerEventLog.PartnerCustomerField> {new Box_PartnerEventLog.PartnerCustomerField('field', 'value')};
		logObj.partner_customer_id = '123';
		logObj.partner_transaction_id = '133';
		logObj.partner_transaction_timestamp = '04/15/2014 10:36:09-05:00';
		logObj.event_code = '333';
		logObj.event_status = 'success'; //event_type
		logObj.event_message = 'Transaction Message';
		logObj.event_description = 'Description test';
		logObj.partner_name = 'AT&T';
 		String payload = JSON.serialize(logObj);
		req.requestBody = Blob.valueOf(payload);       
        req.requestURI = '/services/apexrest/1.0/events';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        PartnerEventLog_REST.doPost(); 
        
        // negative case
        req.requestBody = Blob.valueOf('234 234 234');
        PartnerEventLog_REST.doPost();
	}
	
}