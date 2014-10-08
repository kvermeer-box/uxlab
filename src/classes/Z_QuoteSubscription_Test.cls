@isTest
private class Z_QuoteSubscription_Test {

    static testMethod void testMethod1() {
    	
    	
     	String subscriptionId = '888888';
    	
    	Zuora__Subscription__c subscription = new Zuora__Subscription__c (
    												Zuora__Zuora_Id__c = subscriptionId, 
    												Zuora__Status__c='Active');
    	insert subscription;
    	
    	Zuora__SubscriptionProductCharge__c subscriptionProductCharge = new Zuora__SubscriptionProductCharge__c(
    												Zuora__Subscription__c = subscription.Id,
													Zuora__Type__c = 'Recurring', 
													Zuora__BillingPeriod__c = 'Quarter',
													Zuora__ExtendedAmount__c = 15000.00,
													Zuora__Model__c = 'Per Unit Pricing',
													Zuora__Price__c = 15.0,
													Zuora__Quantity__c = 100.0);
 
    	   
    	insert subscriptionProductCharge;
    	
    	Z_QuoteSubscription quoteSubscription = new Z_QuoteSubscription (subscriptionId);
    	Double arr = quoteSubscription.getARR();
		Double quantity = quoteSubscription.getQuantity();
		Double extendedAmount = quoteSubscription.getExtendedAmount();	
		String billingPeriod = quoteSubscription.getBillingPeriod();	
		    	
    	
 		double factor1 = Z_QuoteSubscription.getPaymentFrequencyFactor('Annual');
		double factor2 = Z_QuoteSubscription.getPaymentFrequencyFactor('Month');
		double factor3 = Z_QuoteSubscription.getPaymentFrequencyFactor('Quarter');
		double factor4 = Z_QuoteSubscription.getPaymentFrequencyFactor('Semi-Annual');
		double factor5 = Z_QuoteSubscription.getPaymentFrequencyFactor('Two Years');
		double factor6 = Z_QuoteSubscription.getPaymentFrequencyFactor('Three Years');
		double factor7 = Z_QuoteSubscription.getPaymentFrequencyFactor('Four Years');
		double factor8 = Z_QuoteSubscription.getPaymentFrequencyFactor('Five Years');
		double factor9 = Z_QuoteSubscription.getPaymentFrequencyFactor('Six Years');
		 	
    }
}