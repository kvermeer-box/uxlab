public class Z_QuoteRatePlanChargeTriggerHelper {
	
	
    public static void beforeInsert(List<zqu__QuoteRatePlanCharge__c> quoteRatePlanChargeList) {
 
		updateFields(quoteRatePlanChargeList);	 
		
    }
 
    public static void beforeUpdate(List<zqu__QuoteRatePlanCharge__c> quoteRatePlanChargeList,
                                    Map<Id,zqu__QuoteRatePlanCharge__c> oldQuoteRatePlanChargeMap) {

	 
		updateFields(quoteRatePlanChargeList);	 

    }

    public static void updateFields(List<zqu__QuoteRatePlanCharge__c> quoteRatePlanChargeList) {

		Set<String> productRatePlanChargeZuoraIds = new Set<String>();
		Map<String, zqu__ProductRatePlanCharge__c> productRatePlanChargeMap = new Map<String, zqu__ProductRatePlanCharge__c> ();
		for(zqu__QuoteRatePlanCharge__c qrpc : quoteRatePlanChargeList){
		
			if(qrpc.zqu__ProductRatePlanChargeZuoraId__c!=null){
				productRatePlanChargeZuoraIds.add(qrpc.zqu__ProductRatePlanChargeZuoraId__c);	
			}	
			
		}//end-for
		
		if (productRatePlanChargeZuoraIds.size()>0){
		
			for(zqu__ProductRatePlanCharge__c prpc : [Select z.zqu__ZuoraId__c, z.zqu__ProductRatePlan__c, 
																	z.Quote_Name__c, z.Id 
																From zqu__ProductRatePlanCharge__c z
																	Where zqu__ZuoraId__c in: productRatePlanChargeZuoraIds]){
			
				
				productRatePlanChargeMap.put(prpc.zqu__ZuoraId__c, prpc);
								
			}//end-for		
			
		}
		
		for(zqu__QuoteRatePlanCharge__c qrpc : quoteRatePlanChargeList){
		
			if(qrpc.zqu__ProductRatePlanChargeZuoraId__c!=null 
				&& productRatePlanChargeMap.containsKey(qrpc.zqu__ProductRatePlanChargeZuoraId__c)){
					
				qrpc.Rate_Plan_Charge__c = productRatePlanChargeMap.get(qrpc.zqu__ProductRatePlanChargeZuoraId__c).Id; 		
				 	
			}	
			
		}//end-for
 

    }


}