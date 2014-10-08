@isTest
private class WebTrialLogServicesTest
{
	static WebTrialRest.WebTrial buildWebTrial()
	{
		WebTrialRest.WebTrial testWebTrial = new WebTrialRest.WebTrial();
		testWebTrial.email = 'test@test.com';
		testWebTrial.enterpriseId = 'test enterpriseId';
		testWebTrial.errorMsg = 'Test Error Msg';
		testWebTrial.statusCode = 'Test status code';
		
		return testWebTrial;
	}

	static void seuptRestContext( String requestBody )
	{
		RestRequest request = new RestRequest();
		request.httpMethod = 'POST';
		request.requestBody = Blob.valueOf( requestBody );
		RestContext.request = request;
	}

	static testMethod void testBuildWebTrialLog()
	{
		WebTrialRest.WebTrial testWebTrial = buildWebTrial();
		
		String expectedRequestBody = JSON.serialize( testWebTrial );
		seuptRestContext( expectedRequestBody );

		Test.startTest();
			Web_Trial_Log__c actualLog = WebTrialLogServices.buildWebTrialLog();
		Test.stopTest();
		
		System.assertEquals( expectedRequestBody, actualLog.Request__c, 'The request should be logged correctly' );
	}

	static testMethod void testSendLogExceptionEmail()
	{
		WebTrialRest.WebTrial testWebTrial = buildWebTrial();
		
		String expectedRequestBody = JSON.serialize( testWebTrial );
		seuptRestContext( expectedRequestBody );

		Test.startTest();
			WebTrialLogServices.sendLogExceptionEmail( 'Dummy Exception', testWebTrial );
		Test.stopTest();

		System.assert( WebTrialLogServices.logExceptionEmailSent, 'The email should have been sent');
	}
}