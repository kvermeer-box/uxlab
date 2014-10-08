/**
 * Test Class for for Z_QuoteUtility.cls
 *
 * @author Alan Young
 * @revision Kyle Vermeer 6/25/2014
 **/
@isTest
private class Z_QuoteUtility_Test {
 
	static testMethod void testMethod1(){
		
        Account acct = Z_TestUtils.createAccount(true);
		Opportunity opp = Z_TestUtils.createOpportunity(acct.Id, true);
        List<Opportunity> oppList = new List<Opportunity> ();
        oppList.add(opp);
        zqu__Quote__c quote1 = Z_TestUtils.createZQuote(opp.Id, true); 
        zqu__Quote__c quote2 = Z_TestUtils.createZQuote(opp.Id, true); 
        Test.startTest();
        
       
        List<ApexPages.Message> syncErrors;

        syncErrors = Z_QuoteUtility.makeLiveQuote(quote1.Id);
        syncErrors = Z_QuoteUtility.makeSignedQuote(quote2.Id);
 
 
         
        Test.stopTest();
    }  
       
	static testMethod void testMethod2() {

        Account acct = Z_TestUtils.createAccount(true);
		Opportunity opp = Z_TestUtils.createOpportunity(acct.Id, true);
		
        List<Opportunity> oppList = new List<Opportunity> ();
        oppList.add(opp);
        zqu__Quote__c quote1 = Z_TestUtils.createZQuote(opp.Id, true); 
        zqu__Quote__c quote2 = Z_TestUtils.createZQuote(opp.Id, true); 
        
        opp.Live_ZQuote__c = quote1.Id;
        update opp;
        
        Test.startTest();
        
       
        List<ApexPages.Message> syncErrors;

        Z_QuoteUtility.updateQuoteFields(oppList); 

        Z_QuoteUtility.updateQuoteFields(null);
         
        Test.stopTest();
    }

    static testMethod void testSetCreatePDF() {
        Account acct = Z_TestUtils.createAccount(true);
        Opportunity opp = Z_TestUtils.createOpportunity(acct.Id, true);
        
        List<Opportunity> oppList = new List<Opportunity> ();
        oppList.add(opp);
        zqu__Quote__c quote1 = Z_TestUtils.createZQuote(opp.Id, true); 

        Z_QuoteUtility.setPDFCreated(quote1.Id);
        Z_QuoteUtility.setPDFCreated(null);
        Z_QuoteUtility.setPDFCreated('YOLO');
    }

}