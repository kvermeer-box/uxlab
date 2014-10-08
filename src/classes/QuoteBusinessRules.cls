public with sharing class QuoteBusinessRules {

 	public static final String RATE_PLAN_GROUP_ALLOW_DUPLICATES 		= 'Allow Duplicates';
	
    public static final Decimal PERCENTAGE_OF_BOX_LICENSE_ON_PREMIER_SUPPORT = 0.15;
    
    public static final String BOX_PREMIER_SUPPORT_PRODUCT_SKU = 'SKU-00000038';
    
    public static final Set<String> BOX_LICENSE_PRODUCT_SKUS = new Set<String>
        { 'SKU-00000006' // Elite Licenses
        , 'SKU-00000007' // Enterprise Licenses
        , 'SKU-00000011' // Starter Licenses
        , 'SKU-00000012' // Business Plus Licenses
        , 'SKU-00000028' // Legacy Enterprise Licenses
        , 'SKU-00000034' // Business Licenses
        , 'SKU-00000035' // Legacy Enterprise (Unlimited External) Licenses
        , 'SKU-00000039' // Business (Web) Licenses
        };

	  
    public static final Set<String> cloudConnectProductNames = new Set<String>
        { 'Cloud Connect'
        , 'CloudConnect-IntApp'
        };
    public static final String cloudConnectImplementationRatePlanName = 'Cloud Connect Configuration Package';

    /* only show the cloud connect implementation (rate plan) when a cloud connect (product) is on the quote */
    public static Set<Id> removeCloudConnectImplementation(Set<Id> ratePlanIds, Id quoteId) {
        Set<String> productNamesOnQuote = ChargeGroupUtility.getProductNamesOnQuote(quoteId);

        Set<Id> ret = ratePlanIds.clone();

        Set<String> nameIntersection = ChargeGroupUtility.setIntersectionStrings(cloudConnectProductNames, productNamesOnQuote);
        if(nameIntersection.isEmpty()) {
            Set<Id> cloudConnectImplementationRatePlanIds = Pluck.ids([
                SELECT Id
                FROM zqu__ProductRatePlan__c
                WHERE Name = :cloudConnectImplementationRatePlanName
            ]);

            ret.removeAll(cloudConnectImplementationRatePlanIds);
        }

        return ret;
    }

    public static Set<Id> removeDuplicateRatePlans(Set<Id> ratePlanIds, List<zqu.zChargeGroup> chargeGroups) {

		System.debug('>>>>>>>>>>removeDuplicateRatePlans<<<<<<<<<<<<');
		System.debug('>>>>>>>>>>ratePlanIds='+ratePlanIds);

		/* get a list of rate plan ids which allow duplicates */
    	List<String> ratePlanGroupNames = new List<String>();
    	ratePlanGroupNames.add(RATE_PLAN_GROUP_ALLOW_DUPLICATES); 
    	Z_RatePlanGroup ratePlanGroups = new Z_RatePlanGroup(ratePlanGroupNames);
		
		/* get a list of rate plan ids in the duplicate list */      
		List<Id> allowDuplicateRatePlanIds = ratePlanGroups.includeRatePlans(RATE_PLAN_GROUP_ALLOW_DUPLICATES, ratePlanIds);

        Set<Id> existingRatePlans = ChargeGroupUtility.getRelatedRatePlans(chargeGroups);
 
		System.debug('>>>>>>>>>>existingRatePlans='+existingRatePlans);
 
        Set<Id> filteredList = ChargeGroupUtility.setDifference(ratePlanIds, existingRatePlans);
        
        filteredList.addAll(allowDuplicateRatePlanIds);
        
        return filteredList;
    }
}