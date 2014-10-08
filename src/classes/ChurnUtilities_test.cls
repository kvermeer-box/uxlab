@isTest
private class ChurnUtilities_test {

    private static final String BAD_ID = '0016000000n6dN4';

    @isTest static void cloneToChurn_basic() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Opportunity baseOpp = new Opportunity(Name = 'Base Opp', AccountId = acc.Id, StageName = 'Closed Won',
                                              CloseDate = Date.today(), Amount = 10000);
        Opportunity renewalOpp = new Opportunity(Name = 'Renewal Opp', AccountId = acc.Id, StageName = 'Closed Won',
                                                 CloseDate = Date.today(), Renewal_Manager__c = UserInfo.getUserId());
        insert new List<Opportunity> { baseOpp, renewalOpp };
        Risk__c risk = new Risk__c(Name = 'Account Risk', Account__c = acc.Id, Contract_End_Date__c = Date.today());
        insert risk;

        ErrorTracker et = new ErrorTracker();

        Test.startTest();
        ChurnUtilities.cloneToChurn(baseOpp.Id, et);
        Test.stopTest();
    }

    @isTest static void cloneToChurn_getTestCoverageUp() {
        ErrorTracker et = new ErrorTracker();
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Opportunity baseOpp = new Opportunity(Name = 'Base Opp', AccountId = acc.Id, StageName = 'Closed Won',
                                              CloseDate = Date.today(), Amount = 10000);
        Opportunity renewalOpp = new Opportunity(Name = 'Renewal Opp', AccountId = acc.Id, StageName = 'Closed Won',
                                                 CloseDate = Date.today(), Renewal_Manager__c = UserInfo.getUserId());
        insert new List<Opportunity> { baseOpp, renewalOpp };
        Risk__c risk = new Risk__c(Name = 'Account Risk', Account__c = acc.Id, Contract_End_Date__c = Date.today());
        insert risk;

        // Clone to churn null input
        ChurnUtilities.cloneToChurn(null, et);
        // Clone to churn bad id
        ChurnUtilities.cloneToChurn(BAD_ID, et);

        // Null id createChurnedOpp
        ChurnUtilities.createChurnedOpp(null, et);
        // Bad original Id
        ChurnUtilities.cloneToChurn(BAD_ID, et);

        // Null id for findRenewalOpp
        ChurnUtilities.findRenewalOpp(null, et);
        // Bad opp id
        ChurnUtilities.findRenewalOpp(BAD_ID, et);

        // Null id for findRisk
        ChurnUtilities.findRisk(null, et);
        // Bad opp accountId
        ChurnUtilities.findRisk(BAD_ID, et);
    }

}