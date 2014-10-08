@isTest
private class Z_DeleteQuoteExtension_Test {
 
 	/* delete a non-live quote */   
	static testMethod void testDeleteQuote1() {

    	Account acct = TestFactory.makeAccount();
        Opportunity opp = TestFactory.makeOpportunity(acct);
        zqu__Quote__c quote = TestFactory.makeQuote(opp);

        quote.Live_Quote__c=false;
        update quote;

        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.standardController(quote);
        Z_DeleteQuoteExtension ext = new Z_DeleteQuoteExtension(sc);	
		
		Boolean allowDelete = ext.getAllowDelete();
		PageReference processRef = ext.processQuote();
		PageReference deleteRef = ext.deleteQuote();
		
        Test.stopTest();
    }

	/* delete a live quote */
	static testMethod void testDeleteQuote2() {


    	Account acct = TestFactory.makeAccount();
        Opportunity opp = TestFactory.makeOpportunity(acct);
        zqu__Quote__c quote = TestFactory.makeQuote(opp);
        
        quote.Live_Quote__c=true;
        update quote;
        
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.standardController(quote);
        Z_DeleteQuoteExtension ext = new Z_DeleteQuoteExtension(sc);	
		
		Boolean allowDelete = ext.getAllowDelete();
		PageReference processRef = ext.processQuote();
		PageReference deleteRef = ext.deleteQuote();
		
        Test.stopTest();
    }

}