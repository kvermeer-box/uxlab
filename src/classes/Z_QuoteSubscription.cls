public class Z_QuoteSubscription {

	private String subscriptionId;
	private Zuora__Subscription__c subscription;
 
	public Z_QuoteSubscription (String existingSubscriptionId) {
	 
	 	if(existingSubscriptionId!=null) {
	 		
			subscriptionId = existingSubscriptionId;	
	
			for(Zuora__Subscription__c s : [Select z.Zuora__Zuora_Id__c, z.Id, 
						(Select Zuora__BillingPeriod__c, Zuora__ExtendedAmount__c, 
								Zuora__Model__c, Zuora__Price__c, Zuora__Quantity__c, 
								Zuora__Type__c, Zuora__Zuora_Id__c, Zuora__External_Id__c, 
								Status__c, List_Price__c, Upsell_Price__c, Upsell_Quantity__c 
									From Zuora__Subscription_Product_Charges__r 
										Where Status__c = 'Active' and Zuora__Type__c = 'Recurring') 
							From Zuora__Subscription__c z 
								where Zuora__Zuora_Id__c =: subscriptionId ]){
						
				subscription = s;
								
			}//end-for
	 	}
		
	}

	public static double getPaymentFrequencyFactor(String paymentFrequency){
 	
		if(paymentFrequency == 'Annual'){
			
			return 1;
		
		}else if(paymentFrequency == 'Month'){
			
			return 12;
		 
		}else if(paymentFrequency == 'Quarter'){
		
			return 4;
			
		}else if(paymentFrequency == 'Semi-Annual'){
		
			return 2;
			
		}else if(paymentFrequency == 'Two Years'){
		
			return 0.5;
			
		}else if(paymentFrequency == 'Three Years'){
		
			return 1/3;
			
		}else if(paymentFrequency == 'Five Years'){
		
			return 0.2;
			
		}else if(paymentFrequency == 'Four Years'){
		
			return 0.25;
		}
		
		return 1;
	}

	public double getARR(){
	
		Double arr=0;	

		if(subscription!= null && subscription.Zuora__Subscription_Product_Charges__r!=null){
			
			for (Zuora__SubscriptionProductCharge__c spc : subscription.Zuora__Subscription_Product_Charges__r){
				
				arr = arr + (spc.Zuora__ExtendedAmount__c * getPaymentFrequencyFactor(spc.Zuora__BillingPeriod__c));	 			
				
			}
		}
		
		
		return arr;
	}

	public double getQuantity(){
		
		double quantity=0;
 
		
		if(subscription!= null && subscription.Zuora__Subscription_Product_Charges__r!=null){
			
			for (Zuora__SubscriptionProductCharge__c spc : subscription.Zuora__Subscription_Product_Charges__r){
				
				quantity = quantity + spc.Zuora__Quantity__c;		
				
			}
		}
		
		return quantity;	
		
	}
	
	public double getExtendedAmount(){
		
		double extendedAmount=0;
 
		
		if(subscription!= null && subscription.Zuora__Subscription_Product_Charges__r!=null){
			
			for (Zuora__SubscriptionProductCharge__c spc : subscription.Zuora__Subscription_Product_Charges__r){
				
				extendedAmount = extendedAmount + spc.Zuora__ExtendedAmount__c;		
				
			}
		}
		
		return extendedAmount;	
		
	}

	public String getBillingPeriod(){
		
		String billingPeriod;
 
		
		if(subscription!= null && subscription.Zuora__Subscription_Product_Charges__r!=null){
			
			for (Zuora__SubscriptionProductCharge__c spc : subscription.Zuora__Subscription_Product_Charges__r){
				
				if(spc.Zuora__BillingPeriod__c!=null){
					billingPeriod = spc.Zuora__BillingPeriod__c;
					break;	
				}	
				
			}
		}
		
		return billingPeriod;	
	}

}