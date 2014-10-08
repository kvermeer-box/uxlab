public class Z_ChargeGroupUtility {
	
	@future(callout=true)
    public static void processRenewalSubscription(Id quoteId){ 

        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = new Set<String>
            { 'Box_Discount__c'
            , 'List_Price__c'
            , 'Upsell_Price__c'
            , 'Upsell_Quantity__c'
            };

       if(quoteId==null) { return; }
    
    	List<zqu.ZChargeGroup> chargeGroupList = zqu.ZQuoteUtil.getChargeGroups(quoteId);
        
        if(chargeGroupList.isEmpty()) { return; }

		populateCustomPercentProductFields(chargeGroupList);
   
        chargeGroupList=zqu.zQuoteUtil.updateChargeGroups(chargeGroupList);
        
        zqu__Quote__c quote = new zqu__Quote__c(id = quoteId);
        quote.Processing__c = false;
        update quote;

    }
 
    public static Decimal stringToDecimal(String s) {
            
            if(s==null || s.length()==0){
            	return 0;	
            }
            
            Decimal d;
            
            try {
                d = Decimal.valueOf(s);
            } catch(TypeException e) {}
            
            return d;
    }

    public static void populateCustomPercentProductFields(List<zqu.ZChargeGroup> chargeGroupList) {
    	
        for(zqu.ZChargeGroup chargeGroup : chargeGroupList) {
 
                
                Map<zqu.zCharge, Zuora__SubscriptionProductCharge__c> chargeToSubscriptionCharge = PricingRules.getRelatedSubscriptionCharge(chargeGroup);
                
                for(zqu.zCharge charge : chargeGroup.zCharges) {
                
                    Zuora__SubscriptionProductCharge__c subscriptionCharge = chargeToSubscriptionCharge.get(charge);
                    
                    if(subscriptionCharge != null) {
                    	if(subscriptionCharge.List_Price__c!=null){
       						charge.chargeObject.put('List_Price__c', Decimal.valueOf(subscriptionCharge.List_Price__c));
                    	}
                    	if(subscriptionCharge.Box_Discount__c!=null){
        					charge.chargeObject.put('Box_Discount__c', Decimal.valueOf(subscriptionCharge.Box_Discount__c));
                    	}
                    }
                }
 
        }
    }
    
}