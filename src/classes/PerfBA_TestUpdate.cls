@isTest
private class PerfBA_TestUpdate {
	
			static testMethod void UnitTestPost1() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
	Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('1002');
	lt.Enterprise_ID_Tenant__c='e12345';
	lt.Active_Status__c='trial';
	lt.Partner_Plan__c=pp.id;
	lt.Trial_Start_Date__c=date.today().addDays(2);
	Update lt;
	    String jsonInput = '{\n' +
	    ' "enterpriseid":"e12345",\n' +
        ' "partnerid":"123456",\n' +
        ' "plancode":"1002",\n' +
        ' "dealstatus":"live_deal",\n' +
         ' "companyname":"Test",\n' +
         ' "street":"Test",\n' +
         ' "city":"Test",\n' +
         ' "country":"Test",\n' +
         ' "zip":"50309",\n' +
         ' "employees":"12",\n' +
         ' "seats":"3",\n' +
    ' "account": ' +
            '{ "firstname":"Joe" , ' +
                '"lastname":"Nik" , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345",\n' +
        ' "activestatus":"active"\n' +
        '}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/update';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	PerfBA_Update.boxAPIUpdates();
	Test.stopTest();
		}
		
				static testMethod void UnitTestPost2() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
	Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('1002');

	lt.Enterprise_ID_Tenant__c='e12345';
	lt.Active_Status__c='trial';
	lt.Partner_Plan__c=pp.id;
	lt.Trial_Start_Date__c=date.today().addDays(2);
	Update lt;
	    String jsonInput = '{\n' +
	    ' "enterpriseid":"e123456",\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"1002",\n' +
        ' "dealstatus":"live_deal",\n' +
         ' "companyname":"Test",\n' +
         ' "street":"Test",\n' +
         ' "city":"Test",\n' +
         ' "country":"Test",\n' +
         ' "zip":"50309",\n' +
         ' "employees":"12",\n' +
         ' "seats":"3",\n' +
    ' "account": ' +
            '{ "firstname":"Joe" , ' +
                '"lastname":"Nik" , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345",\n' +
        ' "activestatus":"active"\n' +
        '}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/update';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	PerfBA_Update.boxAPIUpdates();
	Test.stopTest();
		}
    
		static testMethod void UnitTestPost3() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
		Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('1002');

	lt.Enterprise_ID_Tenant__c='e12345';
	lt.Active_Status__c='deactivated';
	lt.Partner_Plan__c=pp.id;
	lt.Deal_Status__c='trial';
	lt.Trial_Start_Date__c=date.today().addDays(2);
	Update lt;
	    String jsonInput = '{\n' +
	    ' "enterpriseid":"e12345",\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"1002",\n' +
        ' "dealstatus":"trial",\n' +
        ' "trialenddate":"'+Datetime.now().format('MM/dd/yyyy')+'",\n' +
         ' "companyname":"Test",\n' +
         ' "street":"Test",\n' +
         ' "city":"Test",\n' +
         ' "country":"Test",\n' +
         ' "zip":"50309",\n' +
         ' "employees":"12",\n' +
         ' "seats":"3",\n' +
    ' "account": ' +
            '{ "firstname":"Joe" , ' +
                '"lastname":"Nik" , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345",\n' +
        ' "activestatus":"active"\n' +
        '}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/update';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	PerfBA_Update.boxAPIUpdates();
	Test.stopTest();
		}
		 static testMethod void UnitTestPost4() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
	Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('1002');

	lt.Enterprise_ID_Tenant__c='e12345';
	lt.Active_Status__c='active';
	lt.Partner_Plan__c=pp.id;
	lt.Deal_Status__c='trial';
	lt.Trial_Start_Date__c=date.today().addDays(2);
	Update lt;
	    String jsonInput = '{\n' +
	    ' "enterpriseid":"e12345",\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"1002",\n' +
        ' "dealstatus":"trial",\n' +
        ' "trialenddate":"'+Datetime.now().addDays(6).format('MM/dd/yyyy')+'",\n' +
         ' "companyname":"Test",\n' +
         ' "street":"Test",\n' +
         ' "city":"Test",\n' +
         ' "country":"Test",\n' +
         ' "zip":"50309",\n' +
         ' "employees":"12",\n' +
         ' "seats":"3",\n' +
    ' "account": ' +
            '{ "firstname":"Joe" , ' +
                '"lastname":"Nik" , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345",\n' +
        ' "activestatus":"active"\n' +
        '}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/update';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	PerfBA_Update.boxAPIUpdates();
	Test.stopTest();
		} 
				 static testMethod void UnitTestPost41() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
	Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('1002');

	lt.Enterprise_ID_Tenant__c='e12345';
	lt.Active_Status__c='active';
	lt.Partner_Plan__c=pp.id;
	lt.Deal_Status__c='trial';
	lt.Trial_Start_Date__c=date.today().addDays(2);
	Update lt;
	    String jsonInput = '{\n' +
	    ' "enterpriseid":"e12345",\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"1002",\n' +
        ' "dealstatus":"trial",\n' +
        ' "trialenddate":"'+Datetime.now().format('MM/dd/yyyy')+'",\n' +
         ' "companyname":"Test",\n' +
         ' "street":"Test",\n' +
         ' "city":"Test",\n' +
         ' "country":"Test",\n' +
         ' "zip":"50309",\n' +
         ' "employees":"12",\n' +
         ' "seats":"3",\n' +
    ' "account": ' +
            '{ "firstname":"Joe" , ' +
                '"lastname":"Nik" , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345",\n' +
        ' "activestatus":"active"\n' +
        '}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/update';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	PerfBA_Update.boxAPIUpdates();
	Test.stopTest();
		} 
				 static testMethod void UnitTestPost42() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
	Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('1002');

	lt.Enterprise_ID_Tenant__c='e12345';
	lt.Active_Status__c='active';
	lt.Partner_Plan__c=pp.id;
	lt.Deal_Status__c='trial';
	lt.Trial_Start_Date__c=date.today().addDays(2);
	Update lt;
	    String jsonInput = '{\n' +
	    ' "enterpriseid":"e12345",\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"1002",\n' +
        ' "dealstatus":"trial",\n' +
         ' "companyname":"Test",\n' +
         ' "street":"Test",\n' +
         ' "city":"Test",\n' +
         ' "country":"Test",\n' +
         ' "zip":"50309",\n' +
         ' "employees":"12",\n' +
         ' "seats":"3",\n' +
    ' "account": ' +
            '{ "firstname":"Joe" , ' +
                '"lastname":"Nik" , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345",\n' +
        ' "activestatus":"active"\n' +
        '}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/update';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	PerfBA_Update.boxAPIUpdates();
	Test.stopTest();
		} 
		static testMethod void UnitTestPost5() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
	Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('1002');

	lt.Enterprise_ID_Tenant__c='e12345';
	lt.Active_Status__c='trial';
	lt.Partner_Plan__c=pp.id;
	lt.Trial_Start_Date__c=date.today().addDays(2);
	Update lt;
	    String jsonInput = '{\n' +
	    ' "enterpriseid":"e12345",\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"1002",\n' +
        ' "dealstatus":"live_deal",\n' +
         ' "companyname":"Test",\n' +
         ' "street":"Test",\n' +
         ' "city":"Test",\n' +
         ' "country":"Test",\n' +
         ' "zip":"50309",\n' +
         ' "employees":"12",\n' +
         ' "seats":"3",\n' +
    ' "account": ' +
            '{ "firstname":"Joe" , ' +
                '"lastname":"Nik" , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345",\n' +
        ' "activestatus":"active"\n' +
        '}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/update';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	PerfBA_Update.boxAPIUpdates();
	System.debug('***'+res.responseBody.toString());
	Test.stopTest();
		}
		
		static testMethod void UnitTestPost6() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
	Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('1002');
	PerfBA_TestData.createPartnerPlanCustomization(pp.id,acc.id);
	lt.Enterprise_ID_Tenant__c='e12345';
	lt.Active_Status__c='trial';
	lt.Partner_Plan__c=pp.id;
	lt.plan_code__c='1002';
	lt.Trial_Start_Date__c=date.today().addDays(2);
	Update lt;
	    String jsonInput = '{\n' +
	    ' "enterpriseid":"e12345",\n' +
        ' "partnerid":"12345",\n' +
         ' "dealstatus":"live_deal",\n' +
         ' "companyname":"Test",\n' +
         ' "street":"Test",\n' +
         ' "city":"Test",\n' +
         ' "country":"Test",\n' +
         ' "zip":"50309",\n' +
         ' "employees":"12",\n' +
         ' "seats":"3",\n' +
    ' "account": ' +
            '{ "firstname":"Joe" , ' +
                '"lastname":"Nik" , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345",\n' +
        ' "activestatus":"active"\n' +
        '}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/update';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	try{
	PerfBA_Update.boxAPIUpdates();
		System.debug('***'+res.responseBody.toString());
	
	} catch (Exception e) {
		
	}
	Test.stopTest();
		}
		
		static testMethod void UnitTestPost7() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
	//Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('1002');
	//PerfBA_TestData.createPartnerPlanCustomization(pp.id,acc.id);
	lt.Enterprise_ID_Tenant__c='e12345';
	lt.Active_Status__c='active';
	//lt.Partner_Plan__c=pp.id;
	lt.Trial_Start_Date__c=date.today().addDays(2);
	Update lt;
	    String jsonInput = '{\n' +
	    ' "enterpriseid":"e12345",\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"1002",\n' +
        ' "dealstatus":"live_deal",\n' +
         ' "companyname":"Test",\n' +
         ' "street":"Test",\n' +
         ' "city":"Test",\n' +
         ' "country":"Test",\n' +
         ' "zip":"50309",\n' +
         ' "employees":"12",\n' +
         ' "seats":"3",\n' +
    ' "account": ' +
            '{ "firstname":"Joe" , ' +
                '"lastname":"Nik" , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345",\n' +
        ' "activestatus":"active"\n' +
        '}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/update';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	try{
	PerfBA_Update.boxAPIUpdates();
			System.debug('***'+res.responseBody.toString());
	
	} catch (Exception e) {
					System.debug('***'+e);
		
	}
	Test.stopTest();
		}
		
			
		static testMethod void UnitTestPost8() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
	Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('1002');
	PerfBA_TestData.createPartnerPlanCustomization(pp.id,acc.id);
	PerfBA_TestData.createopp(lt.id, accc.id, acc.id, 'Closed Won','e12345');
	Campaign lc = PerfBA_TestData.createcampaign();
	PerfBA_TestData.createsetting(lc.id);
	PerfBA_TestData.createPRMsetting();
	lt.Enterprise_ID_Tenant__c='e12345';
	lt.Active_Status__c='active';
	lt.Partner_Plan__c=pp.id;
	Update lt;
	    String jsonInput = '{\n' +
	    ' "enterpriseid":"e12345",\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"1002",\n' +
        ' "dealstatus":"live_deal",\n' +
         ' "companyname":"Test",\n' +
         ' "street":"Test",\n' +
         ' "city":"Test",\n' +
         ' "country":"Test",\n' +
         ' "zip":"50309",\n' +
         ' "employees":"12",\n' +
         ' "seats":"3",\n' +
    ' "account": ' +
            '{ "firstname":"Joe" , ' +
                '"lastname":"Nik" , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345",\n' +
        ' "activestatus":"active"\n' +
        '}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/update';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	try{
	PerfBA_Update.boxAPIUpdates();
			System.debug('***'+res.responseBody.toString());
	
	} catch (Exception e) {
							System.debug('***'+e);
		
	}
	Test.stopTest();
		}
		static testMethod void UnitTestPost9() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
	Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('1002');
	PerfBA_TestData.createPartnerPlanCustomization(pp.id,acc.id);
	PerfBA_TestData.createopp(lt.id, accc.id, acc.id, 'Closed Won','e12345');
	lt.Active_Status__c='active';
	lt.Partner_Plan__c=pp.id;
	lt.Enterprise_ID_Tenant__c='e12345';
	Update lt;
	Campaign lc = PerfBA_TestData.createcampaign();
	PerfBA_TestData.createsetting(lc.id);
	PerfBA_TestData.createPRMsetting();
		
	    String jsonInput = '{\n' +
	    ' "enterpriseid":"e12345",\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"1002",\n' +
        ' "dealstatus":"live_deal",\n' +
         ' "companyname":"Test",\n' +
         ' "street":"Test",\n' +
         ' "city":"Test",\n' +
         ' "country":"Test",\n' +
         ' "zip":"50309",\n' +
         ' "employees":"12",\n' +
         ' "seats":"10",\n' +
    ' "account": ' +
            '{ "firstname":"Joe" , ' +
                '"lastname":"Nik" , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345",\n' +
        ' "activestatus":"active"\n' +
        '}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/update';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	try{
	PerfBA_Update.boxAPIUpdates();
			System.debug('***'+res.responseBody.toString());
	
	} catch (Exception e) {
							System.debug('***'+e);
		
	}
	Test.stopTest();
		}
			static testMethod void UnitTestPostConvert() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
	Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('1002');
	Partner_Plan_Customization__c ppc=PerfBA_TestData.createPartnerPlanCustomization(pp.id,acc.id);
	PerfBA_TestData.createdisc(ppc.id);
	PerfBA_TestData.createopp(lt.id, accc.id, acc.id, 'Closed Won','e12345');
	lt.Active_Status__c='active';
	lt.Partner_Plan__c=pp.id;
	lt.Enterprise_ID_Tenant__c='e12345';
	lt.Deal_Status__c='trial';
	Update lt;
	Campaign lc = PerfBA_TestData.createcampaign();
	PerfBA_TestData.createsetting(lc.id);
	PerfBA_TestData.createPRMsetting();
		
	    String jsonInput = '{\n' +
	    ' "enterpriseid":"e12345",\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"1002",\n' +
        ' "dealstatus":"live_deal",\n' +
         ' "companyname":"Test",\n' +
         ' "street":"Test",\n' +
         ' "city":"Test",\n' +
         ' "country":"Test",\n' +
         ' "zip":"50309",\n' +
         ' "employees":"12",\n' +
         ' "seats":"10",\n' +
    ' "account": ' +
            '{ "firstname":"Joe" , ' +
                '"lastname":"Nik" , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345",\n' +
        ' "activestatus":"active"\n' +
        '}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/update';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	try{
	PerfBA_Update.boxAPIUpdates();
			System.debug('***'+res.responseBody.toString());
	
	} catch (Exception e) {
							System.debug('***'+e);
		
	}
	Test.stopTest();
		}
		static testMethod void UnitTestPostupgrade() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
	Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('1002');
	Partner_Plan_Customization__c ppc=PerfBA_TestData.createPartnerPlanCustomization(pp.id,acc.id);
	PerfBA_TestData.createdisc(ppc.id);	
	PerfBA_TestData.createopp(lt.id, accc.id, acc.id, 'Closed Won','e12345');
	lt.Active_Status__c='active';
	lt.Partner_Plan__c=pp.id;
	lt.Enterprise_ID_Tenant__c='e12345';
	lt.Deal_Status__c='live_deal';
	lt.Plan_Code__c='1002';
	lt.Seats_Allocated__c=5;
	Update lt;
	Campaign lc = PerfBA_TestData.createcampaign();
	PerfBA_TestData.createsetting(lc.id);
	PerfBA_TestData.createPRMsetting();
		
	    String jsonInput = '{\n' +
	    ' "enterpriseid":"e12345",\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"1002",\n' +
        ' "dealstatus":"live_deal",\n' +
         ' "companyname":"Test",\n' +
         ' "street":"Test",\n' +
         ' "city":"Test",\n' +
         ' "country":"Test",\n' +
         ' "zip":"50309",\n' +
         ' "employees":"12",\n' +
         ' "seats":"10",\n' +
    ' "account": ' +
            '{ "firstname":"Joe" , ' +
                '"lastname":"Nik" , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345",\n' +
        ' "billingcycle":"year",\n' +
        ' "activestatus":"active"\n' +
        '}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/update';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	try{
	PerfBA_Update.boxAPIUpdates();
			System.debug('***'+res.responseBody.toString());
	
	} catch (Exception e) {
							System.debug('***'+e);
		
	}
	Test.stopTest();
		}
		static testMethod void UnitTestPostdowngrade() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
	Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('1002');
	Partner_Plan_Customization__c ppc=PerfBA_TestData.createPartnerPlanCustomization(pp.id,acc.id);
	PerfBA_TestData.createdisc(ppc.id);
	PerfBA_TestData.createopp(lt.id, accc.id, acc.id, 'Closed Won','e12345');
	lt.Active_Status__c='active';
	lt.Partner_Plan__c=pp.id;
	lt.Enterprise_ID_Tenant__c='e12345';
	lt.Deal_Status__c='live_deal';
	lt.Plan_Code__c='1002';
	lt.Seats_Allocated__c=5;
	Update lt;
	Campaign lc = PerfBA_TestData.createcampaign();
	PerfBA_TestData.createsetting(lc.id);
	PerfBA_TestData.createPRMsetting();
		
	    String jsonInput = '{\n' +
	    ' "enterpriseid":"e12345",\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"1002",\n' +
        ' "dealstatus":"live_deal",\n' +
         ' "companyname":"Test",\n' +
         ' "street":"Test",\n' +
         ' "city":"Test",\n' +
         ' "country":"Test",\n' +
         ' "zip":"50309",\n' +
         ' "employees":"12",\n' +
         ' "seats":"3",\n' +
    ' "account": ' +
            '{ "firstname":"Joe" , ' +
                '"lastname":"Nik" , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345",\n' +
        ' "activestatus":"active"\n' +
        '}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/update';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	try{
	PerfBA_Update.boxAPIUpdates();
			System.debug('***'+res.responseBody.toString());
	
	} catch (Exception e) {
							System.debug('***'+e);
		
	}
	Test.stopTest();
		}
		static testMethod void UnitTestPostsamemonth() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
	Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('1002');
	Partner_Plan_Customization__c ppc=PerfBA_TestData.createPartnerPlanCustomization(pp.id,acc.id);
	PerfBA_TestData.createdisc(ppc.id);
	PerfBA_TestData.createopp(lt.id, accc.id, acc.id, 'Closed Won','e12345');
	lt.Active_Status__c='active';
	lt.Partner_Plan__c=pp.id;
	lt.Plan_Code__c='1002';
	lt.Enterprise_ID_Tenant__c='e12345';
	lt.Deal_Status__c='live_deal';
	lt.Seats_Allocated__c=15;
	lt.Original_Live_Date__c=date.today();
	Update lt;
	Campaign lc = PerfBA_TestData.createcampaign();
	PerfBA_TestData.createsetting(lc.id);
	PerfBA_TestData.createPRMsetting();
		
	    String jsonInput = '{\n' +
	    ' "enterpriseid":"e12345",\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"1002",\n' +
        ' "dealstatus":"live_deal",\n' +
         ' "companyname":"Test",\n' +
         ' "street":"Test",\n' +
         ' "city":"Test",\n' +
         ' "country":"Test",\n' +
         ' "zip":"50309",\n' +
         ' "employees":"12",\n' +
         ' "seats":"10",\n' +
    ' "account": ' +
            '{ "firstname":"Joe" , ' +
                '"lastname":"Nik" , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345",\n' +
        ' "activestatus":"active"\n' +
        '}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/update';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	try{
	PerfBA_Update.boxAPIUpdates();
			System.debug('***'+res.responseBody.toString());
	
	} catch (Exception e) {
							System.debug('***'+e);
		
	}
	Test.stopTest();
		}
		
	static testMethod void UnitTestPostreactivate1() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
	Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('1002');
	Partner_Plan_Customization__c ppc=PerfBA_TestData.createPartnerPlanCustomization(pp.id,acc.id);
	PerfBA_TestData.createdisc(ppc.id);
	PerfBA_TestData.createopp(lt.id, accc.id, acc.id,'Closed Won','e12345');
	lt.Active_Status__c='deactivated';
	lt.Partner_Plan__c=pp.id;
	lt.Plan_Code__c='1002';
	lt.Enterprise_ID_Tenant__c='e12345';
	lt.Deal_Status__c='live_deal';
	lt.Seats_Allocated__c=5;
	lt.Original_Live_Date__c=date.today();
	Update lt;
	Campaign lc = PerfBA_TestData.createcampaign();
	PerfBA_TestData.createsetting(lc.id);
	PerfBA_TestData.createPRMsetting();
		
	    String jsonInput = '{\n' +
	    ' "enterpriseid":"e12345",\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"1002",\n' +
        ' "dealstatus":"live_deal",\n' +
         ' "companyname":"Test",\n' +
         ' "street":"Test",\n' +
         ' "city":"Test",\n' +
         ' "country":"Test",\n' +
         ' "zip":"50309",\n' +
         ' "employees":"12",\n' +
         ' "seats":"10",\n' +
    ' "account": ' +
            '{ "firstname":"Joe" , ' +
                '"lastname":"Nik" , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345",\n' +
        ' "activestatus":"active"\n' +
        '}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/update';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	try{
	PerfBA_Update.boxAPIUpdates();
			System.debug('***'+res.responseBody.toString());
	
	} catch (Exception e) {
							System.debug('***'+e);
		
	}
	Test.stopTest();
		}
		static testMethod void UnitTestPostreactivate2() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
	Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('1002');
	Partner_Plan_Customization__c ppc=PerfBA_TestData.createPartnerPlanCustomization(pp.id,acc.id);
	PerfBA_TestData.createdisc(ppc.id);
	PerfBA_TestData.createopp(lt.id, accc.id, acc.id, 'Closed Won','e12345');
	lt.Active_Status__c='deactivated';
	lt.Partner_Plan__c=pp.id;
	lt.Plan_Code__c='1002';
	lt.Enterprise_ID_Tenant__c='e12345';
	lt.Deal_Status__c='trial';
	lt.Seats_Allocated__c=5;
	lt.Original_Live_Date__c=date.today();
	Update lt;
	Campaign lc = PerfBA_TestData.createcampaign();
	PerfBA_TestData.createsetting(lc.id);
	PerfBA_TestData.createPRMsetting();
		
	    String jsonInput = '{\n' +
	    ' "enterpriseid":"e12345",\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"1002",\n' +
        ' "dealstatus":"live_deal",\n' +
         ' "companyname":"Test",\n' +
         ' "street":"Test",\n' +
         ' "city":"Test",\n' +
         ' "country":"Test",\n' +
         ' "zip":"50309",\n' +
         ' "employees":"12",\n' +
         ' "seats":"10",\n' +
    ' "account": ' +
            '{ "firstname":"Joe" , ' +
                '"lastname":"Nik" , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345",\n' +
        ' "activestatus":"active"\n' +
        '}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/update';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	try{
	PerfBA_Update.boxAPIUpdates();
			System.debug('***'+res.responseBody.toString());
	
	} catch (Exception e) {
							System.debug('***'+e);
		
	}
	Test.stopTest();
		}
		static testMethod void UnitTestPosteditlive() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
	Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('1002');
	Partner_Plan_Customization__c ppc=PerfBA_TestData.createPartnerPlanCustomization(pp.id,acc.id);
	PerfBA_TestData.createdisc(ppc.id);
	PerfBA_TestData.createopp(lt.id, accc.id, acc.id, 'Closed Won','e12345');
	lt.Active_Status__c='active';
	lt.Partner_Plan__c=pp.id;
	lt.Plan_Code__c='1002';
	lt.Enterprise_ID_Tenant__c='e12345';
	lt.Deal_Status__c='live_deal';
	lt.Seats_Allocated__c=5;
	lt.Original_Live_Date__c=date.today();
	Update lt;
	Campaign lc = PerfBA_TestData.createcampaign();
	PerfBA_TestData.createsetting(lc.id);
	PerfBA_TestData.createPRMsetting();
		
	    String jsonInput = '{\n' +
	    ' "enterpriseid":"e12345",\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"1002",\n' +
        ' "dealstatus":"live_deal",\n' +
         ' "companyname":"Test",\n' +
         ' "street":"Test",\n' +
         ' "city":"Test",\n' +
         ' "country":"Test",\n' +
         ' "zip":"50309",\n' +
         ' "employees":"12",\n' +
         ' "seats":"5",\n' +
    ' "account": ' +
            '{ "firstname":"Joe" , ' +
                '"lastname":"Nik" , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345",\n' +
        ' "activestatus":"active"\n' +
        '}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/update';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	try{
	PerfBA_Update.boxAPIUpdates();
			System.debug('***'+res.responseBody.toString());
	
	} catch (Exception e) {
							System.debug('***'+e);
		
	}
	Test.stopTest();
		}
		static testMethod void UnitTestPostedittrial() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
	Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('1002');
	Partner_Plan_Customization__c ppc=PerfBA_TestData.createPartnerPlanCustomization(pp.id,acc.id);
	Contact ct=PerfBA_TestData.createcustomerContact('joe@nik.com',accc.id);
	PerfBA_TestData.createdisc(ppc.id);
	PerfBA_TestData.createopp(lt.id, accc.id, acc.id, 'Closed Won','e12345');
	lt.Active_Status__c='active';
	lt.Partner_Plan__c=pp.id;
	lt.Plan_Code__c='1002';
	lt.Enterprise_ID_Tenant__c='e12345';
	lt.Deal_Status__c='trial';
	lt.Seats_Allocated__c=5;
	lt.Original_Live_Date__c=date.today();
	lt.Admin__c=ct.id;
	Update lt;
	Campaign lc = PerfBA_TestData.createcampaign();
	PerfBA_TestData.createsetting(lc.id);
	PerfBA_TestData.createPRMsetting();
		
	    String jsonInput = '{\n' +
	    ' "enterpriseid":"e12345",\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"1002",\n' +
        ' "dealstatus":"trial",\n' +
         ' "companyname":"Test",\n' +
         ' "street":"Test",\n' +
         ' "city":"Test",\n' +
         ' "country":"Test",\n' +
         ' "zip":"50309",\n' +
         ' "employees":"12",\n' +
         ' "seats":"5",\n' +
    ' "account": ' +
            '{ "firstname":"Joe" , ' +
                '"lastname":"Nik" , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345",\n' +
         ' "trialenddate":"'+Datetime.now().format('MM/dd/yyyy')+'",\n' +
        ' "activestatus":"active"\n' +
        '}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/update';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	try{
	PerfBA_Update.boxAPIUpdates();
			System.debug('***'+res.responseBody.toString());
	
	} catch (Exception e) {
							System.debug('***'+e);
		
	}
	Test.stopTest();
		}
		static testMethod void UnitTestPostedittrialvalidation() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
	Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('1002');
	Partner_Plan_Customization__c ppc=PerfBA_TestData.createPartnerPlanCustomization(pp.id,acc.id);
	PerfBA_TestData.createdisc(ppc.id);
	PerfBA_TestData.createopp(lt.id, accc.id, acc.id, 'Closed Won','e12345');
	lt.Active_Status__c='active';
	lt.Partner_Plan__c=pp.id;
	lt.Plan_Code__c='1002';
	lt.Enterprise_ID_Tenant__c='e12345';
	lt.Deal_Status__c='trial';
	lt.Seats_Allocated__c=5;
	lt.Original_Live_Date__c=date.today();
	Update lt;
	Campaign lc = PerfBA_TestData.createcampaign();
	PerfBA_TestData.createsetting(lc.id);
	PerfBA_TestData.createPRMsetting();
		
	    String jsonInput = '{\n' +
	    ' "enterpriseid":"e12345",\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"1002",\n' +
        ' "dealstatus":"trial",\n' +
         ' "companyname":"Test",\n' +
         ' "street":"Test",\n' +
         ' "city":"Test",\n' +
         ' "country":"Test",\n' +
         ' "zip":"50309",\n' +
         ' "employees":"12",\n' +
         ' "seats":"5",\n' +
    ' "account": ' +
            '{ "firstname":"Joe" , ' +
                '"lastname":"Nik" , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345",\n' +
         ' "trialenddate":"'+Datetime.now().adddays(-4).format('MM/dd/yyyy')+'",\n' +
        ' "activestatus":"active"\n' +
        '}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/update';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	try{
	PerfBA_Update.boxAPIUpdates();
			System.debug('***'+res.responseBody.toString());
	
	} catch (Exception e) {
							System.debug('***'+e);
		
	}
	Test.stopTest();
		}
		static testMethod void UnitTestPosttrialdatevalid() {
	Account acc = PerfBA_TestData.createAccount('12345');
	Account accc = PerfBA_TestData.createcustomerAccount();
	Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
	Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('1002');
	Partner_Plan_Customization__c ppc=PerfBA_TestData.createPartnerPlanCustomization(pp.id,acc.id);
	PerfBA_TestData.createdisc(ppc.id);
	PerfBA_TestData.createopp(lt.id, accc.id, acc.id, 'Closed Won','e12345');
	lt.Active_Status__c='active';
	lt.Partner_Plan__c=pp.id;
	lt.Enterprise_ID_Tenant__c='e12345';
	lt.Deal_Status__c='live_deal';
	lt.Plan_Code__c='1002';
	lt.Seats_Allocated__c=5;
	Update lt;
	Campaign lc = PerfBA_TestData.createcampaign();
	PerfBA_TestData.createsetting(lc.id);
	PerfBA_TestData.createPRMsetting();
		
	    String jsonInput = '{\n' +
	    ' "enterpriseid":"e12345",\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"1002",\n' +
        ' "dealstatus":"live_deal",\n' +
         ' "companyname":"Test",\n' +
         ' "street":"Test",\n' +
         ' "city":"Test",\n' +
         ' "country":"Test",\n' +
         ' "zip":"50309",\n' +
         ' "employees":"12",\n' +
         ' "seats":"2",\n' +
    ' "account": ' +
            '{ "firstname":"Joe" , ' +
                '"lastname":"Nik" , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345",\n' +
        ' "activestatus":"active"\n' +
        '}';

	Test.startTest();
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();
	req.requestURI = '/partnerapi/v1.0/update';  //Request URL
	req.httpMethod = 'Post';//HTTP Request Type
	req.requestBody = Blob.valueof(jsonInput);
	RestContext.request = req;
	RestContext.response= res;
	try{
	PerfBA_Update.boxAPIUpdates();
			System.debug('***'+res.responseBody.toString());
	
	} catch (Exception e) {
							System.debug('***'+e);
		
	}
	Test.stopTest();
		}
	}