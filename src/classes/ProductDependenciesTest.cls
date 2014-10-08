@isTest
private class ProductDependenciesTest {
    static zqu__ZProduct__c child;
    static zqu__ZProduct__c parent;
    static zqu__ZProduct__c extra;
    static zqu__Quote__c quote;
    static Product_Dependency__c dependency;

    static void setup(Boolean includeParent) {
        Account account = Z_TestUtils.createAccount(true);
        Opportunity opportunity = Z_TestUtils.createOpportunity(account.Id, true);
        quote = Z_TestUtils.createZQuote(opportunity.Id, true);

        child = Z_TestUtils.createZProduct('Morrowind', 'Elder Scrolls III', true);
        zqu__ProductRatePlan__c productRatePlan = Z_TestUtils.createZProductRatePlan(child.Id, true);
        zqu__ProductRatePlanCharge__c productRatePlanCharge = Z_TestUtils.createZProductRatePlanCharge(productRatePlan.Id, true);

        parent = Z_TestUtils.createZProduct('Cyrodiil', 'Elder Scrolls IV', true);
        if(includeParent) {
            Zuora__Subscription__c subscription = Z_TestUtils.createZSubscription(account.Id, true);
            Zuora__SubscriptionProductCharge__c subscriptionProductCharge_parent = Z_TestUtils.createZSubscriptionProductCharge(subscription.Id, parent.zqu__SKU__c, account.Id, true);
        }

        extra = Z_TestUtils.createZProduct('Skyrim', 'Elder Scrolls V', true);
        Zuora__Subscription__c subscription_extra = Z_TestUtils.createZSubscription(account.Id, true);
        Zuora__SubscriptionProductCharge__c subscriptionProductCharge_extra = Z_TestUtils.createZSubscriptionProductCharge(subscription_extra.Id, extra.zqu__SKU__c, account.Id, true);

        dependency = Z_TestUtils.createProductDependency(parent.Id, child.Id, true);
    }

    static testMethod void QuoteDependencyTest_MissingParent() {
        setup(false);

        Test.startTest();
            ProductDependenciesUtility.QuoteDependency quoteDependency = new ProductDependenciesUtility.QuoteDependency(
                new List<Product_Dependency__c> { dependency },
                new Set<Id> { child.Id, extra.Id },
                new Set<Id> { parent.Id, child.Id, extra.Id } );
        Test.stopTest();

        Set<Id> actual = quoteDependency.productToError.keySet();

        system.assert(!actual.isEmpty(), 'there should be products missing dependencies since the parent was not included');
        system.assertEquals(new Set<Id> { child.Id }, actual, 'the product with a dependency issue should have been returned');
    }

    static testMethod void QuoteDependencyTest_IncludedParent() {
        setup(false);

        Test.startTest();
            ProductDependenciesUtility.QuoteDependency quoteDependency = new ProductDependenciesUtility.QuoteDependency(
                new List<Product_Dependency__c> { dependency },
                new Set<Id> { parent.Id, child.Id, extra.Id },
                new Set<Id> { parent.Id, child.Id, extra.Id } );
        Test.stopTest();

        Set<Id> actual = quoteDependency.productToError.keySet();

        system.assert(actual.isEmpty(), 'there should be no products missing dependencies since the parent was not included');
    }
}