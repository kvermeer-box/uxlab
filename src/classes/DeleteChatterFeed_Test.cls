@isTest
private class DeleteChatterFeed_Test {

    static testMethod void testBatchMethod() {

		Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
		
		Contact testContact = new Contact();
		testContact.FirstName = 'Rob';
		testContact.LastName = 'Smith';
        insert testContact;

		Campaign testCampaign = new Campaign(IsActive = true);
		testCampaign.Name = 'Test Campaign';
		insert testCampaign;
		
		CampaignMember testCampaignMember = new CampaignMember();
		testCampaignMember.CampaignId = testCampaign.Id;
		testCampaignMember.ContactId = testContact.Id;
		insert testCampaignMember;

		FCRM__FCR_Influence_Detail__c testInfluenceDetail = new FCRM__FCR_Influence_Detail__c();
		testInfluenceDetail.FCRM__Response_ID__c = testCampaignMember.Id;
		testInfluenceDetail.FCRM__Account__c = testAccount.Id;
		testInfluenceDetail.FCRM__Contact__c = testContact.Id;
		testInfluenceDetail.FCRM__Campaign__c = testCampaign.Id;
		insert testInfluenceDetail;
 
        DeleteChatterFeed batchClass = new DeleteChatterFeed();
            
        Test.startTest();
        Database.executeBatch(batchClass, 1);
        Test.stopTest();


    }

    static testMethod void testScheduledMethod() {
 
        Test.startTest();

        DeleteChatterFeed scheduledClass = new DeleteChatterFeed();

        // This test runs a scheduled job at midnight Sept. 3rd. 2022

        string schedule = '0 0 0 3 9 ? 2022';

        string jobId = system.schedule('Delete Chatter Feed Test', schedule, scheduledClass);
 
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                FROM CronTrigger WHERE id = :jobId];
 
        // Verify the expressions are the same
        System.assertEquals(schedule, ct.CronExpression); 

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));

        Test.stopTest();

    } 
    
}