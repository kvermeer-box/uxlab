@RestResource(urlMapping='/1.0/events/*')
global with sharing class PartnerEventLog_REST {

	@HttpPost
	/**
	 * Form Partner_Event_Log object from incoming request.
	 * Then, insert to sfdc.
	 */
	global static void doPost() {
		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;
		String requestBody = req.requestBody.toString(); 
		
		// Debug request
		System.debug('Http POST received.');
		System.debug('Body: ' + requestBody); 
		
		// Deserialize
		Partner_Event_Log__c partnerEventLog = new Partner_Event_Log__c();
		Box_PartnerEventLog pLog;
		JSONParser parser = JSON.createParser(requestBody);
		try {
			pLog = (Box_PartnerEventLog)parser.readValueAs(Box_PartnerEventLog.class);
		} catch (Exception e) {
			res.statusCode = 400;
			res.responseBody = Box_GenericError.parseGenericException(e);
			return;
		}

		partnerEventLog = insertPartnerEventLog(pLog, partnerEventLog);
		
		// Return
		String response = JSON.serialize(partnerEventLog);
		System.debug('PartnerEventLog_Rest: Status code: ' + res.statusCode);
		System.debug('PartnerEventLog_Rest: Response body: ' + response);
		res.responseBody = Blob.valueOf(response);
	}
	
	global static Partner_Event_Log__c insertPartnerEventLog(Box_PartnerEventLog pLog, Partner_Event_Log__c partnerEventLog) {
		pLog.constructPartnerCustomerFieldMap();
		partnerEventLog.Customer_Account_Name__c = pLog.customer_account_name;
		partnerEventLog.Customers_Emails__c = pLog.getCustomerEmailsList();
		partnerEventLog.Partners_Unique_Customer_ID__c = pLog.partner_customer_id;
		partnerEventLog.Partner_Key_1__c = pLog.getPartnerKey1();
		partnerEventLog.Partner_Key_2__c = pLog.getPartnerKey2();
		partnerEventLog.Partner_Key_3__c = pLog.getPartnerKey3();
		partnerEventLog.Partner_Transaction_ID__c = pLog.partner_transaction_id;
		partnerEventLog.Partner_Transaction_Date_Time__c = pLog.getPartnerTransactionDatetime();
		partnerEventLog.Operation__c = pLog.getOperationsList();
		partnerEventLog.Event_Type__c = pLog.event_status;
		partnerEventLog.Error_Code__c = pLog.event_code;
		partnerEventLog.Event_Message__c = pLog.event_message;
		partnerEventLog.Event_Description__c = pLog.event_description;
		partnerEventLog.Partner_Name__c = pLog.getPartnerName();
		partnerEventLog.Reseller_ID__c = pLog.getResellerID();
		partnerEventLog.Partner_Rep_Information__c = pLog.getPartnerRepsInfo();
		insert partnerEventLog;
		
		return partnerEventLog;
	}
	
	
}