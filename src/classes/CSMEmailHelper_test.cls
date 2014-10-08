@isTest
private class CSMEmailHelper_test {
  
  @isTest static void updateCSMEmail_basic() {
        User usr = [SELECT Id, Email 
                      FROM User 
                     WHERE isActive = true
                       AND Email != null
                     LIMIT 1];
    Account acc = new Account(Name = 'Test Account', Customer_Success_Manager__c = usr.Id);
        insert acc;

        Opportunity opp = new Opportunity(Name = 'Test Opp', AccountId = acc.Id, StageName = 'Received / Prospecting',
                                          CloseDate = Date.today().addDays(10));

        List<Opportunity> oppList = new List<Opportunity> {opp};

        CSMEmailHelper.updateCSMEmail(oppList, false);

        // Make sure all the opps have the e-mail of the CSM
        for (Opportunity currentOpp : oppList) {
            System.assertEquals(currentOpp.CSM_Email__c, usr.email);
        }
  }
  
  @isTest static void fullTestInsert() {
    User usr = [SELECT Id, Email 
                      FROM User 
                     WHERE isActive = true
                       AND Email != null
                     LIMIT 1];
        Account acc = new Account(Name = 'Test Account', Customer_Success_Manager__c = usr.Id);
        insert acc;

        Opportunity opp = new Opportunity(Name = 'Test Opp', AccountId = acc.Id, StageName = 'Received / Prospecting',
                                          CloseDate = Date.today().addDays(10));

        List<Opportunity> oppList = new List<Opportunity> {opp};

        Test.startTest();
        insert oppList;
        Test.stopTest();

        Opportunity updatedOpp = [SELECT Id, CSM_Email__c
                                    FROM Opportunity
                                   WHERE Id = :opp.Id];

        // Make sure all the opps have the e-mail of the CSM
        System.assertEquals(updatedOpp.CSM_Email__c, usr.email);
  }

    @isTest static void fullTestUpdateAccount() {
        User usr = [SELECT Id, Email 
                      FROM User 
                     WHERE isActive = true
                       AND Email != null
                     LIMIT 1];
        Account acc = new Account(Name = 'Test Account', Customer_Success_Manager__c = usr.Id);
        insert acc;

        Opportunity opp = new Opportunity(Name = 'Test Opp', AccountId = acc.Id, StageName = 'Received / Prospecting',
                                          CloseDate = Date.today().addDays(10));

        List<Opportunity> oppList = new List<Opportunity> {opp};

        insert oppList;

        User otherUser = [SELECT Id, Email
                            FROM User
                           WHERE isActive = true
                             AND Email != null
                             AND Email != :usr.email
                           LIMIT 1];

        acc.Customer_Success_Manager__c = otherUser.Id;
        
        Test.startTest();
        System.debug('Entering Update...');
        CSMEmailHelper.iteration = 0;
        update acc;
        System.debug('Exiting Update...');
        Test.stopTest();

        Opportunity updatedOpp = [SELECT Id, CSM_Email__c
                                    FROM Opportunity
                                   WHERE Id = :opp.Id];

        // Make sure all the opps have the e-mail of the CSM
        System.assertEquals(updatedOpp.CSM_Email__c, otherUser.email);
    }
  
}