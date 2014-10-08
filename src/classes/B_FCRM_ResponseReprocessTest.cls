@isTest (SeeAllData=True)
private class B_FCRM_ResponseReprocessTest {

    static testMethod void TestInsertedResponse() 
    {       
        
        // Make sure there are Eloqua fields on CampaignMember
        system.assert(eloquaFieldSetMembers.size() > 0);
        
        // Register Plugin    
        installPlugin();        
        
        FCRM.FCR_SupportAPI.SetRepeatResponseUserForContext();
        
        List<Contact> cts = initTestContacts('cts', 1);
        insert cts;
        
        List<Campaign> camps = initTestCampaigns('cmp', cts.size());
        insert camps;
        
        // Each contact has a response
        List<CampaignMember> respondedCms = new List<CampaignMember>();
        CampaignMember cm1 = new CampaignMember(Status='Responded', ContactID = cts[0].id, CampaignID = camps[0].id);                  
                
        setAllEloquaFields(cm1, 'Blank');
        
        // Test response inserted   
        Test.startTest();   
        insert cm1;
        Test.stopTest();
        
        // Check if plugin nullified blank values
        CampaignMember cm1Inserted = Database.query(getCmQuery(cm1.Id));
        system.assert(allEloquaFieldsWithValue(cm1Inserted, null));        
        
    }

    static testMethod void TestUpdatedResponse()
    {
        // Register Plugin    
        installPlugin();          
        
        FCRM.FCR_SupportAPI.SetRepeatResponseUserForContext();
        
        List<Contact> cts = initTestContacts('cts', 3);
        insert cts;
        
        List<Campaign> camps = initTestCampaigns('cmp', 2);
        insert camps;
        
        // Each contact has a response
        List<CampaignMember> respondedCms = new List<CampaignMember>();
        CampaignMember origCm1 = new CampaignMember(Status = 'Responded', FCRM__FCR_Response_Status__c = 'Open - Not Contacted', ContactID = cts[0].id, CampaignID = camps[0].id, FCRM__FCR_Response_Date__c = DateTime.Now().AddDays(-1));
        CampaignMember origCm2 = new CampaignMember(Status='Sent', FCRM__FCR_Response_Status__c = 'Open - Not Contacted', ContactID = cts[1].id, CampaignID = camps[0].id);                                 
        
        setAllEloquaFields(origCm1, FIELD_VALUE_ON_INSERT);
        setAllEloquaFields(origCm2, FIELD_VALUE_ON_INSERT);
        
        Test.startTest();
        FCRM.FCR_SupportAPI.DisableApplicationForContext();
        insert new List<CampaignMember>{origCm1, origCm2};
        FCRM.FCR_SupportAPI.UndoDisableApplicationForContext();    
        setAllEloquaFields(origCm1, FIELD_VALUE_ON_UPDATE);
        setAllEloquaFields(origCm2, FIELD_VALUE_ON_UPDATE);
        origCm2.Status = 'Responded';
        update new List<CampaignMember>{origCm1, origCm2};
        Test.stopTest();
        
        // origCm1Inserted and origCm2Inserted should have same values it had on insert
        CampaignMember origCm1Inserted = Database.query(getCmQuery(origCm1.Id));
        CampaignMember origCm2Inserted = Database.query(getCmQuery(origCm2.Id));
        system.assert(allEloquaFieldsWithValue(origCm1Inserted, FIELD_VALUE_ON_INSERT));
        // Respect new field values when campaign member changes to responded
        system.debug('origCm2Inserted' + origCm2Inserted);
        system.assert(allEloquaFieldsWithValue(origCm2Inserted, FIELD_VALUE_ON_UPDATE)); 
    } 
    
    static testMethod void TestUpdatedNonResponse()
    {
        // Register Plugin    
        installPlugin();          
        
        FCRM.FCR_SupportAPI.SetRepeatResponseUserForContext();
        
        List<Contact> cts = initTestContacts('cts', 3);
        insert cts;
        
        List<Campaign> camps = initTestCampaigns('cmp', 2);
        insert camps;
        
        // Each contact has a response
        List<CampaignMember> respondedCms = new List<CampaignMember>();
        CampaignMember origCm1 = new CampaignMember(Status = 'Responded', FCRM__FCR_Response_Status__c = 'Open - Not Contacted', ContactID = cts[0].id, CampaignID = camps[0].id, FCRM__FCR_Response_Date__c = DateTime.Now().AddDays(-1));                     
        
        setAllEloquaFields(origCm1, FIELD_VALUE_ON_INSERT);
        
        Test.startTest();
        insert origCm1;  
        origCm1.FCRM__FCR_Admin_Response_Control__c = 4;
        setAllEloquaFields(origCm1, FIELD_VALUE_ON_UPDATE);
        update origCm1;
        Test.stopTest();
        
        // origCm1Inserted and origCm2Inserted should have same values it had on insert
        CampaignMember origCm1Inserted = Database.query(getCmQuery(origCm1.Id));
        system.assert(allEloquaFieldsWithValue(origCm1Inserted, FIELD_VALUE_ON_INSERT)); 
    }     
    
    static testMethod void TestRevertClearValuesOnNonResponse()
    {
        installPlugin();
        
        FCRM.FCR_SupportAPI.SetRepeatResponseUserForContext();
        
        List<Contact> cts = initTestContacts('cts', 1);
        insert cts;
        
        List<Campaign> camps = initTestCampaigns('cmp', 1);        
        insert camps;
        
        // Each contact has a response
        List<CampaignMember> respondedCms = new List<CampaignMember>();
        CampaignMember origCm1 = new CampaignMember(Status = 'Sent', FCRM__FCR_Response_Status__c = 'Open - Not Contacted', ContactID = cts[0].id, CampaignID = camps[0].id, FCRM__FCR_Response_Date__c = DateTime.Now().AddDays(-1));                     
        
        setAllEloquaFields(origCm1, 'Blank');
        
        // Test response inserted   
        Test.startTest();   
        insert origCm1;
        Test.stopTest();
        
        // Check if plugin nullified blank values
        CampaignMember cm1Inserted = Database.query(getCmQuery(origCm1.Id));
        system.assert(allEloquaFieldsWithValue(cm1Inserted, null));              
    }    
    
    public static String FIELD_VALUE_ON_INSERT = 'Value On Insert';
    public static String FIELD_VALUE_ON_UPDATE = 'Value On Update';

    // When an existing response non repeat campaign is updated, revert values
    static testMethod void TestRevertValuesOnNonRepeatCampaign()
    {
        // Register Plugin    
        installPlugin();          
        
        FCRM.FCR_SupportAPI.SetRepeatResponseUserForContext();
        
        List<Contact> cts = initTestContacts('cts', 1);
        insert cts;
        
        List<Campaign> camps = initTestCampaigns('cmp', 1);
        camps[0].FCRM__FCR_Repeat_Responses_Allowed__c = false;
        insert camps;
        
        // Each contact has a response
        List<CampaignMember> respondedCms = new List<CampaignMember>();
        CampaignMember origCm1 = new CampaignMember(Status = 'Sent', FCRM__FCR_Response_Status__c = 'Open - Not Contacted', ContactID = cts[0].id, CampaignID = camps[0].id, FCRM__FCR_Response_Date__c = DateTime.Now().AddDays(-1));
        
        setAllEloquaFields(origCm1, FIELD_VALUE_ON_INSERT);
        
        Test.startTest();        
        insert origCm1;
        setAllEloquaFields(origCm1, FIELD_VALUE_ON_UPDATE);
        origCm1.Status = 'Responded';
        update origCm1;
        
        // origCm1Inserted should keep it's new values 
        CampaignMember origCm1Inserted = Database.query(getCmQuery(origCm1.Id));
        system.debug('origCm1Inserted' + origCm1Inserted);
        system.assert(allEloquaFieldsWithValue(origCm1Inserted, FIELD_VALUE_ON_UPDATE));         
        
        Test.stopTest();        
    }      
    
    // When a campaign member of a non repeat campaign exists with HasResponded = false then gets updated to HasResponded = true,
    // keep new updated values but clear blank fields
    static testMethod void TestClearValuesOnNonRepeatCampaign()
    {       
        // Register Plugin    
        installPlugin();          
        
        FCRM.FCR_SupportAPI.SetRepeatResponseUserForContext();
        
        List<Contact> cts = initTestContacts('cts', 1);
        insert cts;
        
        List<Campaign> camps = initTestCampaigns('cmp', 1);
        camps[0].FCRM__FCR_Repeat_Responses_Allowed__c = false;
        insert camps;
        
        // Each contact has a response
        List<CampaignMember> respondedCms = new List<CampaignMember>();
        CampaignMember origCm1 = new CampaignMember(Status = 'Sent', FCRM__FCR_Response_Status__c = 'Open - Not Contacted', ContactID = cts[0].id, CampaignID = camps[0].id, FCRM__FCR_Response_Date__c = DateTime.Now().AddDays(-1));
        
        setAllEloquaFields(origCm1, FIELD_VALUE_ON_INSERT);
        
        Test.startTest();        
        insert origCm1;
        setAllEloquaFields(origCm1, 'Blank');
        origCm1.Status = 'Responded';
        update origCm1;
        
        // origCm1Inserted should keep it's new values 
        CampaignMember origCm1Inserted = Database.query(getCmQuery(origCm1.Id));
        system.debug('origCm1Inserted2' + origCm1Inserted);
        system.assert(allEloquaFieldsWithValue(origCm1Inserted, null));         
        
        Test.stopTest();                        
    }                 

    public static List<Schema.FieldSetMember> eloquaFieldSetMembers = Schema.SObjectType.CampaignMember.FieldSets.ELQ_Response_Fields.getFields();
    
    public static String getCmQuery(Id recordId) 
    {
        String query = 'Select ';
        for (Schema.FieldSetMember fsm : eloquaFieldSetMembers) query += fsm.getFieldPath() + ', ';     
        query += ' Status, Id, HasResponded From CampaignMember Where Id = \'' + recordId + '\'';
        return query;
    }    
    
    public static void installPlugin()
    {
        FCRM.FCR_ExtensibilityAPI.EnablePluginsForTest = new Set<String>{'B_FCRM_ResponseReprocessPlugin'};
        FCRM.FCR_ExtensibilityAPI.InstallPluginClass('B_FCRM_ResponseReprocessPlugin');
    }
    
    public static void setAllEloquaFields(CampaignMember cm, String val)
    {
        for (Schema.FieldSetMember fsm : eloquaFieldSetMembers)
        {
            Schema.DisplayType fieldDisplayType = fsm.getType();
            if (fieldDisplayType == DisplayType.MULTIPICKLIST 
                || (fieldDisplayType == DisplayType.URL && val != 'Blank')
                || fieldDisplayType == DisplayType.PICKLIST 
                || fieldDisplayType == DisplayType.STRING 
                || fieldDisplayType == DisplayType.TEXTAREA)
            {
                cm.put(fsm.getFieldPath(), val);
            }       
            else if (fieldDisplayType == DisplayType.URL && val == 'Blank')
            {
                cm.put(fsm.getFieldPath(), 'www.blank.com');
            }
        }   
    }
    
    public static Boolean allEloquaFieldsWithValue(CampaignMember cm, String val)
    {
        for (Schema.FieldSetMember fsm : eloquaFieldSetMembers)
        {
            Schema.DisplayType fieldDisplayType = fsm.getType();
            if (fieldDisplayType == DisplayType.MULTIPICKLIST 
                || fieldDisplayType == DisplayType.PICKLIST 
                || fieldDisplayType == DisplayType.URL 
                || fieldDisplayType == DisplayType.STRING 
                || fieldDisplayType == DisplayType.TEXTAREA)
            {               
                if (cm.get(fsm.getFieldPath()) != val) return false;
            }       
        } 
        return true;        
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
          camps.add(new Campaign(Name = prefix+'_'+ String.ValueOf(x), FCRM__FCR_Repeat_Responses_Allowed__c=true, FCRM__FCR_Bypass_Nurture_Timeout__c=true, IsActive = true));
        }
        return camps;
    }    
}