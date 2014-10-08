@isTest
public with sharing class QuoteTestFactory
{
	private static Integer quoteCounter = 0;
	public static Quote buildNewAgreementQuote( Opportunity opportunity )
	{
		Quote newAgreement = buildQuote( opportunity );
		newAgreement.RecordTypeId = TestUtils.NEW_AGREEMENT_QUOTE_RECORD_TYPE;
		return newAgreement;
	}
	
	public static Quote createNewAgreementQuote( Opportunity opportunity )
	{
		Quote newAgreement = buildNewAgreementQuote( opportunity );
		insert newAgreement;
		return newAgreement;
	}
	
	public static Quote createNewAgreementQuote()
	{
		Quote newAgreement = buildNewAgreementQuote();
		insert newAgreement;
		return newAgreement;
	}
	
	public static Quote buildNewAgreementQuote()
	{
		Opportunity opportunity = OpportunityTestFactory.createOpportunity();
		return buildNewAgreementQuote( opportunity );
	}
	
	public static List<Quote> createNewAgreementQuotes( Integer numToCreate, Opportunity opportunity )
	{
		List<Quote> newAgreements = new List<Quote>();
		for( Integer i = 0; i < numToCreate; i ++ )
		{
			newAgreements.add( buildQuote( opportunity ) );
		}
		
		insert newAgreements;
		return newAgreements;
	}

	public static Quote buildQuote( Opportunity opportunity, Id pricebookId )
	{
		Quote quote = new Quote( Name = 'Test Quote' + quoteCounter,
								 OpportunityId = opportunity.Id,
								 Order_Start_Date__c = Date.today(),
								 Order_End_Date__c = Date.today().addYears(1),
								 Payment_Frequency__c = 'Monthy',
								 Payment_Method__c = 'Check',
								 Payment_Terms__c = 'Net 30',
								 Pricebook2Id = pricebookId );
		quoteCounter++;
		return quote;
	}
	
	public static List<Quote> buildQuotes( List<Opportunity> opportunities, Id pricebookId )
	{
		List<Quote> quotes = new List<Quote>();
		for( Opportunity opportunity : opportunities )
		{
			quotes.add( buildQuote( opportunity, pricebookId ) );
		}
		return quotes;
	}
	
	public static List<Quote> createQuotes( List<Opportunity> opportunities, Id pricebookId )
	{
		List<Quote> quotes = buildQuotes( opportunities, pricebookId );
		insert quotes;
		return quotes;
	}
	
	public static Quote createQuote( Opportunity opportunity, Id pricebookId )
	{
		return createQuotes( new List<Opportunity>{ opportunity }, pricebookId )[0];
	}
	
	private static Quote buildQuote( Opportunity opportunity )
	{
		Quote quote = buildQuote( opportunity, TestUtils.STANDARD_PRICEBOOK.Id );
		quoteCounter++;
		return quote;
	}
	
	
	public static QuoteLineItem buildQuoteLineItem( Quote quote, PricebookEntry pricebookEntry )
	{
		return buildQuoteLineItems( quote, new List<PricebookEntry>{ pricebookEntry } )[0];
	}
	
	public static QuoteLineItem createQuoteLineItem( Quote quote, PricebookEntry pricebookEntry )
	{
		QuoteLineItem quoteLineItem = buildQuoteLineItem( quote, pricebookEntry );
		insert quoteLineItem;
		return quoteLineItem;
	}
	
	public static List<QuoteLineItem> buildQuoteLineItems( Quote quote, List<PricebookEntry> pricebookEntries )
	{
		List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>();
		for( PricebookEntry pricebookEntry : pricebookEntries )
		{
			quoteLineItems.add( new QuoteLineItem( PricebookEntryId = pricebookEntry.Id,
																QuoteId = quote.Id,
																Quantity = 1,
																UnitPrice = 10.0 ) );
		}
		
		return quoteLineItems;
	}
	
	public static List<QuoteLineItem> buildQuoteLineItems( List<Quote> quotes, PricebookEntry pricebookEntry )
	{
		List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>();
		for( Quote quote : quotes )
		{
			quoteLineItems.add( buildQuoteLineItem( quote, pricebookEntry ) );
		}
		return quoteLineItems;
	}
}