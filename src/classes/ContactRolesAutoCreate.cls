// Upon creation of an activity, where the “What” or the Activity “Related To” is an 
// opportunity, and the “Who” is a contact (or multiple contacts) auto-associate the contacts 
// as contact roles to the opportunity. 
public class ContactRolesAutoCreate {
	
	public static Boolean useAsyncProcessing = true;

	public static void autoCreateRequestHandler(Map<Id, Task> taskMap)
	{			
		// Use async api to look for related Contacts on Tasks
        if (Schema.getGlobalDescribe().keySet().contains('taskrelation') && useAsyncProcessing) 
        {
        	List<String> taskIdList = new List<String>();
        	for (String id : taskMap.keySet()) taskIdList.add(id);
            FCRM.FCR_SupportAPI.ScheduleAsyncOperation(
                'ContactRolesAutoCreateAsyncPlugin', 
                Datetime.now().addSeconds(5), 
                String.join(taskIdList, ',')
            );
        }			
        else
        {
        	autoCreate(taskMap);
        }		  		
	}

	public static void autoCreate(Map<Id, Task> taskMap)
	{
		
		Set<Id> relatedOppIds = new Set<Id>();
		Map<Id, Id> relOppIdByRelContactId = new Map<Id, Id>();
		List<Id> tasksToProcess = new List<Id>();
		for (Task t : taskMap.values())
		{
			// Only use tasks related to Opportunity and Contact
			if (t.WhatId != null && t.WhoId != null 
				&& String.valueOf(t.WhatId).startsWith('006') && String.valueOf(t.WhoId).startsWith('003')
				&& t.Exclude_From_Contact_Role__c != 'Yes')
			{
				relatedOppIds.add(t.WhatId);
				relOppIdByRelContactId.put(t.WhoId, t.WhatId);
				tasksToProcess.add(t.Id);
			}
		}			
		
		if (relOppIdByRelContactId.size() > 0)
		{
			
			if (Schema.getGlobalDescribe().keySet().contains('taskrelation'))
			{
				Set<Id> taskIds = taskMap.keySet();
				// Add any additional contacts related to the task
				for (SObject tr : Database.query('Select RelationId, TaskId From TaskRelation Where TaskId IN :taskIds and IsWhat = false'))
				{
					relOppIdByRelContactId.put((Id)tr.get('RelationId'), taskMap.get((Id)tr.get('TaskId')).WhatId);
				}
			}			
			
			Map<Id, Opportunity> relatedOppsById = new Map<Id, Opportunity>([Select Id, AccountId, (Select ContactId From OpportunityContactRoles) 
				From Opportunity Where Id IN :relatedOppIds]);
			
			Set<Id> parentAccounts = new Set<Id>();
			for (Opportunity opp : relatedOppsById.values())
			{
				parentAccounts.add(opp.AccountId);
				for (OpportunityContactRole ocr : opp.OpportunityContactRoles)
				{
					// Remove contacts that have already exist as roles on the Opportunity
					relOppIdByRelContactId.remove(ocr.ContactId); 
				}
			}	
			
			if (relOppIdByRelContactId.size() > 0)
			{
				/*
				Map<Id, Account> parentAcctsById = new Map<Id, Account>([Select Id, (Select Id, AccountId From Contacts) 
					From Account Where Id IN :parentAccounts]);				
				
				Map<Id, Set<Id>> relContactsByAcctId = new Map<Id, Set<Id>>(); 
				for (Account acct : parentAcctsById.values())
				{
					for (Contact contact : acct.Contacts)
					{
						if (relContactsByAcctId.get(acct.Id) == null)
						{
							relContactsByAcctId.put(acct.Id, new Set<Id>{contact.Id});	
						}						
						else
						{
							relContactsByAcctId.get(acct.Id).add(contact.Id);
						}
					}
				}
				*/
				
				List<OpportunityContactRole> ocrsToInsert = new List<OpportunityContactRole>();
				
				for (Id contactId : relOppIdByRelContactId.keySet())
				{
					Opportunity opp = relatedOppsById.get(relOppIdByRelContactId.get(contactId));
					ocrsToInsert.add(
						new OpportunityContactRole(
							Role = 'No Role Assigned',
							ContactId = contactId,
							OpportunityId = opp.Id
						)
					);					
					// [Not anymore] Contact must be related to Opportunity's parent Account
					// if (relContactsByAcctId.get(opp.AccountId) != null && relContactsByAcctId.get(opp.AccountId).contains(contactId))

				}
				
				if (ocrsToInsert.size() > 0) insert ocrsToInsert;				
				
			}
		}
		
	}

}