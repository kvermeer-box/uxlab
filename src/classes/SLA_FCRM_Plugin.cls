global without sharing class SLA_FCRM_Plugin implements FCRM.FCR_ExtensibilityAPI.IExtensibilityPlugin {

	public static final String ACTIVERESPONSEPROCESSED = 'ActiveResponseProcessed'; // Response has been processed on lead or contact
	public static final String STATUSOROWNERCHANGE = 'StatusOrOwnerChange'; // Status has changed on lead, contact or person account

	public static Boolean DisableTriggersForInternalDML = false;	// Ignore triggers during internal DML

	global String GetUniqueName() { return 'boxplugin' ;}
	global Set<String> RequestedAPIs() { return new Set<String>{ACTIVERESPONSEPROCESSED, STATUSOROWNERCHANGE} ;}
	global Map<String,Set<String>> RequestedFields() 
	{ 
		return new Map<String, Set<String>>{ 'CampaignMember'=> new Set<String>{'SLA_Cycles__c','SLA_Expires__c','SLA_Achieved__c','First_SLA_Owner__c','Second_SLA_Owner__c','SLA_Hours__c'}};
	}
	global void ExtensibilityEvent(String eventname, FCRM.FCR_ExtensibilityAPI.IExtensibilityEventArgs args) {
		
		if(DisableTriggersForInternalDML) return;
		
		if(eventname==ACTIVERESPONSEPROCESSED)
		{
			List<ID> recordstoprocess;
			if(args.getRecordIDs()==null) return;
			if(args.getRecordIDs().size()>0) recordstoprocess = args.getRecordIDs()[0];
			if(recordstoprocess==null | recordstoprocess.size()==0) return;
			if(recordstoprocess[0].getSObjectType()!= Lead.SObjectType) return;
			
			// This will pull the fields that we require as well
			List<CampaignMember> responses = FCRM.FCR_SupportAPI.GetActiveResponses(recordstoprocess);

			// Get updated list of leads to process
			Set<ID> leadstoprocess = new Set<ID>();
			// Don't process if contact ID is found - indicates lead is already converted
			for(CampaignMember cm: responses) if(cm.ContactID==null) leadstoprocess.add(cm.LeadID);
			
			//Map<ID, Lead> relatedleads = new Map<ID, Lead>([Select ID, OwnerID, SLA_Cycles__c, SLA_Expires__c from Lead where ID in :leadstoprocess]);

			String querystring = SLA_Support.GetLeadQueryString('Select ID, OwnerID, SLA_Cycles__c, SLA_Expires__c', 'from Lead where ID in :leadstoprocess');
			system.debug(querystring);
			Map<ID, Lead> relatedleads = new Map<ID, Lead>((List<Lead>)Database.query(querystring));

			SLA_Support supportclass = new SLA_Support();
			List<CampaignMember> responsesprocessed = supportclass.ProcessNewResponses(responses, relatedleads);
			
			if(responsesprocessed!=null && responsesprocessed.size()>0)
			{
				// Update any responses that need an update
				database.update(responsesprocessed, false);
				
				// Figure out which leads need to be updated, and update those as well
				leadstoprocess.clear();
				for(CampaignMember cm: responsesprocessed) leadstoprocess.add(cm.LeadID);
				List<Lead> leadstoupdate = new List<Lead>();
				for(ID leadid: leadstoprocess) leadstoupdate.add(relatedleads.get(leadid));
				
				database.update(leadstoupdate,false);
			}
						 
		}
		if(eventname==STATUSOROWNERCHANGE)
		{
			List<SObject> sobjectlist;
			List<Lead> leadlist;
			Map<ID,Lead> oldleadmap;
			if(args.getRecordLists()==null || args.getRecordMaps()==null
				|| args.getRecordLists().size()==0 || args.getRecordMaps().size()==0) return;
			
			sobjectlist = args.getRecordLists()[0];

			if(sobjectlist.size()==0) return;
			
			SLA_Support supportclass = new SLA_Support();
			
			if(sobjectlist[0].getSObjectType()== Lead.SObjectType)
			{
				Map<ID, Lead> modifiedleads = new Map<ID,Lead>();	// Map to leads that are modified
				leadlist = (List<Lead>)sobjectlist;
				oldleadmap = (Map<ID, Lead>)args.getRecordMaps()[0];
				// Get the related responses
				
				List<CampaignMember> relatedcms = null;
				if(args.getRecordLists().size()>1 && args.getRecordLists()[1]!=null && args.getRecordLists()[1].getSObjectType()==CampaignMember.SObjectType) relatedcms = (List<CampaignMember>)args.getRecordLists()[1]; 
				
				// relatedcms might be null on api prior to 1.7.2
				if(relatedcms==null) relatedcms = FCRM.FCR_SupportAPI.GetActiveResponses(new List<ID>(oldleadmap.keyset()));
				
				// Find leads with status change
				List<Lead> statuschangeleads = new List<Lead>();
				for(Lead ld: leadlist) if(ld.Status != oldleadmap.get(ld.id).Status) statuschangeleads.add(ld);
				
				// Check for SLA on leads with status change, and place results in the modified map
				modifiedleads.putall(supportclass.SLAAttainmentCheck(statuschangeleads, relatedcms));
				
				List<Lead> ownerchangeleads = new List<Lead>();
				for(Lead ld: leadlist) if(ld.OwnerID != oldleadmap.get(ld.id).OwnerID) ownerchangeleads.add(ld);
				
				// Check for claimed leads and add results ot the modified map
				modifiedleads.putall(supportclass.LeadsClaimed(ownerchangeleads, oldleadmap, relatedcms));
				
				// Check for owner changed leads and add results ot the modified map
				modifiedleads.putall(supportclass.LeadsOwnersChanged(ownerchangeleads, oldleadmap, relatedcms));
				
				// Called in before trigger, so lead modifications are done. Which CampaignMembers need updating?
				List<CampaignMember> cmschanged = new List<CampaignMember>();
				for(CampaignMember cm: relatedcms)
				{
					if(modifiedleads.containskey(cm.LeadID)) cmschanged.add(cm);
				}
				
				Database.Update(cmschanged,false);
				
			}
			
			
			
			
			
		}		
		
	}


}