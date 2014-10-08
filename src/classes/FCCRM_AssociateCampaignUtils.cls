global class FCCRM_AssociateCampaignUtils {

	public static CampaignMember associateLeadToCampaign(Id leadId, String campaignId) {
		System.debug('Associating lead to campaign...');
		
		CampaignMember cm;
		if (leadId != null && campaignId != null && !campaignId.equals('')) {
			cm = new CampaignMember();
			cm.LeadId = leadId;
			cm.CampaignId = campaignId;
			cm.Status = 'Responded';
			System.debug('Campaign member has been created and is awaiting insertion.');
		}
		return cm;
	}
	
	public static CampaignMember associateContactToCampaign(Id contactId, String campaignId) {
		System.debug('Associating contact to campaign...');
		
		CampaignMember cm;
		if (contactId != null && campaignId != null && !campaignId.equals('')) {
			cm = new CampaignMember();
			cm.ContactId = contactId;
			cm.CampaignId = campaignId;
			cm.Status = 'Responded';
			System.debug('Campaign member has been created and is awaiting insertion.');
		}
		return cm;
	}	

}