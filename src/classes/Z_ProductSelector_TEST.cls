/*

Test class for the product selector

@author Mickael Pham
@Editted by Tom Dziedzic and Forest Hibbard

*/

@isTest
private class Z_ProductSelector_TEST {
    static zqu__Quote__c quote;
    static List<zqu__ZProduct__c> products;
    static zqu__ZProduct__c child;
    static zqu__ZProduct__c extra;
    static zqu__ProductRatePlan__c productRatePlan_child;
    static zqu__ZProduct__c parent;
    static Id quoteId;
    static Account account;
    static zqu.zChargeGroup chargeGroup;

    static final String oldValue = '10';
    static final String newValue = '50';

    static void setup() {
        account = Z_TestUtils.createAccount(true);
        Opportunity opportunity = Z_TestUtils.createOpportunity(account.Id, true);
        quote = Z_TestUtils.createZQuote(opportunity.Id, true);

        child = Z_TestUtils.createZProduct('Red/Blue + Yellow', 'First Gen', false);
        child.Name = 'Child';
        insert child;
        productRatePlan_child = Z_TestUtils.createZProductRatePlan(child.Id, true);
        zqu__ProductRatePlanCharge__c productRatePlanCharge_child = Z_TestUtils.createZProductRatePlanCharge(productRatePlan_child.Id, true);
        zqu__ProductRatePlanChargeTier__c childTier = Z_TestUtils.createProductRatePlanChargeTier(productRatePlanCharge_child.Id, quote.zqu__Currency__c, true);
        zqu__QuoteCharge__c quoteCharge_child = Z_TestUtils.createZQuoteCharge(quote.Id, productRatePlanCharge_child.Id, true);

        extra = Z_TestUtils.createZProduct('Gold/Silver + Crystal', 'Second Gen', false);
        extra.Name = 'Extra';
        insert extra;
        zqu__ProductRatePlan__c productRatePlan = Z_TestUtils.createZProductRatePlan(extra.Id, true);
        zqu__ProductRatePlanCharge__c productRatePlanCharge = Z_TestUtils.createZProductRatePlanCharge(productRatePlan.Id, 'zuoraProductRatePlanCharge2', true);
        zqu__ProductRatePlanChargeTier__c extraTier = Z_TestUtils.createProductRatePlanChargeTier(productRatePlanCharge.Id, quote.zqu__Currency__c, true);
        zqu__QuoteCharge__c quoteCharge = Z_TestUtils.createZQuoteCharge(quote.Id, productRatePlanCharge.Id, true);

        parent = Z_TestUtils.createZProduct('Ruby/Saphire + Emerald', 'Third Gen', false);
        parent.Name = 'Parent';
        insert parent;
    }

    static void setupCharge() {
        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = new Set<String>
        { 'Box_Discount__c'
        , 'List_Price__c'
        };

        products = new List<zqu__ZProduct__c>();
        products.add(TestFactory.prepareProductCatalog(TestFactory.rateplannames));

        account = TestFactory.makeAccount();
        Opportunity opportunity = TestFactory.makeOpportunity(account);
        quote = TestFactory.makeQuote(opportunity);

        List<zqu__ProductRatePlan__c> productRatePlans = [
            SELECT Name
            FROM zqu__ProductRatePlan__c
            WHERE zqu__ZProduct__c = :products[0].Id
        ];

        chargeGroup = zqu.zQuoteUtil.getChargeGroups(quote.Id, new List<Id>{productRatePlans[0].Id})[0];
        for(zqu.zCharge charge : chargeGroup.zCharges) {
            charge.EFFECTIVE_PRICE = oldValue;
        }
        chargeGroup.zCharges = zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(chargeGroup.zCharges);
        for(zqu.zCharge charge : chargeGroup.zCharges) {
            charge.QUANTITY = oldValue;
        }
        chargeGroup.zCharges = zqu.zQuoteUtil.calculateChargesOnQuantityChange(chargeGroup.zCharges);
        for(zqu.zCharge charge : chargeGroup.zCharges) {
            charge.TOTAL = oldValue;
        }
        chargeGroup.zCharges = zqu.zQuoteUtil.calculateChargesOnTotalChange(chargeGroup.zCharges);

        for(zqu.zCharge zcharge : chargeGroup.zCharges) {
            zcharge.chargeObject.put('List_Price__c', 100);
            zcharge.chargeObject.put('Box_Discount__c', 0);
        }

        zqu.zQuoteUtil.addChargeGroups(new List<zqu.zChargeGroup>{chargeGroup});
    }

    static testMethod void testDisplayNoQuoteFound() {

        Test.startTest();

        ApexPages.StandardController stdController = new ApexPages.StandardController(new zqu__Quote__c());
        Z_ProductSelector ctl = new Z_ProductSelector(stdController);

        Test.stopTest();
    }

    static testMethod void testDisplayWrongQuoteId() {

        // Create a non-quote object (to get a correct ID but wrong object)
        Account acc = TestFactory.makeAccount();

        Test.startTest();

        ApexPages.Standardcontroller stdController = new ApexPages.StandardController(acc);
        Z_ProductSelector ctl = new Z_ProductSelector(stdController);

        Test.stopTest();
    }


    static testMethod void testDisplayNoProduct() {

        // Create the quote object
        Account acc = TestFactory.makeAccount();
        Opportunity opp = TestFactory.makeOpportunity(acc);
        quote = TestFactory.makeQuote(opp);

        Test.startTest();

        ApexPages.Standardcontroller stdController = new ApexPages.StandardController(quote);
        Z_ProductSelector ctl = new Z_ProductSelector(stdController);

        Test.stopTest();
    }


    static testMethod void testDisplayProduct() {

        // Setup the product catalog
        zqu__ZProduct__c product = TestFactory.prepareProductCatalog(TestFactory.rateplannames);

        // Create the quote object
        Account acc = TestFactory.makeAccount();
        Opportunity opp = TestFactory.makeOpportunity(acc);
        quote = TestFactory.makeQuote(opp);

        // Update quote information
        quote.zqu__Currency__c = 'USD';
        quote.zqu__StartDate__c = Date.today().addDays(1);
        update quote;

        Test.startTest();

            ApexPages.Standardcontroller stdController = new ApexPages.StandardController(quote);
            Z_ProductSelector ctl = new Z_ProductSelector(stdController);

            // Get the product list to display
            List<zqu__ZProduct__c> productList = ctl.productList;
            List<zqu__ProductRatePlan__c> ratePlanList = ctl.ratePlanList;

            // Get the product section info
            String productSection = ctl.productSectionInfo;
            Boolean productHasPrevious = ctl.productHasPrevious;
            Boolean productHasNext = ctl.productHasNext;
            ctl.nextProductPage();
            ctl.previousProductPage();

            // Search for a given product
            ctl.productSearchString = product.Name;
            ctl.refreshProducts();

            // Select a product and refresh the rate plan
            ctl.selProductId = product.Id;
            ctl.refreshRatePlans();
            ratePlanList = ctl.ratePlanList;

            // Get the product rate plan info
            String ratePlanSection = ctl.ratePlanSectionInfo;
            Boolean ratePlanHasPrevious = ctl.ratePlanHasPrevious;
            Boolean ratePlanHasNext = ctl.ratePlanHasNext;
            ctl.nextRatePlanPage();
            ctl.previousRatePlanPage();

            // Search for a given rate plan
            ctl.ratePlanSearchString = 'some string';
            ctl.refreshRatePlans();

            if (ratePlanList.size() > 0) {
                ctl.selRatePlanId = ratePlanList[0].Id;
            }

            // Charge group
            ctl.refreshChargeGroup();

            ctl.discountChange();
            ctl.quantityChange();
            ctl.totalChange();
            ctl.effectiveChange();

            // Add the charge to the quote
            ctl.saveCharges();
            ctl.saveAndNewCharges();

        Test.stopTest();
    }

    static testMethod void displayCorrectRatePlanTest_AutoSelectCase() {
        setupCharge();

        /*There should only be one ratePlan.
          1st being used for charge groups
          2nd used for this test*/
        List<zqu__ProductRatePlan__c> ratePlans = [
            SELECT Id
            FROM zqu__ProductRatePlan__c
            WHERE zqu__ZProduct__c = :products[0].Id
        ];
        List<zqu__ProductRatePlan__c> toDelete = new List<zqu__ProductRatePlan__c>();
        for(Integer i = 2; i < ratePlans.size(); i++) {
            toDelete.add(ratePlans[i]);
        }
        delete toDelete;

        Test.startTest();
                ApexPages.StandardController stdController = new ApexPages.StandardController(quote);
                Z_ProductSelector ctl = new Z_ProductSelector(stdController);
                ctl.selProductId = products[0].Id;
                ctl.refreshRatePlans();
        Test.stopTest();

        system.assertNotEquals(null, ctl.selRatePlanId, 'when selecting a product the rate plan should be auto selected when only one is available');
        system.assertNotEquals(null, ctl.chargeGroup, 'a charge group should have been set after a rate plan was chosen');
    }

    static testMethod void displayCorrectRatePlanTest_MultiSelectCase() {
        setup();

        zqu__ProductRatePlan__c secondRatePlan = Z_TestUtils.createZProductRatePlan(child.Id, false);
        secondRatePlan.zqu__EffectiveStartDate__c = quote.zqu__StartDate__c;
        secondRatePlan.zqu__EffectiveEndDate__c = quote.zqu__StartDate__c.addMonths(1);
        secondRatePlan.zqu__ZuoraId__c = 'secondproductrateplan';
        insert secondRatePlan;
        zqu__ProductRatePlanCharge__c secondRatePlanCharge = Z_TestUtils.createZProductRatePlanCharge(secondRatePlan.Id, false);
        secondRatePlanCharge.zqu__ZuoraId__c = String.valueOf(Math.random()*100000);
        insert secondRatePlanCharge;
        zqu__ProductRatePlanChargeTier__c secondTier = Z_TestUtils.createProductRatePlanChargeTier(secondRatePlanCharge.Id, quote.zqu__Currency__c, true);
        zqu__QuoteCharge__c secondQuoteCharge = Z_TestUtils.createZQuoteCharge(quote.Id, secondRatePlanCharge.Id, true);

        Test.startTest();
                ApexPages.StandardController stdController = new ApexPages.StandardController(quote);
                Z_ProductSelector ctl = new Z_ProductSelector(stdController);
                ctl.selProductId = child.Id;
                ctl.refreshRatePlans();
        Test.stopTest();

        system.assertEquals('', ctl.selRatePlanId, 'when selecting a product the rate plan should not be auto selected when multiple are available');
    }

    static testMethod void dontDisplayCloudConnectImplementationWhenThereAreNoCloudConnectProducts() {
        account = Z_TestUtils.createAccount(true);
        Opportunity opportunity = Z_TestUtils.createOpportunity(account.Id, true);
        quote = Z_TestUtils.createZQuote(opportunity.Id, true);

        List<String> cloudConnectProductNames = new List<String>(QuoteBusinessRules.cloudConnectProductNames);
        products = Z_TestUtils.createZProducts(cloudConnectProductNames.size() + 1, false);
        for(Integer i = 0; i < cloudConnectProductNames.size(); i++) {
            products[i].Name = cloudConnectProductNames[i];
        }
        insert products;

		Integer cloudConnectImplementationProductIndex = products.size() - 1;

        List<zqu__ProductRatePlan__c> productRatePlans = Z_TestUtils.createProductRatePlans(products, false);
        productRatePlans[cloudConnectImplementationProductIndex].Name = QuoteBusinessRules.cloudConnectImplementationRatePlanName;
        insert productRatePlans;

        List<zqu__ProductRatePlanCharge__c> productRatePlanCharges = Z_TestUtils.createProductRatePlanCharges(productRatePlans, true);

        Test.startTest();
                ApexPages.StandardController stdController = new ApexPages.StandardController(quote);
                Z_ProductSelector ctl = new Z_ProductSelector(stdController);
                ctl.selProductId = products[cloudConnectImplementationProductIndex].Id;
                ctl.refreshRatePlans();
        Test.stopTest();

        system.assertEquals(0, ctl.ratePlanSet.getResultSize(), 'There should be no rate plans returned');
    }

    static testMethod void discountChangeTest() {
        setupCharge();

        Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(quote);
            Z_ProductSelector ctl = new Z_ProductSelector(stdController);
            for(zqu.zCharge charge : chargeGroup.zCharges) {
                charge.DISCOUNT = newValue;
            }
            ctl.chargeGroup = chargeGroup;
            ctl.discountChange();
        Test.stopTest();

        for(zqu.zCharge charge : ctl.chargeGroup.zCharges) {
            system.assertNotEquals(oldValue, charge.DISCOUNT, 'the charge should have been updated');
        }
    }

    static testMethod void quantityChangeTest() {
        setupCharge();

        Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(quote);
            Z_ProductSelector ctl = new Z_ProductSelector(stdController);
            for(zqu.zCharge charge : chargeGroup.zCharges) {
                charge.QUANTITY = newValue;
            }
            ctl.chargeGroup = chargeGroup;
            ctl.quantityChange();
        Test.stopTest();

        for(zqu.zCharge charge : ctl.chargeGroup.zCharges) {
            system.assertNotEquals(oldValue, charge.QUANTITY, 'the charge should have been updated');
        }
    }

    static testMethod void effectiveChangeTest() {
        setupCharge();

        Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(quote);
            Z_ProductSelector ctl = new Z_ProductSelector(stdController);
            for(zqu.zCharge charge : chargeGroup.zCharges) {
                charge.EFFECTIVE_PRICE = newValue;
            }
            ctl.chargeGroup = chargeGroup;
            ctl.effectiveChange();
        Test.stopTest();

        for(zqu.zCharge charge : ctl.chargeGroup.zCharges) {
            system.assertNotEquals(oldValue, charge.EFFECTIVE_PRICE, 'the charge should have been updated');
        }
    }

    static testMethod void totalChangeTest() {
        setupCharge();

        Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(quote);
            Z_ProductSelector ctl = new Z_ProductSelector(stdController);
            for(zqu.zCharge charge : chargeGroup.zCharges) {
                charge.TOTAL = newValue;
            }
            ctl.chargeGroup = chargeGroup;
            ctl.totalChange();
        Test.stopTest();

        for(zqu.zCharge charge : ctl.chargeGroup.zCharges) {
            system.assertNotEquals(oldValue, charge.TOTAL, 'the charge should have been updated');
        }
    }

    static testMethod void cancelTest() {
        setupCharge();

        Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(quote);
            Z_ProductSelector ctl = new Z_ProductSelector(stdController);

            PageReference actual = ctl.stndCancel();
        Test.stopTest();

        system.assertNotEquals(null, actual, 'cancel should be returned');
    }

    static testMethod void customDiscountChangeTest() {
        setupCharge();

        Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(quote);
            Z_ProductSelector ctl = new Z_ProductSelector(stdController);
            ctl.chargeGroup = chargeGroup;
            ctl.customDiscountChange();
        Test.stopTest();

        String expectedPrice = '100.00';
        for(zqu.zCharge charge : ctl.chargeGroup.zCharges) {
            system.assertEquals(expectedPrice, charge.EFFECTIVE_PRICE, 'the charge group\'s total should have been recaculated correctly');
        }
    }

    static testMethod void saveChargesTest() {
        setupCharge();

        Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(quote);
            Z_ProductSelector ctl = new Z_ProductSelector(stdController);
            ctl.chargeGroups = zqu.zQuoteUtil.getChargeGroups(quote.Id);
            ctl.chargeGroup = chargeGroup;
            PageReference actual = ctl.saveCharges();
        Test.stopTest();

        system.assert(ApexPages.getMessages().isEmpty(), 'there should be no errors '+ApexPages.getMessages());
        system.assertNotEquals(null, actual, 'a page reference should have been returned');
    }

    static testMethod void saveAndNewChargesTest() {
        setupCharge();

        Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(quote);
            Z_ProductSelector ctl = new Z_ProductSelector(stdController);
            ctl.chargeGroups = zqu.zQuoteUtil.getChargeGroups(quote.Id);
            ctl.chargeGroup = chargeGroup;
            PageReference actual = ctl.saveCharges();
        Test.stopTest();

        system.assert(ApexPages.getMessages().isEmpty(), 'there should be no errors '+ApexPages.getMessages());
        system.assertNotEquals(null, actual, 'a page reference should have been returned');
    }

    static testMethod void addGroupTest() {
        setupCharge();

        Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(quote);
            Z_ProductSelector ctl = new Z_ProductSelector(stdController);
            ctl.chargeGroups = zqu.zQuoteUtil.getChargeGroups(quote.Id);
            ctl.chargeGroup = chargeGroup;
            PageReference actual = ctl.addGroup();
        Test.stopTest();

        system.assert(ApexPages.getMessages().isEmpty(), 'there should be no errors '+ApexPages.getMessages());
        system.assertNotEquals(null, actual, 'a page reference should have been returned');
    }

    static testMethod void onProductFilterChangeTest() {
        setupCharge();

        Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(quote);
            Z_ProductSelector ctl = new Z_ProductSelector(stdController);
            ctl.onProductFilterChange();
        Test.stopTest();

        system.assert(!ApexPages.getMessages().isEmpty(), 'there should be a page message');
    }

    static testMethod void productWrapperOptionsListTest() {
        setupCharge();

        Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(quote);
            Z_ProductSelector ctl = new Z_ProductSelector(stdController);
            List<Z_ProductSelector.WrapperOptions> actual = ctl.productWrapperOptionsList;
        Test.stopTest();

        system.assert(!actual.isEmpty(), 'a list of wrapper options should have been returned');
    }
}