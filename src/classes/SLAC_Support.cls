// Support class for SLA Contact project
public class SLAC_Support {

    private static Date ReferenceSaturday = Date.newInstance(1970,1,3); // This was a Saturday  
     
    public List<CampaignMember> ProcessNewResponses(List<CampaignMember> newresponses, Map<ID,Contact> relatedContacts)
    {
        Set<ID> campaignids = new Set<ID>();    // We need a set of the campaign IDs
        Set<ID> contactOwners = new Set<ID>();     // We need a set of the contact owners
        List<CampaignMember> cmstoprocess = new List<CampaignMember>(); // Responses to process

        Set<Id> respPromptCampaignIds = FCRM.FCR_SupportAPI.GetResponsePromptCampaignIDs();
        for(CampaignMember cm: newresponses)
        {
            // Check if responses meet the First SLA conditions:
            // The campaign (or repeat) is not a response prompt campaign and not excluded from SLAs.
            // Contact Status is Open - Not Contacted            
            if (cm.ContactID != null
                && !cm.IsWebTrial__c
                && !cm.IsCCFreeTrial__c
                && relatedContacts.get(cm.ContactId).FCRM__FCR_Status__c == 'Open - Not Contacted'
                && ((cm.FCRM__FCR_Campaign_Repeat_Parent__c == null && !respPromptCampaignIds.contains(cm.CampaignId)) 
                    || (cm.FCRM__FCR_Campaign_Repeat_Parent__c != null && !respPromptCampaignIds.contains(cm.FCRM__FCR_Campaign_Repeat_Parent__c)))
                )
            {
                cmstoprocess.add(cm);
                campaignids.add(cm.CampaignID);
                contactOwners.add(relatedContacts.get(cm.ContactId).OwnerID);               
            }                               
        }
        if(cmstoprocess.size()==0) return null; // Nothing to process           
        
        // Get profiles
        Map<ID,User> relatedusers = new Map<ID, User>([Select ID, ProfileID, Profile.Name, UserRole.Name, UserRole.DeveloperName from User where ID in :contactOwners]);
        // Get SLA time
        Map<ID, Campaign> relatedcampaigns = new Map<ID, Campaign>([Select ID, Campaign_SLA__c from Campaign where ID in :campaignids]);    

        List<CampaignMember> modifiedcms = new List<CampaignMember>();

        for(CampaignMember cm: cmstoprocess)
        {           
            cm.Contact_First_SLA_Owner_Role__c = relatedusers.get(relatedContacts.get(cm.ContactId).OwnerID).UserRole.Name; 
            cm.Contact_First_SLA_Owner__c = relatedContacts.get(cm.ContactId).OwnerID;
            cm.Contact_First_SLA_Start__c = Datetime.now();
            cm.Contact_First_SLA_End__c = DateTime.Now().addHours(SLAHours(cm, null));
            relatedContacts.get(cm.ContactId).First_SLA_End__c = cm.Contact_First_SLA_End__c;
            relatedContacts.get(cm.ContactId).SLA_Type__c = cm.Contact_SLA_Hours__c + ' Hour'; 
            relatedContacts.get(cm.ContactId).FCRM__FCR_Admin_Update_Counter__c = relatedContacts.get(cm.ContactId).FCRM__FCR_Admin_Update_Counter__c != null ? relatedContacts.get(cm.ContactId).FCRM__FCR_Admin_Update_Counter__c + 1 : 1; 
            modifiedcms.add(cm);          
        }
        return(modifiedcms);

    }
    
    public void sendAdditionalNotifications(List<Contact> contacts, List<SLAC_Notification_Support__c> notificationSupportObjs)
    {
        if (notificationSupportObjs.size() == 0) return;
        
        SLAC_Configuration__c config = SLAC_Configuration__c.getInstance();     
        List<String> accountTeamRoleLabels = config.Account_Team_Roles_To_Notify__c.split(';');
        
        Set<Id> relatedAccountIds = new Set<Id>();
        for (Contact c : contacts) relatedAccountIds.add(c.AccountId);      
        
        // Fetch contacts' related accounts and their team members with team member role
        Map<Id, AccountTeamMember> relatedAccountTeamMembers = new Map<Id, AccountTeamMember>([Select Id, AccountId, UserId, TeamMemberRole 
            From AccountTeamMember 
            Where AccountId IN :relatedAccountIds
                and TeamMemberRole IN :accountTeamRoleLabels]);        
        
        // Filter out team member users with an inactive user
        Set<Id> accountTeamMemberUserIds = new Set<Id>();
        for (AccountTeamMember atm : relatedAccountTeamMembers.values()) accountTeamMemberUserIds.add(atm.UserId);                              
        Map<Id, User> activeAccountTeamMemberUsers = new Map<Id, User>([Select Id From User Where IsActive = true and Id IN :accountTeamMemberUserIds]);                                 
        for (AccountTeamMember atm : relatedAccountTeamMembers.values())
        {
            if (!activeAccountTeamMemberUsers.containsKey(atm.UserId)) relatedAccountTeamMembers.remove(atm.Id);
        }
        system.debug('relatedAccountTeamMembers' + relatedAccountTeamMembers);
        
        // Filter out team members where the user is the same as the contact's owner
        Map<Id, List<AccountTeamMember>> teamMembersByAccountId = new Map<Id, List<AccountTeamMember>>(); 
        for (AccountTeamMember atm : relatedAccountTeamMembers.values()) 
        {
            if (teamMembersByAccountId.get(atm.AccountId) == null) teamMembersByAccountId.put(atm.AccountId, new List<AccountTeamMember>{atm});
            else teamMembersByAccountId.get(atm.AccountId).add(atm);            
        }                 
        
        // Map of contact owner id by a list of user ids that need the same notification message sent to them        
        Map<Id, Set<Id>> userIdsToNotifyByContactId = new Map<Id, Set<Id>>();           
        
        // Fetch related accounts
        Map<Id, Account> relAccounts = new Map<Id, Account>([Select OwnerId From Account Where Id IN : relatedAccountIds]);
        Set<Id> accountOwnerUserIds = new Set<Id>();
        for (Account acct : relAccounts.values()) accountOwnerUserIds.add(acct.OwnerId);     
        Map<Id, User> activeAccountOwners = new Map<Id, User>([Select Id From User Where IsActive = true and Id IN :accountOwnerUserIds]); 
        
        // Filter out account Owners with an inactive user                                
        for (Account acct : relAccounts.values())
        {
            if (!activeAccountOwners.containsKey(acct.OwnerId)) relAccounts.remove(acct.Id);
        }          
        
        // Add Account owners and Account Team Members that aren't the same as the contact owner              
        for (Contact c : contacts)
        {
            // Adding related Account Owner Id
            if (relAccounts.size() > 0 && relAccounts.containsKey(c.AccountId) && relAccounts.get(c.AccountId).OwnerId != c.OwnerId)
            {
                Id acctOwnerId = relAccounts.get(c.AccountId).OwnerId;
                if (userIdsToNotifyByContactId.get(c.Id) == null) userIdsToNotifyByContactId.put(c.Id, new Set<Id>{acctOwnerId});
                else userIdsToNotifyByContactId.get(c.Id).add(acctOwnerId); 
            }
            
            // Adding Account Team Member user Ids
            if (teamMembersByAccountId.size() > 0 && teamMembersByAccountId.containsKey(c.AccountId))
            {
                for (AccountTeamMember atm : teamMembersByAccountId.get(c.AccountId))
                {
                    if (atm.UserId != c.OwnerId)
                    {
                        if (userIdsToNotifyByContactId.get(c.Id) == null) userIdsToNotifyByContactId.put(c.Id, new Set<Id>{atm.UserId});
                        else userIdsToNotifyByContactId.get(c.Id).add(atm.UserId);  
                    }                           
                }
            }           
        }    
        
        system.debug('userIdsToNotifyByContactId' + userIdsToNotifyByContactId);
        
        // Create new singleemailmessage for each new email notification that needs to be sent out 
        List<Messaging.Singleemailmessage> newNotificationMessages = new List<Messaging.Singleemailmessage>();
        for (SLAC_Notification_Support__c ns : notificationSupportObjs)
        {
            if (userIdsToNotifyByContactId.get(ns.whatId__c) != null)
            {
                for (Id targetId : userIdsToNotifyByContactId.get(ns.whatId__c))
                {
                    Messaging.Singleemailmessage message = new Messaging.Singleemailmessage();
                    message.setTargetObjectId(targetId);
                    message.setSaveAsActivity(false);
                    message.setOrgWideEmailAddressId(ns.orgWideEmailAddressId__c);
                    message.setSubject(ns.subject__c);
                    message.setPlainTextBody(ns.plainTextBody__c);     
                    newNotificationMessages.add(message);      
                }
            }
        }  
        system.debug('newNotificationMessages' + newNotificationMessages);
        
        if (newNotificationMessages.size() > 0)
        {
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(newNotificationMessages, false);
            system.debug('results' + results);      
        }                                     
    }
    
    public static void processFirstSLAContacts(String contactsJSON)
    {
        List<Contact> contactsToUpdate = (List<Contact>)JSON.deserialize(contactsJSON, Type.forName('List<Contact>'));
        update contactsToUpdate;
    }
    
    // Calls the plugin again in an async context
    public static void scheduleAsyncContactUpdate(List<Contact> contacts)    
    {               
        FCRM.FCR_SupportAPI.ScheduleAsyncOperation(
            'boxSLACplugin', 
            Datetime.now().addSeconds(1), 
            JSON.serialize(contacts)
        );      
    }    
    
    public List<Contact> SLAAttainmentCheck(List<Contact> contactstotest, List<CampaignMember> relatedresponses)
    {
        Set<ID> contactowners = new Set<ID>();     // We need a set of the contact owners
        Map<ID, CampaignMember> contactsToResponses = new Map<ID,CampaignMember>();    // Map from contact ID to active response

        for(CampaignMember cm: relatedresponses) contactsToResponses.put(cm.ContactId, cm);

        List<Contact> modifiedcontacts = new List<Contact>();

        List<Contact> contactsToProcess = new List<Contact>();   // Contacts to process
        
        for(Contact ct: contactstotest)
        {
            if (ct.First_SLA_End__c == null) continue;
            contactowners.add(ct.OwnerID);
            contactsToProcess.add(ct);             
        }

        if(contactsToProcess.size()==0) return modifiedcontacts;  // Nothing to process
        
        SLAC_Configuration__c config = SLAC_Configuration__c.getInstance();
        if (config == null) config = new SLAC_Configuration__c(Second_SLA_End_Days__c = 21);
        
        // Get profiles
        Map<ID,User> relatedusers = new Map<ID, User>([Select ID, IsActive, ProfileID, Profile.Name, UserRole.Name, UserRole.DeveloperName from User where ID in :contactowners]);
        
        Set<Id> respPromptCampaignIds = FCRM.FCR_SupportAPI.GetResponsePromptCampaignIDs();
        
        for(Contact ct: contactsToProcess)
        {
            CampaignMember cm = contactsToResponses.get(ct.Id);
            if((relatedusers.get(ct.OwnerId).IsActive && cm.Contact_First_SLA_End__c != null && cm.Contact_First_SLA_Achieved__c == null)
                && ((cm.FCRM__FCR_Campaign_Repeat_Parent__c == null && !respPromptCampaignIds.contains(cm.CampaignId)) 
                    || (cm.FCRM__FCR_Campaign_Repeat_Parent__c != null && !respPromptCampaignIds.contains(cm.FCRM__FCR_Campaign_Repeat_Parent__c))))
            {               
                cm.Contact_First_SLA_Achieved__c = Datetime.now();
                cm.Contact_First_SLA_End__c = Datetime.now();
                cm.Contact_Second_SLA_Owner_Role__c = relatedusers.get(ct.OwnerId).UserRole.Name.length() > 125 ? relatedusers.get(ct.OwnerId).UserRole.Name.substring(0, 125) : relatedusers.get(ct.OwnerId).UserRole.Name;
                cm.Contact_Second_SLA_Owner__c = ct.OwnerId;
                cm.Contact_Second_SLA_Start__c = DateTime.now();
                cm.Contact_Second_SLA_End__c = DateTime.Now().addDays(config.Second_SLA_End_Days__c.intValue());                  
                ct.First_SLA_End__c = null;
                ct.Second_SLA_End__c = cm.Contact_Second_SLA_End__c; 
                ct.SLA_Type__c = config.Second_SLA_End_Days__c.intValue() + ' Days';
                ct.FCRM__FCR_Admin_Update_Counter__c = ct.FCRM__FCR_Admin_Update_Counter__c != null ? ct.FCRM__FCR_Admin_Update_Counter__c + 1 : 1;
                modifiedcontacts.add(ct);
            }    
        }
        return modifiedcontacts;
    }
    
    public static Integer SLAHours(CampaignMember cm, Double customSLAHours)
    {
        if(Test.isRunningTest()) return 2;  // In test mode, we aren't querying our fields        
        double hours = customSLAHours != null ? customSLAHours : (Double)cm.Contact_SLA_Hours__c;
        return SLAHours(hours.intValue());
    }
    
    // Returns the weekeday hours for the specified duration
    public static Integer SLAHours(Integer hoursfromnow)
    {
        Integer weekdayhours = hoursfromnow;
        Integer TodaysWeekDay = Weekday(Date.Today());
        Integer HoursToEndDay = 24 - DateTime.Now().hour();

        // This is a somewhat brute force approach - dealing with the edge conditions
        // mathematically turned out to be complex.

        while (TodaysWeekDay >=5) 
        {   // Today is already a weekend
            weekdayhours+=24;
            TodaysWeekday= Math.Mod(TodaysWeekday+1,7);
        }
                
        while(hoursfromnow >= HoursToEndDay)
        {
            TodaysWeekday= Math.Mod(TodaysWeekday+1,7);
            if(TodaysWeekDay <= 4) hoursfromnow -=24; else weekdayhours+=24;
        }
        
        return weekdayhours;        
    }
    
    // Returns the day of week, where Monday is day 0
    public static Integer Weekday(Date thisdate)
    {
        return math.mod(ReferenceSaturday.AddDays(2).daysBetween(thisdate),7);
    }

}