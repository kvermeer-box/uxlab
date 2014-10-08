@isTest
public with sharing class OpportunityTestFactory
{
	public static Opportunity buildOpportunity()
	{
		Opportunity opportunity =  new Opportunity( Name = 'Test Opportunity',
													StageName = 'Sales Qualified Opportunity (by SDR)',
													CloseDate = Date.Today(),
													CurrencyIsoCode = 'USD',
													Line_of_Business_1__c = 'Buying Box is Great!' );
		return opportunity;
	}
	
	public static Opportunity createOpportunity()
	{
		return createOpportunities( 1 )[0];
	}
	
	public static Opportunity buildOpportunity( Account account )
	{
		Opportunity opportunity = buildOpportunity();
		opportunity.AccountId = account.Id;
		return opportunity;
	}
	
	public static Opportunity createOpportunity( Account account )
	{
		Opportunity opportunity = buildOpportunity( account );
		insert opportunity;
		return opportunity;
	}
	
	public static Opportunity buildRenewalOpportunity()
	{
		Opportunity opportunity = buildOpportunity();
		opportunity.RecordTypeId = QuoteLineItemServices.renewalRecordTypeId;
		return opportunity;
	}
	
	public static Opportunity createRenewalOpportunity()
	{
		Opportunity opportunity = buildRenewalOpportunity();
		insert opportunity;
		return opportunity;
	}
	
	public static List<Opportunity> buildOpportunities( Integer numOfOpps )
	{
		List<Opportunity> opportunities = new List<Opportunity>();
		for( Integer i = 0; i < numOfOpps; i++ )
		{
			opportunities.add( buildOpportunity() );
		}
		return opportunities;
	}
	
	public static List<Opportunity> createOpportunities( Integer numOfOpps )
	{
		List<Opportunity> opportunities = buildOpportunities( numOfOpps );
		insert opportunities;
		return opportunities;
	}
}