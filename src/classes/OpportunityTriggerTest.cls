@isTest
private class OpportunityTriggerTest {
    static final String STAGE_NAME = 'Closed Won';
    static final String TRIAL_TYPE = 'business';
    static final String ACCOUNT_TYPE_SOLD = 'business2';
    static final Decimal PRICE = 10.00;
    static void setupCustomSettings() {
        Web_trial_Originating_Opp_Stage__c oppStage = new Web_trial_Originating_Opp_Stage__c();
        oppStage.Name = STAGE_NAME;
        Trial_Type_To_Account_Type_Sold__c trialTypeToAccountTypeSold = new Trial_Type_To_Account_Type_Sold__c();
        trialTypeToAccountTypeSold.Name = 'test';
        trialTypeToAccountTypeSold.Trial_Type__c = TRIAL_TYPE;
        trialTypeToAccountTypeSold.Account_Type_Sold__c = ACCOUNT_TYPE_SOLD;
        trialTypeToAccountTypeSold.USD__c = PRICE;
        System.runAs(TestUtils.ADMIN_USER) {
            insert oppStage;
            insert trialTypeToAccountTypeSold;
        }
    }

    static testMethod void testBulkUpdate() {
        setupCustomSettings();
        final Decimal SEATS_SOLD = 2;
        Date currentDate = Date.today();
        final String NAME = 'name';
        final Integer EXPECTED_PAYMENT_TERM = 1;
        final String EXPECTED_FEE_FREQUENCY = 'Test Fee Frequency';
        final Date EXPECTED_CLOSE_DATE = Date.today().addDays(-1);
        final Integer NUM_OPPS = Limits.getLimitQueries() + 1;
        Opportunity originatingOppty = TestUtils.createOpportunities(1, NAME, true)[0];
        Opportunity originatingOppty2 = TestUtils.createOpportunities(1, NAME, true)[0];
        List<Opportunity> oppties = TestUtils.createOpportunities(NUM_OPPS, NAME, true);
        for(Integer i=0;i<NUM_OPPS/2;i++) {
            oppties[i].CloseDate = currentDate;
            oppties[i].Trial_End_Date__c = currentDate.addDays(1);
            oppties[i].StageName = STAGE_NAME;
            oppties[i].Initial_Trial_Signup__c = String.valueOf(SEATS_SOLD);
            oppties[i].Trial_Type__c = TRIAL_TYPE + ' (Monthly)';
            oppties[i].Originating_Opportunity__c = originatingOppty.Id;
            oppties[i].Payment_Term__c = EXPECTED_PAYMENT_TERM;
            oppties[i].Fee_Frequency__c = EXPECTED_FEE_FREQUENCY;
            oppties[i].Rep_Quota_Relief__c = true;
        }

        for(Integer i=NUM_OPPS/2;i<NUM_OPPS;i++) {
            oppties[i].Originating_Opportunity__c = originatingOppty2.Id;
            oppties[i].Payment_Term__c = EXPECTED_PAYMENT_TERM;
            oppties[i].Rep_Quota_Relief__c = true;
        }

        Test.startTest();
            update oppties;
        Test.stopTest();

        Opportunity actualOriginatingOppty = [SELECT Amount, Account_Type_Sold__c, Seats_Sold__c, StageName, Payment_Term__c, Fee_Frequency__c, CloseDate, Rep_Quota_Relief__c FROM Opportunity WHERE Id = :originatingOppty.Id];
        System.assertEquals(STAGE_NAME, actualOriginatingOppty.StageName, 'The stage name should be set correctly');
        System.assertEquals(EXPECTED_PAYMENT_TERM, actualOriginatingOppty.Payment_Term__c, 'The payment term should get set correctly' );
        System.assertEquals(EXPECTED_FEE_FREQUENCY, actualOriginatingOppty.Fee_Frequency__c, 'The fee frequency should get set correctly' );
        System.assertEquals( true, actualOriginatingOppty.Rep_Quota_Relief__c, 'The rep deal should get set correctly' );
        System.assertEquals( Date.today(), actualOriginatingOppty.CloseDate, 'The Close Date should get set correctly' );
        System.assertEquals( PRICE * SEATS_SOLD *12, actualOriginatingOppty.Amount, 'The amount should be calculated correctly' );
        System.assertEquals( ACCOUNT_TYPE_SOLD, actualOriginatingOppty.Account_Type_Sold__c, 'The correct account type should be set' );
        System.assertEquals( SEATS_SOLD, actualOriginatingOppty.Seats_Sold__c, 'The Initial_Trial_Signup__c field should be copied over' );

        Opportunity actualOriginatingOppty2 = [SELECT Amount, Account_Type_Sold__c, Seats_Sold__c, StageName, Payment_Term__c, Fee_Frequency__c, Rep_Quota_Relief__c FROM Opportunity WHERE Id = :originatingOppty2.Id];
        System.assertEquals(NAME, actualOriginatingOppty2.StageName, 'The stage name should stay the same');
        System.assertNotEquals(EXPECTED_PAYMENT_TERM, actualOriginatingOppty2.Payment_Term__c, 'The payment term should not get set' );
        System.assertNotEquals(EXPECTED_FEE_FREQUENCY, actualOriginatingOppty2.Fee_Frequency__c, 'The fee frequency should not get set' );
        System.assertEquals(false, actualOriginatingOppty2.Rep_Quota_Relief__c, 'The rep deal should not get set' );
        System.assertEquals( 1.00, actualOriginatingOppty2.Amount, 'The amount should default to 1.00' );
        System.assertEquals( null, actualOriginatingOppty2.Account_Type_Sold__c, 'The account type should not be set' );
        System.assertEquals( null, actualOriginatingOppty2.Seats_Sold__c, 'The seats sold field should not be set' );
    }
}