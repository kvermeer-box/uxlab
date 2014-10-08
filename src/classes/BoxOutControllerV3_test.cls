@isTest
private class BoxOutControllerV3_test {
	
	@isTest static void basicTest() {
        SalesDivision__c sales_division_settings = SalesDivision__c.getInstance('Mappings');
        if (sales_division_settings == null) sales_division_settings = new SalesDivision__c(Name='Mappings', Grouping__c='Major');
        insert sales_division_settings;

        Id userId = TestDataFactory_hlpr.createUser('Major','NATAM','Kyle V','blahblah@test.st');
        Opportunity opp = new Opportunity(OwnerId= userId, Name = 'Test Opp', StageName = 'Validating Biz Case & Confirming Plan', 
                                          CloseDate = Date.today().addDays(1), Amount = 50000, Sales_Division__c = 'ESB', 
                                          Competitor_We_Lost_To__c = 'GDrive');
        insert opp;
        

        BoxOut_Request__c testBO = new BoxOut_Request__c(Opportunity__c = opp.Id);
        insert testBO;

        Amount_Threshold__c at = new Amount_Threshold__c(Name = 'BoxOut - Major', Program__c = 'BoxOut', Category__c = 'Major',
                                                         Threshold_Amount__c = 500);
        insert at;

        ApexPages.currentPage().getParameters().put('oppId', opp.Id);

        BoxOutControllerV3 boxOut = new BoxOutControllerV3();

        boxOut.salesRequest = testBO;

        Test.startTest();
        boxOut.validateOpp();
        boxOut.getAmountReqColor();
        boxOut.getCompetitorReqColor();
        boxOut.getStageReqColor();
        boxOut.getURL();
        boxOut.getButtonColor();
        boxOut.getButtonCursor();
        boxOut.getButtonText();
        String comps = boxOut.validCompetitors;
        Test.stopTest();
    }
		
	
}