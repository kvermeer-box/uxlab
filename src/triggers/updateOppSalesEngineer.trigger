trigger updateOppSalesEngineer on Sales_Request__c (before update, after insert) {
	
	// Get a set of all opps that are related to the Sales Requests in this trigger
	Set<Id> oppIds = new Set<Id>();
	for (Sales_Request__c s : Trigger.new) {
		if (s.Opportunity__c != null) {
			oppIds.add(s.Opportunity__c);
		}
	}
	
	// Get the field values we need from the related opps
	Map<Id, Opportunity> oppsMap = new Map<Id, Opportunity>();
	if (oppIds != null && oppIds.size() > 0) {
		List<Opportunity> oppsList = [SELECT Id, Sales_Engineer_Lookup__c, Sales_Engineer_Lookup__r.Name FROM Opportunity WHERE Id IN :oppIds];
		if (oppsList != null && oppsList.size() > 0) {
			oppsMap.putAll(oppsList);
		}
	}

	/** 
	 * Fills in the "Sales Engineer" field on an opp when the following are true:
	 *  1. Must be an SE Request record type 
	 *  2. Dominator must be changed and non-null  
	 *  3. SE Request must tie to an opp
	 *  4. "Sales Engineer" on the opp must be null
	 */
	for (Sales_Request__c s : Trigger.new) {
				
		// Must be an SE Request
		System.debug('Sales Request record type: ' + s.RecordTypeId);
		if (s.RecordTypeId == '012600000009VN9') {
			
			// Set up the old dominator value
			String oldDominator;			
			if (Trigger.isInsert) {
				oldDominator = null;
			} else {
				oldDominator = Trigger.oldMap.get(s.Id).Dominator__c;
			}
			
			// SE Request must have a dominator and it must be changing
			String newDominator = Trigger.newMap.get(s.Id).Dominator__c;									
			System.debug('Old dominator: ' + oldDominator + '. New dominator: ' + newDominator);
			if (newDominator != null && !newDominator.equals(oldDominator)) {
				
				// SE Request must tie to an opp
				System.debug('Opportunity: ' + s.Opportunity__c);
				if (s.Opportunity__c != null) {
					
					// If this set is null or size is 0, something is wrong
					if (oppsMap != null && oppsMap.size() > 0) {
						
						// "Sales Engineer" must not be populated on the opp	
						Opportunity o = oppsMap.get(s.Opportunity__c);
						System.debug('Sales Engineer on opp: ' + o.Sales_Engineer_Lookup__r.Name);
						if (o == null || o.Sales_Engineer_Lookup__c == null) {
							System.debug('New sales engineer on opp: ' + s.Dominator__c);
							o.Sales_Engineer_Lookup__c = s.Dominator__c;
							update o;
						}				
					}
				}
			}
		}
	}

}