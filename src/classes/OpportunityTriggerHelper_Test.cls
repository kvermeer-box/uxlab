@isTest
private class OpportunityTriggerHelper_Test {

  @isTest static void testDeleteOpportunity() {

        Id userId = TestDataFactory_hlpr.createUser('Major','NATAM','Kyle V','OpportunityTriggerHelper_Test1@box.com');

        // Create Opportunity
        Opportunity opp = new Opportunity(OwnerId = userId, Name = 'Major - NATAM Opp', StageName = 'Received / Prospecting', 
                                          CloseDate = Date.today().addDays(10));
        insert opp;
  	
  
 		// User can delete it
		delete opp;
		
		
		Opportunity testOpp;
		
		for(Opportunity deletedOpp : [Select Id from Opportunity where Id =: opp.Id]){
			
			testOpp=deletedOpp;
		}
			
		System.assertEquals(null,testOpp);

  }
  
  @isTest static void testInactiveOpportunityOwner() {

        Id userId = TestDataFactory_hlpr.createUser('Major','NATAM','Kyle V','OpportunityTriggerHelper_Test2@box.com');
		
		/* deactivate user */
		User testUser = new User(Id=userId);
		testUser.isActive=false;		
		update testUser;

        // Create Opportunity
        Opportunity opp = new Opportunity(OwnerId = userId, Name = 'Major - NATAM Opp', StageName = 'Received / Prospecting', 
                                          CloseDate = Date.today().addDays(10));
        insert opp;
  

  }

   
  
}