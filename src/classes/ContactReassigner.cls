// Evaluate whether contacts should have their owner reassigned and do reassignement depending on evaluation 
public without sharing class ContactReassigner {
    
    public static Boolean ranOnce = false;
    
    public static void requestHandler(Map<Id, Contact> updatedcontacts) 
    {
        if (ranOnce) return; 
        ranOnce = true;
        
        Map<Id, Contact> contacts = new Map<Id, Contact>();
        for (Contact c : updatedcontacts.values()) contacts.put(c.Id, c);

        Set<Id> noReassignmentContactIds = new Set<Id>();
        Map<Id, Id> newOwnerIdByContactId = new Map<Id, Id>();
        
        for (Contact c : contacts.values()) 
        {
            if (!c.Trigger_Assignment__c) 
            {
                contacts.remove(c.Id);
                noReassignmentContactIds.add(c.Id);
            }           
        }

        if (contacts.size() > 0)
        {
            // Filters out contacts with one or more opportunity active responses
            Map<Id, CampaignMember> activeResponses = new Map<Id, CampaignMember>(FCRM.FCR_SupportAPI.GetActiveResponses(new List<Id>(contacts.keySet()))); 
            List<CampaignMember> activeOppResponseIds = FCRM.FCR_SupportAPI.GetActiveAndOpActiveResponses(new List<Id>(contacts.keySet()));
            
            for (CampaignMember cm : activeOppResponseIds)
            {
                if (!activeResponses.containsKey(cm.Id) && contacts.containsKey(cm.ContactId)) 
                {
                    contacts.remove(cm.ContactId);
                    noReassignmentContactIds.add(cm.ContactId);
                }
            }

            if (contacts.size() > 0)
            {
                Map<Id, CampaignMember> activeResponses2 = new Map<Id, CampaignMember>(FCRM.FCR_SupportAPI.GetActiveResponses(new List<Id>(contacts.keySet())));
                List<CampaignMember> activeResponsesList = [Select Id, FCRM__FCR_Campaign_Repeat_Parent__c, IsWebTrial__c, IsCCFreeTrial__c, ContactId, CampaignId From CampaignMember Where Id IN :activeResponses2.keySet()];      
                
                Map<Id, CampaignMember> activeResponsesToProcess = new Map<Id, CampaignMember>();
                Set<Id> respPromptCampaignIds = FCRM.FCR_SupportAPI.GetResponsePromptCampaignIDs();
                Set<Id> activeResponseCampaignIds = new Set<Id>();
                
                for (CampaignMember cm : activeResponsesList) 
                {
                    // Filter for responses whose related campaign or repeat campaign are response prompts
                    if (!cm.IsWebTrial__c
                        && !cm.IsCCFreeTrial__c 
                        && ((cm.FCRM__FCR_Campaign_Repeat_Parent__c == null && !respPromptCampaignIds.contains(cm.CampaignId))
                            || (cm.FCRM__FCR_Campaign_Repeat_Parent__c != null && !respPromptCampaignIds.contains(cm.FCRM__FCR_Campaign_Repeat_Parent__c)))
                        )
                    {
                        activeResponseCampaignIds.add(cm.FCRM__FCR_Campaign_Repeat_Parent__c != null ? cm.FCRM__FCR_Campaign_Repeat_Parent__c : cm.CampaignId);
                        activeResponsesToProcess.put(cm.Id, cm);
                    }
                }

                if (activeResponsesToProcess.size() > 0)
                {               
                    Map<Id, Campaign> activeResponseCampaigns = new Map<Id, Campaign>([Select Exclude_From_Contact_MQL_Routing__c, Id From Campaign Where Id IN :activeResponseCampaignIds]);
                    
                    // Excludes responses related to a campaign or repeat campaign where Exclude_From_Contact_MQL_Routing__c is false
                    for (CampaignMember cm : activeResponsesToProcess.values())
                    {
                        if (activeResponseCampaigns.get(cm.FCRM__FCR_Campaign_Repeat_Parent__c != null ? cm.FCRM__FCR_Campaign_Repeat_Parent__c : cm.CampaignId).Exclude_From_Contact_MQL_Routing__c)
                        {
                            activeResponsesToProcess.remove(cm.Id);
                        }
                    }
                    
                    if (activeResponsesToProcess.size() > 0)
                    {
                        // Remove contacts whose new active response isn't related to a response prompt campaign or repeat campaign that has Exclude_From_Contact_MQL_Routing__c equal to false
                        Set<Id> activeResponseContactIds = new Set<Id>();     
                        for (CampaignMember cm : activeResponsesToProcess.values()) activeResponseContactIds.add(cm.ContactId);  
                        for (Contact c : contacts.values()) 
                        {
                            if (!activeResponseContactIds.contains(c.Id)) 
                            {
                                contacts.remove(c.Id);
                                noReassignmentContactIds.add(c.Id);
                            }   
                        }   
                        
                        if (contacts.size() > 0)
                        {
                            // Only change owner if contact’s related Account has an account team with a defined ACTIVE user 
                            // with the role ‘Outbound Rep’, and this user is not the Contact owner
                            Set<Id> relatedAccountIds = new Set<Id>();
                            for (Contact c : contacts.values()) relatedAccountIds.add(c.AccountId);
                            
                            // Fetch contacts' related accounts and their team members with team member role "Outbound Rep"
                            Map<Id, AccountTeamMember> relatedAccountTeamMembers = new Map<Id, AccountTeamMember>([Select Id, AccountId, UserId, TeamMemberRole 
                                From AccountTeamMember 
                                Where AccountId IN :relatedAccountIds
                                    and TeamMemberRole = 'Outbound Rep']);
                            
                            // Filter out team member users with an inactive user
                            Set<Id> accountTeamMemberUserIds = new Set<Id>();
                            for (AccountTeamMember atm : relatedAccountTeamMembers.values()) accountTeamMemberUserIds.add(atm.UserId);                              
                            Map<Id, User> activeAccountTeamMemberUsers = new Map<Id, User>([Select Id From User Where IsActive = true and Id IN :accountTeamMemberUserIds]);                                 
                            for (AccountTeamMember atm : relatedAccountTeamMembers.values())
                            {
                                if (!activeAccountTeamMemberUsers.containsKey(atm.UserId)) relatedAccountTeamMembers.remove(atm.Id);
                            }
                            
                            // Filter out team members where the user is the same as the contact's owner
                            Map<Id, AccountTeamMember> teamMemberByAccountId = new Map<Id, AccountTeamMember>(); 
                            for (AccountTeamMember atm : relatedAccountTeamMembers.values()) teamMemberByAccountId.put(atm.AccountId, atm);     
                                              
                            for (Contact c : contacts.values())
                            {
                                if (!teamMemberByAccountId.containsKey(c.AccountId) 
                                    || (teamMemberByAccountId.containsKey(c.AccountId) && teamMemberByAccountId.get(c.AccountId).UserId == c.OwnerId))
                                {
                                    contacts.remove(c.Id);
                                    noReassignmentContactIds.add(c.Id);
                                }
                                else
                                {                                       
                                    newOwnerIdByContactId.put(c.Id, teamMemberByAccountId.get(c.AccountId).UserId); 
                                }
                            }
                            
                        }                                           
                    }   
                    else
                    {
                        // If there are no contacts with a new active response prompt that has Exclude_From_Contact_MQL_Routing__c equal to false, reset all contact notification fields
                        noReassignmentContactIds.addAll(contacts.keySet());                 
                    }                                   
                }
                else
                {
                    // If there are no contacts with a new active response prompt, reset all contact notification fields
                    noReassignmentContactIds.addAll(contacts.keySet());
                }               
            }
                    
        }   
        List<Contact> contactsToUpdate = new List<Contact>();
        // Reset all contact notification fields
        if (noReassignmentContactIds.size() > 0) contactsToUpdate.addAll(ContactReassigner.resetNotificationFields(noReassignmentContactIds));
        // Reassign contact owners                             
        if (newOwnerIdByContactId.size() > 0) contactsToUpdate.addAll(ContactReassigner.reassignOwner(newOwnerIdByContactId));
        update contactsToUpdate;
    }
    
    private static List<Contact> reassignOwner(Map<Id, Id> newOwnerIdByContactId)
    {
        List<Contact> contacts = [Select Trigger_Assignment__c, OwnerId, FCRM__FCR_PostAssignNotificationPending__c From Contact Where Id IN :newOwnerIdByContactId.keySet()];
        for (Contact c : contacts)
        {
            c.OwnerId = newOwnerIdByContactId.get(c.Id);
            c.Trigger_Assignment__c = false;
            c.FCRM__FCR_PostAssignNotificationPending__c = false;
            c.FCRM__FCR_Admin_Update_Counter__c = c.FCRM__FCR_Admin_Update_Counter__c != null ? c.FCRM__FCR_Admin_Update_Counter__c + 1 : 1;
        }
        return contacts;        
    }
    
    private static List<Contact> resetNotificationFields(Set<Id> contactIds)
    {
        List<Contact> contacts = [Select Trigger_Assignment__c, FCRM__FCR_PostAssignNotificationPending__c From Contact Where Id IN :contactIds];
        for (Contact c : contacts)
        {
            c.Trigger_Assignment__c = false;
            c.FCRM__FCR_PostAssignNotificationPending__c = false;
            c.FCRM__FCR_Admin_Update_Counter__c = c.FCRM__FCR_Admin_Update_Counter__c != null ? c.FCRM__FCR_Admin_Update_Counter__c + 1 : 1;
        }
        return contacts;
    }

}