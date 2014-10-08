@isTest
private class WebTrialLogModelTest {

	static testMethod void testSetErrorFields()
	{
		final String DUMMY_EXCEPTION = 'Test Exception';
		
		WebTrialRest.WebTrial testWebTrial = new WebTrialRest.WebTrial();
		testWebTrial.errorMsg = 'Test Error Msg';
		
		Web_Trial_Log__c testLog = new Web_Trial_Log__c();
		WebTrialLogModel webTrialLogModel = new WebTrialLogModel( testLog );
				
		Test.startTest();
			webTrialLogModel.setErrorFields( DUMMY_EXCEPTION, testWebTrial );
		Test.stopTest();
		
		System.assertEquals( DUMMY_EXCEPTION, webTrialLogModel.currentLog.Exception_Message__c, 'The exception messages should be logged correctly' );
		System.assertEquals( testWebTrial.errorMsg, webTrialLogModel.currentLog.errorMsg__c, 'The error messages in the response should logged correctly' );
		System.assert( !webTrialLogModel.currentLog.Success__c, 'The web trial log should not be marked a success' );
	}

	static testMethod void testSetSuccess()
	{
		Web_Trial_Log__c testLog = new Web_Trial_Log__c();
		WebTrialLogModel webTrialLogModel = new WebTrialLogModel( testLog );
				
		Test.startTest();
			webTrialLogModel.setSuccess();
		Test.stopTest();
		
		System.assert( webTrialLogModel.currentLog.Success__c, 'The web trial log should be marked a success' );
	}

	static testMethod void testSetIdFields()
	{
		final String DUMMY_ACCOUNT_ID = '0011100000xxxxx';
		final String DUMMY_ACCOUNT_NAME = 'accountName';
		final String DUMMY_OPPORTUNITY_ID = '0061100000xxxxx';
		final String DUMMY_OWNER_NAME = 'ownerName';

		WebTrialRest.WebTrial testWebTrial = new WebTrialRest.WebTrial();
		testWebTrial.accountId = DUMMY_ACCOUNT_ID;
		testWebTrial.accountName = DUMMY_ACCOUNT_NAME;
		testWebTrial.opportunityId = DUMMY_OPPORTUNITY_ID;
		testWebTrial.ownerName = DUMMY_OWNER_NAME;

		Web_Trial_Log__c testLog = new Web_Trial_Log__c();
		WebTrialLogModel webTrialLogModel = new WebTrialLogModel( testLog );

		Test.startTest();
			webTrialLogModel.setIdFields( testWebTrial );
		Test.stopTest();
		
		System.assertEquals( DUMMY_ACCOUNT_ID, webTrialLogModel.currentLog.Account__c, 'The web trial log track the accountId' );
		System.assertEquals( DUMMY_ACCOUNT_NAME, webTrialLogModel.currentLog.accountName__c, 'The web trial log should track the account name' );
		System.assertEquals( DUMMY_OPPORTUNITY_ID, webTrialLogModel.currentLog.Opportunity__c, 'The web trial log should track the opportunity Id' );
		System.assertEquals( DUMMY_OWNER_NAME, webTrialLogModel.currentLog.ownerName__c, 'The web trial log should track the owner name' );
	}

	static testMethod void testSetStatusCode()
	{

		WebTrialRest.WebTrial testWebTrial = new WebTrialRest.WebTrial();
		testWebTrial.statusCode = 'Test Code';
		
		Web_Trial_Log__c testLog = new Web_Trial_Log__c();
		WebTrialLogModel webTrialLogModel = new WebTrialLogModel( testLog );
				
		Test.startTest();
			webTrialLogModel.setStatusCode( testWebTrial );
		Test.stopTest();
		
		System.assertEquals( testWebTrial.statusCode, webTrialLogModel.currentLog.statusCode__c, 'The statusCode in the response should logged correctly' );
	}
	
	
	static testMethod void setContactIdTest()
    {
        final Id DUMMY_CONTACT_ID = TestUtils.generateSObjectDummyId( new Contact() );
        Web_Trial_Log__c testLog = new Web_Trial_Log__c();
        WebTrialLogModel webTrialLogModel = new WebTrialLogModel( testLog );
                
        Test.startTest();
            webTrialLogModel.setContactId( DUMMY_CONTACT_ID );
        Test.stopTest();
        
        System.assertEquals( DUMMY_CONTACT_ID, webTrialLogModel.currentLog.Contact__c, 'The contact ID should be added' );
    }

	static testMethod void setLeadIdTest()
	{
        final Id DUMMY_LEAD_ID = TestUtils.generateSObjectDummyId( new Lead() );
        Web_Trial_Log__c testLog = new Web_Trial_Log__c();
        WebTrialLogModel webTrialLogModel = new WebTrialLogModel( testLog );
                
        Test.startTest();
            webTrialLogModel.setLeadId( DUMMY_LEAD_ID );
        Test.stopTest();
        
        System.assertEquals( DUMMY_LEAD_ID, webTrialLogModel.currentLog.Lead__c, 'The lead ID should be added' );
	}

}