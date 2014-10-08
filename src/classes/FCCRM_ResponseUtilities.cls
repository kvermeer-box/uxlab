global class FCCRM_ResponseUtilities {

	public static List<CampaignMember> FindDQdTrialResponse(List<Id> personIds)
	{
		List<CampaignMember> responses = new List<CampaignMember>();
		
		InAppRestSettings__c setting = InAppRestSettings__c.getInstance('default');
		List<String> disqualifiedStatusValues = setting.Disqualified_Response_Status_Values__c.split(';');
		Date minResponseDate = Date.today() - (Integer)setting.Last_X_Days_Responded__c;
		
		List<CampaignMember> DQdresponses = [Select Id, ContactId, LeadId From CampaignMember 
			Where (LeadId IN :personIds or ContactId IN :personIds)
				and FCRM__FCR_Response_Status__c IN :disqualifiedStatusValues
				and FCRM__FCR_Response_Date__c > :minResponseDate
			Order By FCRM__FCR_Response_Date__c DESC];
		
		Set<Id> personIdsToExclude = new Set<Id>();
			
		if (DQdresponses.size() > 0)
		{
			// Add most recent DQ'd response									
			responses.addAll(getRecentResponses(DQdresponses));
			
			// Exclude person Ids where DQ'd response is found from personIds			
			//if (responses.size() < personIds.size())
			//{	// Not sure why you had this check - seems we always want the most recent DQ response for each contact on this list
			// If we don't include all of them, we may fail to exclude the contact in the next query, resulting
			// in two responses on the list 
			for (CampaignMember cm : responses) personIdsToExclude.add(cm.ContactId != null ? cm.ContactId : cm.LeadId);
			//}
											
		} 
		
		List<CampaignMember> activeWTresponses = [Select Id, ContactId, LeadId From CampaignMember 
			Where (LeadId IN :personIds or ContactId IN :personIds)
				and (LeadId NOT IN :personIdsToExclude and ContactId NOT IN :personIdsToExclude)
				and IsWebTrial__c = true
				and FCRM__FCR_Response_Date__c > :minResponseDate
				and (FCRM__FCR_Response_Status__c = 'Resolved - No Action Required' or FCRM__FCR_Response_Status__c = 'Resolved - Already Engaged')
			Order By FCRM__FCR_Response_Date__c DESC];
			
		if (activeWTresponses.size() > 0)
		{
			// Add most recent active web trial campaign 
			responses.addAll(getRecentResponses(activeWTresponses));
		}
		
		return responses;
	}
	
	// Returns a list of the first CampaignMembers per person id seen in cms. 
	// Assumes the list of CampaignMembers is ordered by most recent (FCRM__FCR_Response_Date__c) in descending order  
	public static List<CampaignMember> getRecentResponses(List<CampaignMember> cms)
	{
		Set<Id> personIdsSeen = new Set<Id>();
		List<CampaignMember> recentResponse = new List<CampaignMember>();
		for (CampaignMember cm : cms)
		{
			if (!personIdsSeen.contains(cm.ContactId) && !personIdsSeen.contains(cm.LeadId))
			{
				recentResponse.add(cm);
				personIdsSeen.add(cm.ContactId != null ? cm.ContactId : cm.LeadId);
			}
		}
		return recentResponse;
	} 

}