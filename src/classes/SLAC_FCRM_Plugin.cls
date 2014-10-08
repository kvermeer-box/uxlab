global without sharing class SLAC_FCRM_Plugin implements FCRM.FCR_ExtensibilityAPI.IExtensibilityPlugin {

    public static final String ACTIVERESPONSEPROCESSED = 'ActiveResponseProcessed'; // Response has been processed on Contact or contact
    public static final String STATUSOROWNERCHANGE = 'StatusOrOwnerChange'; // Status has changed on Contact, contact or person account
    public static final String TIMEDASYNC = 'TimedAsync';
    public static final String NOTIFICATIONREQUEST = 'NotificationRequest';
    
    public static List<SLAC_Notification_Support__c> notificationMessagesToProcess = new List<SLAC_Notification_Support__c>();

    public static Boolean DisableTriggersForInternalDML = false;    // Ignore triggers during internal DML

    global String GetUniqueName() { return 'boxSLACplugin' ;}
    global Set<String> RequestedAPIs() { return new Set<String>{ACTIVERESPONSEPROCESSED, STATUSOROWNERCHANGE, TIMEDASYNC, NOTIFICATIONREQUEST} ;}
    global Map<String,Set<String>> RequestedFields() 
    { 
        return new Map<String, Set<String>>{ 'CampaignMember'=> new Set<String>{'Contact_First_SLA_Start__c','IsWebTrial__c', 'IsCCFreeTrial__c', 'Contact_First_SLA_End__c','Contact_First_SLA_Owner__c','Contact_First_SLA_Owner_Role__c'}};
    }
    
    
    
    global void ExtensibilityEvent(String eventname, FCRM.FCR_ExtensibilityAPI.IExtensibilityEventArgs args) {
        
        if(DisableTriggersForInternalDML) return;        

        if(eventname==NOTIFICATIONREQUEST)
        {
            if (args.getAdditionalParams() == null || args.getAdditionalParams()[0] == null) return;    
            FCRM.FCR_ExtensibilityAPI.NotificationHookItem notificationObj = (FCRM.FCR_ExtensibilityAPI.NotificationHookItem)args.getAdditionalParams()[0]; 
            
            // Check if notification objs are for active responses and with target object Contact   
            if (notificationObj.isActiveResponseTemplate != null && notificationObj.leadOrContactId != null 
                && notificationObj.isActiveResponseTemplate && String.valueOf(notificationObj.leadOrContactId).startsWith('003'))
            {
                Messaging.Singleemailmessage message = (Messaging.Singleemailmessage)notificationObj.message;
                notificationMessagesToProcess.add(new SLAC_Notification_Support__c(
                    orgWideEmailAddressId__c = message.OrgWideEmailAddressID,
                    plainTextBody__c = message.plainTextBody,
                    subject__c = message.subject,
                    targetObjectId__c = message.targetObjectId,
                    whatId__c = notificationObj.leadOrContactId
                ));             
            }   
            // No more notifications come in so store the message data in a SLAC_Notification_Support__c record to be processed in an ACTIVERESPONSEPROCESSED event
            else if (notificationObj.processingComplete==true && notificationMessagesToProcess.size() > 0)
            {
                insert notificationMessagesToProcess;
                notificationMessagesToProcess = new List<SLAC_Notification_Support__c>();
            }       
        }        
        
        if(eventname==ACTIVERESPONSEPROCESSED)
        {
            List<ID> recordstoprocess;
            if(args.getRecordIDs()==null) return;
            if(args.getRecordIDs().size()>0) recordstoprocess = args.getRecordIDs()[0];
            if(recordstoprocess==null | recordstoprocess.size()==0) return;
            if(recordstoprocess[0].getSObjectType()!= Contact.SObjectType) return;
            
            List<Messaging.Singleemailmessage> notificationMessages = new List<Messaging.Singleemailmessage>(); 
            List<SLAC_Notification_Support__c> notificationSupportObjs = [Select orgWideEmailAddressId__c, whatId__c, plainTextBody__c, subject__c, targetObjectId__c From SLAC_Notification_Support__c];           
            
            // This will pull the fields that we require as well
            Map<Id, CampaignMember> activeResponses = new Map<Id, CampaignMember>(FCRM.FCR_SupportAPI.GetActiveResponses(recordstoprocess));
            List<CampaignMember> responses = [Select Id, ContactId, LeadId, FCRM__FCR_Campaign_Repeat_Parent__c, CampaignId, 
                Contact_First_SLA_Start__c, IsWebTrial__c, IsCCFreeTrial__c, Contact_SLA_Hours__c, Contact_First_SLA_End__c, Contact_First_SLA_Owner__c, Contact_First_SLA_Owner_Role__c
                From CampaignMember Where Id IN :activeResponses.keySet()];

            // Get updated list of Contacts to process
            Set<ID> contactsToProcess = new Set<ID>();
            // Process if contact ID is found
            for(CampaignMember cm: responses) if(cm.ContactID!=null) contactsToProcess.add(cm.ContactId);

            String querystring = 'Select ID, OwnerID, FCRM__FCR_Status__c, AccountId, First_SLA_End__c, FCRM__FCR_Admin_Update_Counter__c, SLA_Type__c from Contact where ID in :contactsToProcess';
            List<Contact> relatedContactsList = (List<Contact>)Database.query(querystring);
            Map<ID, Contact> relatedContacts = new Map<ID, Contact>(relatedContactsList);
            
            SLAC_Support supportclass = new SLAC_Support();
            List<CampaignMember> responsesprocessed = supportclass.ProcessNewResponses(responses, relatedContacts);

            if(responsesprocessed!=null && responsesprocessed.size()>0)
            {
                // Update any responses that need an update
                update responsesprocessed;
                
                // Figure out which contacts need to be updated, and update those as well
                Set<Id> contactIdsToProcess = new Set<Id>();
                for(CampaignMember cm: responsesprocessed) contactIdsToProcess.add(cm.ContactId);
                List<Contact> contactstoupdate = new List<Contact>();
                for(ID contactid: contactIdsToProcess) contactstoupdate.add(relatedContacts.get(contactid));
                
                if (System.isFuture() || System.isBatch()) SLAC_Support.scheduleAsyncContactUpdate(contactstoupdate);
                else update contactstoupdate;               
                
                if (notificationSupportObjs.size() > 0) supportclass.sendAdditionalNotifications(contactstoupdate, notificationSupportObjs);
            }
            
            List<Database.DeleteResult> drs = Database.Delete(notificationSupportObjs, false);
            HardDeleteObjects(drs);            
                         
        }
        
        if (eventname == TIMEDASYNC && args.getXMLdata() != null)
        {
            SLAC_Support.processFirstSLAContacts(args.getXMLdata());
        }        
        
        if(eventname==STATUSOROWNERCHANGE)
        {
            List<SObject> sobjectlist;
            List<Contact> contactlist;
            Map<ID,Contact> oldcontactmap;
            if(args.getRecordLists()==null || args.getRecordMaps()==null
                || args.getRecordLists().size()==0 || args.getRecordMaps().size()==0) return;
            
            sobjectlist = args.getRecordLists()[0];

            if(sobjectlist.size()==0) return;
            
            SLAC_Support supportclass = new SLAC_Support();
            
            if(sobjectlist[0].getSObjectType()== Contact.SObjectType)
            {
                Map<ID, Contact> modifiedContacts = new Map<ID,Contact>();   // Map to Contacts that are modified
                contactlist = (List<Contact>)sobjectlist;
                oldcontactmap = (Map<ID, Contact>)args.getRecordMaps()[0];
                // Get the related responses
                
                List<CampaignMember> relatedcms = null;
                if(args.getRecordLists().size()>1 && args.getRecordLists()[1]!=null && args.getRecordLists()[1].getSObjectType()==CampaignMember.SObjectType) relatedcms = (List<CampaignMember>)args.getRecordLists()[1]; 
                
                // relatedcms might be null on api prior to 1.7.2
                if(relatedcms==null) relatedcms = FCRM.FCR_SupportAPI.GetActiveResponses(new List<ID>(oldcontactmap.keyset()));
                
                Map<Id, CampaignMember> relatedcmsMap = new Map<Id, CampaignMember>(relatedcms);
                
                relatedcms = [Select Id, ContactId, LeadId, FCRM__FCR_Campaign_Repeat_Parent__c, CampaignId, 
                    Contact_First_SLA_End__c, Contact_First_SLA_Achieved__c
                    From CampaignMember Where Id IN :relatedcmsMap.keySet()];                
                
                // Find Contacts with status change
                List<Contact> statuschangeContacts = new List<Contact>();
                for(Contact ct : contactlist) 
                {
                    if (oldcontactmap.get(ct.id).FCRM__FCR_Status__c == 'Open - Not Contacted'
                        && (ct.FCRM__FCR_Status__c == 'Attempting Contact' || ct.FCRM__FCR_Status__c == 'Working')) statuschangeContacts.add(ct);                   
                }
                
                // Check for SLA on Contacts with status change, and place results in the modified map
                modifiedContacts.putall(supportclass.SLAAttainmentCheck(statuschangeContacts, relatedcms));
                
                // Called in before trigger, so Contact modifications are done. Which CampaignMembers need updating?
                List<CampaignMember> cmschanged = new List<CampaignMember>();
                for(CampaignMember cm: relatedcms)
                {
                    if(modifiedContacts.containskey(cm.ContactID)) cmschanged.add(cm);
                }
                
                Database.Update(cmschanged,false);
                
            }
        }       
        
    }

    public static void HardDeleteObjects(List<Database.DeleteResult> drs)
    {
        List<ID> drids = new List<ID>();
        for(Database.DeleteResult dr: drs)
        {
            if(dr.isSuccess()) drids.add(dr.id);
            if(drids.size()==199)
            {
                Database.emptyRecycleBin(drids); drids.clear();
            }               
        }
        if(drids.size()>0) Database.emptyRecycleBin(drids);
    }

}