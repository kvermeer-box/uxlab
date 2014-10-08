@isTest
private class Z_DisplayQuoteLinesExtension_Test
{

    static zqu__Quote__c quote;
    static zqu__ZProduct__c parentProduct;
    static List<zqu__ProductRatePlan__c> parentProductRatePlan;
    static zqu__ZProduct__c percentProduct;
    static List<zqu__ProductRatePlan__c> percentProductRatePlan;
    static zqu.zChargeGroup percentCharge;
    static zqu.zChargeGroup parentCharge;

    static Pricing_Rule__c pricingRule;
    static Zuora__SubscriptionProductCharge__c subscriptionCharge;
    static zqu__QuoteAmendment__c quoteAmendment;

    static final String percentName = 'Percent Product';
    static final String oldValue = '10.00';
    static final String newValue = '50.00';

	static void setup() {
    	
        Amount_Threshold__c threshold = Z_TestUtils.createAmountThreshold(true);

        parentProduct = TestFactory.prepareProductCatalog(TestFactory.rateplannames);
        percentProduct = TestFactory.prepareProductCatalog(TestFactory.rateplanKHnames);

        percentProduct.Name = percentName;
        update percentProduct;

        Account account = TestFactory.makeAccount();
        Opportunity opportunity = TestFactory.makeOpportunity(account);
        quote = TestFactory.makeQuote(opportunity);

        parentProductRatePlan = [
            SELECT Name, zqu__ZuoraId__c
            FROM zqu__ProductRatePlan__c
            WHERE zqu__ZProduct__c = :parentProduct.Id
        ];

        percentProductRatePlan = [
            SELECT Id
            FROM zqu__ProductRatePlan__c
            WHERE zqu__ZProduct__c = :percentProduct.Id
        ];

        pricingRule = Z_TestUtils.createPricingRule(parentProduct.Id, percentProduct.Id, 15, true);

        percentCharge = zqu.zQuoteUtil.getChargeGroups(quote.Id, new List<Id>{percentProductRatePlan[0].Id})[0];
        for(zqu.zCharge zcharge : percentCharge.zCharges) {
            zcharge.TOTAL = oldValue;
        }
        percentCharge.zCharges = zqu.zQuoteUtil.calculateChargesOnTotalChange(percentCharge.zCharges);

        parentCharge = zqu.zQuoteUtil.getChargeGroups(quote.Id, new List<Id>{parentProductRatePlan[0].Id})[0];
        for(zqu.zCharge zcharge : parentCharge.zCharges) {
            zcharge.TOTAL = oldValue;
        }
        parentCharge.zCharges = zqu.zQuoteUtil.calculateChargesOnTotalChange(parentCharge.zCharges);

        zqu.zQuoteUtil.addChargeGroups(new List<zqu.zChargeGroup>{parentCharge, percentCharge});

        Zuora__Subscription__c subscription = Z_TestUtils.createZSubscription(account.Id, true);
        subscriptionCharge = Z_TestUtils.createZSubscriptionProductCharge(subscription.Id, percentProduct.zqu__SKU__c, account.Id, false);
        subscriptionCharge.Zuora__External_Id__c = 'HK-47';
        subscriptionCharge.Box_Discount__c = '0.00';
        subscriptionCharge.List_Price__c = '100.00';
        insert subscriptionCharge;

        quoteAmendment = Z_TestUtils.createQuoteAmendment(quote.Id, true);

        zqu__QuoteRatePlan__c quoteRatePlan = Z_TestUtils.createQuoteRatePlan(quote.Id, quoteAmendment.Id, parentProductRatePlan[0].zqu__ZuoraId__c, subscriptionCharge.Zuora__External_Id__c, true);

		zqu__QuoteChargeSummary__c quoteChargeSummary;
		
		List<zqu__QuoteChargeSummary__c> quoteChargeSummaryList = new List<zqu__QuoteChargeSummary__c>();
		
        for(zqu.zCharge charge : percentCharge.zCharges) {
		
			
			quoteChargeSummary = Z_TestUtils.createQuoteChargeSummary(charge, quoteRatePlan.Id, opportunity.Id); 
			quoteChargeSummaryList.add(quoteChargeSummary);
			
			    
    
        }
    
        for(zqu.zCharge charge : parentCharge.zCharges) {
		
 
			quoteChargeSummary = Z_TestUtils.createQuoteChargeSummary(charge, quoteRatePlan.Id, opportunity.Id);
			quoteChargeSummaryList.add(quoteChargeSummary);   
  
        }

	}

	@isTest  
	static void testDisplayQuotesLines()
	{

    	setup();
 
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.standardController(quote);
        Z_DisplayQuoteLinesExtension ext = new Z_DisplayQuoteLinesExtension(sc);	
 
        Test.stopTest();

	}
}