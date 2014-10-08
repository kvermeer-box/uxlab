@isTest
private class NAICSUpdater_test {
  
  @isTest static void parseJSONResponse_basic() {
    String simpleJson = '[{ "code" : 1, "title" : "Test Title", "ignore_field" : true }]';
    NAICSUpdater.NAICSResponse response = new NAICSUpdater.NAICSResponse(simpleJson);
    NAICSUpdater.NAICSObject naicsObj = response.getObjectForCode(1);
    System.assert(naicsObj != null);
    System.assertEquals(naicsObj.getTitle(),'Test Title');
  }

  @isTest static void parseJSONResponse_multipleObject() {
    String multipleObjectJson = '[{ "code" : 1, "title" : "Test Title" , "ignore_field" : true }, ' +
                                 '{ "code" : 2, "title" : "Second Test" , "other_ignore_field" : false}]';
    NAICSUpdater.NAICSResponse response = new NAICSUpdater.NAICSResponse(multipleObjectJson);
    NAICSUpdater.NAICSObject naicsObj = response.getObjectForCode(1);
    System.assert(naicsObj != null);
    System.assertEquals(naicsObj.getTitle(),'Test Title'); 
    NAICSUpdater.NAICSObject naicsObjTwo = response.getObjectForCode(2);
    System.assert(naicsObjTwo != null);
    System.assertEquals(naicsObjTwo.getTitle(),'Second Test');            
  }

  @isTest static void parseJSONResponse_2DigitCodeLength() {
    String multipleObjectJson = '[{ "code" : 1, "title" : "Test Title" , "ignore_field" : true }, ' +
                                 '{ "code" : 2, "title" : "Second Test" , "other_ignore_field" : false}, ' +
                                 '{ "code" : 10, "title" : "Code 10 Test"}]';
    NAICSUpdater.NAICSResponse response = new NAICSUpdater.NAICSResponse(multipleObjectJson);
    NAICSUpdater.NAICSObject naicsObj = response.getObjectForCode(1);
    System.assert(naicsObj != null);
    System.assertEquals(naicsObj.getTitle(),'Test Title'); 
    NAICSUpdater.NAICSObject naicsObjTwo = response.getObjectForCode(2);
    System.assert(naicsObjTwo != null);
    System.assertEquals(naicsObjTwo.getTitle(),'Second Test'); 
    NAICSUpdater.NAICSObject naicsObjThree = response.getObjectForCode(10);
    System.assert(naicsObjThree != null);
    System.assertEquals(naicsObjThree.getTitle(),'Code 10 Test');  
    System.assertEquals(naicsObjThree.getCodeLength(),2);          
  }

  @isTest static void getNAICSCodeInfoFromAPI_basic() {
    Account newAccount = new Account(Name = 'Test Account', Primary_NAICS__c = 123456);
    String jsonResponse = getJSONForCode123456();
    DynamicTestValues.setNaicsJSONResponse(jsonResponse);
    NAICSUpdater.NAICSResponse responseObject = NAICSUpdater.getNAICSCodeInfoFromAPI(newAccount);
    System.assertEquals(6,responseObject.getLongestCodeLength());
    System.assertEquals(123456,responseObject.getLongestCode());
    NAICSUpdater.NAICSObject naicsObj6Digit = responseObject.getObjectForCode(123456);
    System.assert(naicsObj6Digit != null);
    System.assertEquals(naicsObj6Digit.getTitle(), '6 digit code');
  }

  @isTest static void updateNAICSFields_nullNAICSCode() {
    Account newAccount = new Account(Name = 'Test Account');
    insert newAccount;
    Account insertedAccount = [SELECT Id, Primary_NAICS__c FROM Account WHERE Id = :newAccount.Id];
    insertedAccount.Primary_NAICS__c = null;
    update insertedAccount;
    Test.startTest();
    String jsonResponse = getJSONForCode123456();
    DynamicTestValues.setNaicsJSONResponse(jsonResponse);
    NAICSUpdater.updateNaicsFields(new Set<Id> {newAccount.Id});
    Test.stopTest();
    Account updatedAccount = [SELECT Id, Primary_NAICS__c
                              FROM Account
                              WHERE Id = :newAccount.Id];
  }

  @isTest static void batchTest_basic() {
    Account accountToUpdate = new Account(Name = 'Test Account', Primary_NAICS__c = 123456, updateNAICSFields__c = true);
    insert accountToUpdate;
    // Set Mock Reponse up
    String jsonResponse = getJSONForCode123456();
    DynamicTestValues.setNaicsJSONResponse(jsonResponse);
    NAICSUpdater_batch batchClass = new NAICSUpdater_batch();
    Test.startTest();
    Database.executeBatch(batchClass);
    Test.stopTest();
    Account accountToUpdateRefreshed = [SELECT Id, Primary_NAICS__c, Industry_2_Digit_NAICS_Code__c,
                                        Industry_4_Digit_NAICS_Code__c, Industry_5_Digit_NAICS_Code__c,
                                        updateNAICSFields__c
                                        FROM Account
                                        WHERE Id = :accountToUpdate.Id
                                        LIMIT 1];
    System.assertEquals(accountToUpdateRefreshed.Industry_2_Digit_NAICS_Code__c,'2 digit code');
  }

  @isTest static void parseJSONResponse_malformedJSON() {
    String badJSON = '@#$K{';
    NAICSUpdater.NAICSResponse response = new NAICSUpdater.NAICSResponse(badJSON);
    List<LoggedException__c> loggedExceptions = [SELECT Id FROM LoggedException__c];
    System.assert(loggedExceptions.size() > 0);
  }

  public static String getJSONForCode123456()
  {
    return '[{ "code" : 123456, "title" : "6 digit code"}, { "code" : 12345, "title" : "5 digit code"}, ' +
           '{ "code" : 1234, "title" : "4 digit code" }, { "code" : 123, "title" : "3 digit code" }, ' +
           '{ "code" : 12, "title" : "2 digit code" }]';
  }
  
}