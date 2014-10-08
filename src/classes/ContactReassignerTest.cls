@isTest (SeeAllData=true)
public without sharing class ContactReassignerTest {

    static testMethod void testWithReassign() 
    {        
        List<Account> acts = initTestAccounts('aa',1);
        insert acts;        
        
        ID TestUserID = TestDataFactory_hlpr.createUserSimple();
        
        List<User> users = [Select Id From User Where id = :TestUserID];
        AccountTeamMember atm = new AccountTeamMember(AccountId = acts[0].Id, TeamMemberRole = 'Outbound Rep', UserId = users[0].Id);
        insert atm;
        
        List<Campaign> camps = initTestCampaigns('cmp', 1);
        insert camps;
        
        List<Contact> cts = initTestContacts('cts', 1);
        cts[0].AccountId = acts[0].Id;
        insert cts;            
        FCRM.FCR_SupportAPI.TreatNextCampaignAssociationsAsResponsePrompts(); 
        //CampaignMember newresponse = new CampaignMember(Status='Responded', FCRM__FCR_Response_Date__c=Date.today(), IsWebTrial__c = false, IsCCFreeTrial__c = false, ContactID = cts[0].id, CampaignID = camps[0].id);
        CampaignMember newresponse = new CampaignMember(Status='Responded', IsWebTrial__c = false, IsCCFreeTrial__c = false, ContactID = cts[0].id, CampaignID = camps[0].id);
        
        Test.startTest();   
        insert newresponse; 
        CampaignMember response = [Select Id, FCRM__FCR_Response_Status__c, FCRM__FCR_First_Owner_Type__c, FCRM__FCR_First_Owner_Assigned__c From CampaignMember Where Id = :newresponse.Id];

        Boolean TriggerFieldConfigured = true;

        if(response.FCRM__FCR_First_Owner_Assigned__c!=users[0].id)
        {
            // Maybe the trigger isn't configured yet? Try setting manually
            TriggerFieldConfigured = false;
            Contact ct = [Select ID, Trigger_Assignment__c from Contact where ID = :cts[0].id];
            ct.Trigger_Assignment__c = true;
            ContactReassigner.ranOnce = false;    // Clear the flag that prevents repeat processing
            update ct;

        }

        Test.stopTest();       

        if(!TriggerFieldConfigured)
        {    // Validate reassignment only
            Contact ct = [Select ID, OwnerID from Contact where ID = :cts[0].id];
            System.AssertEquals(users[0].id, ct.OwnerID);
            return;
        }
        
        // Validate reassignment and FCRM field settings.
        response = [Select Id, FCRM__FCR_Response_Status__c, FCRM__FCR_First_Owner_Type__c, FCRM__FCR_First_Owner_Assigned__c From CampaignMember Where Id = :newresponse.Id];
        
        system.assertEquals(users[0].Id, response.FCRM__FCR_First_Owner_Assigned__c);
        system.assertEquals('User', response.FCRM__FCR_First_Owner_Type__c);           
    }
    
    static testMethod void testNoReassign() 
    {
        List<Account> acts = initTestAccounts('aa',1);
        insert acts;                
        
        List<User> users = [Select Id From User Where IsActive = true Limit 1];
        AccountTeamMember atm = new AccountTeamMember(AccountId = acts[0].Id, TeamMemberRole = 'Wrong value', UserId = users[0].Id);
        insert atm;
        
        List<Contact> cts = initTestContacts('cts', 1);
        cts[0].AccountId = acts[0].Id;
        insert cts;     
        
        Set<Id> respPromptCampaignIds = FCRM.FCR_SupportAPI.GetResponsePromptCampaignIDs(); 
        List<Campaign> respCamps = [Select Id From Campaign Where Exclude_From_Contact_MQL_Routing__c = false and Id NOT IN :respPromptCampaignIds];
        
        FCRM.FCR_SupportAPI.TreatNextCampaignAssociationsAsResponsePrompts(); 
        CampaignMember responsePrompt = new CampaignMember(Status='Responded', IsWebTrial__c = false, FCRM__FCR_Response_Date__c=Date.today(), IsCCFreeTrial__c = false, ContactID = cts[0].id,  CampaignID = respCamps[0].id);
        
        Test.startTest();   
        insert responsePrompt; 
        Test.stopTest();                  
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