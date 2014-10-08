public with sharing class ProductLimitationsUtility {

    public static Set<Id> removeProductsExceedingLimit(Set<Id> productIds, Id quoteId, List<zqu.zChargeGroup> chargeGroups) {
        Set<Id> productsExceedingLimit = getProductsExceedingLimit(quoteId, chargeGroups);

        return ChargeGroupUtility.setDifference(productIds, productsExceedingLimit);
    }

    @TestVisible class QuoteLimit {
        public List<Product_Rule__c> rules;
        public List<Product_Group__c> groups;
        public List<Id> existingProducts;
        public Set<Id> existingRatePlans;
        public Set<Id> productsToCheck;

        public QuoteLimit(List<Product_Rule__c> rules, List<Product_Group__c> groups, List<Id> existingProducts, Set<Id> existingRatePlans, Set<Id> productsToCheck) {
            this.rules = rules;
            this.groups = groups;
            this.existingProducts = existingProducts;
            this.existingRatePlans = existingRatePlans;
            this.productsToCheck = productsToCheck;
        }

        public Map<Id, String> productToError {
            get {
                if(productToError == null) {
                    productToError = createErrors();
                }
                return productToError;
            }

            private set;
        }

        public Boolean isSatisfied {
            get {
                if(isSatisfied == null) {
                    isSatisfied = productToError.isEmpty();
                }

                return isSatisfied;
            }

            private set;
        }

        public String errorMessage {
            get {
                if(errorMessage == null) {
                    errorMessage = String.join(productToError.values(), '\n');
                }

                return errorMessage;
            }

            private set;
        }

        Map<Id, String> createErrors() {
            Map<Id, String> errors = new Map<Id, String>();
            Map<Id, Integer> numberofProductsInGroups = getNumberofProductsInGroups();

            for(Id productId : productsToCheck) {
                if(hasLimits(productId) && !hasSatisfiedLimits(productId, numberofProductsInGroups)) {
                    String errorMessage = getErrorMessage(productId);
                    errors.put(productId, errorMessage);
                }
            }

            return errors;
        }

        Map<Id, Integer> getNumberofProductsInGroups() {
            Map<Id, Integer> existingProductIdToNum = idCount(existingProducts);

            Map<Id, Integer> groupToNum = new Map<Id, Integer>();
            for(Product_Group__c pgroup : groups) {
                groupToNum.put(pgroup.Id, 0);
                for(Product_Group_Member__c member : pgroup.Product_Group_Members__r) {
                    if(existingProductIdToNum.containsKey(member.Product__c)) {
                        Integer existingGroupCount = groupToNum.get(pgroup.Id);
                        Integer existingProductCount = existingProductIdToNum.get(member.Product__c);

                        groupToNum.put(pgroup.Id, existingGroupCount + existingProductCount);
                    }
                }
            }
            return groupToNum;
        }

        Boolean groupContains(List<Product_Group_Member__c> members, Id productId) {
            return Pluck.ids('Product__c', members).contains(productId);
        }

        Boolean hasLimits(Id productToCheck) {
            for(Product_Group__c pgroup : groups) {
                if(groupContains(pgroup.Product_Group_Members__r, productToCheck)) {
                    return true;
                }
            }

            return false;
        }

        Boolean hasSatisfiedLimits(Id productToCheck, Map<Id, Integer> numberofProductsInGroups) {
            for(Product_Rule__c rule : rules) {
                for(Product_Group__c pgroup : groups) {
                    if( (groupContains(pgroup.Product_Group_Members__r, productToCheck))
                       && (numberofProductsInGroups.get(pgroup.Id) < rule.Max_Quantity__c)) {
                        return true;
                    }
                }
            }

            return false;
        }

        String getErrorMessage(Id productToCheck) {
            for(Product_Rule__c rule : rules) {
                for(Product_Group__c pgroup : groups) {
                    if(groupContains(pgroup.Product_Group_Members__r, productToCheck)){
                        if(rule.Error_Message__c == null) {
                            return 'products from family '+pgroup.Name+' are limited to a maximum of '+rule.Max_Quantity__c+' and minumum of '+rule.Min_Quantity__c+' as defined by rule '+rule;
                        }

                        return rule.Error_Message__c;
                    }
                }
            }

            return 'Product is outside of its Product Limitations. Check Product Rule for more details.';
        }
    }

    static Map<Id, Integer> idCount(List<Id> ids) {
        Map<Id, Integer> idCount = new Map<Id, Integer>();

        for(Id id : ids) {
            if(idCount.containsKey(id)) {
                idCount.put(id, idCount.get(id) + 1);
            } else {
                idCount.put(id, 1);
            }
        }

        return idCount;
    }

    static Set<Id> getProductsExceedingLimit(Id quoteId, List<zqu.zChargeGroup> chargeGroups) {
        List<Id> existingProducts = ChargeGroupUtility.getRelatedProductsList(chargeGroups);
        Set<Id> allProducts = Pluck.ids([SELECT Id FROM zqu__ZProduct__c]);
        Set<Id> existingRatePlans = ChargeGroupUtility.getRelatedRatePlans(chargeGroups);

        List<Product_Rule__c> rules = [
           SELECT Product_Rate_Plan__c, Error_Message__c, Max_Quantity__c, Min_Quantity__c, Product_Group__c
           FROM Product_Rule__c
           WHERE Product_Rate_Plan__c IN :existingRatePlans
        ];

        List<Product_Group__c> groups = [
           SELECT Id, Name,
               (SELECT Product__c FROM Product_Group_Members__r)
           FROM Product_Group__c
           WHERE Id IN :Pluck.ids('Product_Group__c', rules)
        ];

        QuoteLimit quoteLimit = new QuoteLimit(rules, groups, existingProducts, existingRatePlans, allProducts);

        return quoteLimit.productToError.keySet();
    }
}