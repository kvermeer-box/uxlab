@isTest
private class AccountUpdateSalesDivision_test {
  
  @isTest static void testUpdateSalesDivisionAndTheaterForInsert() 
  {
    Test.startTest();
    LimitsDiagnostics_hlpr.printDiagnostics();
    Id ownerId = TestDataFactory_hlpr.createUser('Major', 'NATAM', 'testt', 'theuntestable@iuobxyfuudsa.com');
    Account curAccount = new Account(Name = 'Test Account', OwnerId = ownerId);
    insert curAccount;
    LimitsDiagnostics_hlpr.printDiagnostics();
    Test.stopTest();
    Account requeriedAccount = [SELECT Id, Sales_Division__c, Theater__c, OwnerID FROM Account where Id = :curAccount.Id];
    System.assertEquals('Major',requeriedAccount.Sales_Division__c);
    System.assertEquals('NATAM',requeriedAccount.Theater__c);
  }

  @isTest static void testUpdateSalesDivisionAndTheaterForUpdate()
  {
    Test.startTest();
    LimitsDiagnostics_hlpr.printDiagnostics();
    Id ownerId = TestDataFactory_hlpr.createUser('Major', 'NATAM', 'testt', 'theuntestable@iuobxyfuudsa.com');
    Account curAccount = new Account(Name = 'Test Account', OwnerId = ownerId);
    insert curAccount;
    update curAccount;
    LimitsDiagnostics_hlpr.printDiagnostics();
    Test.stopTest();
    Account requeriedAccount = [SELECT Id, Sales_Division__c, Theater__c, OwnerID FROM Account where Id = :curAccount.Id];
    System.assertEquals('Major',requeriedAccount.Sales_Division__c);
    System.assertEquals('NATAM',requeriedAccount.Theater__c);
  }
}