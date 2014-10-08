global with sharing class Box_QuoteFactory {

	private static String QUOTE_NEW_AGREEMENT_RECORD_TYPE = '012600000009VgB';
	private static String QUOTE_UPSELL_RECORD_TYPE = '012600000009VgG';
	private static String QUOTE_DEFAULT_PRICE_BOOK = '01s60000000ALfM';
	public static String PRODUCT_BUSINESS_ID = '01u6000000574Dr';
	public static String PRODUCT_ENTERPRISE_ID = '01u60000005X0vs';
	public static String PRODUCT_UNLIMITED_ID = '01u60000005X0w7';
	private static String DATE_ONE_MONTH = 'one month';

	public static Quote createNewQuote(Box_SalesTransaction salesTransaction, Opportunity opportunity, Account partner, Tenant__c originalTenant) {
		System.debug('Creating quote from opportunity...');
		
		if (opportunity == null) {
			throw new CustomException('Error: Cannot create quote with a null opportunity.');
		}
		
		Quote quote = new Quote();
		quote.Pricebook2Id = QUOTE_DEFAULT_PRICE_BOOK;
		quote.OpportunityId = opportunity.Id;
		quote.Name = opportunity.Name;
		quote.Order_Start_Date__c = Opportunity.CloseDate;
		quote.Order_End_Date__c = calculateEndDateFromPartnerOrderLength(quote, partner);
		quote.Payment_Frequency__c = 'Monthly';
		quote.Payment_Method__c = 'Valid Credit Card Required';
		quote.Payment_Terms__c = 'Due Upon Receipt';
		
		// Record Type
		if (Box_OpportunityFactory.mapEnterpriseAccountTypeToOppAccountTypeSold(salesTransaction.enterprise.account_type).equals(opportunity.Account_Type_Sold__c) && opportunity.Seats_Sold__c >= 0) {
			quote.RecordTypeId = QUOTE_UPSELL_RECORD_TYPE;
		} else {
			quote.RecordTypeId = QUOTE_NEW_AGREEMENT_RECORD_TYPE;
		}
		
		insert quote;
		
		// Create line item
		QuoteLineItem qli = createQuoteLineItem(salesTransaction.enterprise, opportunity, quote, partner, originalTenant); 
		
		return Quote;
	}
	
	private static QuoteLineItem createQuoteLineItem(Box_Enterprise enterprise, Opportunity opportunity, Quote quote, Account partner, Tenant__c originalTenant) {
		System.debug('Creating quote line item from opportunity...');
		
		if (enterprise == null || opportunity == null || quote == null || partner == null) {
			throw new CustomException('Error: Cannot create quote line item with a null enterprise, opportunity, quote, or partner.');
		}
		
		// Make sure we have the inputs we need
		if (enterprise.account_type == null || enterprise.account_type.equals('')) {
			throw new CustomException('Error: enterprise account type cannot be null.');
		} else if (enterprise.seats == null || enterprise.seats.equals('')) {
			throw new CustomException('Error: enterprise seats count is empty.');
		} else if (Box_AccountDAO.getPartnerPricePerSeat(enterprise.account_type, partner) == null) {
			throw new CustomException('Error: partner price per seat is empty.');
		} 
		 
		QuoteLineItem qli = new QuoteLineItem();
		qli.QuoteId = quote.Id;
		qli.PricebookEntryId = Box_PricebookEntryDAO.mapEnterpriseAccountTypeToPBE(enterprise.account_type); 
		qli.Purchase_Start_Date__c = quote.Order_Start_Date__c;
		qli.Purchase_End_Date__c = quote.Order_End_Date__c;
		
		// Quantity
		if (originalTenant == null || !enterprise.account_type.equals(originalTenant.Account_Type__c) || (originalTenant.Active_Status__c == Box_ActiveStatus.deactivated.name() && enterprise.active_status == Box_ActiveStatus.active.name())) {
			// If there is a change in plan type or reactivation, take the final full number of seats
			qli.Quantity = Integer.valueOf(enterprise.seats);
		} else {
			// No change in plan type
			if (opportunity.Seats_Sold__c > 0) {
				// Map to opp seats sold if it is positive and the account types are the same (clean upsell)
				qli.Quantity = opportunity.Seats_Sold__c;
			} else if (opportunity.Seats_Sold__c < 0) {
				qli.Quantity = Integer.valueOf(enterprise.seats);
			} else {
				// We will get an error if we try to make a zero quantity line item
				System.debug('Cannot insert quote line item when seats sold is zero.');
				return null;
			}
		}
		
		try {		
			qli.UnitPrice = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Id = :qli.PricebookEntryId][0].UnitPrice;
			qli.List_Price__c = qli.UnitPrice;
			qli.Discount__c = (1 - (Box_AccountDAO.getPartnerPricePerSeat(enterprise.account_type, partner) / qli.UnitPrice)) * 100;
			insert qli;
			return qli;
		} catch (Exception e) {
			System.debug('Exception caught: ' + e.getmessage());
			return null;
		}
	}

	private static Date calculateEndDateFromPartnerOrderLength(Quote quote, Account partner) {
		Date startDate = quote.Order_Start_Date__c;
		Date endDate = quote.Order_Start_Date__c.addYears(1);
		if (partner.Partner_Order_Length__c != null) {
			if (partner.Partner_Order_Length__c.toLowerCase().equals(DATE_ONE_MONTH)) {
				endDate = startDate.addMonths(1);
			}			
		}
		return endDate;
	}

}