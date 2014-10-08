@isTest
private class BoxOutControllerRisk_test {
    
    @isTest static void basic_test() {
        Account acc = new Account(Name = 'Kyle\'s Account');
        insert acc;

        Risk__c risk = new Risk__c(Name = 'Risky risk!', ARR_at_risk__c=15000, Post_Churn_Solution__c = 'Competitor', 
                                    Post_Churn_Solution_Sub_reason__c = 'GDrive', CurrencyISOCode = 'USD', Account__c = acc.Id, Contract_End_Date__c = Date.today());
        insert risk;

        BoxOut_Request__c testBO = new BoxOut_Request__c(Risk__c = risk.Id);
        insert testBO;

        ApexPages.currentPage().getParameters().put('riskId', risk.Id);

        BoxOutControllerRisk boxOut = new BoxOutControllerRisk();

        boxOut.salesRequest = testBO;

        Test.startTest();
        Boolean isValid = boxOut.isValidRisk;
        boxout.validateRisk();
        boxout.getUrl();
        String comps = boxout.validCompetitors;
        Test.stopTest();
    }
    
    
}