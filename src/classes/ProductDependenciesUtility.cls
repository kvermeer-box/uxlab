public with sharing class ProductDependenciesUtility {

    public static Set<Id> removeProductsWithMissingDependencies(Set<Id> productIds, Id quoteId, List<zqu.zChargeGroup> chargeGroups) {
        Set<Id> productsMissingDependencies = getProductsWithMissingDependencies(quoteId, chargeGroups);

        return ChargeGroupUtility.setDifference(productIds, productsMissingDependencies);
    }

    @TestVisible class QuoteDependency {
        public List<Product_Dependency__c> dependencies;
        public Set<Id> existingProducts;
        public Set<Id> productsToCheck;

        public QuoteDependency(List<Product_Dependency__c> dependencies, Set<Id> existingProducts, Set<Id> productsToCheck) {
            this.dependencies = dependencies;
            this.existingProducts = existingProducts;
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
            Map<Id, Set<Id>> productIdToParent = buildDependencyMap();
            Map<Id, String> productIdToName = buildProductIdToName();

            for(Id productId : productIdToParent.keySet()) {
                Set<Id> parents = productIdToParent.get(productId);
                if(!hasNoDependencies(parents) && !hasSatisfiedDependencies(parents)) {
                    String errorMessage = productIdToName.get(productId)+' cannot be inserted without it\'s parent(s): '+mapIdsToStrings(parents, productIdToName);
                    errors.put(productId, errorMessage);
                }
            }

            return errors;
        }

        Set<String> mapIdsToStrings(Set<Id> ids, Map<Id, String> idToString) {
            Set<String> strings = new Set<String>();

            for(Id id : ids) {
                strings.add(idToString.get(id));
            }

            return strings;
        }

        Map<Id, Set<Id>> buildDependencyMap() {
            Map<Id, Set<Id>> childToParent = new Map<Id, Set<Id>>();

            for(Id productId : productsToCheck) {
                childToParent.put(productId, new Set<Id>());
                for(Product_Dependency__c dependency : dependencies) {
                    if(dependency.Dependent_Product__c == productId) {
                        childToParent.get(productId).add(dependency.Product__c);
                    }
                }
            }

            return childToParent;
        }

        Map<Id, String> buildProductIdToName() {
            Map<Id, String> productIdToName = new Map<Id, String>();

            for(Product_Dependency__c dependency : dependencies) {
                productIdToName.put(dependency.Dependent_Product__c, dependency.Dependent_Product__r.Name);
                productIdToName.put(dependency.Product__c, dependency.Product__r.Name);
            }

            return productIdToName;
        }

        Boolean hasSatisfiedDependencies(Set<Id> parents) {
            return !ChargeGroupUtility.setIntersection(parents, existingProducts).isEmpty();
        }

        Boolean hasNoDependencies(Set<Id> parents) {
            return parents.isEmpty();
        }
    }

    static Set<Id> getProductsWithMissingDependencies(Id quoteId, List<zqu.zChargeGroup> chargeGroups) {
        Set<Id> existingProducts = ChargeGroupUtility.getRelatedProducts(chargeGroups);
        Set<Id> allZProducts = Pluck.ids([SELECT Id FROM zqu__ZProduct__c]);
        List<Product_Dependency__c> dependencies = [SELECT Product__c, Product__r.Name, Dependent_Product__c, Dependent_Product__r.Name FROM Product_Dependency__c];

        QuoteDependency quoteDependency = new QuoteDependency(dependencies, existingProducts, allZProducts);

        return quoteDependency.productToError.keySet();
    }
}