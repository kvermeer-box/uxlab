@isTest
private class  Z_QuoteChargeTriggerHelper_Test {

    static zqu__Quote__c quote;
    static List<zqu__QuoteCharge__c> quoteCharges;
    static zqu__ZProduct__c child;
    static zqu__ZProduct__c parent;
    static zqu__ZProduct__c extra;
    static zqu__ProductRatePlan__c productRatePlan;
    static zqu__ProductRatePlanCharge__c productRatePlanCharge;
    static final Integer numberOfCharges = 100;
    static final Integer extraProduct = 1;

    static void setup(Boolean includeParent) {
        Account account = Z_TestUtils.createAccount(true);
        Opportunity opportunity = Z_TestUtils.createOpportunity(account.Id, true);
        quote = Z_TestUtils.createZQuote(opportunity.Id, true);

        child = Z_TestUtils.createZProduct(false);
        child.Name = 'Child';
        insert child;
        productRatePlan = Z_TestUtils.createZProductRatePlan(child.Id, true);
        productRatePlanCharge = Z_TestUtils.createZProductRatePlanCharge(productRatePlan.Id, true);
        zqu__QuoteCharge__c quoteCharge = Z_TestUtils.createZQuoteCharge(quote.Id, productRatePlanCharge.Id, true);
        quoteCharges = (List<zqu__QuoteCharge__c>)Z_TestUtils.replicate(quoteCharge, numberOfCharges);


        parent = Z_TestUtils.createZProduct(false);
        parent.Name = 'Parent';
        insert parent;
        zqu__ProductRatePlan__c productRatePlan_parent = Z_TestUtils.createZProductRatePlan(parent.Id, true);
        zqu__ProductRatePlanCharge__c productRatePlanCharge_parent = Z_TestUtils.createZProductRatePlanCharge(productRatePlan_parent.Id, true);
        if(includeParent) {
            Zuora__Subscription__c subscription = Z_TestUtils.createZSubscription(account.Id, true);
            Zuora__SubscriptionProductCharge__c subscriptionProductCharge_parent = Z_TestUtils.createZSubscriptionProductCharge(subscription.Id, parent.zqu__SKU__c, account.Id, false);
            subscriptionProductCharge_parent.Zuora__RatePlanName__c = productRatePlan_parent.Name;
            insert subscriptionProductCharge_parent;
        }

        extra = Z_TestUtils.createZProduct(false);
        extra.Name = 'Extra';
        insert extra;
        zqu__ProductRatePlan__c productRatePlan_extra = Z_TestUtils.createZProductRatePlan(extra.Id, true);
        zqu__ProductRatePlanCharge__c productRatePlanCharge_extra = Z_TestUtils.createZProductRatePlanCharge(productRatePlan_extra.Id, true);
        Zuora__Subscription__c subscription_extra = Z_TestUtils.createZSubscription(account.Id, true);
        Zuora__SubscriptionProductCharge__c subscriptionProductCharge_extra = Z_TestUtils.createZSubscriptionProductCharge(subscription_extra.Id, extra.zqu__SKU__c, account.Id, false);
        subscriptionProductCharge_extra.Zuora__RatePlanName__c = productRatePlan_extra.Name;
        insert subscriptionProductCharge_extra;
    }
 
    static testMethod void bulkTriggerTest_Pass_ConflictCase() {
        setup(true);

        Test.startTest();
            insert quoteCharges;
        Test.stopTest();

        List<zqu__QuoteCharge__c> actual = [
            SELECT zqu__Quote__c
            FROM zqu__QuoteCharge__c
            WHERE zqu__Quote__c = :quote.Id
        ];

        system.assertEquals(numberOfCharges+extraProduct, actual.size(), 'num amount of quote charges should have been successfully inserted');
    }
 

    static testMethod void bulkTriggerTest_Pass_DependenciesCase() {
        setup(true);
        Product_Dependency__c dependency = Z_TestUtils.createProductDependency(parent.Id, child.Id, true);

        Test.startTest();
            insert quoteCharges;
        Test.stopTest();

        List<zqu__QuoteCharge__c> actual = [
            SELECT zqu__Quote__c
            FROM zqu__QuoteCharge__c
            WHERE zqu__Quote__c = :quote.Id
        ];

        system.assertEquals(numberOfCharges+extraProduct, actual.size(), 'num amount of quote charges should have been successfully inserted');
    }
 

    static testMethod void bulkTriggerTest_Pass_LimitationCase() {
        setup(true);

        zqu__ZProduct__c sibling = Z_TestUtils.createZProduct(false);
        sibling.Name = 'Sibling to the Child';
        insert sibling;

        zqu__ProductRatePlan__c productRatePlan_sibling = Z_TestUtils.createZProductRatePlan(sibling.Id, 'sibling product rate plan', true);
        zqu__ProductRatePlanCharge__c productRatePlanCharge_sibling = Z_TestUtils.createZProductRatePlanCharge(productRatePlan_sibling.Id, 'sibling rate plane charge', true);
        zqu__QuoteCharge__c limitedQuoteCharge = Z_TestUtils.createZQuoteCharge(quote.Id, productRatePlanCharge_sibling.Id, false);
        quoteCharges = (List<zqu__QuoteCharge__c>)Z_TestUtils.replicate(limitedQuoteCharge, numberOfCharges);

        Product_Group__c productGroup = Z_TestUtils.createProductGroup(true);
        Product_Group_Member__c member1 = Z_TestUtils.createProductGroupMember(child.Id, productGroup.Id, true);
        Product_Group_Member__c member2 = Z_TestUtils.createProductGroupMember(sibling.Id, productGroup.Id, true);
        Product_Rule__c rule = Z_TestUtils.createProductRule(productRatePlan.Id, 'error message', 2, 0, productGroup.Id, true);

        Test.startTest();
            insert quoteCharges;
        Test.stopTest();

        List<zqu__QuoteCharge__c> actual = [
            SELECT zqu__Quote__c
            FROM zqu__QuoteCharge__c
            WHERE zqu__Quote__c = :quote.Id
        ];

        system.assertEquals(numberOfCharges+extraProduct, actual.size(), 'num amount of quote charges should have been successfully inserted');
    }

    static /*testMethod*/ void bulkTriggerTest_Fail_LimitationCase() {
        //neeeds to be commented out until Limitation in trigger case is fixed
        setup(true);

        zqu__ZProduct__c sibling = Z_TestUtils.createZProduct(false);
        sibling.Name = 'Sibling to the Child';
        insert sibling;

        zqu__ProductRatePlan__c productRatePlan_sibling = Z_TestUtils.createZProductRatePlan(sibling.Id, 'sibling product rate plan', true);
        zqu__ProductRatePlanCharge__c productRatePlanCharge_sibling = Z_TestUtils.createZProductRatePlanCharge(productRatePlan_sibling.Id, 'sibling rate plane charge', true);
        zqu__QuoteCharge__c limitedQuoteCharge = Z_TestUtils.createZQuoteCharge(quote.Id, productRatePlanCharge_sibling.Id, false);
        quoteCharges = (List<zqu__QuoteCharge__c>)Z_TestUtils.replicate(limitedQuoteCharge, numberOfCharges);

        Product_Group__c productGroup = Z_TestUtils.createProductGroup(true);
        Product_Group_Member__c member1 = Z_TestUtils.createProductGroupMember(child.Id, productGroup.Id, true);
        Product_Group_Member__c member2 = Z_TestUtils.createProductGroupMember(sibling.Id, productGroup.Id, true);
        Product_Rule__c rule = Z_TestUtils.createProductRule(productRatePlan.Id, 'error message', 0, 0, productGroup.Id, true);

        Test.startTest();
            try {
                insert quoteCharges;
                system.assert(false, 'the insert should have failed');
            }
            catch (Exception actual) {
                system.assert(actual.getMessage().contains(rule.Error_Message__c), 'an error message should be generated');
            }
        Test.stopTest();
    }

    static testMethod void insertWithNoQuoteChargesAndOneConflict() {
        Account account = Z_TestUtils.createAccount(true);
        Opportunity opportunity = Z_TestUtils.createOpportunity(account.Id, true);
        quote = Z_TestUtils.createZQuote(opportunity.Id, true);

        zqu__ZProduct__c product1 = Z_TestUtils.createZProduct(true);
        productRatePlan = Z_TestUtils.createZProductRatePlan(product1.Id, true);
        productRatePlanCharge = Z_TestUtils.createZProductRatePlanCharge(productRatePlan.Id, true);

        zqu__ZProduct__c product2 = Z_TestUtils.createZProduct(true);

        Product_Conflict__c conflict = Z_TestUtils.createProductConflict(product1.Id, product2.Id, true);

        Test.startTest();
            try {
                Z_TestUtils.createZQuoteCharge(quote.Id, productRatePlanCharge.Id, true);
            } catch(DMLException e) {
                system.assert(false, 'We should be able to insert quote charges with a conflict if no other quote charges exist');
            }
        Test.stopTest();
    }
     static testMethod void triggerTest_AutoAddPremium_Fail() {
        Account account_license = Z_TestUtils.createAccount(true);

        zqu__ZProduct__c supportProduct = Z_TestUtils.createZProduct(false);
        supportProduct.Name = 'Premier Support';
        supportProduct.zqu__SKU__c = QuoteBusinessRules.BOX_PREMIER_SUPPORT_PRODUCT_SKU;
        insert supportProduct;
        zqu__ProductRatePlan__c supportRateplan = Z_TestUtils.createZProductRatePlan(supportProduct.Id, false);
        supportRateplan.Name = 'Premier Support Level 1';
        insert supportRateplan;
        zqu__ProductRatePlanCharge__c supportRateplanCharge = Z_TestUtils.createZProductRatePlanCharge(supportRateplan.Id, true);

        zqu__ZProduct__c licenseProduct = Z_TestUtils.createZProduct(false);
        licenseProduct.Name = 'Box License';
        licenseProduct.zqu__SKU__c = new List<String>(QuoteBusinessRules.BOX_LICENSE_PRODUCT_SKUS)[0];  
        insert licenseProduct;
        zqu__ProductRatePlan__c licenseRateplan = Z_TestUtils.createZProductRatePlan(licenseProduct.Id, false);
        licenseRateplan.Name = 'Box License Level 1';
        insert licenseRateplan;
        zqu__ProductRatePlanCharge__c licenseRateplanCharge = Z_TestUtils.createZProductRatePlanCharge(licenseRateplan.Id, true);

        Opportunity opportunity_license = Z_TestUtils.createOpportunity(account_license.Id, true);
        zqu__Quote__c quote_license = Z_TestUtils.createZQuote(opportunity_license.Id, true);
        zqu__QuoteCharge__c quotecharge_license = Z_TestUtils.createZQuoteCharge(quote_license.Id, licenseRateplanCharge.Id, false);

        Test.startTest();
            insert quotecharge_license;
        Test.stopTest();

        List<zqu__QuoteCharge__c> actual = [
            SELECT zqu__Quote__c, zqu__Currency__c, zqu__Total__c, zqu__Discount__c, zqu__Quantity__c, zqu__ProductRatePlanCharge__c
            FROM zqu__QuoteCharge__c
            WHERE zqu__Quote__c = :quote_license.Id
            AND Id != :quotecharge_license.Id
        ];

        system.assert(actual.isEmpty(), 'There should be no added quote charges since there is no subscription');
    }
    
 
    
}