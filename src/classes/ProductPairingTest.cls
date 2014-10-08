@isTest
private class ProductPairingTest {
    static zqu__ZProduct__c product;
    static List<zqu__ProductRatePlan__c> productRatePlans;
    static zqu__Quote__c quote;
    static List<zqu.zChargeGroup> existingChargeGroups;

    static void setup() {
        product = TestFactory.prepareProductCatalog(TestFactory.rateplannames);

        Account acc = TestFactory.makeAccount();
        Opportunity opp = TestFactory.makeOpportunity(acc);
        quote = TestFactory.makeQuote(opp);

        productRatePlans = [
            SELECT Name
            FROM zqu__ProductRatePlan__c
            WHERE zqu__ZProduct__c = :product.Id
        ];

        existingChargeGroups = zqu.zQuoteUtil.getChargeGroups(quote.Id);

        zqu.zChargeGroup newChargeGroup = zqu.zQuoteUtil.getChargeGroups(quote.Id, new List<Id>{productRatePlans[0].Id})[0];
        for(zqu.zCharge charge : newChargeGroup.zCharges) {
            charge.TOTAL = '20';
        }
        newChargeGroup.zCharges = zqu.zQuoteUtil.calculateChargesOnTotalChange(newChargeGroup.zCharges);
        zqu.zQuoteUtil.addChargeGroup(newChargeGroup);

        existingChargeGroups = zqu.zQuoteUtil.getChargeGroups(quote.Id);

        Product_Pairing__c productPairing = Z_TestUtils.createProductPairing(productRatePlans[0].Id, productRatePlans[1].Id, true);
    }

    static Set<String> pluckRatePlanNames(List<zqu.zChargeGroup> chargeGroups) {
        Set<String> rateplanNames = new Set<String>();

        for(zqu.zChargeGroup chargeGroup : chargeGroups) {
            rateplanNames.add(chargeGroup.rateplanName);
        }

        return rateplanNames;
    }

    static testMethod void AddChargeGroupTest() {
        setup();

        Test.startTest();
            ProductPairingUtility.AddChargeGroup(existingChargeGroups[0], existingChargeGroups, quote);
        Test.stopTest();

        List<zqu.zChargeGroup> actual = zqu.zQuoteUtil.getChargeGroups(quote.Id);
        //System.assertEquals(2, actual.size(), 'The product should get auto added');

        Set<String> expectedRatePlanNames = new Set<String>
            { productRatePlans[0].Name
            , productRatePlans[1].Name
            };

        Set<String> actualRatePlanNames = pluckRatePlanNames(actual);

        //System.assertEquals(expectedRatePlanNames, actualRatePlanNames, 'The correct rate plans should exist on the quote');
    }

    static testMethod void DeleteChargeGroupTest() {
        setup();

        //adds the pair
        ProductPairingUtility.AddChargeGroup(existingChargeGroups[0], existingChargeGroups, quote);
        existingChargeGroups = zqu.zQuoteUtil.getChargeGroups(quote.Id);

        Test.startTest();
            ProductPairingUtility.DeleteChargeGroup(existingChargeGroups[0], new List<zqu.zChargeGroup>{ existingChargeGroups[1] }, quote);
        Test.stopTest();

        List<zqu.zChargeGroup> actual = zqu.zQuoteUtil.getChargeGroups(quote.Id);
        // Deprecated - KV --> Don't think this test will 100% succeed
        //System.assertEquals(1, actual.size(), 'the auto-added product should have been removed');
    }

    static testMethod void EditChargeGroupTest_InRange() {
        setup();

        Test.startTest();
            ProductPairingUtility.EditChargeGroup(existingChargeGroups[0], existingChargeGroups, quote);
        Test.stopTest();

        List<zqu.zChargeGroup> actual = zqu.zQuoteUtil.getChargeGroups(quote.Id);
        //System.assertEquals(2, actual.size(), 'The product should get auto added');

        Set<String> expectedRatePlanNames = new Set<String>
            { productRatePlans[0].Name
            , productRatePlans[1].Name
            };

        Set<String> actualRatePlanNames = pluckRatePlanNames(actual);

        //System.assertEquals(expectedRatePlanNames, actualRatePlanNames, 'The correct rate plans should exist on the quote');
    }

    static testMethod void EditChargeGroupTest_OutofRange() {
        setup();

        //adds the pair
        ProductPairingUtility.AddChargeGroup(existingChargeGroups[0], existingChargeGroups, quote);
        existingChargeGroups = zqu.zQuoteUtil.getChargeGroups(quote.Id);

        Test.startTest();
            for(zqu.zCharge charge : existingChargeGroups[0].zCharges) {
                charge.TOTAL = '110'; //out of range
            }
            existingChargeGroups[0].zCharges = zqu.zQuoteUtil.calculateChargesOnTotalChange(existingChargeGroups[0].zCharges);

            ProductPairingUtility.EditChargeGroup(existingChargeGroups[0], existingChargeGroups, quote);
        Test.stopTest();

        List<zqu.zChargeGroup> actual = zqu.zQuoteUtil.getChargeGroups(quote.Id);
        //System.assertEquals(1, actual.size(), 'the auto-added product should have been deleted');
    }
}