@isTest
private class PartnerEventLogEmailHandler_Test {

	static testMethod void testHandleInbound() {
		PartnerEventLogEmailHandler handler = new PartnerEventLogEmailHandler();
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
 		
		Messaging.inboundEmail inEmail = new Messaging.inboundEmail();
		inEmail.plainTextBody =  payload;
		handler.handleInboundEmail(inEmail, new Messaging.InboundEnvelope());
		
		//negative case
		inEmail.plainTextBody = '234 234 234';
		handler.handleInboundEmail(inEmail, new Messaging.InboundEnvelope());
	}

}