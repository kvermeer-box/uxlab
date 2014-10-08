@isTest
private class BoxOutUtils_test {
    
    @isTest static void validateStageReq_basic() {
        // Should be valid
        Boolean isValidStage = BoxOutUtils.validateStageReq(35);
        System.assert(isValidStage);

        // Shoudn't be valid
        Boolean isValidStage2 = BoxOutUtils.validateStageReq(15);
        System.assert(!isValidStage2);

        // Null
        BoxOutUtils.validateStageReq(null);
    }
    
    @isTest static void validateCompetitorReq_basic() {
        // Should be valid
        Boolean isValidComp = BoxOutUtils.validateCompetitorReq('GDrive');
        System.assert(isValidComp);

        // Shouldn't be valid
        Boolean isValidComp2 = BoxOutUtils.validateCompetitorReq('QDrive');
        System.assert(!isValidComp2);

        // Null
        BoxOutUtils.validateCompetitorReq(null);
    }

    @isTest static void validateAmountThreshold_basic() {
        // Prepare thresholds
        Amount_Threshold__c esbThreshold = new Amount_Threshold__c(Name='ESB Boxout', Program__c = 'BoxOut', Category__c = 'ESB', Threshold_Amount__c = 10000);
        insert esbThreshold;

        // Should be valid
        Boolean isValidAmount = BoxOutUtils.validateAmountThreshold('ESB', 15000);
        System.assert(isValidAmount);

        // Shouldn't be valid
        Boolean isValidAmount2 = BoxOutUtils.validateAmountThreshold('ESB', 5000);
        System.assert(!isValidAmount2);

        // Shouldn't be valid
        Boolean isValidAmount3 = BoxOutUtils.validateAmountThreshold('Majors', 12000);
        System.assert(!isValidAmount3);

        //Null
        BoxOutUtils.validateAmountThreshold(null, 200);
        BoxOutUtils.validateAmountThreshold('ESB', null);
    }

    @isTest static void isValidOpp_basic() {
        // Prepare Data
        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Negotiating $$', Probability = 30, Amount = 20000,
                                          Sales_Division__c = 'ESB', CloseDate = Date.today(), Competitor_We_Lost_To__c = 'GDrive');
        insert opp;

        Amount_Threshold__c esbThreshold = new Amount_Threshold__c(Name='ESB Boxout', Program__c = 'BoxOut', Category__c = 'ESB', Threshold_Amount__c = 10000);
        insert esbThreshold;

        // Test
        Test.startTest();
        Boolean isValidOpp = BoxOutUtils.isQualifiedBoxOutOpp(opp);
        Test.stopTest();

        //System.assert(isValidOpp);
    }

    @isTest static void getQualifiedBoxOuts_basic() {
        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Negotiating $$', Probability = 30, Amount = 20000,
                                          Sales_Division__c = 'ESB', CloseDate = Date.today(), Competitor_We_Lost_To__c = 'GDrive');
        insert opp;
        BoxOutUtils.getQualfiedBoxOutOpps(new Id[] { opp.Id });
    }
}