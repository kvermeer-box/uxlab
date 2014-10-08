@isTest
private class TaskUpdateLastAccountActivity_test {

  private static String IN_PROGRESS = 'In Progress';
  private static String COMPLETED = 'Completed';
  private static String LOW_PRIORITY = 'Low';
  
  @isTest static void testFullSystem() {
    Id system_user_id = TestDataFactory_hlpr.createUserSimple();
    Account sample_account = new Account(name='Test Account',ownerId=system_user_id);
    insert sample_account;

    // Test that first task updates Last Activity By Owner
    Task first_task = new Task(Priority=LOW_PRIORITY,Status=COMPLETED,whatID=sample_account.Id,
                                ownerId=system_user_id, Subject='Task 1');
    insert first_task;
    sample_account = [SELECT Id, Last_Activity_By_Owner__c
                      FROM Account
                      WHERE Id = :sample_account.Id LIMIT 1];
    first_task = [SELECT Id, Completed_Date_Time__c
                  FROM Task
                  WHERE Id = :first_task.Id LIMIT 1];
    System.assertNotEquals(sample_account.Last_Activity_By_Owner__c,null);
    System.assert(sample_account.Last_Activity_By_Owner__c >= first_task.Completed_Date_Time__c);

    // Test that the second task overtakes first task as Last Activity
    Task second_task = new Task(Priority=LOW_PRIORITY,Status=COMPLETED,whatID=sample_account.Id,
                                ownerId=system_user_id, Subject='Task 2');
    insert second_task;
    second_task = [SELECT Id, Completed_Date_Time__c
                   FROM Task
                   WHERE Id = :second_task.Id LIMIT 1];
    sample_account = [SELECT Id, Last_Activity_By_Owner__c
                      FROM Account
                      WHERE Id = :sample_account.Id LIMIT 1];
    System.assert(sample_account.Last_Activity_By_Owner__c >= second_task.Completed_Date_Time__c);

    // Test that activity not be owner doesn't overtake second activity
    Id other_user_id = TestDataFactory_hlpr.createUser('SDR','NATAM','test1','test+testing@test.com');
    Task other_user_task = new Task(Priority=LOW_PRIORITY,Status=COMPLETED,whatID=sample_account.Id,
                                    ownerId=other_user_id, Subject='Other user task');
    insert other_user_task;
    other_user_task = [SELECT Id, Completed_Date_Time__c
                      FROM Task
                      WHERE Id = :other_user_task.Id LIMIT 1];
    sample_account = [SELECT Id, Last_Activity_By_Owner__c
                      FROM Account
                      WHERE Id = :sample_account.Id LIMIT 1];
    System.assert(sample_account.Last_Activity_By_Owner__c <= other_user_task.Completed_Date_Time__c);
    System.assert(sample_account.Last_Activity_By_Owner__c >= second_task.Completed_Date_Time__c);
    
    // Test that an email Task doesn't overtake second task
    Task email_task = new Task(Priority=LOW_PRIORITY,Status=COMPLETED,whatID=sample_account.Id,
                               ownerId=system_user_id,Subject='Email: test');
    insert email_task;
    email_task = [SELECT Id, Completed_Date_Time__c
                  FROM Task
                  WHERE Id = :email_task.Id LIMIT 1];
    sample_account = [SELECT Id, Last_Activity_By_Owner__c
                      FROM Account
                      WHERE Id = :sample_account.Id LIMIT 1];
    System.assert(sample_account.Last_Activity_By_Owner__c <= email_task.Completed_Date_Time__c);
    System.assert(sample_account.Last_Activity_By_Owner__c >= second_task.Completed_Date_Time__c);

    // Test deletion of second Task, should revert to first task
    DateTime second_task_completed_date_time = second_task.Completed_Date_Time__c;
    delete second_task;
    sample_account = [SELECT Id, Last_Activity_By_Owner__c
                      FROM Account
                      WHERE Id = :sample_account.Id LIMIT 1];
    System.debug('Account: ' + sample_account.Last_Activity_By_Owner__c);
    System.debug('First Task: ' +first_task.Completed_Date_Time__c);
    System.debug('Second Task: ' + second_task_completed_date_time);
    System.assert(sample_account.Last_Activity_By_Owner__c <= second_task_completed_date_time);

    System.assert(sample_account.Last_Activity_By_Owner__c == first_task.Completed_Date_Time__c);
  }
  
}