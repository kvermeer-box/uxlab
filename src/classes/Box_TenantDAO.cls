global with sharing class Box_TenantDAO {
	
	private static final String STATE_SUSPEND_CHURN_REASON = 'Billing: Non-payment';
	private static final String ACTIVE_STATUS_ACTIVE = 'active';
	private static final String ACTIVE_STATUS_DEACTIVATED = 'deactivated'; 

	public static Map<String, String> getParamKeys() {
		Map<String, String> paramKeyMap = new Map<String, String>();
		paramKeyMap = new Map<String, String>();
		paramKeyMap.put('id', 'Enterprise_ID_Tenant__c');
		paramKeyMap.put('email', 'Admin__r.Email');
		paramKeyMap.put('externalaccountid', 'EXTERNAL_ACCOUNT_ID');
		return paramKeyMap; 
	} 
	
	public static String getQuery() {
		System.debug('Box_TenantDAO: Getting the base SOQL query for tenants...');
		
		String q = ' SELECT Id,' 
				 + ' 		Account_Type__c, '
				 + '        Active_Status__c, '
				 + ' 		Admin__r.Id, '
				 + ' 		Admin__r.Account.Total_Account_Value__c, ' 
			 	 + ' 		Admin_Email_Lookup__c, '			 	 
			 	 + ' 		Admin_Name_Lookup__c, '
			 	 + ' 		Admin_Phone_Number_Lookup__c, '				 
   				 + ' 		Billing_Cycle__c, '
   				 + '		Blocked_Status__c, '
				 + ' 		Deal_Status__c, '
				 + ' 		Enterprise_ID_Tenant__c, '				 
				 + ' 		Hide_Add_User_UI__c, '
				 + ' 		Name, '
				 + ' 		Price_Per_User__c, '
				 + '		Seats_Allocated__c, '
				 + '		Seats_Used__c, '
				 + ' 		Silent_Mode__c, '
				 + ' 		Space_Allocated__c, '
				 + '		Space_Used__c, '
				 + '		Subdomain__c, '
				 + ' 		Trial_Start_Date__c, '
			 	 + ' 		Trial_End_Date__c, '
			 	 + ' 		Trial_Extended__c, '
			 	 + ' 		Last_Transaction_ID__c, ' 
			 	 + ' 		Box_Sync_Error_Response_Body__c, '
			 	 + ' 		Account__r.Id, '
			 	 + ' 		Account__r.Total_Account_Value__c, '
			 	 + '        Reseller_ID__c, '
			 	 + '		( Select Box_Partner_Account__r.Reseller_ID__c From Opportunities__r ORDER BY CreatedDate ASC ) '
			 	 + '	FROM Tenant__c ';			 	 

		System.debug('Query: ' + q); 
	 	return q;
	}
	
	public static Tenant__c getTenantFromKey(String key, String value) {
		System.debug('Box_TenantDAO: Querying tenant by key...');		
		
		Tenant__c t;
		if (key != null && value != null && !key.equals('') && !value.equals('')) {
			
			// Partner external IDs get the special treatment
			if (key.equals(getParamKeys().get('externalaccountid'))) {
				key = 'Account__r.Id'; 
				value = Box_AccountPartnerKeyDAO.getAccountIdFromPartnerKey(value); 
			}			
			
			// Build query
			System.debug('Box_TenantDAO: Looking for ' + value + ' on the tenant ' + key + ' field...');
			String q = getQuery() + ' '
			         + ' WHERE ' + key + ' = \'' + value + '\' ';
	        System.debug('Box_TenantDAO: Final query: ' + q);	        
			         
			// Execute query         
         	List<Tenant__c> tenants = (List<Tenant__c>)Database.query(q);
         	if (tenants == null || tenants.size() == 0) {
				throw new CustomException('Error: no tenant found for ' + value + '.');
			} else if (tenants.size() > 1) {
				throw new CustomException('Error: multiple tenants found for ' + value + '.');
			} else {				
				t = tenants[0];
				System.debug('Box_TenantDAO: Tenant found: ' + t);
			}		
		} else {			
			throw new CustomException('Error: invalid parameters.');
		}		
		return t;
	}

	public static Tenant__c findTenantFromSalesTransaction(Box_SalesTransaction salesTransaction) {
		System.debug('Box_TenantDAO: Finding tenant from sales transaction...');		
		
		// Make sure we have all we need
		if (salesTransaction == null) {
			throw new CustomException('Error: Cannot find a tenant. Sales transaction is null.');
		} 
		
		// Get variables ready
		Tenant__c tenant;		
		
		// Make sure we have inputs
		if (salesTransaction == null || salesTransaction.enterprise == null 
			|| ((salesTransaction.enterprise.id == null || salesTransaction.enterprise.id.equals(''))  
				&& (salesTransaction.enterprise.administered_by == null || salesTransaction.enterprise.administered_by.login == null || salesTransaction.enterprise.administered_by.login.equals(''))) 
				&& (salesTransaction.external_account_id == null || salesTransaction.external_account_id.equals(''))) {	
			throw new CustomException('Error: cannot find tenant when enterprise id, admin login, and external account id are null.');
		}
		
		Box_Enterprise enterprise = salesTransaction.enterprise;
		// Find by enterprise id first 
		try { 
			tenant = getTenantFromKey(getParamKeys().get('id'), enterprise.id); 
		} catch (Exception ex) {
			System.debug('Box_TenantDAO: Tenant could not be found by enterprise id ' + enterprise.id);
		}
		// Try admin email
		if (tenant == null) {
			try { 
				tenant = getTenantFromKey(getParamKeys().get('email'), enterprise.administered_by.login); 
			} catch (Exception ex) {
				System.debug('Box_TenantDAO: Tenant could not be found by admin email ' + enterprise.administered_by.login);
			}
		}									
		
		// Try Partner External ID
		if (tenant == null) {
			try { 
				tenant = getTenantFromKey(getParamKeys().get('externalaccountid'), salesTransaction.external_account_id); 
			} catch (Exception ex) {
				System.debug('Box_TenantDAO: Tenant could not be found by external account id ' + salesTransaction.external_account_id);
				throw new CustomException('Error: Could not find tenant from enterprise.');
			}
		}		
				
		return tenant;
	}
	
	public static Box_TransactionState getState(Tenant__c tenant) {
		System.debug('Box_TenantDAO: Calculating state...');
		
		Box_TransactionState state;
		if (tenant != null) {
			// State corresponds to active status, unless it is deactivated		
			if (tenant.Active_Status__c == null || tenant.Active_Status__c.equals(ACTIVE_STATUS_ACTIVE)) {
				state = Box_TransactionState.initiate;
			// Deactivated can mean cancel or suspend, depending on the most recent closed opp	
			} else {
				state = Box_TransactionState.cancel;				
				try {
					// Search for the most recent closed opp
					Account account = [SELECT Id, (SELECT Id, Churn_Reason__c FROM Opportunities WHERE IsClosed = true ORDER BY CloseDate DESC, CreatedDate DESC) FROM Account WHERE Id = :tenant.Account__r.Id];
					if (account != null && account.Opportunities != null && account.Opportunities.size() > 0) {
						List<Opportunity> opps = account.Opportunities;
						if (opps[0].Churn_Reason__c != null && opps[0].Churn_Reason__c.equals(STATE_SUSPEND_CHURN_REASON)) {
							state = Box_TransactionState.suspend;
						}
					}
				} catch (Exception e) {}
			}	
		}			
		System.debug('Box_TenantDAO: State: ' + state);
		return state;
	}

}