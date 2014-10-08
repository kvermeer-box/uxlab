@isTest
private class QuoteApproval_ListExtension_Test {


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

        QuoteApproval_ZQuoteDataSource ds = new QuoteApproval_ZQuoteDataSource(quote.Id);
        Quote_Approval__c approval1 = new Quote_Approval__c(
                                Active__c = true, 
                                Status__c = QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_IN_PROGRESS, 
                                ZQuote__c = quote.Id);
        insert approval1;


        Quote_Approval__c approval2 = new Quote_Approval__c(
                                Active__c = true, 
                                Status__c = QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_REVOKED, 
                                ZQuote__c = quote.Id);
        insert approval2;

        Quote_Approval__c approval3 = new Quote_Approval__c(
                                Active__c = true, 
                                Status__c = QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_REJECTED, 
                                ZQuote__c = quote.Id);
        insert approval3;


        Quote_Approval__c approval4 = new Quote_Approval__c(
                                Active__c = true, 
                                Status__c = QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_APPROVED, 
                                ZQuote__c = quote.Id);
        insert approval4; 


        Quote_Approval__c approval5 = new Quote_Approval__c(
                                Active__c = false, 
                                Status__c = QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_IN_PROGRESS, 
                                ZQuote__c = quote.Id);
        insert approval5;


        Quote_Approval__c approval6 = new Quote_Approval__c(
                                Active__c = false, 
                                Status__c = QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_REVOKED, 
                                ZQuote__c = quote.Id);
        insert approval6;

        Quote_Approval__c approval7 = new Quote_Approval__c(
                                Active__c = false, 
                                Status__c = QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_REJECTED, 
                                ZQuote__c = quote.Id);
        insert approval7;


        Quote_Approval__c approval8= new Quote_Approval__c(
                                Active__c = false, 
                                Status__c = QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_APPROVED, 
                                ZQuote__c = quote.Id);
        insert approval8; 


        ApexPages.StandardController sc = new ApexPages.standardController(quote);
        QuoteApproval_ListExtension ext = new QuoteApproval_ListExtension(sc);
        
        List<QuoteApproval_ListExtension.ApprovalDisplay> approvalList = ext.getApprovals(); 
        
        for(QuoteApproval_ListExtension.ApprovalDisplay approval : approvalList){
        
        	String approvalColor = approval.getColor();
        	Quote_Approval__c qa = approval.getApproval();	
        	
        }
        
        
        ext.toggleShowActive();    	
        String buttonText = ext.getButtonText();
        boolean approvalsEmpty = ext.getApprovalsEmpty();
	}


}