@isTest (SeeAllData=true) // Use SeeAllData to allow Custom Settings to be accessed
private class OpportunityUpdateSalesDivision_test {
  
  private static final Integer OPPS_TO_TEST = 2;
  private static final Integer ACCOUNTS_TO_TEST = 1;
  private static final Integer QUOTES_TO_TEST = 0;

  @isTest static void testInsertSalesDivisionAndTheater() {

    Test.startTest();
    LimitsDiagnostics_hlpr.printDiagnostics();
    Set<ID> opp_ids = TestDataFactory_hlpr.createOpportunities('testOpp_',OPPS_TO_TEST,ACCOUNTS_TO_TEST,
                                                                  0,QUOTES_TO_TEST,Date.today(),'Prospecting');
    LimitsDiagnostics_hlpr.printDiagnostics();
    Test.stopTest();
    List<Opportunity> opps = [SELECT Id, Sales_Division__c, Theater__c, OwnerID FROM Opportunity where Id in :opp_ids];
    for (Opportunity opp : opps)
    {
      System.assertEquals('Major',opp.Sales_Division__c);
      System.assertEquals('NATAM',opp.Theater__c);
    }

    

  }

  @isTest static void testUpdateSalesDivisionAndTheater()
  {
    Set<ID> opp_ids = TestDataFactory_hlpr.createOpportunities('testOpp_',OPPS_TO_TEST,ACCOUNTS_TO_TEST,
                                                                  0,QUOTES_TO_TEST,Date.today(),'Prospecting');
    List<Opportunity> opps = [SELECT Id, Sales_Division__c, Theater__c, OwnerID FROM Opportunity where Id in :opp_ids];

    // Test change owner (Currently createUser grabs the same user (bad))
    Id test_user_id = '00560000002teOt'; // Adam Johnson NATAM, Renewals
    for (Opportunity opp : opps)
    {
      opp.OwnerId = test_user_id;
    }
    Test.startTest();
    LimitsDiagnostics_hlpr.printDiagnostics();
    update opps;
    LimitsDiagnostics_hlpr.printDiagnostics();
    Test.stopTest();
    List<Opportunity> updated_opps = [Select Id, Sales_Division__c, Theater__c FROM Opportunity where Id = :opp_ids];
    for (Opportunity updated_opp: updated_opps)
    {
      System.assertEquals('Renewal',updated_opp.Sales_Division__c);
      System.assertEquals('NATAM',updated_opp.Theater__c);
    }
  }

}