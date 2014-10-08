public with sharing class ProductConflictUtility {

    public static Set<Id> removeConflictingRatePlans(Set<Id> ratePlanIds, Id quoteId, List<zqu.zChargeGroup> chargeGroups) {
        Set<Id> existingRatePlans = ChargeGroupUtility.getRelatedRatePlans(chargeGroups);
        Set<Id> conflictingRatePlans = findConflictingRatePlanIds(existingRatePlans, quoteId);

        return ChargeGroupUtility.setDifference(ratePlanIds, conflictingRatePlans);
    }

    public static Set<Id> removeConflictingProducts(Set<Id> productIds, Id quoteId, List<zqu.zChargeGroup> chargeGroups) {
        Set<Id> existingProducts = ChargeGroupUtility.getRelatedProducts(chargeGroups);
        Set<Id> conflictingProducts = findConflictingProductIds(existingProducts, quoteId);

        return ChargeGroupUtility.setDifference(productIds, conflictingProducts);
    }

    static List<Product_Conflict__c> getProductConflicts(Set<Id> productIds) {
        return [
            SELECT Product__c, Incompatible_Product__c, Product__r.Name, Incompatible_Product__r.Name
            FROM Product_Conflict__c
            WHERE Product__c IN :productIds
            OR Incompatible_Product__c IN :productIds
        ];
    }

    static List<Product_Conflict__c> getRatePlanConflicts(Set<Id> ratePlanIds) {
        return [
            SELECT Product_Rate_Plan__c, Incompatible_Product_Rate_Plan__c, Product_Rate_Plan__r.Name, Incompatible_Product_Rate_Plan__r.Name
            FROM Product_Conflict__c
            WHERE Product_Rate_Plan__c IN :ratePlanIds
            OR Incompatible_Product_Rate_Plan__c IN :ratePlanIds
        ];
    }

    @TestVisible static Set<Id> findConflictingProductIds(Set<Id> productIds, Id quoteId) {
        Set<Id> conflictingProducts = new Set<Id>();
        List<Product_Conflict__c> conflicts = getProductConflicts(productIds);

        for(Id existingProductId : productIds) {
            for(Product_Conflict__c conflict : conflicts) {
                if(conflict.Product__c == existingProductId && conflict.Product__c != null) {
                    conflictingProducts.add(conflict.Incompatible_Product__c);
                } else if(conflict.Incompatible_Product__c == existingProductId && conflict.Incompatible_Product__c != null) {
                    conflictingProducts.add(conflict.Product__c);
                }
            }
        }

        return conflictingProducts;
    }

    @TestVisible static Set<Id> findConflictingRatePlanIds(Set<Id> ratePlanIds, Id quoteId) {
        Set<Id> conflictingRatePlanIds = new Set<Id>();
        List<Product_Conflict__c> conflicts = getRatePlanConflicts(ratePlanIds);

        for(Id ratePlanId : ratePlanIds) {
            for(Product_Conflict__c conflict : conflicts) {
                if(conflict.Product_Rate_Plan__c == ratePlanId && conflict.Product_Rate_Plan__c != null) {
                    conflictingRatePlanIds.add(conflict.Incompatible_Product_Rate_Plan__c);
                } else if(conflict.Incompatible_Product_Rate_Plan__c == ratePlanId && conflict.Incompatible_Product_Rate_Plan__c != null) {
                    conflictingRatePlanIds.add(conflict.Product_Rate_Plan__c);
                }
            }
        }

        return conflictingRatePlanIds;
    }
}