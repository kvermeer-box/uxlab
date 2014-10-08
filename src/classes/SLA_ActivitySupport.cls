public class SLA_ActivitySupport {

	public static Integer iteration = 0;

	public static DateTime ForceExpiration1Fortest = null;
	public static DateTime ForceExpiration2Fortest = null;

	// ProcessTasks is called to handle activity count on task insert/update
	// Call on create if the task is closed, or on update if it is being closed
	// Section H in spec
	// All tasks in array taskstotest must be closed

	public static void ProcessTasks(List<Task> taskstotest)
	{
		if (iteration > 0) return;
		else iteration = iteration +1;
		List<Task> taskstoprocess = new List<Task>();
		Set<ID> leadowners = new Set<ID>();		// We need a set of the task owners
		Set<ID> relatedleadIDs = new Set<ID>();
		
		for(Task t: taskstotest)
		{
			if(t.CreatedById == t.OwnerID && t.WhoID!=null &&
				t.WhoID.getSObjectType() == Lead.sObjectType && t.IsClosed &&
				!(t.Subject!=null && t.Subject.toLowerCase().StartsWith('mass email')))
			{
				leadowners.add(t.OwnerID);
				relatedleadIDs.add(t.WhoID);
				taskstoprocess.add(t);			
			}
		}

		// Get leads
		// Map<ID,Lead> relatedleads = new Map<ID, Lead>([Select ID, Status, OwnerID, Owner_Activity_Counter__c, Owner_Last_Activity_Date__c from Lead where ID in :relatedleadIDs]);
		String querystring = SLA_Support.GetLeadQueryString('Select ID, Status, OwnerID, Owner_Activity_Counter__c, Owner_Last_Activity_Date__c', ' from Lead where ID in :relatedleadIDs ');
		Map<ID, Lead> relatedleads = new Map<ID, Lead>((List<Lead>)Database.query(querystring));

		Set<ID> leadownerids = new Set<ID>();
		for(Lead ld: relatedleads.values()) leadownerids.add(ld.OwnerID);

		// Get related users
		Map<ID, User> relatedusers = new Map<ID, User>((List<User>)[Select ID, UserRole.DeveloperName from User where ID in :leadownerids ]);
		
		// Now run the loop again to see if leads need updating
		List<Lead> leadstoupdate = new List<Lead>();
		
		for(Task t: taskstoprocess)
		{
			System.debug('Task: ID: ' + t.Id + ' Object: ' + t);
			Lead ld = relatedleads.get(t.WhoID);
			SLA_Configuration config = new SLA_Configuration(relatedusers.get(ld.OwnerID), ld);
			if(config.onLead() && config.IsWorkingStage(ld.Status))
			{
				System.debug('Current Activity Counter: ' + ld.Owner_Activity_Counter__c);
				ld.Owner_Activity_Counter__c = (ld.Owner_Activity_Counter__c==null)? 1: ld.Owner_Activity_Counter__c+1;
				System.debug('New Activity Counter: ' + ld.Owner_Activity_Counter__c);
				ld.Owner_Last_Activity_Date__c = Date.Today();
				leadstoupdate.add(ld);
			}
		}
		update leadstoupdate;
		
	}


	// Sends warnings regarding inactive SLA
	// Implements Section I, J
	// Returns true if all available records have been processed, false otherwise
	public static Boolean WorkingSLAInactiveWarning()
	{
		// List of SLA roles
		Set<String> roles = SLA_Configuration.SLARolesForLeads();
		Set<String> workingstatuses = SLA_Configuration.getAllWorkingStageNames();

		DateTime expiration1 = (ForceExpiration1Fortest==null || !Test.isRunningTest())? DateTime.Now().addDays(-SLA_Configuration.getSmallestWarningDays()): ForceExpiration1Fortest;
		DateTime expiration2 = (ForceExpiration2Fortest==null || !Test.isRunningTest())? DateTime.Now().addDays(-SLA_Configuration.getSmallestMovementDays()): ForceExpiration2Fortest;
		Date expiration1date = expiration1.date();
		Date expiration2date = expiration2.date();
		
		/*Map<ID,Lead> expiredleads14 = new Map<ID, Lead>([Select ID,
			OwnerID, Status, Disqualified_Reason__c, Owner_Last_Activity_Date__c, Status_Change_Timestamp__c, SLA_Email_Warning_Sent__c 
			from Lead where
			(Owner.UserRole.DeveloperName in :roles And Status in :workingstatuses) 
			And ((
				(Owner_Last_Activity_Date__c=null Or Owner_Last_Activity_Date__c < :expiration1.Date()) AND
				(Status_Change_Timestamp__c=null Or Status_Change_Timestamp__c < :expiration1) And
				(SLA_Email_Warning_Sent__c =null Or SLA_Email_Warning_Sent__c < :expiration1 )
				)  
			) Limit 200  ]);
		*/
			
		String querystring = SLA_Support.GetLeadQueryString('Select ID, OwnerID, Status, Disqualified_Reason__c, Owner_Last_Activity_Date__c, Status_Change_Timestamp__c, SLA_Email_Warning_Sent__c ', 
			'from Lead where ' +
			' (Owner.UserRole.DeveloperName in :roles And Status in :workingstatuses) ' + 
			' And (( ' +
				'(Owner_Last_Activity_Date__c=null Or Owner_Last_Activity_Date__c < :expiration1date) AND ' +
				'(Status_Change_Timestamp__c=null Or Status_Change_Timestamp__c < :expiration1) And ' +
				'(SLA_Email_Warning_Sent__c =null Or SLA_Email_Warning_Sent__c < :expiration1 ) ' +
				') ' +  
			') Limit 200 ');		
		system.debug(querystring);	
		Map<ID, Lead> expiredleads14 = new Map<ID, Lead>((List<Lead>)Database.query(querystring));

		/*Map<ID,Lead> expiredleads21 = new Map<ID, Lead>([Select ID, OwnerID,
			Status, Disqualified_Reason__c, Owner_Last_Activity_Date__c, Status_Change_Timestamp__c 
			from Lead where
			(Owner.UserRole.DeveloperName in :roles And Status in :workingstatuses) 
			And (
				(Owner_Last_Activity_Date__c=null Or Owner_Last_Activity_Date__c < :expiration2.Date()) AND
				(Status_Change_Timestamp__c=null Or Status_Change_Timestamp__c < :expiration2)
			) Limit 200  ]);
		*/

		querystring = SLA_Support.GetLeadQueryString('Select ID, OwnerID, Status, Disqualified_Reason__c, Owner_Last_Activity_Date__c, Status_Change_Timestamp__c',
			'from Lead where ' + 
			'(Owner.UserRole.DeveloperName in :roles And Status in :workingstatuses) ' + 
			' And ( ' +
				'(Owner_Last_Activity_Date__c=null Or Owner_Last_Activity_Date__c < :expiration2date) AND ' +
				'(Status_Change_Timestamp__c=null Or Status_Change_Timestamp__c < :expiration2) ' +
			') Limit 200 ');

		Map<ID, Lead> expiredleads21 = new Map<ID, Lead>((List<Lead>)Database.query(querystring));

			
		Set<Lead> leadstoupdate = new Set<Lead>();
		
		if(expiredleads14.size()>0)
		{	
			// Check owners
			Set<ID> ownerids = new Set<ID>();
			for(Lead ld: expiredleads14.values()) ownerids.add(ld.OwnerID);
			Map<ID,User> leadowners = new Map<ID,User>([Select IsActive, UserRole.DeveloperName from User where id in :ownerids]);
			
			List<OrgWideEmailAddress> orgaddresses = [Select ID from OrgWideEmailAddress where address='sfdcunicorn@box.com'];
			List<Messaging.Singleemailmessage> warnings = new List<Messaging.Singleemailmessage>();
			
			for(Lead ld: expiredleads14.values())
			{
				// If it's already met the 21 day limit, don't send a warning
				if(expiredleads21.containskey(ld.id)) continue;
				
				User u = leadowners.get(ld.OwnerID);
				
				SLA_Configuration config = new SLA_Configuration(u, ld);
				// Validate the date against the actual date
				DateTime retestexpiration = (ForceExpiration1Fortest==null || !Test.isRunningTest())? DateTime.Now().addDays(-config.WorkingActivityWarningDays()): ForceExpiration1Fortest;
				if(! (ld.Owner_Last_Activity_Date__c==null || ld.Owner_Last_Activity_Date__c < retestexpiration.Date()) &&
					 (ld.Status_Change_Timestamp__c==null || ld.Status_Change_Timestamp__c < retestexpiration) &&
					 (ld.SLA_Email_Warning_Sent__c ==null || ld.SLA_Email_Warning_Sent__c < retestexpiration )
					) continue;
				
				
				if(u==null || !u.IsActive) continue;
				// If 14 days
				// Send warning Email
				ld.SLA_Email_Warning_Sent__c = DateTime.Now();
				leadstoupdate.add(ld);
				Messaging.Singleemailmessage msg = new Messaging.Singleemailmessage();
				if(orgaddresses.size()>0) msg.setOrgWideEmailAddressId(orgaddresses[0].id);
				else 
				{
					msg.SetSenderDisplayName('Salesforce Unicorn');
					msg.SetReplyTo('sfdcunicorn@box.com');
				}
				msg.setSubject('Inactive record warning');
				msg.setTargetObjectId(ld.OwnerID);
				msg.setSaveAsActivity(false);
				msg.setPlaintextBody(
				'The following record has had no activity in 14 days. In a week this record will be automatically disqualified.\n' +
				'View Record: '+ URL.getSalesforceBaseUrl().toExternalForm() + '/' + ld.ID + '\n');
				warnings.add(msg);
			}
			messaging.sendEmail(warnings, false);
		}
		if(expiredleads21.size()>0)
		{	
			// Check owners
			Set<ID> ownerids = new Set<ID>();
			for(Lead ld: expiredleads21.values()) ownerids.add(ld.OwnerID);
			Map<ID,User> leadowners = new Map<ID,User>([Select IsActive, UserRole.DeveloperName from User where id in :ownerids]);

			for(Lead ld: expiredleads21.values())
			{
				User u = leadowners.get(ld.OwnerID);
				
				SLA_Configuration config = new SLA_Configuration(u, ld);

				// Validate the date against the actual date
				DateTime retestexpiration = (ForceExpiration2Fortest==null || !Test.isRunningTest())? DateTime.Now().addDays(-config.WorkingActivityMovementDays()): ForceExpiration2Fortest;
				if(! (ld.Owner_Last_Activity_Date__c==null || ld.Owner_Last_Activity_Date__c < retestexpiration.Date()) &&
					 (ld.Status_Change_Timestamp__c==null || ld.Status_Change_Timestamp__c < retestexpiration) 
					) continue;
				
				
				// If 21 days has pssed
				ld.Status = 'Disqualified';
				ld.Disqualified_Reason__c = 'Lack of Progress';
				ld.SLA_Email_Warning_Sent__c = null;
				leadstoupdate.add(ld);
			}
		}
		if(leadstoupdate.size()>0) database.update(new List<Lead>(leadstoupdate),false);
		if(expiredleads14.size()==200 || expiredleads21.size()==200) return false;
		return true;
			
	}	


}