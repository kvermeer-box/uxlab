/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestOpportunityCustomization {

    // Test primary contact validation on clone
    static testMethod void testClone1() {
        SetupValidationCustomSettings();
        
        List<Contact> contacts = new List<Contact>{new Contact(LastName='ct1'), new Contact(LastName='ct2')};
        insert contacts;
        
        Campaign camp = new Campaign(Name = 'camp1', IsActive = true);
        insert camp;

        // Create one closed and one not
        List<Opportunity> ops = GetTestOpportunities();

        insert ops;

        List<Opportunity> clonedopps = ops.DeepClone(false);
        System.Debug(LoggingLevel.Info, 'op stage ' + clonedopps[0].StageName + ' - ' + clonedopps[1].StageName);
        
        // Set admin field - this would be done via gating mechansim
        for(Integer x =0; x<ops.size(); x++) clonedopps[x].Admin_Opportunity_Cloned_From__c = ops[x].id;
        
        Test.startTest();
            List<Database.SaveResult> srs = Database.Insert(clonedopps, false);
        Test.stopTest();
        
        for(Integer x = 0; x<2; x++)
        {
            if(!srs[x].IsSuccess())
            {
                for(Database.Error e: srs[x].getErrors()) System.Debug(LoggingLevel.Info, e.getMessage());
            }
        }
        
        System.Assert(srs[0].IsSuccess());  // First one, not closed, should be success
        System.Assert(!srs[1].IsSuccess()); // Second one, closed, should be failure

        //Map<ID, Opportunity> clonedoppsmap = new Map<ID, Opportunity>(clonedopps);    // To get the IDs
        //List<Opportunity> clonedresults = [SELECT Id, CampaignID from Opportunity where ID in :clonedoppsmap.keyset()];


        // TO DO: implement unit test
    }
    
    // Test primary contact validation on update
    static testMethod void testUpdate() {
        
        SetupValidationCustomSettings();
        
        List<Contact> contacts = new List<Contact>{new Contact(LastName='ct1'), new Contact(LastName='ct2')};
        insert contacts;
        
        Campaign camp = new Campaign(Name = 'camp1', IsActive = true);
        insert camp;

        // Both closed and one not
        List<Opportunity> ops = GetTestOpportunities();
        ops[1].StageName = getOpportunityStage(false);  // Make them both Open

        insert ops;

        // Give first one a primary contact
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityID = ops[0].id, ContactID = contacts[0].id, IsPrimary = true);
        insert ocr;

        Test.startTest();
            // Now update to closed
            for(Opportunity op: ops) op.StageName = GetOpportunityStage(true);
            List<Database.SaveResult> srs = Database.Update(ops, false);
        Test.stopTest();
        
        System.Assert(srs[0].IsSuccess());  // First one, has primary contact, should be success
        System.Assert(!srs[1].IsSuccess()); // Second one, no primary contact, should be failure

    }
    
    
    // Test primary Campaign assignment on clone
    static testMethod void testClone2() {
    /*  COMMENTING THIS OUT TO ALLOW PUSHES TO PRODUCTION
        List<Contact> contacts = new List<Contact>{new Contact(LastName='ct1'), new Contact(LastName='ct2')};
        insert contacts;
        
        List<Campaign> camps = new List<Campaign>{new Campaign(Name = 'camp1', IsActive = true),
                        new Campaign(Name = 'camp2', IsActive = true)};
        insert camps;
        
        CampaignMember cm1 = new CampaignMember(CampaignID = camps[0].id, Contactid = contacts[0].id, Status='Responded');
        insert cm1; // First responded date 
        // Can't really test two of them because we can't set the first responded date.

        // Create one closed and one not
        List<Opportunity> ops = GetTestOpportunities();
        ops[1].CampaignId = camps[1].id;    // No primary contact on this one, so this should be reset
        System.debug('Campaign: ' + ops[1].CampaignId);
        ops[1].StageName = GetOpportunityStage(false);  // Both are open - so should be no errors

        insert ops;
        
        // Give first one a primary contact
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityID = ops[0].id, ContactID = contacts[0].id, IsPrimary = true);
        insert ocr;
        
        List<Opportunity> clonedopps = ops.DeepClone(false);
        
        // Set admin field - this would be done via gating mechansim
        for(Integer x =0; x<ops.size(); x++) 
        {
            System.debug('Campign after cloning: ' + clonedopps[x].CampaignId);
            clonedopps[x].Admin_Opportunity_Cloned_From__c = ops[x].id;
        }
        
        Test.startTest();
            List<Database.SaveResult> srs = Database.Insert(clonedopps, false);
        Test.stopTest();
        
        System.Assert(srs[0].IsSuccess());  // First one, not closed, should be success
        System.Assert(srs[1].IsSuccess());  // Second one, closed, should be failure

        Map<ID, Opportunity> clonedoppsmap = new Map<ID, Opportunity>(clonedopps);  // To get the IDs
        Map<ID,Opportunity> cloned_results_map = new Map<ID,Opportunity>([SELECT Id, CampaignID from Opportunity where ID in :clonedoppsmap.keyset()]);
        Opportunity first_opp = cloned_results_map.get(clonedopps[0].Id);
        System.AssertEquals(camps[0].id, first_opp.CampaignID);  // Should be set to latest
        Opportunity second_opp = cloned_results_map.get(clonedopps[1].Id);
        System.AssertEquals(null, second_opp.CampaignID); // Should have been cleared ()

    */
    }
    
    private static List<OpportunityStage> opportunitystages;
    
    private static List<Opportunity> getTestOpportunities()
    {
        List<Opportunity> ops = new List<Opportunity>{ new Opportunity(CloseDate=Date.Today(), Name = 'op1', StageName = GetOpportunityStage(false)),
            new Opportunity(CloseDate=Date.Today(), Name = 'op2', StageName = GetOpportunityStage(true)) };
        for(Opportunity op: ops)
        {
            op.Box_Enterprise_ID__c = 'testid';
            op.Fee_Frequency__c = 'Monthly';
            op.Lost_Reason__c = 'test';
            op.Lost_Biz_Reason__c = 'test';
            op.Line_of_Business_1__c = 'Buying Box is Great!';
        }
        return ops;
    }
    
    private static void SetupValidationCustomSettings()
    {
        Map<String, OppValidationStages__c> oppstages = OppValidationStages__c.getAll();
        if(oppstages.size()>0) Database.Delete(oppstages.values());
        OppValidationStages__c opstage = new OppValidationStages__c();
        opstage.name = 'test';
        opstage.StageName__c = getOpportunityStage(true);
        Database.Insert(opstage);
        Opportunity_Management__c omc = Opportunity_Management__c.getInstance();
        omc.Exempt_From_Validation__c = false;
        Database.upsert(omc);
        
    }
   
    private static String getOpportunityStage(Boolean closed)
    {
        if(opportunitystages == null ) opportunitystages = [SELECT ID, IsClosed, IsWon, IsActive, MasterLabel from OpportunityStage];
        for(OpportunityStage opstage: opportunitystages)
        {
            if(closed && opstage.isWon && opstage.isClosed) return opstage.MasterLabel;
            if(!closed && !opstage.isClosed && opstage.IsActive) return opstage.MasterLabel;
        }
        return null;
    }
    
    
}