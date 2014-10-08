@isTest
private class LegalRequest_Controller_test {
    
    @isTest static void basicTest() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Opportunity opp = new Opportunity(Name = 'Test Opp', CloseDate = Date.today(), StageName = 'Recieved / Prospecting', accountId = acc.Id);
        insert opp;

        ApexPages.currentPage().getParameters().put(LegalRequest_Controller.OPP_PARAMETER_NAME, opp.Id);
        ApexPages.currentPage().getParameters().put(LegalRequest_Controller.ACC_PARAMETER_NAME, acc.Id);

        LegalRequest_Controller controller = new LegalRequest_Controller();
        System.debug(controller.urlParameters);
    }
    
    
}