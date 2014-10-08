@isTest
private class QuoteLineItemTriggerTest
{
	final static Integer NUM_OF_QUOTES = 3;
	final static Integer PS_THRESHOLD = QuoteLineItemServicesTest.PS_THRESHOLD;
	
	@isTest(seeAllData=true)
	static void testCreatePairedProducts_onInsert()
	{
		QuoteLineItemServicesTest.setupProductPairings();
		Opportunity opportunity = OpportunityTestFactory.createOpportunity();
		List<Quote> newAgreements = QuoteTestFactory.createNewAgreementQuotes( NUM_OF_QUOTES, opportunity );
		
		List<QuoteLineItem> licenseItems = new List<QuoteLineItem>();
		for( Quote newAgreement : newAgreements )
		{
			licenseItems.add( QuoteLineItemServicesTest.buildLicenseItem( newAgreement, PS_THRESHOLD - 1 ) );
		}
		
		Test.startTest();
			insert licenseItems;
		Test.stopTest();

		List<QuoteLineItem> insertedQuoteLineItems = [SELECT Id, QuoteId, PricebookEntryId FROM QuoteLineItem WHERE QuoteId IN :newAgreements AND Id NOT IN :licenseItems ];

		System.assertEquals( NUM_OF_QUOTES * 3, insertedQuoteLineItems.size(), 'All of the paired products should be returned' );
		
		Map<Id, List<QuoteLineItem>> quoteIdtoQuoteLineItems = GroupBy.ids('QuoteId', insertedQuoteLineItems);
		System.assertEquals( NUM_OF_QUOTES, quoteIdtoQuoteLineItems.size(), 'There should be a list of quote line items for each quote affected' );
		
		for( Id quoteId : quoteIdtoQuoteLineItems.keySet() )
		{
			List<QuoteLineItem> pairedQuoteItems = quoteIdtoQuoteLineItems.get( quoteId );
			System.assertEquals( 3, pairedQuoteItems.size(), 'Each quote should have the correct number of paired products' );
			Set<Id> pairedPricebookEntryIds = Pluck.ids( 'PricebookEntryId', pairedQuoteItems );
			System.assert( QuoteLineItemServicesTest.expectedBelowThresholdPricebookEntryIds.containsAll( pairedPricebookEntryIds ), 'Only the paired products should be returned' );
		}
	}

	@isTest(seeAllData=true)
	static void testMarkQuoteWithAddedBonusProducts_pairedAreBonus()
	{
		Product2 licenseProduct = ProductTestFactory.createProduct();
		String licenseProduct15Id = String.valueOf(licenseProduct.Id).left(15);
		PricebookEntry licensePricebookEntry = ProductTestFactory.createPricebookEntry( licenseProduct );
		
		TestUtils.createBonusProductsSetting( TestUtils.STANDARD_PRICEBOOK.Id );
		Product_Pairings__c productPairingSetting = new Product_Pairings__c();
		productPairingSetting.Name = licenseProduct15Id;
		productPairingSetting.Paired_Products__c = Bonus_Products__c.getInstance().High_Bonus_Product_Id__c;
		
		System.runAs( TestUtils.ADMIN_USER )
		{
			insert productPairingSetting;
		}
		
		Opportunity opportunity = OpportunityTestFactory.createOpportunity();
		List<Quote> newAgreements = QuoteTestFactory.createNewAgreementQuotes( NUM_OF_QUOTES, opportunity );
		
		List<QuoteLineItem> licenseItems = QuoteTestFactory.buildQuoteLineItems( newAgreements, licensePricebookEntry );
		
		Test.startTest();
			insert licenseItems;
		Test.stopTest();

		List<Quote> updateQuotes = [SELECT Added_Bonus_Products__c FROM Quote WHERE Id IN :newAgreements ];

		System.assertEquals( NUM_OF_QUOTES , updateQuotes.size(), 'All of the quotes should be returned' );
		for( Quote quote : updateQuotes )
		{
			System.assert( quote.Added_Bonus_Products__c, 'The quote should be marked that bonus products were added' );
		}
	}

	@isTest(seeAllData=true)
	static void testCreatePairedProducts_onUnDelete()
	{
		QuoteLineItemServicesTest.setupProductPairings();
		Opportunity opportunity = OpportunityTestFactory.createOpportunity();
		List<Quote> newAgreements = QuoteTestFactory.createNewAgreementQuotes( NUM_OF_QUOTES, opportunity );
		
		List<QuoteLineItem> licenseItems = new List<QuoteLineItem>();
		for( Quote newAgreement : newAgreements )
		{
			licenseItems.add( QuoteLineItemServicesTest.buildLicenseItem( newAgreement, PS_THRESHOLD - 1 ) );
		}
		insert licenseItems;
		
		delete licenseItems;
		
		List<QuoteLineItem> remainingQuoteLineItems = [SELECT Product_Id__c FROM QuoteLineItem WHERE QuoteId IN :newAgreements ];
		
		System.assert( remainingQuoteLineItems.isEmpty(), 'There should be no remaining line items' );
		
		Test.startTest();
			undelete licenseItems;
		Test.stopTest();
		
		List<QuoteLineItem> undeletedQuoteLineItems = [SELECT Id, QuoteId, PricebookEntryId FROM QuoteLineItem WHERE QuoteId IN :newAgreements AND Id NOT IN :licenseItems ];

		System.assertEquals( NUM_OF_QUOTES * 3, undeletedQuoteLineItems.size(), 'All of the paired products should be returned' );
		
		Map<Id, List<QuoteLineItem>> quoteIdtoQuoteLineItems = GroupBy.ids('QuoteId', undeletedQuoteLineItems);
		System.assertEquals( NUM_OF_QUOTES, quoteIdtoQuoteLineItems.size(), 'There should be a list of quote line items for each quote affected' );
		
		for( Id quoteId : quoteIdtoQuoteLineItems.keySet() )
		{
			List<QuoteLineItem> pairedQuoteItems = quoteIdtoQuoteLineItems.get( quoteId );
			System.assertEquals( 3, pairedQuoteItems.size(), 'Each quote should have the correct number of paired products' );
			Set<Id> pairedPricebookEntryIds = Pluck.ids( 'PricebookEntryId', pairedQuoteItems );
			System.assert( QuoteLineItemServicesTest.expectedBelowThresholdPricebookEntryIds.containsAll( pairedPricebookEntryIds ), 'Only the paired products should be returned' );
		}
	}

	@isTest(seeAllData=true)
	static void testCreatePairedProducts_leaveOutExistingProducts_onInsert()
	{
		QuoteLineItemServicesTest.setupProductPairings();
		PricebookEntry cloudStoragePricebookEntry = QuoteLineItemServicesTest.productIdToPricebookEntry.get( QuoteLineItemServicesTest.cloudStorage.Id );
		Opportunity opportunity = OpportunityTestFactory.createOpportunity();
		List<Quote> newAgreements = QuoteTestFactory.createNewAgreementQuotes( NUM_OF_QUOTES, opportunity );
		
		List<QuoteLineItem> licenseItems = new List<QuoteLineItem>();
		List<QuoteLineItem> existingQuoteLineItems = new List<QuoteLineItem>();
		for( Quote newAgreement : newAgreements )
		{
			licenseItems.add( QuoteLineItemServicesTest.buildLicenseItem( newAgreement, PS_THRESHOLD - 1 ) );
			existingQuoteLineItems.add( QuoteTestFactory.buildQuoteLineItem( newAgreement, cloudStoragePricebookEntry ) );
		}
		insert existingQuoteLineItems;
		
		Test.startTest();
			insert licenseItems;
		Test.stopTest();

		List<QuoteLineItem> insertedQuoteLineItems = [SELECT Id, QuoteId, PricebookEntryId FROM QuoteLineItem WHERE QuoteId IN :newAgreements AND Id NOT IN :licenseItems ];

		System.assertEquals( NUM_OF_QUOTES * 3, insertedQuoteLineItems.size(), 'All of the paired products should be returned' );
		
		Map<Id, List<QuoteLineItem>> quoteIdtoQuoteLineItems = GroupBy.ids('QuoteId', insertedQuoteLineItems);
		System.assertEquals( NUM_OF_QUOTES, quoteIdtoQuoteLineItems.size(), 'There should be a list of quote line items for each quote affected' );
		
		for( Id quoteId : quoteIdtoQuoteLineItems.keySet() )
		{
			List<QuoteLineItem> pairedQuoteItems = quoteIdtoQuoteLineItems.get( quoteId );
			System.assertEquals( 3, pairedQuoteItems.size(), 'Each quote should have the correct number of paired products' );
			Set<Id> pairedPricebookEntryIds = Pluck.ids( 'PricebookEntryId', pairedQuoteItems );
			System.assert( QuoteLineItemServicesTest.expectedBelowThresholdPricebookEntryIds.containsAll( pairedPricebookEntryIds ), 'Only the paired products should be returned' );
		}
	}

	@isTest(seeAllData=true)
	static void testDeletePairedLineItemsOnDelete()
	{
		QuoteLineItemServicesTest.setupProductPairings();
		Product2 nonPairedProduct = ProductTestFactory.createProduct();
		PricebookEntry nonPairedProductPricebookEntry = ProductTestFactory.createPricebookEntry( nonPairedProduct );
		
		Opportunity opportunity = OpportunityTestFactory.createOpportunity();
		List<Quote> newAgreements = QuoteTestFactory.createNewAgreementQuotes( NUM_OF_QUOTES, opportunity );
		
		List<QuoteLineItem> licenseItems = new List<QuoteLineItem>();
		List<QuoteLineItem> allLineItems = new List<QuoteLineItem>();
		for( Quote newAgreement : newAgreements )
		{
			licenseItems.add( QuoteLineItemServicesTest.buildLicenseItem( newAgreement, PS_THRESHOLD - 1 ) );
			allLineItems.add( QuoteTestFactory.buildQuoteLineItem( newAgreement, nonPairedProductPricebookEntry) );
		}
		allLineItems.addAll( licenseItems );
		insert allLineItems;
		
		Test.startTest();
			delete licenseItems;
		Test.stopTest();
		
		List<QuoteLineItem> remainingQuoteLineItems = [SELECT Product_Id__c FROM QuoteLineItem WHERE QuoteId IN :newAgreements ];
		
		System.assertEquals( NUM_OF_QUOTES, remainingQuoteLineItems.size(), 'All of the remaining products should be returned' );
		
		for( QuoteLineItem quoteLineItem : remainingQuoteLineItems )
		{
			System.assertEquals( nonPairedProduct.Id, quoteLineItem.Product_Id__c, 'Only the non paired products should remain' );
		}
	}
	
	@isTest(seeAllData=true)
	static void testPreventInsertOfCompetingQuoteLineItems_hasLowerRankedCompetingItem()
	{
		QuoteLineItemServicesTest.setupCompetingProducts();
		
		Id currentLowerRankedCompetingProductId = QuoteLineItemServicesTest.starterService.Id;
		Quote testQuote = QuoteTestFactory.createNewAgreementQuote();
		QuoteLineItem currentCompetingLineItem = QuoteTestFactory.buildQuoteLineItem( testQuote,
			QuoteLineItemServicesTest.productIdToPricebookEntry.get( currentLowerRankedCompetingProductId ) );
		QuoteLineItem serviceIntegrationLineItem = QuoteTestFactory.buildQuoteLineItem( testQuote,
			QuoteLineItemServicesTest.productIdToPricebookEntry.get( QuoteLineItemServicesTest.serviceIntegration.Id ) );
		
		List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>{ currentCompetingLineItem, serviceIntegrationLineItem };
		insert quoteLineItems;

		QuoteLineItem newCompetingLineItem = QuoteTestFactory.buildQuoteLineItem( testQuote,
			QuoteLineItemServicesTest.productIdToPricebookEntry.get( QuoteLineItemServicesTest.professionalService.Id ) );
		
		String dmlErrorMessage; 
		Test.startTest();
			try
			{
				insert newCompetingLineItem;
			}
			catch( DmlException dmlEx )
			{
				dmlErrorMessage = dmlEx.getMessage();
			}
		Test.stopTest();
		
		System.assertEquals( NULL, dmlErrorMessage, 'There should not be a dmlexception' );
		
		quoteLineItems = [ SELECT Product_Id__c FROM QuoteLineItem WHERE QuoteId = :testQuote.Id ];
		System.assertEquals( 2, quoteLineItems.size(), 'All of the original line items should be returned' );
		System.assertEquals( false, Pluck.ids( 'Product_Id__c', quoteLineItems).contains( QuoteLineItemServicesTest.starterService.Id ), 'The lower ranked competing product should not be line item anymore' );
	}
	
	@isTest(seeAllData=true)
	static void testPreventInsertOfCompetingQuoteLineItems_hasHigherRankedCompetingItem()
	{
		QuoteLineItemServicesTest.setupCompetingProducts();
		
		Quote testQuote = QuoteTestFactory.createNewAgreementQuote();
		QuoteLineItem currentCompetingLineItem = QuoteTestFactory.buildQuoteLineItem( testQuote,
			QuoteLineItemServicesTest.productIdToPricebookEntry.get( QuoteLineItemServicesTest.professionalService.Id ) );
		QuoteLineItem serviceIntegrationLineItem = QuoteTestFactory.buildQuoteLineItem( testQuote,
			QuoteLineItemServicesTest.productIdToPricebookEntry.get( QuoteLineItemServicesTest.serviceIntegration.Id ) );
		
		List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>{ currentCompetingLineItem, serviceIntegrationLineItem };
		insert quoteLineItems;

		Id newLowerRankedCompetingProductId = QuoteLineItemServicesTest.starterService.Id;
		QuoteLineItem newCompetingLineItem = QuoteTestFactory.buildQuoteLineItem( testQuote,
			QuoteLineItemServicesTest.productIdToPricebookEntry.get( newLowerRankedCompetingProductId ) );
		
		String dmlErrorMessage; 
		Test.startTest();
			try
			{
				insert newCompetingLineItem;
			}
			catch( DmlException dmlEx )
			{
				dmlErrorMessage = dmlEx.getMessage();
			}
		Test.stopTest();
		
		System.assert( dmlErrorMessage.contains( QuoteLineItemServices.COMPETING_ITEM_ERROR), 'There should be a dmlexception' );
		
		quoteLineItems = [ SELECT Product_Id__c FROM QuoteLineItem WHERE QuoteId = :testQuote.Id ];
		System.assertEquals( 2, quoteLineItems.size(), 'All of the original line items should be returned' );
		System.assertEquals( false, Pluck.ids( 'Product_Id__c', quoteLineItems).contains( newLowerRankedCompetingProductId ), 'The lower ranked competing product should not be a line item' );
	}
	
	@isTest(seeAllData=true)
	static void testPreventInsertOfCompetingQuoteLineItems_doesNotHaveCompetingItem()
	{
		QuoteLineItemServicesTest.setupCompetingProducts();
		
		Quote testQuote = QuoteTestFactory.createNewAgreementQuote();
		QuoteLineItem nonCompetingLineItem = QuoteTestFactory.buildQuoteLineItem( testQuote,
			QuoteLineItemServicesTest.productIdToPricebookEntry.get( QuoteLineItemServicesTest.cloudStorage.Id ) );
		QuoteLineItem serviceIntegrationLineItem = QuoteTestFactory.buildQuoteLineItem( testQuote,
			QuoteLineItemServicesTest.productIdToPricebookEntry.get( QuoteLineItemServicesTest.serviceIntegration.Id ) );
		
		List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>{ nonCompetingLineItem, serviceIntegrationLineItem };
		insert quoteLineItems;

		Id newCompetingProductId = QuoteLineItemServicesTest.professionalService.Id;
		QuoteLineItem newCompetingLineItem = QuoteTestFactory.buildQuoteLineItem( testQuote,
			QuoteLineItemServicesTest.productIdToPricebookEntry.get( newCompetingProductId ) );
		
		String dmlErrorMessage; 
		Test.startTest();
			try
			{
				insert newCompetingLineItem;
			}
			catch( DmlException dmlEx )
			{
				dmlErrorMessage = dmlEx.getMessage();
			}
		Test.stopTest();
		
		System.assertEquals( NULL, dmlErrorMessage, 'There should not be a dmlexception' );
		
		quoteLineItems = [ SELECT Product_Id__c FROM QuoteLineItem WHERE QuoteId = :testQuote.Id ];
		System.assertEquals( 3, quoteLineItems.size(), 'All of the line items should be returned' );
		System.assert( Pluck.ids( 'Product_Id__c', quoteLineItems).contains( newCompetingProductId ), 'The new competing product should not be a line item' );
	}

	@isTest(seeAllData=true)
	static void testPreventInsertOfCompetingQuoteLineItems_addNonCompetingItem()
	{
		QuoteLineItemServicesTest.setupCompetingProducts();
		
		Quote testQuote = QuoteTestFactory.createNewAgreementQuote();
		QuoteLineItem currentCompetingLineItem = QuoteTestFactory.buildQuoteLineItem( testQuote,
			QuoteLineItemServicesTest.productIdToPricebookEntry.get( QuoteLineItemServicesTest.starterService.Id ) );
		
		insert currentCompetingLineItem;

		Id newCompetingProductId = QuoteLineItemServicesTest.cloudStorage.Id;
		QuoteLineItem nonCompetingLineItem = QuoteTestFactory.buildQuoteLineItem( testQuote,
			QuoteLineItemServicesTest.productIdToPricebookEntry.get( QuoteLineItemServicesTest.cloudStorage.Id ) );
		
		String dmlErrorMessage; 
		Test.startTest();
			try
			{
				insert nonCompetingLineItem;
			}
			catch( DmlException dmlEx )
			{
				dmlErrorMessage = dmlEx.getMessage();
			}
		Test.stopTest();
		
		System.assertEquals( NULL, dmlErrorMessage, 'There should not be a dmlexception' );
		
		List<QuoteLineItem> quoteLineItems = [ SELECT Product_Id__c FROM QuoteLineItem WHERE QuoteId = :testQuote.Id ];
		System.assertEquals( 2, quoteLineItems.size(), 'Both of the line items should be returned' );
		System.assert( Pluck.ids( 'Product_Id__c', quoteLineItems).contains( newCompetingProductId ), 'The non competing product should  be a line item' );
	}
	
	public static List<QuoteLineItem> setupQuoteLineItemsForProductTiers( Id pricebookId )
	{
		Product2 businessProduct = ProductTestFactory.buildProduct();
		Product2 eliteProduct = ProductTestFactory.buildProduct();

		insert new List<Product2>{ businessProduct, eliteProduct };

		TestUtils.createProductTierSettings( new List<Product2> { businessProduct, eliteProduct } );

		PricebookEntry standardBusinessPricebookEntry = ProductTestFactory.buildPricebookEntry( businessProduct );
		PricebookEntry standardElitePricebookEntry = ProductTestFactory.buildPricebookEntry( eliteProduct );
		
		insert new List<PricebookEntry> { standardBusinessPricebookEntry, standardElitePricebookEntry };
		
		PricebookEntry businessPricebookEntry = ProductTestFactory.buildPricebookEntry( businessProduct, pricebookId );
		PricebookEntry elitePricebookEntry = ProductTestFactory.buildPricebookEntry( eliteProduct, pricebookId );

		insert new List<PricebookEntry> { businessPricebookEntry, elitePricebookEntry };

		Opportunity opportunity = OpportunityTestFactory.createOpportunity();
		Quote businessQuote = QuoteTestFactory.buildQuote( opportunity, pricebookId );
		Quote eliteQuote = QuoteTestFactory.buildQuote( opportunity, pricebookId );

		insert new List<Quote> { businessQuote, eliteQuote };

		QuoteLineItem businessQuoteLineItem = QuoteTestFactory.buildQuoteLineItem(businessQuote, businessPricebookEntry);
		QuoteLineItem eliteQuoteLineItem = QuoteTestFactory.buildQuoteLineItem(eliteQuote, elitePricebookEntry);

		return new List<QuoteLineItem>{ businessQuoteLineItem, eliteQuoteLineItem };
	}
	
	@isTest(seeAllData=true)
	static void testSetQuoteProductTier_onInsert_CurrentPricebook()
	{
		TestUtils.createPricebookSettings();
		List<QuoteLineItem> allQuoteLineItems = setupQuoteLineItemsForProductTiers( Pricebook_Setting__c.getInstance( 'Current' ).Id__c );
		
		Test.startTest();
			insert allQuoteLineItems;
		Test.stopTest();

		List<Quote> updatedQuotes = [SELECT Id, Product_Tier__c, (SELECT Product_ID__c FROM QuoteLineItems ) FROM Quote WHERE Id IN :Pluck.ids( 'QuoteId', allQuoteLineItems ) ];
		System.assertEquals( 2, updatedQuotes.size(), 'All of the quotes should remain' );
		
		for( Quote quote : updatedQuotes )
		{
			System.assertEquals( 1, quote.QuoteLineItems.size(), 'The quote line items should still be on the quote' );
			String relatedProductId = quote.QuoteLineItems[0].Product_ID__c;
			String expectedProductTier = Product_Tier__c.getInstance( relatedProductId ).Product_Tier__c;
			String actualProductTier = quote.Product_Tier__c;
			System.assertEquals( expectedProductTier, actualProductTier, 'The product tier should be set correctly' );
		}
	}

	@isTest(seeAllData=true)
	static void testSetQuoteProductTier_onInsert_DefaultPricebook()
	{
		TestUtils.createPricebookSettings();
		List<QuoteLineItem> allQuoteLineItems = setupQuoteLineItemsForProductTiers( Pricebook_Setting__c.getInstance( 'Legacy' ).Id__c );
		
		Test.startTest();
			insert allQuoteLineItems;
		Test.stopTest();

		List<Quote> updatedQuotes = [SELECT Id, Product_Tier__c, (SELECT Product_ID__c FROM QuoteLineItems ) FROM Quote WHERE Id IN :Pluck.ids( 'QuoteId', allQuoteLineItems ) ];
		System.assertEquals( 2, updatedQuotes.size(), 'All of the quotes should remain' );
		
		for( Quote quote : updatedQuotes )
		{
			System.assertEquals( 1, quote.QuoteLineItems.size(), 'The quote line items should still be on the quote' );
			String relatedProductId = quote.QuoteLineItems[0].Product_ID__c;
			String expectedProductTier = QuoteLineItemServices.LEGACY_PREFIX + Product_Tier__c.getInstance( relatedProductId ).Product_Tier__c;
			String actualProductTier = quote.Product_Tier__c;
			System.assertEquals( expectedProductTier, actualProductTier, 'The product tier should be set correctly' );
		}
	}
	
	@isTest(seeAllData=true)
	static void testSetQuoteProductTier_onInsert_NonLicenseItem()
	{
		TestUtils.createPricebookSettings();
		Id pricebookId = Pricebook_Setting__c.getInstance( 'Current' ).Id__c;
		Product2 licenseProduct = ProductTestFactory.buildProduct();
		Product2 nonLicenseProduct = ProductTestFactory.buildProduct();

		insert new List<Product2>{ licenseProduct, nonLicenseProduct };

		TestUtils.createProductTierSettings( new List<Product2> { licenseProduct } );

		PricebookEntry standardNonlicensePricebookEntry = ProductTestFactory.buildPricebookEntry( nonLicenseProduct );
		PricebookEntry nonlicensePricebookEntry = ProductTestFactory.buildPricebookEntry( nonLicenseProduct, pricebookId );

		insert new List<PricebookEntry> { standardNonlicensePricebookEntry, nonlicensePricebookEntry };

		Opportunity opportunity = OpportunityTestFactory.createOpportunity();
		Quote nonLicenseQuote = QuoteTestFactory.createQuote( opportunity, pricebookId );
		QuoteLineItem nonLicenseQuoteLineItem = QuoteTestFactory.buildQuoteLineItem(nonLicenseQuote, nonlicensePricebookEntry);
		
		Test.startTest();
			insert nonLicenseQuoteLineItem;
		Test.stopTest();
		
		nonLicenseQuote = [SELECT Id, Product_Tier__c FROM Quote WHERE Id = :nonLicenseQuote.Id ];
		System.assert( String.isBlank( nonLicenseQuote.Product_Tier__c), 'The product tier should not get when inserting a non license product line item' );
	}
}