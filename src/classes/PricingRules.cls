public with sharing class PricingRules {

    private static final String BOX_LICENSE_PRODUCT_GROUP_NAME = 'Licensed Products';

    public static List<Pricing_Rule__c> checkPricingRules(List<zqu.zChargeGroup> existingGroups, String selProductId) {
        Set<Id> productsOnQuote = getProductsOnQuote(existingGroups);

        if(productsOnQuote.isEmpty()) {
            return new List<Pricing_Rule__c>();
        }

        return [
            SELECT Auto_Set_Product__c, Percent__c, Product__c
            FROM Pricing_Rule__c
            WHERE Auto_Set_Product__c = :selProductId
            AND Product__c IN :productsOnQuote
        ];
    }

    public static List<Pricing_Rule__c> getPricingRulesRelatedToProducts(Set<Id> productIds) {
        if(productIds.isEmpty()) {
            return new List<Pricing_Rule__c>();
        }

        return [
            SELECT Auto_Set_Product__c, Percent__c, Product__c
            FROM Pricing_Rule__c
            WHERE Auto_Set_Product__c IN :productIds
        ];
    }

    public static zqu.ZChargeGroup getChargeGroup(List<zqu.zChargeGroup> existingGroups, Pricing_Rule__c pricingRule, Id quoteId, String selRatePlanId) {
        zqu.ZChargeGroup chargeGroup = zqu.ZQuoteUtil.getChargeGroups(quoteId, new List<Id>{selRatePlanId})[0];

        Decimal effectivePrice = getTotalofParentProduct(existingGroups, pricingRule.Product__c);

        for(zqu.zCharge charge : chargeGroup.zCharges) {
            charge.EFFECTIVE_PRICE = getPercentofProductPrice(effectivePrice, pricingRule.Percent__c);
        }

        chargeGroup.zCharges = zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(chargeGroup.zCharges);

        return chargeGroup;
    }

    public static void updatePercentProduct(List<zqu.ZChargeGroup> percentProductCharges, List<zqu.zChargeGroup> existingGroups) {
        Map<String, String> chargeGroupIdToTotal = new Map<String, String>();

        // workaround to refresh charge groups
        //percentProductCharges = zqu.zQuoteUtil.getChargeGroups(percentProductCharges[0].quote.Id, new List<Id>(ChargeGroupUtility.getRelatedRatePlans(percentProductCharges)));

        Map<Id, List<zqu.zChargeGroup>> percentProductIdToCharge = ChargeGroupUtility.getProductIdToChargeGroups(percentProductCharges);
        Set<Id> productIds = getProductsOnQuote(existingGroups);

        List<Pricing_Rule__c> pricingRules = getPricingRulesRelatedToProducts(productIds);
        if(pricingRules.isEmpty()) { return; }

        Map<Id, Pricing_Rule__c> productIdToRule = getProductIdToRuleMap(pricingRules, productIds);
        if(productIdToRule.isEmpty()) { return; }

        List<zqu.zChargeGroup> toUpdate = new List<zqu.zChargeGroup>();

        for(Id percentProductId : percentProductIdToCharge.keySet()) {
            Pricing_Rule__c productRule = productIdToRule.get(percentProductId);
            zqu.ZChargeGroup chargeGroup = percentProductIdToCharge.get(percentProductId)[0];

            Decimal total = getTotalofParentProduct(existingGroups, productRule.Product__c);
            String newEffectivePrice = getPercentofProductPrice(total, productRule.Percent__c);
            for(zqu.zCharge charge : chargeGroup.zCharges) {
                charge.chargeObject.put('List_Price__c', Decimal.valueOf(newEffectivePrice));

                Decimal discount = (Decimal) charge.chargeObject.get('Box_Discount__c');
                Decimal price = Decimal.valueOf(newEffectivePrice);

                discount = discount == null ? 0 : discount/100;
                price = price - (price * discount);

                charge.EFFECTIVE_PRICE = String.valueOf(price);
            }

            chargeGroup.zCharges = zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(chargeGroup.zCharges);
            toUpdate.add(chargeGroup);
        }
        if(!toUpdate.isEmpty()) {
            zqu.ZQuoteUtil.updateChargeGroups(toUpdate);
        }
    }

    public static void updateTotalWithCustomDiscount(zqu.ZChargeGroup chargeGroup) {
        for(zqu.zCharge charge : chargeGroup.zCharges) {
            charge.EFFECTIVE_PRICE = calculateNewEffectivePrice(charge);
        }

        chargeGroup.zCharges = zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(chargeGroup.zCharges);
    }

    public static Map<zqu.zCharge, Zuora__SubscriptionProductCharge__c> getRelatedSubscriptionCharge(zqu.zChargeGroup chargeGroup) {
        Set<Id> percentProductIds = getProductsOnQuote(new List<zqu.zChargeGroup > { chargeGroup });
        Map<zqu.zCharge, String> chargeToSubscriptionId = getChargeToSubscriptionId(new List<zqu.zChargeGroup > { chargeGroup }, percentProductIds);

        List<Zuora__SubscriptionProductCharge__c> subscriptionCharges = [
            SELECT Zuora__External_Id__c, Zuora__Zuora_Id__c, Box_Discount__c, List_Price__c
            FROM Zuora__SubscriptionProductCharge__c
            WHERE Zuora__External_Id__c IN :chargeToSubscriptionId.values()
            OR Zuora__Zuora_Id__c IN :chargeToSubscriptionId.values()
        ];

        Map<zqu.zCharge, Zuora__SubscriptionProductCharge__c> chargeToSubscriptionCharge = new Map<zqu.zCharge, Zuora__SubscriptionProductCharge__c>();
        for(zqu.zCharge charge : chargeGroup.zCharges) {
            Zuora__SubscriptionProductCharge__c subscriptionProductCharge = getSubscriptionProductCharge(subscriptionCharges, chargeToSubscriptionId.get(charge));
            if(subscriptionProductCharge != null) {
                chargeToSubscriptionCharge.put(charge, subscriptionProductCharge);
            }
        }

        return chargeToSubscriptionCharge;
    }

    public static void populateCustomPercentProductFields(List<zqu.zChargeGroup> chargeGroups) {
        Set<Id> productIds = getProductsOnQuote(chargeGroups);

        List<Pricing_Rule__c> pricingRule = getPricingRulesRelatedToProducts(productIds);
        if(pricingRule.isEmpty()) { return; }

        Set<Id> percentProductIds = Pluck.ids('Auto_Set_Product__c', pricingRule);
        Map<zqu.zCharge, String> chargeToSubscriptionId = getChargeToSubscriptionId(chargeGroups, percentProductIds);

        List<Zuora__SubscriptionProductCharge__c> subscriptionCharges = [
            SELECT Zuora__External_Id__c, Zuora__Zuora_Id__c, Box_Discount__c, List_Price__c
            FROM Zuora__SubscriptionProductCharge__c
            WHERE Zuora__External_Id__c IN :chargeToSubscriptionId.values()
            OR Zuora__Zuora_Id__c IN :chargeToSubscriptionId.values()
        ];

        Map<String, zqu.zChargeGroup> toUpdate = new Map<String, zqu.zChargeGroup>();
        for(zqu.zChargeGroup chargeGroup : chargeGroups) {
            for(zqu.zCharge charge : chargeGroup.zCharges) {
                Zuora__SubscriptionProductCharge__c subscriptionProductCharge = getSubscriptionProductCharge(subscriptionCharges, chargeToSubscriptionId.get(charge));
                if(subscriptionProductCharge != null) {
                    setPriceAndDiscount(charge, subscriptionProductCharge);
                    toUpdate.put(chargeGroup.groupId, chargeGroup);
                }
            }
        }

        if(!toUpdate.isEmpty()) {
            zqu.ZQuoteUtil.updateChargeGroups(new List<zqu.zChargeGroup>(toUpdate.values()));
        }
    }

    @TestVisible static Set<Id> getProductsOnQuote(List<zqu.zChargeGroup> existingGroups) {
        Map<Id, List<zqu.zChargeGroup>> productToChargeGroups = ChargeGroupUtility.getProductIdToChargeGroups(existingGroups);

        return productToChargeGroups.keySet();
    }

    static Map<Id, Pricing_Rule__c> getProductIdToRuleMap(List<Pricing_Rule__c> pricingRules, Set<Id> productIds) {
        Map<Id, Pricing_Rule__c> productIdToRule = new Map<Id, Pricing_Rule__c>();

        for(Pricing_Rule__c rule : pricingRules) {
            if(productIds.contains(rule.Product__c) && productIds.contains(rule.Auto_Set_Product__c)) {
                productIdToRule.put(rule.Auto_Set_Product__c, rule);
            }
        }

        return productIdToRule;
    }

    @TestVisible static Decimal getTotalofParentProduct(List<zqu.zChargeGroup> existingGroups, Id productId) {
        Map<Id, List<zqu.zChargeGroup>> productToChargeGroups = ChargeGroupUtility.getProductIdToChargeGroups(existingGroups);

        List<zqu.zChargeGroup> relatedGroups = productToChargeGroups.get(productId);

        return ChargeGroupUtility.getChargeGroupTotal(relatedGroups[0]);
    }

    static String getPercentofProductPrice(Decimal price, Decimal percent) {
        return String.valueOf(price * (percent/100));
    }

    static String calculateNewEffectivePrice(zqu.zCharge charge) {
        Decimal discount = (Decimal) charge.chargeObject.get('Box_Discount__c');
        discount = discount == null ? 0 : discount/100;
        Decimal listPrice = (Decimal) charge.chargeObject.get('List_Price__c');
        listPrice = listPrice == null ? 0 : (listPrice - (listPrice * discount)).setScale(2);
        return String.valueOf(listPrice);
    }

    static Map<zqu.zCharge, String> getChargeToSubscriptionId(List<zqu.zChargeGroup> chageGroups, Set<Id> productIds) {
        List<zqu__ZProduct__c> products = [
           SELECT Name
           FROM zqu__ZProduct__c
           WHERE Id IN :productIds
        ];
        Set<String> productNames = new Set<String>();
        for(zqu__ZProduct__c product : products) {
            productNames.add(product.Name);
        }

        Map<zqu.zCharge, String> chargeToSubscriptionId = new Map<zqu.zCharge, String>();
        Map<String, zqu.zCharge> quoteRatePlanZuoraIdToCharge = new Map<String, zqu.zCharge>();

        for(zqu.zChargeGroup chargeGroup : chageGroups) {
            if(productNames.contains(chargeGroup.productName)) {
                for(zqu.zCharge charge : chargeGroup.zCharges) {
                    String zuoraId = charge.getQuoteRatePlanChargeZuoraId();
                    if(zuoraId != null) {
                        chargeToSubscriptionId.put(charge, zuoraId);
                    }
                }
            }
        }

        return chargeToSubscriptionId;
    }

    static zqu.zCharge setPriceAndDiscount(zqu.zCharge charge, Zuora__SubscriptionProductCharge__c subscriptionProductCharge) {
        Decimal listPrice = (subscriptionProductCharge.List_Price__c != null) ? Decimal.valueOf(subscriptionProductCharge.List_Price__c)
                                                                              : Decimal.valueOf(0);
        Decimal boxDiscount = (subscriptionProductCharge.Box_Discount__c != null) ? Decimal.valueOf(subscriptionProductCharge.Box_Discount__c)
                                                                                  : Decimal.valueOf(0);
        charge.chargeObject.put('List_Price__c', listPrice); 
        charge.chargeObject.put('Box_Discount__c', boxDiscount);

        return charge;
    }

    static Zuora__SubscriptionProductCharge__c getSubscriptionProductCharge(List<Zuora__SubscriptionProductCharge__c> subscriptionCharges, String zuoraId) {
        for(Zuora__SubscriptionProductCharge__c subscriptionCharge : subscriptionCharges) {
            if(subscriptionCharge.Zuora__Zuora_Id__c == zuoraId || subscriptionCharge.Zuora__External_Id__c == zuoraId) {
                return subscriptionCharge;
            }
        }

        return null;
    }

    /**
     * Returns a set of all license products
     *
     * @return {Set<Id>} - set of ids for all license products (NOT RATE PLANS)
     */
    public static Set<Id> getLicenseProductsIds() {
        try { // Query for Product_Group_Members to find all products in the Box License group
            /*
            List<Product_Group_Member__c> licenseProductGroupMembers1 = [SELECT Id, Product__r.Name, Name
                                                                           FROM Product_Group_Member__c];
            for (Product_Group_Member__c curGroupMember : licenseProductGroupMembers1) {
                System.debug('Group Member Name: ' + curGroupMember.Product__r.Name);
            }
            */
            //System.debug('License product group: ' + licenseProductGroupMembers1);
            List<Product_Group_Member__c> licenseProductGroupMembers = [SELECT Id, Product__c
                                                                          FROM Product_Group_Member__c
                                                                         WHERE Product_Group__r.Name = :BOX_LICENSE_PRODUCT_GROUP_NAME];
            Set<Id> licenseProductIds = new Set<Id>();
            for (Product_Group_Member__c currentGroupMember : licenseProductGroupMembers) {
                licenseProductIds.add(currentGroupMember.Product__c);
            }
            return licenseProductIds;
        }
        catch (Exception e) {
            new LoggedException(e,'Issues querying for the License Product Group', 'PricingRules');
            return new Set<Id>();
        }
    }
}