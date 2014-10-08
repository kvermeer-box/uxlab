public class Z_QuoteChargeValidationUtility {

 	public static final String RATE_PLAN_GROUP_PREMIER_SUPPORT = 'Premier Support';
 	public static final String CURRENCY_CODE_USD = 'USD'; 
 	public static final String CUSTOM_SETTING_PREMIER_SUPPORT_MINIMUM = 'Premier Support Minimum ';
  
	public static List <ApexPages.Message> validate(Id quoteId, zqu.ZChargeGroup chargeGroup){

		List <ApexPages.Message> messageList = new List <ApexPages.Message>();

		ApexPages.Message errorMessage;
		
		System.debug('>>>>>>>>>>>chargeGroup='+chargeGroup);  
		
		zqu__Quote__c quote = getQuote(quoteId);
		
		/* validate premier support price */
		errorMessage = validatePremierSupport(quote, chargeGroup);
		
		if(errorMessage!=null){
			messageList.add(errorMessage);	
		}	


		return messageList;
	}

 

	public static ApexPages.Message validatePremierSupport(zqu__Quote__c quote, zqu.ZChargeGroup chargeGroup){

		ApexPages.Message errorMessage;

    	List<String> ratePlanGroupNames = new List<String>();
    	ratePlanGroupNames.add(RATE_PLAN_GROUP_PREMIER_SUPPORT); 
    	Z_RatePlanGroup ratePlanGroups = new Z_RatePlanGroup(ratePlanGroupNames);
    	
    	String currencyCode = quote.zqu__Currency__c;
    	
		System.debug('>>>>>>>>currencyCode='+currencyCode);
		
		Amount_Threshold__c customSettingThreshold = Amount_Threshold__c.getInstance(CUSTOM_SETTING_PREMIER_SUPPORT_MINIMUM + currencyCode);

		if(customSettingThreshold == null){
			return errorMessage;  
		}	
		
		Decimal threshold = customSettingThreshold.Threshold_Amount__c;
		
		if(threshold==null || threshold<=0){
			return errorMessage;        
		}
		
        for(zqu.zCharge charge : chargeGroup.zCharges) {

			if(ratePlanGroups.containsRatePlanCharge (RATE_PLAN_GROUP_PREMIER_SUPPORT,charge.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID)){
				
				System.debug('>>>>>>>>>>>Z_QuoteChargeValidationUtility.validate: PREMIER SUPPORT');	
				
		        Decimal total = ChargeGroupUtility.getChargeGroupTotal(chargeGroup) * quote.Payment_Frequency_Number__c; 
		        
				System.debug('>>>>>>>>>>>total='+total);
				System.debug('>>>>>>>>>>>threshold='+threshold);
				

				if(total<threshold){
					errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Premier Support can\'t be sold for under ' + Integer.valueOf(threshold) + '.');
				} 
			}    	
        }
		
 
		return errorMessage;		
		
	}


	/* use quote id to return a quote */
	public static zqu__Quote__c getQuote(Id quoteId){
	
		if(quoteId==null){		
			return null;	
		}
		
		for(zqu__Quote__c q : [Select z.Payment_Frequency__c, z.Id, ARR__c,
										z.Payment_Frequency_Number__c, 
										zqu__PaymentMethod__c,  
										zqu__SubscriptionType__c, Recurring_Payment__c,
										z.zqu__SoldToContact__r.Email, z.zqu__SoldToContact__c, 
										z.zqu__BillToContact__r.Email, z.zqu__BillToContact__c,
										zqu__Currency__c   
									From zqu__Quote__c z 
										Where z.Id =: quoteId]){
			
			return q;		
			
		}//end-for
		 
		return null;
			
	}

}