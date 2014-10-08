@isTest
private class ProductConflictTest {
    static List<zqu__ZProduct__c> products;
    static List<zqu__ProductRatePlan__c> productRatePlans;
    static zqu__Quote__c quote;
    static List<zqu.zChargeGroup> chargeGroups;

    static void setup() {
        products = new List<zqu__ZProduct__c>();
        products.add(TestFactory.prepareProductCatalog(TestFactory.rateplannames));
        products.add(TestFactory.prepareProductCatalog(TestFactory.rateplanKHnames));

        Account acc = TestFactory.makeAccount();
        Opportunity opp = TestFactory.makeOpportunity(acc);
        quote = TestFactory.makeQuote(opp);

        productRatePlans = [
            SELECT Name
            FROM zqu__ProductRatePlan__c
            WHERE zqu__ZProduct__c = :products[0].Id
        ];

        List<zqu__ProductRatePlan__c> productRatePlansKH = [
            SELECT Id
            FROM zqu__ProductRatePlan__c
            WHERE zqu__ZProduct__c = :products[1].Id
        ];

        List<Id> ratePlanIds = new List<Id>();
        ratePlanIds.addAll(Pluck.ids(productRatePlans));
        ratePlanIds.addAll(Pluck.ids(productRatePlansKH));

        chargeGroups = zqu.zQuoteUtil.getChargeGroups(quote.Id, ratePlanIds);

        system.assertNotEquals(null, chargeGroups, 'wasn\'t able to create a charge group');
    }

    static testMethod void findConflictingRatePlanIdsTest() {
        setup();

        Z_TestUtils.createProductConflictForRatePlans(productRatePlans[0].Id, productRatePlans[1].Id, true);

        Test.startTest();
            Set<Id> conflicts = ProductConflictUtility.findConflictingRatePlanIds(Pluck.ids(productRatePlans), quote.Id);
        Test.stopTest();

        system.assert(!conflicts.isEmpty(), 'a set of rate plans Ids should be returned');
        system.assertEquals(new Set<Id> { productRatePlans[0].Id, productRatePlans[1].Id }, conflicts, 'the map should return the correct conflicting rate plans given then quote as a key');
    }

    static testMethod void findConflictingProductIdsTest() {
        setup();

        Z_TestUtils.createProductConflict(products[0].Id, products[1].Id, true);

        Test.startTest();
            Set<Id> conflicts = ProductConflictUtility.findConflictingProductIds(Pluck.ids(products), quote.Id);
        Test.stopTest();

        system.assert(!conflicts.isEmpty(), 'a set of product Ids should be returned');
        system.assertEquals(new Set<Id> { products[0].Id, products[1].Id }, conflicts, 'the map should return the correct conflicting products given then quote as a key');
    }

    static testMethod void removeConflictingRatePlansTest() {
        setup();

        Z_TestUtils.createProductConflictForRatePlans(productRatePlans[0].Id, productRatePlans[1].Id, true);

        Test.startTest();
           Set<Id> filteredRatePlans = ProductConflictUtility.removeConflictingRatePlans(Pluck.ids(productRatePlans), quote.Id, chargeGroups);
        Test.stopTest();

        system.assert(!filteredRatePlans.contains(productRatePlans[0].Id), 'conflicting rate plan '+productRatePlans[0].Name+' should have been removed');
        system.assert(!filteredRatePlans.contains(productRatePlans[1].Id), 'conflicting rate plan '+productRatePlans[1].Name+' should have been removed');
    }

    static testMethod void removeConflictingProductsTest() {
        setup();

        Z_TestUtils.createProductConflict(products[0].Id, products[1].Id, true);

        Test.startTest();
            Set<Id> filteredProducts = ProductConflictUtility.removeConflictingProducts(Pluck.ids(products), quote.Id, chargeGroups);
        Test.stopTest();

        system.assert(!filteredProducts.contains(products[0].Id), 'conflicting product '+products[0].Name+' should have been removed');
        system.assert(!filteredProducts.contains(products[1].Id), 'conflicting product '+products[1].Name+' should have been removed');
    }
}