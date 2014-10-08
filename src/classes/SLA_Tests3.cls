@istest
public class SLA_Tests3 {

	private final static Integer bulksize = 5; 

	static testMethod void TestActivtyCounter() {
        User u = SLA_Tests1.GetSDRUser();
        if(u==null) return;	// Can't test without user

		// Initialize outside of the runas term to prevent initial user from being SLA
       	SLA_Configuration config = new SLA_Configuration(u.UserRole.DeveloperName);
		ID sharktankowner = config.SLALeadMovementQueueID();
		        
        System.RunAs(u)
        {
        	List<Lead> testleads = SLA_Tests1.initTestLeads('slatest', bulksize);
        	insert testleads;
        	
        	List<Campaign> camps = SLA_Tests1.initTestCampaigns('slacamp',1);
        	insert camps;
        	
        	List<CampaignMember> cms = new List<CampaignMember>();
        	// Create active response. Note, SeeAllData is off, so FCRM application is disabled
        	for(Integer x = 0; x< bulksize; x++) 
        		cms.add(new CampaignMember(LeadID = testleads[x].id, CampaignID = camps[0].id, 
        		FCRM__FCR_Response_Status__c = 'Open - Not Contacted', FCRM__FCR_Response_Date__c = DateTime.Now()));
        	insert cms;
        	
        	Map<ID, Lead> leadmap = new Map<ID, Lead>(testleads);
        	
        	SLA_FCRM_Plugin plugin = new SLA_FCRM_Plugin();
        	FCRM.FCR_ExtensibilityAPI.IExtensibilityEventArgs args = new SLA_Tests1.Args(null, null, new List<ID>(leadmap.keyset()));
        	
        	plugin.ExtensibilityEvent(SLA_FCRM_Plugin.ACTIVERESPONSEPROCESSED, args);

			// Requery for latest field values so the comparison will work
        	testleads = [Select ID, Status, OwnerID, SLA_Cycles__c, SLA_Expires__c from Lead where ID in :leadmap.keyset()];
			leadmap = new Map<ID, Lead>(testleads);
			
			// Clone the leads
			List<Lead> clonedleads = testleads.DeepClone(true);
			for(Lead ld: clonedleads) ld.Status = new List<String>(config.WorkingStageNames())[0];	// Set to a working status

			update clonedleads;
			// leadmap has the old status values, so it's very much like the old map on a trigger
			args = new SLA_Tests1.Args(clonedleads, leadmap, null);
        	plugin.ExtensibilityEvent(SLA_FCRM_Plugin.STATUSOROWNERCHANGE, args);
        	
        	// Update changes
        	update clonedleads;

			// Now create closed tasks
			List<Task> tasks = new List<Task>();
			for(Lead ld: clonedleads)
			{
				tasks.add(new Task(Status = 'Completed', Subject='sometask', WhoID = ld.id ));
			}
			Test.StartTest();
			insert tasks;
			Test.StopTest();

        	testleads = [Select ID, Status, OwnerID, Owner_Activity_Counter__c, Owner_Last_Activity_Date__c from Lead where ID in :leadmap.keyset()];
			for(Lead ld: testleads)
			{
				system.assertEquals(1, ld.Owner_Activity_Counter__c);
				system.assertNotEquals(null, ld.Owner_Last_Activity_Date__c);
			}

        }
    }     
	

	static testMethod void TestActivtyWarnings() {
        User u = SLA_Tests1.GetSDRUser();
        if(u==null) return;	// Can't test without user

		// Initialize outside of the runas term to prevent initial user from being SLA
       	SLA_Configuration config = new SLA_Configuration(u.UserRole.DeveloperName);
		ID sharktankowner = config.SLALeadMovementQueueID();
		        
        System.RunAs(u)
        {
        	List<Lead> testleads = SLA_Tests1.initTestLeads('slatest', bulksize);
        	insert testleads;
        	
        	List<Campaign> camps = SLA_Tests1.initTestCampaigns('slacamp',1);
        	insert camps;
        	
        	List<CampaignMember> cms = new List<CampaignMember>();
        	// Create active response. Note, SeeAllData is off, so FCRM application is disabled
        	for(Integer x = 0; x< bulksize; x++) 
        		cms.add(new CampaignMember(LeadID = testleads[x].id, CampaignID = camps[0].id, 
        		FCRM__FCR_Response_Status__c = 'Open - Not Contacted', FCRM__FCR_Response_Date__c = DateTime.Now()));
        	insert cms;
        	
        	Map<ID, Lead> leadmap = new Map<ID, Lead>(testleads);
        	
        	SLA_FCRM_Plugin plugin = new SLA_FCRM_Plugin();
        	FCRM.FCR_ExtensibilityAPI.IExtensibilityEventArgs args = new SLA_Tests1.Args(null, null, new List<ID>(leadmap.keyset()));
        	
        	plugin.ExtensibilityEvent(SLA_FCRM_Plugin.ACTIVERESPONSEPROCESSED, args);

			// Requery for latest field values so the comparison will work
        	testleads = [Select ID, Status, OwnerID, SLA_Cycles__c, SLA_Expires__c from Lead where ID in :leadmap.keyset()];
			leadmap = new Map<ID, Lead>(testleads);
			
			// Clone the leads
			List<Lead> clonedleads = testleads.DeepClone(true);
			for(Lead ld: clonedleads) ld.Status = new List<String>(config.WorkingStageNames())[0];	// Set to a working status

			update clonedleads;
			// leadmap has the old status values, so it's very much like the old map on a trigger
			args = new SLA_Tests1.Args(clonedleads, leadmap, null);
        	plugin.ExtensibilityEvent(SLA_FCRM_Plugin.STATUSOROWNERCHANGE, args);
        	
        	// Update changes
        	update clonedleads;

			// Now create closed tasks
			List<Task> tasks = new List<Task>();
			for(Lead ld: clonedleads)
			{
				tasks.add(new Task(Status = 'Completed', Subject='sometask', WhoID = ld.id ));
			}
			insert tasks;
			
			SLA_ActivitySupport.ForceExpiration1Fortest = DateTime.Now().addDays(1);
			
			Test.StartTest();
			SLA_ActivitySupport.WorkingSLAInactiveWarning();
			Test.StopTest();

        	testleads = [Select ID, Status, Status_Change_Timestamp__c, SLA_Email_Warning_Sent__c, OwnerID, Owner_Activity_Counter__c, Owner_Last_Activity_Date__c from Lead where ID in :leadmap.keyset()];
        	system.debug(testleads);
			for(Lead ld: testleads)
			{
				system.assertNotEquals(null, ld.SLA_Email_Warning_Sent__c);
			}

        }
        
    }     

	static testMethod void TestActivtyTimeout() {
        User u = SLA_Tests1.GetSDRUser();
        if(u==null) return;	// Can't test without user

		// Initialize outside of the runas term to prevent initial user from being SLA
       	SLA_Configuration config = new SLA_Configuration(u.UserRole.DeveloperName);
		ID sharktankowner = config.SLALeadMovementQueueID();
		        
        System.RunAs(u)
        {
        	List<Lead> testleads = SLA_Tests1.initTestLeads('slatest', bulksize);
        	insert testleads;
        	
        	List<Campaign> camps = SLA_Tests1.initTestCampaigns('slacamp',1);
        	insert camps;
        	
        	List<CampaignMember> cms = new List<CampaignMember>();
        	// Create active response. Note, SeeAllData is off, so FCRM application is disabled
        	for(Integer x = 0; x< bulksize; x++) 
        		cms.add(new CampaignMember(LeadID = testleads[x].id, CampaignID = camps[0].id, 
        		FCRM__FCR_Response_Status__c = 'Open - Not Contacted', FCRM__FCR_Response_Date__c = DateTime.Now()));
        	insert cms;
        	
        	Map<ID, Lead> leadmap = new Map<ID, Lead>(testleads);
        	
        	SLA_FCRM_Plugin plugin = new SLA_FCRM_Plugin();
        	FCRM.FCR_ExtensibilityAPI.IExtensibilityEventArgs args = new SLA_Tests1.Args(null, null, new List<ID>(leadmap.keyset()));
        	
        	plugin.ExtensibilityEvent(SLA_FCRM_Plugin.ACTIVERESPONSEPROCESSED, args);

			// Requery for latest field values so the comparison will work
        	testleads = [Select ID, Status, OwnerID, SLA_Cycles__c, SLA_Expires__c from Lead where ID in :leadmap.keyset()];
			leadmap = new Map<ID, Lead>(testleads);
			
			// Clone the leads
			List<Lead> clonedleads = testleads.DeepClone(true);
			for(Lead ld: clonedleads) ld.Status = new List<String>(config.WorkingStageNames())[0];	// Set to a working status

			update clonedleads;
			// leadmap has the old status values, so it's very much like the old map on a trigger
			args = new SLA_Tests1.Args(clonedleads, leadmap, null);
        	plugin.ExtensibilityEvent(SLA_FCRM_Plugin.STATUSOROWNERCHANGE, args);
        	
        	// Update changes
        	update clonedleads;

			// Now create closed tasks
			List<Task> tasks = new List<Task>();
			for(Lead ld: clonedleads)
			{
				tasks.add(new Task(Status = 'Completed', Subject='sometask', WhoID = ld.id ));
			}
			insert tasks;
			
			SLA_ActivitySupport.ForceExpiration2Fortest = DateTime.Now().addDays(1);
			
			Test.StartTest();
			SLA_ActivitySupport.WorkingSLAInactiveWarning();
			Test.StopTest();

        	testleads = [Select ID, Status, Status_Change_Timestamp__c, SLA_Email_Warning_Sent__c, OwnerID, Owner_Activity_Counter__c, Owner_Last_Activity_Date__c from Lead where ID in :leadmap.keyset()];
        	system.debug(testleads);
			for(Lead ld: testleads)
			{
				system.assertEquals(ld.Status, 'Disqualified');
			}

        }
        
    }     


}