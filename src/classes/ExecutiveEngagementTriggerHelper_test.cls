@isTest
private class ExecutiveEngagementTriggerHelper_test {

     @isTest static void testRiskSync() {
        Account acc = new Account(Name = 'Test Acc');
        insert acc;

        Risk__c newRisk = new Risk__c(Name = 'Test Risk', Account__c = acc.Id, ARR_At_Risk__c = 10000, Contract_End_Date__c = Date.today(), Status__c = 'New', Risk_Level__c = 'Orange', Potential_Impact__c = 'Full churn', Primary_Churn_Reason__c = 'Me');
        insert newRisk;

        Test.startTest();
        Executive_Engagement__c ee = new Executive_Engagement__c(Box_Executive__c = 'Cat', Status__c = 'Pizza', Risk__c = newRisk.Id);
        insert ee;
        Test.stopTest();

        Risk__c requeriedRisk = [SELECT Id, Executive_Engagement_Box_Executive__c, Executive_Engagement_Created_Date__c, Executive_Engagement_Status__c
                                   FROM Risk__c
                                  WHERE Id = :newRisk.Id];
        System.assertEquals(ee.Box_Executive__c, requeriedRisk.Executive_Engagement_Box_Executive__c, 'Risk and EE should be synced');
        System.assertEquals(ee.Status__c, requeriedRisk.Executive_Engagement_Status__c, 'Risk and EE should be synced');
        // Not testing created date right now
     }

}