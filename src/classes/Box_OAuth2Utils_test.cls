@isTest
private class Box_OAuth2Utils_test {
	
	@isTest static void getAuthToken_basic() {
        PRM_Settings__c prmSettings = new PRM_Settings__c(OAuth_Authorization_Endpoint__c = 'www.test.com',
                                                          OAuth_Client_ID__c = 'A123BCD',
                                                          OAuth_Client_Secret__c = 'IMSECRET',
                                                          Name = 'default');
        insert prmSettings;
        Test.startTest();
		Test.setMock(HttpCalloutMock.class, new Box_OAuth2Utils.AuthTokenHTTPCalloutMock());
        String authToken = Box_OAuth2Utils.getAuthToken('0000');
        Test.stopTest();
        System.assertEquals('TestToken',authToken);
	}

}