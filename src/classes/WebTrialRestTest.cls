@isTest
private class WebTrialRestTest {

    // Zuora constants
    private static final String ZUORA_SUBSCRIPTION_STATUS_ACTIVE    = 'Active';
    private static final String ZUORA_PAYMENT_METHOD_CREDIT_CARD    = 'CreditCard';
    private static final String ZUORA_LAST_TRANSACTION_APPROVED     = 'Approved';
    private static final String ZUORA_LAST_PAYMENT_PROCESSED        = 'Processed';
    private static final String ZUORA_LAST_PAYMENT_VOIDED           = 'Voided';
    private static final String ZUORA_SUBSCRIPTION_STATUS_CANCELLED = 'Cancelled';
    private static final String ZUORA_SUBSCRIPTION_STATUS_EXPIRED   = 'Expired';
    private static final String ZUORA_BILLING_ANNUAL                = 'Annual';
    private static final String ZUORA_BILLING_MONTHLY               = 'Month';

    private static WebTrialRest.WebTrial wt;
    private static String randomNum;

    // Other constants
    private static final String OPP_NAME_APPEND          = '-Web Trial Conversion';
    private static final String OPP_NAME_CANCEL_APPEND   = '-Web Trial Conversion(cancelled)';
    private static final String OPP_NAME_DECLINE_APPEND  = '-Web Trial Conversion(cc decline)';
    private static final String OPP_NAME_INACTIVE_APPEND = '-Web Trial Conversion(inactive)';
    private static final String OPP_STAGE_CLOSED_WON     = 'Closed Won';
    private static final String OPP_STAGE_CLOSED_LOST    = 'Closed Lost';
    private static final String OPP_LOST_BIZ_REASON      = 'Lack of Adoption';
    private static final String ENTERPRISE_BLOCK         = 'block';
    private static final String OWNER_QUEUE_PREFIX       = '00G';
    private static final String LEAD_STATUS_DEFAULT      = 'Pending';

    static final String ENTERPRISE_ID = 'appery';
    static final String EMAIL = 'tom@tom.tom';
    static final Date TRIAL_END = Date.newInstance(1987, 05, 28);

    static final String REQUEST_BODY = 'Test Body';

    static void setupRestContext()
    {
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf( REQUEST_BODY );
        RestContext.request = request;
    }

    static void setupDefaultCampaign() {
        Campaign campaign = TestUtils.createCampaign(true);
        TestUtils.createInAppRestSettings('default', campaign.Id, true);
    }

    static void setUp() {
        setupRestContext();
        Account testAccount = AccountTestFactory.createAccount();
        // Custom Setting stuffs
        InAppRestSettings__c cSettings = new InAppRestSettings__c();
        cSettings.Name = 'defaultz';
        cSettings.Converted_Contact_Opp_Stage__c = 'Received / Prospecting';
        cSettings.Default_Lead_Converted_Status__c = 'Qualified - New Opportunity';
        cSettings.Web_Trial_Campaign_ID__c = '70160000000FBCW';
        cSettings.Lead_Disqualified_Status__c = 'Disqualified';
        cSettings.Web_Trial_Owner_Roles_To_Reassign__c = 'SDR;Sales Development Rep;';
        cSettings.Web_Trial_Reassign_To_User_ID__c = '00560000001HN53';
        insert cSettings;

        InAppRestSettings__c settings        = InAppRestSettings__c.getInstance('defaultz');
        String CONVERTED_CONTACT_OPP_STAGE   = settings.Converted_Contact_Opp_Stage__c;
        String DEFAULT_LEAD_CONVERTED_STATUS = settings.Default_Lead_Converted_Status__c;
        String WEB_TRIAL_CAMPAIGN_ID         = settings.Web_Trial_Campaign_ID__c;
        String LEAD_STATUS_DISQUALIFIED      = settings.Lead_Disqualified_Status__c;
        String OWNER_ROLES_TO_REASSIGN       = settings.Web_Trial_Owner_Roles_To_Reassign__c;
        String REASSIGN_TO_ID                = settings.Web_Trial_Reassign_To_User_ID__c;

        List<String> roles = OWNER_ROLES_TO_REASSIGN.split(';');
        String roleName = '%' + roles[0] + '%';
        User u = [SELECT Id FROM User WHERE UserRole.Name LIKE :roleName LIMIT 1];

        System.debug(System.LoggingLevel.ERROR, '------------' + roleName);
        System.debug(System.LoggingLevel.ERROR, '------------' + u.Id);

        // TO DO: implement unit test
        Decimal randomNumDecimal = Math.random() * 1000000000.0;
        randomNum = String.valueOf(randomNumDecimal.intValue());

        Contact c = ContactTestFactory.createContact( testAccount );

        wt = new WebTrialRest.WebTrial();
        wt.readOnly              = false;
        wt.email                 = 'test' + randomNum + '@box.com';
        wt.isDeactivated         = false;
        wt.isBlocked             = false;
        wt.trialEnd              = TRIAL_END;
        wt.enterpriseId          = randomNum;
        wt.seatsSold             = 100;
        wt.gbSold                = 100;
        wt.lastPaymentDate       = null;
        wt.subscriptionStatus    = ZUORA_SUBSCRIPTION_STATUS_ACTIVE;
        wt.arr                   = 100;
        wt.paymentMethodType     = ZUORA_PAYMENT_METHOD_CREDIT_CARD;
        wt.billingPeriod         = 'Three Years';
        wt.lastTransactionStatus = ZUORA_LAST_TRANSACTION_APPROVED;
        wt.currencyIsoCode       = 'USD';
        wt.isBlocked             = true;

        // Standard test
        // System.debug('WebTrialRestTest standard test case...');
        // WebTrialRest.WebTrial wtResult = WebTrialRest.processWebTrial(wt);

        // Test for lead dupes
        System.debug('WebTrialRestTest duplicate lead test case...');
        String randomNum2 = String.valueOf((randomNumDecimal + 1).intValue());

        wt.enterpriseId       = randomNum2;
        wt.email              = 'test' + randomNum2 + '@box.com';
        wt.subscriptionStatus = null;
        wt.isDeactivated      = true;
        WebTrialRest.resetWebTrialApi();

        Lead l                 = new Lead();
        l.OwnerId              = u.Id;
        l.LastName             = 'Taco';
        l.Company              = 'Bell';
        l.Box_Enterprise_ID__c = randomNum2;
        insert l;
    }

    @isTest(SeeAllData=true)
    static void myUnitTest() {
        
        setup();
        Test.startTest();
        WebTrialRest.WebTrial wtResultLeadDupe = WebTrialRest.processSingleWebTrial(wt);
        Test.stopTest();

        
    }

    @isTest(SeeAllData=true) 
    static void test2() {
        // Test for contact dupes
        setUp();
        System.debug('WebTrialRestTest duplicate contact test case...');

        wt.lastTransactionStatus = 'hehehehhee';
        wt.subscriptionStatus    = ZUORA_SUBSCRIPTION_STATUS_ACTIVE;
        wt.billingPeriod         = ZUORA_BILLING_MONTHLY;
        wt.isDeactivated         = false;
        wt.email                 = 'test' + randomNum + '@box.com';
        wt.enterpriseId          = randomNum;
        Test.startTest();
        WebTrialRest.resetWebTrialApi();
        WebTrialRest.WebTrial wtResultContactDupe = WebTrialRest.processSingleWebTrial(wt);
        Test.stopTest();
    }

    static WebTrialRest.WebTrial createWebtrial() {
        wt = new WebTrialRest.WebTrial();
        wt.readOnly              = false;
        wt.email                 = EMAIL;
        wt.isDeactivated         = false;
        wt.isBlocked             = false;
        wt.trialEnd              = TRIAL_END;
        wt.enterpriseId          = ENTERPRISE_ID;
        wt.seatsSold             = 100;
        wt.gbSold                = 100;
        wt.lastPaymentDate       = null;
        wt.subscriptionStatus    = ZUORA_SUBSCRIPTION_STATUS_ACTIVE;
        wt.arr                   = 100;
        wt.paymentMethodType     = ZUORA_PAYMENT_METHOD_CREDIT_CARD;
        wt.billingPeriod         = 'Three Years';
        wt.lastTransactionStatus = ZUORA_LAST_TRANSACTION_APPROVED;
        wt.lastPaymentStatus     = ZUORA_LAST_PAYMENT_PROCESSED;
        wt.currencyIsoCode       = 'USD';
        wt.isBlocked             = true;

        return wt;
    }

    static testMethod void duplicateLeads_EnterpriseId() {
        setupRestContext();
        setupDefaultCampaign();

        wt = createWebTrial();

        Lead thing1 = LeadTestFactory.buildLead(ENTERPRISE_ID, null);
        Lead thing2 = LeadTestFactory.buildLead(null, EMAIL);
        insert new List<Lead>{thing1, thing2};

        Test.startTest();
            WebTrialRest.WebTrial wtResultLeadDupe = WebTrialRest.processSingleWebTrial(wt);
        Test.stopTest();

        assertNoFailedLogs();

        List<Lead> actualLeads = [
                SELECT Id
                FROM Lead
                WHERE IsConverted = true
        ];

        System.assertEquals(1, actualLeads.size(), 'Only one of the leads should be converted');
        System.assertEquals(thing1.Id, actualLeads[0].Id, 'The lead with the email set should have been converted');
    }

    static testMethod void duplicateLeads_EnterpriseIdAndEmail() {
        setupRestContext();
        setupDefaultCampaign();

        wt = createWebTrial();

        Lead thing1 = LeadTestFactory.buildLead(ENTERPRISE_ID, null);
        Lead thing2 = thing1.clone(false, true);
          thing2.Email = EMAIL;
        insert new List<Lead>{thing1, thing2};

        Test.startTest();
            WebTrialRest.WebTrial wtResultLeadDupe = WebTrialRest.processSingleWebTrial(wt);
        Test.stopTest();

        assertNoFailedLogs();

        List<Lead> actualLeads = [
                SELECT Id
                FROM Lead
                WHERE IsConverted = true
        ];

        System.assertEquals(1, actualLeads.size(), 'Only one of the leads should be converted');
        System.assertEquals(thing2.Id, actualLeads[0].Id, 'The lead with the email should have been converted');
    }

    static testMethod void duplicateLeads_EnterpriseIdAndEmailAndTrialEndDate() {
        setupRestContext();
        setupDefaultCampaign();

        wt = createWebTrial();

        Lead thing1 = LeadTestFactory.buildLead(ENTERPRISE_ID, EMAIL);
        Lead thing2 = thing1.clone(false, true);
        thing2.Trial_End_Date__c = TRIAL_END;

        insert new List<Lead>{thing1, thing2};

        Test.startTest();
            WebTrialRest.WebTrial wtResultLeadDupe = WebTrialRest.processSingleWebTrial(wt);
        Test.stopTest();

        assertNoFailedLogs();

        List<Lead> actualLeads = [
                SELECT Id
                FROM Lead
                WHERE IsConverted = true
        ];

        System.assertEquals(1, actualLeads.size(), 'Only one of the leads should be converted');
        System.assertEquals(thing2.Id, actualLeads[0].Id, 'The lead with the email should have been converted');
    }

    static testMethod void findLeads_matchOnlyEmail() {
        setupRestContext();
        setupDefaultCampaign();

        wt = createWebTrial();

        Lead thing1 = LeadTestFactory.buildLead(null, EMAIL);
        Lead thing2 = LeadTestFactory.buildLead(null, EMAIL + 'x');
        insert new List<Lead>{thing1, thing2};

        Test.startTest();
            WebTrialRest.WebTrial wtResultLeadDupe = WebTrialRest.processSingleWebTrial(wt);
        Test.stopTest();

        assertNoFailedLogs();

        List<Lead> actualLeads = [
                SELECT Id
                FROM Lead
                WHERE IsConverted = true
        ];

        System.assertEquals(1, actualLeads.size(), 'Only one of the leads should be converted');
        System.assertEquals(thing1.Id, actualLeads[0].Id, 'The lead with the email should have been converted');
        //WebTrialRest.mapIdsToLeads(new List<Id>{thing1.Id}, new Map<Id, Lead>{thing1.Id => thing1});
    }

    static testMethod void findLeads_matchOnlyEmailAndTrialEnd() {
        setupRestContext();
        setupDefaultCampaign();

        wt = createWebTrial();

        Lead thing1 = LeadTestFactory.buildLead(null, EMAIL);
        Lead thing2 = thing1.clone(false, true);
        thing2.Trial_End_Date__c = TRIAL_END;

        insert new List<Lead>{thing1, thing2};

        Test.startTest();
            WebTrialRest.WebTrial wtResultLeadDupe = WebTrialRest.processSingleWebTrial(wt);
        Test.stopTest();

        assertNoFailedLogs();

        List<Lead> actualLeads = [
                SELECT Id
                FROM Lead
                WHERE IsConverted = true
        ];

        System.assertEquals(1, actualLeads.size(), 'Only one of the leads should be converted');
        System.assertEquals(thing2.Id, actualLeads[0].Id, 'The lead with the trial end should have been converted');
    }

    static testMethod void testWebTrialConstructor() {
        Test.startTest();

        wt = new WebTrialRest.WebTrial();
        wt.readOnly              = false;
        wt.email                 = EMAIL;
        wt.isDeactivated         = false;
        wt.isBlocked             = false;
        wt.trialEnd              = TRIAL_END;
        wt.enterpriseId          = ENTERPRISE_ID;
        wt.seatsSold             = 100;
        wt.gbSold                = 100;
        wt.lastPaymentDate       = null;
        wt.subscriptionStatus    = ZUORA_SUBSCRIPTION_STATUS_ACTIVE;
        wt.arr                   = 100;
        wt.paymentMethodType     = ZUORA_PAYMENT_METHOD_CREDIT_CARD;
        wt.billingPeriod         = 'Three Years';
        wt.lastTransactionStatus = ZUORA_LAST_TRANSACTION_APPROVED;
        wt.lastPaymentStatus     = ZUORA_LAST_PAYMENT_PROCESSED;
        wt.currencyIsoCode       = 'USD';
        wt.statusCode            = 'status';
        wt.errorMsg              = 'msg';
        wt.sendNotificationToEloqua = true;
        wt.setEnterpriseBlocked     = 'blah';
        wt.opportunityId         = 'opp';
        wt.accountId             = 'acc';
        wt.accountName           = 'name';
        wt.ownerName             = 'owner';
        String payload = JSON.serialize(wt);
        WebTrialRest.WebTrial wtJson = new WebTrialRest.WebTrial(payload);


        Test.stopTest();
    }

    static testMethod void mapZuoraBillingPeriodToOppFeeFrequencyTest_nullString() {
        Test.startTest();
            String result;
            try {
                result = WebTrialRest.mapZuoraBillingPeriodToOppFeeFrequency(null);
            } catch(NullPointerException e) {
                System.assert(false, 'Upon passing a null, we should not get a NullPointer Exception');
            }
        Test.stopTest();

        System.assertEquals(null, result, 'When we pass a null, we expect a null');
    }

    static testMethod void associateWebTrialCampaignTest_contact() {
        Campaign campaign = TestUtils.createCampaign(true);
        Account account = AccountTestFactory.createAccount();
        Contact contact = ContactTestFactory.createContact(account);

        TestUtils.createInAppRestSettings('default', campaign.Id, true);
        WebTrialRest.opp = OpportunityTestFactory.createOpportunity();

        Test.startTest();
            WebTrialRest.associateWebTrialCampaign(null, contact.Id);
        Test.stopTest();

        List<CampaignMember> campaignMembers = [
            SELECT Id, FCRM__FCR_Admin_Response_Control__c, FCRM__FCR_Opportunity__c
            FROM CampaignMember
            WHERE CampaignId = :campaign.Id
            AND ContactId = :contact.Id
        ];

        System.assertEquals(1, campaignMembers.size(), 'When associating a contact to a campaign, there should be 1 campaign member created');
        System.assertEquals( WebTrialRest.ADMIN_RESPONSE_CONTROL_CONTACT, campaignMembers[0].FCRM__FCR_Admin_Response_Control__c, 'The Admin Response Control should be set correctly' );
        System.assertEquals( WebTrialRest.opp.Id, campaignMembers[0].FCRM__FCR_Opportunity__c, 'The campaign member should lookup to the correct opportunity' );
    }

    static testMethod void associateWebTrialCampaignTest_lead() {
        Campaign campaign = TestUtils.createCampaign(true);
        Lead lead = TestUtils.createLead(true);

        TestUtils.createInAppRestSettings('default', campaign.Id, true);
        WebTrialRest.opp = OpportunityTestFactory.createOpportunity();

        Test.startTest();
            WebTrialRest.associateWebTrialCampaign(lead.Id, null);
        Test.stopTest();

        List<CampaignMember> campaignMembers = [
            SELECT Id, FCRM__FCR_Admin_Response_Control__c, FCRM__FCR_Opportunity__c
            FROM CampaignMember
            WHERE CampaignId = :campaign.Id
            AND LeadId = :lead.Id
        ];

        System.assertEquals(1, campaignMembers.size(), 'When associating a lead to a campaign, there should be 1 campaign member created');
        System.assertEquals( WebTrialRest.ADMIN_RESPONSE_CONTROL, campaignMembers[0].FCRM__FCR_Admin_Response_Control__c, 'The Admin Response Control should be set correctly' );
        System.assertEquals( WebTrialRest.opp.Id, campaignMembers[0].FCRM__FCR_Opportunity__c, 'The campaign member should lookup to the correct opportunity' );
    }

    static testMethod void createNewLeadTest() {
        final Date EXPECTED_TRIAL_START_DATE = Date.today().addDays(-15);
        WebTrialRest.WebTrial webTrial = new WebTrialRest.WebTrial();
        webTrial.email = 'tom@tom.tom';
        webTrial.enterpriseId = '0123456789';
        webTrial.readOnly = false;
        webTrial.trialEnd = Date.today();
        webTrial.seatsSold = 10;

        Test.startTest();
            Lead lead = WebTrialRest.createNewLead(webTrial);
        Test.stopTest();

        System.assertNotEquals(null, lead.Id, 'The lead returned should have an Id');
        System.assertEquals(webTrial.email, lead.LastName, 'The lead last name should be set to the webtrial email');
        System.assertEquals(webTrial.email, lead.Email, 'The lead email should be set to the webtrial email');
        System.assertEquals(webTrial.email, lead.Company, 'The lead company should be set to the webtrial email');
        System.assertEquals(WebTrialRest.INDUSTRY_OTHER, lead.Industry, 'The lead industry should be set to the "other" option');
        System.assertEquals(WebTrialRest.PRIOR_ACCOUNT_TYPE_NONE, lead.Prior_Account_Type__c, 'The lead prior account type should be set to the "none" option');
        System.assertEquals(webtrial.enterpriseId, lead.Box_Enterprise_ID__c, 'The lead box enterprise id should be set to the webtrial enterprise id');
        System.assertEquals(webtrial.trialEnd, lead.Trial_End_Date__c, 'The trial end date should be set with the trial end on the request');
        System.assertEquals(webtrial.trialEnd, lead.Trial_End_Date_Copy1__c, 'The trial end date copy1 should be set with the trial end on the request');
        System.assertEquals(webtrial.trialEnd, lead.Trial_End_Date_Copy2__c, 'The trial end date copy2 should be set with the trial end on the request');
        System.assertEquals(webtrial.seatsSold, Integer.valueOf(lead.Initial_Trial_Signup__c), 'Initial trial signup should be set with the seats sold on the request');
        System.assertEquals(lead.Initial_Trial_Signup__c, lead.Initial_Trial_Signup_Copy__c, 'The copy field Initial trial signup should copy correctly' );
        System.assertEquals(EXPECTED_TRIAL_START_DATE, lead.Trial_Start_Date__c, 'The trial start date should be set correctly' );
        System.assertEquals(EXPECTED_TRIAL_START_DATE, lead.Trial_Start_Date_Copy__c, 'The trial start date copy should be set correctly' );
        System.assert(String.isBlank(webtrial.errorMsg), 'There should be no error message for this webtrial');
    }

    static testMethod void createNewLeadTest_readOnly() {
        WebTrialRest.WebTrial webTrial = new WebTrialRest.WebTrial();
        webTrial.email = 'tom@tom.tom';
        webTrial.enterpriseId = '0123456789';
        webTrial.readOnly = true;

        Test.startTest();
            Lead lead = WebTrialRest.createNewLead(webTrial);
        Test.stopTest();

        System.assertEquals(null, lead.Id, 'The lead returned should not have an Id');
        System.assertEquals(webTrial.email, lead.LastName, 'The lead last name should be set to the webtrial email');
        System.assertEquals(webTrial.email, lead.Email, 'The lead email should be set to the webtrial email');
        System.assertEquals(webTrial.email, lead.Company, 'The lead company should be set to the webtrial email');
        System.assertEquals(WebTrialRest.INDUSTRY_OTHER, lead.Industry, 'The lead industry should be set to the "other" option');
        System.assertEquals(WebTrialRest.PRIOR_ACCOUNT_TYPE_NONE, lead.Prior_Account_Type__c, 'The lead prior account type should be set to the "none" option');
        System.assertEquals(webtrial.enterpriseId, lead.Box_Enterprise_ID__c, 'The lead box enterprise id should be set to the webtrial enterprise id');
        System.assertEquals(WebTrialRest.ERRORMSG_READONLY_WEBTRIAL, webtrial.errorMsg, 'The error message should state that the webtrial is in read only mode');
    }

    static testMethod void createOpportunityFromContactTest() {
        WebTrialRest.WebTrial webTrial = new WebTrialRest.WebTrial();
        webTrial.trialEnd = Date.today();

        Account account = AccountTestFactory.createAccount();
        Contact contact = ContactTestFactory.buildContact(account);
        contact.Trial_Type__c = 'Test Trial';
        contact.Trial_Start_Date__c = Date.Today();
        contact.Trial_End_Date__c = Date.Today().addMonths(1);
        contact.Initial_Trial_Signup__c = 'tes';
        insert contact;

        Test.startTest();
            Opportunity opportunity = WebTrialRest.createOpportunityFromContact(webTrial, contact);
        Test.stopTest();

        System.assertNotEquals(null, opportunity.Id, 'The opportunity returned should be in the database');
        System.assertEquals(account.Name, opportunity.Name, 'The opportunity name created from the contact should match the contact\'s account name');
        System.assertEquals(account.Id, opportunity.AccountId, 'The opportunity should be associated to the contact\'s account');
        System.assertEquals(webTrial.trialEnd, opportunity.CloseDate, 'The opportunity close date should match the webtrial end date');
        System.assertEquals( OPP_STAGE_CLOSED_WON, opportunity.StageName, 'The stage should be set correcdtly' );
        System.assertEquals( contact.Trial_Type__c, opportunity.Trial_Type__c, 'The opportunity trial type should match the corresponding contact field');
        System.assertEquals( contact.Trial_Start_Date__c, opportunity.Trial_Start_Date__c, 'The opportunity trial start date should match the corresponding contact field');
        System.assertEquals( contact.Trial_End_Date__c, opportunity.Trial_End_Date__c, 'The opportunity trial end date should match the corresponding contact field');
        System.assertEquals( contact.Initial_Trial_Signup__c, opportunity.Initial_Trial_Signup__c, 'The opportunity initial trial signup should match the corresponding contact field');

        List<OpportunityContactRole> opportunityContactRoles = [
            SELECT Id
            FROM OpportunityContactRole
            WHERE ContactId = :contact.Id
            AND OpportunityId = :opportunity.Id
            AND IsPrimary = true
        ];
        System.assertEquals(1, opportunityContactRoles.size(), 'There should be one opportunity contact role for the opportunity created and the contact from which we created the opportunity');
    }

    static testMethod void testProcessSingleWebTrial_Failure()
    {
        setupRestContext();
        Test.startTest();
            WebTrialRest.processSingleWebTrial( null );
        Test.stopTest();

        List<Web_Trial_Log__c> actualLog = [ SELECT Success__c FROM Web_Trial_Log__c ];

        System.assertEquals( 1, actualLog.size(), 'A web trial log should have been created' );
        System.assert( !actualLog[0].Success__c, 'The web trial log should not be marked a success' );
    }

    static testMethod void TestDeserializeWebTrial()
    {
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        String requestBody = 'Blarg';
        request.requestBody = Blob.valueOf( requestBody );
        RestContext.request = request;
        wt = new WebTrialRest.WebTrial();
    }
    
    static testMethod void testFindOrCreateOpp_ContactFound()
    {
        Campaign campaign = TestUtils.createCampaign(true);
        TestUtils.createInAppRestSettings('default', campaign.Id, true);
        
        final String CONTACT_EMAIL = 't3st3@t3st.c0m';
        Contact testContact = ContactTestFactory.buildContact( AccountTestFactory.createAccount() );
        testContact.email = CONTACT_EMAIL;
        insert testContact;
        
        WebTrialRest.wt = new WebTrialRest.WebTrial();
        WebTrialRest.wt.email = CONTACT_EMAIL;
        WebTrialRest.wt.trialEnd = Date.Today();
        
        Test.startTest();
            WebTrialRest.findOrCreateOpp();
        Test.stopTest();
        
        Contact updatedContact = [SELECT Trial_End_Date__c, FCRM__FCR_Status__c FROM Contact WHERE Id = :testContact.Id ];
        System.assertEquals( WebTrialRest.CONTACT_STATUS_PENDING, updatedContact.FCRM__FCR_Status__c, 'The FCRM status field on the contact should be updated correctly' );
        System.assertEquals( WebTrialRest.wt.trialEnd, updatedContact.Trial_End_Date__c, 'The trial end date on the contact should be updated correctly' );
    }

    static testMethod void testFindExistingOpp() {

        Opportunity nonWebTrial = OpportunityTestFactory.buildOpportunity();
        nonWebTrial.Box_Enterprise_ID__c = ENTERPRISE_ID;
        nonWebTrial.Web_Trial__c = false;

        Opportunity webTrial = nonWebTrial.clone(false, true);
        webTrial.Web_Trial__c = true;

        insert new List<Opportunity>{nonWebTrial, webTrial};

        WebTrialRest.wt = new WebTrialRest.WebTrial();
        WebTrialRest.wt.enterpriseId = ENTERPRISE_ID;

        Test.startTest();
            Opportunity actualOpportunity = WebTrialRest.findExistingOpp();
        Test.stopTest();

        System.assertEquals(webTrial.Id, actualOpportunity.Id, 'The web trial opportunity should be returned');
    }

    static testMethod void testFindExistingOpp_ClosedLostWithinLast30Days() {

        Opportunity webTrial = OpportunityTestFactory.buildOpportunity();
        webTrial.Box_Enterprise_ID__c = ENTERPRISE_ID;
        webTrial.Web_Trial__c = true;
        webTrial.StageName = WebTrialRest.OPP_STAGE_CLOSED_LOST;
        webTrial.CloseDate = Date.today();
        insert webTrial;

        WebTrialRest.wt = new WebTrialRest.WebTrial();
        WebTrialRest.wt.enterpriseId = ENTERPRISE_ID;

        Test.startTest();
            Opportunity actualOpportunity = WebTrialRest.findExistingOpp();
        Test.stopTest();

        System.assertEquals(webTrial.Id, actualOpportunity.Id, 'The web trial opportunities closed within the last 30 days should be returned' );
    }

    static testMethod void testFindExistingOpp_ClosedLostGreaterThan30DaysAgo() {

        Opportunity webTrial = OpportunityTestFactory.buildOpportunity();
        webTrial.Box_Enterprise_ID__c = ENTERPRISE_ID;
        webTrial.Web_Trial__c = true;
        webTrial.StageName = WebTrialRest.OPP_STAGE_CLOSED_LOST;
        webTrial.CloseDate = Date.today().addDays( -31 );
        insert webTrial;

        WebTrialRest.wt = new WebTrialRest.WebTrial();
        WebTrialRest.wt.enterpriseId = ENTERPRISE_ID;

        Test.startTest();
            Opportunity actualOpportunity = WebTrialRest.findExistingOpp();
        Test.stopTest();

        System.assertEquals( null, actualOpportunity, 'No opportunity should be return when the opportunity is closed more than 30 days ago' );
    }

    static testMethod void testFindExistingContact() {
        Contact thing = ContactTestFactory.buildContact();
        thing.Email = EMAIL;
        insert thing;

        WebTrialRest.wt = new WebTrialRest.WebTrial();
        WebTrialRest.wt.email = EMAIL;
        WebTrialRest.wt.enterpriseId = ENTERPRISE_ID;

        Test.startTest();
            Contact actualContact = WebTrialRest.findExistingContact();
        Test.stopTest();

        System.assertEquals(thing.Id, actualContact.Id, 'The contact should have been found by the email');
    }

    static testMethod void testMatchMultipleContacts_findByEntepriseId() {
        Contact woEID = ContactTestFactory.buildContact();
        woEID.FirstName = 'woEID';
        woEID.Email = EMAIL;

        Contact wEID = woEID.clone(false, true);
        wEID.FirstName = 'wEID';
        wEID.Box_Enterprise_ID__c = ENTERPRISE_ID;

        Contact imposterEID = woEID.clone(false, true);
        imposterEID.FirstName = 'imposterEID';
        imposterEID.Box_Enterprise_ID__c = ENTERPRISE_ID + 'x';

        Test.startTest();
            Contact matched = WebTrialRest.matchMultipleContacts(new List<Contact>{woEID, wEID, imposterEID}, ENTERPRISE_ID);
        Test.stopTest();

        System.assertNotEquals(null, matched, 'There should be a result returned');
        System.assertEquals(wEID.FirstName, matched.FirstName, 'The contact with the matching enterprise id should be returned');
    }

    static testMethod void testMatchMultipleContacts_findByEarliestActiveTrial() {
        Date TODAY = Date.today();

        Contact noActiveTrial = ContactTestFactory.buildContact();
        noActiveTrial.FirstName = 'noActiveTrial';
        noActiveTrial.Trial_Start_Date__c = null;

        Contact earliestActiveTrial = ContactTestFactory.buildContact();
        earliestActiveTrial.FirstName = 'earliestActiveTrial';
        earliestActiveTrial.Trial_Start_Date__c = TODAY.addDays(-2);

        Contact laterActiveTrial = ContactTestFactory.buildContact();
        laterActiveTrial.FirstName = 'laterActiveTrial';
        laterActiveTrial.Trial_Start_Date__c = TODAY.addDays(-1);

        Test.startTest();
            Contact matched = WebTrialRest.matchMultipleContacts(new List<Contact>{noActiveTrial, earliestActiveTrial, laterActiveTrial}, ENTERPRISE_ID);
        Test.stopTest();

        System.assertNotEquals(null, matched, 'There should be a result returned');
        System.assertEquals(earliestActiveTrial.FirstName, matched.FirstName, 'The contact with the earliest trial start date should be returned');
    }

    static testMethod void testMatchMultipleContacts_findByEarliestCreatedDate() {
        Contact earliestContact = (Contact)JSON.deserialize('{"attributes":{"type":"Contact"},"FirstName":"earliest","CreatedDate":"2012-10-04T17:54:26.000+0000"}', Contact.class);
        Contact laterContact = (Contact)JSON.deserialize('{"attributes":{"type":"Contact"},"FirstName":"later","CreatedDate":"2012-11-04T17:54:26.000+0000"}', Contact.class);

        Test.startTest();
            Contact matched = WebTrialRest.matchMultipleContacts(new List<Contact>{laterContact, earliestContact}, ENTERPRISE_ID);
        Test.stopTest();

        System.assertNotEquals(null, matched, 'There should be a result returned');
        System.assertEquals(earliestContact.FirstName, matched.FirstName, 'The contact with the earliest created date should be returned');
    }

    static testMethod void testprocessClosedLostWebTrialRequest_openOpportunityFound()
    {
        Opportunity webTrialOpp = OpportunityTestFactory.buildOpportunity();
        webTrialOpp.Box_Enterprise_ID__c = ENTERPRISE_ID;
        webTrialOpp.Web_Trial__c = true;
        insert webTrialOpp;

        WebTrialRest.wt = new WebTrialRest.WebTrial();
        WebTrialRest.wt.enterpriseId = ENTERPRISE_ID;

        Test.startTest();
            WebTrialRest.processClosedLostWebTrialRequest();
        Test.stopTest();

        Opportunity updatedWebTrialOpp = [SELECT StageName FROM Opportunity WHERE Id = :webTrialOpp.Id ];

        System.assertEquals( WebTrialRest.OPP_STAGE_CLOSED_LOST, updatedWebTrialOpp.StageName, 'The web trial should be updated to the correct stage' );
    }

    static testMethod void testprocessClosedLostWebTrialRequest_closedOpportunityFound()
    {
        Opportunity webTrialOpp = OpportunityTestFactory.buildOpportunity();
        webTrialOpp.Box_Enterprise_ID__c = ENTERPRISE_ID;
        webTrialOpp.Web_Trial__c = true;
        webTrialOpp.StageName = WebTrialRest.OPP_STAGE_CLOSED_LOST;
        webTrialOpp.CloseDate = Date.today();
        insert webTrialOpp;

        WebTrialRest.wt = new WebTrialRest.WebTrial();
        WebTrialRest.wt.enterpriseId = ENTERPRISE_ID;

        CustomException expectedException;
        Test.startTest();
            try
            {
                WebTrialRest.processClosedLostWebTrialRequest();
            }
            catch( CustomException ex )
            {
                expectedException = ex;
            }
        Test.stopTest();
        System.assertNotEquals( null, expectedException, 'An exception should have been thrown if a closed opportunity was found' );
    }

    static testMethod void testProcessClosedLostWebTrialRequest_noOpportunityContactFound()
    {
        final String CONTACT_EMAIL = 'strongbad@sbemail.com';

        Account account = AccountTestFactory.createAccount();
        Contact contact = ContactTestFactory.buildContact(account);
        contact.Email = CONTACT_EMAIL;
        insert contact;

        WebTrialRest.wt = new WebTrialRest.WebTrial();
        WebTrialRest.wt.email = CONTACT_EMAIL;
        WebTrialRest.wt.enterpriseId = ENTERPRISE_ID;
        WebTrialRest.webTrialLogModel = new WebTrialLogModel( new Web_Trial_Log__c() );

        Test.startTest();
            WebTrialRest.processClosedLostWebTrialRequest();
        Test.stopTest();
        
        Contact actualContact = [SELECT FCRM__FCR_Status__c, Disqualified_Reason__c, Trial_End_Date__c, Box_Enterprise_ID__c FROM Contact WHERE Id = :contact.Id];
        System.assertEquals(WebTrialRest.CONTACT_STATUS_DISQUALIFIED, actualContact.FCRM__FCR_Status__c, 'The status should be set to disqualified');
        System.assertEquals(WebTrialRest.CONTACT_DISQUALIFIED_REASON, actualContact.Disqualified_Reason__c, 'The status should be set to ' + WebTrialRest.CONTACT_DISQUALIFIED_REASON);
        System.assertEquals(Date.today(), actualContact.Trial_End_Date__c, 'The trial end date should be set today');
        System.assertEquals(ENTERPRISE_ID, actualContact.Box_Enterprise_ID__c, 'The enterprise id from the rest call should be set');
    }
    
    static testMethod void testProcessClosedLostWebTrialRequest_noOpportunityNoContactLeadFound()
    {
        final String LEAD_EMAIL = 'strongbad@sbemail.com';
        
        WebTrialRest.wt = new WebTrialRest.WebTrial();
        WebTrialRest.wt.enterpriseId = ENTERPRISE_ID;
        WebTrialRest.wt.email = LEAD_EMAIL;
        WebTrialRest.webTrialLogModel = new WebTrialLogModel( new Web_Trial_Log__c() );
        Lead lead = TestUtils.createLead(false);
        lead.Email = LEAD_EMAIL;
        insert lead;

        Test.startTest();
            WebTrialRest.processClosedLostWebTrialRequest();
        Test.stopTest();

        Lead actualLead = [SELECT Status, Disqualified_Reason__c, Trial_End_Date__c, Box_Enterprise_ID__c FROM Lead WHERE Id = :lead.Id];
        System.assertEquals(WebTrialRest.LEAD_STATUS_DISQUALIFIED, actualLead.Status, 'The status should be set to disqualified');
        System.assertEquals(WebTrialRest.LEAD_DISQUALIFIED_REASON, actualLead.Disqualified_Reason__c, 'The status should be set to ' + WebTrialRest.LEAD_DISQUALIFIED_REASON);
        System.assertEquals(Date.today(), actualLead.Trial_End_Date__c, 'The trial end date should be set today');
        System.assertEquals(ENTERPRISE_ID, actualLead.Box_Enterprise_ID__c, 'The enterprise id from the rest call should be set');
    }
    
    static testMethod void testProcessClosedLostWebTrialRequest_noOpportunityNoContactNoLeadFound()
    {
        Campaign campaign = TestUtils.createCampaign(true);
        TestUtils.createInAppRestSettings('default', campaign.Id, true);
        WebTrialRest.wt = new WebTrialRest.WebTrial();
        WebTrialRest.wt.enterpriseId = ENTERPRISE_ID;
        WebTrialRest.wt.email = 't3st@t3st.com';
        WebTrialRest.webTrialLogModel = new WebTrialLogModel( new Web_Trial_Log__c() );

        Test.startTest();
            WebTrialRest.processClosedLostWebTrialRequest();
        Test.stopTest();

        List<Lead> actualLead = [SELECT Status, Disqualified_Reason__c, Trial_End_Date__c, Box_Enterprise_ID__c FROM Lead];
        System.assertEquals( 1, actualLead.size(), 'Only one new lead should have been created' );
        System.assertEquals(WebTrialRest.LEAD_STATUS_DISQUALIFIED, actualLead[0].Status, 'The status should be set to disqualified');
        System.assertEquals(WebTrialRest.LEAD_DISQUALIFIED_REASON, actualLead[0].Disqualified_Reason__c, 'The status should be set to ' + WebTrialRest.LEAD_DISQUALIFIED_REASON);
        System.assertEquals(Date.today(), actualLead[0].Trial_End_Date__c, 'The trial end date should be set today');
        System.assertEquals(ENTERPRISE_ID, actualLead[0].Box_Enterprise_ID__c, 'The enterprise id from the rest call should be set');
        
        List<CampaignMember> campaignMembers = [
            SELECT Id, FCRM__FCR_Admin_Response_Control__c, FCRM__FCR_Opportunity__c
            FROM CampaignMember
            WHERE CampaignId = :campaign.Id
            AND LeadId = :actualLead[0].Id
        ];

        System.assertEquals(1, campaignMembers.size(), 'When associating a lead to a campaign, there should be 1 campaign member created');
        System.assertEquals( WebTrialRest.ADMIN_RESPONSE_CONTROL, campaignMembers[0].FCRM__FCR_Admin_Response_Control__c, 'The Admin Response Control should be set correctly' );
        WebTrialRest.wt = new WebTrialRest.WebTrial();
        WebTrialRest.wt.enterpriseId = ENTERPRISE_ID;
    }
    
    static testMethod void testProcessResponseIfFound_noResponses()
    {
        Campaign campaign = TestUtils.createCampaign(true);
        TestUtils.createInAppRestSettings('default', campaign.Id, true);
        Account account = AccountTestFactory.createAccount();
        Contact contact = ContactTestFactory.createContact(account);

        Test.startTest();
            Boolean responsesFound = WebTrialRest.processResponseIfFound( contact.Id );
        Test.stopTest();

        System.assertEquals( false, responsesFound, 'False should be returned if no responses were found' );
    }
    

    static testMethod void testUpdateLeadTrialEndDate()
    {
        final Date EXPECTED_TRIAL_END_DATE = Date.today();

        WebTrialRest.wt = new WebTrialRest.WebTrial();
        WebTrialRest.wt.trialEnd = EXPECTED_TRIAL_END_DATE;
        Lead lead = TestUtils.createLead(true);

        Test.startTest();
            WebTrialRest.updateLeadTrialEndDate( lead );
        Test.stopTest();

        Lead updatedLead = [SELECT Trial_End_Date__c FROM Lead WHERE Id = :lead.Id ];
        System.assertEquals( EXPECTED_TRIAL_END_DATE, lead.Trial_End_Date__c, 'The trial end date should be set properly from the web trial JSON request' );
    }

    static testMethod void testDisqualifyContact()
    {
        Account account = AccountTestFactory.createAccount();
        Contact contact = ContactTestFactory.createContact(account);
        WebTrialRest.wt = new WebTrialRest.WebTrial();
        WebTrialRest.wt.enterpriseId = ENTERPRISE_ID;
        WebTrialRest.webTrialLogModel = new WebTrialLogModel( new Web_Trial_Log__c() );

        Test.startTest();
            WebTrialRest.disqualifyContact(contact);
        Test.stopTest();

        Contact actualContact = [SELECT FCRM__FCR_Status__c, Disqualified_Reason__c, Trial_End_Date__c, Box_Enterprise_ID__c FROM Contact WHERE Id = :contact.Id];
        System.assertEquals(WebTrialRest.CONTACT_STATUS_DISQUALIFIED, actualContact.FCRM__FCR_Status__c, 'The status should be set to disqualified');
        System.assertEquals(WebTrialRest.CONTACT_DISQUALIFIED_REASON, actualContact.Disqualified_Reason__c, 'The status should be set to ' + WebTrialRest.CONTACT_DISQUALIFIED_REASON);
        System.assertEquals(Date.today(), actualContact.Trial_End_Date__c, 'The trial end date should be set today');
        System.assertEquals(ENTERPRISE_ID, actualContact.Box_Enterprise_ID__c, 'The enterprise id from the rest call should be set');
        System.assertEquals( contact.Id, WebTrialRest.webTrialLogModel.currentLog.Contact__c, 'The contact id should be set in the web trial log' );
    }

    static testMethod void testDisqualifyLead()
    {
        WebTrialRest.wt = new WebTrialRest.WebTrial();
        WebTrialRest.wt.enterpriseId = ENTERPRISE_ID;
        WebTrialRest.webTrialLogModel = new WebTrialLogModel( new Web_Trial_Log__c() );
        Lead lead = TestUtils.createLead(true);

        Test.startTest();
            WebTrialRest.disqualifyLead(lead);
        Test.stopTest();

        Lead actualLead = [SELECT Status, Disqualified_Reason__c, Trial_End_Date__c,
                                  Trial_End_Date_Copy1__c, Trial_End_Date_Copy2__c,
                                  Box_Enterprise_ID__c, Box_Enterprise_ID_Copy__c
                           FROM Lead
                           WHERE Id = :lead.Id];
                           
        System.assertEquals(WebTrialRest.LEAD_STATUS_DISQUALIFIED, actualLead.Status, 'The status should be set to disqualified');
        System.assertEquals(WebTrialRest.LEAD_DISQUALIFIED_REASON, actualLead.Disqualified_Reason__c, 'The status should be set to ' + WebTrialRest.LEAD_DISQUALIFIED_REASON);
        System.assertEquals(Date.today(), actualLead.Trial_End_Date__c, 'The trial end date should be set today');
        System.assertEquals( actualLead.Trial_End_Date__c, actualLead.Trial_End_Date_Copy1__c, 'The copy fields of the trial end date should be set correctly' );
        System.assertEquals( actualLead.Trial_End_Date__c, actualLead.Trial_End_Date_Copy2__c, 'The copy fields of the trial end date should be set correctly' );
        System.assertEquals(ENTERPRISE_ID, actualLead.Box_Enterprise_ID__c, 'The enterprise id from the rest call should be set');
        System.assertEquals(ENTERPRISE_ID, actualLead.Box_Enterprise_ID_Copy__c, 'The copy of the enterprise id from the rest call should be set');
        System.assertEquals( lead.Id, WebTrialRest.webTrialLogModel.currentLog.Lead__c, 'The lead id should be set in the web trial log' );
    }

    static void assertNoFailedLogs() {
        List<Web_Trial_Log__c> failures = [
            SELECT Exception_Message__c, errorMsg__c
            FROM Web_Trial_Log__c
            WHERE Success__c = false
        ];

        System.assert(failures.isEmpty(), 'no expected failures should have happened: ' + failures);
    }
    
    static testMethod void reassignForbiddenLeadOwnersTest_Reassign()
    {
        WebTrialRest.wt = new WebTrialRest.WebTrial();
        WebTrialRest.wt.statusCode = WebTrialRest.STATUS_CLOSED_WON;
        
        User toReassignFrom = UserTestFactory.buildUserWithProfileAndRole( UserTestFactory.STANDARD_USER_PROFILE.Id, UserTestFactory.BILLING_TEAM_ROLE.Id );
        User toReassignTo = UserTestFactory.buildUserWithProfileAndRole( UserTestFactory.STANDARD_USER_PROFILE.Id, UserTestFactory.HEAD_OF_SALES_ROLE.Id );
        
        System.runAs( TestUtils.ADMIN_USER )
        {
            insert new List<User>{ toReassignFrom, toReassignTo };
            TestUtils.createWebTrialOwnerReassignmentSetting( UserTestFactory.BILLING_TEAM_ROLE.Name, toReassignTo.Id );
        }
        
        Lead lead = TestUtils.createLead(false);
        lead.OwnerId = toReassignFrom.Id;
        insert lead;
        lead = [SELECT OwnerId, Owner.UserRole.Name FROM Lead WHERE Id = :lead.Id ];

        Test.startTest();
            Boolean shouldUpdate = WebTrialRest.reassignForbiddenLeadOwners( lead );
        Test.stopTest();
        
        System.assert( shouldUpdate, 'The lead should be set for updating' );
        System.assertEquals( toReassignTo.Id, lead.OwnerId, 'The lead owner should be reassigned to the correct user based on the custom setting' );
    }
    
    static testMethod void reassignForbiddenLeadOwnersTest_DoNotReassign()
    {
        WebTrialRest.wt = new WebTrialRest.WebTrial();
        WebTrialRest.wt.statusCode = WebTrialRest.STATUS_CLOSED_WON;
        
        User originalOwner = UserTestFactory.buildUserWithProfileAndRole( UserTestFactory.STANDARD_USER_PROFILE.Id, UserTestFactory.BILLING_TEAM_ROLE.Id );
        User toReassignTo = UserTestFactory.buildUserWithProfileAndRole( UserTestFactory.STANDARD_USER_PROFILE.Id, UserTestFactory.HEAD_OF_SALES_ROLE.Id );
        
        System.runAs( TestUtils.ADMIN_USER )
        {
            insert new List<User>{ originalOwner, toReassignTo };
            TestUtils.createWebTrialOwnerReassignmentSetting( 'Fake Role', toReassignTo.Id );
        }
        
        Lead lead = TestUtils.createLead(false);
        lead.OwnerId = originalOwner.Id;
        insert lead;
        lead = [SELECT OwnerId, Owner.UserRole.Name FROM Lead WHERE Id = :lead.Id ];
        
        Test.startTest();
            Boolean shouldUpdate = WebTrialRest.reassignForbiddenLeadOwners( lead );
        Test.stopTest();
        
        System.assertEquals( false, shouldUpdate, 'The lead should not be set for updating' );
        System.assertEquals( originalOwner.Id, lead.OwnerId, 'The lead owner should not be reassigned' );
    }
    
    static Opportunity setupTestOpportunityWithAccount()
    {
        return OpportunityTestFactory.createOpportunity( AccountTestFactory.createAccount() );
    }
    
    static void setupWebTrial( String statusCode )
    {
        WebTrialRest.wt = new WebTrialRest.WebTrial();
        WebTrialRest.wt.trialEnd = Date.Today();
        WebTrialRest.wt.statusCode = statusCode;
    }
    
    static testMethod void processResultsTest_statusClosedWon()
    {
        Opportunity testOpp = setupTestOpportunityWithAccount();
        setupWebTrial( WebTrialRest.STATUS_CLOSED_WON );

        WebTrialRest.opp = [ SELECT Account.Name, Account.Owner.Name FROM Opportunity WHERE Id = :testOpp.Id ];
        
        Test.startTest();
            WebTrialRest.processResults();
        Test.stopTest();
        
        Opportunity updatedOpp = [ SELECT Name, StageName, CloseDate, Web_Trial__c
                                   FROM Opportunity
                                   WHERE Id = :testOpp.Id ];
        
        String expectedOppName = WebTrialRest.opp.Account.Name + WebTrialRest.OPP_NAME_APPEND;
        System.assertEquals( expectedOppName, updatedOpp.Name, 'The Opportunity name should be set correctly' );
        System.assertEquals( WebTrialRest.OPP_STAGE_CLOSED_WON, updatedOpp.StageName, 'The Opportunity stage should be set correctly' );
        System.assertEquals( WebTrialRest.wt.trialEnd, updatedOpp.CloseDate, 'The Opportunity close date should be set correctly' );
        System.assertEquals( true, updatedOpp.Web_Trial__c, 'The Opportunity web trial checkbox should be set correctly' );
        
        System.assertEquals( true, WebTrialRest.wt.sendNotificationToEloqua, 'The web trial should be marked to send notification to Eloqua' );
    }
    
    static testMethod void processResultsTest_statusExtensionPaymentUnprocessed()
    {
        Opportunity testOpp = setupTestOpportunityWithAccount();
        setupWebTrial( WebTrialRest.STATUS_EXTENSION_PAYMENT_UNPROCESSED );

        WebTrialRest.opp = [ SELECT Account.Name, Account.Owner.Name FROM Opportunity WHERE Id = :testOpp.Id ];
        
        Test.startTest();
            WebTrialRest.processResults();
        Test.stopTest();
        
        Opportunity updatedOpp = [ SELECT Name, StageName, CloseDate, Web_Trial__c
                                   FROM Opportunity
                                   WHERE Id = :testOpp.Id ];
        
        String expectedOppName = WebTrialRest.opp.Account.Name + WebTrialRest.OPP_NAME_APPEND;
        System.assertEquals( expectedOppName, updatedOpp.Name, 'The Opportunity name should be set correctly' );
        System.assertEquals( WebTrialRest.OPP_STAGE_CLOSED_WON, updatedOpp.StageName, 'The Opportunity stage should be set correctly' );
        System.assertEquals( WebTrialRest.wt.trialEnd, updatedOpp.CloseDate, 'The Opportunity close date should be set correctly' );
        System.assertEquals( true, updatedOpp.Web_Trial__c, 'The Opportunity web trial checkbox should be set correctly' );
        
        System.assertEquals( true, WebTrialRest.wt.sendNotificationToEloqua, 'The web trial should be marked to send notification to Eloqua' );
    }
    
    static testMethod void processResultsTest_statusClosedLost()
    {
        Opportunity testOpp = setupTestOpportunityWithAccount();
        setupWebTrial( WebTrialRest.STATUS_CLOSED_LOST );

        WebTrialRest.opp = [ SELECT Account.Name, Account.Owner.Name FROM Opportunity WHERE Id = :testOpp.Id ];
        
        Test.startTest();
            WebTrialRest.processResults();
        Test.stopTest();
        
        Opportunity updatedOpp = [ SELECT Name, StageName, CloseDate, Lost_Biz_Reason__c
                                   FROM Opportunity
                                   WHERE Id = :testOpp.Id ];
        
        String expectedOppName = WebTrialRest.opp.Account.Name + WebTrialRest.OPP_NAME_CANCEL_APPEND;
        System.assertEquals( expectedOppName, updatedOpp.Name, 'The Opportunity name should be set correctly' );
        System.assertEquals( WebTrialRest.OPP_STAGE_CLOSED_LOST, updatedOpp.StageName, 'The Opportunity stage should be set correctly' );
        System.assertEquals( WebTrialRest.wt.trialEnd, updatedOpp.CloseDate, 'The Opportunity close date should be set correctly' );
        System.assertEquals( WebTrialRest.OPP_LOST_BIZ_REASON, updatedOpp.Lost_Biz_Reason__c, 'The Opportunity Lost Business Reason should be set correctly' );
    }
    
    static testMethod void processResultsTest_statusCCDeclined_Annual()
    {
        Opportunity testOpp = setupTestOpportunityWithAccount();
        setupWebTrial( WebTrialRest.STATUS_CC_DECLINED );
        WebTrialRest.wt.billingPeriod = WebTrialRest.ZUORA_BILLING_ANNUAL;

        WebTrialRest.opp = [ SELECT Account.Name, Account.Owner.Name FROM Opportunity WHERE Id = :testOpp.Id ];
        
        Test.startTest();
            WebTrialRest.processResults();
        Test.stopTest();
        
        Opportunity updatedOpp = [ SELECT Name, StageName, CloseDate, Lost_Biz_Reason__c
                                   FROM Opportunity
                                   WHERE Id = :testOpp.Id ];
        
        String expectedOppName = WebTrialRest.opp.Account.Name + WebTrialRest.OPP_NAME_DECLINE_APPEND;
        System.assertEquals( expectedOppName, updatedOpp.Name, 'The Opportunity name should be set correctly' );
        System.assertEquals( WebTrialRest.OPP_STAGE_CLOSED_LOST, updatedOpp.StageName, 'The Opportunity stage should be set correctly' );
        System.assertEquals( WebTrialRest.wt.trialEnd, updatedOpp.CloseDate, 'The Opportunity close date should be set correctly' );
        System.assertEquals( WebTrialRest.OPP_LOST_BIZ_REASON, updatedOpp.Lost_Biz_Reason__c, 'The Opportunity Lost Business Reason should be set correctly' );
        System.assertEquals( WebTrialRest.ENTERPRISE_BLOCK, WebTrialRest.wt.setEnterpriseBlocked, 'The Opportunity Enterprise Block should be set correctly' );
    }
    
    static testMethod void processResultsTest_statusCCDeclined_Monthly()
    {
        Opportunity testOpp = setupTestOpportunityWithAccount();
        setupWebTrial( WebTrialRest.STATUS_CC_DECLINED );
        WebTrialRest.wt.billingPeriod = WebTrialRest.ZUORA_BILLING_MONTHLY;

        WebTrialRest.opp = [ SELECT Account.Name, Account.Owner.Name FROM Opportunity WHERE Id = :testOpp.Id ];
        
        Test.startTest();
            WebTrialRest.processResults();
        Test.stopTest();
        
        Opportunity updatedOpp = [ SELECT Name, StageName, CloseDate, Web_Trial__c
                                   FROM Opportunity
                                   WHERE Id = :testOpp.Id ];
        
        String expectedOppName = WebTrialRest.opp.Account.Name + WebTrialRest.OPP_NAME_DECLINE_APPEND;
        System.assertEquals( expectedOppName, updatedOpp.Name, 'The Opportunity name should be set correctly' );
        System.assertEquals( WebTrialRest.OPP_STAGE_CLOSED_WON, updatedOpp.StageName, 'The Opportunity stage should be set correctly' );
        System.assertEquals( WebTrialRest.wt.trialEnd, updatedOpp.CloseDate, 'The Opportunity close date should be set correctly' );
        System.assertEquals( WebTrialRest.ENTERPRISE_BLOCK, WebTrialRest.wt.setEnterpriseBlocked, 'The Opportunity Enterprise Block should be set correctly' );
        System.assertEquals( true, updatedOpp.Web_Trial__c, 'The Opportunity web trial checkbox should be set correctly' );
    }
    
    static testMethod void processResultsTest_statusInactiveWebTrial()
    {
        Opportunity testOpp = setupTestOpportunityWithAccount();
        setupWebTrial( WebTrialRest.STATUS_INACTIVE_WEBTRIAL );

        WebTrialRest.opp = [ SELECT Account.Name, Account.Owner.Name FROM Opportunity WHERE Id = :testOpp.Id ];
        
        Test.startTest();
            WebTrialRest.processResults();
        Test.stopTest();
        
        Opportunity updatedOpp = [ SELECT Name, StageName, CloseDate, Lost_Biz_Reason__c
                                   FROM Opportunity
                                   WHERE Id = :testOpp.Id ];
        
        String expectedOppName = WebTrialRest.opp.Account.Name + WebTrialRest.OPP_NAME_INACTIVE_APPEND;
        System.assertEquals( expectedOppName, updatedOpp.Name, 'The Opportunity name should be set correctly' );
        System.assertEquals( WebTrialRest.OPP_STAGE_CLOSED_LOST, updatedOpp.StageName, 'The Opportunity stage should be set correctly' );
        System.assertEquals( WebTrialRest.wt.trialEnd, updatedOpp.CloseDate, 'The Opportunity close date should be set correctly' );
        System.assertEquals( WebTrialRest.OPP_LOST_BIZ_REASON, updatedOpp.Lost_Biz_Reason__c, 'The Opportunity Lost Business Reason should be set correctly' );
        System.assertEquals( true, WebTrialRest.wt.sendNotificationToEloqua, 'The web trial should be marked to send notification to Eloqua' );
    }
    
    static testMethod void processResultsTest_statusInactiveJunk()
    {
        Opportunity testOpp = setupTestOpportunityWithAccount();
        setupWebTrial( WebTrialRest.STATUS_INACTIVE_JUNK );

        WebTrialRest.opp = [ SELECT Account.Name, Account.Owner.Name FROM Opportunity WHERE Id = :testOpp.Id ];
        
        Test.startTest();
            WebTrialRest.processResults();
        Test.stopTest();
        
        Opportunity updatedOpp = [ SELECT Name, StageName, CloseDate, Lost_Biz_Reason__c
                                   FROM Opportunity
                                   WHERE Id = :testOpp.Id ];
        System.assertEquals( true, WebTrialRest.wt.sendNotificationToEloqua, 'The web trial should be marked to send notification to Eloqua' );
    }
    
    static testMethod void processResultsTest_Fallback()
    {
        Opportunity testOpp = setupTestOpportunityWithAccount();
        setupWebTrial( null );

        WebTrialRest.opp = [ SELECT Account.Name, Account.Owner.Name FROM Opportunity WHERE Id = :testOpp.Id ];
        
        Test.startTest();
            WebTrialRest.processResults();
        Test.stopTest();
        
        Opportunity updatedOpp = [ SELECT Name, StageName, CloseDate, Lost_Biz_Reason__c
                                   FROM Opportunity
                                   WHERE Id = :testOpp.Id ];
        
        String expectedOppName = WebTrialRest.opp.Account.Name + WebTrialRest.OPP_NAME_APPEND;
        System.assertEquals( expectedOppName, updatedOpp.Name, 'The Opportunity name should be set correctly' );
        System.assertEquals( WebTrialRest.OPP_STAGE_CLOSED_LOST, updatedOpp.StageName, 'The Opportunity stage should be set correctly' );
        System.assertEquals( WebTrialRest.wt.trialEnd, updatedOpp.CloseDate, 'The Opportunity close date should be set correctly' );
        System.assertEquals( WebTrialRest.OPP_LOST_BIZ_REASON, updatedOpp.Lost_Biz_Reason__c, 'The Opportunity Lost Business Reason should be set correctly' );
    }
}