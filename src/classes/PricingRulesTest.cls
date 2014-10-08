@isTest
private class PricingRulesTest {
    static List<zqu__ZProduct__c> products;
    static List<zqu__ProductRatePlan__c> product1RatePlans;
    static List<zqu__ProductRatePlan__c> product2RatePlans;
    static zqu__Quote__c quote;
    static Pricing_Rule__c pricingRule;
    static zqu.zChargeGroup autoSetCharge;
    static zqu.zChargeGroup parentCharge;
    static Zuora__SubscriptionProductCharge__c subscriptionCharge;

    static final String percentProduct = 'Percent Product';

    static void setup() {
        products = new List<zqu__ZProduct__c>();
        products.add(TestFactory.prepareProductCatalog(TestFactory.rateplannames));
        products.add(TestFactory.prepareProductCatalog(TestFactory.rateplanKHnames));

        products[0].Name = percentProduct;
        update products;

        Account account = TestFactory.makeAccount();
        Opportunity opportunity = TestFactory.makeOpportunity(account);
        quote = TestFactory.makeQuote(opportunity);

        product1RatePlans = [
            SELECT Name
            FROM zqu__ProductRatePlan__c
            WHERE zqu__ZProduct__c = :products[0].Id
        ];

        product2RatePlans = [
            SELECT Id
            FROM zqu__ProductRatePlan__c
            WHERE zqu__ZProduct__c = :products[1].Id
        ];

        pricingRule = Z_TestUtils.createPricingRule(products[1].Id, products[0].Id, 15, true);

        autoSetCharge = zqu.zQuoteUtil.getChargeGroups(quote.Id, new List<Id>{product1RatePlans[0].Id})[0];
        for(zqu.zCharge zcharge : autoSetCharge.zCharges) {
            zcharge.TOTAL = '100';
        }
        autoSetCharge.zCharges = zqu.zQuoteUtil.calculateChargesOnTotalChange(autoSetCharge.zCharges);

        parentCharge = zqu.zQuoteUtil.getChargeGroups(quote.Id, new List<Id>{product2RatePlans[0].Id})[0];
        for(zqu.zCharge zcharge : parentCharge.zCharges) {
            zcharge.TOTAL = '100';
        }
        parentCharge.zCharges = zqu.zQuoteUtil.calculateChargesOnTotalChange(parentCharge.zCharges);

        zqu.zQuoteUtil.addChargeGroups(new List<zqu.zChargeGroup>{parentCharge, autoSetCharge});

        Zuora__Subscription__c subscription = Z_TestUtils.createZSubscription(account.Id, true);
        subscriptionCharge = Z_TestUtils.createZSubscriptionProductCharge(subscription.Id, products[0].zqu__SKU__c, account.Id, false);
        subscriptionCharge.Zuora__External_Id__c = 'HK-47';
        subscriptionCharge.Box_Discount__c = '0.00';
        subscriptionCharge.List_Price__c = '100.00';
        insert subscriptionCharge;
    }

    static void setupCustomFields() {
        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = new Set<String>
        { 'Box_Discount__c'
        , 'List_Price__c'
        };

        List<zqu.zChargeGroup> existingGroups = zqu.zQuoteUtil.getChargeGroups(quote.Id);
        for(zqu.zChargeGroup existingGroup : existingGroups) {
            for(zqu.zCharge zcharge : existingGroup.zCharges) {
                zcharge.chargeObject.put('List_Price__c', 100);
                zcharge.chargeObject.put('Box_Discount__c', 0);
            }
        }

        zqu.ZQuoteUtil.updateChargeGroups(existingGroups);
    }

    static String getExpectedPrice(List<zqu.zChargeGroup> existingGroups) {
        Decimal groupTotal = PricingRules.getTotalofParentProduct(existingGroups, pricingRule.Product__c);
        return String.valueOf(groupTotal * (pricingRule.Percent__c/100)).substring(0, 5);
    }

    static testMethod void checkPricingRulesTest() {
        setup();

        List<zqu.zChargeGroup> existingGroups = zqu.zQuoteUtil.getChargeGroups(quote.Id);
        Test.startTest();
            List<Pricing_Rule__c> actuals = PricingRules.checkPricingRules(existingGroups, products[0].Id);
        Test.stopTest();

        system.assertEquals(1, actuals.size(), 'a pricing rule should have been returned');
        system.assertEquals(pricingRule.Id, actuals[0].Id, 'check pricing rules should have returned the expected pricing rule');
    }

    static testMethod void getPricingRulesRelatedToProductsTest() {
        setup();

        Test.startTest();
            List<Pricing_Rule__c> actual = PricingRules.getPricingRulesRelatedToProducts(Pluck.ids(products));
        Test.stopTest();

        system.assertEquals(1, actual.size(), 'a pricing rule should have been returned');
        system.assertEquals(pricingRule.Id, actual[0].Id, 'the correct pricing rule should have been returned');
    }

    static testMethod void getChargeGroupTest() {
        setup();
        List<zqu.zChargeGroup> existingGroups = zqu.zQuoteUtil.getChargeGroups(quote.Id);

        Test.startTest();
            zqu.ZChargeGroup actual = PricingRules.getChargeGroup(existingGroups, pricingRule, quote.Id, product2RatePlans[0].Id);
        Test.stopTest();

        String expectedPrice = getExpectedPrice(existingGroups);
        for(zqu.zCharge charge : actual.zCharges) {
            system.assertEquals(expectedPrice, charge.EFFECTIVE_PRICE, 'the charge group\'s total should have been recaculated correctly');
        }
    }

    static testMethod void updatePercentProductTest() {
        setup();
        setupCustomFields();
        List<zqu.zChargeGroup> existingGroups = zqu.zQuoteUtil.getChargeGroups(quote.Id);

        List<zqu.zChargeGroup> percentProductCharge = new List<zqu.zChargeGroup>();
        for(zqu.zChargeGroup existingGroup : existingGroups) {
            if(existingGroup.productName == percentProduct) {
                percentProductCharge.add(existingGroup);
            }
        }

        Test.startTest();
            PricingRules.updatePercentProduct(percentProductCharge, existingGroups);
        Test.stopTest();

        existingGroups = zqu.zQuoteUtil.getChargeGroups(quote.Id);

        String expectedPrice = getExpectedPrice(existingGroups);
        for(zqu.zChargeGroup existingGroup : existingGroups) {
            if(existingGroup.productName == percentProduct) {
                for(zqu.zCharge charge : existingGroup.zCharges) {
                    system.assertEquals(expectedPrice, charge.EFFECTIVE_PRICE, 'the charge group\'s total should have been recaculated correctly');
                }
            }
        }
    }

    static testMethod void updateTotalWithCustomDiscountTest() {
        setup();
        setupCustomFields();
        List<zqu.zChargeGroup> existingGroups = zqu.zQuoteUtil.getChargeGroups(quote.Id);

        zqu.zChargeGroup percentProductCharge;
        for(zqu.zChargeGroup existingGroup : existingGroups) {
            if(existingGroup.productName == percentProduct) {
                percentProductCharge = existingGroup;
            }
        }

        Test.startTest();
            PricingRules.updateTotalWithCustomDiscount(percentProductCharge);

            zqu.ZQuoteUtil.updateChargeGroup(percentProductCharge);
        Test.stopTest();

        existingGroups = zqu.zQuoteUtil.getChargeGroups(quote.Id);

        String expectedPrice = '100.00';
        for(zqu.zChargeGroup existingGroup : existingGroups) {
            if(existingGroup.productName == percentProduct) {
                for(zqu.zCharge charge : existingGroup.zCharges) {
                    system.assertEquals(expectedPrice, charge.EFFECTIVE_PRICE, 'the charge group\'s total should have been recaculated correctly');
                }
            }
        }
    }

    static testMethod void populateCustomPremierFieldsTest() {
        setup();
        setupCustomFields();

        List<zqu.zChargeGroup> chargeGroups = new List<zqu.zChargeGroup> { autoSetCharge };

        Test.startTest();
            PricingRules.populateCustomPercentProductFields(chargeGroups);
        Test.stopTest();

        chargeGroups = zqu.zQuoteUtil.getChargeGroups(quote.Id);

        for(zqu.zChargeGroup chargeGroup : chargeGroups) {
            if(chargeGroup.productName == percentProduct) {
                for(zqu.zCharge charge : chargeGroup.zCharges) {
                    //system.assertEquals(subscriptionCharge.Box_Discount__c, String.valueOf(charge.chargeObject.get('Box_Discount__c')), 'the charge\'s discount should be populated correctly');
                    //system.assertEquals(subscriptionCharge.List_Price__c, String.valueOf(charge.chargeObject.get('List_Price__c')), 'the charge\'s list price should be populated correctly');
                }
            }
        }
    }
}