@isTest
private class Z_ValidateQuoteExtension_Test {

	static testMethod void testValidateQuote1() {

    	Account acct = TestFactory.makeAccount();
        Opportunity opp = TestFactory.makeOpportunity(acct);
        zqu__Quote__c quote = TestFactory.makeQuote(opp);
 

        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.standardController(quote);
        Z_ValidateQuoteExtension ext = new Z_ValidateQuoteExtension(sc);	
 
		PageReference processQuotePageRef = ext.processQuote();
		List <ApexPages.Message> messageList = new List <ApexPages.Message> ();
		   
		ext.processMessages(messageList);
		
		messageList.add(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Z_PAYMENT_FREQUENCY_REQUIRED));
		
		ext.processMessages(messageList);
				
        Test.stopTest();
    }

}