public class ChargeGroupUtility {

    public static Decimal getChargeGroupTotal(zqu.zChargeGroup chargeGroup) {
    	
        Decimal total = 0;
        
        for(zqu.zCharge charge : chargeGroup.zCharges) {
            
            Decimal localTotal = stringToDecimal(charge.Total);
            
            if(localTotal == null) {
                Decimal effectivePrice = stringToDecimal(charge.EFFECTIVE_PRICE);
                Decimal quantity = stringToDecimal(charge.QUANTITY);

                if(effectivePrice == null || quantity == null) {
                    localTotal = 0;
                } else {
                    localTotal = effectivePrice * quantity;
                }
            }

            total += localTotal;
        }

        return total;
    }

    static Decimal stringToDecimal(String s) {
            
            if(s==null || s.length()==0){
            	return 0;	
            }
            
            Decimal d;
            
            try {
                d = Decimal.valueOf(s);
            } catch(TypeException e) {}
            
            return d;
    }

    public static Set<Id> getRelatedProducts(List<zqu.zChargeGroup> chargeGroups) {
        return new Set<Id>(getRelatedProductsList(chargeGroups));
    }

    public static List<Id> getRelatedProductsList(List<zqu.zChargeGroup> chargeGroups) {
        List<Id> productIds = new List<Id>();
        for(zqu__ProductRatePlanCharge__c ratePlanCharge : [
            SELECT zqu__ProductRatePlan__r.zqu__ZProduct__c
            FROM zqu__ProductRatePlanCharge__c
            WHERE Id IN :pluckProductRatePlanChargeIds(filterNewChargeGroups(chargeGroups))
        ]) {
            productIds.add(ratePlanCharge.zqu__ProductRatePlan__r.zqu__ZProduct__c);
        }

        return productIds;
    }

    public static Map<Id, zqu.ZChargeGroup> getRatePlanIdToChargeGroup(List<zqu.zChargeGroup> chargeGroups) {
        Map<Id, zqu__ProductRatePlanCharge__c> ratePlanCharges = new Map<Id, zqu__ProductRatePlanCharge__c>([
           SELECT zqu__ProductRatePlan__c
           FROM zqu__ProductRatePlanCharge__c
           WHERE Id IN :pluckProductRatePlanChargeIds(filterNewChargeGroups(chargeGroups))
        ]);

        Map<Id, zqu.ZChargeGroup> ratePlanIdToChargeGroup = new Map<Id, zqu.ZChargeGroup> ();
        for(zqu.ZChargeGroup chargeGroup : chargeGroups) {
            if(ratePlanCharges.get(chargeGroup.zCharges[0].PRODUCT_RATE_PLAN_CHARGE_SFDC_ID) != null) {
                ratePlanIdToChargeGroup.put(
                    ratePlanCharges.get(chargeGroup.zCharges[0].PRODUCT_RATE_PLAN_CHARGE_SFDC_ID).zqu__ProductRatePlan__c,
                    chargeGroup );
            }
        }

        return ratePlanIdToChargeGroup;
    }

    public static Map<Id, List<zqu.ZChargeGroup>> getProductIdToChargeGroups(List<zqu.zChargeGroup> chargeGroups) {
        return getProductIdToChargeGroups(chargeGroups, false);
    }

    public static Map<Id, List<zqu.ZChargeGroup>> getProductIdToChargeGroups(List<zqu.zChargeGroup> chargeGroups, Boolean includeRemoved) {
        Map<Id, zqu__ProductRatePlanCharge__c> ratePlanCharges = getRatePlanCharges(chargeGroups, includeRemoved);

        Map<Id, List<zqu.ZChargeGroup>> productIdToGroups = new Map<Id, List<zqu.ZChargeGroup>> ();
        for(zqu.ZChargeGroup chargeGroup : chargeGroups) {
            String rateplanChargeId = chargeGroup.zCharges[0].PRODUCT_RATE_PLAN_CHARGE_SFDC_ID;
            zqu__ProductRatePlanCharge__c rateplanCharge = ratePlanCharges.get(rateplanChargeId);

            if(rateplanCharge == null) {
                continue;
            }

            Id productId = ratePlanCharge.zqu__ProductRatePlan__r.zqu__ZProduct__c;
            if(productIdToGroups.get(productId) == null) {
                productIdToGroups.put(productId, new List<zqu.zChargeGroup>());
            }

            productIdToGroups.get(productId).add(chargeGroup);
        }

        return productIdToGroups;
    }

    public static Set<Id> getRelatedRatePlans(List<zqu.zChargeGroup> chargeGroups) {
        return Pluck.ids('zqu__ProductRatePlan__c', [
            SELECT zqu__ProductRatePlan__c
            FROM zqu__ProductRatePlanCharge__c
            WHERE Id IN :pluckProductRatePlanChargeIds(filterNewChargeGroups(chargeGroups))
        ]);
    }

    public static Id getRelatedRatePlan(zqu.zChargeGroup chargeGroup) {
        List<zqu.zChargeGroup> chargeGroups = new List<zqu.zChargeGroup>{chargeGroup};

        List<zqu__ProductRatePlanCharge__c> productRatePlanCharges = [
            SELECT zqu__ProductRatePlan__c
            FROM zqu__ProductRatePlanCharge__c
            WHERE Id IN :pluckProductRatePlanChargeIds(filterNewChargeGroups(chargeGroups))
        ];

        if(productRatePlanCharges.isEmpty()) {
            return null;
        }

        return productRatePlanCharges[0].zqu__ProductRatePlan__c;
    }

    public static Set<Id> getRelatedRatePlanCharges(List<zqu.zChargeGroup> chargeGroups) {
        return pluckProductRatePlanChargeIds(filterNewChargeGroups(chargeGroups));
    }

    public static Set<Id> setDifference(Set<Id> originalSet, Set<Id> idsToRemove) {
        Set<Id> ret = originalSet.clone();

        ret.removeAll(idsToRemove);

        return ret;
    }

    public static Set<Id> setIntersection(Set<Id> originalSet, Set<Id> idsToRetain) {
        Set<Id> ret = originalSet.clone();

        ret.retainAll(idsToRetain);

        return ret;
    }

    public static Set<String> setIntersectionStrings(Set<String> originalSet, Set<String> stringsToRetain) {
        Set<String> ret = originalSet.clone();

        ret.retainAll(stringsToRetain);

        return ret;
    }

    public static Set<String> getProductNamesOnQuote(Id quoteId) {
        Set<String> productNamesOnQuote = new Set<String>();

        for(zqu__QuoteCharge__c quoteCharge : [
            SELECT zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.Name
            FROM zqu__QuoteCharge__c
            WHERE zqu__Quote__c = :quoteId
        ]) {
            productNamesOnQuote.add(quoteCharge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.Name);
        }

        return productNamesOnQuote;
    }

    static Map<Id, zqu__ProductRatePlanCharge__c> getRatePlanCharges(List<zqu.zChargeGroup> chargeGroups, Boolean includeRemoved) {
        Set<Id> ratePlanChargeIds = !includeRemoved ? pluckProductRatePlanChargeIds(filterNewChargeGroups(chargeGroups)) : pluckProductRatePlanChargeIds(chargeGroups);

        return new Map<Id, zqu__ProductRatePlanCharge__c>([
           SELECT zqu__ProductRatePlan__r.zqu__ZProduct__c
           FROM zqu__ProductRatePlanCharge__c
           WHERE Id IN :ratePlanChargeIds
        ]);
    }


    static Set<Id> pluckProductRatePlanChargeIds(List<zqu.zChargeGroup> chargeGroups) {
        Set<Id> ratePlanChargeIds = new Set<Id>();
        for(zqu.zChargeGroup chargeGroup : chargeGroups) {
            ratePlanChargeIds.add(chargeGroup.zCharges[0].PRODUCT_RATE_PLAN_CHARGE_SFDC_ID);
        }

        return ratePlanChargeIds;
    }

    static List<zqu.zChargeGroup> filterNewChargeGroups(List<zqu.zChargeGroup> chargeGroups) {
        List<zqu.zChargeGroup> newChargeGroups = new List<zqu.zChargeGroup>();
        for(zqu.zChargeGroup chargeGroup : chargeGroups) {
            if(chargeGroup.groupType != zqu.zChargeGroup.TYPE_AMENDMENT_REMOVEPRODUCT
            	&& chargeGroup.groupType != zqu.zChargeGroup.TYPE_RENEWAL_REMOVEPRODUCT) {
                newChargeGroups.add(chargeGroup);
            }
        }

        return newChargeGroups;
    }

}