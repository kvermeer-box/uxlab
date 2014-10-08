@isTest
private class QuoteMachine_AddProductsControllerTest {

    static final Double SUB_TOTAL = 10000000.00;
    static QuoteMachine_AddProductsController extension;
    static Quote newAgreement;
    static Account account;

    static void setup()
    {
        setup(TestUtils.STANDARD_PRICEBOOK.Id);
    }

    static void setup(Id pricebookId)
    {
        account = AccountTestFactory.createAccount();
        Contact contact = ContactTestFactory.createContact( account );
        Opportunity opportunity = OpportunityTestFactory.createOpportunity( account );

        newAgreement = QuoteTestFactory.buildNewAgreementQuote( opportunity );
        newAgreement.Pricebook2Id = pricebookId;
        insert newAgreement;

        QuoteLineItem quoteLineItem = new QuoteLineItem();

        Test.SetCurrentPageReference( Page.QuoteMachine_AddProductsPage );
        PageReference pageRef = ApexPages.currentPage();
        pageRef.getParameters().put('addTo', newAgreement.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(quoteLineItem);
        extension = new QuoteMachine_AddProductsController(sc);
    }

    static PricebookEntry setupDefaultProduct( Id pricebookId )
    {
        Product2 defaultProduct = ProductTestFactory.buildProduct();
        defaultProduct.Default_Product__c = true;
        insert defaultProduct;

        ProductTestFactory.createPricebookEntry( defaultProduct );
        PricebookEntry defaultProductPricebookEntry = ProductTestFactory.buildPricebookEntry( defaultProduct, pricebookId );
        defaultProductPricebookEntry.UseStandardPrice = true;
        insert defaultProductPricebookEntry;

        return defaultProductPricebookEntry;
    }

    @isTest(seeAllData=true)
    static void testRefreshProductsList_Legacy()
    {
        //Quote is considered legacy based on CreatedDate.
        //We can't set the CreatedDate so we set Legacy Date to the future
        QuoteMachine_AddProductsController.LEGACY_DATE = Date.Today().addYears(1);
        Id defaultPricebookId = [SELECT Id FROM Pricebook2 WHERE Name = 'Default' and isActive = true ][0].Id;
        setup(defaultPricebookId);

        Test.startTest();
            List<PricebookEntry> pricebookEntries = extension.refreshProductsList();
        Test.stopTest();

        System.assert( !pricebookEntries.isEmpty(), 'A list of products should be returned' );
        for( PricebookEntry entry : pricebookEntries )
        {
            System.assertEquals( defaultPricebookId, entry.Pricebook2Id, 'Legacy quotes should use the legacy pricebook' );
        }
    }

    @isTest(seeAllData=true)
    static void testRefreshProductsList_Current()
    {
        //Quote is considered legacy based on CreatedDate.
        //We can't set the CreatedDate so we set Legacy Date to the past
        QuoteMachine_AddProductsController.LEGACY_DATE = Date.Today().addYears(-1);
        Id newPricebookId = [SELECT Id FROM Pricebook2 WHERE Name = 'New Pricebook' and isActive = true ][0].Id;
        setup(newPricebookId);

        Test.startTest();
            List<PricebookEntry> pricebookEntries = extension.refreshProductsList();
        Test.stopTest();

        System.assert( !pricebookEntries.isEmpty(), 'A list of products should be returned' );
        for( PricebookEntry entry : pricebookEntries )
        {
            System.assertEquals( newPricebookId, entry.Pricebook2Id, 'Current quotes should use the current pricebook' );
        }
    }

    @isTest(seeAllData=true)
    static void testAddBonusProduct_legacy()
    {
        //Quote is considered legacy based on CreatedDate.
        //We can't set the CreatedDate so we set Legacy Date to the future
        QuoteMachine_AddProductsController.LEGACY_DATE = Date.Today().addYears(1);
        setup();
        Id defaultPricebookId = [SELECT Id FROM Pricebook2 WHERE Name = 'Default' and isActive = true ][0].Id;
        setupDefaultProduct( defaultPricebookId );

        extension.qli.PricebookEntry = [SELECT Id, Product2.Default_Product__c
                                        FROM PricebookEntry WHERE Pricebook2Id = :defaultPricebookId AND Product2.Default_Product__c = true LIMIT 1];
        extension.ownsQuickSmartStart = false;
        extension.subtotal = SUB_TOTAL;

        Test.startTest();
            extension.addBonusProducts();
        Test.stopTest();

        List<QuoteLineItem> insertedQuoteLineItems = [SELECT Id FROM QuoteLineItem WHERE QuoteId = :extension.q.Id ];
        System.assertEquals(1, insertedQuoteLineItems.size(), 'A bonus product should have been added' );
    }

    @isTest(seeAllData=true)
    static void testAddBonusProduct_Current()
    {
        //Quote is considered legacy based on CreatedDate.
        //We can't set the CreatedDate so we set Legacy Date to the past
        QuoteMachine_AddProductsController.LEGACY_DATE = Date.Today().addYears(-1);
        setup();
        Id newPricebookId = [SELECT Id FROM Pricebook2 WHERE Name = 'New Pricebook' and isActive = true ][0].Id;
        setupDefaultProduct( newPricebookId );

        extension.qli.PricebookEntry = [SELECT Id, Product2.Default_Product__c
                                        FROM PricebookEntry WHERE Pricebook2Id = :newPricebookId AND Product2.Default_Product__c = true LIMIT 1];
        extension.ownsQuickSmartStart = false;
        extension.subtotal = SUB_TOTAL;

        Test.startTest();
            extension.addBonusProducts();
        Test.stopTest();

        List<QuoteLineItem> insertedQuoteLineItems = [SELECT Id FROM QuoteLineItem WHERE QuoteId = :extension.q.Id ];
        System.assert( insertedQuoteLineItems.isEmpty(), 'A bonus product should not have been added' );
    }

    @isTest(seeAllData=true)
    static void testSetDefaultUnitPrice()
    {
        final Integer EXPECTED_PRICE = 10000;

        final Integer NEW_SEATS = 100;
        final Integer EXISTING_SEATS = 150;

        final Integer NUMBER_OF_SEATS = NEW_SEATS + EXISTING_SEATS;

        Pricebook2 customPricebook = new Pricebook2(Name='a new pricebook');
        insert customPricebook;

        setup(customPricebook.Id);

        Opportunity closedOpp = OpportunityTestFactory.buildOpportunity(account);
        closedOpp.StageName = 'Closed Won';
        closedOpp.Seats_Sold__c = EXISTING_SEATS;
        insert closedOpp;

        Product2 businessLicenseProduct = new Product2(Id = QuoteMachine_AddProductsController.BUSINESS_LICENSES_PRODUCT_ID);
        PricebookEntry businessLicensePBE = ProductTestFactory.createPricebookEntry(businessLicenseProduct, customPricebook.Id);

        Product2 product = ProductTestFactory.buildProduct();
        insert product;

        PricebookEntry defaultProductPBE = ProductTestFactory.createPricebookEntry( product );
        Product_Pricing__c testProductPricing = TestUtils.buildProductPricingSetting(defaultProductPBE.Product2Id, NUMBER_OF_SEATS - 1, 'Test Product Pricing', EXPECTED_PRICE);
        System.runAs(TestUtils.ADMIN_USER)
        {
            insert testProductPricing;
        }

        QuoteLineItem testQLI = new QuoteLineItem();
        testQLI.QuoteId = newAgreement.Id;
        testQLI.PricebookEntryId = businessLicensePBE.Id;
        testQLI.Quantity = NEW_SEATS;
        testQLI.UnitPrice = 1;
        insert testQLI;

        ApexPages.StandardController sc = new ApexPages.StandardController(new QuoteLineItem());
        extension = new QuoteMachine_AddProductsController(sc);

        Test.startTest();
            extension.selectedProductId = defaultProductPBE.Id;
            extension.setProductId();
        Test.stopTest();

        System.assertEquals( EXPECTED_PRICE, extension.qli.unitPrice, 'The Quote Line Item should have its unit price defaulted to the matching Product Price custom setting.');
    }

    static PricebookEntry nonPlatformPbe;
    static ApexPages.StandardController standardController;
    static QuoteMachine_AddProductsController controller;
	static List<PricebookEntry> pricebookEntries;

    static void setupBoxPlatformTest() {
        // new pricebook
        Pricebook2 pricebook = ProductTestFactory.createPricebook();

        // use existing products
        // update the display order of the products
        List<Product2> products = new List<Product2>
            { buildProduct(QuoteMachine_AddProductsController.BOX_PLATFORM_BUILD_NAME, 1)
            , buildProduct(QuoteMachine_AddProductsController.BOX_PLATFORM_SCALE_NAME, 2)
            , buildProduct(QuoteMachine_AddProductsController.BOX_PLATFORM_TRANSFORM_NAME, 3)
            };
        upsert products Product2.Name;

        // create pbes for products for new pricebook
        pricebookEntries = ProductTestFactory.createPricebookEntries(pricebook, products);
        // create pbe for non box platform product to make this test fail w/o box platform condition in query
        Product2 nonPlatformProduct = ProductTestFactory.createProduct();
        ProductTestFactory.createPricebookEntries(TestUtils.STANDARD_PRICEBOOK, new List<Product2>{nonPlatformProduct});
        nonPlatformPbe = ProductTestFactory.createPricebookEntries(pricebook, new List<Product2>{nonPlatformProduct})[0];

        // set the current pricebook custom setting to the new pricebook
        Pricebook_Setting__c pricebookSetting = TestUtils.buildPricebookSetting(QuoteMachine_AddProductsController.PRICEBOOK_SETTING_NAME_CURRENT, pricebook.Id);
        System.runAs(TestUtils.ADMIN_USER) {
            upsert pricebookSetting Pricebook_Setting__c.Name;
        }

        // create an opportunity
        account = AccountTestFactory.createAccount();
        Contact contact = ContactTestFactory.createContact( account );
        Opportunity opportunity = OpportunityTestFactory.createOpportunity( account );

        // create a quote
        Quote quote = QuoteTestFactory.buildNewAgreementQuote( opportunity );
        quote.Pricebook2Id = pricebook.Id;
        insert quote;

        standardController = new ApexPages.StandardController(new QuoteLineItem(QuoteId=quote.Id, PricebookEntryId=pricebookEntries[0].Id));
    }

    static Product2 buildProduct(String name, Integer displayOrder) {
        return new Product2(Name=name, Display_Order__c=displayOrder);
    }

    static void setupBoxPlatformController() {
        controller = new QuoteMachine_AddProductsController(standardController);
    }

    @isTest(seeAllData=true)
    static void testBoxPlatformProductList() {
        setupBoxPlatformTest();

        Test.startTest();
            setupBoxPlatformController();
        Test.stopTest();

        Set<String> platformProductNames = new Set<String>
            { QuoteMachine_AddProductsController.BOX_PLATFORM_BUILD_NAME
            , QuoteMachine_AddProductsController.BOX_PLATFORM_SCALE_NAME
            , QuoteMachine_AddProductsController.BOX_PLATFORM_TRANSFORM_NAME
            };

        // assert controller productsList does not have box platform products
        for(PricebookEntry pricebookEntry : controller.productsList) {
            System.assert(!platformProductNames.contains(pricebookEntry.Product2.Name), 'The platform product should not be in the product list: ' + pricebookEntry.Product2Id);
        }

        // assert controller boxPlatformPbeList does have box platform products
        System.assertEquals(platformProductNames.size(), controller.boxPlatformPbes.size(), 'The number of platform ids should match');

        // assert order of boxPlatformPbeList
        System.assertEquals(QuoteMachine_AddProductsController.BOX_PLATFORM_BUILD_NAME, controller.boxPlatformPbes[0].Product2.Name, 'The first should be the basic product');
        System.assertEquals(QuoteMachine_AddProductsController.BOX_PLATFORM_SCALE_NAME, controller.boxPlatformPbes[1].Product2.Name, 'The second should be the production product');
        System.assertEquals(QuoteMachine_AddProductsController.BOX_PLATFORM_TRANSFORM_NAME, controller.boxPlatformPbes[2].Product2.Name, 'The third should be the custom product');
    }

    @isTest(seeAllData=true)
    static void testBoxPlatformProduct_buildLocksSalesprice() {
        setupBoxPlatformTest();
        setupBoxPlatformController();

        Test.startTest();
            controller.selectedProductId = controller.nameToPlatformProductId.get(QuoteMachine_AddProductsController.BOX_PLATFORM_BUILD_NAME);
            controller.setProductId();
        Test.stopTest();

        System.assert(controller.lockSalesprice, 'The build product should lock the salesprice');
    }

    @isTest(seeAllData=true)
    static void testBoxPlatformProduct_otherUnlocksSalesprice() {
        setupBoxPlatformTest();
        setupBoxPlatformController();

        Test.startTest();
            controller.selectedProductId = controller.nameToPlatformProductId.get(QuoteMachine_AddProductsController.BOX_PLATFORM_SCALE_NAME);
            controller.setProductId();
        Test.stopTest();

        System.assert(!controller.lockSalesprice, 'The scale product should not lock the salesprice');
    }

    @isTest(seeAllData=true)
    static void testBoxPlatformProduct_buildHidesListPrice() {
        setupBoxPlatformTest();
        setupBoxPlatformController();

        Test.startTest();
            controller.selectedProductId = controller.nameToPlatformProductId.get(QuoteMachine_AddProductsController.BOX_PLATFORM_BUILD_NAME);
            controller.setProductId();
        Test.stopTest();

        System.assert(!controller.showListPrice, 'The build product should not show the list price');
    }

    @isTest(seeAllData=true)
    static void testBoxPlatformProduct_transformHidesListPrice() {
        setupBoxPlatformTest();
        setupBoxPlatformController();

        Test.startTest();
            controller.selectedProductId = controller.nameToPlatformProductId.get(QuoteMachine_AddProductsController.BOX_PLATFORM_TRANSFORM_NAME);
            controller.setProductId();
        Test.stopTest();

        System.assert(!controller.showListPrice, 'The transform product should not show the list price');
    }

    @isTest(seeAllData=true)
    static void testBoxPlatformProduct_otherShowsListPrice() {
        setupBoxPlatformTest();
        setupBoxPlatformController();

        Test.startTest();
            controller.selectedProductId = controller.nameToPlatformProductId.get(QuoteMachine_AddProductsController.BOX_PLATFORM_SCALE_NAME);
            controller.setProductId();
        Test.stopTest();

        System.assert(controller.showListPrice, 'The scale product should show the list price');
    }

    @isTest(seeAllData=true)
    static void testBoxPlatformProduct_buildIsPlatform() {
        setupBoxPlatformTest();
        setupBoxPlatformController();

        Test.startTest();
            controller.selectedProductId = controller.nameToPlatformProductId.get(QuoteMachine_AddProductsController.BOX_PLATFORM_BUILD_NAME);
            controller.setProductId();
        Test.stopTest();

        System.assert(controller.isBoxPlatform, 'The build product is a platform product');
    }

    @isTest(seeAllData=true)
    static void testBoxPlatformProduct_scaleIsPlatform() {
        setupBoxPlatformTest();
        setupBoxPlatformController();

        Test.startTest();
            controller.selectedProductId = controller.nameToPlatformProductId.get(QuoteMachine_AddProductsController.BOX_PLATFORM_SCALE_NAME);
            controller.setProductId();
        Test.stopTest();

        System.assert(controller.isBoxPlatform, 'The scale product is a platform product');
    }

    @isTest(seeAllData=true)
    static void testBoxPlatformProduct_transformIsPlatform() {
        setupBoxPlatformTest();
        setupBoxPlatformController();

        Test.startTest();
            controller.selectedProductId = controller.nameToPlatformProductId.get(QuoteMachine_AddProductsController.BOX_PLATFORM_TRANSFORM_NAME);
            controller.setProductId();
        Test.stopTest();

        System.assert(controller.isBoxPlatform, 'The transform product is a platform product');
    }

    @isTest(seeAllData=true)
    static void testBoxPlatformProduct_otherIsNotPlatform() {
        setupBoxPlatformTest();
        setupBoxPlatformController();

        Test.startTest();
            controller.selectedProductId = nonPlatformPbe.Id;
            controller.setProductId();
        Test.stopTest();

        System.assert(!controller.isBoxPlatform, 'The non platform product is not a platform product');
    }

    static testMethod void testGetActionsPackageOptions(){
        final String FIRST_RANGE_NAME = '500,000 - 999,999';
        final String SECOND_RANGE_NAME = '1,000,000 - 1,499,999';

        List<Actions_Package__c> actionPackages = new List<Actions_Package__c>
            { TestUtils.createActionsPackage(FIRST_RANGE_NAME, 500000, 999999, 1, false)
            , TestUtils.createActionsPackage(SECOND_RANGE_NAME, 1000000, 1499999, 2, false)
            };
        System.runAs(TestUtils.ADMIN_USER) {
            insert actionPackages;
        }

        List<SelectOption> expected = new List<SelectOption>{
            new SelectOption('1.0', FIRST_RANGE_NAME),
            new SelectOption('2.0', SECOND_RANGE_NAME)
        };

        Test.startTest();
            List<SelectOption> actual = QuoteMachine_AddProductsController.getActionPackageOptions();
        Test.stopTest();

        System.assertEquals(expected, actual, 'The action package options should be fetched in the correct order');
    }

    @isTest(seeAllData=true)
    static void testBoxPlatformProduct_scaleShowsActionPackage() {
        setupBoxPlatformTest();
        setupBoxPlatformController();

        Test.startTest();
            controller.selectedProductId = controller.nameToPlatformProductId.get(QuoteMachine_AddProductsController.BOX_PLATFORM_SCALE_NAME);
            controller.setProductId();
        Test.stopTest();

        System.assert(controller.showActionsPackage, 'The scale product should show the actions package');
    }

    @isTest(seeAllData=true)
    static void testBoxPlatformProduct_otherHidesActionPackage() {
        setupBoxPlatformTest();
        setupBoxPlatformController();

        Test.startTest();
            controller.selectedProductId = controller.nameToPlatformProductId.get(QuoteMachine_AddProductsController.BOX_PLATFORM_BUILD_NAME);
            controller.setProductId();
        Test.stopTest();

        System.assert(!controller.showActionsPackage, 'The build product should not show the actions package');
    }

    @isTest(seeAllData=true)
    static void testBoxPlatformProduct_buildHidesDiscount() {
        setupBoxPlatformTest();
        setupBoxPlatformController();

        Test.startTest();
            controller.selectedProductId = controller.nameToPlatformProductId.get(QuoteMachine_AddProductsController.BOX_PLATFORM_BUILD_NAME);
            controller.setProductId();
        Test.stopTest();

        System.assert(!controller.showDiscount, 'The build product should hide the discount');
    }

    @isTest(seeAllData=true)
    static void testBoxPlatformProduct_transformHidesDiscount() {
        setupBoxPlatformTest();
        setupBoxPlatformController();

        Test.startTest();
            controller.selectedProductId = controller.nameToPlatformProductId.get(QuoteMachine_AddProductsController.BOX_PLATFORM_TRANSFORM_NAME);
            controller.setProductId();
        Test.stopTest();

        System.assert(!controller.showDiscount, 'The transform product should not show the discount');
    }

    @isTest(seeAllData=true)
    static void testBoxPlatformProduct_otherShowsDiscount() {
        setupBoxPlatformTest();
        setupBoxPlatformController();

        Test.startTest();
            controller.selectedProductId = controller.nameToPlatformProductId.get(QuoteMachine_AddProductsController.BOX_PLATFORM_SCALE_NAME);
            controller.setProductId();
        Test.stopTest();

        System.assert(controller.showDiscount, 'The scale product should show the discount');
    }

    @isTest(seeAllData=true)
	static void calculateTotal_transformProuct() {
        setupBoxPlatformTest();
        setupBoxPlatformController();

		final Decimal QUOTELINEITEM_UNITPRICE = 10000;
		PricebookEntry transformPricebookEntry = [
			SELECT Product2.Name, UnitPrice
			FROM PricebookEntry
			WHERE Id = :pricebookEntries[2].Id
		];

		Test.startTest();
			controller.selectedPriceBookEntry = transformPricebookEntry;
			controller.qli = new QuoteLineItem(UnitPrice = QUOTELINEITEM_UNITPRICE);

			controller.calculateTotal();
		Test.stopTest();

		System.assertEquals(QUOTELINEITEM_UNITPRICE, controller.qli.List_Price__c, 'The list price on the qli should be set to the unit price for the quote line item');
		System.assertEquals(0, controller.qli.Discount__c, 'The discount should be set to 0 for the transform product');
		System.assertEquals(1, controller.qli.Quantity, 'The quantity should be set to 1 for the transform product');
	}

    @isTest(seeAllData=true)
	static void calculateTotal_otherProduct() {
        setupBoxPlatformTest();
        setupBoxPlatformController();

		final Decimal QUOTELINEITEM_UNITPRICE = 10000;
		PricebookEntry scalePricebookEntry = pricebookEntries[1];

		Test.startTest();
			controller.selectedPriceBookEntry = scalePricebookEntry;
			controller.qli = new QuoteLineItem(UnitPrice = QUOTELINEITEM_UNITPRICE);

			controller.calculateTotal();
		Test.stopTest();

		System.assertEquals(scalePricebookEntry.UnitPrice, controller.qli.List_Price__c, 'The list price on the qli should be set to the unit price for the scale pricebook entry');
	}
}