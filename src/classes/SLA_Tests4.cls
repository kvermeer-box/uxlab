@isTest
private class SLA_Tests4 {

	private final static Integer bulksize = 5; 

    static testMethod void TestTransferToNonSLAOwner() {
        User u = SLA_Tests1.GetSDRUser();
        if(u==null) return;	// Can't test without user

		// Initialize outside of the runas term to prevent initial user from being SLA
       	SLA_Configuration config = new SLA_Configuration(u.UserRole.DeveloperName);

       	List<Lead> testleads = SLA_Tests1.initTestLeads('slatest', bulksize);
       	List<Campaign> camps = SLA_Tests1.initTestCampaigns('slacamp',1);
        List<CampaignMember> cms = new List<CampaignMember>();

       	Map<ID, Lead> leadmap;

        
        System.RunAs(u)
        {
        	insert testleads;
        	
        	insert camps;
        	
        	// Create active response. Note, SeeAllData is off, so FCRM application is disabled
        	for(Integer x = 0; x< bulksize; x++) 
        		cms.add(new CampaignMember(LeadID = testleads[x].id, CampaignID = camps[0].id, 
        		FCRM__FCR_Response_Status__c = 'Open - Not Contacted', FCRM__FCR_Response_Date__c = DateTime.Now()));
        	insert cms;
        	
        	leadmap = new Map<ID, Lead>(testleads);
        }

        	
        SLA_FCRM_Plugin plugin = new SLA_FCRM_Plugin();
        FCRM.FCR_ExtensibilityAPI.IExtensibilityEventArgs args = new SLA_Tests1.Args(null, null, new List<ID>(leadmap.keyset()));
        	
        plugin.ExtensibilityEvent(SLA_FCRM_Plugin.ACTIVERESPONSEPROCESSED, args);

		// Requery for latest field values so the comparison will work
       	testleads = [Select ID, Status, OwnerID, SLA_Cycles__c, SLA_Expires__c from Lead where ID in :leadmap.keyset()];
		leadmap = new Map<ID, Lead>(testleads);
			
		// Clone the leads
		List<Lead> clonedleads = testleads.DeepClone(true);
		for(Lead ld: clonedleads) ld.OwnerID = UserInfo.getUserId();

		Test.StartTest();
		args = new SLA_Tests1.Args(clonedleads, leadmap, null);
       	plugin.ExtensibilityEvent(SLA_FCRM_Plugin.STATUSOROWNERCHANGE, args);

       	Test.StopTest();

       	Map<ID, CampaignMember> cmmap = new Map<ID, CampaignMember>(cms);
        	
       	List<CampaignMember> cmresults = [Select id, Transferred_to_Non_SLA_Owner__c, SLA_Cycles__c, First_SLA_Owner__c, SLA_Achieved__c from Campaignmember where id in :cmmap.keyset()];
    	for(Lead ld: clonedleads)
    	{
    		System.assertEquals(null, ld.SLA_Cycles__c);
    		System.assertEquals(null, ld.SLA_Expires__c);
    	}

    	for(CampaignMember cm: cmresults)
    	{
    		System.Assert(cm.Transferred_to_Non_SLA_Owner__c);
    	}
        
    } 

    static testMethod void TestTransferFromNonSLAOwner1() {
        User u = SLA_Tests1.GetSDRUser();
        if(u==null) return;	// Can't test without user

		// Initialize outside of the runas term to prevent initial user from being SLA
       	SLA_Configuration config = new SLA_Configuration(u.UserRole.DeveloperName);

       	List<Lead> testleads = SLA_Tests1.initTestLeads('slatest', bulksize);
       	List<Campaign> camps = SLA_Tests1.initTestCampaigns('slacamp',1);
        List<CampaignMember> cms = new List<CampaignMember>();

       	Map<ID, Lead> leadmap;

        
       	insert testleads;
        	
       	insert camps;
        	
    	// Create active response. Note, SeeAllData is off, so FCRM application is disabled
    	for(Integer x = 0; x< bulksize; x++) 
    		cms.add(new CampaignMember(LeadID = testleads[x].id, CampaignID = camps[0].id, 
    		FCRM__FCR_Response_Status__c = 'Open - Not Contacted', FCRM__FCR_Response_Date__c = DateTime.Now()));
    	insert cms;

		List<Lead> clonedleads;
       	leadmap = new Map<ID, Lead>(testleads);

		System.RunAs(u)
		{

	        	
	        SLA_FCRM_Plugin plugin = new SLA_FCRM_Plugin();
	
			// Requery for latest field values so the comparison will work
	       	//testleads = [Select ID, Status, OwnerID, SLA_Cycles__c, SLA_Expires__c from Lead where ID in :leadmap.keyset()];
	       	testleads = new SLA_Tests1.SLA_TestSupport().queryleads(leadmap.keyset());
			leadmap = new Map<ID, Lead>(testleads);
			
			// Clone the leads
			clonedleads = testleads.DeepClone(true);
			for(Lead ld: clonedleads) ld.OwnerID = u.id;
			
			Test.StartTest();
			FCRM.FCR_ExtensibilityAPI.IExtensibilityEventArgs args = new SLA_Tests1.Args(clonedleads, leadmap, null);
	       	plugin.ExtensibilityEvent(SLA_FCRM_Plugin.STATUSOROWNERCHANGE, args);
	
	       	Test.StopTest();
			
		}

       	Map<ID, CampaignMember> cmmap = new Map<ID, CampaignMember>(cms);
        	
       	List<CampaignMember> cmresults = [Select id, SLA_Cycles__c, First_SLA_Owner__c, SLA_Achieved__c from Campaignmember where id in :cmmap.keyset()];
    	for(Lead ld: clonedleads)
    	{
    		System.assertEquals(1, ld.SLA_Cycles__c);
    		System.assertNotEquals(null, ld.SLA_Expires__c);
    	}

    	for(CampaignMember cm: cmresults)
    	{
    		System.AssertEquals(1, cm.SLA_Cycles__c);
    	}
        
    } 


}