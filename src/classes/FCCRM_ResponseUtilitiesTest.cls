@isTest
private class FCCRM_ResponseUtilitiesTest {

    static testMethod void TestDisqualifiedFound() {

        InAppRestSettings__c cSettings = new InAppRestSettings__c();
        cSettings.Name = 'default';
        cSettings.Last_X_Days_Responded__c = 30;
        cSettings.Disqualified_Response_Status_Values__c = 'Disqualified';
        insert cSettings;
        
        List<Lead> lds = initTestLeads('lds', 1);		
        insert lds;      
        
        List<Campaign> camps = initTestCampaigns('cmp', 1);
        insert camps;
        
        CampaignMember cmLead = new CampaignMember(Status='Responded', FCRM__FCR_Response_Date__c=Date.today(), LeadId = lds[0].id, CampaignID = camps[0].id);        
        insert cmLead;
        
        cmLead.FCRM__FCR_Response_Status__c = 'Disqualified';
        update cmLead;
        
        Test.startTest();
        List<CampaignMember> cms = FCCRM_ResponseUtilities.FindDQdTrialResponse(new List<Id>{lds[0].Id});        
        Test.stopTest();		
        
        system.assertEquals(cmLead.Id, cms[0].Id);
    }
    
    static testMethod void TestWebTrialCmFound() 
    {
        InAppRestSettings__c cSettings = new InAppRestSettings__c();
        cSettings.Name = 'default';
        cSettings.Last_X_Days_Responded__c = 30;
        cSettings.Disqualified_Response_Status_Values__c = 'Disqualified';
        insert cSettings;
        
        List<Contact> cts = initTestContacts('cts', 1);
        insert cts;                     
        
        List<Campaign> camps = initTestCampaigns('cmp', 1);
        insert camps;
        
        CampaignMember cmContact = new CampaignMember(Status='Responded', IsWebTrial__c=true, FCRM__FCR_Response_Status__c='Resolved - No Action Required', FCRM__FCR_Response_Date__c=Date.today(), ContactId = cts[0].id, CampaignID = camps[0].id);        
        insert cmContact;
        
        Test.startTest();
        List<CampaignMember> cms = FCCRM_ResponseUtilities.FindDQdTrialResponse(new List<Id>{cts[0].Id});        
        Test.stopTest();		
        
        system.assertEquals(cmContact.Id, cms[0].Id);
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


    public static List<Campaign> initTestCampaigns(String prefix, Integer count)
    {
        List<Campaign> camps = new List<Campaign>();
        for(Integer x=1; x<count+1; x++)
        {
          camps.add(new Campaign(Name = prefix+'_'+ String.ValueOf(x), IsActive = true));
        }
        return camps;
    }      
    
    public static List<Lead> initTestLeads(String prefix, Integer count)  
    {    
        List<Lead>lds = new List<Lead>();    
        for(Integer x=1;x<count+1;x++)    
        {      
          lds.add(new Lead(Company= prefix + '_' + String.valueOf(x), LastName = prefix + '_' + String.valueOf(x), Status='Nurture/Marketing'));    
        }    
        return lds;  
    }    
}