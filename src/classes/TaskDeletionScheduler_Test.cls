@isTest
private class TaskDeletionScheduler_Test {

    static testMethod void testBatchMethod() {

        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
   
        Task testTask = new Task(Subject ='Test Task', WhatId=testAccount.Id);
        insert testTask;

        TaskDeletionScheduler batchClass = new TaskDeletionScheduler();
            
        Test.startTest();
        Database.executeBatch(batchClass, 1);
        Test.stopTest();

    }
   
    static testMethod void testScheduledMethod() {

        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Task testTask = new Task(Subject ='Test Task', WhatId=testAccount.Id);
        insert testTask;
        
        Test.startTest();

        TaskDeletionScheduler scheduledClass = new TaskDeletionScheduler();

        // This test runs a scheduled job at midnight Sept. 3rd. 2022

        string schedule = '0 0 0 3 9 ? 2022';

        string jobId = system.schedule('Delete Tasks - Testx', schedule, scheduledClass);
 
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