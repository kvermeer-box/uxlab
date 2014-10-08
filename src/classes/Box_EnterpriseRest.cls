@RestResource(urlMapping='/1.0/enterprises/*')
global with sharing class Box_EnterpriseRest {
	 
	@HttpGet 
	global static void doGet() {				
		// Set variables. Params are auto decoded!
		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;
		Map<String, String> reqParams = req.params;
		
		// Debug request		
		System.debug('Http GET Enterprise received.');
		System.debug('Parameters:');
		for (String s : reqParams.keySet()) {
			System.debug(s + ': ' + reqParams.get(s));
		}
		 
		// Determine deduping method 	 
		String dedupeField;
		String dedupeValue;	 	 
		Map<String, String> allParams = Box_TenantDAO.getParamKeys();
		for (String paramField : reqParams.keySet()) {
			if (allParams.get(paramField) != null && !allParams.get(paramField).equals('')) {
				dedupeField = allParams.get(paramField);
				dedupeValue = reqParams.get(paramField);
			}
		}
		System.debug('We will search for ' + dedupeValue + ' on the ' + dedupeField + ' field.');			
		
		// Query		
		Tenant__c tenant; 
		try {
			tenant = Box_TenantDAO.getTenantFromKey(dedupeField, dedupeValue);
		} catch (Exception e) {
			// Not found
			res.statusCode = 404;
			res.responseBody = Box_GenericError.parseGenericException(e);
			return;
		}
		
		// Create json to return.
		Box_SalesTransaction salesTransaction = new Box_SalesTransaction(); 
		salesTransaction.convertTenantToSalesTransaction(tenant);	
		Box_BasicSalesTransaction basicSalesTransaction = salesTransaction.convertToBasicSalesTransaction();
		
		// return
		String response = JSON.serialize(basicSalesTransaction);
		System.debug('Box_EnterpriseRest: Status code: ' + res.statusCode);
		System.debug('Box_EnterpriseRest: Response body: ' + response);
		res.responseBody = Blob.valueOf(response);
	}
	
	@HttpPost
	/**
	 * For initiate calls:
	 *  1. Find a matching deal reg opp
	 *  2. Find a matching partner
	 *  3. Create/update enterprise
	 *  4. Close the deal reg in SFDC
	 *
	 * For cancel/suspend calls:
	 *  1. Find a matching partner
	 *  2. Create/update enterprise
	 *  3. Create churn records in SFDC
	 */
	global static void doPost() {
		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;
		String requestBody = req.requestBody.toString(); 
		
		// Debug request
		System.debug('Http POST received.');
		System.debug('Body: ' + requestBody); 
		
		// Deserialize
		Box_SalesTransaction salesTransaction;
		try {
			Box_BasicSalesTransaction basicSalesTransaction = (Box_BasicSalesTransaction)JSON.deserialize(requestBody, Box_BasicSalesTransaction.class);
			salesTransaction = basicSalesTransaction.convertToSalesTransaction();
			salesTransaction.parseStateToEnterpriseStatus();
		} catch (Exception e) {
			res.statusCode = 400;
			res.responseBody = Box_GenericError.parseGenericException(e);
			return;
		}
		
		// If this is not a cancel/suspend, try to find a matching deal reg opportunity
		Opportunity dealReg;	
		if (salesTransaction.state != null && (salesTransaction.state == Box_TransactionState.cancel || salesTransaction.state == Box_TransactionState.suspend)) {
			res.statusCode = 400;	
			CustomException ex = new CustomException('Error: Cancel and suspend states are not supported in POST requests.');
			res.responseBody = Box_GenericError.parseGenericException(ex);
			return;
		} else {
			try {
				dealReg = Box_OpportunityDAO.findOpportunityFromSalesTransaction(salesTransaction);
			} catch (Exception e) {
				res.statusCode = 412;
				res.responseBody = Box_GenericError.parseGenericException(e);
				return;
			}
		}
		
		// Now find a matching partner account
		Account partner;
		try {
			partner = Box_AccountDAO.findPartnerFromSalesTransaction(salesTransaction);
		} catch (Exception e) {
			res.statusCode = 404;
			res.responseBody = Box_GenericError.parseGenericException(e);
			return;
		}
				
		// Try to find an existing tenant in Salesforce first		
		Tenant__c tenant;
		try {
			tenant = Box_TenantDAO.findTenantFromSalesTransaction(salesTransaction);
						
			// Throw an error is it's active
			if (tenant.Active_Status__c.toLowerCase().equals(Box_ActiveStatus.active.name())) {
				res.statusCode = 400;
				res.responseBody = Blob.valueOf('Error: Enterprise is already active.');
				return;
			// If deactivated, ignore it
			} else {
				tenant = null;
			}
		} catch (Exception e) {
			System.debug('No tenant currently found.');
		}
		
		// No tenant exists, create one	- initiate states only!
		Box_SyncingEnterprise boxSyncer = new Box_SyncingEnterprise(salesTransaction);
		try {
			/* 12/30/2013 call method for AT&T Reseller */
			tenant = (Tenant__c)boxSyncer.create(true);		
		} catch (Box_CalloutException c) {
			res.statusCode = c.getHttpResponseError().status;
			res.responseBody = Blob.valueOf(JSON.serialize(c.getHttpResponseError()));			
			return;		
		} catch (Exception e) {
			res.statusCode = 500;
			res.responseBody = Box_GenericError.parseGenericException(e);
			return;
		}			
		
		// Create the SFDC revenue objects
		Box_DealFactory deal;
		salesTransaction = boxSyncer.salesTransaction;	 
		try {
			deal = new Box_DealFactory(salesTransaction, dealReg, null, partner, tenant); 
			deal.closeDeal(); 
		} catch (Exception e) {
			res.statusCode = 500;
			res.responseBody = Box_GenericError.parseGenericException(e);			
			return;
		} 
		
		// Update keys if necessary
		try {
			salesTransaction.updatePartnerKeys();
		} catch (NoDataFoundException n) {
			res.statusCode = 404;
			res.responseBody = Box_GenericError.parseGenericException(n);
			return;
		} catch (Exception e) {
			res.statusCode = 500;
			res.responseBody = Box_GenericError.parseGenericException(e);
			return;
		}
		
		// Return
		String response = JSON.serialize(salesTransaction.convertToBasicSalesTransaction());
		System.debug('Box_EnterpriseRest: Status code: ' + res.statusCode);
		System.debug('Box_EnterpriseRest: Response body: ' + response);
		res.responseBody = Blob.valueOf(response);
	}
	
	@HttpPut
	global static void doPut() {
		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;
		String requestBody = req.requestBody.toString();
		
		// Get enterprise id
		String uri = req.requestURI;
		String enterpriseId;		
		Integer index = uri.lastIndexOf('enterprises/') == -1 ? null : uri.lastIndexOf('enterprises/') + 12; 
		if (index != null && index > 0) {
			enterpriseId = uri.substring(index);
		}
		if (enterpriseId == null || enterpriseId.equals('') || index == 0) {
			res.statusCode = 400;
			CustomException e = new CustomException('No enterpise ID specified.');
			res.responseBody = Box_GenericError.parseGenericException(e);
			return;
		}
		
		// Debug request
		System.debug('Http PUT received.');
		System.debug('Body: ' + requestBody);
		
		// Deserialize
		Box_SalesTransaction salesTransaction;
		try {
			Box_BasicSalesTransaction basicSalesTransaction = (Box_BasicSalesTransaction)JSON.deserialize(requestBody, Box_BasicSalesTransaction.class);
			salesTransaction = basicSalesTransaction.convertToSalesTransaction();
			salesTransaction.parseStateToEnterpriseStatus();
		} catch (Exception e) {
			res.statusCode = 400;
			res.responseBody = Box_GenericError.parseGenericException(e);
			return;
		}
		
		// Try to find tenant
		Tenant__c tenant;
		Tenant__c originalTenant;
		Box_SyncingEnterprise boxSyncer = new Box_SyncingEnterprise(salesTransaction);
		try {
			tenant = Box_TenantDAO.getTenantFromKey(Box_TenantDAO.getParamKeys().get('id'), enterpriseId);
			originalTenant = tenant.clone();
		} catch (Exception e) {
			res.statusCode = 404;
			res.responseBody = Box_GenericError.parseGenericException(e);
			return;
		}
		
		// Now find a matching partner account
		Account partner;
		try { 
			partner = Box_AccountDAO.findPartnerFromSalesTransaction(salesTransaction);
		} catch (Exception e) {
			res.statusCode = 404;
			res.responseBody = Box_GenericError.parseGenericException(e);
			return;
		} 
		
		// If this is a net new revenue transaction, deal reg is required
		Opportunity dealReg;		
		if (Box_OpportunityDAO.isNetNewRevenueRequest(tenant.Account__r, salesTransaction, tenant, partner)) {
			try {
				dealReg = Box_OpportunityDAO.findOpportunityFromTenant(tenant);
			} catch (Exception e) {
				res.statusCode = 412;
				res.responseBody = Box_GenericError.parseGenericException(e);
				return;
			}
		}

		// Sync
		try {
			boxSyncer.setSObject(tenant);
			
			/* 03/03/14 - Call correct edit method for AT&T reseller */
			//tenant = (Tenant__c)boxSyncer.edit();
			tenant = (Tenant__c)boxSyncer.edit(true);
			
		} catch (Box_CalloutException c) {
			res.statusCode = c.getHttpResponseError().status;
			res.responseBody = Blob.valueOf(JSON.serialize(c.getHttpResponseError()));
			return;
		} catch (Exception ex) {
			res.statusCode = 500;
			res.responseBody = Box_GenericError.parseGenericException(ex);
			return;
		}

		// Set new (updated) sales transaction object
		salesTransaction = boxSyncer.salesTransaction;			
		
		// Create the SFDC revenue objects
		Box_DealFactory deal;
		salesTransaction = boxSyncer.salesTransaction;	 
		try {
			deal = new Box_DealFactory(salesTransaction, dealReg, originalTenant, partner, tenant); 
			deal.closeDeal(); 
		} catch (Exception e) {
			res.statusCode = 500;
			res.responseBody = Box_GenericError.parseGenericException(e);			
			return;
		}
		
		// Update keys if necessary
		try {
			salesTransaction.updatePartnerKeys();
		} catch (NoDataFoundException n) {
			res.statusCode = 404;
			res.responseBody = Box_GenericError.parseGenericException(n);
			return;
		} catch (Exception e) {
			res.statusCode = 500;
			res.responseBody = Box_GenericError.parseGenericException(e);
			return;
		}
		
		// Return
		String response = JSON.serialize(salesTransaction.convertToBasicSalesTransaction());
		System.debug('Box_EnterpriseRest: Status code: ' + res.statusCode);
		System.debug('Box_EnterpriseRest: Response body: ' + response);
		res.responseBody = Blob.valueOf(response);
	}

}