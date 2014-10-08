@isTest
private class OpportunityServicesTest {
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

    static testMethod void testFilterOpportunities() {
        setupCustomSettings();
        Date currentDate = Date.today();
        Opportunity originatingOppty = TestUtils.createOpportunities(1, STAGE_NAME, true)[0];
        Opportunity oldOppty = TestUtils.createOpportunities(1, 'name', false)[0];
        oldOppty.Originating_Opportunity__c = originatingOppty.Id;
        oldOppty.CloseDate = currentDate;
        oldOppty.Trial_End_Date__c = currentDate.addDays(1);
        insert oldOppty;

        Opportunity newOppty = [SELECT StageName, Originating_Opportunity__c, CloseDate, Trial_End_Date__c, Webtrial_Has_CW_Orig_Opp__c FROM Opportunity WHERE Id = :oldOppty.Id];
        newOppty.StageName = STAGE_NAME;

        Opportunity oldNegativeOppty = TestUtils.createOpportunities(1, 'some name', true)[0];
        Opportunity newNegativeOppty = [SELECT StageName, Webtrial_Has_CW_Orig_Opp__c FROM Opportunity WHERE Id = :oldNegativeOppty.Id];

        Test.startTest();
            List<Opportunity> filteredOppties = OpportunityServices.filterOpportunities(new List<Opportunity>{newOppty, newNegativeOppty}, new Map<Id, Opportunity>{oldOppty.Id => oldOppty, oldNegativeOppty.Id => oldNegativeOppty});
        Test.stopTest();

        System.assertEquals(1, filteredOppties.size(), 'There should be one oppty returned');
        System.assertEquals(newOppty.Id, filteredOppties[0].Id, 'The correct oppty should be returned');
    }

    static testMethod void testGetOriginatingOpportunities() {
        setupCustomSettings();
        Opportunity originatingOppty = TestUtils.createOpportunities(1, STAGE_NAME, true)[0];

        Test.startTest();
            List<Opportunity> originatingOppties = OpportunityServices.getOriginatingOpportunities(new Set<Id>{originatingOppty.Id});
        Test.stopTest();

        System.assertEquals(1, originatingOppties.size(), 'There should be one oppty in the list');
        System.assertEquals(originatingOppty.Id, originatingOppties[0].Id, 'The correct oppty should be in the list');
    }

    static testMethod void testCopyOpptyFieldsOntoOriginatingOppty(){
        final Integer NUM_OPPTIES = 4;
        final Decimal SEATS_SOLD = 2;
        final List<String> currencyIsoCodes = new List<String> {
            'USD', 'JPY', 'GBP', 'EUR'
        };
        setupCustomSettings();
        List<Opportunity> originatingOppties = TestUtils.createOpportunities(NUM_OPPTIES, STAGE_NAME, true);
        List<Opportunity> oppties = TestUtils.createOpportunities(NUM_OPPTIES, STAGE_NAME, false);
        for( Integer i = 0; i < NUM_OPPTIES; i++ )
        {
            oppties[i].Originating_Opportunity__c = originatingOppties[i].Id;
            oppties[i].Payment_Term__c = i;
            oppties[i].Initial_Trial_Signup__c = String.valueOf(SEATS_SOLD);
            oppties[i].Trial_Type__c = TRIAL_TYPE + ' (Monthly)';
            oppties[i].Fee_Frequency__c = 'Fee Frequency ' + i;
            oppties[i].Rep_Quota_Relief__c = true;
            oppties[i].CurrencyIsoCode = currencyIsoCodes[i];
        }
        Map<Id, Opportunity> idToOriginatingOpportunity = new Map<Id, Opportunity>( originatingOppties );
        Test.startTest();
            OpportunityServices.copyOpptyFieldsOntoOriginatingOppty( idToOriginatingOpportunity, oppties );
        Test.stopTest();
        Integer i = 0;
        for( Opportunity oppty : oppties )
        {
            Opportunity originatingOppty = idToOriginatingOpportunity.get( oppty.Originating_Opportunity__c );
            System.assertEquals( oppty.Payment_Term__c, originatingOppty.Payment_Term__c, 'The Payment_Term__c field should be copied over' );
            System.assertEquals( oppty.Fee_Frequency__c, originatingOppty.Fee_Frequency__c, 'The Fee_Frequency__c field should be copied over' );
            System.assertEquals( oppty.Rep_Quota_Relief__c, originatingOppty.Rep_Quota_Relief__c, 'The Rep_Quota_Relief__c field should be copied over' );
            System.assertEquals( SEATS_SOLD, originatingOppty.Seats_Sold__c, 'The Initial_Trial_Signup__c field should be copied over' );
            System.assertEquals( ACCOUNT_TYPE_SOLD, originatingOppty.Account_Type_Sold__c, 'The correct account type should be set' );
            System.assertEquals( PRICE*OpportunityServices.currencyIsoCodeToConversionRate.get(oppty.CurrencyIsoCode) * SEATS_SOLD *12, originatingOppty.Amount, 'The amount should be calculated correctly' );
            i++;
        }
    }

    static testMethod void testSetOriginatingOpportunitiesStatus() {
        setupCustomSettings();
        Opportunity oppty = TestUtils.createOpportunities(1, 'name', true)[0];

        Test.startTest();
            OpportunityServices.setOriginatingOpportunitiesStatus(new List<Opportunity>{oppty}, new Map<Id, List<Opportunity>>{oppty.Id => new List<Opportunity>{oppty}});
        Test.stopTest();

        Opportunity actualOppty = [SELECT StageName FROM Opportunity WHERE Id = :oppty.Id];
        System.assertEquals(STAGE_NAME, actualOppty.StageName, 'The stage name should be set correctly');
    }

    static testMethod void testSafeUpdate_Fail() {
        setupCustomSettings();
        Account account = new Account(Name = 'name');
        insert account;
        Opportunity oppty = TestUtils.createOpportunities(1, 'name', true)[0];
        Opportunity originatingOppty = TestUtils.createOpportunities(1, 'name', true)[0];
        originatingOppty.Originating_Opportunity__c = account.Id;

        Test.startTest();
            try {
                OpportunityServices.safeUpdate(new List<Opportunity>{originatingOppty}, new Map<Id, List<Opportunity>>{originatingOppty.Id => new List<Opportunity>{oppty}});
            }
            catch(Exception e) {
                System.assert(false, 'The exception should be caught in the method');
            }
        Test.stopTest();
    }
}