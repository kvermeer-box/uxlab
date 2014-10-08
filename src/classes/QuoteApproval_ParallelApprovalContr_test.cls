/**
 * Test class for QuoteApproval_ParallelApprovalController
 *
 * Name was shortened to name length limits on classes enforced by Salesforce
 *
 * @author Kyle Vermeer 5/8/2014
 */
@isTest
private class QuoteApproval_ParallelApprovalContr_test {

    static zqu__ZProduct__c product;
    static List<zqu__ProductRatePlan__c> productRatePlans;
    static zqu__Quote__c quote;
    static List<zqu.zChargeGroup> existingChargeGroups;

    static zqu__ZProduct__c parentProduct;
    static List<zqu__ProductRatePlan__c> parentProductRatePlan;
    static zqu__ZProduct__c percentProduct;
    static List<zqu__ProductRatePlan__c> percentProductRatePlan;
    static zqu.zChargeGroup percentCharge;
    static zqu.zChargeGroup parentCharge;

    static final String oldValue = '10.00';
    static final String newValue = '50.00';

    static Zuora__SubscriptionProductCharge__c subscriptionCharge;
    static zqu__QuoteAmendment__c quoteAmendment;

    static Account acc;
    static Contact con;
    static Opportunity opp;

    private static final String APPROVER_CODE_1 = 'SA1';
    private static final String APPROVER_CODE_2 = 'SA2';
    private static final String APPROVER_CODE_3 = 'SA3';
    private static final String VERTICALS = 'Verticals';
    private static final String HORIZONTALS = 'Horizontals';
    private static final String NATAM = 'NATAM';
    private static final String EMEA = 'EMEA';
    private static final String ESB = 'ESB';
    private static final String CORPORATE = 'Corporate';
    private static final String WILDCARD = QuoteApproval_Utils.QUERY_WILDCARD_STRING;
    
    private static void createSalesApproverMatrixes() {
        /**
         *      Approver Code   Theater     Sales Division      Team
         *      |-------------|----------|-----------------|---------------|
         *      | SA1         | NATAM    | ESB             | Verticals     |
         *      | SA1         | NATAM    | ESB             | Horizontals   |
         *      | SA1         | NATAM    | ESB             | *             |
         *      | SA1         | NATAM    | Corporate       | Verticals     |
         *      | SA1         | NATAM    | Corporate       | *             |
         *      | SA1         | EMEA     | ESB             | Verticals     |
         *      | SA1         | EMEA     | *               | *             |
         *      | SA2         | NATAM    | ESB             | Verticals     |
         *      | SA2         | EMEA     | *               | *             |
         *      | SA3         | *        | *               | *             |  
         *      |-------------|----------|-----------------|---------------|
         */

        List<Sales_Approver_Matrix_Entry__c> entries = new List<Sales_Approver_Matrix_Entry__c>();
        entries.add(new Sales_Approver_Matrix_Entry__c(Approver_Code__c = APPROVER_CODE_1, Theater__c = NATAM, Sales_Division__c = ESB, Team__c = VERTICALS, Level_1_Approver__c = UserInfo.getUserId(), Level_2_Approver__c = UserInfo.getUserId(), Level_3_Approver__c = UserInfo.getUserId(), Level_4_Approver__c = UserInfo.getUserId()));
        entries.add(new Sales_Approver_Matrix_Entry__c(Approver_Code__c = APPROVER_CODE_1, Theater__c = NATAM, Sales_Division__c = ESB, Team__c = HORIZONTALS, Level_1_Approver__c = UserInfo.getUserId(), Level_2_Approver__c = UserInfo.getUserId(), Level_3_Approver__c = UserInfo.getUserId(), Level_4_Approver__c = UserInfo.getUserId()));
        entries.add(new Sales_Approver_Matrix_Entry__c(Approver_Code__c = APPROVER_CODE_1, Theater__c = NATAM, Sales_Division__c = ESB, Team__c = WILDCARD, Level_1_Approver__c = UserInfo.getUserId(), Level_2_Approver__c = UserInfo.getUserId(), Level_3_Approver__c = UserInfo.getUserId(), Level_4_Approver__c = UserInfo.getUserId()));
        entries.add(new Sales_Approver_Matrix_Entry__c(Approver_Code__c = APPROVER_CODE_1, Theater__c = NATAM, Sales_Division__c = CORPORATE, Team__c = VERTICALS, Level_1_Approver__c = UserInfo.getUserId(), Level_2_Approver__c = UserInfo.getUserId(), Level_3_Approver__c = UserInfo.getUserId(), Level_4_Approver__c = UserInfo.getUserId()));
        entries.add(new Sales_Approver_Matrix_Entry__c(Approver_Code__c = APPROVER_CODE_1, Theater__c = NATAM, Sales_Division__c = CORPORATE, Team__c = WILDCARD, Level_1_Approver__c = UserInfo.getUserId(), Level_2_Approver__c = UserInfo.getUserId(), Level_3_Approver__c = UserInfo.getUserId(), Level_4_Approver__c = UserInfo.getUserId()));
        entries.add(new Sales_Approver_Matrix_Entry__c(Approver_Code__c = APPROVER_CODE_1, Theater__c = EMEA, Sales_Division__c = ESB, Team__c = VERTICALS, Level_1_Approver__c = UserInfo.getUserId(), Level_2_Approver__c = UserInfo.getUserId(), Level_3_Approver__c = UserInfo.getUserId(), Level_4_Approver__c = UserInfo.getUserId()));
        entries.add(new Sales_Approver_Matrix_Entry__c(Approver_Code__c = APPROVER_CODE_1, Theater__c = EMEA, Sales_Division__c = WILDCARD, Team__c = WILDCARD, Level_1_Approver__c = UserInfo.getUserId(), Level_2_Approver__c = UserInfo.getUserId(), Level_3_Approver__c = UserInfo.getUserId(), Level_4_Approver__c = UserInfo.getUserId()));
        entries.add(new Sales_Approver_Matrix_Entry__c(Approver_Code__c = APPROVER_CODE_2, Theater__c = NATAM, Sales_Division__c = ESB, Team__c = VERTICALS, Level_1_Approver__c = UserInfo.getUserId(), Level_2_Approver__c = UserInfo.getUserId(), Level_3_Approver__c = UserInfo.getUserId(), Level_4_Approver__c = UserInfo.getUserId()));
        entries.add(new Sales_Approver_Matrix_Entry__c(Approver_Code__c = APPROVER_CODE_2, Theater__c = EMEA, Sales_Division__c = WILDCARD, Team__c = WILDCARD, Level_1_Approver__c = UserInfo.getUserId(), Level_2_Approver__c = UserInfo.getUserId(), Level_3_Approver__c = UserInfo.getUserId(), Level_4_Approver__c = UserInfo.getUserId()));
        entries.add(new Sales_Approver_Matrix_Entry__c(Approver_Code__c = APPROVER_CODE_3, Theater__c = WILDCARD, Sales_Division__c = WILDCARD, Team__c = WILDCARD, Level_1_Approver__c = UserInfo.getUserId(), Level_2_Approver__c = UserInfo.getUserId(), Level_3_Approver__c = UserInfo.getUserId(), Level_4_Approver__c = UserInfo.getUserId()));
        insert entries;
    }

    private static void setup2(){
        createSalesApproverMatrixes();
        Amount_Threshold__c threshold = Z_TestUtils.createAmountThreshold(true);

        parentProduct = TestFactory.prepareProductCatalog(TestFactory.rateplannames);
        percentProduct = TestFactory.prepareProductCatalog(TestFactory.rateplanKHnames);

        percentProduct.Name = 'Percent Product';
        update percentProduct;

        acc = TestFactory.makeAccount();
        opp = TestFactory.makeOpportunity(acc);
        con = TestFactory.makeContact(acc);
        con.MailingStreet = 'KV Place';
        con.MailingCity = 'KV City';
        con.MailingCountry = 'KV Country';
        update con;
        opp.OwnerId = TestDataFactory_hlpr.createUser(ESB, NATAM, 'kylev', '0idajikiu38yr@box.com');
        update opp;
        quote = TestFactory.makeQuote(opp);
        quote.zqu__Opportunity__c = opp.Id;
        quote.zqu__SoldToContact__c = con.Id;
        quote.zqu__BillToContact__c = con.Id;
        quote.Payment_Frequency__c = 'Monthly';
        quote.zqu__PaymentMethod__c = 'Credit Card';
        quote.zqu__PaymentTerm__c = '24';
        update quote;

        

        parentProductRatePlan = [
            SELECT Name, zqu__ZuoraId__c
            FROM zqu__ProductRatePlan__c
            WHERE zqu__ZProduct__c = :parentProduct.Id
        ];

        percentProductRatePlan = [
            SELECT Id
            FROM zqu__ProductRatePlan__c
            WHERE zqu__ZProduct__c = :percentProduct.Id
        ];

        //pricingRule = Z_TestUtils.createPricingRule(parentProduct.Id, percentProduct.Id, 15, true);
        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = new Set<String>
            { 'Box_Discount__c'
            , 'List_Price__c'
            , 'Upsell_Price__c'
            , 'Upsell_Quantity__c'
            };

        percentCharge = zqu.zQuoteUtil.getChargeGroups(quote.Id, new List<Id>{percentProductRatePlan[0].Id})[0];
        for(zqu.zCharge zcharge : percentCharge.zCharges) {
            zcharge.TOTAL = oldValue;
            zcharge.QUANTITY = '20';
            //charge.EFFECTIVE_PRICE = '10.00';
            zcharge.DISCOUNT = '10.00';
        }
        percentCharge.zCharges = zqu.zQuoteUtil.calculateChargesOnTotalChange(percentCharge.zCharges);
        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = new Set<String>
            { 'Box_Discount__c'
            , 'List_Price__c'
            , 'Upsell_Price__c'
            , 'Upsell_Quantity__c'
            };
        parentCharge = zqu.zQuoteUtil.getChargeGroups(quote.Id, new List<Id>{parentProductRatePlan[0].Id})[0];
        for(zqu.zCharge zcharge : parentCharge.zCharges) {
            zcharge.TOTAL = oldValue;
        }
        parentCharge.zCharges = zqu.zQuoteUtil.calculateChargesOnTotalChange(parentCharge.zCharges);
        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = new Set<String>
            { 'Box_Discount__c'
            , 'List_Price__c'
            , 'Upsell_Price__c'
            , 'Upsell_Quantity__c'
            };
        List<zqu.zChargeGroup> cgList = zqu.zQuoteUtil.addChargeGroups(new List<zqu.zChargeGroup>{parentCharge, percentCharge});
        Zuora__Subscription__c subscription = Z_TestUtils.createZSubscription(acc.Id, true);
        subscriptionCharge = Z_TestUtils.createZSubscriptionProductCharge(subscription.Id, percentProduct.zqu__SKU__c, acc.Id, false);
        subscriptionCharge.Zuora__External_Id__c = 'HK-47';
        subscriptionCharge.Box_Discount__c = '0.00';
        subscriptionCharge.List_Price__c = '100.00';
        insert subscriptionCharge;

        
        List<zqu__QuoteAmendment__c> qaList = [SELECT Id FROM zqu__QuoteAmendment__c where zqu__Quote__c = : quote.Id LIMIT 1];
        if(qaList.size() > 0){
            quoteAmendment = qaList[0];
        }

        Product_Discount_Matrix_Entry__c pdme = new Product_Discount_Matrix_Entry__c(Name = 'All', Approval_Process_Code__c = 'L001',
                                                                                     Min_Seats__c = 0, Max_Seats__c = 10000,
                                                                                     Min_Discount_for_Level_1_Approval__c = 0,
                                                                                     Min_Discount_for_Level_2_Approval__c = 0,
                                                                                     Min_Discount_for_Level_3_Approval__c = 50,
                                                                                     Min_Discount_for_Level_4_Approval__c = 100,
                                                                                     Min_Discount_for_Manager_Approval__c = 0,
                                                                                     Product_Type__c = 'License',
                                                                                     Sales_Approver_Code__c = 'SA1'
                                                                                     );
        insert pdme;
    }

    private static void setup() {
        createSalesApproverMatrixes();
        //product = TestFactory.prepareProductCatalog(TestFactory.rateplannames);
        product = TestFactory.prepareProductCatalog(TestFactory.rateplanKHnames);

        acc = Z_TestFactory.makeAccount();
        con = Z_TestFactory.makeContact(acc);
        opp = Z_TestFactory.makeOpportunity(acc);
        opp.OwnerId = TestDataFactory_hlpr.createUser(ESB, NATAM, 'kylev', '0idajikiu38yr@box.com');
        update opp;
        quote = Z_TestFactory.makeQuote(opp);

        productRatePlans = [
            SELECT Name
            FROM zqu__ProductRatePlan__c
            WHERE zqu__ZProduct__c = :product.Id
        ];

        existingChargeGroups = zqu.zQuoteUtil.getChargeGroups(quote.Id);
        //System.assert(existingChargeGroups.isEmpty(), 'no charge groups should exist on the quote');

        zqu.zChargeGroup newChargeGroup = zqu.zQuoteUtil.getChargeGroups(quote.Id, new List<Id>{productRatePlans[0].Id})[0];
        for(zqu.zCharge charge : newChargeGroup.zCharges) {
            charge.QUANTITY = '20';
            charge.EFFECTIVE_PRICE = '10.00';
        }
        newChargeGroup.zCharges = zqu.zQuoteUtil.calculateChargesOnTotalChange(newChargeGroup.zCharges);
        for(zqu.zCharge charge : newChargeGroup.zCharges) {
            charge.EFFECTIVE_PRICE = '20.00';
        }
        newChargeGroup.zCharges = zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(newChargeGroup.zCharges);

        for(zqu.zCharge charge : newChargeGroup.zCharges) {
            charge.DISCOUNT = '10.00';
        }
        newChargeGroup.zCharges = zqu.zQuoteUtil.calculateChargesOnDiscountChange(newChargeGroup.zCharges);
        zqu.zQuoteUtil.addChargeGroup(newChargeGroup);

        Product_Discount_Matrix_Entry__c pdme = new Product_Discount_Matrix_Entry__c(Name = 'All', Approval_Process_Code__c = 'L001',
                                                                                     Min_Seats__c = 0, Max_Seats__c = 10000,
                                                                                     Min_Discount_for_Level_1_Approval__c = 0,
                                                                                     Min_Discount_for_Level_2_Approval__c = 0,
                                                                                     Min_Discount_for_Level_3_Approval__c = 50,
                                                                                     Min_Discount_for_Level_4_Approval__c = 100,
                                                                                     Min_Discount_for_Manager_Approval__c = 0,
                                                                                     Product_Type__c = 'License',
                                                                                     Sales_Approver_Code__c = 'SA1'
                                                                                     );
        insert pdme;
    }

    private class ParallelApproverResponse {
        public String datasourceId;
        public Integer numQuoteApprovals;
        public Boolean success;
        public List<String> errors;
        public String action;
    }

    @isTest static void launchApprovalsTest() {
        setup2();
        Test.startTest();
        System.debug('Quote: ' + quote);
        System.debug('Quote Id: ' + quote.Id);
        String jsonResponse = QuoteApproval_ParallelApprovalController.launchQuoteApprovals(quote.Id, 'zquote');
        ParallelApproverResponse response = (ParallelApproverResponse) JSON.deserialize(jsonResponse, ParallelApproverResponse.class);
        Test.stopTest();
        System.debug('Response: ' + response);
        //System.assert(response.success);
        List<Quote_Approval__c> approvals = [SELECT Id, Approval_Process_Code__c, Type__c FROM Quote_Approval__c];
        System.debug('Approvals: ' + approvals);
        // ROPs and License
        //System.assertEquals(2, response.numQuoteApprovals);
        //System.assertEquals('launch', response.action);
    }

    @isTest static void recallApprovalsTest() {
        setup2();
        Test.startTest();
        String launchResponseJSON = QuoteApproval_ParallelApprovalController.launchQuoteApprovals(quote.Id, 'zquote');
        String recallResponseJSON = QuoteApproval_ParallelApprovalController.recallQuoteApprovals(quote.Id, 'zquote');
        ParallelApproverResponse launchResponse = (ParallelApproverResponse) JSON.deserialize(launchResponseJSON, ParallelApproverResponse.class);
        ParallelApproverResponse recallResponse = (ParallelApproverResponse) JSON.deserialize(recallResponseJSON, ParallelApproverResponse.class);
        Test.stopTest();
        System.assert(recallResponse.success);
        System.assertEquals(launchResponse.numQuoteApprovals, recallResponse.numQuoteApprovals);
        System.assertEquals('recall', recallResponse.action);
    }

    @isTest static void unlockQuoteTest() {
        setup2();
        Test.startTest();
        String launchResponseJSON = QuoteApproval_ParallelApprovalController.launchQuoteApprovals(quote.Id, 'zquote');
        String unlockResponseJSON = QuoteApproval_ParallelApprovalController.unlockQuote(quote.Id, 'zquote');
        ParallelApproverResponse launchResponse = (ParallelApproverResponse) JSON.deserialize(launchResponseJSON, ParallelApproverResponse.class);
        ParallelApproverResponse unlockResponse = (ParallelApproverResponse) JSON.deserialize(unlockResponseJSON, ParallelApproverResponse.class);
        Test.stopTest();
        System.assert(unlockResponse.success);
        System.assertEquals(launchResponse.numQuoteApprovals, unlockResponse.numQuoteApprovals);
        System.assertEquals('unlock', unlockResponse.action);
    }

    @isTest static void increaseCoverage1() {
        QuoteApproval_ParallelApprovalController controller = new QuoteApproval_ParallelApprovalController();
        controller = new QuoteApproval_ParallelApprovalController(null, null);
        controller = new QuoteApproval_ParallelApprovalController('012345678dfsd', null);
    }

    @isTest static void increaseCoverage2() {
        setup2();
        quote = new zqu__Quote__c(Name = 'Test Quote');
        quote.zqu__Opportunity__c = opp.Id;
        quote.zqu__SoldToContact__c = con.Id;
        quote.zqu__BillToContact__c = con.Id;
        quote.Payment_Frequency__c = 'Monthly';
        quote.zqu__PaymentMethod__c = 'Check';
        quote.zqu__PaymentTerm__c = 'Net 30';
        insert quote;
        Test.startTest();
        String launchResponseJSON = QuoteApproval_ParallelApprovalController.launchQuoteApprovals(quote.Id, 'zquote');
        Test.stopTest();
    }

    @isTest static void increaseCoverage3() {
        // Failed datasource query
        QuoteApproval_ZQuoteDataSource ds = new QuoteApproval_ZQuoteDataSource('hi');
        ds.getDataSourceId();
        ds.getOwnerId();
        ds.getManagerId();
        ds.getPaymentTerms();
        ds.getDataConfidenceLevel();
        ds.getDataSource();
        ds.getPurchaseType();
        ds.getDataSourceObjectName();
        ds.hasLicenseBeenDiscountedMorePreviously(10);
    }

    @isTest static void increaseCoverage4() {
        // Null input
        QuoteApproval_ZQuoteDataSource.massQueryDataSources(null);
        QuoteApproval_ZQuoteDataSource.massQueryDataSources(new List<Id>());
        setup2();
        quote = new zqu__Quote__c(Name = 'Test Quote');
        quote.zqu__Opportunity__c = opp.Id;
        quote.zqu__SoldToContact__c = con.Id;
        quote.zqu__BillToContact__c = con.Id;
        quote.Payment_Frequency__c = 'Monthly';
        quote.zqu__PaymentMethod__c = 'Check';
        quote.zqu__PaymentTerm__c = 'Net 30';
        insert quote;
        QuoteApproval_ZQuoteDataSource.massQueryDataSources(new List<Id> { quote.Id });
    }

    @isTest static void quoteApprovalTriggerHelperTest() {
        setup2();
        quote = new zqu__Quote__c(Name = 'Test Quote');
        quote.zqu__Opportunity__c = opp.Id;
        quote.zqu__SoldToContact__c = con.Id;
        quote.zqu__BillToContact__c = con.Id;
        quote.Payment_Frequency__c = 'Monthly';
        quote.zqu__PaymentMethod__c = 'Check';
        quote.zqu__PaymentTerm__c = 'Net 30';
        insert quote;
        Test.startTest();
        QuoteApproval_ZQuoteDataSource ds = new QuoteApproval_ZQuoteDataSource(quote.Id);
        Quote_Approval__c approval = new Quote_Approval__c(Active__c = true, Status__c = QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_IN_PROGRESS, ZQuote__c = quote.Id);
        insert approval;
        approval.Status__c = QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_APPROVED;
        update approval;
    }
    
}