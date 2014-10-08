public class SLA_ScheduledProcessSupport implements SLA_ScheduledProcess.IScheduledEntry {

	public void Execute()
	{
		HandleSLAExpirationCycle2();	
		HandleSLAExpiredLeads();
		SLA_ActivitySupport.WorkingSLAInactiveWarning();
	}

	public static DateTime ForceExpirationFortest = null;

	// Instance entry points to prevent lock from scheduled class
	/*public Boolean SE_HandleSLAExpiredLeads()
	{
		return HandleSLAExpiredLeads();
	}
	
	public Boolean SE_HandleSLAExpirationCycle2()
	{
		return HandleSLAExpirationCycle2();
	}
	
	public Boolean SE_WorkingSLAInactiveWarning()
	{
		return SLA_ActivitySupport.WorkingSLAInactiveWarning();
	}
	*/

	@future
	public static void HandleSLAExpiredLeadsFuture()
	{
		HandleSLAExpiredLeads();
	}

	// Looks for expired SLA
	// Implements Section B, F
	// Returns true if all available records have been processed, false otherwise
	public static Boolean HandleSLAExpiredLeads()
	{
		// List of SLA profiles
		Set<String> roles = SLA_Configuration.SLARolesForLeads();
		
		DateTime expiration = (Test.isRunningTest() && ForceExpirationForTest!=null)? ForceExpirationForTest: DateTime.Now().addHours(-2);
		
		Set<String> allslastages = SLA_Configuration.getAllSLAStageNames();
		
		/*Map<ID,Lead> expiredleads = new Map<ID, Lead>([Select ID, OwnerID, Owner.Profile.Name, Owner.UserRole.DeveloperName,
			SLA_Expires__c, Status, Disqualified_Reason__c, SLA_Cycles__c from Lead where
			Owner.UserRole.DeveloperName in :roles And SLA_Cycles__c!= null
			And SLA_Expires__c!=null And SLA_Expires__c < :expiration And Status in :allslastages Limit 200 ] );
		*/

		String querystring = SLA_Support.GetLeadQueryString('Select ID, OwnerID, Owner.Profile.Name, Owner.UserRole.DeveloperName, SLA_Expires__c, Status, Disqualified_Reason__c, SLA_Cycles__c',
			'from Lead where ' +
			'Owner.UserRole.DeveloperName in :roles And SLA_Cycles__c!= null ' +
			'And SLA_Expires__c!=null And SLA_Expires__c < :expiration And Status in :allslastages Limit 200 ');
		Map<ID, Lead> expiredleads = new Map<ID, Lead>((List<Lead>)Database.query(querystring));
			

		List<Lead> modifiedleads = new List<Lead>();

		Set<ID> ownerids = new Set<ID>();
		for(Lead ld: expiredleads.values()) ownerids.add(ld.OwnerID);
		Map<ID, User> relatedUserMap = new Map<ID, User>((List<User>)[Select ID, UserRole.DeveloperName from User where ID in :ownerids]);
		

		if(expiredleads.size()>0)
		{	
			Map<ID, CampaignMember> ResponsesForLeads = new Map<ID, CampaignMember>();
			List<CampaignMember> cms = FCRM.FCR_SupportAPI.GetActiveResponses(new List<ID>(expiredleads.keyset()));
			// Build map from lead to its active response
			for(CampaignMember cm: cms) ResponsesForLeads.put(cm.LeadID, cm);
			
			for(Lead ld: expiredleads.values())
			{
				SLA_Configuration config = new SLA_Configuration(relatedUserMap.get(ld.OwnerID), ld);
				ID sharktankowner = config.SLALeadMovementQueueID();
				
				if(!config.IsSLAStage(ld.status)) continue;
				
				CampaignMember cm = ResponsesForLeads.get(ld.id);
				if(ld.SLA_Cycles__c==1)
				{
					if(cm!=null) cm.First_SLA_Owner__c = ld.OwnerID;
					ld.ownerID = sharktankowner;
				}
				if(ld.SLA_Cycles__c==2)
				{
					if(cm!=null) cm.SLA_Expired_Date__c = DateTime.Now();
					ld.Status = 'Disqualified';
					ld.Disqualified_Reason__c = 'SLA Expired';
					ld.SLA_Expires__c = null;
					ld.SLA_Cycles__c = null;
				}
				modifiedleads.add(ld);
				
			}
			FCRM.FCR_SupportAPI.DisableApplicationForContext();
			database.update(cms, false);
			FCRM.FCR_SupportAPI.UndoDisableApplicationForContext();

			// We're updating lead status here, so don't disable the app
			// But don't intercept triggers either
			database.update(modifiedleads,false);
		}
		if(expiredleads.size()==200) return false;
		return true;
			
	}

	@future
	public static void HandleSLAExpirationCycle2Future()
	{
		HandleSLAExpirationCycle2();
	}


	// Looks for expires out of first SLA cycle
	// Implements Section C
	// Returns true if all available records have been processed, false otherwise
	public static Boolean HandleSLAExpirationCycle2()
	{
		// List of SLA profiles
		Integer DayOfWeek = SLA_Support.Weekday(Date.Today());
		//DateTime expiration = (DayOfWeek==4)? DateTime.Now().addDays(-5): ( (DayOfWeek==5)? DateTime.Now().addDays(-6) : DateTime.Now().addDays(-7));
		// Saturday is prior Friday, Sunday is prior Friday. All other days are 7 days back (5 weekdays) 
		DateTime expiration = (DayOfWeek==5)? DateTime.Now().addDays(-8): ( (DayOfWeek==6)? DateTime.Now().addDays(-9) : DateTime.Now().addDays(-7));
		if(Test.isRunningTest() && ForceExpirationForTest!=null) expiration = ForceExpirationForTest;
		
		Set<ID> allleadmovementqueues = SLA_Configuration.getAllSLALeadMovementQueueIDs();
		
		/*Map<ID,Lead> expiredleads = new Map<ID, Lead>([Select ID,
			Status, Disqualified_Reason__c, SLA_Expires__c, SLA_Cycles__c, Owner.UserRole.DeveloperName from Lead where
			OwnerID in :allleadmovementqueues And SLA_Cycles__c = 1
			And SLA_Expires__c !=null And SLA_Expires__c < :expiration Limit 200 ]);
		*/

		String querystring = SLA_Support.GetLeadQueryString('Select ID,	Status, Disqualified_Reason__c, SLA_Expires__c, SLA_Cycles__c, Owner.UserRole.DeveloperName',
				'from Lead where ' +
				'OwnerID in :allleadmovementqueues And SLA_Cycles__c = 1 ' +
				'And SLA_Expires__c !=null And SLA_Expires__c < :expiration Limit 200 '	);
		system.debug(querystring);
		Map<ID, Lead> expiredleads = new Map<ID, Lead>((List<Lead>)Database.query(querystring));

		if(expiredleads.size()>0)
		{	
			Map<ID, CampaignMember> ResponsesForLeads = new Map<ID, CampaignMember>();
			List<CampaignMember> cms = FCRM.FCR_SupportAPI.GetActiveResponses(new List<ID>(expiredleads.keyset()));
			// Build map from lead to its active response
			for(CampaignMember cm: cms) ResponsesForLeads.put(cm.LeadID, cm);
			
			for(Lead ld: expiredleads.values())
			{
				CampaignMember cm = ResponsesForLeads.get(ld.id);
				
				ld.Status = 'Disqualified';
				ld.Disqualified_Reason__c = 'SLA Expired';
				ld.SLA_Expires__c = null;
				ld.SLA_Cycles__c = null;
				
				if(cm!=null) cm.SLA_Expired_Date__c = DateTime.now();
				
			}

			FCRM.FCR_SupportAPI.DisableApplicationForContext();
			database.update(cms, false);
			FCRM.FCR_SupportAPI.UndoDisableApplicationForContext();
			// We're syncing lead status - don't disable the app for that!
			database.update(expiredleads.values(),false);
		}
		
		
		if(expiredleads.size()==200) return false;
		return true;
			
	}	

}