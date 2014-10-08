@isTest
private class EERSelectController_test {
    
    @isTest static void basicTest() {
        PageReference pageRef = Page.EERSelect;
        Test.setCurrentPage(pageRef);

        Account acct = new Account(Name = 'Test Acct');
        insert acct;
        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'In Trial', CloseDate = Date.today(),
                                          AccountId = acct.id);
        insert opp;

        ApexPages.currentPage().getParameters().put('opportunityId', opp.Id);
        ApexPages.currentPage().getParameters().put('accountId', acct.Id);

        EERSelectController controller = new EERSelectController();
        String parameters = controller.autoPopulateParameters;
    }
}