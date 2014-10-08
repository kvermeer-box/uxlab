@isTest
public class SLA_Tests1 {

	// Internal class used to bypass sharing rules when using system.runas
	public without sharing class SLA_TestSupport
	{
		public List<Lead> queryleads(Set<ID> ids)
		{
			return  [Select ID, Status, OwnerID, SLA_Cycles__c, SLA_Expires__c from Lead where ID in :ids];
		}
		public void updateleads(List<Lead> leads)
		{
			update leads;
		}
	}

	private final static Integer bulksize = 5; 

	// Args class used for testing the plugin
	public Class Args implements FCRM.FCR_ExtensibilityAPI.IExtensibilityEventArgs
	{
		public List<List<Sobject>> Recordlists;
		public List<Map<ID, Sobject>> RecordMaps;
		public List<List<ID>> RecordIds;
		
		public List<List<Sobject>> getRecordLists() { return RecordLists; }
		public List<Map<ID, Sobject>> getRecordMaps() { return RecordMaps; }
		public List<List<ID>> getRecordIds() { return RecordIds; }
		public List<Object> getAdditionalParams() {return null; }
		public void setRaiseFuture() {  }
		public String getXMLdata() { return null; }
		
		public Args(List<SObject> objlist, Map<ID,SObject> objmap, List<ID> idlist)
		{
			Recordlists = new List<List<SObject>>{ objlist };
			RecordMaps = new List<Map<ID, SObject>> { objmap };
			RecordIDs = new List<List<ID>> { idlist };
		}		
	}


    static testMethod void TestActiveResponse() {
        User u = GetSDRUser();
        if(u==null) return;	// Can't test without user
 
 		// Initialize outside of the runas term to prevent initial user from being SLA
       	SLA_Configuration config = new SLA_Configuration(u.UserRole.DeveloperName);
        
        System.RunAs(u)
        {
        	List<Lead> testleads = initTestLeads('slatest', bulksize);
        	insert testleads;
        	
        	List<Campaign> camps = initTestCampaigns('slacamp',1);
        	insert camps;
        	
        	List<CampaignMember> cms = new List<CampaignMember>();
        	// Create active response. Note, SeeAllData is off, so FCRM application is disabled
        	for(Integer x = 0; x< bulksize; x++) 
        		cms.add(new CampaignMember(LeadID = testleads[x].id, CampaignID = camps[0].id, 
        		FCRM__FCR_Response_Status__c = 'Open - Not Contacted', FCRM__FCR_Response_Date__c = DateTime.Now()));
        	insert cms;
        	
        	Map<ID, Lead> leadmap = new Map<ID, Lead>(testleads);
        	
        	SLA_FCRM_Plugin plugin = new SLA_FCRM_Plugin();
        	FCRM.FCR_ExtensibilityAPI.IExtensibilityEventArgs args = new Args(null, null, new List<ID>(leadmap.keyset()));
        	
        	Test.StartTest();
        	plugin.ExtensibilityEvent(SLA_FCRM_Plugin.ACTIVERESPONSEPROCESSED, args);
        	Test.StopTest();
        	
        	Map<ID, CampaignMember> cmmap = new Map<ID, CampaignMember>(cms);
        	
        	List<Lead> leadresults = [Select ID, SLA_Cycles__c from Lead where ID in :leadmap.keyset()];
        	List<CampaignMember> cmresults = [Select id, SLA_Cycles__c from Campaignmember where id in :cmmap.keyset()];
        	for(Lead ld: leadresults)
        	{
        		System.assertEquals(1, ld.SLA_Cycles__c);
        	}
        	for(CampaignMember cm: cmresults)
        	{
        		System.assertEquals(1, cm.SLA_Cycles__c);
        	}
        	
        }
    }


    static testMethod void TestFirstOwnerAttained() {
        User u = GetSDRUser();
        if(u==null) return;	// Can't test without user

		// Initialize outside of the runas term to prevent initial user from being SLA
       	SLA_Configuration config = new SLA_Configuration(u.UserRole.DeveloperName);
        
        System.RunAs(u)
        {
        	List<Lead> testleads = initTestLeads('slatest', bulksize);
        	insert testleads;
        	
        	List<Campaign> camps = initTestCampaigns('slacamp',1);
        	insert camps;
        	
        	List<CampaignMember> cms = new List<CampaignMember>();
        	// Create active response. Note, SeeAllData is off, so FCRM application is disabled
        	for(Integer x = 0; x< bulksize; x++) 
        		cms.add(new CampaignMember(LeadID = testleads[x].id, CampaignID = camps[0].id, 
        		FCRM__FCR_Response_Status__c = 'Open - Not Contacted', FCRM__FCR_Response_Date__c = DateTime.Now()));
        	insert cms;
        	
        	Map<ID, Lead> leadmap = new Map<ID, Lead>(testleads);
        	
        	SLA_FCRM_Plugin plugin = new SLA_FCRM_Plugin();
        	FCRM.FCR_ExtensibilityAPI.IExtensibilityEventArgs args = new Args(null, null, new List<ID>(leadmap.keyset()));
        	plugin.ExtensibilityEvent(SLA_FCRM_Plugin.ACTIVERESPONSEPROCESSED, args);
			// Requery for latest field values so the comparison will work
        	testleads = [Select ID, Status, OwnerID, SLA_Cycles__c, SLA_Expires__c from Lead where ID in :leadmap.keyset()];
			leadmap = new Map<ID, Lead>(testleads);
			// Clone the leads
			List<Lead> clonedleads = testleads.DeepClone(true);
			for(Lead ld: clonedleads) ld.Status = new List<String>(config.WorkingStageNames())[0];	// Set to a working status
			Test.StartTest();
			update clonedleads;
			// leadmap has the old status values, so it's very much like the old map on a trigger
			args = new Args(clonedleads, leadmap, null);
        	plugin.ExtensibilityEvent(SLA_FCRM_Plugin.STATUSOROWNERCHANGE, args);
        	Test.StopTest();

        	Map<ID, CampaignMember> cmmap = new Map<ID, CampaignMember>(cms);
        	
        	List<CampaignMember> cmresults = [Select id, SLA_Cycles__c, First_SLA_Owner__c, SLA_Achieved__c from Campaignmember where id in :cmmap.keyset()];
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
        		System.assertEquals(u.id, cm.First_SLA_Owner__c);
        		System.Assert(cm.SLA_Achieved__c!=null);
        	}
        	
        }
    }    

    static testMethod void TestFirstSLAExpire() {
        User u = GetSDRUser();
        if(u==null) return;	// Can't test without user

		// Initialize outside of the runas term to prevent initial user from being SLA
       	SLA_Configuration config = new SLA_Configuration(u.UserRole.DeveloperName);
		ID sharktankowner = config.SLALeadMovementQueueID();
		        
        System.RunAs(u)
        {
        	
        	List<Lead> testleads = initTestLeads('slatest', bulksize);
        	for(Lead ld: testleads) ld.Status = 'Open - Not Contacted';
        	insert testleads;
        	
        	List<Campaign> camps = initTestCampaigns('slacamp',1);
        	insert camps;
        	
        	List<CampaignMember> cms = new List<CampaignMember>();
        	// Create active response. Note, SeeAllData is off, so FCRM application is disabled
        	for(Integer x = 0; x< bulksize; x++) 
        		cms.add(new CampaignMember(LeadID = testleads[x].id, CampaignID = camps[0].id, 
        		FCRM__FCR_Response_Status__c = 'Open - Not Contacted', FCRM__FCR_Response_Date__c = DateTime.Now()));
        	insert cms;
        	
        	Map<ID, Lead> leadmap = new Map<ID, Lead>(testleads);
        	
        	SLA_FCRM_Plugin plugin = new SLA_FCRM_Plugin();
        	FCRM.FCR_ExtensibilityAPI.IExtensibilityEventArgs args = new Args(null, null, new List<ID>(leadmap.keyset()));
        	
        	plugin.ExtensibilityEvent(SLA_FCRM_Plugin.ACTIVERESPONSEPROCESSED, args);

			// Now expire first SLA
			SLA_ScheduledProcess processobject = new SLA_ScheduledProcess();
			SLA_ScheduledProcessSupport.ForceExpirationFortest = DateTime.Now().addDays(15);
			
			Test.StartTest();
			processobject.execute(null);
			Test.StopTest();

			// Requery for latest field values so the comparison will work
        	testleads = [Select ID, Status, OwnerID, SLA_Cycles__c, SLA_Expires__c from Lead where ID in :leadmap.keyset()];

        	Map<ID, CampaignMember> cmmap = new Map<ID, CampaignMember>(cms);
        	
        	List<CampaignMember> cmresults = [Select id, SLA_Cycles__c, First_SLA_Owner__c, SLA_Achieved__c from Campaignmember where id in :cmmap.keyset()];

        	for(Lead ld: testleads)
        	{
        		System.assertEquals(sharktankowner, ld.OwnerID);
        	}
        	for(CampaignMember cm: cmresults)
        	{
        		System.assertEquals(u.id, cm.First_SLA_Owner__c);
        	}

        	
        }
    }  

     static testMethod void ClaimFromSharktank() {
        User u = GetSDRUser();
        if(u==null) return;	// Can't test without user

		// Initialize outside of the runas term to prevent initial user from being SLA
       	SLA_Configuration config = new SLA_Configuration(u.UserRole.DeveloperName);
		ID sharktankowner = config.SLALeadMovementQueueID();

		List<Lead> testleads;
		List<Campaign> camps;
		FCRM.FCR_ExtensibilityAPI.IExtensibilityEventArgs args;
		SLA_FCRM_Plugin plugin;
		List<CampaignMember> cms;
		Map<ID, Lead> leadmap;
								
        System.RunAs(u)
        {
        	testleads = initTestLeads('slatest', bulksize);
        	for(Lead ld: testleads) ld.Status = 'Open - Not Contacted';
        	insert testleads;
        	
        	camps = initTestCampaigns('slacamp',1);
        	insert camps;
        	
        	cms = new List<CampaignMember>();
        	// Create active response. Note, SeeAllData is off, so FCRM application is disabled
        	for(Integer x = 0; x< bulksize; x++) 
        		cms.add(new CampaignMember(LeadID = testleads[x].id, CampaignID = camps[0].id, 
        		FCRM__FCR_Response_Status__c = 'Open - Not Contacted', FCRM__FCR_Response_Date__c = DateTime.Now()));
        	insert cms;
        	
        	leadmap = new Map<ID, Lead>(testleads);
        	
        	plugin = new SLA_FCRM_Plugin();
        	args = new Args(null, null, new List<ID>(leadmap.keyset()));
        	
        	plugin.ExtensibilityEvent(SLA_FCRM_Plugin.ACTIVERESPONSEPROCESSED, args);

			// Now expire first SLA
			SLA_ScheduledProcess processobject = new SLA_ScheduledProcess();
			SLA_ScheduledProcessSupport.ForceExpirationFortest = DateTime.Now().addDays(4);
			
			processobject.execute(null);
 
			SLA_ScheduledProcessSupport.ForceExpirationFortest = null;
        
			// Requery for latest field values so the comparison will work
        	//List<Lead> testleads2 = [Select ID, Status, OwnerID, SLA_Cycles__c, SLA_Expires__c from Lead where ID in :leadmap.keyset()];
			
			List<Lead> testleads2 = new SLA_TestSupport().queryleads(leadmap.keyset());
		
			Map<ID,Lead> leadmap2 = new Map<ID, Lead>(testleads2);
 			
			// Clone the leads
			List<Lead> clonedleads = testleads2.DeepClone(true);
			for(Lead ld: clonedleads) ld.OwnerID = u.id;	// Reclaim back to an SDR owner
			Test.StartTest();
			
			// Update the leads, ignoring sharing rules
			new SLA_TestSupport().updateleads(clonedleads);
			//update clonedleads;
			
			// leadmap has the old status values, so it's very much like the old map on a trigger
			args = new Args(clonedleads, leadmap2, null);
        	plugin.ExtensibilityEvent(SLA_FCRM_Plugin.STATUSOROWNERCHANGE, args);
        	Test.StopTest();

        	Map<ID, CampaignMember> cmmap = new Map<ID, CampaignMember>(cms);
        	
        	List<CampaignMember> cmresults = [Select id, SLA_Cycles__c, First_SLA_Owner__c, Second_SLA_Owner__c, SLA_Achieved__c from Campaignmember where id in :cmmap.keyset()];
        	// We test against the clonedlaads array. Because this Extesnibility event is normally called
        	// during a before trigger, the leads were not actually updated in the database during
        	// the test
        	for(Lead ld: clonedleads)
        	{
        		System.assertEquals(2, ld.SLA_Cycles__c,'clonedleads1 ' + ld);
        		System.assertNotEquals(null, ld.SLA_Expires__c,'clonedleads2');
        	}
        	for(CampaignMember cm: cmresults)
        	{
        		System.assertEquals(2, cm.SLA_Cycles__c,'cmresults1' );
        		System.AssertEquals(cm.Second_SLA_Owner__c, u.id,'cmresults2');
        	}

        	
        }
    }     


    
    public static User GetSDRUser()
    {
    	return SLA_Configuration.GetSLAUser();
    	/*
    	List<User> users = [Select ID, Name from User where IsActive=True And (Profile.Name = 'Box: SDR Manager' Or Profile.Name='Box: Sales Development Rep') Limit 1];
    	return (users.size()>0)?users[0]:null;
    	*/
    }
    
    public static List<Lead> initTestLeads(String prefix, Integer count)
    {
    	List<Lead> results = new List<Lead>();
    	for(Integer x=0; x<count; x++)
    	{
    		results.add(new Lead(LastName = prefix + '_' + string.ValueOf(x), 
    			Company = prefix + '_' + string.ValueOf(x), Contact_Method__c = 'Chat'));
    	}
		return results;
    }
    
	 public static List<Campaign> initTestCampaigns(String prefix, Integer count)
	 {
	 	List<Campaign> camps = new List<Campaign>();
	 	for(Integer x=1; x<count+1; x++)
	 	{
	 		camps.add(new Campaign(Name = prefix+'_'+ String.ValueOf(x), IsActive = true, Campaign_SLA__c = 24));
	 	}
	 	return camps;
	 }
    
    
    
}