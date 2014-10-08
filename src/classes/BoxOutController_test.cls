@isTest
private class BoxOutController_test {
    
    @isTest static void fullTest() {
        // Implement test code

        SalesDivision__c sales_division_settings = SalesDivision__c.getInstance('Mappings');
        if (sales_division_settings == null) sales_division_settings = new SalesDivision__c(Name='Mappings', Grouping__c='Major');
        insert sales_division_settings;

        Id userId = TestDataFactory_hlpr.createUser('Major','NATAM','Kyle V','blahblah@test.st');
        Opportunity opp = new Opportunity(OwnerId= userId, Name = 'Test Opp', StageName = 'Recieved / Prospecting', CloseDate = Date.today().addDays(1),
                                          Amount = 50000, Sales_Division__c = 'ESB', Competitor_We_Lost_To__c = 'GDrive');
        insert opp;
        BoxOutController boxOut = new BoxOutController();

        RecordType recordType = [SELECT Id From RecordType WHERE SObjectType= 'Sales_Request__c' and Name = 'BoxOut'];
        Sales_Request__c testSR = new Sales_Request__c(RecordTypeId = recordType.Id, Opportunity__c = opp.Id);
        insert testSR;

        boxOut.salesRequest = testSR;

        Test.startTest();
        boxOut.validateOpp();
        boxOut.getAmountReqColor();
        boxOut.getCompetitorReqColor();
        boxOut.getStageReqColor();
        boxOut.getURL();
        boxOut.getButtonColor();
        boxOut.getButtonCursor();
        Test.stopTest();
    }
    
}