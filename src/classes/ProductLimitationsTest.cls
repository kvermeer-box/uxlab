@isTest
private class ProductLimitationsTest {
    static zqu__Quote__c quote;
    static zqu__QuoteCharge__c quoteCharge1;
    static zqu__QuoteCharge__c quoteCharge2;
    static zqu__QuoteCharge__c quoteCharge3;
    static List<zqu__ZProduct__c> products;
    static List<zqu__ProductRatePlan__c> productRatePlans;
    static Product_Rule__c rule;
    static Product_Group__c productGroup;
    static final Integer min = 0;

    static void setup(Integer numAllowed) {
        Account account = Z_TestUtils.createAccount(true);
        Opportunity opportunity = Z_TestUtils.createOpportunity(account.Id, true);
        quote = Z_TestUtils.createZQuote(opportunity.Id, true);

        products = Z_TestUtils.createZProducts(4, true);

        productRatePlans = Z_TestUtils.createProductRatePlans(products, true);

        List<zqu__ProductRatePlanCharge__c> productRatePlanCharges = Z_TestUtils.createProductRatePlanCharges(productRatePlans, true);

        quoteCharge1 = Z_TestUtils.createZQuoteCharge(quote.Id, productRatePlanCharges[0].Id, false);
        quoteCharge2 = Z_TestUtils.createZQuoteCharge(quote.Id, productRatePlanCharges[1].Id, false);
        quoteCharge3 = Z_TestUtils.createZQuoteCharge(quote.Id, productRatePlanCharges[2].Id, false);
        insert new List<zqu__QuoteCharge__c>{quoteCharge1, quoteCharge2, quoteCharge3};

        productGroup = Z_TestUtils.createProductGroup(true);
        Product_Group_Member__c member1 = Z_TestUtils.createProductGroupMember(products[1].Id, productGroup.Id, true);
        Product_Group_Member__c member2 = Z_TestUtils.createProductGroupMember(products[2].Id, productGroup.Id, true);
        productGroup = [
            SELECT Id, Name,
                (SELECT Product__c FROM Product_Group_Members__r)
            FROM Product_Group__c
            WHERE Id = :productGroup.Id
        ];
        rule = Z_TestUtils.createProductRule(productRatePlans[0].Id, 'error message', numAllowed, min, productGroup.Id, true);
    }

    static testMethod void QuoteLimitTest_LimitSurpassed() {
        setup(1);

        Test.startTest();
            ProductLimitationsUtility.QuoteLimit quoteLimit = new ProductLimitationsUtility.QuoteLimit
                ( new List<Product_Rule__c> { rule }
                , new List<Product_Group__c> { productGroup }
                , new List<Id> { products[1].Id, products[2].Id, products[3].Id }
                , new Set<Id> { productRatePlans[0].Id }
                , Pluck.ids(products)
                );
        Test.stopTest();

        Set<Id> actual =  quoteLimit.productToError.keySet();

        system.assertEquals(new Set<Id> { products[1].Id, products[2].Id }, actual, 'quoteLimit errors should include all products that have surpassed their limits');
    }

    static testMethod void QuoteLimitTest_LimitUnsurpassed() {
        setup(3);

        Test.startTest();
            ProductLimitationsUtility.QuoteLimit quoteLimit = new ProductLimitationsUtility.QuoteLimit
                ( new List<Product_Rule__c> { rule }
                , new List<Product_Group__c> { productGroup }
                , new List<Id> { products[1].Id, products[2].Id, products[3].Id }
                , new Set<Id> { productRatePlans[0].Id }
                , Pluck.ids(products)
                );
        Test.stopTest();

        Set<Id> actual =  quoteLimit.productToError.keySet();

        system.assertEquals(new Set<Id>{}, actual, 'no product limit was suprassed so no errors should exist');
    }
}