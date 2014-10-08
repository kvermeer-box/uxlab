@isTest
public class QuoteLineItemServicesTest
{
	public final static Integer PS_THRESHOLD = 100;
	final static Integer NUM_OF_QUOTES = 3;
	final static Id LICENSE_PRODUCT_ID = '01t60000001xre8'; //hardcoded because it is in Business_Enterprise_Unlimited_Seats__c rollup field in Quote
	final static String LICENSE_PRODUCT_ID_STRING = '01t60000001xre8'; //Apex automatically uses the 18 digit ID, even if you define the id as the 15 digit id

	public static Product2 cloudStorage;
	public static Product2 serviceIntegration;
	public static Product2 professionalService;
	public static Product2 starterService;
	static Product_Pairings__c productPairingSetting;
	static Integer expectedNumOfPairedProducts;
	static Product2 testPricingProduct;
	static Product2 testPricingProduct2;

	public static Map<Id,PricebookEntry> productIdToPricebookEntry;
	public static Set<Id> expectedAboveThresholdPricebookEntryIds;
	public static Set<Id> expectedBelowThresholdPricebookEntryIds;

	static PricebookEntry licensePricebookEntry
	{
		get
		{
			if( licensePricebookEntry == NULL )
			{
				licensePricebookEntry = [ SELECT Id, Product2.Name FROM PricebookEntry
										  WHERE Product2Id = :LICENSE_PRODUCT_ID AND CurrencyIsoCode = 'USD' AND Pricebook2Id = :TestUtils.STANDARD_PRICEBOOK.ID LIMIT 1];
			}
			return licensePricebookEntry;
		}
		private set;
	}

	static void setupProducts()
	{
		professionalService = ProductTestFactory.buildProduct();
		starterService = ProductTestFactory.buildProduct();
		cloudStorage = ProductTestFactory.buildProduct();
		serviceIntegration = ProductTestFactory.buildProduct();

		List<Product2> pairedProducts = new List<Product2>{ professionalService, starterService, cloudStorage, serviceIntegration };
		insert pairedProducts;
		expectedNumOfPairedProducts = pairedProducts.size() - 1;

		productIdToPricebookEntry = new Map<Id,PricebookEntry>();
		for( PricebookEntry entry :  ProductTestFactory.createPricebookEntries( pairedProducts ) )
		{
			productIdToPricebookEntry.put( entry.Product2Id, entry );
		}

		expectedBelowThresholdPricebookEntryIds = new Set<Id>{ productIdToPricebookEntry.get( starterService.Id ).Id,
														productIdToPricebookEntry.get( cloudStorage.Id ).Id,
														productIdToPricebookEntry.get( serviceIntegration.Id).Id };
		expectedAboveThresholdPricebookEntryIds = new Set<Id>{ productIdToPricebookEntry.get( professionalService.Id ).Id,
														productIdToPricebookEntry.get( cloudStorage.Id ).Id,
														productIdToPricebookEntry.get( serviceIntegration.Id).Id };

	}

	public static void setupProductPairings()
	{
		setupProducts();
		productPairingSetting = Product_Pairings__c.getInstance( LICENSE_PRODUCT_ID_STRING ) != NULL ? Product_Pairings__c.getInstance( LICENSE_PRODUCT_ID_STRING ) :
			new Product_Pairings__c( Name = LICENSE_PRODUCT_ID_STRING );
		productPairingSetting.Paired_Products__c = cloudStorage.Id + ',' + serviceIntegration.Id;
		productPairingSetting.Above_Threshold_PS__c = professionalService.Id;
		productPairingSetting.Below_Threshold_PS__c = starterService.Id;
		productPairingSetting.Seat_Threshold__c = PS_THRESHOLD;

		System.runAs( TestUtils.ADMIN_USER )
		{
			upsert productPairingSetting;
		}
	}

	public static void setupCompetingProducts()
	{
		setupProducts();
		List<Competing_Product__c> competingProductsSettings = new List<Competing_Product__c>();
		Competing_Product__c starterSetting = TestUtils.buildCompetingProductSetting( starterService );
		starterSetting.Seniority_Rank__c = 1;
		Competing_Product__c professionalSetting = TestUtils.buildCompetingProductSetting( professionalService );
		professionalSetting.Seniority_Rank__c = 2;
		
		competingProductsSettings.add( starterSetting );
		competingProductsSettings.add( professionalSetting );

		System.runAs( TestUtils.ADMIN_USER )
		{
			insert competingProductsSettings;
		}
	}

	public static QuoteLineItem buildLicenseItem( Quote quote, Integer quantity )
	{
		QuoteLineItem quoteLineItem = QuoteTestFactory.buildQuoteLineItem( quote, licensePricebookEntry );
		quoteLineItem.Quantity = quantity;
		return quoteLineItem;
	}

	static List<QuoteLineItem> requeryforQuoteLineItems( List<QuoteLineItem> quoteLineItems )
	{
		return [SELECT Quantity, QuoteId, Product_ID__c, Parent_Quote_Pricebook__c, Parent_Quote_Created_Date__c, PricebookEntryId, CurrencyIsoCode
				FROM QuoteLineItem WHERE Id IN :quoteLineItems ];
	}

	@isTest(seeAllData=true)
	static void testFilterQuoteLineItemsWithPairs()
	{
		setupProductPairings();
		QuoteLineItemServices.LEGACY_DATE = Date.today().addYears(-1);
		Opportunity opportunity = OpportunityTestFactory.createOpportunity();
		List<Quote> newAgreements = QuoteTestFactory.createNewAgreementQuotes( NUM_OF_QUOTES, opportunity );

		QuoteLineItem nonLicenseItem = QuoteTestFactory.buildQuoteLineItem( newAgreements[0], productIdToPricebookEntry.get( cloudStorage.Id ) );
		List<QuoteLineItem> licenseItems = new List<QuoteLineItem>();
		for( Integer i = 1; i < newAgreements.size(); i++ )
		{
			licenseItems.add( buildLicenseItem( newAgreements[i], PS_THRESHOLD + 1 ) );
		}

		List<QuoteLineItem> allLineItems = new List<QuoteLineItem>();
		allLineItems.addAll( licenseItems );
		allLineItems.add( nonLicenseItem );

		insert allLineItems;
		allLineItems = requeryforQuoteLineItems( allLineItems );

		Test.startTest();
			List<QuoteLineItem> filteredQuoteLineItems = QuoteLineItemServices.filterQuoteLineItemsWithPairs( allLineItems );
		Test.stopTest();

		System.assertEquals( licenseItems.size(), filteredQuoteLineItems.size(), 'All of the line items with paired products should be returned' );

		for( QuoteLineItem filteredQuoteLineItem : filteredQuoteLineItems )
		{
			System.assertEquals( licensePricebookEntry.Id, filteredQuoteLineItem.PricebookEntryId );
		}
	}

	@isTest(seeAllData=true)
	static void testFilterQuoteLineItemsWithPairs_legacyDate()
	{
		setupProductPairings();
		Opportunity opportunity = OpportunityTestFactory.createOpportunity();
		List<Quote> newAgreements = QuoteTestFactory.createNewAgreementQuotes( NUM_OF_QUOTES, opportunity );

		//We can't control the created date on a object so we the legacy date to the future
		QuoteMachine_AddProductsController.LEGACY_DATE = Date.today().addYears(1);

		List<QuoteLineItem> licenseItems = new List<QuoteLineItem>();
		for( Integer i = 1; i < newAgreements.size(); i++ )
		{
			licenseItems.add( buildLicenseItem( newAgreements[i], PS_THRESHOLD + 1 ) );
		}

		insert licenseItems;
		licenseItems = requeryforQuoteLineItems( licenseItems );
		Test.startTest();
			List<QuoteLineItem> filteredQuoteLineItems = QuoteLineItemServices.filterQuoteLineItemsWithPairs( licenseItems );
		Test.stopTest();

		System.assert( filteredQuoteLineItems.isEmpty(), 'Legacy quotes should not be returned' );
	}

	@isTest(seeAllData=true)
	static void deDupePairedLineItems()
	{
		final Integer NUM_OF_PRODUCTS = 10;
		List<Product2> products = ProductTestFactory.createProducts( NUM_OF_PRODUCTS );
		List<PricebookEntry> pricebookEntries = ProductTestFactory.createPricebookEntries( products );
		Quote testQuote = QuoteTestFactory.createNewAgreementQuote();
		QuoteLineItem existingQuoteLineItem = QuoteTestFactory.createQuoteLineItem( testQuote, pricebookEntries[0] );

		testQuote= [SELECT (SELECT PricebookEntryId FROM QuoteLineItems ) FROM Quote WHERE Id = :testQuote.Id ];
		List<QuoteLineItem> newQuoteLineItems = new List<QuoteLineItem>();
		for( PricebookEntry pricebookEntry : pricebookEntries )
		{
			newQuoteLineItems.add( QuoteTestFactory.buildQuoteLineItem( testQuote, pricebookEntry ) );
		}
		Test.startTest();
			List<QuoteLineItem> deDupedPairedLineItems = QuoteLineItemServices.deDupePairedLineItems( newQuoteLineItems, testQuote );
		Test.stopTest();

		System.assertEquals( NUM_OF_PRODUCTS - 1 , deDupedPairedLineItems.size(), 'The quote line item that already exists on the quote should not be returned' );
		Set<Id> deDupedLineItemPricebookIds = Pluck.ids( 'PricebookEntryId', deDupedPairedLineItems );
		System.assert( !deDupedLineItemPricebookIds.contains( existingQuoteLineItem.PricebookEntryId ), 'The quote line item that already exists on the quote should not be returned' );
	}

	static testMethod void testBuildPairedProducts()
	{
		final Integer NUM_OF_ENTRIES = 10;
		final Double UNIT_PRICE = 10.0;

		QuoteLineItem quoteLineItem = new QuoteLineItem();
		quoteLineItem.quoteId = TestUtils.generateSObjectDummyId( new Quote() );
		List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
		for( Integer i = 0; i < NUM_OF_ENTRIES; i ++)
		{
			PricebookEntry entry = new PricebookEntry( UnitPrice = UNIT_PRICE );
			TestUtils.generateSObjectDummyId( entry );
			pricebookEntries.add( entry );
		}

		Test.startTest();
			List<QuoteLineItem> actualQuoteLineItems = QuoteLineItemServices.buildPairedLineItems( quoteLineItem, pricebookEntries );
		Test.stopTest();

		System.assertEquals( 10, actualQuoteLineItems.size(), 'All of the paired products should be returned' );

		Set<Id> expectPricebookEntryIds = Pluck.ids( pricebookEntries );
		Set<Id> actualPricebookEntryIds = Pluck.ids( 'PricebookEntryId', actualQuoteLineItems );

		System.assert( expectPricebookEntryIds.containsAll( actualPricebookEntryIds ), 'Only the paired products should be returned' );
		System.assert( actualPricebookEntryIds.containsAll( expectPricebookEntryIds ), 'All of the paired products should be returned' );
	}

	@isTest(seeAllData=true)
	static void testGetPairedProducts_aboveThreshold()
	{
		setupProductPairings();
		Opportunity opportunity = OpportunityTestFactory.createOpportunity();
		List<Quote> newAgreements = QuoteTestFactory.createNewAgreementQuotes( NUM_OF_QUOTES, opportunity );

		List<QuoteLineItem> licenseItems = new List<QuoteLineItem>();
		for( Quote newAgreement : newAgreements )
		{
			licenseItems.add( buildLicenseItem( newAgreement, PS_THRESHOLD + 1 ) );
		}
		insert licenseItems;

		//trigger creates paired quote line items, need to delete them all for unit test
		delete [SELECT Id FROM QuoteLineItem WHERE QuoteId IN :newAgreements AND Id NOT IN :licenseItems ];
		licenseItems = requeryforQuoteLineItems( licenseItems );

		Test.startTest();
			List<QuoteLineItem> actualQuoteLineItems = QuoteLineItemServices.getPairedProducts( licenseItems );
		Test.stopTest();
		System.assertEquals( NUM_OF_QUOTES * expectedNumOfPairedProducts, actualQuoteLineItems.size(), 'All of the paired products should be returned' );

		Map<Id, List<QuoteLineItem>> quoteIdtoQuoteLineItems = GroupBy.ids('QuoteId', actualQuoteLineItems);
		System.assertEquals( NUM_OF_QUOTES, quoteIdtoQuoteLineItems.size(), 'There should be a list of quote line items for each quote affected' );

		for( Id quoteId : quoteIdtoQuoteLineItems.keySet() )
		{
			List<QuoteLineItem> pairedQuoteItems = quoteIdtoQuoteLineItems.get( quoteId );
			System.assertEquals( expectedNumOfPairedProducts, pairedQuoteItems.size(), 'Each quote should have the correct number of paired products' );
			Set<Id> pairedPricebookEntryIds = Pluck.ids( 'PricebookEntryId', pairedQuoteItems );
			System.assert( expectedAboveThresholdPricebookEntryIds.containsAll( pairedPricebookEntryIds ), 'Only the paired products should be returned' );
		}
	}

	@isTest(seeAllData=true)
	static void testGetPairedProducts_belowThreshold()
	{
		setupProductPairings();
		Opportunity opportunity = OpportunityTestFactory.createOpportunity();
		List<Quote> newAgreements = QuoteTestFactory.createNewAgreementQuotes( NUM_OF_QUOTES, opportunity );

		List<QuoteLineItem> licenseItems = new List<QuoteLineItem>();
		for( Quote newAgreement : newAgreements )
		{
			licenseItems.add( buildLicenseItem( newAgreement, PS_THRESHOLD - 1 ) );
		}
		insert licenseItems;

		//trigger creates paired quote line items, need to delete them all for unit test
		delete [SELECT Id FROM QuoteLineItem WHERE QuoteId IN :newAgreements AND Id NOT IN :licenseItems ];
		licenseItems = requeryforQuoteLineItems( licenseItems );

		Test.startTest();
			List<QuoteLineItem> actualQuoteLineItems = QuoteLineItemServices.getPairedProducts( licenseItems );
		Test.stopTest();
		System.assertEquals( NUM_OF_QUOTES * expectedNumOfPairedProducts, actualQuoteLineItems.size(), 'All of the paired products should be returned' );

		Map<Id, List<QuoteLineItem>> quoteIdtoQuoteLineItems = GroupBy.ids('QuoteId', actualQuoteLineItems);
		System.assertEquals( NUM_OF_QUOTES, quoteIdtoQuoteLineItems.size(), 'There should be a list of quote line items for each quote affected' );

		for( Id quoteId : quoteIdtoQuoteLineItems.keySet() )
		{
			List<QuoteLineItem> pairedQuoteItems = quoteIdtoQuoteLineItems.get( quoteId );
			System.assertEquals( expectedNumOfPairedProducts, pairedQuoteItems.size(), 'Each quote should have the correct number of paired products' );
			Set<Id> pairedPricebookEntryIds = Pluck.ids( 'PricebookEntryId', pairedQuoteItems );
			System.assert( expectedBelowThresholdPricebookEntryIds.containsAll( pairedPricebookEntryIds ), 'Only the paired products should be returned' );
		}
	}

	@isTest(seeAllData=true)
	static void testGetQuoteItemIdToPairedProductIds()
	{
		setupProductPairings();
		Opportunity opportunity = OpportunityTestFactory.createOpportunity();
		Quote aboveThresholdQuote = QuoteTestFactory.buildNewAgreementQuote( opportunity );
		Quote belowThresholdQuote = QuoteTestFactory.buildNewAgreementQuote( opportunity );

		insert new List<Quote>{ aboveThresholdQuote, belowThresholdQuote };
		Map<Id,Quote> idToQuote = new Map<Id, Quote>([SELECT (SELECT PricebookEntryId, Product_Id__c FROM QuoteLineItems ) FROM Quote WHERE Id IN ( :aboveThresholdQuote.Id, :belowThresholdQuote.Id) ]);

		QuoteLineItem aboveThresholdQuoteLineItem = buildLicenseItem( aboveThresholdQuote, PS_THRESHOLD + 1 );
		QuoteLineItem belowThresholdQuoteLineItem = buildLicenseItem( belowThresholdQuote, PS_THRESHOLD - 1 );

		List<QuoteLineItem> allQuoteLineItems = new List<QuoteLineItem>{ aboveThresholdQuoteLineItem, belowThresholdQuoteLineItem };
		insert allQuoteLineItems;

		allQuoteLineItems = requeryforQuoteLineItems( allQuoteLineItems );

		Test.startTest();
			Map<Id,Set<Id>> actualQuoteItemIdToPairedEntryIds = QuoteLineItemServices.getQuoteItemIdToPairedProductIds( allQuoteLineItems, idToQuote );
		Test.stopTest();

		Set<Id> expectedAboveThresholdProductIds = new Set<Id>{ professionalService.Id, cloudStorage.Id, serviceIntegration.Id };
		Set<Id> expectedBelowThresholdProductIds = new Set<Id>{ starterService.Id, cloudStorage.Id, serviceIntegration.Id };

		System.assertEquals( 2, actualQuoteItemIdToPairedEntryIds.size(), 'All of the quotes should have a set of paired pricebook entry ids' );
		System.assert( actualQuoteItemIdToPairedEntryIds.keySet().contains( aboveThresholdQuoteLineItem.Id ), 'Each quote should be a key');
		System.assert( actualQuoteItemIdToPairedEntryIds.keySet().contains( belowThresholdQuoteLineItem.Id ), 'Each quote should be a key');

		System.assertEquals( expectedNumOfPairedProducts, actualQuoteItemIdToPairedEntryIds.get(aboveThresholdQuoteLineItem.Id).size(), 'All of the paired products should be returned');
		System.assert( expectedAboveThresholdProductIds.contains( professionalService.Id ), 'Each of the correct paired items should be returned' );
		System.assert( expectedAboveThresholdProductIds.contains( cloudStorage.Id ), 'Each of the correct paired items should be returned' );
		System.assert( expectedAboveThresholdProductIds.contains( serviceIntegration.Id ), 'Each of the correct paired items should be returned' );

		System.assertEquals( expectedNumOfPairedProducts, actualQuoteItemIdToPairedEntryIds.get(belowThresholdQuoteLineItem.Id).size(), 'All of the paired products should be returned');
		System.assert( expectedBelowThresholdProductIds.contains( starterService.Id ), 'Each of the correct paired items should be returned' );
		System.assert( expectedBelowThresholdProductIds.contains( cloudStorage.Id ), 'Each of the correct paired items should be returned' );
		System.assert( expectedBelowThresholdProductIds.contains( serviceIntegration.Id ), 'Each of the correct paired items should be returned' );
	}

	@isTest(seeAllData=true)
	static void testGetQuoteItemIdToPairedProductIds_doesNotHavePrerequisite()
	{
		setupProductPairings();
		Product2 prerequisiteProduct = ProductTestFactory.createProduct();
		productPairingSetting.Prerequisite_Products__c = prerequisiteProduct.Id;
		System.runAs( TestUtils.ADMIN_USER )
		{
			update productPairingSetting;
		}

		Opportunity opportunity = OpportunityTestFactory.createOpportunity();
		Quote testQuote = QuoteTestFactory.createNewAgreementQuote( opportunity );

		QuoteLineItem aboveThresholdQuoteLineItem = buildLicenseItem( testQuote, PS_THRESHOLD + 1 );
		insert aboveThresholdQuoteLineItem;

		Map<Id, Quote> testQuoteMap = new Map<Id, Quote>([SELECT (SELECT Product_Id__c FROM QuoteLineItems ) FROM Quote WHERE Id = :testQuote.Id ]);
		List<QuoteLineItem> databaseQuoteLineItem = requeryforQuoteLineItems( new List<QuoteLineItem>{aboveThresholdQuoteLineItem} );

		Test.startTest();
			Map<Id,Set<Id>> actualQuoteItemIdToPairedProductIds = QuoteLineItemServices.getQuoteItemIdToPairedProductIds( databaseQuoteLineItem, testQuoteMap );
		Test.stopTest();

		Set<Id> expectedAboveThresholdProductIds = new Set<Id>{ cloudStorage.Id, serviceIntegration.Id };

		System.assertEquals( 1, actualQuoteItemIdToPairedProductIds.size(), 'All of the quotes should have a set of paired pricebook entry ids' );
		System.assert( actualQuoteItemIdToPairedProductIds.keySet().contains( aboveThresholdQuoteLineItem.Id ), 'Each quote should be a key');

		System.assert( expectedAboveThresholdProductIds.containsAll( actualQuoteItemIdToPairedProductIds.get(aboveThresholdQuoteLineItem.Id) ), 'All of the correct paired items should be returned' );
		System.assert( actualQuoteItemIdToPairedProductIds.get(aboveThresholdQuoteLineItem.Id).containsAll( expectedAboveThresholdProductIds ), 'Only the correct paired items should be returned' );
	}

	@isTest(seeAllData=true)
	static void testGetQuoteItemIdToPairedProductIds_hasPrerequisite()
	{
		setupProductPairings();
		Product2 prerequisiteProduct = ProductTestFactory.createProduct();
		PricebookEntry prerequisiteProductPricebookEntry = ProductTestFactory.createPricebookEntry( prerequisiteProduct );
		productPairingSetting.Prerequisite_Products__c = prerequisiteProduct.Id;
		System.runAs( TestUtils.ADMIN_USER )
		{
			update productPairingSetting;
		}

		Opportunity opportunity = OpportunityTestFactory.createOpportunity();
		Quote testQuote = QuoteTestFactory.createNewAgreementQuote( opportunity );

		QuoteLineItem aboveThresholdQuoteLineItem = buildLicenseItem( testQuote, PS_THRESHOLD + 1 );
		QuoteLineItem prerequisiteProductQuoteLineItem = QuoteTestFactory.buildQuoteLineItem( testQuote, prerequisiteProductPricebookEntry );

		insert new List<QuoteLineItem>{ aboveThresholdQuoteLineItem, prerequisiteProductQuoteLineItem };

		Map<Id, Quote> testQuoteMap = new Map<Id, Quote>([SELECT (SELECT Product_Id__c FROM QuoteLineItems ) FROM Quote WHERE Id = :testQuote.Id ]);
		List<QuoteLineItem> databaseQuoteLineItem = requeryforQuoteLineItems( new List<QuoteLineItem>{aboveThresholdQuoteLineItem} );

		Test.startTest();
			Map<Id,Set<Id>> actualQuoteItemIdToPairedProductIds = QuoteLineItemServices.getQuoteItemIdToPairedProductIds( databaseQuoteLineItem, testQuoteMap );
		Test.stopTest();

		Set<Id> expectedAboveThresholdProductIds = new Set<Id>{ professionalService.Id, cloudStorage.Id, serviceIntegration.Id };

		System.assertEquals( 1, actualQuoteItemIdToPairedProductIds.size(), 'All of the quotes should have a set of paired pricebook entry ids' );
		System.assert( actualQuoteItemIdToPairedProductIds.keySet().contains( aboveThresholdQuoteLineItem.Id ), 'Each quote should be a key');

		System.assert( expectedAboveThresholdProductIds.containsAll( actualQuoteItemIdToPairedProductIds.get(aboveThresholdQuoteLineItem.Id) ), 'Only of the correct paired items should be returned' );
		System.assert( actualQuoteItemIdToPairedProductIds.get(aboveThresholdQuoteLineItem.Id).containsAll( expectedAboveThresholdProductIds ), 'All of the correct paired items should be returned' );
	}

	@isTest(seeAllData=true)
	static void testGetPairedProducts_leaveOutExistingProducts()
	{
		setupProductPairings();
		PricebookEntry cloudStoragePricebookEntry = productIdToPricebookEntry.get( cloudStorage.Id );

		Opportunity opportunity = OpportunityTestFactory.createOpportunity();
		List<Quote> newAgreements = QuoteTestFactory.createNewAgreementQuotes( NUM_OF_QUOTES, opportunity );

		List<QuoteLineItem> licenseItems = new List<QuoteLineItem>();
		List<QuoteLineItem> existingQuoteLineItems = new List<QuoteLineItem>();
		for( Quote newAgreement : newAgreements )
		{
			licenseItems.add( buildLicenseItem( newAgreement, PS_THRESHOLD - 1 ) );
			existingQuoteLineItems.add( QuoteTestFactory.buildQuoteLineItem( newAgreement, cloudStoragePricebookEntry ) );
		}
		insert licenseItems;
		licenseItems = requeryforQuoteLineItems( licenseItems );

		//trigger creates paired quote line items, need to delete them all for unit test
		delete [SELECT Id FROM QuoteLineItem WHERE QuoteId IN :newAgreements AND Id NOT IN :licenseItems ];

		insert existingQuoteLineItems;

		Set<Id> expectedPricebookEntryIds = new Set<Id>{ productIdToPricebookEntry.get( starterService.Id ).Id,
														productIdToPricebookEntry.get( serviceIntegration.Id ).Id };

		Test.startTest();
			List<QuoteLineItem> actualQuoteLineItems = QuoteLineItemServices.getPairedProducts( licenseItems );
		Test.stopTest();
		System.assertEquals( NUM_OF_QUOTES * 2, actualQuoteLineItems.size(), 'All of the paired products should be returned' );

		Map<Id, List<QuoteLineItem>> quoteIdtoQuoteLineItems = GroupBy.ids('QuoteId', actualQuoteLineItems);
		System.assertEquals( NUM_OF_QUOTES, quoteIdtoQuoteLineItems.size(), 'There should be a list of quote line items for each quote affected' );

		for( Id quoteId : quoteIdtoQuoteLineItems.keySet() )
		{
			List<QuoteLineItem> pairedQuoteItems = quoteIdtoQuoteLineItems.get( quoteId );
			System.assertEquals( 2, pairedQuoteItems.size(), 'Each quote should have the correct number of paired products' );
			Set<Id> pairedPricebookEntryIds = Pluck.ids( 'PricebookEntryId', pairedQuoteItems );
			System.assert( pairedPricebookEntryIds.containsAll( expectedPricebookEntryIds ), 'All of the new paired products should be returned' );
			System.assert( expectedPricebookEntryIds.containsAll( pairedPricebookEntryIds ), 'Only the new paired products should be returned' );
		}
	}

	@isTest(seeAllData=true)
	static void testGetExistingPairedLineItems()
	{
		setupProductPairings();

		Opportunity opportunity = OpportunityTestFactory.createOpportunity();
		List<Quote> newAgreements = QuoteTestFactory.createNewAgreementQuotes( NUM_OF_QUOTES, opportunity );

		List<QuoteLineItem> licenseItems = new List<QuoteLineItem>();
		for( Quote newAgreement : newAgreements )
		{
			licenseItems.add( buildLicenseItem( newAgreement, PS_THRESHOLD - 1 ) );
		}
		insert licenseItems;
		licenseItems = requeryforQuoteLineItems( licenseItems );

		Test.startTest();
			List<QuoteLineItem> actualQuoteLineItems = QuoteLineItemServices.getExistingPairedLineItems( licenseItems );
		Test.stopTest();
		System.assertEquals( NUM_OF_QUOTES * expectedNumOfPairedProducts, actualQuoteLineItems.size(), 'All of the paired products should be returned' );

		Map<Id, List<QuoteLineItem>> quoteIdtoQuoteLineItems = GroupBy.ids('QuoteId', actualQuoteLineItems);
		System.assertEquals( NUM_OF_QUOTES, quoteIdtoQuoteLineItems.size(), 'There should be a list of quote line items for each quote affected' );

		for( Id quoteId : quoteIdtoQuoteLineItems.keySet() )
		{
			List<QuoteLineItem> pairedQuoteItems = quoteIdtoQuoteLineItems.get( quoteId );
			System.assertEquals( expectedNumOfPairedProducts, pairedQuoteItems.size(), 'Each quote should have the correct number of paired products' );
			Set<Id> pairedPricebookEntryIds = Pluck.ids( 'PricebookEntryId', pairedQuoteItems );
			System.assert( pairedPricebookEntryIds.containsAll( expectedBelowThresholdPricebookEntryIds ), 'All of the existing paired products should be returned' );
			System.assert( expectedBelowThresholdPricebookEntryIds.containsAll( pairedPricebookEntryIds ), 'Only the existing paired products should be returned' );
		}
	}

	@isTest(seeAllData=true)
	static void testHasHigherRankedCompetingProduct_doesNotHaveCompetingProduct()
	{
		setupCompetingProducts();

		Quote testQuote = QuoteTestFactory.createNewAgreementQuote();
		QuoteLineItem cloudStorageLineItem = QuoteTestFactory.buildQuoteLineItem( testQuote, productIdToPricebookEntry.get( cloudStorage.Id ) );
		QuoteLineItem serviceIntegrationLineItem = QuoteTestFactory.buildQuoteLineItem( testQuote, productIdToPricebookEntry.get( serviceIntegration.Id) );

		List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>{ cloudStorageLineItem, serviceIntegrationLineItem };
		insert quoteLineItems;
		quoteLineItems = requeryforQuoteLineItems( quoteLineItems );

		Test.startTest();
			Boolean hasHigherRankedCompetingProduct = QuoteLineItemServices.hasHigherRankedCompetingProduct( starterService.Id, quoteLineItems );
		Test.stopTest();

		System.assertEquals( false, hasHigherRankedCompetingProduct, 'Quotes that do not have any competing line items should return false' );
	}

	@isTest(seeAllData=true)
	static void testHasHigherRankedCompetingProduct_hasHigherRanked()
	{
		setupCompetingProducts();

		Quote testQuote = QuoteTestFactory.createNewAgreementQuote();
		QuoteLineItem higherRankedCompetingLineItem = QuoteTestFactory.buildQuoteLineItem( testQuote, productIdToPricebookEntry.get( professionalService.Id ) );
		QuoteLineItem serviceIntegrationLineItem = QuoteTestFactory.buildQuoteLineItem( testQuote, productIdToPricebookEntry.get( serviceIntegration.Id) );

		List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>{ higherRankedCompetingLineItem, serviceIntegrationLineItem };
		insert quoteLineItems;
		quoteLineItems = requeryforQuoteLineItems( quoteLineItems );
		
		Test.startTest();
			Boolean hasHigherRankedCompetingProduct = QuoteLineItemServices.hasHigherRankedCompetingProduct( starterService.Id, quoteLineItems );
		Test.stopTest();

		System.assert( hasHigherRankedCompetingProduct, 'Quotes that do have higher ranked competing line items should return true' );
	}

	@isTest(seeAllData=true)
	static void testHasHigherRankedCompetingProduct_hasLowerRanked()
	{
		setupCompetingProducts();

		Quote testQuote = QuoteTestFactory.createNewAgreementQuote();
		QuoteLineItem lowerRankedCompetingLineItem = QuoteTestFactory.buildQuoteLineItem( testQuote, productIdToPricebookEntry.get( starterService.Id ) );
		QuoteLineItem serviceIntegrationLineItem = QuoteTestFactory.buildQuoteLineItem( testQuote, productIdToPricebookEntry.get( serviceIntegration.Id) );

		List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>{ lowerRankedCompetingLineItem, serviceIntegrationLineItem };
		insert quoteLineItems;
		quoteLineItems = requeryforQuoteLineItems( quoteLineItems );
		
		Test.startTest();
			Boolean hasHigherRankedCompetingProduct = QuoteLineItemServices.hasHigherRankedCompetingProduct( professionalService.Id, quoteLineItems );
		Test.stopTest();

		System.assertEquals( false, hasHigherRankedCompetingProduct, 'Quotes that do not have any higher ranked competing line items should return false' );
	}


	final static Integer SMALL_THRESHOLD = 0;
	final static Integer MEDIUM_THRESHOLD = 251;
	final static Integer LARGE_THRESHOLD = 501;
	static Product_Pricing__c smallProductPricing;
	static Product_Pricing__c mediumProductPricing;
	static Product_Pricing__c largeProductPricing;
	static Product_Pricing__c otherProductPricing;

	static void setupProductPricing()
	{
		testPricingProduct = ProductTestFactory.createProduct();
		testPricingProduct2 = ProductTestFactory.createProduct();

		smallProductPricing = new Product_Pricing__c();
		smallProductPricing.Min_Seat_Threshold__c = SMALL_THRESHOLD;
		smallProductPricing.Price__c = 2000;
		smallProductPricing.Product_Id__c = testPricingProduct.Id;
		smallProductPricing.Name = 'Cloud Connect <250 Seats';

		mediumProductPricing = new Product_Pricing__c();
		mediumProductPricing.Min_Seat_Threshold__c = MEDIUM_THRESHOLD;
		mediumProductPricing.Price__c = 3000;
		mediumProductPricing.Product_Id__c = testPricingProduct.Id;
		mediumProductPricing.Name = 'Cloud Connect251-500 Seats';

		largeProductPricing = new Product_Pricing__c();
		largeProductPricing.Min_Seat_Threshold__c = LARGE_THRESHOLD;
		largeProductPricing.Price__c = 4000;
		largeProductPricing.Product_Id__c = testPricingProduct.Id;
		largeProductPricing.Name = 'Cloud Connect 500-2500 Seats';

		otherProductPricing = new Product_Pricing__c();
		otherProductPricing.Min_Seat_Threshold__c = SMALL_THRESHOLD;
		otherProductPricing.Price__c = 1000;
		otherProductPricing.Product_Id__c = testPricingProduct2.Id;
		otherProductPricing.Name = 'Other Product';

		System.runAs(TestUtils.ADMIN_USER)
		{
			insert new List<Product_Pricing__c> {largeProductPricing, mediumProductPricing, smallProductPricing, otherProductPricing};
		}
	}

	static testMethod void testSetDefaultPrice_smallestThreshold()
	{
		setupProductPricing();
		QuoteLineItem testQLI = new QuoteLineItem();

		Test.startTest();
			QuoteLineItem returnedQLI = QuoteLineItemServices.setDefaultPrice( testQLI, testPricingProduct.Id, SMALL_THRESHOLD + 1 );
		Test.stopTest();

		System.assertEquals( smallProductPricing.Price__c, returnedQLI.UnitPrice, 'The Unit Price of the returned Quote Line Item should be equal to the matching Product Pricing custom setting.' );
	}

	static testMethod void testSetDefaultPrice_atThreshold()
	{
		setupProductPricing();

		Test.startTest();
			QuoteLineItem returnedQLI = QuoteLineItemServices.setDefaultPrice( new QuoteLineItem(), testPricingProduct.Id, MEDIUM_THRESHOLD );
		Test.stopTest();

		System.assertEquals( mediumProductPricing.Price__c, returnedQLI.UnitPrice, 'The Unit Price of the returned Quote Line Item should be equal to the matching Product Pricing custom setting.' );
	}

	static testMethod void testSetDefaultPrice_WithLargestThreshold()
	{
		setupProductPricing();

		Test.startTest();
			QuoteLineItem returnedQLI = QuoteLineItemServices.setDefaultPrice( new QuoteLineItem(), testPricingProduct.Id, LARGE_THRESHOLD + 1000 );
		Test.stopTest();

		System.assertEquals( largeProductPricing.Price__c, returnedQLI.UnitPrice, 'The Unit Price of the returned Quote Line Item should be equal to the matching Product Pricing custom setting.' );
	}

	static testMethod void testSetDefaultPrice_NoMatchingProducts()
	{
		testPricingProduct = ProductTestFactory.createProduct();
		testPricingProduct2 = ProductTestFactory.createProduct();

		mediumProductPricing = new Product_Pricing__c();
		mediumProductPricing.Min_Seat_Threshold__c = MEDIUM_THRESHOLD;
		mediumProductPricing.Price__c = 3000;
		mediumProductPricing.Product_Id__c = testPricingProduct.Id;
		mediumProductPricing.Name = 'Cloud Connect251-500 Seats';


		testPricingProduct = ProductTestFactory.createProduct();
		Test.startTest();
			QuoteLineItem returnedQLI = QuoteLineItemServices.setDefaultPrice( new QuoteLineItem(), testPricingProduct2.Id, MEDIUM_THRESHOLD );
		Test.stopTest();

		System.assertEquals( null, returnedQLI.UnitPrice, 'The Unit Price should not be set when there is no matching Product Pricing custom setting.' );
	}

	static testMethod void testSetDefaultPrice_NoMatchingThreshold()
	{
		testPricingProduct = ProductTestFactory.createProduct();

		mediumProductPricing = new Product_Pricing__c();
		mediumProductPricing.Min_Seat_Threshold__c = MEDIUM_THRESHOLD;
		mediumProductPricing.Price__c = 3000;
		mediumProductPricing.Product_Id__c = testPricingProduct.Id;
		mediumProductPricing.Name = 'Cloud Connect251-500 Seats';

		System.runAs(TestUtils.ADMIN_USER)
		{
			insert mediumProductPricing;
		}

		Test.startTest();
			QuoteLineItem returnedQLI = QuoteLineItemServices.setDefaultPrice( new QuoteLineItem(), testPricingProduct.Id, MEDIUM_THRESHOLD - 1);
		Test.stopTest();

		System.assertEquals( null, returnedQLI.UnitPrice, 'The Unit Price should not be set when there is no matching Product Pricing custom setting.' );
	}
	
	@isTest(seeAllData=true)
	static void testFilterBonusProducts()
	{
		Bonus_Products__c bonusProductsSetting = TestUtils.createBonusProductsSetting( TestUtils.STANDARD_PRICEBOOK.Id );
		Id bonusProductId = bonusProductsSetting.High_Bonus_Product_Id__c;
		
		Product2 nonBonusProduct = ProductTestFactory.createProduct();
		PricebookEntry nonBonusPricebookEntry = ProductTestFactory.createPricebookEntry( nonBonusProduct );
		
		Opportunity opportunity = OpportunityTestFactory.createOpportunity();
		Quote newAgreement = QuoteTestFactory.createNewAgreementQuote( opportunity );
		
		PricebookEntry bonusPricebookEntry = [SELECT Id FROM PricebookEntry WHERE Product2Id = :bonusProductId ];
		
		List<QuoteLineItem> quoteLineItems = QuoteTestFactory.buildQuoteLineItems( newAgreement, new List<PricebookEntry> { bonusPricebookEntry, nonBonusPricebookEntry } );
		Test.startTest();
			List<QuoteLineItem> filteredQuoteLineItems = QuoteLineItemServices.filterBonusProducts( quoteLineItems );
		Test.stopTest();
		
		System.assertEquals( 1, filteredQuoteLineItems.size(), 'Only bonus products should be returned' );
		System.assertEquals( bonusPricebookEntry.Id , filteredQuoteLineItems[0].PricebookEntryId , 'Only bonus products should be returned' );
	}
}