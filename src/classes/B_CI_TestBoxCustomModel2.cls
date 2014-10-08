@isTest
private class B_CI_TestBoxCustomModel2 {

    // Note - Full Circle CRM application is off during external tests - so we can
    // set all fields directly without interaction with the application

    static testMethod void TestRolesOnly() {
        Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> OpenOpportunityRevenue = new Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>>();
        Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> ClosedOpportunityRevenue = new Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>>();
        Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> LostOpportunityRevenue = new Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>>();
        
        TestModel(0,1, 1, OpenOpportunityRevenue, ClosedOpportunityRevenue, LostOpportunityRevenue);
        system.debug('Open ' + OpenOpportunityRevenue);
        system.debug('Closed ' + ClosedOpportunityRevenue);
        system.debug('Lost ' + LostOpportunityRevenue);

        Decimal dtotal = 0;
        for(ID cmid: OpenOpportunityRevenue.keyset())
        {
            for(FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue d: OpenOpportunityRevenue.get(cmid)) dtotal+= d.InfluenceAmount;
        }
        System.AssertEquals(10000, dtotal);
        
        dtotal = 0;
        for(ID cmid: OpenOpportunityRevenue.keyset())
        {
            system.debug('closed op revenue ' + ClosedOpportunityRevenue );
            system.debug('closed op revenue2 ' + ClosedOpportunityRevenue.get(cmid) );
            for(FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue d: ClosedOpportunityRevenue.get(cmid)) dtotal+= d.InfluenceAmount;
        }
        System.AssertEquals(10000, dtotal);

        dtotal = 0;
        for(ID cmid: OpenOpportunityRevenue.keyset())
        {
            for(FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue d: LostOpportunityRevenue.get(cmid)) dtotal+= d.InfluenceAmount;
        }
        System.AssertEquals(10000, dtotal);

    }

    static testMethod void TestAccountsOnly() {
        Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> OpenOpportunityRevenue = new Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>>();
        Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> ClosedOpportunityRevenue = new Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>>();
        Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> LostOpportunityRevenue = new Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>>();
        
        TestModel(1,0, 0, OpenOpportunityRevenue, ClosedOpportunityRevenue, LostOpportunityRevenue);
        system.debug('Open ' + OpenOpportunityRevenue);
        system.debug('Closed ' + ClosedOpportunityRevenue);
        system.debug('Lost ' + LostOpportunityRevenue);

        Decimal dtotal = 0;
        for(ID cmid: OpenOpportunityRevenue.keyset())
        {
            for(FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue d: OpenOpportunityRevenue.get(cmid)) dtotal+= d.InfluenceAmount;
        }
        System.AssertEquals(10000, dtotal);
        
        dtotal = 0;
        for(ID cmid: OpenOpportunityRevenue.keyset())
        {
            for(FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue d: ClosedOpportunityRevenue.get(cmid)) dtotal+= d.InfluenceAmount;
        }
        System.AssertEquals(10000, dtotal);

        dtotal = 0;
        for(ID cmid: OpenOpportunityRevenue.keyset())
        {
            for(FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue d: LostOpportunityRevenue.get(cmid)) dtotal+= d.InfluenceAmount;
        }
        System.AssertEquals(10000, dtotal);
    }

     
    
    public static void TestModel(Integer AccountWeight, Integer RoleWeight, Integer CampaignSpecificWeight,
        Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> OpenOpportunityRevenue,
        Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> ClosedOpportunityRevenue,
        Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> LostOpportunityRevenue)
    {
        B_CI_BoxCustomInfluenceModelConfig config = new B_CI_BoxCustomInfluenceModelConfig();
        List<String> roles = config.getAvailableRoles();

        B_CI_AccountModelSettings__c modelsettings = new B_CI_AccountModelSettings__c(name='default', Account_Weight__c = AccountWeight, Search_Days__c = 365, Enabled__c = true);
        insert modelsettings;

        B_CI_ContactRoleWeight__c roleweightsetting = new B_CI_ContactRoleWeight__c(name = 'w0' , role__c = roles[0], weight__c = RoleWeight );     
        insert roleweightsetting;               

        B_CI_CampaignSpecificWeight__c campaignweightsetting = new B_CI_CampaignSpecificWeight__c(name = 'w0' , Type__c = 'Primary', weight__c = CampaignSpecificWeight );      
        insert campaignweightsetting;   
        
        B_CI_TimeFrameWeights__c timeframesetting = new B_CI_TimeFrameWeights__c(Sales_Division__c = 'Default', Name = 'w0Default', Number_of_Days__c = 1, Instance__c = 0);        
        insert timeframesetting;                
        
        List<Account> acts = B_CI_TestBoxCustomModel.initTestAccounts('aa',1);
        insert acts;
        
        // Create 3 opportunities
        List<Opportunity> ops = B_CI_TestBoxCustomModel.initTestOpportunities('opwon',1,false, false);
        ops.addall(B_CI_TestBoxCustomModel.initTestOpportunities('opclosedlost',1,true, false));
        ops.addall(B_CI_TestBoxCustomModel.initTestOpportunities('opclosedwon',1,true, true));
        for(Opportunity op: ops)
        {
            op.Line_of_Business_1__c = 'Test';
            op.AccountID = acts[0].id;
            op.Amount = 10000;
        }
        insert ops;

        List<Contact> cts = B_CI_TestBoxCustomModel.initTestContacts('cts', 4);
        for(Contact ct: cts) ct.AccountID = acts[0].id;
        insert cts;
        
        List<Campaign> camps = B_CI_TestBoxCustomModel.initTestCampaigns('cmp', cts.size());
        insert camps;
        
        // Each contact has a response
        List<CampaignMember> cms = new List<CampaignMember>();
        for(Integer x = 0; x< 4; x++)
            cms.add(new CampaignMember(Status='Responded', ContactID = cts[x].id, CampaignID = camps[x].id, FCRM__FCR_Response_Date__c = DateTime.Now().AddDays(-1)));
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
        
        state = model.AccountProcessAttribution2(accounts, 
            opportunities, OpenOpportunityRevenue, ClosedOpportunityRevenue, 
            LostOpportunityRevenue, State);     
        
        model.Finish(state);
        Test.StopTest();
    }
}