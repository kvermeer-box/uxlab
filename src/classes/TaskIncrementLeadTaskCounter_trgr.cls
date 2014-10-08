public without sharing class TaskIncrementLeadTaskCounter_trgr {
  /* Constants */
  private static final String SDR_STRING = 'SDR';

  /**
  * Empty Contructor
  **/
  public TaskIncrementLeadTaskCounter_trgr() {}

  /**
  * Method: updateLeadTaskCounter
  * Modifiers: public, static
  * Description:
  *   The method takes in a both the old value and new value Lists of the Tasks that fired the trigger.
  *   This method then proceeds to grab the Leads associated with these tasks.  If there are no leads,
  *   the method does nothing.  If there are some leads, the functions checks to see if the fields
  *   SDR_Touches__c and Completed_Tasks__c match the number of tasks on this lead that are owned by
  *   SDRs (and completed for Completed_Tasks__c).  If these numbers are out of sync, this function
  *   updates SDR_Touches__c and Completed_Tasks__c to the appropriate values.
  * Inputs:
  *   Boolean is_delete - true if this is being fired on a delete trigger, false otherwise.
  *   List<Task> old_values - Trigger.old
  *   List<Task> new_values - Trigger.new
  * Return:
  *   None
  */
  public static void updateLeadTaskCounter(boolean is_delete, List<Task> old_values, List<Task> new_values)
  {
    // Get Leads for all updates tasks
    List<Lead> all_leads = getLeads(is_delete,old_values,new_values);
    // Get leads that have their task counters changed
    List<Lead> leads_to_update = getChangedLeads(all_leads);
    
    // Update DML
    if (leads_to_update != null && leads_to_update.size() > 0) {       
      update leads_to_update;
      System.debug('[incrementLeadTaskCounters] ' + leads_to_update.size() + ' leads updated.');
    }   
  }

  /**
  * Method: getLeads
  * Modifiers: private, static
  * Description:
  *   The method takes in a both the old value and new value Lists of the Tasks that fired the trigger.
  *   This method then proceeds to grab and return the Leads associated with these tasks.
  * Inputs:
  *   Boolean is_delete - true if this is being fired on a delete trigger, false otherwise.
  *   List<Task> old_values - Trigger.old
  *   List<Task> new_values - Trigger.new
  * Return:
  *   List<Lead> - List of leads associated with the provided tasks.  If the provided tasks are null or
  *                there was an issue retrieving the leads from the database, null is returned.
  */
  @TestVisible private static List<Lead> getLeads(boolean is_delete, List<Task> old_values, List<Task> new_values)
  {
     // Get a list of all tasks in the trigger
    List<Task> tasks = new List<Task>();
    if (is_delete) tasks = old_values; // Delete triggers will only have an old values
    else tasks = new_values; // Non-Delete triggers should used updated values in new values
    // Return null if tasks is null
    if (tasks == null) 
    {
      System.debug('Tasks list used was null, returning null.');
      return null;
    }
    
    // Get a list of all leads associated to these tasks
    Set<Id> leads_to_check_ids = new Set<Id>();
    for (Task t : tasks) 
      // This filters out non-leads
      if (t.WhatId == null && t.WhoId != null) 
        leads_to_check_ids.add(t.WhoId);

    // Now that we have Ids, get the actual leads
    List<Lead> leads = new List<Lead>();
    try {
      if (leads_to_check_ids != null && leads_to_check_ids.size() > 0)
        leads = [SELECT Id, SDR_Touches__c, Completed_Tasks__c, IsConverted, (SELECT Id, IsClosed, OwnerID FROM Tasks) 
                 FROM Lead 
                 WHERE Id IN :leads_to_check_ids];
    } catch (QueryException e)
    {
      System.debug('QueryException: ' + e.getMessage());
      return null;
    }
    return leads;
  }

  /**
  * Method: getChangedLeads
  * Modifiers: private, static
  * Description:
  *   The method takes a list of leads who's tasks fired the trigger.  These leads are
  *   then checked to see if their SDR_Touches__c field matches the number of Tasks on
  *   the lead that are owned by SDRs.  The also have their Completed_Tasks__c fields checked
  *   for the same criteria, except the Task must be completed.  If the Lead is already 
  *   converted, it is skipped, as converted leads cannot be updated.  It then updates the lead
  *   fields that are out of sync, but does not commit them to the database.  Instead it returns
  *   the list of now in-sync Leads.
  * Inputs:
  *   List<Lead> - Leads associated with the tasks that fired the trigger.
  * Return:
  *   List<Lead> - List of leads that were out of sync and now have their fields updated to be
  *                in-sync.  These leads have no yet been committed to the database.
  */
  @TestVisible private static List<Lead> getChangedLeads(List<Lead> leads)
  {
    List<Lead> changed_leads = new List<Lead>();
    // If null leads list passed in, return null
    if (leads == null) 
    {
      System.debug('Provided leads list was null, returning null.');
      return null;
    }

    // Get user map to find UserRole.Name of owners
    Map<ID, User> userMap = new Map<ID, User>([SELECT Id, UserRole.Name FROM User WHERE (NOT Profile.Name LIKE '%Eventforce%') AND (NOT Profile.Name LIKE '%Chatter%')]);

    for (Lead cur_lead : leads) {   
      // Skip converted leads
      if (cur_lead.isConverted) continue;     
      // Update SDR_Touches__c field
      Integer tasks_owned_by_SDRs = 0;
      Integer task_completed_by_SDRs = 0;
      if (cur_lead.Tasks != null) 
      {
        // Get count of tasks owned by SDRs
        for (Task current_task : cur_lead.Tasks)
        {
          // Check if owner of Task is an SDR
          Id owner_id = current_task.OwnerID;
          User owner = userMap.get(owner_id);
          if (owner == null || owner.UserRole.Name == null) continue;
          String owner_role = owner.UserRole.Name;
          if (owner_role.contains(SDR_STRING)) 
          {
            tasks_owned_by_SDRs++; // If owner is SDR, increment owned counter
            if (current_task.IsClosed)
              task_completed_by_SDRs++; // If owner is SDR and task closed, increment completed counter
          }
        }
        // If SDR_Touches__c or Completed_Tasks__c doesn't match tasks_owned_by_SDRs or task_compelted_by_SDRs, respectively
        if (cur_lead.SDR_Touches__c == null || 
          cur_lead.Completed_Tasks__c == null || 
          tasks_owned_by_SDRs != cur_lead.SDR_Touches__c ||
          task_completed_by_SDRs != cur_lead.Completed_Tasks__c) 
        {
          cur_lead.SDR_Touches__c = tasks_owned_by_SDRs;
          cur_lead.Completed_Tasks__c = task_completed_by_SDRs;
          changed_leads.add(cur_lead);
          System.debug('[incrementLeadTaskCounters] Lead ' + cur_lead.Id + ' new Completed_Tasks__c count: ' + cur_lead.Completed_Tasks__c);
          System.debug('[incrementLeadTaskCounters] Lead ' + cur_lead.Id + ' new SDR_Touches__c count: ' + cur_lead.SDR_Touches__c);
        }
      } 
    }
    return changed_leads;
  }
}