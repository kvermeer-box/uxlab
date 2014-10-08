@isTest
private class Z_SetPrimaryQuote_Test
{
   
	static testMethod void testSetPrimaryQuote1() {

    	Account acct = TestFactory.makeAccount();
        Opportunity opp = TestFactory.makeOpportunity(acct);
        zqu__Quote__c quote = TestFactory.makeQuote(opp);

        quote.Live_Quote__c=false;
        update quote;    

      

        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.standardController(quote);
        Z_SetPrimaryQuote controller = new Z_SetPrimaryQuote(sc);	
		
 
		PageReference processQuotePageRef = controller.processQuote();
		PageReference cancelPageRef = controller.cancel();
		
        Test.stopTest();
    }      

	static testMethod void testSetPrimaryQuote2() {

    	Account acct = TestFactory.makeAccount();
        Opportunity opp = TestFactory.makeOpportunity(acct);
        zqu__Quote__c quote = TestFactory.makeQuote(opp);

        quote.Live_Quote__c=true;
        update quote;

        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.standardController(quote);
        Z_SetPrimaryQuote controller = new Z_SetPrimaryQuote(sc);	
		
 
		PageReference processQuotePageRef = controller.processQuote();
		PageReference cancelPageRef = controller.cancel();
		
        Test.stopTest();
    }
    
    static testMethod void testProcessMessages(){



    	Account acct = TestFactory.makeAccount();
        Opportunity opp = TestFactory.makeOpportunity(acct);
        zqu__Quote__c quote = TestFactory.makeQuote(opp);
 

        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.standardController(quote);
        Z_SetPrimaryQuote controller = new Z_SetPrimaryQuote(sc);	
		
 		List <ApexPages.Message> messageList = new List <ApexPages.Message> ();
 		messageList.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'test message'));
		controller.processMessages(messageList);
		
        Test.stopTest();

    }
 
}