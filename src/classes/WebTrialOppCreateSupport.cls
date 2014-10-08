public class WebTrialOppCreateSupport {
    
    private static InAppRestSettings__c restsetting = InAppRestSettings__c.getInstance('default');
    
    private static final String WEBTRIAL_RECORDTYPE_NAME = 'Trial_Opp'; 
    
    // Returns the Web Trial Opportunity Record Type
    private static Id getWebTrialRecordType() {
        List<RecordType> rts = [Select Id From RecordType Where DeveloperName = :WEBTRIAL_RECORDTYPE_NAME];
        if (rts.size() == 1) return rts[0].Id;
        return null;        
    }       
    
    // Calls the plugin again in an async context
    public static void scheduleAsyncOppCreation(List<String> webTrialContactIds)
    {       
        FCRM.FCR_SupportAPI.ScheduleAsyncOperation(
            'WebTrialOppCreatePlugin', 
            Datetime.now().addSeconds(1), 
            String.join(webTrialContactIds, ',')
        );      
    }

    // Creates new Opportunities 
    public static void createOppsForResponses(List<CampaignMember> responses, Map<Id, Contact> contacts)
    {
        Id webTrialRecordTypeId = getWebTrialRecordType();
        Set<Id> seencontacts = new Set<Id>();
        List<Opportunity> newopps = new List<Opportunity>();
        Map<ID,CampaignMember> cmsToUpdate = new Map<ID, CampaignMember>();
        Map<ID, Opportunity> cmsToOpportunity = new Map<ID, Opportunity>();
        for (CampaignMember cm : responses)
        {
            if (!seencontacts.contains(cm.ContactId))
            {
                Contact relcontact = contacts.get(cm.ContactId);
                system.debug('relcontact' + relcontact);
                
                Opportunity newopportunity = new Opportunity(
                        OwnerId = relcontact.OwnerId,
                        Name = relcontact.Account != null ? relcontact.Account.Name : 'Auto created',
                        AccountId = relcontact.AccountId,
                        RecordTypeId = webTrialRecordTypeId,
                        Initial_Trial_Signup__c = relcontact.Initial_Trial_Signup__c, 
                        Trial_End_Date__c = relcontact.Trial_End_Date__c,
                        Trial_Start_Date__c = relcontact.Trial_Start_Date__c,
                        Trial_Type__c = relcontact.Trial_Type__c,
                        Box_Enterprise_ID__c = relcontact.Box_Enterprise_ID__c,
                        Contact_Method_Most_Recent__c = relcontact.Contact_Method_Most_Recent__c,
                        Originating_Contact_Id__c = cm.ContactId,
                        Web_Trial__c = true,
                        Payment_Term__c = 12,
                        Payment_Method__c = 'Credit Card',
                        Admin_Notify_For_New_Webtrial__c = true,
                        StageName = restsetting.Converted_Contact_Opp_Stage__c,
                        CloseDate = relcontact.Trial_End_Date__c != null ? relcontact.Trial_End_Date__c : Date.today() + 14
                    );
                newopps.add(newopportunity);
                cm.Reanimation_Audit_Field__c = Datetime.now();
                cmsToUpdate.put(cm.id, cm);
                cmsToOpportunity.put(cm.id, newopportunity );
                seencontacts.add(cm.ContactId); 
            }
        }
        
        if (newopps.size() > 0)
        {
            insert newopps;
            List<OpportunityContactRole> newocrs = new List<OpportunityContactRole>();
            for (Opportunity opp : newopps)
            {
                newocrs.add(
                    new OpportunityContactRole(
                        ContactId = opp.Originating_Contact_Id__c,
                        IsPrimary = true,
                        Role = 'Primary',
                        OpportunityId = opp.id                  
                    )                   
                );
            }   
            insert newocrs;    
            for(CampaignMember cm: cmsToUpdate.Values())
            {
                Opportunity opp = cmsToOpportunity.get(cm.id);
                cm.FCRM__FCR_Opportunity__c = opp.id;
                cm.FCRM__FCR_Admin_Response_Control__c = 8;
            }     
            // FCRM.FCR_SupportAPI.AssociateOpportunitiesToResponses(newopps); Responses may be inactive, so use control field instead
            update cmsToUpdate.values();      
        }
    }
    
    
    // Creates a new response for each contact and associates the response with the new Opp
    public static void createOppAndRespFromContact(List<Contact> contacts) 
    {
        Id webTrialRecordTypeId = getWebTrialRecordType();
        List<Opportunity> newopps = new List<Opportunity>();        
        for (Contact c : contacts)
        {
            newopps.add(
                new Opportunity(
                    OwnerId = c.OwnerId,
                    Name = c.Account.Name != null ? c.Account.Name : 'Auto created',
                    AccountId = c.AccountId,
                    RecordTypeId = webTrialRecordTypeId,
                    Initial_Trial_Signup__c = c.Initial_Trial_Signup__c, 
                    Trial_End_Date__c = c.Trial_End_Date__c,
                    Trial_Start_Date__c = c.Trial_Start_Date__c,
                    Trial_Type__c = c.Trial_Type__c,
                    Box_Enterprise_ID__c = c.Box_Enterprise_ID__c,
                    Contact_Method_Most_Recent__c = c.Contact_Method_Most_Recent__c,
                    Payment_Term__c = 12,
                    Payment_Method__c = 'Credit Card',
                    Admin_Notify_For_New_Webtrial__c = true,
                    Originating_Contact_Id__c = c.Id,                   
                    Web_Trial__c = true,
                    StageName = restsetting.Converted_Contact_Opp_Stage__c,
                    CloseDate = c.Trial_End_Date__c != null ? c.Trial_End_Date__c : Date.today() + 14                    
                )
            );          
        }
        
        insert newopps;
        
        List<CampaignMember> responsesToInsert = new List<CampaignMember>();
        List<OpportunityContactRole> newocrs = new List<OpportunityContactRole>();
        for (Opportunity opp : newopps)
        {
            newocrs.add(
                new OpportunityContactRole(
                    ContactId = opp.Originating_Contact_Id__c,
                    IsPrimary = true,
                    Role = 'Primary',
                    OpportunityId = opp.id                  
                )                   
            );                          
            responsesToInsert.add(
                new CampaignMember(
                    FCRM__FCR_Admin_Response_Control__c = 10,
                    FCRM__FCR_Opportunity__c = opp.Id,
                    CampaignId = restsetting.Web_Trial_Campaign_ID__c,
                    ContactId = opp.Originating_Contact_Id__c
                )
            );          
        }
        insert responsesToInsert;
        insert newocrs; 
    }

}