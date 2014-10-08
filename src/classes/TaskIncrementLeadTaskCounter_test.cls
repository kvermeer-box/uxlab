@isTest
private class TaskIncrementLeadTaskCounter_test {
  
  @isTest static void testGetLeads() 
  {
    Id user_id = TestDataFactory_hlpr.createUser('SDR','NATAM','SDRAlias','sdr@sdr.sdr');
    Lead new_lead = new Lead(Company='Test Co', LastName='Tester', ownerId=user_id);
    Lead other_lead = new Lead(Company='Other Test Co', LastName='OtherLastName',ownerId=user_id);
    List<Lead> new_leads = new Lead[] {new_lead,other_lead};
    insert new_leads;
    Task new_task = new Task(Priority='Low',Status='In Progress',WhoId=new_lead.Id, ownerId=user_id);
    Task other_task = new Task(Priority='Low',Status='In Progress',WhoId=other_lead.Id, ownerId=user_id);
    List<Task> new_tasks = new Task[] {new_task,other_task};
    insert new_tasks;
    List<Lead> leads = TaskIncrementLeadTaskCounter_trgr.getLeads(false,new Task[]{},new_tasks);
    List<Lead> leads_pretend_deleted = TaskIncrementLeadTaskCounter_trgr.getLeads(true,new_tasks,new Task[]{});
    System.assertEquals(leads.size(),2,'Two Leads are associated with the tasks.');
    System.assertEquals(leads_pretend_deleted.size(),2,'Two leads were associated with the tasks that were pretend deleted.');
  }

  @isTest static void testGetLeads_NullInputs()
  {
    Id user_id = TestDataFactory_hlpr.createUser('SDR','NATAM','SDRAlias','sdr@sdr.sdr');
    Lead new_lead = new Lead(Company='Test Co', LastName='Tester', ownerId=user_id);
    insert new_lead;
    Task new_task = new Task(Priority='Low',Status='In Progress',WhoId=new_lead.Id, ownerId=user_id);
    List<Task> new_tasks = new Task[] {new_task};
    insert new_tasks;
    List<Lead> leads = TaskIncrementLeadTaskCounter_trgr.getLeads(false,null,null);
    List<Lead> delete_leads = TaskIncrementLeadTaskCounter_trgr.getLeads(true,null,null);
    System.assertEquals(leads,null,'Null tasks lists provided, should return null.');
    System.assertEquals(delete_leads,null,'Null tasks lists provided, should return null.');
  }

  @isTest static void testGetLeads_EmptyLists()
  {
    List<Task> new_tasks_empty = new Task[]{};
    List<Lead> leads = TaskIncrementLeadTaskCounter_trgr.getLeads(false,new_tasks_empty,new_tasks_empty);
    List<Lead> delete_leads = TaskIncrementLeadTaskCounter_trgr.getLeads(true,new_tasks_empty,new_tasks_empty);
    System.assertEquals(leads.size(),0,'Empty task lists provided, return List should have size 0.');
    System.assertEquals(delete_leads.size(),0,'Empty task lists provided, return List should have size 0.');
  }

  @isTest static void testGetChangedLeads()
  {
    Id user_id = TestDataFactory_hlpr.createUser('SDR','NATAM','SDRAlias','sdr@sdr.sdr');
    Lead new_lead = new Lead(Company='Test Co', LastName='Tester', ownerId=user_id);
    Lead other_lead = new Lead(Company='Other Test Co', LastName='OtherLastName',ownerId=user_id);
    Lead third_lead = new Lead(Company='Third Test Co', LastName='ThirdLastName',ownerId=user_id);
    Lead fourth_lead = new Lead(Company='Fourth Test Co', LastName='FourthLastName',ownerId=user_id);
    List<Lead> new_leads = new Lead[] {new_lead,other_lead,third_lead,fourth_lead};
    insert new_leads;
    Task new_task = new Task(Priority='Low',Status='Completed',WhoId=new_lead.Id, ownerId=user_id);
    Task other_task = new Task(Priority='Low',Status='Completed',WhoId=other_lead.Id, ownerId=user_id);
    Task third_task = new Task(Priority='Low',Status='Completed',WhoId=third_lead.Id, ownerId=user_id);
    Id non_sdr_user = TestDataFactory_hlpr.createUser('Major','NATAM','MajorAl','major@major.major');
    Task fourth_task = new Task(Priority='Low',Status='Completed',WhoId=fourth_lead.Id,ownerId=non_sdr_user);
    List<Task> new_tasks = new Task[] {new_task,other_task,third_task,fourth_task};
    insert new_tasks;
    List<Id> lead_ids = new Id[] {new_lead.Id,other_lead.Id,third_lead.Id,fourth_lead.Id};
    List<Lead> leads = [SELECT Id, SDR_Touches__c, Completed_Tasks__c, IsConverted, (SELECT Id, IsClosed, OwnerID FROM Tasks) 
                        FROM Lead 
                        WHERE Id IN :lead_ids];
    for (Lead cur_lead : leads)
    {
      if (cur_lead.Id==new_lead.Id) cur_lead.SDR_Touches__c = 0;
      if (cur_lead.Id==other_lead.Id) cur_lead.Completed_Tasks__c = 0;
      if (cur_lead.Id==fourth_lead.Id) cur_lead.SDR_Touches__c = 0; // This should not cause a change, as SDR hasn't touched it.
    }
    List<Lead> leads_changed = TaskIncrementLeadTaskCounter_trgr.getChangedLeads(leads);
    System.assertEquals(leads_changed.size(),2,'Two leads were changed, two leads should be returned.');
  }

  @isTest static void testGetChangedLeads_NullInputs()
  {
    List<Lead> leads_changed = TaskIncrementLeadTaskCounter_trgr.getChangedLeads(null);
    System.assertEquals(leads_changed,null,'Null leads list provided, should return null.');
  }

  @isTest static void testGetChangedLeads_ConvertedLead()
  {
    Id user_id = TestDataFactory_hlpr.createUser('SDR','NATAM','SDRAlias','sdr@sdr.sdr');
    Lead new_lead = new Lead(Company='Test Co', LastName='Tester', ownerId=user_id);
    List<Lead> new_leads = new Lead[] {new_lead};
    insert new_leads;
    Task new_task = new Task(Priority='Low',Status='Completed',WhoId=new_lead.Id, ownerId=user_id);
    List<Task> new_tasks = new Task[] {new_task};
    insert new_tasks;
    List<Id> lead_ids = new Id[] {new_lead.Id};
    for (Id cur_lead_id : lead_ids)
    {
      // Convert Lead
      Database.LeadConvert lc = new database.LeadConvert();
      lc.setLeadId(cur_lead_id);
      LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
      lc.setConvertedStatus(convertStatus.MasterLabel);
      Database.LeadConvertResult lcr = Database.convertLead(lc);
    }
    List<Lead> leads = [SELECT Id, SDR_Touches__c, Completed_Tasks__c, IsConverted, (SELECT Id, IsClosed, OwnerID FROM Tasks) 
                        FROM Lead 
                        WHERE Id IN :lead_ids];
    leads[0].SDR_Touches__c = 0;
    List<Lead> leads_changed = TaskIncrementLeadTaskCounter_trgr.getChangedLeads(leads);
    System.assertEquals(leads_changed.size(),0,'All leads input were converted, 0 leads should be returned as changed.');
  }

  
}