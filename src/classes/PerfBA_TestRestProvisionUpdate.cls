@isTest
private class PerfBA_TestRestProvisionUpdate {

	static testMethod void UnitTestPost1() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
	Partner_Key_Account__c lpka = PerfBA_TestData.createpka('XYZ123456',accc.id,acc.id);
	String jsonInput = '{\n' +
		' "enterpriseid":"12345",\n' +
		' "status":"trial",\n' +
		' "partnerkey":"XYZ12345"\n' +
		'}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/provision/update';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	PerfBA_RestProvisionUpdate.doPost();
	Test.stopTest();
		}

 

}