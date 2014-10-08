@isTest
private class PerfBA_TestRestProvision {

        static testMethod void UnitTestget1() {
    Account acc = PerfBA_TestData.createAccount('12345');
    Test.startTest();
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/partnerapi/v1.0/provision';  //Request URL
    req.httpMethod = 'Get';//HTTP Request Type
    req.addParameter('partnerid','12345');
    req.addParameter('plancode','1001');
    RestContext.request = req;
    RestContext.response= res;
    PerfBA_RestProvision.doGet();
    Test.stopTest();
        }
        static testMethod void UnitTestget2() {
    Account acc = PerfBA_TestData.createAccount('12345');
    Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('1001');
    Test.startTest();
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/partnerapi/v1.0/provision';  //Request URL
    req.httpMethod = 'Get';//HTTP Request Type
    req.addParameter('partnerid','123456');
    req.addParameter('plancode','1001');
    RestContext.request = req;
    RestContext.response= res;
    PerfBA_RestProvision.doGet();
    Test.stopTest();
        }
        static testMethod void UnitTestget3() {
    Account acc = PerfBA_TestData.createAccount('12345');
    Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('1001');

    Test.startTest();
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/partnerapi/v1.0/provision';  //Request URL
    req.httpMethod = 'Get';//HTTP Request Type
    req.addParameter('partnerid','12345');
    req.addParameter('plancode','1001');
    RestContext.request = req;
    RestContext.response= res;
    PerfBA_RestProvision.doGet();
    Test.stopTest();
        }
        static testMethod void UnitTestget4() {
    Account acc = PerfBA_TestData.createAccount('12345');
    Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('1001');
    Partner_Plan_Customization__c ppc = PerfBA_TestData.createPartnerPlanCustomization(pp.id,acc.id);
    Test.startTest();
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/partnerapi/v1.0/provision';  //Request URL
    req.httpMethod = 'Get';//HTTP Request Type
    req.addParameter('partnerid','12345');
    req.addParameter('plancode','1001');
    RestContext.request = req;
    RestContext.response= res;
    PerfBA_RestProvision.doGet();
    Test.stopTest();
        }


    static testMethod void UnitTestPost1() {
    Account accc = PerfBA_TestData.createcustomerAccount();
    Tenant__c lt = PerfBA_TestData.createtenant('joe@nik.com',accc.id);
   
    String jsonInput = '{\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"t001",\n' +
    ' "account": ' +
            '{ "firstname":"Joe" , ' +
                '"lastname":"Nik" , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345"\n' +
        '}';

    Test.startTest();
    System.debug('ltenant*********'+lt);
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/partnerapi/v1.0/provision';  //Request URL
    req.httpMethod = 'Post';//HTTP Request Type
    req.requestBody = Blob.valueof(jsonInput);
    RestContext.request = req;
    RestContext.response= res;
    PerfBA_RestProvision.doPost();
    Test.stopTest();
        }
      
    static testMethod void UnitTestPost2() {
    Account acc = PerfBA_TestData.createAccount('12345');
    Account accc = PerfBA_TestData.createcustomerAccount();
    PerfBA_TestData.createpka('XYZ12345',accc.id,acc.id);
        PerfBA_TestData.createPartnerPlan('t001');
    
    String jsonInput = '{\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"t001",\n' +
        ' "trialenddate":"'+Datetime.now().format('MM/dd/yyyy')+'",\n' +
         ' "dealstatus":"trial",\n' +
    ' "account": ' +
            '{ "firstname":"Joe" , ' +
                '"lastname":"Nik" , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345"\n' +
        '}';

    Test.startTest();

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/partnerapi/v1.0/provision';  //Request URL
    req.httpMethod = 'Post';//HTTP Request Type
    req.requestBody = Blob.valueof(jsonInput);
    RestContext.request = req;
    RestContext.response= res;
    PerfBA_RestProvision.doPost();
    Test.stopTest();
        }
    static testMethod void UnitTestPost3() {

        Account acc = PerfBA_TestData.createAccount('123456');
        Account accc = PerfBA_TestData.createcustomerAccount();
            PerfBA_TestData.createPartnerPlan('t001');
        
        String jsonInput = '{\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"t001",\n' +
         ' "trialenddate":"'+Datetime.now().format('MM/dd/yyyy')+'",\n' +
         ' "dealstatus":"trial",\n' +
    ' "account": ' +
            '{ "firstname":"Joe" , ' +
                '"lastname":"Nik" , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345"\n' +
        '}';

    Test.startTest();
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/partnerapi/v1.0/provision';  //Request URL
    req.httpMethod = 'Post';//HTTP Request Type
    req.requestBody = Blob.valueof(jsonInput);
    RestContext.request = req;
    RestContext.response= res;
    PerfBA_RestProvision.doPost();
    Test.stopTest();
        }
         static testMethod void UnitTestPost4() {

        Account acc = PerfBA_TestData.createAccount('12345');
        Account accc = PerfBA_TestData.createcustomerAccount();
            PerfBA_TestData.createPartnerPlan('t001');
        
        String jsonInput = '{\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"t001",\n' +
        ' "trialenddate":"'+Datetime.now().format('MM/dd/yyyy')+'",\n' +
         ' "dealstatus":"trial",\n' +
    ' "account": ' +
            '{ "firstname":"Joe" , ' +
                '"lastname":"Nik" , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345"\n' +
        '}';

    Test.startTest();
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/partnerapi/v1.0/provision';  //Request URL
    req.httpMethod = 'Post';//HTTP Request Type
    req.requestBody = Blob.valueof(jsonInput);
    RestContext.request = req;
    RestContext.response= res;
    PerfBA_RestProvision.doPost();
    Test.stopTest();
        }
                 static testMethod void UnitTestPost5() {

        Account acc = PerfBA_TestData.createAccount('12345');
        Account accc = PerfBA_TestData.createcustomerAccount();
        Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('t001');
        Partner_Plan_Customization__c ppc = PerfBA_TestData.createPartnerPlanCustomization(pp.id,acc.id);
         PerfBA_TestData.createPRMsetting();
        
        String jsonInput = '{\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"t001",\n' +
         ' "trialenddate":"'+Datetime.now().format('MM/dd/yyyy')+'",\n' +
         ' "dealstatus":"trial",\n' +
    ' "account": ' +
            '{ "firstname":"Joe" , ' +
                '"lastname":"Nik" , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345"\n' +
        '}';

    Test.startTest();
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/partnerapi/v1.0/provision';  //Request URL
    req.httpMethod = 'Post';//HTTP Request Type
    req.requestBody = Blob.valueof(jsonInput);
    RestContext.request = req;
    RestContext.response= res;
    PerfBA_RestProvision.doPost();
    Test.stopTest();
        }
        static testMethod void UnitTestPost6() {

        Account acc = PerfBA_TestData.createAccount('12345');
        Account accc = PerfBA_TestData.createcustomerAccount();
        Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('t001');
        Partner_Plan_Customization__c ppc = PerfBA_TestData.createPartnerPlanCustomization(pp.id,acc.id);
        Campaign lc = PerfBA_TestData.createcampaign();
        PerfBA_TestData.createsetting(lc.id);
        PerfBA_TestData.createPRMsetting();
        String jsonInput = '{\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"t001",\n' +
         ' "trialenddate":"'+Datetime.now().format('MM/dd/yyyy')+'",\n' +
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
        ' "partnerkey":"XYZ12345"\n' +
        '}';

    Test.startTest();
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/partnerapi/v1.0/provision';  //Request URL
    req.httpMethod = 'Post';//HTTP Request Type
    req.requestBody = Blob.valueof(jsonInput);
    RestContext.request = req;
    RestContext.response= res;
    PerfBA_RestProvision.doPost();
    Test.stopTest();
        }
  static testMethod void UnitTestPost7() {

        Account acc = PerfBA_TestData.createAccount('12345');
        Account accc = PerfBA_TestData.createcustomerAccount();
        Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('t001');
        Partner_Plan_Customization__c ppc = PerfBA_TestData.createPartnerPlanCustomization(pp.id,acc.id);
        Campaign lc = PerfBA_TestData.createcampaign();
        PerfBA_TestData.createcustomerContact('joe@nik.com',accc.id);
        PerfBA_TestData.createsetting(lc.id);
        PerfBA_TestData.createPRMsetting();
        String jsonInput = '{\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"t001",\n' +
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
        ' "partnerkey":"XYZ12345"\n' +
        '}';

    Test.startTest();
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/partnerapi/v1.0/provision';  //Request URL
    req.httpMethod = 'Post';//HTTP Request Type
    req.requestBody = Blob.valueof(jsonInput);
    RestContext.request = req;
    RestContext.response= res;
    PerfBA_RestProvision.doPost();
    Test.stopTest();
        }
  static testMethod void UnitTestPost8() {

        Account acc = PerfBA_TestData.createAccount('12345');
        Account accc = PerfBA_TestData.createcustomerAccount();
        Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('t001');
        Partner_Plan_Customization__c ppc = PerfBA_TestData.createPartnerPlanCustomization(pp.id,acc.id);
        Campaign lc = PerfBA_TestData.createcampaign();
        PerfBA_TestData.createcustomerContact('joe@nik.com',accc.id);
        PerfBA_TestData.createsetting(lc.id);
        PerfBA_TestData.createPRMsetting();
        String jsonInput = '{\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"t001",\n' +
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
        ' "partnerkey":"XYZ12345"\n' +
        '}';

    Test.startTest();
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/partnerapi/v1.0/provision';  //Request URL
    req.httpMethod = 'Post';//HTTP Request Type
    req.requestBody = Blob.valueof(jsonInput);
    RestContext.request = req;
    RestContext.response= res;
    PerfBA_RestProvision.doPost();
    Test.stopTest();
        }
   static testMethod void UnitTestPost9() {

        Account acc = PerfBA_TestData.createAccount('12345');
        Account accc = PerfBA_TestData.createcustomerAccount();
        Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('t001');
        Partner_Plan_Customization__c ppc = PerfBA_TestData.createPartnerPlanCustomization(pp.id,acc.id);
        Campaign lc = PerfBA_TestData.createcampaign();
        PerfBA_TestData.createcustomerContact('joe@nik.com',accc.id);
        PerfBA_TestData.createsetting(lc.id);
        PerfBA_TestData.createPRMsetting();
        String jsonInput = '{\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"t001",\n' +
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
                '"lastname":"" , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345"\n' +
        '}';

    Test.startTest();
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/partnerapi/v1.0/provision';  //Request URL
    req.httpMethod = 'Post';//HTTP Request Type
    req.requestBody = Blob.valueof(jsonInput);
    RestContext.request = req;
    RestContext.response= res;
    PerfBA_RestProvision.doPost();
    Test.stopTest();
        }
      static testMethod void UnitTestPost10() {

        Account acc = PerfBA_TestData.createAccount('12345');
        Account accc = PerfBA_TestData.createcustomerAccount();
        Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('t001');
        Partner_Plan_Customization__c ppc = PerfBA_TestData.createPartnerPlanCustomization(pp.id,acc.id);
        Campaign lc = PerfBA_TestData.createcampaign();
        PerfBA_TestData.createcustomerContact('joe@nik.com',accc.id);
        PerfBA_TestData.createsetting(lc.id);
        PerfBA_TestData.createPRMsetting();
        String jsonInput = '{\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"t001",\n' +
        ' "dealstatus":"live_deal",\n' +
         ' "companyname":"Test",\n' +
         ' "street":"Test",\n' +
         ' "city":"Test",\n' +
         ' "country":"Test",\n' +
         ' "zip":"50309",\n' +
         ' "employees":"12",\n' +
         ' "seats":"1",\n' +
    ' "account": ' +
            '{ "firstname":"Joe" , ' +
                '"lastname":"nik" , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345"\n' +
        '}';

    Test.startTest();
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/partnerapi/v1.0/provision';  //Request URL
    req.httpMethod = 'Post';//HTTP Request Type
    req.requestBody = Blob.valueof(jsonInput);
    RestContext.request = req;
    RestContext.response= res;
    PerfBA_RestProvision.doPost();
    Test.stopTest();
        }
    static testMethod void UnitTestPost11() {

        Account acc = PerfBA_TestData.createAccount('12345');
        Account accc = PerfBA_TestData.createcustomerAccount();
        Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('t001');
        Partner_Plan_Customization__c ppc = PerfBA_TestData.createPartnerPlanCustomization(pp.id,acc.id);
        Campaign lc = PerfBA_TestData.createcampaign();
        PerfBA_TestData.createcustomerContact('joe@nik.com',accc.id);
        PerfBA_TestData.createsetting(lc.id);
        PerfBA_TestData.createPRMsetting();
        String jsonInput = '{\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"t001",\n' +
        ' "trialenddate":"2/01/2013",\n' +
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
        ' "partnerkey":"XYZ12345"\n' +
        '}';

    Test.startTest();
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/partnerapi/v1.0/provision';  //Request URL
    req.httpMethod = 'Post';//HTTP Request Type
    req.requestBody = Blob.valueof(jsonInput);
    RestContext.request = req;
    RestContext.response= res;
    PerfBA_RestProvision.doPost();
    Test.stopTest();
        }
            static testMethod void UnitTestPost12() {

        Account acc = PerfBA_TestData.createAccount('12345');
        Account accc = PerfBA_TestData.createcustomerAccount();
        Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('t001');
        Partner_Plan_Customization__c ppc = PerfBA_TestData.createPartnerPlanCustomization(pp.id,acc.id);
        Campaign lc = PerfBA_TestData.createcampaign();
        PerfBA_TestData.createcustomerContact('joe@nik.com',accc.id);
        PerfBA_TestData.createsetting(lc.id);
        PerfBA_TestData.createPRMsetting();
        String jsonInput = '{\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"t001",\n' +
        ' "trialenddate":"'+Datetime.now().format('MM/dd/yyyy')+'",\n' +
        ' "dealstatus":"trial",\n' +
         ' "companyname":"Test",\n' +
         ' "street":"Test",\n' +
         ' "city":"Test",\n' +
         ' "country":"Test",\n' +
         ' "zip":"50309",\n' +
         ' "employees":"12",\n' +
         ' "seats":"1",\n' +
    ' "account": ' +
            '{ "firstname":"Joe" , ' +
                '"lastname":"Nik" , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345"\n' +
        '}';

    Test.startTest();
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/partnerapi/v1.0/provision';  //Request URL
    req.httpMethod = 'Post';//HTTP Request Type
    req.requestBody = Blob.valueof(jsonInput);
    RestContext.request = req;
    RestContext.response= res;
    PerfBA_RestProvision.doPost();
    Test.stopTest();
        }
     static testMethod void UnitTestPost13() {

        Account acc = PerfBA_TestData.createAccount('12345');
        Account accc = PerfBA_TestData.createcustomerAccount();
        Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('t001');
        Partner_Plan_Customization__c ppc = PerfBA_TestData.createPartnerPlanCustomization(pp.id,acc.id);
        Campaign lc = PerfBA_TestData.createcampaign();
        PerfBA_TestData.createsetting(lc.id);
        PerfBA_TestData.createPRMsetting();
        String jsonInput = '{\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"t001",\n' +
         ' "trialenddate":"'+Datetime.now().format('MM/dd/yyyy')+'",\n' +
         ' "dealstatus":"trial",\n' +
         ' "companyname":"Test",\n' +
         ' "street":"Test",\n' +
         ' "city":"Test",\n' +
         ' "country":"Test",\n' +
         ' "zip":"50309",\n' +
         ' "employees":"12",\n' +
         ' "seats":"3",\n' +
    ' "account": ' +
            '{ "firstname":" " , ' +
                '"lastname":" " , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345"\n' +
        '}';

    Test.startTest();
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/partnerapi/v1.0/provision';  //Request URL
    req.httpMethod = 'Post';//HTTP Request Type
    req.requestBody = Blob.valueof(jsonInput);
    RestContext.request = req;
    RestContext.response= res;
    PerfBA_RestProvision.doPost();
    Test.stopTest();
        }
             static testMethod void UnitTestPost14() {

        Account acc = PerfBA_TestData.createAccount('12345');
        Account accc = PerfBA_TestData.createcustomerAccount();
        Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('t001');
        Partner_Plan_Customization__c ppc = PerfBA_TestData.createPartnerPlanCustomization(pp.id,acc.id);
        Campaign lc = PerfBA_TestData.createcampaign();
        PerfBA_TestData.createcustomerContact('joe@nik.com',accc.id);
        PerfBA_TestData.createsetting(lc.id);
        PerfBA_TestData.createPRMsetting();
        String jsonInput = '{\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"t001",\n' +
        ' "trialenddate":"'+Datetime.now().adddays(3).format('MM/dd/yyyy')+'",\n' +
        ' "dealstatus":"trial",\n' +
         ' "companyname":"Test",\n' +
         ' "street":"Test",\n' +
         ' "city":"Test",\n' +
         ' "country":"Test",\n' +
         ' "zip":"50309",\n' +
         ' "employees":"12",\n' +
         ' "seats":"1",\n' +
    ' "account": ' +
            '{ "firstname":"Joe" , ' +
                '"lastname":"Nik" , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345"\n' +
        '}';
        Test.startTest();
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/partnerapi/v1.0/provision';  //Request URL
    req.httpMethod = 'Post';//HTTP Request Type
    req.requestBody = Blob.valueof(jsonInput);
    RestContext.request = req;
    RestContext.response= res;
    PerfBA_RestProvision.doPost();
    Test.stopTest();
             }
     static testMethod void UnitTestPost15() {

        Account acc = PerfBA_TestData.createAccount('12345');
        Account accc = PerfBA_TestData.createcustomerAccount();
        Partner_Plan__c pp = PerfBA_TestData.createPartnerPlan('t001');
        Partner_Plan_Customization__c ppc = PerfBA_TestData.createPartnerPlanCustomization(pp.id,acc.id);
        Campaign lc = PerfBA_TestData.createcampaign();
        PerfBA_TestData.createcustomerContact('joe@nik.com',accc.id);
        PerfBA_TestData.createsetting(lc.id);
        PerfBA_TestData.createPRMsetting();
        String jsonInput = '{\n' +
        ' "partnerid":"12345",\n' +
        ' "plancode":"t001",\n' +
        ' "dealstatus":"trial",\n' +
         ' "companyname":"Test",\n' +
         ' "street":"Test",\n' +
         ' "city":"Test",\n' +
         ' "country":"Test",\n' +
         ' "zip":"50309",\n' +
         ' "employees":"12",\n' +
         ' "seats":"1",\n' +
    ' "account": ' +
            '{ "firstname":"Joe" , ' +
                '"lastname":"Nik" , ' +
        '"email":"joe@nik.com" , ' +
                '"phone":"4154154156"},\n' +
        ' "partnerkey":"XYZ12345"\n' +
        '}';

    Test.startTest();
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/partnerapi/v1.0/provision';  //Request URL
    req.httpMethod = 'Post';//HTTP Request Type
    req.requestBody = Blob.valueof(jsonInput);
    RestContext.request = req;
    RestContext.response= res;
    PerfBA_RestProvision.doPost();
    Test.stopTest();
        }         
             
}