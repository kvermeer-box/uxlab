@isTest
public class B_CI_TestBoxCustomModel {

  // Note - Full Circle CRM application is off during external tests - so we can
  // set all fields directly without interaction with the application

    static testMethod void TestRolesOnly() {
    Map<ID, Decimal> OpenOpportunityRevenue = new Map<ID, Decimal>();
    Map<ID, Decimal> ClosedOpportunityRevenue = new Map<ID, Decimal>();
    Map<ID, Decimal> LostOpportunityRevenue = new Map<ID, Decimal>();
      
        TestModel(0,1,1, OpenOpportunityRevenue, ClosedOpportunityRevenue, LostOpportunityRevenue);
        system.debug('Open ' + OpenOpportunityRevenue);
        system.debug('Closed ' + ClosedOpportunityRevenue);
        system.debug('Lost ' + LostOpportunityRevenue);

        Decimal dtotal = 0;
        for(Decimal d: OpenOpportunityRevenue.values()) dtotal+= d;
        System.AssertEquals(10000, dtotal);
        
        dtotal = 0;
        for(Decimal d: ClosedOpportunityRevenue.values()) dtotal+= d;
        System.AssertEquals(10000, dtotal);

        dtotal = 0;
        for(Decimal d: LostOpportunityRevenue.values()) dtotal+= d;
        System.AssertEquals(10000, dtotal);

    }

    static testMethod void TestAccountsOnly() {
    Map<ID, Decimal> OpenOpportunityRevenue = new Map<ID, Decimal>();
    Map<ID, Decimal> ClosedOpportunityRevenue = new Map<ID, Decimal>();
    Map<ID, Decimal> LostOpportunityRevenue = new Map<ID, Decimal>();
      
        TestModel(1,0, 0, OpenOpportunityRevenue, ClosedOpportunityRevenue, LostOpportunityRevenue);
        system.debug('Open ' + OpenOpportunityRevenue);
        system.debug('Closed ' + ClosedOpportunityRevenue);
        system.debug('Lost ' + LostOpportunityRevenue);

        Decimal dtotal = 0;
        for(Decimal d: OpenOpportunityRevenue.values()) dtotal+= d;
        System.AssertEquals(10000, dtotal);
        
        dtotal = 0;
        for(Decimal d: ClosedOpportunityRevenue.values()) dtotal+= d;
        System.AssertEquals(10000, dtotal);

        dtotal = 0;
        for(Decimal d: LostOpportunityRevenue.values()) dtotal+= d;
        System.AssertEquals(10000, dtotal);

    }

     
    static testMethod void TestTrigger()
    {
      FCRM__FCR_APIHookTrigger__c hookobject = new FCRM__FCR_APIHookTrigger__c(FCRM__Hook_Type__c = 'campaigninfluence');
      Test.StartTest();
      insert hookobject;

      Test.StopTest();
      List<FCRM__FCR_APIHookTrigger__c> objs = [Select ID from FCRM__FCR_APIHookTrigger__c];
      system.AssertEquals(1, objs.size());
    }
    
    static testMethod void TestModel()
    {
    B_CI_BoxCustomInfluenceModel model = new B_CI_BoxCustomInfluenceModel();
    System.Assert(model.GetSupportsAccountInfluence());
    System.Assert(!model.GetSupportsOpInfluence());
    System.Assert(model.GetUniqueName() != null );
    System.Assert(model.GetDescription() != null );
    System.Assert(model.GetManufacturer() != null );
    System.Assert(model.GetCopyright() != null );
    System.Assert(model.GetConfigurationPage() != null); 
      
    }
    
    public static void TestModel(Integer AccountWeight, Integer RoleWeight, Integer CampaignSpecificWeight,
      Map<ID, Decimal> OpenOpportunityRevenue,
    Map<ID, Decimal> ClosedOpportunityRevenue,
    Map<ID, Decimal> LostOpportunityRevenue)
    {
      B_CI_BoxCustomInfluenceModelConfig config = new B_CI_BoxCustomInfluenceModelConfig();
        List<String> roles = config.getAvailableRoles();

    B_CI_AccountModelSettings__c modelsettings = new B_CI_AccountModelSettings__c(name='default', Account_Weight__c = AccountWeight, Search_Days__c = 365, Enabled__c = true);
    insert modelsettings;

    B_CI_ContactRoleWeight__c roleweightsetting = new B_CI_ContactRoleWeight__c(name = 'w0' , role__c = roles[0], weight__c = RoleWeight, Instance__c = 0 );    
    insert roleweightsetting;     
    
        B_CI_TimeFrameWeights__c timeframesetting = new B_CI_TimeFrameWeights__c(Sales_Division__c = 'Default', Name = 'w0Default', Number_of_Days__c = 1, Instance__c = 0);    
    insert timeframesetting;
    
    List<B_CI_CampaignSpecificWeight__c> campaignweightsettings = new List<B_CI_CampaignSpecificWeight__c>{
      new B_CI_CampaignSpecificWeight__c(Instance__c = 0, name = 'w0Primary' , Type__c = 'Primary', weight__c = CampaignSpecificWeight ),
      new B_CI_CampaignSpecificWeight__c(Instance__c = 0, name = 'w0First Touch' , Type__c = 'First Touch', weight__c = CampaignSpecificWeight ),
      new B_CI_CampaignSpecificWeight__c(Instance__c = 0, name = 'w0Last Touch' , Type__c = 'Last Touch', weight__c = CampaignSpecificWeight )
    };    
    insert campaignweightsettings;        
      
      List<Account> acts = initTestAccounts('aa',1);
      insert acts;
      
      // Create 3 opportunities
      List<Opportunity> ops = initTestOpportunities('opwon',1,false, false);
      ops.addall(initTestOpportunities('opclosedlost',1,true, false));
      ops.addall(initTestOpportunities('opclosedwon',1,true, true));
      for(Opportunity op: ops)
      {
        op.Line_of_Business_1__c = 'Test';
        op.AccountID = acts[0].id;
        op.Amount = 10000;
      }
      insert ops;

    List<Contact> cts = initTestContacts('cts', 5);
    for(Contact ct: cts) ct.AccountID = acts[0].id;
    cts[4].Exclude_From_Influence__c = true;
    insert cts;
    
    List<Campaign> camps = initTestCampaigns('cmp', cts.size());
    insert camps;
    
    // Assign different Campaign types to each opp
    ops[0].FCRM__FCR_First_Campaign_Touch__c = camps[0].Id;
    update ops;
    
    // Each contact has a response
    List<CampaignMember> cms = new List<CampaignMember>();
    for(Integer x = 0; x< 4; x++)
      cms.add(new CampaignMember(Status='Responded', ContactID = cts[x].id, CampaignID = camps[x].id, FCRM__FCR_Response_Date__c = DateTime.Now().AddDays(-1)));
    
    // Add Contact with Exclude_from_Influence__c = true
    CampaignMember cmContact = new CampaignMember(Status='Responded', ContactID = cts[4].id, CampaignID = camps[0].id, FCRM__FCR_Response_Date__c = DateTime.Now().AddDays(-1));
    cms.add(cmContact);
    
    insert cms;
    
    // Each opportunity has one contact
    // Account has all 4 contacts
    List<OpportunityContactRole> ocrs = new List<OpportunityContactRole>();
    ocrs.add(new OpportunityContactRole(OpportunityID=ops[0].id, ContactID = cts[0].id, Role = roles[0]));
    ocrs.add(new OpportunityContactRole(OpportunityID=ops[1].id, ContactID = cts[1].id, Role = roles[0]));
    ocrs.add(new OpportunityContactRole(OpportunityID=ops[2].id, ContactID = cts[2].id, Role = roles[0]));
    insert ocrs;
    
    B_CI_BoxCustomInfluenceModel model = new B_CI_BoxCustomInfluenceModel();
    System.Assert(model.GetEnabled());
    System.Assert(model.OpportunityProcessAttribution(null, null, null, null, null)==null);

    Map<ID, Account> accounts = new Map<ID, Account>(acts);
    Map<ID, Map<ID, Opportunity>> opportunities = new Map<ID, Map<ID, Opportunity>>
       { acts[0].id => new Map<ID, Opportunity>(ops) };

    String state;
      Test.StartTest();
      state = model.Start();
    
    state = model.AccountProcessAttribution(accounts, 
      opportunities, OpenOpportunityRevenue, ClosedOpportunityRevenue, 
      LostOpportunityRevenue, State);     
      
      model.Finish(state);
      Test.StopTest();
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
    

  public static List<Account> initTestAccounts(String prefix, Integer count)
  {
    List<Account> accounts = new List<Account>();
    for(Integer x=1; x<count + 1; x++)
    {
      accounts.add(new Account(Name= prefix + '_' + String.valueOf(x)));    
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
  
  public static List<Opportunity> initTestOpportunities(String prefix, Integer count, Boolean closed, Boolean won)
  {
    List<Opportunity> ops = new List<Opportunity>();
    for(Integer x=1; x<count+1; x++)
    {
      ops.add(new Opportunity(CloseDate = Date.Today().addDays(5), Name = prefix + '_' + String.valueOf(x), StageName = getOpportunityStage(closed, won) ));  
    }
    return ops;
  }
  
  public static String getOpportunityStage(Boolean closed, Boolean won)
  {
    List<OpportunityStage> opportunitystages = [SELECT ID, IsClosed, IsWon, IsActive, MasterLabel from OpportunityStage where IsClosed = :closed and IsWon = :won];
    if(opportunitystages.size()>0) return opportunitystages[0].MasterLabel;
  
    return null;
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
    
    
}