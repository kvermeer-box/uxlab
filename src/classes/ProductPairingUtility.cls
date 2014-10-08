public with sharing class ProductPairingUtility {
  
    public static void AddChargeGroup(zqu.ZChargeGroup newChargeGroup, List<zqu.ZChargeGroup> allChargeGroups, zqu__Quote__c quote) {
        Id newRatePlanId = ChargeGroupUtility.getRelatedRatePlan(newChargeGroup);
        Decimal newChargeGroupTotal = ChargeGroupUtility.getChargeGroupTotal(newChargeGroup);

        Set<Id> relatedRatePlanIds = getRelatedRatePlanIds(allChargeGroups, newRatePlanId);

        List<Product_Pairing__c> companions = getRelatedPairings(newRatePlanId);
		String quoteCurrencyCode = quote.zqu__Currency__c;
        List<zqu.zChargeGroup> chargeGroupsToInsert = new List<zqu.zChargeGroup>();
        for(Product_Pairing__c companion : companions) {
            if(isSatisfied(companion, newChargeGroupTotal,quoteCurrencyCode)
                && !alreadyAdded(relatedRatePlanIds, companion.Product_Rate_Plan_To_Add__c) ){

                zqu.ZChargeGroup chargeGroup = zqu.zQuoteUtil.getChargeGroups(quote.Id, new List<Id>{companion.Product_Rate_Plan_To_Add__c})[0];
                chargeGroupsToInsert.add(chargeGroup);
            }
        }

        for(zqu.zChargeGroup chargeGroup : chargeGroupsToInsert) {
            for(zqu.zCharge charge : chargeGroup.zCharges) {
                charge.DISCOUNT = '0';
                charge.QUANTITY = '1';
            }
        }

        if(!chargeGroupsToInsert.isEmpty()) {
            zqu.zQuoteUtil.addChargeGroups(chargeGroupsToInsert);
        }
    }

    public static void DeleteChargeGroup(zqu.ZChargeGroup removedChargeGroup, List<zqu.ZChargeGroup> allChargeGroups, zqu__Quote__c quote) {
        Id removedRatePlanId = ChargeGroupUtility.getRelatedRatePlan(removedChargeGroup);
        Set<Id> relatedRatePlanIds = getRelatedRatePlanIds(allChargeGroups, removedRatePlanId);

        List<Product_Pairing__c> companions = getRelatedPairings(removedRatePlanId);
        Map<Id, zqu.ZChargeGroup> ratePlanIdToChargeGroup = ChargeGroupUtility.getRatePlanIdToChargeGroup(allChargeGroups);

        for(Product_Pairing__c companion : companions) {
            if(!alreadyRemoved(relatedRatePlanIds, companion.Product_Rate_Plan_To_Add__c)
                && noOtherSatisfactoryParents(relatedRatePlanIds, companion.Product_Rate_Plan__c) ){

                zqu.ZChargeGroup chargeGroupToDelete = ratePlanIdToChargeGroup.get(companion.Product_Rate_Plan_To_Add__c);

                if(chargeGroupToDelete != null) {
                    zqu.zQuoteUtil.deleteChargeGroup(chargeGroupToDelete);
                }
            }
        }
    }

    public static void EditChargeGroup(zqu.ZChargeGroup editingChargeGroup, List<zqu.ZChargeGroup> allChargeGroups, zqu__Quote__c quote) {
        
        AddChargeGroup(editingChargeGroup, allChargeGroups, quote);

        Id editedRatePlanId = ChargeGroupUtility.getRelatedRatePlan(editingChargeGroup);
        Decimal editedChargeGroupTotal = ChargeGroupUtility.getChargeGroupTotal(editingChargeGroup);
        String quoteCurrencyCode = quote.zqu__Currency__c;

        Set<Id> relatedRatePlanIds = getRelatedRatePlanIds(allChargeGroups, editedRatePlanId);

        List<Product_Pairing__c> companions = getRelatedPairings(editedRatePlanId);

        Map<Id, zqu.ZChargeGroup> ratePlanIdToChargeGroup = ChargeGroupUtility.getRatePlanIdToChargeGroup(allChargeGroups);
        
        for(Product_Pairing__c companion : companions) {
        	
            if(!isSatisfied(companion, editedChargeGroupTotal, quoteCurrencyCode)
                && !alreadyRemoved(relatedRatePlanIds, companion.Product_Rate_Plan_To_Add__c)
                && noOtherSatisfactoryParents(relatedRatePlanIds, companion.Product_Rate_Plan__c) ){

                zqu.ZChargeGroup chargeGroupToDelete = ratePlanIdToChargeGroup.get(companion.Product_Rate_Plan_To_Add__c);
                if(chargeGroupToDelete != null) {
                    zqu.zQuoteUtil.deleteChargeGroup(chargeGroupToDelete);
                }
            }
        }
    }

    public static Set<Id> getRelatedRatePlanIds(List<zqu.ZChargeGroup> allChargeGroups, Id newRatePlanId) {
        Set<Id> allRatePlanIds = ChargeGroupUtility.getRelatedRatePlans(allChargeGroups);

        return ChargeGroupUtility.setDifference(allRatePlanIds, new Set<Id> { newRatePlanId });
    }

    static List<Product_Pairing__c> getRelatedPairings(Id ratePlanId) {
        return [
           SELECT Product_Rate_Plan__c, Minimum_Total__c, Maximum_Total__c, Product_Rate_Plan_To_Add__c, CurrencyIsoCode
           FROM Product_Pairing__c
           WHERE Product_Rate_Plan__c = :ratePlanId
           	LIMIT 2000
        ];
    }

    static Boolean isSatisfied(Product_Pairing__c companion, Decimal total, String totalCurrencyCode) {
    	
    	Decimal companionMinimum;
    	Decimal companionMaximum;
    	Decimal compareTotal;
    	
    	//check currency code
    	if(companion.CurrencyIsoCode==totalCurrencyCode){
			// same currency code
    		companionMinimum	= companion.Minimum_Total__c;	
    		companionMaximum	= companion.Maximum_Total__c;
    		compareTotal		= total;    	
    	}else{	
    		//convert everything to USD
    		companionMinimum	= CurrencyUtils.convertAmountToUSD(companion.Minimum_Total__c,companion.CurrencyIsoCode);	
    		companionMaximum	= CurrencyUtils.convertAmountToUSD(companion.Maximum_Total__c,companion.CurrencyIsoCode);
    		compareTotal		= CurrencyUtils.convertAmountToUSD(total,totalCurrencyCode);  
    	}
    	
        //return withinRange(companion.Minimum_Total__c, companion.Maximum_Total__c, total);
        return withinRange(companionMinimum, companionMaximum, compareTotal);
    }

    static Boolean withinRange(Decimal minimum, Decimal maximum, Decimal x) {
        return minimum < x && x <= maximum;
    }

    static Boolean alreadyAdded(Set<Id> relatedRatePlanCharges, Id ratePlanToAdd) {
        return ratePlanFound(relatedRatePlanCharges, ratePlanToAdd);
    }

    static Boolean alreadyRemoved(Set<Id> relatedRatePlanCharges, Id ratePlanToRemove) {
        return !ratePlanFound(relatedRatePlanCharges, ratePlanToRemove);
    }

    static Boolean noOtherSatisfactoryParents(Set<Id> relatedRatePlanCharges, Id parentRatePlan) {
        return !ratePlanFound(relatedRatePlanCharges, parentRatePlan);
    }

    static Boolean ratePlanFound(Set<Id> relatedRatePlanCharges, Id ratePlanToFind) {
        return relatedRatePlanCharges.contains(ratePlanToFind);
    }
}