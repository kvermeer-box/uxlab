@isTest
private class DebugLogger_Test {

	@isTest static void testNewAccount() {
	
		Debug_Log_Settings__c testSetting = new Debug_Log_Settings__c();
		testSetting.Name = 'Test1';
		testSetting.Enabled__c = true;
		insert testSetting;
		
		DebugLogger.write('Test1', '>>>>>>>> Test <<<<<<<<');
		
		
		
	}

}