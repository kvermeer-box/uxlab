@isTest
private class PerfBA_TestGetEnterpriseId {

		static testMethod void myUnitTestget1() {

	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
	Partner_Key_Account__c lpka = PerfBA_TestData.createpka('XYZ123456',accc.id,acc.id);
	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/getenterpriseid/';  //Request URL
	req.httpMethod = 'Get';//HTTP Request Type
	req.addParameter('partnerkey','XYZ12345');
	RestContext.request = req;
	RestContext.response= res;
	PerfBA_GetEnterpriseId.getEnterpriseId();
	Test.stopTest();
		}
	static testMethod void myUnitTestget2() {

	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Partner_Key_Account__c lpka = PerfBA_TestData.createpka('XYZ12345',accc.id,acc.id);
	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/getenterpriseid/';  //Request URL
	req.httpMethod = 'Get';//HTTP Request Type
	req.addParameter('partnerkey','XYZ12345');
	RestContext.request = req;
	RestContext.response= res;
	PerfBA_GetEnterpriseId.getEnterpriseId();
	Test.stopTest();
		}
			static testMethod void myUnitTestget3() {

	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Partner_Key_Account__c lpka = PerfBA_TestData.createpka('XYZ12345',accc.id,acc.id);
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
	lt.Enterprise_ID_Tenant__c='12345';
	lt.Active_Status__c='trial';
	Update lt;
	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/getenterpriseid/';  //Request URL
	req.httpMethod = 'Get';//HTTP Request Type
	req.addParameter('partnerkey','XYZ12345');
	RestContext.request = req;
	RestContext.response= res;
	PerfBA_GetEnterpriseId.getEnterpriseId();
	Test.stopTest();
		}



}