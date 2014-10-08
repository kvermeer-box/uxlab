@isTest
private class Box_PartnerEventLog_Test {

	static Box_PartnerEventLog eventLog;
	static Box_PartnerEventLog.Operation oper;
	static Box_PartnerEventLog.PartnerCustomerField pcf;
	static Box_PartnerEventLog.PartnerRepField pRep;
	
	@isTest
	static void setup() {
		eventLog = new Box_PartnerEventLog();
		eventLog.customer_account_name = 'cas';
		eventLog.customer_emails = new List<String> {'sd'};
		oper = new Box_PartnerEventLog.Operation('act', 'seat', 'account');
    	pcf = new Box_PartnerEventLog.PartnerCustomerField('name', 'val');
    	pRep = new Box_PartnerEventLog.PartnerRepField('id123', 'email@email.com');
		eventLog.operations = new List<Box_PartnerEventLog.Operation> {oper, null};
		eventLog.partner_customer_fields = new List<Box_PartnerEventLog.PartnerCustomerField> {pcf, null};
		eventLog.partner_reps = new List<Box_PartnerEventLog.PartnerRepField> {pRep, null};
		eventLog.partner_customer_id = 'id';
		eventLog.partner_transaction_id = 'id2';
		eventLog.partner_transaction_timestamp = '04/15/2014 10:36:09-05:00';
		eventLog.event_code = '32';
		eventLog.event_status = '22'; 
		eventLog.event_message = 'msg';
		eventLog.event_description = 'desc';
		eventLog.partner_name = 'AT&T';
	}
	
	@isTest
    static void testMethods() {
    	
    	setup();
    	//customer email
    	eventLog.customer_emails = null;
    	eventLog.getCustomerEmailsList();
    	eventLog.customer_emails = new List<String> {'sd', 'e2'};
    	eventLog.getCustomerEmailsList();
    	
    	// partner keys
    	eventLog.constructPartnerCustomerFieldMap();
    	eventLog.getPartnerKey1();
    	eventLog.getPartnerKey2();
    	eventLog.getPartnerKey3();
    	
    	// operations
    	eventLog.operations = null;
    	eventLog.getOperationsList();
    	eventLog.operations = new List<Box_PartnerEventLog.Operation> {oper, null};
    	eventLog.getOperationsList();
    	
    	// transaction time
    	eventLog.partner_transaction_timestamp = null;
    	eventLog.getPartnerTransactionDatetime();
    	//unexpected format timestamp from ATT
    	eventLog.partner_transaction_timestamp = '04/15/201410:36:09-05:00';
    	eventLog.getPartnerTransactionDatetime();
    	//unexpected timestamp, unable to deserialize
    	eventLog.partner_transaction_timestamp = '04/15/2014 zz';
    	eventLog.getPartnerTransactionDatetime();
    	eventLog.partner_transaction_timestamp = '33 10';
    	eventLog.getPartnerTransactionDatetime();
    	eventLog.partner_transaction_timestamp = '04/15/2014 10:36:09-05:00';
    	eventLog.getPartnerTransactionDatetime();
    	
    	// reseller ID
    	eventLog.getResellerID();
    	
    	// partner name
    	eventLog.getPartnerName();
    	eventLog.partner_name = null;
    	eventLog.getPartnerName();
    	
    	//partner rep info
    	eventLog.getPartnerRepsInfo();
    	eventLog.partner_reps = null;
    	eventLog.getPartnerRepsInfo();
    }
	
}