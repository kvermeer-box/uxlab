@isTest
private class PerfBA_TestRestSuspend {

			static testMethod void UnitTestPost1() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
	Partner_Key_Account__c lpka = PerfBA_TestData.createpka('XYZ123456',accc.id,acc.id);
	PerfBA_TestData.createPRMsetting();
	String jsonInput = '{\n' +
		' "enterpriseid":"12345",\n' +
		' "status":"trial",\n' +
		' "partnerkey":"XYZ12345"\n' +
		'}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/changestatus';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	PerfBA_RestSuspend.doPost();
	Test.stopTest();
		}
			static testMethod void UnitTestPost2() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
	lt.Enterprise_ID_Tenant__c='12345';
	lt.Active_Status__c='deactivated';
	Update lt;
	Partner_Key_Account__c lpka = PerfBA_TestData.createpka('XYZ123456',accc.id,acc.id);
	PerfBA_TestData.createPRMsetting();
	String jsonInput = '{\n' +
		' "enterpriseid":"12345",\n' +
		' "status":"trial",\n' +
		' "partnerkey":"XYZ12345"\n' +
		'}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/changestatus';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	PerfBA_RestSuspend.doPost();
	Test.stopTest();
		}
		/****************************************************************
		static testMethod void UnitTestPost3() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
	Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('1002');
	opportunity opp =PerfBA_TestData.createopp(lt.id, accc.id, acc.id, 'Discovery / Trial','12345');
	
	lt.Enterprise_ID_Tenant__c='12345';
	lt.Active_Status__c='active';
	lt.Plan_Code__c='1002';
	lt.Reseller_ID__c=decimal.valueOf('12345');
	Update lt;
	system.debug('opp'+opp);
	system.debug('lt'+lt);
	Partner_Key_Account__c lpka = PerfBA_TestData.createpka('XYZ123456',accc.id,acc.id);
	PerfBA_TestData.createPRMsetting();
	String jsonInput = '{\n' +
		' "enterpriseid":"12345",\n' +
		' "status":"trial",\n' +
		' "partnerkey":"XYZ12345"\n' +
		'}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/changestatus';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	PerfBA_RestSuspend.doPost();
	Test.stopTest();
		}
		*****************************************************************/
		
		static testMethod void UnitTestPost4() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Contact ct=PerfBA_TestData.createcustomerContact('joe@nik.com',accc.id);
		Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('1002');
	Partner_Plan_Customization__c ppc=	PerfBA_TestData.createPartnerPlanCustomization(pp.id,acc.id);
		PerfBA_TestData.createdisc(ppc.id);
	
	PerfBA_TestData.createPRMsetting();
	
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
	PerfBA_TestData.createopp(lt.id, accc.id, acc.id, 'Closed Won','12345');
	lt.Enterprise_ID_Tenant__c='12345';
	lt.Active_Status__c='active';
	lt.Admin_Name__c='test';
	lt.Deal_Status__c='live_deal';
	lt.Admin__c=ct.id;
		lt.Plan_Code__c='1002';
	lt.Reseller_ID__c=decimal.valueOf('12345');
	Update lt;
	Partner_Key_Account__c lpka = PerfBA_TestData.createpka('XYZ123456',accc.id,acc.id);
	String jsonInput = '{\n' +
		' "enterpriseid":"12345",\n' +
		' "newstatus":"trial",\n' +
		' "partnerkey":"XYZ12345"\n' +
		'}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/changestatus';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	PerfBA_RestSuspend.doPost();
	Test.stopTest();
		}
	static testMethod void UnitTestPost5() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Contact ct=PerfBA_TestData.createcustomerContact('joe@nik.com',accc.id);
	Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('1002');
	Partner_Plan_Customization__c ppc=	PerfBA_TestData.createPartnerPlanCustomization(pp.id,acc.id);
		PerfBA_TestData.createdisc(ppc.id);
	PerfBA_TestData.createPRMsetting();
	
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
	PerfBA_TestData.createopp(lt.id, accc.id, acc.id, 'Closed Won','12345');
	lt.Enterprise_ID_Tenant__c='12345';
	lt.Active_Status__c='active';
	lt.Admin_Name__c='test';
	lt.Deal_Status__c='live_deal';
	lt.Original_Live_Date__c=date.today();
	lt.Admin__c=ct.id;
	lt.Plan_Code__c='1002';
	lt.Reseller_ID__c=decimal.valueOf('12345');
	Update lt;
	Partner_Key_Account__c lpka = PerfBA_TestData.createpka('XYZ123456',accc.id,acc.id);
	String jsonInput = '{\n' +
		' "enterpriseid":"12345",\n' +
		' "newstatus":"trial",\n' +
		' "partnerkey":"XYZ12345"\n' +
		'}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/changestatus';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	PerfBA_RestSuspend.doPost();
	Test.stopTest();
		}	
		static testMethod void UnitTestPost6() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Contact ct=PerfBA_TestData.createcustomerContact('joe@nik.com',accc.id);
	Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('1002');
	Partner_Plan_Customization__c ppc=	PerfBA_TestData.createPartnerPlanCustomization(pp.id,acc.id);
		PerfBA_TestData.createdisc(ppc.id);
	PRM_Settings__c prms=PerfBA_TestData.createPRMsetting();
	prms.Ownerid__c='';
	update prms;
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
	PerfBA_TestData.createopp(lt.id, accc.id, acc.id, 'Closed Won','12345');
	lt.Enterprise_ID_Tenant__c='12345';
	lt.Active_Status__c='active';
	lt.Admin_Name__c='test';
	lt.Deal_Status__c='live_deal';
	lt.Original_Live_Date__c=date.today();
	lt.Admin__c=ct.id;
	lt.Plan_Code__c='1002';
	lt.Reseller_ID__c=decimal.valueOf('12345');
	Update lt;
	Partner_Key_Account__c lpka = PerfBA_TestData.createpka('XYZ123456',accc.id,acc.id);
	String jsonInput = '{\n' +
		' "enterpriseid":"12345",\n' +
		' "newstatus":"trial",\n' +
		' "partnerkey":"XYZ12345"\n' +
		'}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/changestatus';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	PerfBA_RestSuspend.doPost();
	Test.stopTest();
		}	
		static testMethod void UnitTestPost7() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Contact ct=PerfBA_TestData.createcustomerContact('joe@nik.com',accc.id);
	Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('1002');
	Partner_Plan_Customization__c ppc=	PerfBA_TestData.createPartnerPlanCustomization(pp.id,acc.id);
		PerfBA_TestData.createdisc(ppc.id);
	PRM_Settings__c prms=PerfBA_TestData.createPRMsetting();
	prms.Ownerid__c='';
	update prms;
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
	PerfBA_TestData.createopp(lt.id, accc.id, acc.id, 'Closed Won','12345');
	lt.Enterprise_ID_Tenant__c='12345';
	lt.Active_Status__c='active';
	lt.Admin_Name__c='test';
	lt.Deal_Status__c='live_deal';
	lt.Admin__c=ct.id;
	lt.Plan_Code__c='1002';
	lt.Reseller_ID__c=decimal.valueOf('12345');
	Update lt;
	Partner_Key_Account__c lpka = PerfBA_TestData.createpka('XYZ123456',accc.id,acc.id);
	String jsonInput = '{\n' +
		' "enterpriseid":"12345",\n' +
		' "newstatus":"trial",\n' +
		' "partnerkey":"XYZ12345"\n' +
		'}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/changestatus';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	PerfBA_RestSuspend.doPost();
	Test.stopTest();
		}
		/****************************************************************
		
		static testMethod void UnitTestPost8() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
	Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('1002');
	opportunity opp=PerfBA_TestData.createopp(lt.id, accc.id, acc.id, 'Discovery / Trial','12345');
	
	lt.Enterprise_ID_Tenant__c='12345';
	lt.Active_Status__c='active';
	lt.Plan_Code__c='1002';
	lt.Reseller_ID__c=decimal.valueOf('12345');
	Update lt;
	system.debug('opp'+opp);
	system.debug('lt'+lt);
	Partner_Key_Account__c lpka = PerfBA_TestData.createpka('XYZ123456',accc.id,acc.id);
	PRM_Settings__c prms=PerfBA_TestData.createPRMsetting();
	prms.Ownerid__c='';
	update prms;
		String jsonInput = '{\n' +
		' "enterpriseid":"12345",\n' +
		' "status":"trial",\n' +
		' "partnerkey":"XYZ12345"\n' +
		'}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/changestatus';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	PerfBA_RestSuspend.doPost();
	Test.stopTest();
		}
		*****************************************************************/
					
}