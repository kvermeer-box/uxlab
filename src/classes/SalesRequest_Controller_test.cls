@isTest
private class SalesRequest_Controller_test {
    
    @isTest static void basic_test() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Lead l = new Lead(LastName = 'Leaderton', Company = 'Chumbawumba');
        insert l;

        Opportunity opp = new Opportunity(AccountId = acc.Id, Name = 'Test Opp', CloseDate = Date.today(), StageName = 'Received / Prospecting');
        insert opp;

        Contact c = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
        insert c;

        Risk__c risk = new Risk__c(Name = 'Risky risk!', ARR_at_risk__c=15000, Post_Churn_Solution__c = 'Competitor', 
                                   Post_Churn_Solution_Sub_reason__c = 'GDrive', CurrencyISOCode = 'USD', Account__c = acc.Id, 
                                   Contract_End_Date__c = Date.today());
        insert risk;

        ApexPages.currentPage().getParameters().put(SalesRequest_Controller.OPPORTUNITY_ID_PARAMETER, opp.Id);
        ApexPages.currentPage().getParameters().put(SalesRequest_Controller.ACCOUNT_ID_PARAMETER, acc.Id);
        ApexPages.currentPage().getParameters().put(SalesRequest_Controller.LEAD_ID_PARAMETER, l.Id);
        ApexPages.currentPage().getParameters().put(SalesRequest_Controller.CONTACT_ID_PARAMETER, c.Id);
        ApexPages.currentPage().getParameters().put(SalesRequest_Controller.RISK_ID_PARAMETER, risk.Id);

        Sales_Request_Entry__c entry1 = new Sales_Request_Entry__c(Name = 'Cat', Info_Text__c = 'Do you like Cats?', Link_to_Request_Page__c = '/apex/cats',
                                                                  Account_Parameter_Name__c = 'accId', Opportunity_Parameter_Name__c = 'oppId',
                                                                  Risk_Parameter_Name__c = 'riskId', Contact_Parameter_Name__c = 'conId',
                                                                  Lead_Parameter_Name__c = 'leadId', Is_VisualForce_Page__c = true,
                                                                  Only_Allow_Profiles__c = true, Restrict_From_Profiles__c = false,
                                                                  Listed_Profiles__c = 'Sys Admin;');
        Sales_Request_Entry__c entry2 = new Sales_Request_Entry__c(Name = 'Dog', Info_Text__c = 'Do you like Dogs?', Link_to_Request_Page__c = '/apex/dogs',
                                                                  Account_Parameter_Name__c = 'accId', Opportunity_Parameter_Name__c = 'oppId',
                                                                  Risk_Parameter_Name__c = 'riskId', Contact_Parameter_Name__c = 'conId',
                                                                  Lead_Parameter_Name__c = 'leadId', Is_VisualForce_Page__c = false,
                                                                  Only_Allow_Profiles__c = false, Restrict_From_Profiles__c = true,
                                                                  Listed_Profiles__c = 'Sys Admin;');
        insert new List<Sales_Request_Entry__c> { entry1, entry2 };
    
        SalesRequest_Controller controller = new SalesRequest_Controller();
    }

}