global with sharing class Box_OpportunityDAO {

	private static Map<String, String> opportunityValidityMap;
	private static Map<String, String> opportunityApprovedMap;
	private static Map<String, String> allOpportunityCriteriaMap;

	public static Map<String, String> getParamKeys() {
		Map<String, String> paramKeyMap = new Map<String, String>();
		paramKeyMap = new Map<String, String>();
		paramKeyMap.put('email', 'Contact.Email');
		paramKeyMap.put('customer_contact_email', 'Contact.Email');
		paramKeyMap.put('externalaccountid', 'EXTERNAL_ACCOUNT_ID');
		paramKeyMap.put('external_account_id', 'EXTERNAL_ACCOUNT_ID');		
		paramKeyMap.put('id', 'Opportunity.Id');
		paramKeyMap.put('tenant', 'Opportunity.Tenant__r.Id');
		paramKeyMap.put('accountid', 'Opportunity.Account.Id');
		return paramKeyMap; 
	} 

	public static String getQuery() {
		System.debug('Box_OpportunityDAO: Getting the base SOQL query for opportunities...');
		
		String q = ' SELECT Id, '
				 + ' 		Contact.Email, '
				 + ' 		Contact.Name, '
				 + ' 		Opportunity.Id, '
				 + ' 		Opportunity.Name, '
				 + ' 		Opportunity.Account.Id, '
				 + ' 		Opportunity.Account.Name, '
				 + '		Opportunity.Account.Total_Account_Value__c, '
				 + ' 		Opportunity.Box_Partner_Account__r.Id, '
				 + ' 		Opportunity.Box_Partner_Account__r.Partner_Order_Length__c, ' 
				 + ' 		Opportunity.Box_Partner_Account__r.Partner_Trial_Length__c, '
				 + ' 		Opportunity.Box_Partner_Account__r.Partner_Extended_Trial_Length__c, '
				 + ' 		Opportunity.Box_Partner_Account__r.Partner_Price_Per_Seat_Business__c, '
				 + ' 		Opportunity.Box_Partner_Account__r.Partner_Price_Per_Seat_Enterprise__c, '		
				 + ' 		Opportunity.Box_Partner_Account__r.Partner_Price_Per_Seat_Unlimited__c, '					 
				 + ' 		Opportunity.Amount, '
				 + ' 		Opportunity.RecordTypeId, '
				 + ' 		Opportunity.Seats_Sold__c, '
				 + ' 		Opportunity.Account_Type_Sold__c, '
				 + ' 		Opportunity.CloseDate, '
				 + ' 		Opportunity.StageName, '
				 + ' 		Opportunity.IsClosed, '
				 + ' 		Opportunity.Deal_Reg_Approval_Status__c, '				 
				 + '		Opportunity.ATTUID__c, '
				 + '		Opportunity.Partner_Submitter_Email__c '
				 + '	FROM OpportunityContactRole ';	

		System.debug('Box_OpportunityDAO: Query: ' + q);
	 	return q;
	} 
	
	// Refactored version
	public static Opportunity getOpportunityFromKey(String key, String value) {
		System.debug('Box_OpportunityDAO: Querying opportunity by key...');					
		
		Opportunity opp;						
		if (key != null && value != null && !key.equals('') && !value.equals('')) {
			// Special treatment for partner external IDs
			if (key.equals(getParamKeys().get('externalaccountid'))) {
				key = 'Opportunity.Account.Id';
				value = Box_AccountPartnerKeyDAO.getAccountIdFromPartnerKey(value);
			} 
			
			// Build query
			System.debug('Box_OpportunityDAO: Looking for value ' + value + ' on the OpportunityContactRole.' + key + ' field...');
			String q = getQuery() + ' '
			         + ' WHERE IsPrimary = true '		         
			         + ' ' + getOppSoqlCriteria(getAllCriteriaMap()) + ' '
			         + ' AND ' + key + ' = \'' + value + '\' ';     
	        System.debug('Box_OpportunityDAO: Final query: ' + q);
	        // + ' 	AND Opportunity.RecordTypeId = \'' + Box_CustomSettings.getOpportunityPartnerRecordTypeId() + '\' '	  
	        
	        // Query
	        List<OpportunityContactRole> results = (List<OpportunityContactRole>)Database.query(q);
	        
	        // Find the single opp
	        opp = parseSingleOpportunity(results);   
		}
        
        return opp;						
	}
	
	// Refactored version
	private static Opportunity parseSingleOpportunity(List<OpportunityContactRole> results) {
		Opportunity opp;
		if (results == null || results.size() == 0) {
			throw new CustomException('Error: Deal reg opportunity could not be found.');
		} else if (results.size() > 1) {
			throw new CustomException('Error: Multiple deal reg opportunities found. Please contact your administrator');
		} else {
			opp = results[0].Opportunity;
			System.debug('Box_OpportunityDAO: Opportunity found: ' + opp);
		}
		return opp;
	}
	
	// Refactored version
	public static Map<Opportunity, OpportunityContactRole> getOpportunityAndContactRoleFromKeyAndApprovalType(String key, String values, Box_DealRegApprovalType approvalType) {
		System.debug('Box_OpportunityDAO: Querying opportunity and opp contact role by key and approval type...');
		
		List<String> valuesList = new List<String>();
		valuesList = parseCsvToSet(values);
		
		// Special treatment for partner external IDs
		if (key.equals(getParamKeys().get('externalaccountid'))) {
			key = 'Opportunity.Account.Id';
			values = Box_AccountPartnerKeyDAO.getAccountIdFromPartnerKey(values);
		} 
		
		// Build query
		System.debug('Box_OpportunityDAO: Looking for value(s) ' + values + ' on the OpportunityContactRole.' + key + ' field...');
		String q = getQuery() + ' '
		         + ' WHERE IsPrimary = true ';
		         
		         // Depending on the approval type, we restrict to only pending deal regs, approved, or no restrictions.
		         System.debug(String.valueOf(approvalType));
		         if (approvalType == Box_DealRegApprovalType.PENDING) {
		         	q += getOppSoqlCriteria(getOpportunityValidityMap()) + ' ';
		         } else if (approvalType == Box_DealRegApprovalType.APPROVED) { 
		         	q += getOppSoqlCriteria(getAllCriteriaMap()) + ' ';
		         } 
		         
		         // Let us check for a match among multiple inputs
		         if (valuesList != null && valuesList.size() > 1) {
		         	q += ' AND ' + key + ' IN :valuesList ';
		         } else {
		         	q += ' AND ' + key + ' = \'' + values + '\' ';
		         }					         		
		         q += ' ORDER BY Opportunity.CreatedDate DESC ';	        
        System.debug('Box_OpportunityDAO: Final query: ' + q);	  
        
        // Query
        List<OpportunityContactRole> results = (List<OpportunityContactRole>)Database.query(q);
        
        // Find the single opp
        Map<Opportunity, OpportunityContactRole> oppAndContactRole = parseSingleOpportunityAndContactRole(results, approvalType);           
        return oppAndContactRole;   				
	}
	
	// Refactored version
	private static Map<Opportunity, OpportunityContactRole> parseSingleOpportunityAndContactRole(List<OpportunityContactRole> results, Box_DealRegApprovalType approvalType) {
		Map<Opportunity, OpportunityContactRole> oppAndContactRole = new Map<Opportunity, OpportunityContactRole>();
		if (results == null || results.size() == 0) {
			if (approvalType == null || approvalType == Box_DealRegApprovalType.ALL) {
				throw new CustomException('Error: No deal reg opportunities found.');
			} else if (approvalType == Box_DealRegApprovalType.PENDING) {
				throw new CustomException('Error: No pending deal reg opportunities found.');
			} else if (approvalType == Box_DealRegApprovalType.APPROVED) {
				throw new CustomException('Error: No approved deal reg opportunities found.');
			}
		} else if (results.size() > 1 && approvalType == Box_DealRegApprovalType.APPROVED) {
			throw new CustomException('Error: Multiple approved deal regs found.');
		} else {			
			// Now return the ocr's parent opportunity	
			OpportunityContactRole ocr = results[0];
			Opportunity o = ocr.Opportunity;
			oppAndContactRole.put(o, ocr);
			System.debug('Box_OpportunityDAO: Opportunity found: ' + o);			
		}	
		return oppAndContactRole;
	}
	
	
	public static boolean opportunityIsValid(Opportunity opp) {
		boolean valid = true;
		Map<String, String> criteria = getAllCriteriaMap();		
		for (String s : criteria.keySet()) {
			String validValue = criteria.get(s);
			String actualValue = String.valueOf(opp.get(s));
			if (validValue != null && actualValue != null && !validValue.equals('') && validValue != actualValue) {
				valid = false;
				break;
			} 
		}
		return valid;
	}
	
	private static Map<String, String> getOpportunityValidityMap() {		
		Map<String, String> validityMap = new Map<String, String>();
		if (opportunityValidityMap != null) {
			validityMap = opportunityValidityMap;
		} else {					
			validityMap.put('isClosed', 'false');
			validityMap.put('RecordTypeId', Box_CustomSettings.getOpportunityPartnerRecordTypeId());
		}
		return validityMap;
	}
	
	private static Map<String, String> getOpportunityApprovedMap() {		
		Map<String, String> approvedMap = new Map<String, String>();
		if (opportunityApprovedMap != null) {
			approvedMap = opportunityApprovedMap;
		} else {
			approvedMap.put('Deal_Reg_Approval_Status__c', 'Approved');
		}
		return approvedMap;		
	}
	
	private static Map<String, String> getAllCriteriaMap() {
		Map<String, String> critMap = new Map<String, String>();
		if (allOpportunityCriteriaMap != null) {
			critMap = allOpportunityCriteriaMap;
		} else {
			critMap.putAll(getOpportunityValidityMap());
			critMap.putAll(getOpportunityApprovedMap());
		}
		return critMap;
	}
	
	private static Boolean isStringField(String sObjectName, String fieldName) {
		Boolean isString = false;
		DescribeSObjectResult dsr = Schema.getGlobalDescribe().get(sObjectName).getDescribe();
		Schema.SOAPType fieldType = dsr.fields.getMap().get(fieldName).getDescribe().getSOAPType();
		if (fieldType == Schema.SOAPType.String || fieldType == Schema.SOAPType.Id) {
			isString = true;
		}
		return isString;
	}
	
	private static String getOppSoqlCriteria(Map<String, String> criteriaMap) {
		String q = '';
		for (String s : criteriaMap.keySet()) {
			if (isStringField('Opportunity', s)) {
         		q += ' AND Opportunity.' + s + ' = \'' + criteriaMap.get(s) + '\' ';
     		} else {
     			q += ' AND Opportunity.' + s + ' = ' + criteriaMap.get(s) + ' ';
     		} 
		}
		System.debug('Box_OpportunityDAO: Soql criteria' + q);
		return q;
	}
		
	private static List<String> parseCsvToSet(String valueSet) {
		List<String> stringList = new List<String>();
		if (valueSet != null) {
			List<String> stringListTmp = valueSet.split(',');
			for (String s : stringListTmp) { 
				stringList.add(s.trim());
			}
		}
		System.debug('Box_OpportunityDAO: valuesList = ' + stringList);
		return stringList;
	}
	
	public static Opportunity findOpportunityFromSalesTransaction(Box_SalesTransaction salesTransaction) {
		System.debug('Box_OpportunityDAO: Finding opportunity from sales transaction...');		
		
		// Make sure we have all we need
		if (salesTransaction == null) {
			throw new CustomException('Error: Cannot find an opportunity. Sales transaction is null.');
		} 
		
		// Get variables ready
		Opportunity o;		
		
		// Make sure we have the inputs we need
		if (salesTransaction == null || salesTransaction.enterprise == null ||
			(salesTransaction.external_account_id == null || salesTransaction.external_account_id.equals('')) && 
			(salesTransaction.enterprise.administered_by == null || salesTransaction.enterprise.administered_by.login == null || salesTransaction.enterprise.administered_by.login.equals(''))) {
			throw new CustomException('Error: Cannot find an opportunity. Enterprise needs an external account id or user login parameter.');
		}
		
		Box_Enterprise enterprise = salesTransaction.enterprise;
		// Find by external account id first
		try { 
			o = getOpportunityFromKey(getParamKeys().get('externalaccountid'), salesTransaction.external_account_id); 
		} catch (Exception ex) {
			System.debug('Box_OpportunityDAO: Opportunity could not be found by external account id ' + salesTransaction.external_account_id);
		}
		// Try admin email
		if (o == null) {
			try { 
				o = getOpportunityFromKey(getParamKeys().get('email'), enterprise.administered_by.login); 
			} catch (Exception ex) {
				System.debug('Box_OpportunityDAO: Opportunity could not be found by admin email ' + enterprise.administered_by.login);
				throw ex;
			}
		}									
		return o;
	} 
	
	public static Opportunity findOpportunityFromTenant(Tenant__c tenant) {
		System.debug('Box_OpportunityDAO: Finding opportunity from tenant...');
		
		// Make sure we have the inputs we need
		if (tenant == null) {
			throw new CustomException('Error: Cannot find an opportunity. Tenant is null.');
		} else if (tenant.Account__r.Id == null && tenant.Admin_Email_Lookup__c == null) {
			throw new CustomException('Error: no account id or admin email on tenant');
		}
		
		Opportunity opportunity;
		// Find by external account id first
		try { 
			opportunity = getOpportunityFromKey(getParamKeys().get('accountid'), tenant.Account__r.Id); 
		} catch (Exception ex) {
			System.debug('Box_OpportunityDAO: Opportunity could not be found by account id ' + tenant.Account__r.Id);
		}
		// Try admin email
		if (opportunity == null) {
			try { 
				opportunity = getOpportunityFromKey(getParamKeys().get('email'), tenant.Admin_Email_Lookup__c); 
			} catch (Exception ex) {
				System.debug('Box_OpportunityDAO: Opportunity could not be found by admin email ' + tenant.Admin_Email_Lookup__c);
				throw new CustomException('Error: Could not find deal reg opportunity for enterprise ' + tenant.Admin_Email_Lookup__c);
			}
		}									
		return opportunity;
	}
 
	public static boolean isNetNewRevenueRequest(Account account, Box_SalesTransaction salesTransaction, Tenant__c tenant, Account partner) {
		System.debug('Box_OpportunityDAO: Checking if request results in net new revenue...');
		boolean netNewRevenue = true;
		Double newTav = Box_OpportunityFactory.calculateTavDelta(account, salesTransaction, tenant, partner); 
		if (newTav > 0) {
			netNewRevenue = true;
		} else {
			netNewRevenue = false;
		}
		System.debug('Box_OpportunityDAO: Net new revenue request: ' + netNewRevenue);
		return netNewRevenue;
	}

}