@isTest
private class QuoteTriggerTest
{
    private class QuoteSetupData
    {
        final Integer NUM_OF_QUOTES = 10;
        final Decimal BELOW_THRESHOLD_PRICE = 1.00;
        final Product2 testProduct;
        final PricebookEntry pricebookEntry;
        final Decimal HIGH_THRESHOLD_PRICE;
        final Decimal LOW_THRESHOLD_PRICE;
        List<Quote> testQuotes;
        List<QuoteLineItem> quoteLineItems;
        Opportunity opportunity;

        private QuoteSetupData()
        {
            TestUtils.createBonusProductsSetting( TestUtils.STANDARD_PRICEBOOK.Id );
            this.testProduct = ProductTestFactory.createProduct();
            this.pricebookEntry = ProductTestFactory.createPricebookEntry( testProduct );
            this.quoteLineItems = new List<QuoteLineItem>();
            this.HIGH_THRESHOLD_PRICE = Bonus_Products__c.getInstance().High_Bonus_Product_Threshold__c + 100;
            this.LOW_THRESHOLD_PRICE = Bonus_Products__c.getInstance().Low_Bonus_Product_Threshold__c + 100;
        }

        private void setupDefaultOpportunity()
        {
            this.opportunity = OpportunityTestFactory.createOpportunity();
        }

        private void setupRenewalOpportunity()
        {
            this.opportunity = OpportunityTestFactory.createRenewalOpportunity();
        }

        private void setupQuotes( Decimal price )
        {
            this.testQuotes = QuoteTestFactory.createNewAgreementQuotes( NUM_OF_QUOTES, opportunity );
            for( Quote quote : testQuotes )
            {
                QuoteLineItem quoteLineItem = QuoteTestFactory.buildQuoteLineItem( quote, pricebookEntry );
                quoteLineItem.UnitPrice = price;
                quoteLineItem.List_Price__c = price;
                this.quoteLineItems.add( quoteLineItem );
            }
        }
        
        private void setAddedBonusProductsOnQuotes()
        {
        	for( Quote quote : testQuotes )
            {
                quote.Added_Bonus_Products__c = true;
            }
        }
    }

    @isTest(seeAllData=true)
    static void testGetBonusProducts_lowThreshold()
    {
        QuoteSetupData quoteSetupData = new QuoteSetupData();
        quoteSetupData.setupDefaultOpportunity();
        quoteSetupData.setupQuotes( quoteSetupData.LOW_THRESHOLD_PRICE );

        Test.startTest();
            insert quoteSetupData.quoteLineItems;
        Test.stopTest();

        List<Quote> returnedQuotes = [ SELECT Id, ( SELECT Id, Product_ID__c FROM QuoteLineItems) FROM Quote WHERE Id IN :quoteSetupData.testQuotes ];
        System.assertEquals( quoteSetupData.NUM_OF_QUOTES, quoteSetupData.testQuotes.size(), 'All of the quotes should have been returned' );

        Id expectedBonusProductId = Bonus_Products__c.getInstance().Low_Bonus_Product_Id__c;
        for( Quote returnedQuote : returnedQuotes )
        {
            System.assertEquals( 2, returnedQuote.QuoteLineItems.size(), 'Each quote should have a bonus product added when the price is greater than the threshold' );
            Set<Id> productIds = Pluck.ids('Product_ID__c', returnedQuote.QuoteLineItems );
            System.assert( productIds.contains( expectedBonusProductId ), 'The correct bonus product should have been added to the quote' );
        }
    }

    @isTest(seeAllData=true)
    static void testGetBonusProducts_highThreshold()
    {
        QuoteSetupData quoteSetupData = new QuoteSetupData();
        quoteSetupData.setupDefaultOpportunity();
        quoteSetupData.setupQuotes( quoteSetupData.HIGH_THRESHOLD_PRICE );

        Test.startTest();
            insert quoteSetupData.quoteLineItems;
        Test.stopTest();

        List<Quote> returnedQuotes = [ SELECT Id, ( SELECT Id, Product_ID__c FROM QuoteLineItems) FROM Quote WHERE Id IN :quoteSetupData.testQuotes ];
        System.assertEquals( quoteSetupData.NUM_OF_QUOTES, quoteSetupData.testQuotes.size(), 'All of the quotes should have been returned' );

        Id expectedBonusProductId = Bonus_Products__c.getInstance().High_Bonus_Product_Id__c;
        for( Quote returnedQuote : returnedQuotes )
        {
            System.assertEquals( 2, returnedQuote.QuoteLineItems.size(), 'Each quote should have a bonus product added when the price is greater than the threshold' );
            Set<Id> productIds = Pluck.ids('Product_ID__c', returnedQuote.QuoteLineItems );
            System.assert( productIds.contains( expectedBonusProductId ), 'The correct bonus product should have been added to the quote' );
        }
    }

    @isTest(seeAllData=true)
    static void testGetBonusProducts_belowThreshold()
    {
        QuoteSetupData quoteSetupData = new QuoteSetupData();
        quoteSetupData.setupDefaultOpportunity();
        quoteSetupData.setupQuotes( quoteSetupData.BELOW_THRESHOLD_PRICE );

        Test.startTest();
            insert quoteSetupData.quoteLineItems;
        Test.stopTest();

        List<Quote> returnedQuotes = [ SELECT Id, ( SELECT Id, Product_ID__c FROM QuoteLineItems) FROM Quote WHERE Id IN :quoteSetupData.testQuotes ];
        System.assertEquals( quoteSetupData.NUM_OF_QUOTES, quoteSetupData.testQuotes.size(), 'All of the quotes should have been returned' );

        for( Quote returnedQuote : returnedQuotes )
        {
            System.assertEquals( 1, returnedQuote.QuoteLineItems.size(), 'Each quote should not have a bonus product added when the price is lower than the threshold' );
            System.assertEquals( quoteSetupData.testProduct.Id, returnedQuote.QuoteLineItems[0].Product_ID__c, 'The bonus product should not have been added' );
        }
    }
    
    @isTest(seeAllData=true)
    static void testAddedBonusCheckedOnQuotes_QuoteNotChecked()
    {
        QuoteSetupData quoteSetupData = new QuoteSetupData();
        quoteSetupData.setupDefaultOpportunity();
        quoteSetupData.setupQuotes( quoteSetupData.HIGH_THRESHOLD_PRICE );

        Test.startTest();
            insert quoteSetupData.quoteLineItems;
        Test.stopTest();

        List<Quote> returnedQuotes = [ SELECT Added_Bonus_Products__c FROM Quote WHERE Id IN :quoteSetupData.testQuotes ];
        System.assertEquals( quoteSetupData.NUM_OF_QUOTES, quoteSetupData.testQuotes.size(), 'All of the quotes should have been returned' );

        for( Quote returnedQuote : returnedQuotes )
        {
            System.assert( returnedQuote.Added_Bonus_Products__c, 'The quote should be marked that bonus products were added' );
        }
    }

    @isTest(seeAllData=true)
    static void testAddedBonusCheckedOnQuotes_QuoteChecked()
    {
        QuoteSetupData quoteSetupData = new QuoteSetupData();
        quoteSetupData.setupDefaultOpportunity();
        quoteSetupData.setupQuotes( quoteSetupData.HIGH_THRESHOLD_PRICE );
        quoteSetupData.setAddedBonusProductsOnQuotes();
        update quoteSetupData.testQuotes;

        Test.startTest();
            insert quoteSetupData.quoteLineItems;
        Test.stopTest();

        List<Quote> returnedQuotes = [ SELECT ( SELECT Product_ID__c FROM QuoteLineItems) FROM Quote WHERE Id IN :quoteSetupData.testQuotes ];
        System.assertEquals( quoteSetupData.NUM_OF_QUOTES, quoteSetupData.testQuotes.size(), 'All of the quotes should have been returned' );

        for( Quote returnedQuote : returnedQuotes )
        {
            System.assertEquals( 1, returnedQuote.QuoteLineItems.size(), 'The quote should not have bonus products if Added Bonus Products is true on the quote' );
            System.assertEquals( quoteSetupData.testProduct.Id, returnedQuote.QuoteLineItems[0].Product_ID__c, 'Only the inserted product should be on the quote' );
        }
    }

/*
    @isTest(seeAllData=true)
    static void testGetBonusProducts_Renewal()
    {
        QuoteSetupData quoteSetupData = new QuoteSetupData();
        quoteSetupData.setupRenewalOpportunity();
        quoteSetupData.setupQuotes( quoteSetupData.HIGH_THRESHOLD_PRICE );

        Test.startTest();
            insert quoteSetupData.quoteLineItems;
        Test.stopTest();

        List<Quote> returnedQuotes = [ SELECT Id, ( SELECT Id, Product_ID__c FROM QuoteLineItems) FROM Quote WHERE Id IN :quoteSetupData.testQuotes ];
        System.assertEquals( quoteSetupData.NUM_OF_QUOTES, quoteSetupData.testQuotes.size(), 'All of the quotes should have been returned' );

        for( Quote returnedQuote : returnedQuotes )
        {
            for (QuoteLineItem item : returnedQuote.QuoteLineItems) {
                System.debug('Line Item added: ' + item);
            }
            System.assertEquals( 1, returnedQuote.QuoteLineItems.size(), 'Quotes that are part of a renewal should not get a bonus product' );
            System.assertEquals( quoteSetupData.testProduct.Id, returnedQuote.QuoteLineItems[0].Product_ID__c, 'The bonus product should not have been added' );
        }
    }
    */

    static testMethod void testUpdateParentOpportunityAccountTypeSold_OnInsert()
    {
        final Integer NUM_OF_OPPS = Limits.getLimitQueries() + 1;
        final String EXPECTED_PRODUCT_TIER = 'Business';

        TestUtils.createQuoteMachineSettings();
        List<Opportunity> testOpportunities = OpportunityTestFactory.createOpportunities( NUM_OF_OPPS );
        List<Quote> testQuotes = QuoteTestFactory.buildQuotes( testOpportunities, null );
        TestUtils.setSObjectFields( testQuotes, 'Product_Tier__c', EXPECTED_PRODUCT_TIER );

        Test.startTest();
            insert testQuotes;
        Test.stopTest();

        testOpportunities = [SELECT Account_Type_Sold__c FROM Opportunity WHERE Id IN :testOpportunities ];
        System.assertEquals( NUM_OF_OPPS, testOpportunities.size(), 'All of the opportunities should have been returned' );

        for( Opportunity opportunity : testOpportunities )
        {
            System.assertEquals( EXPECTED_PRODUCT_TIER, opportunity.Account_Type_Sold__c, 'The opportunities should have been updated with the quote product tier' );
        }
    }

    static testMethod void testUpdateParentOpportunityAccountTypeSold_OnUpdate()
    {
        final Integer NUM_OF_OPPS = Limits.getLimitQueries() + 1;
        final String EXPECTED_PRODUCT_TIER = 'Business';

        TestUtils.createQuoteMachineSettings();
        List<Opportunity> testOpportunities = OpportunityTestFactory.createOpportunities( NUM_OF_OPPS );
        List<Quote> testQuotes = QuoteTestFactory.createQuotes( testOpportunities, null );
        TestUtils.setSObjectFields( testQuotes, 'Product_Tier__c', EXPECTED_PRODUCT_TIER );

        Test.startTest();
            update testQuotes;
        Test.stopTest();

        testOpportunities = [SELECT Account_Type_Sold__c FROM Opportunity WHERE Id IN :testOpportunities ];
        System.assertEquals( NUM_OF_OPPS, testOpportunities.size(), 'All of the opportunities should have been returned' );

        for( Opportunity opportunity : testOpportunities )
        {
            System.assertEquals( EXPECTED_PRODUCT_TIER, opportunity.Account_Type_Sold__c, 'The opportunities should have been updated with the quote product tier' );
        }
    }
}