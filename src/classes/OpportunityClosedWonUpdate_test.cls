@isTest (SeeAllData=true)
private class OpportunityClosedWonUpdate_test {
  
  private static final Integer OPPS_TO_TEST = 2;
  private static final Integer ACCOUNTS_TO_TEST = 2;
  private static final Integer QUOTES_TO_TEST = 2;

  private static final String OPP_STAGE_NAME = 'Received / Prospecting';
  private static final String CLOSED_WON = 'Closed Won';
  private static final String UK = 'United Kingdom';

  static testMethod void testUpdateBillingCountryClassificationDomestic () {
    testUpdateBillingCountryClassification(true);   
  }

  static testMethod void testUpdateBillingCountryClassificationInternational () {
    testUpdateBillingCountryClassification(false);
  }

  static testMethod void testInsertBillingCountryClassificationInternational()
  {
    Test.startTest();
    Set<ID> opp_ids = TestDataFactory_hlpr.createOpportunities('testOpp_',OPPS_TO_TEST,ACCOUNTS_TO_TEST,
                                                                  0,0,
                                                                  Date.today(),OpportunityClosedWonUpdate_trgr.CLOSED_WON);
    Test.stopTest();
    List<Opportunity> inserted_opps = [SELECT Id, Billing_Country_Classification__c, StageName
                                       FROM Opportunity
                                       WHERE Id in :opp_ids];
    for (Opportunity inserted_opp : inserted_opps)
    {
      System.assertEquals(LocationUtils_hlpr.US_COUNTRY,inserted_opp.Billing_Country_Classification__c);
    }
  }

  private static void testUpdateBillingCountryClassification(Boolean domestic)
  {
    // Create list of opportunities and insert them
    Account acct = new Account(Name = 'Test Account', BillingCountry = 'United States');
    insert acct;
        
    Contact testContact1 = new Contact(LastName = 'Connery', 
                                       AccountId= acct.Id); 
    if (domestic) {
      testContact1.MailingCountry = 'United States';
    }
    else {
      testContact1.MailingCountry = 'United Kingdom';
    }                   
    insert testContact1;
                                
    Opportunity opp = Z_TestUtils.createOpportunity(acct.Id, true);
    zqu__Quote__c quote = Z_TestUtils.createZQuote(opp.Id, true);
    
    quote.zqu__PaymentMethod__c = 'Check';
    quote.zqu__PaymentTerm__c = null;
    quote.zqu__BillToContact__c = testContact1.Id;
    quote.zqu__SoldToContact__c = testContact1.Id;

    update quote;
    // Change StageName to 'Closed Won'
    opp.StageName = OpportunityClosedWonUpdate_trgr.CLOSED_WON;
    opp.Live_ZQuote__c = quote.Id;

    // Update the opps, will fire trigger
    Test.startTest();
    update opp;
    Test.stopTest();

    opp = [SELECT Id, Billing_Country_Classification__c FROM Opportunity WHERE Id = :opp.Id];

    if (domestic) {
        System.assertEquals(LocationUtils_hlpr.US_COUNTRY, opp.Billing_Country_Classification__c);
    }
    else System.assertEquals(LocationUtils_hlpr.NON_US_COUNTRY, opp.Billing_Country_Classification__c);
  }

  static testMethod void testTwoOppsPointingToSameLiveQuote()
  {
    Id opp_owner = TestDataFactory_hlpr.createUserSimple();
    // Create Account
    Account sample_account = new Account(name='Test Account',ownerID=opp_owner,BillingCountry='USA');
    insert sample_account;

    Contact testContact1 = new Contact(LastName = 'Connery', 
                                       AccountId= sample_account.Id,
                                       MailingCountry = 'United States'); 
    insert testContact1;

    // Create Opportunities
    Opportunity quote_owner_opp = new Opportunity(Name='Test Opp 1',OwnerID=opp_owner,CloseDate=Date.today().addDays(1),AccountID=sample_account.Id, 
                                                  Stagename=OPP_STAGE_NAME, Rep_Quota_Relief__c=true);
    Opportunity not_quote_owner_opp = new Opportunity(Name='Test Opp 2',OwnerID=opp_owner,CloseDate=Date.today().addDays(1),AccountID=sample_account.Id, 
                                                  Stagename=OPP_STAGE_NAME, Rep_Quota_Relief__c=true);
    insert new List<Opportunity> {quote_owner_opp,not_quote_owner_opp};

    // Create Quote
    zqu__Quote__c test_quote = Z_TestUtils.createZQuote(quote_owner_opp.Id, true);
    test_quote.zqu__PaymentMethod__c = 'Check';
    test_quote.zqu__PaymentTerm__c = null;
    test_quote.zqu__BillToContact__c = testContact1.Id;
    test_quote.zqu__SoldToContact__c = testContact1.Id;

    update test_quote;

    // Make the quote the live quote for both opps
    quote_owner_opp.Live_ZQuote__c = test_quote.Id;
    not_quote_owner_opp.Live_ZQuote__c = test_quote.Id;
    quote_owner_opp.StageName = CLOSED_WON;
    not_quote_owner_opp.StageName = CLOSED_WON;

    Test.startTest();
    update new List<Opportunity> {quote_owner_opp,not_quote_owner_opp};
    Test.stopTest();

    // Get Updated Opps
    List<Opportunity> updated_opps = [SELECT Id, Name, Billing_Country_Classification__c FROM Opportunity WHERE Id = :quote_owner_opp.Id OR Id = :not_quote_owner_opp.Id];

    // Make sure both opps were changed to quotes Billing Country
    for (Opportunity updated_opp : updated_opps)
    {
      System.debug('Opportunity Name: ' + updated_opp.Name + '; Billing Country: ' + updated_opp.Billing_Country_Classification__c);
      System.assertEquals(LocationUtils_hlpr.US_COUNTRY,updated_opp.Billing_Country_Classification__c);
    }
  }

  static testMethod void testNoQuoteOpp() {
    Id opp_owner = TestDataFactory_hlpr.createUserSimple();
    // Create Account
    Account sample_account = new Account(name='Test Account',ownerID=opp_owner,BillingCountry='United States');
    insert sample_account;

    // Create Opportunities
    Opportunity opp = new Opportunity(Name='Test Opp 1',OwnerID=opp_owner,CloseDate=Date.today().addDays(1),AccountID=sample_account.Id, 
                                                  Stagename=OPP_STAGE_NAME, Rep_Quota_Relief__c=true);
    insert opp;
    opp.StageName = CLOSED_WON;

    Test.startTest();
    update opp;
    Test.stopTest();

    opp = [SELECT Id, Billing_Country_Classification__c FROM Opportunity WHERE Id = :opp.Id];

    System.assertEquals(LocationUtils_hlpr.US_COUNTRY, opp.Billing_Country_Classification__c);

  }

  
}