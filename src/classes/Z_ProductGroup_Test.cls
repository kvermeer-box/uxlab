@isTest
private class Z_ProductGroup_Test {

 	public static String PRODUCT_GROUP_BOX_VIEW_API 			= 'Box View API';
 	public static String PRODUCT_GROUP_BOX_CONTENT_API 			= 'Box Content API'; 	

	public static zqu__ZProduct__c prod1;
	public static zqu__ZProduct__c prod2;
	public static zqu__ZProduct__c prod3;
	public static zqu__ZProduct__c prod4;
	
    static void setup() {

    	prod1 = TestFactory.makeProduct('view prod 1');	
    	prod2 = TestFactory.makeProduct('view prod 2');
    	prod3 = TestFactory.makeProduct('content prod 3');	
    	prod4 = TestFactory.makeProduct('content prod 4');
    	    	
		Product_Group__c productGroup1 = new Product_Group__c(Name=PRODUCT_GROUP_BOX_VIEW_API);
		insert productGroup1;
		
		Product_Group_Member__c member1 = new Product_Group_Member__c(Product_Group__c=productGroup1.Id, product__c=prod1.Id);
		insert member1;

		Product_Group_Member__c member2 = new Product_Group_Member__c(Product_Group__c=productGroup1.Id, product__c=prod2.Id);
		insert member2;

		Product_Group__c productGroup2 = new Product_Group__c(Name=PRODUCT_GROUP_BOX_CONTENT_API);
		insert productGroup2;
		
		Product_Group_Member__c member3 = new Product_Group_Member__c(Product_Group__c=productGroup2.Id, product__c=prod3.Id);
		insert member3;

		Product_Group_Member__c member4 = new Product_Group_Member__c(Product_Group__c=productGroup2.Id, product__c=prod4.Id);
		insert member4;
 
    }
 
    static testMethod void testMethod1() {

        setup();

		List<String> productGroupNames = new List<String>();
		productGroupNames.add(PRODUCT_GROUP_BOX_VIEW_API);
		productGroupNames.add(PRODUCT_GROUP_BOX_CONTENT_API);  
		Z_ProductGroup productGroups = new Z_ProductGroup(productGroupNames);  
		
		boolean containsProduct1a = productGroups.containsProduct(PRODUCT_GROUP_BOX_VIEW_API, prod1.Id);		
		boolean containsProduct1b = productGroups.containsProduct(PRODUCT_GROUP_BOX_VIEW_API, prod3.Id);	
		boolean containsProduct2a = productGroups.containsProduct(PRODUCT_GROUP_BOX_CONTENT_API, new List<Id> {prod2.Id, prod4.Id});
		integer productCount = productGroups.countProduct(PRODUCT_GROUP_BOX_VIEW_API, new List<Id> {prod1.Id, prod4.Id});
		set<Id> memberIds = productGroups.getMemberIds(PRODUCT_GROUP_BOX_CONTENT_API);	      
    }        
}