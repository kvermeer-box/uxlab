@isTest
private class Z_SubscriptionTest {
    static zqu__Quote__c quote;
    static List<Id> ratePlanIds;
    static List<zqu.zChargeGroup> chargeGroups;

    static void setup() {
        zqu__ZProduct__c product = TestFactory.prepareProductCatalog(TestFactory.rateplannames);
        Account acc = TestFactory.makeAccount();
        Opportunity opp = TestFactory.makeOpportunity(acc);
        quote = TestFactory.makeQuote(opp);

        List<zqu__ProductRatePlan__c> ratePlans = [
            SELECT Name
            FROM zqu__ProductRatePlan__c
            WHERE zqu__ZProduct__c = :product.Id
        ];

        ratePlanIds = new List<Id>();
        ratePlanIds.addAll(Pluck.ids(ratePlans));

        chargeGroups = zqu.zQuoteUtil.getChargeGroups(quote.Id, ratePlanIds);

        system.assertNotEquals(null, chargeGroups, 'wasn\'t able to create a charge group');
    }

    static testMethod void clearSubscriptionTest() {
        setup();

        Test.startTest();
            Z_SubscriptionUtility.clearSubscription(quote.Id);
        Test.stopTest();

        List<zqu.zChargeGroup> actual = zqu.zQuoteUtil.getChargeGroups(quote.Id);

        //system.assert(actual.isEmpty(), 'all charge groups should have been deleted');
    }
}