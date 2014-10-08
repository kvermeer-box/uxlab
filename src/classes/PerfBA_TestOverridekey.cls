@isTest
private class PerfBA_TestOverridekey {

	static testMethod void UnitTestPost1() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Partner_Key_Account__c lpka = PerfBA_TestData.createpka('XYZ123456',accc.id,acc.id);
	String jsonInput = '{\n' +
		' "oldpartnerkey":"XYZ1234",\n' +
		' "newpartnerkey":"XYZ12345"\n' +
		'}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/provision/overridekey';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	PerfBA_Overridekey.doPost();
	Test.stopTest();
		}
		static testMethod void UnitTestPost2() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Partner_Key_Account__c lpka = PerfBA_TestData.createpka('XYZ123456',accc.id,acc.id);
	String jsonInput = '{\n' +
		' "oldpartnerkey":"XYZ123456",\n' +
		' "newpartnerkey":"XYZ123456"\n' +
		'}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/provision/overridekey';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	PerfBA_Overridekey.doPost();
	Test.stopTest();
		}
		static testMethod void UnitTestPost3() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Partner_Key_Account__c lpka = PerfBA_TestData.createpka('XYZ123456',accc.id,acc.id);
	String jsonInput = '{\n' +
		' "oldpartnerkey":"XYZ123456",\n' +
		' "newpartnerkey":"XYZ1234567"\n' +
		'}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/provision/overridekey';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	PerfBA_Overridekey.doPost();
	Test.stopTest();
		}
}