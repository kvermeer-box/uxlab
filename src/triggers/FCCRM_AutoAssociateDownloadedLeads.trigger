trigger FCCRM_AutoAssociateDownloadedLeads on Lead (after insert) {

	// Generic settings
	public static final FccrmInternalSettings__c settings;	
	
	// Data.com settings
	public static final String DATACOM_CAMPAIGN_ID;
	public static final String DATACOM_LEAD_SOURCE;
	
	// DiscoverOrg settings
	public static final String DISCOVERORG_CAMPAIGN_ID;
	public static final String DISCOVERORG_API_USER_ID;
	 
	try {
		settings                = FccrmInternalSettings__c.getInstance('default');
		DATACOM_CAMPAIGN_ID     = settings.Data_com_Campaign_Id__c;
		DATACOM_LEAD_SOURCE     = settings.Data_com_Lead_Source__c;
		DISCOVERORG_CAMPAIGN_ID = settings.DiscoverOrg_Campaign_Id__c;
		DISCOVERORG_API_USER_ID = settings.DiscoverOrg_API_User_Id__c;
	} catch (Exception e) {
		System.debug('FccrmInternalSettings__c not yet initialized. Killing...');
		return;
	}
	
	public static Integer iteration = 0;
	if (iteration == 0) {
		System.debug('FCCRM_AutoAssociateDownloadedLeads iteration: ' + iteration);
		iteration++;
	
		List<CampaignMember> newMembersList = new List<CampaignMember>();
		for (Lead l : Trigger.new) {
			System.debug('Checking if ' + l.Id + ' should be automatically associated with a campaign...');
			
			// Data.com Check
			if (l.LeadSource != null && DATACOM_LEAD_SOURCE != null && !DATACOM_LEAD_SOURCE.equals('') && l.LeadSource.equals(DATACOM_LEAD_SOURCE)) {
				CampaignMember m = FCCRM_AssociateCampaignUtils.associateLeadToCampaign(l.Id, DATACOM_CAMPAIGN_ID);
				if (m != null) {
					newMembersList.add(m);
					System.debug('Lead ' + l.Id + ' will be associated with the Data.com campaign ' + DATACOM_CAMPAIGN_ID);
					break;
				}
			}
			
			// DiscoverOrg Check
			if (l.CreatedById == DISCOVERORG_API_USER_ID) {
				CampaignMember m = FCCRM_AssociateCampaignUtils.associateLeadToCampaign(l.Id, DISCOVERORG_CAMPAIGN_ID);
				if (m != null) {
					newMembersList.add(m);
					System.debug('Lead ' + l.Id + ' will be associated with the DiscoverOrg campaign ' + DISCOVERORG_CAMPAIGN_ID);
					break;
				}
			}
		}
	
		if (newMembersList != null && newMembersList.size() > 0) {
			insert newMembersList;
			System.debug(newMembersList.size() + ' campaign members inserted.');
		}		
	}
}