trigger QuoteMachine_waterfallQuoteDates on Quote (after update) {

	// Foreplay time!  Set up a quotes w/premier support line items map
	List<Quote> allQuotesList = [SELECT Id, Order_Start_Date__c, Order_End_Date__c,
											(SELECT Id, PricebookEntry.Product2.Name, PricebookEntry.Product2.NumberOfRevenueInstallments
												FROM QuoteLineItems
												WHERE PricebookEntry.Product2.NumberOfRevenueInstallments != null)  
										FROM Quote
										WHERE Id IN :Trigger.new];
	System.debug('Number of quotes we will evaluate: ' + allQuotesList.size());												
																						
	// Foreplay is over.  Time for the good stuff.		
	List<QuoteLineItem> updateList = new List<QuoteLineItem>();																			
	for (Quote q : allQuotesList) {
		System.debug('Evaluating changes to quote ' + q.Id);

		Date oldStartDate;		
		Date newStartDate;
		if (Trigger.oldMap.get(q.Id).Order_Start_Date__c != null) {
			oldStartDate = Trigger.oldMap.get(q.Id).Order_Start_Date__c;
		}
		if (Trigger.newMap.get(q.Id).Order_Start_Date__c != null) {
			newStartDate = Trigger.newMap.get(q.Id).Order_Start_Date__c;
		}
		
		Date oldEndDate;
		Date newEndDate;
		if (Trigger.oldMap.get(q.Id).Order_End_Date__c != null) {
			oldEndDate = Trigger.oldMap.get(q.Id).Order_End_Date__c;
		}				
		if (Trigger.newMap.get(q.Id).Order_End_Date__c != null) {
			newEndDate = Trigger.newMap.get(q.Id).Order_End_Date__c;
		}
		
		// Check if start date or end date is changed
		if ((oldStartDate != null && newStartDate != null && oldStartDate != newStartDate) || (oldEndDate != null && newEndDate != null && oldEndDate != newEndDate)) {
			System.debug('A start or end date has been changed...');			
			if (q.QuoteLineItems != null && q.QuoteLineItems.size() > 0) {
				System.debug(q.QuoteLineItems.size() + ' ARR line items that need to be changed.');
				for (QuoteLineItem qli : q.QuoteLineItems) {
					if (qli.PricebookEntry != null && qli.PricebookEntry.Product2 != null && qli.PricebookEntry.Product2.NumberOfRevenueInstallments != null) {
						qli.Purchase_Start_Date__c = newStartDate;
						qli.Purchase_End_Date__c = newEndDate;
						updateList.add(qli);	
						System.debug('New dates for ' + qli.PricebookEntry.Product2.Name + ': ' + qli.Purchase_Start_Date__c + ' - ' + qli.Purchase_End_Date__c);
					}		
				}
			}
		}
	}
	if (updateList != null && updateList.size() > 0) {
		update updateList;
		System.debug(updateList.size() + ' products updated.');
	}


}