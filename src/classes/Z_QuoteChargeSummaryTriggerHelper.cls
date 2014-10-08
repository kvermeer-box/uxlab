public class Z_QuoteChargeSummaryTriggerHelper { 
	  
    public static void beforeInsert(List<zqu__QuoteChargeSummary__c> quoteChargeSummaryList) {


		updateFields(quoteChargeSummaryList);

    }

    public static void beforeUpdate(List<zqu__QuoteChargeSummary__c> quoteChargeSummaryList,
                                    Map<Id,zqu__QuoteChargeSummary__c> oldQuoteChargeSummaryMap) {

		updateFields(quoteChargeSummaryList);


    }
 
    public static void updateFields(List<zqu__QuoteChargeSummary__c> quoteChargeSummaryList) {
     
    	Set<Id> quoteRatePlanChargeIds = new Set<Id>();
    	Map<Id, zqu__QuoteRatePlanCharge__c> quoteRatePlanChargeMap = new Map<Id,zqu__QuoteRatePlanCharge__c>();
    	    
    	Set<Id> quoteChargeIds = new Set<Id>();
    	Map<Id, zqu__QuoteCharge__c> quoteChargeMap = new Map<Id,zqu__QuoteCharge__c>();
    	    	 
    	Set<Id> quoteRatePlanIds = new Set<Id>();    	    	 
    	Map<Id, zqu__QuoteRatePlan__c> quoteRatePlanMap = new Map<Id,zqu__QuoteRatePlan__c>(); 


    	Set<String> productRatePlanZuoraIds = new Set<String>();
    	Map<String, zqu__ProductRatePlan__c> productRatePlanMap = new Map<String,zqu__ProductRatePlan__c>();
    	
    	Set<String> subscriptionRatePlanChargeZuoraIds = new Set<String>();
    	Map<String, Zuora__SubscriptionProductCharge__c> subscriptionRatePlanChargeMap = new Map<String,Zuora__SubscriptionProductCharge__c>();
    	      	    	 
 
    	    
    	// get quote rate plan charge Ids, quote charge Ids
    	for(zqu__QuoteChargeSummary__c qcs : quoteChargeSummaryList){

    		if(qcs.zqu__QuoteRatePlan__c!=null){
    			quoteRatePlanIds.add(qcs.zqu__QuoteRatePlan__c);	
    		}	
    	 
     		if(qcs.zqu__QuoteRatePlanCharge__c!=null){
    			quoteRatePlanChargeIds.add(qcs.zqu__QuoteRatePlanCharge__c);	
    		}	
    			
    		if(qcs.zqu__Quote_Charge__c!=null){
    			quoteChargeIds.add(qcs.zqu__Quote_Charge__c);	
    		}	

    	}	


		// get quote plans 
		if(quoteRatePlanIds.size()>0){
			for(zqu__QuoteRatePlan__c qrp : [Select z.zqu__SubscriptionRatePlanZuoraId__c, z.zqu__Quote__c, 
														z.zqu__QuoteRatePlanZuoraId__c, z.zqu__QuoteProductName__c, 
														z.zqu__QuoteAmendment__c, z.zqu__ProductRatePlanZuoraId__c, 
														z.zqu__AmendmentType__c, z.Name, z.Id 
													From zqu__QuoteRatePlan__c z 
															where Id in: quoteRatePlanIds]){

				quoteRatePlanMap.put(qrp.Id, qrp);
				if(qrp.zqu__ProductRatePlanZuoraId__c!=null){
					productRatePlanZuoraIds.add(qrp.zqu__ProductRatePlanZuoraId__c);
				}
				
			}
		}

		
		System.debug('>>>>>>>>>productRatePlanZuoraIds='+productRatePlanZuoraIds);
		
		
		// get quote plan charges 
		if(quoteRatePlanChargeIds.size()>0){
			for(zqu__QuoteRatePlanCharge__c qrpc : [Select z.zqu__SubscriptionRatePlanChargeZuoraId__c, 
															z.zqu__QuoteRatePlan__c, z.zqu__QuoteRatePlanChargeZuoraId__c, 
															z.zqu__ProductRatePlanChargeZuoraId__c, 
															z.Name, z.Id, z.Product_Rate_Plan_ID__c,
															z.zqu__QuoteRatePlan__r.zqu__Quote__c  
														From zqu__QuoteRatePlanCharge__c z 
															where Id in: quoteRatePlanChargeIds]){

				quoteRatePlanChargeMap.put(qrpc.Id, qrpc);
				if(qrpc.zqu__SubscriptionRatePlanChargeZuoraId__c!=null){
					subscriptionRatePlanChargeZuoraIds.add(qrpc.zqu__SubscriptionRatePlanChargeZuoraId__c);
				}
				
			}
		}

		// get quote charges 
		if(quoteChargeIds.size()>0){
			for(zqu__QuoteCharge__c qc : [Select z.zqu__ProductRatePlanCharge__c, z.zqu__Quote__c, 
														z.Product_Rate_Plan_ID__c, z.Id 
													From zqu__QuoteCharge__c z 
														where Id in: quoteChargeIds]){

				quoteChargeMap.put(qc.Id, qc);
			}
		}
 
 
 		if(productRatePlanZuoraIds.size()>0){
			for(zqu__ProductRatePlan__c prp : [Select z.zqu__ZuoraId__c, z.zqu__ZProduct__c, z.zqu__Description__c, 
													z.Quote_Approval_Code__c, z.LegacyProduct__c, 
													z.Id, z.BillingPeriod__c, z.AvailableforQuote__c, z.Account_Type__c 
														From zqu__ProductRatePlan__c z
															where zqu__ZuoraId__c in: productRatePlanZuoraIds]){

				productRatePlanMap.put(prp.zqu__ZuoraId__c, prp); 
				
			}
 		}

 		if(subscriptionRatePlanChargeZuoraIds.size()>0){
			for(Zuora__SubscriptionProductCharge__c spc : [Select z.Zuora__Zuora_Id__c, z.Zuora__Quantity__c, 
													z.Zuora__MonthlyRecurringRevenue__c, 
											 		z.Zuora__External_Id__c, z.Zuora__ExtendedAmount__c, 
											 		z.Zuora__BillingPeriod__c, z.Zuora__Price__c, 
											 		z.List_Price__c, z.Id, z.Box_Discount__c, z.Zuora__Type__c 
											 			From Zuora__SubscriptionProductCharge__c z
															where Zuora__Zuora_Id__c in: subscriptionRatePlanChargeZuoraIds]){

				subscriptionRatePlanChargeMap.put(spc.Zuora__Zuora_Id__c, spc); 
				
			}
 		}
 		
 
 
 		System.debug('>>>>>>>>>productRatePlanMap='+productRatePlanMap);
 
		zqu__QuoteCharge__c currentQuoteCharge;
		zqu__QuoteRatePlanCharge__c currentQuoteRatePlanCharge;
		zqu__QuoteRatePlan__c currentQuoteRatePlan;
		zqu__ProductRatePlan__c currentProductRatePlan;
		Zuora__SubscriptionProductCharge__c currentSubscriptionProductCharge;
		
				
    	// populate fields: Quote, Product Rate Plan  
		for(zqu__QuoteChargeSummary__c qcs : quoteChargeSummaryList){
 
    		currentQuoteCharge=null;
    		currentQuoteRatePlanCharge=null;
    		currentQuoteRatePlan=null; 
    		currentProductRatePlan=null;
			currentSubscriptionProductCharge=null;
    			
    		if(qcs.zqu__Quote_Charge__c!=null){
    			currentQuoteCharge=quoteChargeMap.get(qcs.zqu__Quote_Charge__c);	
    		}	
    		if(qcs.zqu__QuoteRatePlanCharge__c!=null){
    			currentQuoteRatePlanCharge=quoteRatePlanChargeMap.get(qcs.zqu__QuoteRatePlanCharge__c);	
    		}	
    		if(qcs.zqu__QuoteRatePlan__c!=null){
    			currentQuoteRatePlan=quoteRatePlanMap.get(qcs.zqu__QuoteRatePlan__c);	
    		}	

			System.debug('>>>>>>>currentQuoteRatePlan='+currentProductRatePlan);

    		if(currentQuoteRatePlan != null && currentQuoteRatePlan.zqu__ProductRatePlanZuoraId__c!=null){ 

    			currentProductRatePlan = productRatePlanMap.get(currentQuoteRatePlan.zqu__ProductRatePlanZuoraId__c);

    			System.debug('>>>>>>>currentProductRatePlan='+currentProductRatePlan);

    		}
    		
    		if(currentQuoteRatePlanCharge!=null && currentQuoteRatePlanCharge.zqu__SubscriptionRatePlanChargeZuoraId__c!=null){
    			
				currentSubscriptionProductCharge = subscriptionRatePlanChargeMap.get(currentQuoteRatePlanCharge.zqu__SubscriptionRatePlanChargeZuoraId__c);	
    			
    		}
    		 
    		// populate qcs.Product_Rate_Plan__c from quote charge obj
    		if(currentQuoteCharge != null && currentQuoteCharge.Product_Rate_Plan_ID__c != null){
  
     			qcs.Product_Rate_Plan__c = currentQuoteCharge.Product_Rate_Plan_ID__c;

    		}
    		
    		// populate qcs.Product_Rate_Plan__c from quote rate plan charge
    		if(currentQuoteRatePlanCharge != null && currentQuoteRatePlanCharge.Product_Rate_Plan_ID__c != null){
 
    			qcs.Product_Rate_Plan__c = currentQuoteRatePlanCharge.Product_Rate_Plan_ID__c;

    		}

    		// populate qcs.Product_Rate_Plan__c for an amend subscription quote when it's a removed product record
    		if(qcs.Product_Rate_Plan__c == null && currentProductRatePlan != null){
 
    			qcs.Product_Rate_Plan__c = currentProductRatePlan.Id;

    		}
    		  
    		
    		if(currentQuoteRatePlan != null && currentQuoteRatePlan.zqu__Quote__c != null){

    			qcs.quote__c = currentQuoteRatePlan.zqu__Quote__c;

    		}
    		
    		if(currentSubscriptionProductCharge != null){
    			
    			qcs.Subscription_MRR__c 			= currentSubscriptionProductCharge.Zuora__MonthlyRecurringRevenue__c;
				qcs.Subscription_Price__c			= currentSubscriptionProductCharge.Zuora__Price__c;
    			qcs.Subscription_Extended_Amount__c	= currentSubscriptionProductCharge.Zuora__ExtendedAmount__c;
    			qcs.Subscription_Quantity__c		= currentSubscriptionProductCharge.Zuora__Quantity__c;    	
    			qcs.Subscription_Type__c			= currentSubscriptionProductCharge.Zuora__Type__c;    
    			qcs.Subscription_Billing_Period__c  = currentSubscriptionProductCharge.Zuora__BillingPeriod__c; 			
    			   
    		}


    	}//end-for	
    
    	
    }
}