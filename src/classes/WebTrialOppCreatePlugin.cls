global without sharing class WebTrialOppCreatePlugin implements FCRM.FCR_ExtensibilityAPI.IExtensibilityPlugin {

    public static final String ACTIVERESPONSEPROCESSED = 'ActiveResponseProcessed'; // Response has been processed on lead or contact
    global static final String INACTIVETQRESPONSEPROCESSED = 'InactiveTQResponseProcessed'; // Inactive but qualified Response has been processed on lead or contact
    public static final String INACTIVENONTQRESPONSEPROCESSED ='InactiveNonTQResponseProcessed';	// Inactive and not qualified
    public static final String TIMEDASYNC = 'TimedAsync';   

    global String GetUniqueName() { return 'WebTrialOppCreatePlugin' ;}
    global Set<String> RequestedAPIs() { return new Set<String>{ACTIVERESPONSEPROCESSED, INACTIVETQRESPONSEPROCESSED, TIMEDASYNC, INACTIVENONTQRESPONSEPROCESSED} ;}
    global Map<String,Set<String>> RequestedFields() { return new Map<String,Set<String>>(); }
    private static InAppRestSettings__c restsetting = InAppRestSettings_cs.getInstance('default');
    
    global void ExtensibilityEvent(String eventname, FCRM.FCR_ExtensibilityAPI.IExtensibilityEventArgs args) {

        if (eventname == ACTIVERESPONSEPROCESSED || eventname == INACTIVETQRESPONSEPROCESSED || eventname==INACTIVENONTQRESPONSEPROCESSED)
        {
            List<ID> recordstoprocess;
            if(args.getRecordIDs()==null) return;
            if(args.getRecordIDs().size()>0) recordstoprocess = args.getRecordIDs()[0];
            if(recordstoprocess==null | recordstoprocess.size()==0) return;
            if(recordstoprocess[0].getSObjectType()!= Contact.SObjectType) return;

            // Calls this plugin again but in an Async context 
            // Pass it the list of contacts that have a web trials as thier most recent response
            // Most of the time we'll already be in a future context, so it's ok to just process directly
            if(System.isBatch() || System.isFuture())
            {
            	ProcessContactIDs(recordstoprocess);
            }
            else
            {
            	WebTrialOppCreateSupport.scheduleAsyncOppCreation(recordstoprocess);
            }             
        }
        
        if (eventname == TIMEDASYNC && args.getXMLdata() != null)
        {
            // Grab contacts
            List<ID> contactIds = args.getXMLdata().split(',');
            ProcessContactIDs(contactIds);
        }
        
    }
    
    public void ProcessContactIDs(List<ID> CandidateContactIds)
    {
    	// Make sure there is a recent webtrial response that has not been processed
    	DateTime datefilter = DateTime.Now().AddMinutes(-10);
    	List<CampaignMember> recentresponses = [Select ID, ContactID, IsWebTrial__c, CreatedDate, FCRM__FCR_Opportunity__c from CampaignMember where ContactID in :CandidateContactIds and FCRM__FCR_Opportunity__c=null and CreatedDate> :datefilter Order By CreatedDate desc ];
    	Set<ID> ContactIDProcessed = new Set<ID>();
		List<ID> contactIds = new List<ID>();    	
    	
    	// Go through each campaignmember. If the first one for a contact is a webtrial, record it.
    	// Otherwise, note that the contact has been processed, and ignore all further campaignmembers, as they are
    	// not the most recent (recentresponses was sorted descending by createddate)
    	for(CampaignMember cm: recentresponses)
    	{
    		if(!ContactIDProcessed.contains(cm.ContactID) && cm.IsWebTrial__c) contactIds.add(cm.ContactID);
    		ContactIDProcessed.add(cm.ContactID);
    	}
    	if(contactIds.size()==0) return;	// No contacts have their most recent response as a web trial

    	
            Map<Id, Contact> contacts = new Map<Id, Contact>([Select Id, Account.Name, Account.OwnerID, AccountId, OwnerId,
                Initial_Trial_Signup__c, Trial_End_Date__c, Trial_Start_Date__c, Trial_Type__c, Box_Enterprise_ID__c, Contact_Method_Most_Recent__c From Contact 
                Where Id IN :contactIds]);

            List<CampaignMember> activeResponses = FCRM.FCR_SupportAPI.GetActiveResponses(contactIds);
            
            // Create new opportunity for each contact and associate active response to new opp
            if (activeResponses.size() > 0)
            {
                Set<Id> activeResponseIds = new Set<Id>();
                for (CampaignMember cm : activeResponses) activeResponseIds.add(cm.Id);
                // We associate to all active responses, not just if the web trial is true             
                List<CampaignMember> activeResponsesDetailed = [Select Id, ContactId, Reanimation_Audit_Field__c, IsWebTrial__c 
                    From CampaignMember Where ContactId != null and Id IN :activeResponseIds];
                
                Map<Id, Contact> contactsWithActiveResponses = new Map<Id, Contact>();
                List<CampaignMember> activeResponsesToProcess = new List<CampaignMember>();
                for (CampaignMember cm : activeResponsesDetailed) 
                {
                	// Process active response now always - because we know a webtrial just came in.
                   	contactsWithActiveResponses.put(cm.ContactId, contacts.get(cm.ContactId));
                   	activeResponsesToProcess.add(cm);
                   	contacts.remove(cm.ContactId);
                }
                if(activeResponsesToProcess.size()>0) WebTrialOppCreateSupport.createOppsForResponses(activeResponsesToProcess, contactsWithActiveResponses);              
            }
            
            // Exits when all contacts have active responses
            if (contacts.size() == 0) return;
            
            List<Id> remainingContactIds = new List<Id>();
            for (Id cId : contacts.keySet()) remainingContactIds.add(cId);
            List<CampaignMember> DQdAndTrialResponses = FCCRM_ResponseUtilities.FindDQdTrialResponse(remainingContactIds);
                
            // Create new opportunity for each contact and associate non-active Web Trial responses to new opp
            if (DQdAndTrialResponses.size() > 0)
            {
                Set<Id> trailResponseIds = new Set<Id>();
                for (CampaignMember cm : DQdAndTrialResponses) trailResponseIds.add(cm.Id);
                List<CampaignMember> trailResponses = [Select Id, ContactId, FCRM__FCR_Opportunity__c, FCRM__FCR_Response_Status__c, FCRM__FCR_Admin_Response_Control__c, Reanimation_Audit_Field__c From CampaignMember Where ContactId != null and Id IN :trailResponseIds];               
                
                Map<Id, Contact> contactsWithDQedOrTrialResponses = new Map<Id, Contact>();
                for (CampaignMember cm : trailResponses) 
                {
                    contactsWithDQedOrTrialResponses.put(cm.ContactId, contacts.get(cm.ContactId));
                    contacts.remove(cm.ContactId);  
                }
                
                WebTrialOppCreateSupport.createOppsForResponses(trailResponses, contactsWithDQedOrTrialResponses);                  
            }
            
            // Exists when all contacts have either active responses or non-active Web Trial responses 
            if (contacts.size() == 0) return;
            
            // For the remaining responses, create a new response and associated that response with a new Opportunity
            WebTrialOppCreateSupport.createOppAndRespFromContact(contacts.values());    	
    }

}