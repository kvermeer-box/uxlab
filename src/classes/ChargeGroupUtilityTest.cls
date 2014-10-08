@isTest
private class ChargeGroupUtilityTest {
    static zqu__ZProduct__c product;
    static zqu.zChargeGroup chargeGroup;

    static void setup() {
        product = TestFactory.prepareProductCatalog(TestFactory.rateplannames);

        Account acc = TestFactory.makeAccount();
        Opportunity opp = TestFactory.makeOpportunity(acc);
        zqu__Quote__c quote = TestFactory.makeQuote(opp);

        List<zqu__ProductRatePlan__c> productRatePlans = [
            SELECT Name
            FROM zqu__ProductRatePlan__c
            WHERE zqu__ZProduct__c = :product.Id
        ];

        chargeGroup = zqu.zQuoteUtil.getChargeGroups(quote.Id, new List<Id>{productRatePlans[0].Id})[0];
        for(zqu.zCharge charge : chargeGroup.zCharges) {
            charge.TOTAL = '20';
        }
        chargeGroup.zCharges = zqu.zQuoteUtil.calculateChargesOnTotalChange(chargeGroup.zCharges);
        zqu.zQuoteUtil.addChargeGroup(chargeGroup);
    }

    static testMethod void setDifferenceTest() {
        final Id a = '50130000000014a';
        final Id b = '50130000000014b';
        final Id c = '50130000000014c';

        Set<Id> originalSet = new Set<Id> { a, b, c };
        Set<Id> idsToRemove = new Set<Id> { b, c };

        Test.startTest();
            Set<Id> actual = ChargeGroupUtility.setDifference(originalSet, idsToRemove);
        Test.stopTest();

        system.assertEquals(new Set<Id>{ a }, actual, 'the only value in the set should be the one not removed');
    }

    static testMethod void setIntersectionTest() {
        final Id a = '50130000000014a';
        final Id b = '50130000000014b';
        final Id c = '50130000000014c';

        Set<Id> originalSet = new Set<Id> { a, b, c };
        Set<Id> idsToRetain = new Set<Id> { b, c };

        Test.startTest();
            Set<Id> actual = ChargeGroupUtility.setIntersection(originalSet, idsToRetain);
        Test.stopTest();

        system.assertEquals(new Set<Id>{ b, c }, actual, 'the only value in the set should be the values in both');
    }

    static testMethod void setIntersectionStringsTest() {
        final String a = 'a';
        final String b = 'b';
        final string c = 'c';

        Set<String> originalSet = new Set<String> { a, b, c };
        Set<String> stringsToRetain = new Set<String> { b, c };

        Test.startTest();
            Set<String> actual = ChargeGroupUtility.setIntersectionStrings(originalSet, stringsToRetain);
        Test.stopTest();

        system.assertEquals(new Set<String>{ b, c }, actual, 'the only value in the set should be the values in both');
    }

    static testMethod void getProductNamesOnQuoteTest() {
        final String name = 'Test Name Please Ignore';
        Account account = Z_TestUtils.createAccount(true);
        Opportunity opportunity = Z_TestUtils.createOpportunity(account.Id, true);
        zqu__Quote__c quote = Z_TestUtils.createZQuote(opportunity.Id, true);

        product = Z_TestUtils.createZProduct(false);
        product.Name = name;
        insert product;
        zqu__ProductRatePlan__c productRatePlan = Z_TestUtils.createZProductRatePlan(product.Id, true);
        zqu__ProductRatePlanCharge__c productRatePlanCharge = Z_TestUtils.createZProductRatePlanCharge(productRatePlan.Id, true);

        zqu__QuoteCharge__c quoteCharge = Z_TestUtils.createZQuoteCharge(quote.Id, productRatePlanCharge.Id, true);

        Test.startTest();
            Set<String> actual = ChargeGroupUtility.getProductNamesOnQuote(quote.Id);
        Test.stopTest();

        system.assertEquals(new Set<String> { name }, actual, 'the name on the product should have been returned');
    }

    static testMethod void getRelatedProducts() {
        setup();

        Test.startTest();
           Set<Id> actual = ChargeGroupUtility.getRelatedProducts(new List<zqu.zChargeGroup>{ chargeGroup });
        Test.stopTest();

        system.assertEquals(1, actual.size(), 'the correct number of products should have been returned');
        system.assertEquals(new Set<Id> { product.Id }, actual, 'the correct products should have been returned');
    }
}