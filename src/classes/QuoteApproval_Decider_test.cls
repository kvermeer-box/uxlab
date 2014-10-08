/**
 * Test class for QuoteApproval_Decider
 *
 * @author Kyle Vermeer 5/8/2014
 */
@isTest
private class QuoteApproval_Decider_test {

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

    static zqu__ZProduct__c product;
    static List<zqu__ProductRatePlan__c> productRatePlans;
    static zqu__Quote__c quote;
    static List<zqu.zChargeGroup> existingChargeGroups;
  
    @isTest static void SalesApproverDirectory_basic() {
        /**
         *      Approver Code   Theater     Sales Division      Team
         *      |-------------|----------|-----------------|---------------|
         *      | SA1         | NATAM    | ESB             | Verticals     |
         *      | SA1         | NATAM    | ESB             | Horizontals   |
         *      | SA1         | NATAM    | ESB             | *             |
         *      |-------------|----------|-----------------|---------------|
         */
        String APPROVER_CODE = 'SA1';
        
        Sales_Approver_Matrix_Entry__c entry1 = new Sales_Approver_Matrix_Entry__c(Approver_Code__c = APPROVER_CODE, Theater__c = NATAM, Sales_Division__c = ESB, Team__c = VERTICALS);
        Sales_Approver_Matrix_Entry__c entry2 = new Sales_Approver_Matrix_Entry__c(Approver_Code__c = APPROVER_CODE, Theater__c = NATAM, Sales_Division__c = ESB, Team__c = HORIZONTALS);
        Sales_Approver_Matrix_Entry__c entry3 = new Sales_Approver_Matrix_Entry__c(Approver_Code__c = APPROVER_CODE, Theater__c = NATAM, Sales_Division__c = ESB, Team__c = QuoteApproval_Utils.QUERY_WILDCARD_STRING);
        insert new List<Sales_Approver_Matrix_Entry__c> { entry1, entry2, entry3 };
        Test.startTest();
        QuoteApproval_Decider.SalesApproverDirectory directory = new QuoteApproval_Decider.SalesApproverDirectory(new List<String> {APPROVER_CODE}, new ErrorTracker());
        Sales_Approver_Matrix_Entry__c retrievedEntry1 = directory.getEntry(APPROVER_CODE, NATAM, ESB, VERTICALS);
        Sales_Approver_Matrix_Entry__c retrievedEntry2 = directory.getEntry(APPROVER_CODE, NATAM, ESB, HORIZONTALS);
        Sales_Approver_Matrix_Entry__c retrievedEntry3 = directory.getEntry(APPROVER_CODE, NATAM, ESB, null);
        Sales_Approver_Matrix_Entry__c retrievedEntryNull = directory.getEntry(APPROVER_CODE, NATAM, 'Corporate', VERTICALS);
        Test.stopTest();
        System.assertEquals(VERTICALS, retrievedEntry1.Team__c);
        System.assertEquals(HORIZONTALS, retrievedEntry2.Team__c);
        System.assertEquals(QuoteApproval_Utils.QUERY_WILDCARD_STRING, retrievedEntry3.Team__c);
        System.assertEquals(null,retrievedEntryNull);
    }

    @isTest static void SalesApproverDirectory_complex() {
        createSalesApproverMatrixes();
        Test.startTest();
        QuoteApproval_Decider.SalesApproverDirectory directory = new QuoteApproval_Decider.SalesApproverDirectory(new List<String> {APPROVER_CODE_1, APPROVER_CODE_2, APPROVER_CODE_3}, new ErrorTracker());
        Sales_Approver_Matrix_Entry__c retrievedEntry1 = directory.getEntry(APPROVER_CODE_1, NATAM, CORPORATE, VERTICALS);
        Sales_Approver_Matrix_Entry__c retrievedEntry2 = directory.getEntry(APPROVER_CODE_1, NATAM, CORPORATE, HORIZONTALS);
        Sales_Approver_Matrix_Entry__c retrievedEntry3 = directory.getEntry(APPROVER_CODE_1, EMEA, null, null);
        Sales_Approver_Matrix_Entry__c retrievedEntry4 = directory.getEntry(APPROVER_CODE_2, NATAM, ESB, VERTICALS);
        Sales_Approver_Matrix_Entry__c retrievedEntry5 = directory.getEntry(APPROVER_CODE_3, NATAM, ESB, VERTICALS);
        Test.stopTest();
        // Retrieved Entry 1
        System.assertEquals(APPROVER_CODE_1, retrievedEntry1.Approver_Code__c);
        System.assertEquals(NATAM, retrievedEntry1.Theater__c);
        System.assertEquals(CORPORATE, retrievedEntry1.Sales_Division__c);
        System.assertEquals(VERTICALS, retrievedEntry1.Team__c);
        // Retrieved Entry 2
        System.assertEquals(APPROVER_CODE_1, retrievedEntry2.Approver_Code__c);
        System.assertEquals(NATAM, retrievedEntry2.Theater__c);
        System.assertEquals(CORPORATE, retrievedEntry2.Sales_Division__c);
        System.assertEquals(WILDCARD, retrievedEntry2.Team__c);
        // Retrieved Entry 3
        System.assertEquals(APPROVER_CODE_1, retrievedEntry3.Approver_Code__c);
        System.assertEquals(EMEA, retrievedEntry3.Theater__c);
        System.assertEquals(WILDCARD, retrievedEntry3.Sales_Division__c);
        System.assertEquals(WILDCARD, retrievedEntry2.Team__c);
        // Retrieve Entry 4
        System.assertEquals(APPROVER_CODE_2, retrievedEntry4.Approver_Code__c);
        System.assertEquals(NATAM, retrievedEntry4.Theater__c);
        System.assertEquals(ESB, retrievedEntry4.Sales_Division__c);
        System.assertEquals(VERTICALS, retrievedEntry4.Team__c);
        // Retrieve Entry 5
        System.assertEquals(APPROVER_CODE_3, retrievedEntry5.Approver_Code__c);
        System.assertEquals(WILDCARD, retrievedEntry5.Theater__c);
        System.assertEquals(WILDCARD, retrievedEntry5.Sales_Division__c);
        System.assertEquals(WILDCARD, retrievedEntry5.Team__c);
    }

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

    private static void setup() {
        createSalesApproverMatrixes();
        product = TestFactory.prepareProductCatalog(TestFactory.rateplannames);

        Account acc = TestFactory.makeAccount();
        Opportunity opp = TestFactory.makeOpportunity(acc);
        opp.OwnerId = TestDataFactory_hlpr.createUser(ESB, NATAM, 'kylev', '0idajikiu38yr@box.com');
        update opp;
        quote = TestFactory.makeQuote(opp);

        productRatePlans = [
            SELECT Name
            FROM zqu__ProductRatePlan__c
            WHERE zqu__ZProduct__c = :product.Id
        ];

        existingChargeGroups = zqu.zQuoteUtil.getChargeGroups(quote.Id);
        //System.assert(existingChargeGroups.isEmpty(), 'no charge groups should exist on the quote');

        zqu.zChargeGroup newChargeGroup = zqu.zQuoteUtil.getChargeGroups(quote.Id, new List<Id>{productRatePlans[0].Id})[0];
        for(zqu.zCharge charge : newChargeGroup.zCharges) {
            charge.TOTAL = '20';
        }
        newChargeGroup.zCharges = zqu.zQuoteUtil.calculateChargesOnTotalChange(newChargeGroup.zCharges);
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

    @isTest static void decider_basic() {
        setup();
        Test.startTest();
        ErrorTracker et = new ErrorTracker();
        QuoteApproval_DataSource datasource = new QuoteApproval_ZQuoteDataSource(quote.Id);
        QuoteApproval_Decider decider = new QuoteApproval_Decider(datasource,et);
        List<Quote_Approval__c> approvals = decider.getApprovalsNeeded();

        Test.stopTest();
        System.debug('Any Errors: ' + et.getErrorList());
        //System.assert(!et.hasErrors());
        //System.assertEquals(1, approvals.size(), 'Only one approval should have been launched.');

        System.debug('Approvals: ' + approvals);
    }
}