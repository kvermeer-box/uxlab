@isTest
private class QuoteServicesTest
{
    static final String ORIGINAL_PRODUCT_TIER = 'Spotify';
    static final String PRODUCT_TIER = 'Business';

    static Opportunity testOpportunity;
    static Quote testQuote;

    static void setup()
    {
        testOpportunity = OpportunityTestFactory.createOpportunity();
        testQuote = QuoteTestFactory.buildQuote( testOpportunity, null );
        testQuote.Product_Tier__c = ORIGINAL_PRODUCT_TIER;

        TestUtils.createQuoteMachineSettings();
    }

    static testMethod void testSetParentOpportunityProductTier()
    {
        setup();

        testQuote.Product_Tier__c = PRODUCT_TIER;

        Test.startTest();
            List<Opportunity> opportunitiesToUpdate = QuoteServices.setParentOpportunityProductTier( new List<Quote>{ testQuote } );
        Test.stopTest();

        System.assertEquals( 1, opportunitiesToUpdate.size(), 'The parent opportunity should be returned' );
        System.assertEquals( PRODUCT_TIER, opportunitiesToUpdate[0].Account_Type_Sold__c, 'The parent opportunity should be updated with the child quote\'s product tier' );
    }

    static testMethod void testGenericSafeUpdate_success()
    {
        setup();
        insert testQuote;

        testOpportunity.Account_Type_Sold__c = PRODUCT_TIER;

        Test.startTest();
            QuoteServices.genericSafeUpdate(new List<Opportunity>{testOpportunity}, new List<Quote>{testQuote}, QuoteServices.QUOTE_FIELD_OPPORTUNITY_ID);
        Test.stopTest();

        testOpportunity = [
            SELECT Account_Type_Sold__c
            FROM Opportunity
            WHERE Id = :testOpportunity.Id
        ];

        System.assertEquals(PRODUCT_TIER, testOpportunity.Account_Type_Sold__c, 'Safe updating a valid opportunity should succeed');
    }

    static testMethod void testGenericSafeUpdate_failure()
    {
        setup();
        insert testQuote;

        testOpportunity.Account_Type_Sold__c = PRODUCT_TIER;
        testOpportunity.AccountId = testOpportunity.Id;

        Test.startTest();
            try
            {
                QuoteServices.genericSafeUpdate(new List<Opportunity>{testOpportunity}, new List<Quote>{testQuote}, QuoteServices.QUOTE_FIELD_OPPORTUNITY_ID);
            }
            catch(Exception e)
            {
                System.assert(false, 'The safe update function should not throw an exception: ' + e.getMessage());
            }
        Test.stopTest();

        testOpportunity = [
            SELECT Account_Type_Sold__c
            FROM Opportunity
            WHERE Id = :testOpportunity.Id
        ];

        System.assertEquals(ORIGINAL_PRODUCT_TIER, testOpportunity.Account_Type_Sold__c, 'The update should have gracefully failed and not set any field');
    }

    static testMethod void testSetAddedBonusProducts_noAddedBonusProducts()
    {
        setup();

        testQuote.Added_Bonus_Products__c = false;

        Test.startTest();
            List<Quote> quotes = QuoteServices.setAddedBonusProducts(new Set<Id>{testQuote.Id}, new List<QuoteLineItem>());
        Test.stopTest();

        System.assertEquals(1, quotes.size(), 'There should be one quote returned');
        System.assert(quotes[0].Added_Bonus_Products__c, 'The added bonus products should be checked on the quote');
    }

    static testMethod void testSetAddedBonusProducts_addedBonusProducts()
    {
        setup();

        testQuote.Added_Bonus_Products__c = true;

        Test.startTest();
            List<Quote> quotes = QuoteServices.setAddedBonusProducts(new Set<Id>{testQuote.Id}, new List<QuoteLineItem>());
        Test.stopTest();

        System.assertEquals(1, quotes.size(), 'There should be one quote returned');
        System.assert(quotes[0].Added_Bonus_Products__c, 'The added bonus products should be checked on the quote');
    }
}