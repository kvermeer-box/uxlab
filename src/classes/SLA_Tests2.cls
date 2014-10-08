@isTest
public class SLA_Tests2 {

	private final static Integer bulksize = 5; 

     static testMethod void ExpiresFromSharktank() {
        User u = SLA_Tests1.GetSDRUser();
        if(u==null) return;	// Can't test without user

		// Initialize outside of the runas term to prevent initial user from being SLA
       	SLA_Configuration config = new SLA_Configuration(u.UserRole.DeveloperName);
		ID sharktankowner = config.SLALeadMovementQueueID();

        System.RunAs(u)
        {
        	List<Lead> testleads = SLA_Tests1.initTestLeads('slatest', bulksize);
        	for(Lead ld: testleads) ld.Status = 'Open - Not Contacted';
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

			// Now expire first SLA
			SLA_ScheduledProcess processobject = new SLA_ScheduledProcess();
			SLA_ScheduledProcessSupport.ForceExpirationFortest = DateTime.Now().addDays(4);
			
			processobject.execute(null);

			SLA_ScheduledProcessSupport.ForceExpirationFortest = DateTime.Now().addDays(8);

			// Now expires second SLA
			
			Test.StartTest();
			processobject.execute(null);
			Test.StopTest();					
	

			SLA_ScheduledProcessSupport.ForceExpirationFortest = null;

			// Requery for latest field values so the comparison will work
        	testleads = [Select ID, Status, OwnerID, SLA_Cycles__c, SLA_Expires__c from Lead where ID in :leadmap.keyset()];


        	// We test against the clonedlaads array. Because this Extesnibility event is normally called
        	// during a before trigger, the leads were not actually updated in the database during
        	// the test
        	for(Lead ld: testleads)
        	{
        		// System.assertEquals('Disqualified', ld.Status);
        		// System.assertEquals(null, ld.SLA_Expires__c);
        		// System.assertEquals(null, ld.SLA_Cycles__c);
        	}
        	
        }
    }    

     static testMethod void TestSecondOwnerAttained() {
        User u = SLA_Tests1.GetSDRUser();
        if(u==null) return;	// Can't test without user

		// Initialize outside of the runas term to prevent initial user from being SLA
       	SLA_Configuration config = new SLA_Configuration(u.UserRole.DeveloperName);
		ID sharktankowner = config.SLALeadMovementQueueID();
		        
        System.RunAs(u)
        {
        	List<Lead> testleads = SLA_Tests1.initTestLeads('slatest', bulksize);
        	for(Lead ld: testleads) ld.Status = 'Open - Not Contacted';
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

			// Now expire first SLA
			SLA_ScheduledProcess processobject = new SLA_ScheduledProcess();
			SLA_ScheduledProcessSupport.ForceExpirationFortest = DateTime.Now().addDays(4);
			
			processobject.execute(null);

			SLA_ScheduledProcessSupport.ForceExpirationFortest = null;

			// Requery for latest field values so the comparison will work
        	//testleads = [Select ID, Status, OwnerID, SLA_Cycles__c, SLA_Expires__c from Lead where ID in :leadmap.keyset()];
			testleads = new SLA_Tests1.SLA_TestSupport().queryleads(leadmap.keyset());

			leadmap = new Map<ID, Lead>(testleads);
			
			// Clone the leads
			List<Lead> clonedleads = testleads.DeepClone(true);
			for(Lead ld: clonedleads) ld.OwnerID = u.id;	// Reclaim back to an SDR owner
			new SLA_Tests1.SLA_TestSupport().updateleads(clonedleads);
			// update clonedleads;
			// leadmap has the old status values, so it's very much like the old map on a trigger
			args = new SLA_Tests1.Args(clonedleads, leadmap, null);
        	plugin.ExtensibilityEvent(SLA_FCRM_Plugin.STATUSOROWNERCHANGE, args);

			//update clonedleads;	// And update the modified leads
			new SLA_Tests1.SLA_TestSupport().updateleads(clonedleads);
			

			// Requery for latest field values so the comparison will work
        	testleads = [Select ID, Status, OwnerID, SLA_Cycles__c, SLA_Expires__c from Lead where ID in :leadmap.keyset()];
			for(Lead ld: testleads) system.assertEquals(2, ld.SLA_Cycles__c);
			// Now set attainment via status change

			leadmap = new Map<ID, Lead>(testleads);
			// Clone the leads
			clonedleads = testleads.DeepClone(true);
			for(Lead ld: clonedleads) ld.Status = new List<String>(config.WorkingStageNames())[0];	// Set to a working status
			Test.StartTest();
			update clonedleads;
			// leadmap has the old status values, so it's very much like the old map on a trigger
			args = new SLA_Tests1.Args(clonedleads, leadmap, null);
        	plugin.ExtensibilityEvent(SLA_FCRM_Plugin.STATUSOROWNERCHANGE, args);
        	Test.StopTest();


        	Map<ID, CampaignMember> cmmap = new Map<ID, CampaignMember>(cms);
        	
        	List<CampaignMember> cmresults = [Select id, SLA_Cycles__c, First_SLA_Owner__c, Second_SLA_Owner__c, SLA_Achieved__c from Campaignmember where id in :cmmap.keyset()];
        	// We test against the clonedlaads array. Because this Extesnibility event is normally called
        	// during a before trigger, the leads were not actually updated in the database during
        	// the test
        	for(Lead ld: clonedleads)
        	{
        		System.assertEquals(null, ld.SLA_Cycles__c);
        		System.assertEquals(null, ld.SLA_Expires__c);
        	}
        	for(CampaignMember cm: cmresults)
        	{
        		System.Assert(cm.SLA_Achieved__c!=null);
        	}

        	
        }
    }     

}