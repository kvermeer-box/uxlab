@isTest (SeeAllData=true)
public with sharing class SLACTest {

    static testMethod void testResponseCreateAndNotifications() 
    {
        SLAC_Configuration__c config = SLAC_Configuration__c.getInstance();
        if (config == null) return;
        
        // Register Plugin            
        installPlugin('boxSLACplugin');         
        
        FCRM.FCR_SupportAPI.SetRepeatResponseUserForContext();
        
        List<User> users = [Select Id From User Where IsActive = true and UserRole.Name != null Limit 3];
        
        List<Account> acts = initTestAccounts('aa',1);
        acts[0].OwnerId = users[1].Id;
        insert acts;      
        
        List<String> accountTeamRoleLabels = config.Account_Team_Roles_To_Notify__c.split(';');
        
        AccountTeamMember atm = new AccountTeamMember(AccountId = acts[0].Id, TeamMemberRole = accountTeamRoleLabels[0], UserId = users[2].Id);
        insert atm;        
        
        List<Campaign> camps = initTestCampaigns('cmp', 1);
        insert camps;
        
        List<Contact> cts = initTestContacts('cts', 1);
        cts[0].FCRM__FCR_Status__c = 'Open - Not Contacted';
        cts[0].OwnerId = users[0].Id;
        cts[0].AccountId = acts[0].Id;
        insert cts;    
        
        Map<Id, Contact> contactMap = new Map<Id, Contact>(cts);        
        
        FCRM.FCR_SupportAPI.TreatNextCampaignAssociationsAsResponsePrompts(); 
        CampaignMember newresponse = new CampaignMember(Status='Responded', FCRM__FCR_Response_Date__c=Date.today(), IsWebTrial__c = false, IsCCFreeTrial__c = false, ContactID = cts[0].id, CampaignID = camps[0].id);
        insert newresponse; 
        
        SLAC_Notification_Support__c notificationSupportRecord = new SLAC_Notification_Support__c(
            orgWideEmailAddressId__c =  [select Id from OrgWideEmailAddress][0].Id,
            plainTextBody__c = 'test',
            subject__c = 'test',
            targetObjectId__c = users[0].Id,
            whatId__c = cts[0].Id
        );
        insert notificationSupportRecord;
        
        SLAC_FCRM_Plugin plugin = new SLAC_FCRM_Plugin();   
        FCRM.FCR_ExtensibilityAPI.IExtensibilityEventArgs args = new Args(null, null, new List<ID>(contactMap.keySet()), null);        
        
        Test.startTest();  
        plugin.ExtensibilityEvent(SLAC_FCRM_Plugin.ACTIVERESPONSEPROCESSED, args);     
        SLAC_Support.scheduleAsyncContactUpdate(cts);
        SLAC_Support.processFirstSLAContacts(JSON.serialize(cts));
        Test.stopTest();  
        
                 
    } 
    
    static testMethod void testResponseUpdate() 
    {
        SLAC_Configuration__c config = SLAC_Configuration__c.getInstance();
        if (config == null) return;     
        
        // Register Plugin            
        installPlugin('boxSLACplugin');     
        
        FCRM.FCR_SupportAPI.SetRepeatResponseUserForContext();

        List<User> users = [Select Id From User Where IsActive = true and UserRole.Name != null Limit 1];
        
        List<Campaign> camps = initTestCampaigns('cmp', 1);
        insert camps;
        
        List<Contact> cts = initTestContacts('cts', 1);
        cts[0].FCRM__FCR_Status__c = 'Open - Not Contacted';
        cts[0].OwnerId = users[0].Id;
        insert cts;    
        
        Map<Id, Contact> contactMap = new Map<Id, Contact>(cts);   
        
        List<Contact> contactListBeforeUpdate = contactMap.values().DeepClone(true);
        Map<Id, Contact> contactBeforeUpdate = new Map<Id, Contact>();
        for (Contact c : contactListBeforeUpdate) contactBeforeUpdate.put(c.Id, c);    
        
        FCRM.FCR_SupportAPI.TreatNextCampaignAssociationsAsResponsePrompts(); 
        CampaignMember newresponse = new CampaignMember(Status='Responded', Contact_First_SLA_End__c = DateTime.now(), FCRM__FCR_Response_Date__c=Date.today(), IsWebTrial__c = false, IsCCFreeTrial__c = false, ContactID = cts[0].id, CampaignID = camps[0].id);
        
        insert newresponse;
        
        cts[0].FCRM__FCR_Status__c = 'Attempting Contact';
        cts[0].First_SLA_End__c = DateTime.now();
        
        FCRM.FCR_SupportAPI.DisableApplicationForContext();
        newresponse.Contact_First_SLA_Achieved__c = null; 
        update newresponse;
        FCRM.FCR_SupportAPI.UndoDisableApplicationForContext();
        
        update cts;
        
        Map<Id, Contact> newcts = new Map<Id, Contact>([Select Id, First_SLA_End__c,SLA_Expiration_Date__c, OwnerId, FCRM__FCR_Status__c From Contact Where Id IN :contactMap.keySet()]);
        
        SLAC_FCRM_Plugin plugin = new SLAC_FCRM_Plugin();
        FCRM.FCR_ExtensibilityAPI.IExtensibilityEventArgs args = new Args(newcts.values(), contactBeforeUpdate, null, null);        
        
        SLAC_ScheduledProcess processobject = new SLAC_ScheduledProcess();
        SLAC_ScheduledProcessSupport.ForceExpirationFortest =  DateTime.Now().addDays(15);
        
        Test.startTest();  
        plugin.ExtensibilityEvent(SLAC_FCRM_Plugin.STATUSOROWNERCHANGE, args);
        processobject.execute(null);                
        Test.stopTest();           
        
        List<Contact> updatedcts = [Select Id, SLA_Expiration_Date__c, FCRM__FCR_Status__c From Contact Where Id IN :contactMap.keySet()]; 
        
        for (Contact c : updatedcts)
        {
            system.assert(c.FCRM__FCR_Status__c == 'Disqualified' );
        }  
        
    }     

    // Args class used for testing the plugin
    public Class Args implements FCRM.FCR_ExtensibilityAPI.IExtensibilityEventArgs
    {
        public List<List<Sobject>> Recordlists;
        public List<Map<ID, Sobject>> RecordMaps;
        public List<List<ID>> RecordIds;
        
        public List<List<Sobject>> getRecordLists() { return RecordLists; }
        public List<Map<ID, Sobject>> getRecordMaps() { return RecordMaps; }
        public List<List<ID>> getRecordIds() { return RecordIds; }
        public FCRM.FCR_ExtensibilityAPI.NotificationHookItem notificationHook;
        public List<Object> getAdditionalParams() {return new List<Object>{notificationHook}; }
        public void setRaiseFuture() {  }
        public String getXMLdata() { return null; }
        
        public Args(List<SObject> objlist, Map<ID,SObject> objmap, List<ID> idlist, FCRM.FCR_ExtensibilityAPI.NotificationHookItem notificationHookParam)
        {
            notificationHookParam = notificationHook;
            Recordlists = new List<List<SObject>>{ objlist };
            RecordMaps = new List<Map<ID, SObject>> { objmap };
            RecordIDs = new List<List<ID>> { idlist };
        }       
    }
    
    public static void installPlugin(String pluginname)
    {
        FCRM.FCR_ExtensibilityAPI.EnablePluginsForTest = new Set<String>{pluginname};
        FCRM.FCR_ExtensibilityAPI.InstallPluginClass(pluginname);
    }    

    public static List<Contact> initTestContacts(String prefix, Integer count)  
    {    
        List<Contact>cts = new List<Contact>();    
        for(Integer x=1;x<count+1;x++)    
        {      
          cts.add(new Contact(LastName = prefix + '_' + String.valueOf(x)));
        }
        return cts;  
    }
    
    public static List<Account> initTestAccounts(String prefix, Integer count)
    {
      List<Account> accounts = new List<Account>();
      for(Integer x=1; x<count + 1; x++)
      {
        accounts.add(new Account(Name= prefix + '_' + String.valueOf(x)));    
      }
      return accounts;
    }
        
    
    public static List<Campaign> initTestCampaigns(String prefix, Integer count)
    {
        List<Campaign> camps = new List<Campaign>();
        for(Integer x=1; x<count+1; x++)
        {
          camps.add(new Campaign(Name = prefix+'_'+ String.ValueOf(x), FCRM__FCR_Repeat_Responses_Allowed__c=true, FCRM__FCR_Bypass_Nurture_Timeout__c=true, Exclude_From_Contact_MQL_Routing__c = false, IsActive = true));
        }
        return camps;
    }      

}