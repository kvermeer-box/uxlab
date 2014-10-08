@RestResource(urlMapping='/1.0/dealreg/*')
global with sharing class Box_DealRegRest {
 
	@HttpGet
	global static void doGet() {
		// Set variables. Params are auto decoded!
		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;
		Map<String, String> reqParams = req.params;
		
		// Debug request		
		System.debug('Http GET Deal Reg received.'); 
		System.debug('Parameters:');
		for (String s : reqParams.keySet()) {
			System.debug(s + ': ' + reqParams.get(s));
		}
		 
		// Determine deduping method 	  
		String dedupeField;
		String dedupeValue;	 	 
		Map<String, String> allParams = Box_OpportunityDAO.getParamKeys();
		for (String paramField : reqParams.keySet()) {
			if (allParams.get(paramField) != null && !allParams.get(paramField).equals('')) {
				dedupeField = allParams.get(paramField);
				dedupeValue = reqParams.get(paramField);
				break;
			}
		}
		System.debug('We will search for ' + dedupeValue + ' on the ' + dedupeField + ' field.');		
		
		// Determine if we should query all deal regs or just live ones		
		Boolean approvedOnly;
		Box_DealRegApprovalType approvalType = Box_DealRegApprovalType.ALL; 
		String isLiveString = reqParams.get('is_live');
		if (isLiveString != null) {
			approvedOnly = Boolean.valueOf(isLiveString);
			if (approvedOnly == null) {
				approvalType = Box_DealRegApprovalType.ALL;
			} else if (approvedOnly) {
				approvalType = Box_DealRegApprovalType.APPROVED;
			} else {
				approvalType = Box_DealRegApprovalType.PENDING;
			}
		}
		
		// Query		
		Map<Opportunity, OpportunityContactRole> oppAndOcrMap; 
		try {			
			oppAndOcrMap = Box_OpportunityDAO.getOpportunityAndContactRoleFromKeyAndApprovalType(dedupeField, dedupeValue, approvalType); 
		} catch (Exception e) {
			// Not found
			res.statusCode = 404;
			res.responseBody = Box_GenericError.parseGenericException(e);
			return;
		}	
		
		// Create json to return.
		Box_BasicDealReg basicDealReg = new Box_BasicDealReg();
		basicDealReg.parseOpportunityAndOpportunityContactRole(oppAndOcrMap);
		
		// return
		String response = JSON.serialize(basicDealReg);
		System.debug('Box_DealRegRest: Status code: ' + res.statusCode);
		System.debug('Box_DealRegRest: Response body: ' + response);
		res.responseBody = Blob.valueOf(response);
	}	

}