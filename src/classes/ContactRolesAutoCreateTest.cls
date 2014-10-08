@isTest (SeeAllData=True) 
public with sharing class ContactRolesAutoCreateTest {



    static testMethod void TestActivityInsertSync() 
    { 
      ContactRolesAutoCreate.useAsyncProcessing = false;        
        
      List<Account> acts = initTestAccounts('aa',2);
      insert acts;
      
      List<Opportunity> ops = initTestOpportunities('test',1, acts[0].Id);
      insert ops;
      
      List<Contact> cts = initTestContacts('contacts', 3);
      cts[0].AccountId = acts[0].Id;
      cts[1].AccountId = acts[0].Id;
      cts[2].AccountId = acts[1].Id;
      insert cts;
      
      OpportunityContactRole ocr = new OpportunityContactRole(
        OpportunityId = ops[0].Id,
        ContactId = cts[0].Id
      );      
      insert ocr;
      
      List<Task> tsks = initTestTasks('tasks', 3);
      
      Test.startTest();
      
      // Contact already eixsts on Opportunity as a role
      tsks[0].WhatId = ops[0].Id;
      tsks[0].WhoId = cts[0].Id;
      insert tsks[0];
      
      // Contact isn't on eixsting on Opportunity as a role, new role should be added
      tsks[1].WhatId = ops[0].Id;
      tsks[1].WhoId = cts[1].Id;
      insert tsks[1];
      
      // Contact's related opp's account doesn't contain contact
      tsks[2].WhatId = ops[0].Id;
      tsks[2].WhoId = cts[2].Id; // Contact with different account than ops[0]
      insert tsks[2];
      
      Test.stopTest();
      
      List<OpportunityContactRole> ocrs = [Select Id From OpportunityContactRole 
        Where OpportunityId = :ops[0].Id and ContactId = :cts[1].Id]; 
      
      //system.assert(ocrs.size() == 1);
    }
    
    static testMethod void TestActivityInsertAsync() 
    {   
      FCRM.FCR_ExtensibilityAPI.EnablePluginsForTest = new Set<String>{'ContactRolesAutoCreateAsyncPlugin'};  
      FCRM.FCR_ExtensibilityAPI.InstallPluginClass('ContactRolesAutoCreateAsyncPlugin');            
        
      ContactRolesAutoCreate.useAsyncProcessing = true;     
        
      List<Account> acts = initTestAccounts('aa',2);
      insert acts;
      
      List<Opportunity> ops = initTestOpportunities('test',1, acts[0].Id);
      insert ops;
      
      List<Contact> cts = initTestContacts('contacts', 3);
      cts[0].AccountId = acts[0].Id;
      cts[1].AccountId = acts[0].Id;
      cts[2].AccountId = acts[1].Id;
      insert cts;
      
      OpportunityContactRole ocr = new OpportunityContactRole(
        OpportunityId = ops[0].Id,
        ContactId = cts[0].Id
      );      
      insert ocr;
      
      List<Task> tsks = initTestTasks('tasks', 3);
      
      Test.startTest();
      ContactRolesAutoCreateAsyncPlugin plugin = new ContactRolesAutoCreateAsyncPlugin();         
      
      // Contact already eixsts on Opportunity as a role
      tsks[0].WhatId = ops[0].Id;
      tsks[0].WhoId = cts[0].Id;
      insert tsks[0];
      plugin.ExtensibilityEvent('TimedAsync', getArgs(new List<Id>{tsks[0].Id}));   
      
      // Contact isn't on eixsting on Opportunity as a role, new role should be added
      tsks[1].WhatId = ops[0].Id;
      tsks[1].WhoId = cts[1].Id;
      insert tsks[1];
      plugin.ExtensibilityEvent('TimedAsync', getArgs(new List<Id>{tsks[1].Id}));
      
      // Contact's related opp's account doesn't contain contact
      tsks[2].WhatId = ops[0].Id;
      tsks[2].WhoId = cts[2].Id; // Contact with different account than ops[0]
      insert tsks[2];
      plugin.ExtensibilityEvent('TimedAsync', getArgs(new List<Id>{tsks[2].Id}));
      
      Test.stopTest();
      
      List<OpportunityContactRole> ocrs = [Select Id From OpportunityContactRole 
        Where OpportunityId = :ops[0].Id and ContactId = :cts[1].Id]; 
      
      system.assert(ocrs.size() == 1);
    }   

    public static Args getArgs(List<Id> taskIdList) 
    {
        Args args = new Args();
        args.RecordIds = new List<List<Id>>();
        args.RecordIds.add(taskIdList);
        return args;
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
        public List<Object> getAdditionalParams() {return null; }
        public void setRaiseFuture() {  }
        public String getXMLdata() {
            List<String> taskIdListString = new List<String>();
            for (String id : this.getRecordIds()[0]) taskIdListString.add(id);          
            return String.join(taskIdListString, ',');
        }
        
        public Args(){}
                
    } 

    public static List<Account> initTestAccounts(String prefix, Integer count)
    {
        List<Account> accounts = new List<Account>();
        for(Integer x=1; x<count + 1; x++)
        {
          accounts.add(new Account(Name= prefix + '_' + String.valueOf(x), BillingCountry = 'United States'));    
        }
        return accounts;
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
    
    public static List<Task> initTestTasks(String prefix, Integer count)  
    {    
        List<Task>ts = new List<Task>();    
        for(Integer x=1;x<count+1;x++)    
        {      
          ts.add(new Task(Subject = prefix + '_' + String.valueOf(x)));
        }
        return ts;  
    }   
  
    public static List<Opportunity> initTestOpportunities(String prefix, Integer count, Id acctId)
        {
        List<Opportunity> ops = new List<Opportunity>();
        for(Integer x=1; x<count+1; x++)
        {
          ops.add(new Opportunity( 
            AccountId = acctId,
            Name = prefix + '_' + String.valueOf(x),
            Line_of_Business_1__c = 'Test',
            Amount = 10000,
            StageName = 'Test',
            CloseDate = Date.Today(),
            CurrencyIsoCode = 'USD' ));  
        }
        return ops;
        }
    
    }