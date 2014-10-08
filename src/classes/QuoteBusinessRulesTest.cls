@isTest
private class QuoteBusinessRulesTest {
    static Boolean isCloudConnect = false;
    static List<zqu__ProductRatePlan__c> productRatePlans;
    static List<zqu__ProductRatePlan__c> customRatePlans;
    static List<zqu.zChargeGroup> chargeGroups;
    static zqu__Quote__c quote;

    static void setup() {
        List<zqu__ZProduct__c> products = new List<zqu__ZProduct__c>();
        products.add(TestFactory.prepareProductCatalog(TestFactory.rateplannames));
        products.add(TestFactory.prepareProductCatalog(TestFactory.rateplanKHnames));

        if(isCloudConnect) {
            List<String> cloudConnectNames = new List<String>(QuoteBusinessRules.cloudConnectProductNames);
            products[0].Name = cloudConnectNames[0];
            update products;
        }

        Account acc = TestFactory.makeAccount();
        Opportunity opp = TestFactory.makeOpportunity(acc);
        quote = TestFactory.makeQuote(opp);

        productRatePlans = [
            SELECT Name
            FROM zqu__ProductRatePlan__c
            WHERE zqu__ZProduct__c = :products[0].Id
        ];

        if(isCLoudConnect) {
            for(zqu__ProductRatePlan__c ratePlan : productRatePlans) {
                ratePlan.Name = QuoteBusinessRules.cloudConnectImplementationRatePlanName;
            }

            update productRatePlans;
        }

        customRatePlans = [
            SELECT Id
            FROM zqu__ProductRatePlan__c
            WHERE zqu__ZProduct__c = :products[1].Id
        ];

        List<Id> ratePlanIds = new List<Id>();

        ratePlanIds.addAll(Pluck.ids(productRatePlans));

        chargeGroups = zqu.zQuoteUtil.getChargeGroups(quote.Id, ratePlanIds);

        system.assertNotEquals(null, chargeGroups, 'wasn\'t able to create a charge group');

        productRatePlans.addAll(customRatePlans);
    }

    static testMethod void removeDuplicateRatePlansTest() {
        setup();

        Test.startTest();
            Set<Id> filteredRatePlans = QuoteBusinessRules.removeDuplicateRatePlans(Pluck.ids(productRatePlans), chargeGroups);
        Test.stopTest();

        system.assert(!filteredRatePlans.isEmpty(), 'rate plans should have been returned');
        system.assertEquals(Pluck.ids(customRatePlans), filteredRatePlans, 'only rate plans not on the chargeGroups should be returned');
    }

    static testMethod void removeCloudConnectImplementationTest() {
        isCloudConnect = true;
        setup();

        Test.startTest();
            Set<Id> filteredRatePlans = QuoteBusinessRules.removeCloudConnectImplementation(Pluck.ids(productRatePlans), quote.Id);
        Test.stopTest();

        system.assert(!filteredRatePlans.isEmpty(), 'rate plans should have been returned');
        system.assertEquals(Pluck.ids(customRatePlans), filteredRatePlans, 'only rate plans not on the chargeGroups should be returned');
    }
}