@isTest
private class CloneToChurnController_test {
    
    @isTest static void cloneAndChurnOpp_basic() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Opportunity baseOpp = new Opportunity(Name = 'Base Opp', AccountId = acc.Id, StageName = 'Closed Won',
                                              CloseDate = Date.today(), Amount = 10000);
        Opportunity renewalOpp = new Opportunity(Name = 'Renewal Opp', AccountId = acc.Id, StageName = 'Closed Won',
                                                 CloseDate = Date.today(), Renewal_Manager__c = UserInfo.getUserId());
        insert new List<Opportunity> { baseOpp, renewalOpp };
        Risk__c risk = new Risk__c(Name = 'Account Risk', Account__c = acc.Id, Contract_End_Date__c = Date.today());
        insert risk;

        CloneToChurnController.cloneAndChurnOpp(baseOpp.Id);
    }
}