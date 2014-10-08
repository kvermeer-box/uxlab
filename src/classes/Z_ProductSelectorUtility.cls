public class Z_ProductSelectorUtility {

    public static string PAYMENT_FREQUENCY_ONE_TIME = 'One-Time';

	public static final String PRODUCT_GROUP_IMPLEMENTATION = 'Implementation';
	public static final String PRODUCT_GROUP_INTEGRATIONS 	= 'Integrations';

	public static final integer INTEGRATIONS_QUICK_START 	= 1;
	public static final integer INTEGRATIONS_SMART_START	= 3;

    /* return only non-legacy products available for quote */
    public static Set < Id >getFilteredZProductIds(Set<Id> productIds, Id quoteId, List<zqu.zChargeGroup> chargeGroups){

        Set < Id > newProductIds = new Set < Id > ();

        if(productIds==null || productIds.size()==0){
            return newProductIds;
        }

        for(zqu__ZProduct__c zProduct : [Select z.zqu__SKU__c, z.zqu__Description__c, z.zqu__Currency__c,
                                                z.Name, z.LegacyProduct__c, z.Id, z.AvailableforQuote__c
                                            From zqu__ZProduct__c z
                                                Where z.AvailableforQuote__c = 'Yes'
                                                    and z.LegacyProduct__c = 'No'
                                                    and z.Id in: productIds]){

            newProductIds.add(zProduct.Id);

        }//end-for

		System.debug('>>>>>>before removeIntegrationProducts newProductIds='+newProductIds);
		System.debug('>>>>>>before removeIntegrationProducts newProductIds.size()='+newProductIds.size());
		removeIntegrationProducts(newProductIds, quoteId, chargeGroups);
		System.debug('>>>>>>after removeIntegrationProducts  newProductIds='+newProductIds);
		System.debug('>>>>>>after removeIntegrationProducts  newProductIds.size()='+newProductIds.size());
		
        return newProductIds;
    }

	/* remove integration product ids if implementation id is not present */
	public static void removeIntegrationProducts(Set<Id> productIds, Id quoteId, List<zqu.zChargeGroup> chargeGroups){
	
		List<Id> existingProducts = ChargeGroupUtility.getRelatedProductsList(chargeGroups);	
		Set<Id> existingRatePlans = ChargeGroupUtility.getRelatedRatePlans(chargeGroups);

    	List<String> productGroupNames = new List<String>();
    	productGroupNames.add(PRODUCT_GROUP_IMPLEMENTATION);
    	productGroupNames.add(PRODUCT_GROUP_INTEGRATIONS);  
    	Z_ProductGroup productGroups = new Z_ProductGroup(productGroupNames);

		// check if there's an implementation product.
		// if there's no implementation product, then remove integration product
		
		integer integrationProductCount=0;
		
		if(!productGroups.containsProduct(PRODUCT_GROUP_IMPLEMENTATION, existingProducts)){
			removeProductIds(productIds, productGroups.getMemberIds(PRODUCT_GROUP_INTEGRATIONS));
		}	
		else{
			
			integrationProductCount=productGroups.countProduct(PRODUCT_GROUP_INTEGRATIONS, existingProducts);
			
			// check if there's Quick Start Rate Plan (implementation product)
			// check if there is 1 integration.  display integration product if no integration product
			//
			// check if there's Smart Start  (implementation product
			// check if there are 3 integrations.  display integration product if fewer than 3
			
			
		}
		 

	
		return;
	}

	public static void removeProductIds(Set<Id> productIds, Set<Id>removeProductIds){
	
		if(productIds==null || removeProductIds==null){
			return;
		}
		
		productIds.removeAll(removeProductIds);
 
		return;
	}

    /* return only non-legacy rate plans available for quote */
    public static List < Id > getFilteredRatePlanIds(List < ID > ratePlanIds, Id zProductId, Id quoteId){
        List < ID > newRatePlanIds = new List < ID > ();
        Map<Id, zqu__ProductRatePlan__c> ratePlanMap = new Map<Id, zqu__ProductRatePlan__c> ();

        if(ratePlanIds==null || ratePlanIds.size()==0){
            return newRatePlanIds;
        }

        for(zqu__ProductRatePlan__c prp :	[Select z.zqu__ZProduct__c, z.zqu__Description__c,
                        z.LegacyProduct__c, z.Id,
                        z.BillingPeriod__c, z.AvailableforQuote__c
                    From zqu__ProductRatePlan__c z
                        Where z.Id in: ratePlanIds
                            and z.AvailableforQuote__c = 'Yes'
                            and z.LegacyProduct__c = 'No']){

            newRatePlanIds.add(prp.Id);
            ratePlanMap.put(prp.Id, prp);

        }//end-for

        zqu__Quote__c zQuote = getQuote(quoteId);

        if(zQuote!=null && zQuote.Payment_Frequency__c!=null){
             newRatePlanIds=filterRatePlanIdsByPaymentFrequency(newRatePlanIds, ratePlanMap, zQuote.Payment_Frequency__c);
        }
        return newRatePlanIds;
    }

    public static List < Id > filterRatePlanIdsByPaymentFrequency(List < ID > ratePlanIds,
                                                                    Map<Id, zqu__ProductRatePlan__c> ratePlanMap,
                                                                    String paymentFrequency){
        System.debug('>>>>>>>>>>BEFORE ratePlanIds='+ratePlanIds);
        List < ID > newRatePlanIds = new List < ID > ();

        if(ratePlanIds==null){
            return newRatePlanIds;
        }else if(ratePlanMap==null || paymentFrequency==null){
            return ratePlanIds;
        }


        zqu__ProductRatePlan__c ratePlan;

        for(Id ratePlanId: ratePlanIds){

            ratePlan=ratePlanMap.get(ratePlanId);
            if(ratePlan.BillingPeriod__c==null
                || ratePlan.BillingPeriod__c==PAYMENT_FREQUENCY_ONE_TIME
                || ratePlan.BillingPeriod__c==paymentFrequency){

                newRatePlanIds.add(ratePlanId);
            }//end-if

        }
        System.debug('>>>>>>>>>>AFTER ratePlanIds='+ratePlanIds);
        return newRatePlanIds;

    }

    /* use quote id to return a quote */
    public static zqu__Quote__c getQuote(Id quoteId){

        if(quoteId==null){
            return null;
        }

        for(zqu__Quote__c q : [Select z.Payment_Frequency__c, z.Id
                                    From zqu__Quote__c z
                                        Where z.Id =: quoteId]){

            return q;

        }//end-for

        return null;

    }

}