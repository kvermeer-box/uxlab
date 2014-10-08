@isTest
private class Z_RatePlanGroup_Test {

	public static final String RATE_PLAN_GROUP_PREMIER_SUPPORT = 'Premier Support';
	public static final String RATE_PLAN_GROUP_BOX_CONSULTING = 'Box Consulting';
	
 	static Account account;
    static Opportunity opportunity;
    static zqu__Quote__c quote;
    static Set<Id> quoteIds = new Set<Id>();
    static Map<Id, List<zqu__QuoteChargeSummary__c>> quoteChargeSummaryMap; 
    static List<String> ratePlanGroupNames;
	static Z_RatePlanGroup ratePlanGroups;
    static List<zqu__ProductRatePlan__c> percentProductRatePlan;
    static zqu__ZProduct__c product;
    static zqu__ProductRatePlan__c productRatePlan;
    static zqu__ProductRatePlanCharge__c productRatePlanCharge;
    static Rate_Plan_Group__c ratePlanGroup;
    static Rate_Plan_Group_Member__c ratePlanGroupMember;

    static void setup() {
    	//delete
    	account = TestFactory.makeAccount();
        opportunity = TestFactory.makeOpportunity(account);
        quote = TestFactory.makeQuote(opportunity);	
        
        ratePlanGroupNames = new List<String>();
    	ratePlanGroupNames.add(RATE_PLAN_GROUP_PREMIER_SUPPORT);
    	ratePlanGroupNames.add(RATE_PLAN_GROUP_BOX_CONSULTING); 
    	
        quoteIds.add(quote.Id);	
    	
    	quoteChargeSummaryMap = new Map<Id, List<zqu__QuoteChargeSummary__c>> (); //?
    	quoteChargeSummaryMap.put(quote.Id, new List<zqu__QuoteChargeSummary__c> {new zqu__QuoteChargeSummary__c(Name = 'name')});//quote.Quote_Charge_Summarys__r);	
        product = Z_TestUtils.createZProduct(false);
        product.Name = 'name'; 
        insert product;
        productRatePlan = Z_TestUtils.createZProductRatePlan(product.Id, true);
        productRatePlanCharge = Z_TestUtils.createZProductRatePlanCharge(productRatePlan.Id, true);

        ratePlanGroup = new Rate_Plan_Group__c(Name=RATE_PLAN_GROUP_BOX_CONSULTING);
        insert ratePlanGroup;
        
        ratePlanGroupMember = new Rate_Plan_Group_Member__c(Rate_Plan_Group__c=ratePlanGroup.Id);
        insert ratePlanGroupMember;

    }
    
	static testMethod void testContainsRatePlan() {

        setup();
        
        Test.startTest();
        
        //First test constructor with null
        ratePlanGroups = new Z_RatePlanGroup(null);
        
        //Test with null argument:
        ratePlanGroups.containsRatePlan(null, null);

        //Test with ratePlanGroupNames from setup() 
    	ratePlanGroups = new Z_RatePlanGroup(ratePlanGroupNames);
        List<zqu__QuoteChargeSummary__c> quoteChargeSummaryList = quoteChargeSummaryMap.get(quote.Id);
        for(zqu__QuoteChargeSummary__c qcs : quoteChargeSummaryList){
			System.debug('>>>>>>>>qcs='+qcs);
			if(ratePlanGroups.containsRatePlan(RATE_PLAN_GROUP_PREMIER_SUPPORT,qcs.Product_Rate_Plan__c)) {
				//boxConsulting = boxConsulting + qcs.zqu__TotalPrice__c;
			}
			if(ratePlanGroups.containsRatePlan(RATE_PLAN_GROUP_BOX_CONSULTING,qcs.Product_Rate_Plan__c)) {
				
			}
		}//end-for qcs
        
        Test.stopTest(); 
    }

    static testMethod void testContainsRatePlanZuoraId() {

        setup();

        Test.startTest();
        
        //Test with ratePlanGroupNames from setup() 
        ratePlanGroups = new Z_RatePlanGroup(ratePlanGroupNames);

        //Test with null args:
        ratePlanGroups.containsRatePlanZuoraId(null, null);

        if(ratePlanGroups.containsRatePlanZuoraId(RATE_PLAN_GROUP_PREMIER_SUPPORT, 'plan1')) {
            //boxConsulting = boxConsulting + qcs.zqu__TotalPrice__c;
        }
        if(ratePlanGroups.containsRatePlanZuoraId(RATE_PLAN_GROUP_BOX_CONSULTING, 'plan2')) {
            
        }
        
        Test.stopTest();
    }

    static testMethod void testContainsRatePlanCharge() {

        setup();

        Test.startTest();

        //Test with ratePlanGroupNames from setup() 
        ratePlanGroups = new Z_RatePlanGroup(ratePlanGroupNames);

        //Test with null args:
        ratePlanGroups.containsRatePlanCharge(null, null);

        boolean bool = ratePlanGroups.containsRatePlanCharge('group', productRatePlanCharge.Id);  
        
        Test.stopTest();
    }

    static testMethod void testIncludeRatePlans() {

        setup();

        Test.startTest();

        //Test with ratePlanGroupNames from setup() 
        ratePlanGroups = new Z_RatePlanGroup(ratePlanGroupNames);
        List<Id> ids = ratePlanGroups.includeRatePlans('grp', quoteIds);

        //Test with null args:
        ids = ratePlanGroups.includeRatePlans(null, null);

        //Test with valid group name:
        ids = ratePlanGroups.includeRatePlans(RATE_PLAN_GROUP_BOX_CONSULTING, quoteIds);
        ids = ratePlanGroups.includeRatePlans(RATE_PLAN_GROUP_PREMIER_SUPPORT, quoteIds);

        Test.stopTest();
    }
    
}