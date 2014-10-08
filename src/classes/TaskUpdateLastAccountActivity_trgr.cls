public without sharing class TaskUpdateLastAccountActivity_trgr {

  private static final String COMPLETED_STATUS = 'Completed';
  private static final String EMAIL_FLAG = 'Email:';

  // Don't use constructor, static class
  public TaskUpdateLastAccountActivity_trgr() {}

  public static void updateLastActivity(Boolean is_delete,List<Task> old_tasks, List<Task> new_tasks)
  {
    if (!is_delete)
    {
      List<Task> completed_tasks = getCompletedActivities(old_tasks, new_tasks);
      Set<Account> accounts_with_new_completed_task = getAccountsForTasks(completed_tasks);
      updateLastActivityOnAccounts(accounts_with_new_completed_task, completed_tasks);
    }
    else
    {
      updateAccountsWithDeletedTasks(old_tasks);
    }
  }

  /**
  * Method: getCompletedActivities
  * Availibility: private, static
  * Description:
  *   This method, given the Trigger.old and Trigger.new lists as parameters, decides which Tasks
  *   were just completed, and returns all of those newly completed tasks that fulfill the specified criteria.
  *   Currently, this criteria are that the Tasks are not from emails, specified by an 'Email:' starting the
  *   subject of the Task.
  * Inputs:
  *   List<Task> old_tasks  - Trigger.old
  *   List<Task> new_tasks  - Trigger.new
  * Return:
  *   List<Task>            - List of Tasks that were just completed and are were not created by e-mail.
  */
  @TestVisible private static List<Task> getCompletedActivities(List<Task> old_tasks, List<Task> new_tasks)
  {
    List<Task> completed_tasks = new List<Task>();
    // In both after insert and after update triggers, new tasks should be provided
    if (new_tasks == null)
    {
      System.debug('The list of new tasks is null, canceling update.');
      return completed_tasks;
    }

    // After insert
    if (old_tasks == null)
    {
      // Get any task that is closed and fulfills the other criteria
      for (Task new_task : new_tasks)
      {
        System.debug('Considering task: ' + new_task);
        if (new_task.isClosed && ((new_task.Subject == null) || new_task.Subject.indexOfIgnoreCase(EMAIL_FLAG) != 0))
        {
          System.debug('Adding task: ' + new_task);
          completed_tasks.add(new_task);
        }
      }
    }
    // After update 
    else
    {
      List<Task> uncompleted_tasks = new List<Task>();
      // Get all tasks that were changed from not closed to closed and fulfill the criteria
      Map<ID,Task> old_task_map = new Map<ID,Task>(old_tasks);
      for (Task new_task : new_tasks)
      {
        // Criteria 1: Not an email
        if (new_task.Subject != null && new_task.Subject.indexOfIgnoreCase(EMAIL_FLAG) == 0)
          continue;
        // Compare old and new task
        Task old_task = old_task_map.get(new_task.ID);
        if (old_task == null)
          System.debug('No old task for new task: ' + new_task);
        if (new_task.isClosed && (old_task == null || !old_task.isClosed))
          completed_tasks.add(new_task);
        if (old_task != null && old_task.isClosed && !new_task.isClosed)
          uncompleted_tasks.add(new_task);
      }
      // Send the uncompleted tasks off for updating... pretty hacky
      updateAccountsWithDeletedTasks(uncompleted_tasks);
    }

    return completed_tasks;
  }

  /**
  * Method: getAccountsForTasks
  * Availibility: private, static
  * Description: 
  *   This method gets the accounts for the tasks that were just completed.  The account
  *   is only returned if the task was completed by the owner of the account.
  * Inputs:
  *   List<Task> completed_tasks  - List of all the tasks that were just completed.
  * Return:
  *   Set<Account>               - A list containing all the accounts that just had a task completed
  *                                 by its owner.
  */
  private static Set<Account> getAccountsForTasks(List<Task> completed_tasks)
  {
    // If argument provided is null, exit gracefully with an empty map
    if (completed_tasks == null)
    {
      System.debug('Completed Tasks was null! Returning empty account map');
      return new Set<Account>();
    }

    // Get id of all accounts from the tasks
    Set<ID> account_ids_for_completed_tasks = new Set<ID>();
    for (Task completed_task : completed_tasks)
    {
      if (completed_task.AccountID!=null)
        account_ids_for_completed_tasks.add(completed_task.AccountID);
    }

    Set<Account> accounts_with_tasks_completed_by_owner = new Set<Account>();
    // Get the accounts, but only if the task was completed by the account's owner
    if (account_ids_for_completed_tasks != null && account_ids_for_completed_tasks.size() > 0)
    {
      try
      {
        // Get all the accounts associated with the tasks
        List<Account> accounts = [SELECT Id, Last_activity_by_owner__c, OwnerId
                                  FROM Account
                                  WHERE Id in :account_ids_for_completed_tasks];
        Map<ID,Account> account_map = new Map<ID,Account>(accounts);
        // Only add accounts to the return map if the task was completed by the account owner
        for (Task completed_task : completed_tasks)
        {
          // If task doesn't have an account ID, ignore it completly
          if (completed_task.AccountID!=null)
          {
            // Get account for that tasks
            Account account_for_task = account_map.get(completed_task.AccountID);
            if (account_for_task == null)
              System.debug('Account map does not have entry for Task: ' + completed_task);
            else // There is an account of the task
            {
              System.debug('Account Owner: ' + account_for_task.OwnerId);
              System.debug('Task Owner: ' + completed_task.OwnerId);
              // If Account is owned by the task completer, add to the list
              if (account_for_task.OwnerId == completed_task.OwnerId)
                accounts_with_tasks_completed_by_owner.add(account_for_task);
              else
                System.debug('Task was not completed by owner of account!');
            }
          }
        }
      } catch (QueryException e)
      {
        System.debug('QueryException: ' + e.getMessage());
      }
    }
    return accounts_with_tasks_completed_by_owner;
  } 
  
  /**
  * Method: updateLastActivityOnAccounts
  * Availibility: private, static
  * Description:
  *   This method updates the last activity field on all the provided accounts to
  *   the tasks completed date-time.
  * Inputs:
  *   List<Account> accounts      - A list of accounts to update
  *   List<Task> completed_tasks  - List of completed tasks
  * Return:
  *   None
  */
  private static void updateLastActivityOnAccounts(Set<Account> accounts, List<Task> completed_tasks)
  {
    if (accounts == null || accounts.size() <= 0)
    {
      System.debug('Null or empty list of accounts.');
      return;
    }
    Set<Account> accounts_to_update = new Set<Account>();
    //Map<ID,Account> accounts_map = new Map<ID,Account>(accounts);
    List<Account> account_list = new List<Account>();
    account_list.addAll(accounts);
    Map<ID,Account> accounts_map = new Map<ID,Account>(account_list);
    // Update Last Activity By Owner and add to list
    for (Task cur_task: completed_tasks)
    {
      Account cur_account = accounts_map.get(cur_task.AccountID);
      if (cur_account!=null)
      {
        cur_account.Last_Activity_by_Owner__c = cur_task.Completed_Date_Time__c;
        accounts_to_update.add(cur_account);
      }
    }
    
    if (accounts_to_update != null && accounts_to_update.size() > 0)
    {
      // Update accounts
      try {
        List<Account> accounts_to_update_list = new List<Account>();
        accounts_to_update_list.addAll(accounts_to_update);
        update accounts_to_update_list;
      } catch (DMLException e)
      {
        System.debug('DMLException: ' + e.getMessage());
      }
    } else System.debug('No Accounts to Update!');
  }

/**
* Method: updateAccountsWithDeletedTasks
* Availibility: private, static
* Description:
*   This function updates the Last Activity Date field on Accounts for tasks that
*   have been deleted.  Note: This also works for tasks that were changed from completed
*   to not complete.
* Inputs:
*   List<Task> deleted_tasks  - The list of tasks that have been deleted
* Return:
*   None
*/
  private static void updateAccountsWithDeletedTasks(List<Task> deleted_tasks)
  {
    if (deleted_tasks == null || deleted_tasks.size() == 0)
    {
      System.debug('Null or Empty List Provided.');
      return;
    }
    // Create a Set of all accounts associated with these deleted tasks
    Set<ID> deleted_task_account_ids = new Set<ID>();
    for (Task deleted_task : deleted_tasks)
      deleted_task_account_ids.add(deleted_task.accountId);
    
    Map<ID,List<Task>> account_task_map = getAccountToTasksMap(deleted_task_account_ids);
    updateAccountsToReflectMostRecentActivity(account_task_map);
      

  }

  /**
  * Method: getAccountToTasksMap
  * Availibility: private, static
  * Description:
  *   This function takes in a set of account IDs and returns a Map from the account
  *   IDs to all the completed Tasks related to those accounts that aren't emails.
  * Inputs:
  *   Set<ID> account_id_set  - A Set of IDs for the accounts
  * Return:
  *   Map<ID,List<Task>>      - A Map from Account Ids to a list of completed tasks for
  *                             that Account
  */
  private static Map<ID,List<Task>> getAccountToTasksMap(Set<ID> account_id_set)
  {
    Map<ID,List<Task>> account_task_map = new Map<ID,List<Task>>();
    if (account_id_set == null || account_id_set.size() <= 0)
      return account_task_map;
    try {
      // Grab all completed tasks associated with these accounts that aren't emails
      String email_like_clause = EMAIL_FLAG + '%';
      List<Task> all_tasks_on_accounts = [SELECT Id, Status, Completed_Date_Time__c, Subject, AccountId, OwnerId
                                          FROM Task
                                          WHERE Status = :COMPLETED_STATUS
                                          AND AccountID in :account_id_set
                                          AND (NOT Subject LIKE :email_like_clause)];
      Map<ID,Account> account_map = new Map<ID,Account>([SELECT Id, Last_Activity_by_Owner__c, OwnerId
                                                          FROM Account
                                                          WHERE Id in :account_id_set]);
      // Populate account_task_map with a map from account_id to tasks for that account
      // For each account
      for (ID account_id : account_id_set)
      {
        List<Task> tasks_for_account = new List<Task>();
        // Add all completed tasks for that account to list then put the list in the map
        for (Task potential_task : all_tasks_on_accounts)
        {
          Account cur_account = account_map.get(potential_task.AccountId);
          if (potential_task.AccountID == account_id && potential_task.ownerID == cur_account.ownerID)
            tasks_for_account.add(potential_task);
        }
        account_task_map.put(account_id,tasks_for_account);
      }
    } catch (QueryException e)
    {
      System.debug('Query Exception: ' + e);
    }
    return account_task_map;
  }

  /**
  * Method: updateAccountsToReflectMostRecentActivity
  * Availibility: private, static
  * Description:
  *   This function takes a Map from account ids to a list of tasks for that account and updates the
  *   the account to correctly reflect the most recently completed task date.
  * Inputs:
  *   Map<ID,List<Task>> account_to_tasks_map - map from account ids to the tasks for completed tasks
  *                                             for that account
  * Return:
  *   None
  */
  private static void updateAccountsToReflectMostRecentActivity(Map<ID,List<Task>> account_to_tasks_map)
  {
    // Now actually get the accounts
    Map<ID,Account> account_map = new Map<ID,Account>([SELECT Id, Last_Activity_by_Owner__c
                                                       FROM Account
                                                       WHERE Id in :account_to_tasks_map.keySet()]);
    // Now find most recently completed task for each account
    List<Account> accounts_to_update = new List<Account>();
    for (ID account_id : account_to_tasks_map.keySet())
    {
      // Get the account
      Account cur_account = account_map.get(account_id);
      if (cur_account == null)
      {
        System.debug('Account null in map... Sould be an account.');
        cur_account.addError('Something bad happened behind the seens...Contact Sales Systems');
        return;
      }
      // Get the list of tasks for the account
      List<Task> tasks_for_account = account_to_tasks_map.get(account_id);
      if (tasks_for_account == null)
      {
        System.debug('Null list of Tasks for account... Should be length of zero if empty.');
        cur_account.addError('Something bad happened behind the seens...Contact Sales Systems');
        return;
      }
      // Get the most recently completed task from the list
      Task most_recent_task = getMostRecentlyCompletedTask(tasks_for_account);
      // If the most recent task is null, that means there is no non-email completed task
      if (most_recent_task == null)
      {
        System.debug('Adding account: ' + cur_account);
        cur_account.Last_Activity_By_Owner__c = null;
        accounts_to_update.add(cur_account);
      }
      // If the most recent task was completed before the last activity date on the account, update the account
      else if (most_recent_task.Completed_Date_Time__c < cur_account.Last_Activity_By_Owner__c)
      {
        System.debug('Adding account: ' + cur_account);
        cur_account.Last_Activity_By_Owner__c = most_recent_task.Completed_Date_Time__c;
        accounts_to_update.add(cur_account);
      }
    }
    System.debug('Number of accounts to update: ' + accounts_to_update.size());
    if (accounts_to_update.size() > 0)
      update accounts_to_update;
  }

  /**
  * Method: getMostRecentlyCompletedTask
  * Availibility: private, static
  * Description:
  *   Given a list of Tasks, returns the task that was most recently completed.  If there are no tasks
  *   provided, this function returns null.
  * Inputs:
  *   List<Task> tasks_for_account  - List of completed Tasks
  * Return:
  *   Task                          - Most recently completed task, or null if no task is available.
  */
  private static Task getMostRecentlyCompletedTask(List<Task> tasks_for_account)
  {
    Task most_recent_completed_task = null;
    for (Task cur_task : tasks_for_account)
    {
      System.debug('Task: ' + cur_task);
      System.debug('Completed Date/Time: ' + cur_task.Completed_Date_Time__c);
      if (most_recent_completed_task == null)
        most_recent_completed_task = cur_task;
      else
      {
        if (most_recent_completed_task.Completed_Date_Time__c < cur_task.Completed_Date_Time__c)
          most_recent_completed_task = cur_task;
      }
    }
    if (most_recent_completed_task != null)
      System.debug('Completed Date/Time Returned: ' + most_recent_completed_task.Completed_Date_Time__c);
    else System.debug('No Most Recent Completed Task!');
    return most_recent_completed_task;
  }

}