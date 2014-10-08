global with sharing class Box_DealFactory {

	private Box_SalesTransaction salesTransaction;
	private Account partner;
	private Opportunity dealReg;
	private Quote quote;
	private Tenant__c originalTenant; 
	private Tenant__c tenant;
	
	public Box_DealFactory(Box_SalesTransaction salesTransaction, Opportunity dealReg, Tenant__c originalTenant, Account partner, Tenant__c tenant) {
		this.salesTransaction = salesTransaction; 
		this.dealReg = dealReg;
		this.originalTenant = originalTenant;
		this.partner = partner; 
		this.tenant = tenant;
	}	

	public Opportunity closeDeal() {
		System.debug('Closing deal...');

		if (dealReg != null) {
			// Close deal reg
			dealReg = Box_OpportunityFactory.closeDealRegOpportunity(dealReg, salesTransaction, partner, originalTenant, tenant);			
		} else {
			// Create a churn		
			dealReg = Box_OpportunityFactory.createChurnOpportunity(salesTransaction, partner, originalTenant, tenant);
		}
		quote = Box_QuoteFactory.createNewQuote(salesTransaction, dealReg, partner, originalTenant);
		
		return dealReg;
	}

}