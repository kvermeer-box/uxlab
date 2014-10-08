global class Box_BasicDealReg {

	// Partner properties
	public String sales_rep_id;  // ATTUID__c
	public String sales_rep_email;  // Partner_Submitter_Email__c
	
	// Customer properties
	public String external_account_id;  // Partner_Key_Account__c
	public String customer_company_name; // Account.Name
	public String customer_contact_name; // Contact.Name
	public String customer_contact_email; // Contact.Email
	
	// Deal reg properties
	public Boolean is_live;
	
	public void parseOpportunityAndOpportunityContactRole(Map<Opportunity, OpportunityContactRole> oppAndOcrMap) {
		System.debug('Box_BasicDealReg: Parsing opportunity to basic deal reg object...');
		
		Opportunity opp;
		OpportunityContactRole ocr;
		for (Opportunity o : oppAndOcrMap.keySet()) {
			opp = o;
			ocr = oppAndOcrMap.get(o);
		}
		
		if (opp.ATTUID__c != null)                      { sales_rep_id = opp.ATTUID__c; }
		if (opp.Partner_Submitter_Email__c != null)     { sales_rep_email = opp.Partner_Submitter_Email__c; }
		if (opp.Account.Name != null)                   { customer_company_name = opp.Account.Name; }
		if (ocr.Contact.Name != null)                   { customer_contact_name = ocr.Contact.Name; }
		if (ocr.Contact.Email != null)                  { customer_contact_email = ocr.Contact.Email; }
		
		external_account_id = Box_AccountPartnerKeyDAO.getPartnerKeyFromAccountIdAndRunningUser(opp.Account.Id);
				
		if (Box_OpportunityDAO.opportunityIsValid(opp)) { 
			is_live = true;
		} else {
			is_live = false;
		}
	}
	
}