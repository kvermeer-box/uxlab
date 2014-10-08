@isTest
private class Z_IntegrationUtility_Test
{

	@isTest(seeAllData=true)
	static void testUpdateZuoraAccount() {

		Account acct = Z_TestUtils.createAccount(true);
		acct.VAT_ID_Number__c = '123456';
		update acct;

		Z_IntegrationUtility.updateZuoraAccount(acct.Id, 'United States', '111111', '222222');
		Z_IntegrationUtility.updateZuoraAccount(null, null, null, null);

	}	 
 
	@isTest(seeAllData=true)
	static void handleZuoraErrors_failure() {
		
		final String ZUORA_ID = '1234567890';
		final String ERROR_CODE = 'red';
		final String ERROR_MESSAGE = 'blue';

		Zuora.zObject error = new Zuora.zObject('Error');
		error.setValue('Code', ERROR_CODE);
		error.setValue('Message', ERROR_MESSAGE);

		Zuora.zApi.SaveResult saveResult = new Zuora.zApi.SaveResult();
		saveResult.Id = ZUORA_ID;
		saveResult.Success = false;
		saveResult.Errors = new List<Zuora.zObject>{error};

		Test.startTest();
			try {

				Z_IntegrationUtility.handleZuoraErrors(new List<Zuora.zApi.SaveResult>{saveResult});

				system.assert(false, 'On failure, an exception should occur');
			
			} catch(Z_IntegrationUtility.ZuoraUpdateErrorException e) {
				String message = e.getMessage();

				system.assert(message.contains(ZUORA_ID), 'Message should contain the zuora id');
				system.assert(message.contains(ERROR_CODE), 'Message should contain the error code');
				system.assert(message.contains(ERROR_MESSAGE), 'Message should contain the error message');
			}
		Test.stopTest();
	}

	@isTest(seeAllData=true)
	static void handleZuoraErrors_success() {
		
		Zuora.zApi.SaveResult saveResult = new Zuora.zApi.SaveResult();
		saveResult.Id = '1234567890';
		saveResult.Success = true;
		saveResult.Errors = new List<Zuora.zObject>();

		Test.startTest();
			try {
				Z_IntegrationUtility.handleZuoraErrors(new List<Zuora.zApi.SaveResult>{saveResult});
			} catch(Z_IntegrationUtility.ZuoraUpdateErrorException e) {
				system.assert(false, 'On success, no exception should occur: ' + e);
			}

			Z_IntegrationUtility.ZApi zapi = Z_IntegrationUtility.zApi;
			//zapi.zlogin();
			//zapi.zquery('select AccountId from contact'); 
		Test.stopTest();
	} 
 
}