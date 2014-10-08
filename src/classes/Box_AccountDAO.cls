global with sharing class Box_AccountDAO {

	// Each transaction will only ever refer to one partner
	static Account partner;

	public static Map<String, String> getParamKeys() {
		Map<String, String> paramKeyMap = new Map<String, String>(); 
		paramKeyMap = new Map<String, String>();
		paramKeyMap.put('resellerid', 'Reseller_ID__c');
		paramKeyMap.put('externalaccountid', 'EXTERNAL_ACCOUNT_ID'); 
		return paramKeyMap;  
	} 

	public static String getQuery() {
		System.debug('Box_AccountDAO: Getting the base SOQL query for accounts...');
		
		String q = ' SELECT Id,' 
				 + '        Name, '
				 + '        Reseller_ID__c, '
				 + '        Total_Account_Value__c, '
				 + ' 		Partner_Order_Length__c, '
				 + ' 		Partner_Trial_Length__c, '
				 + ' 		Partner_Extended_Trial_Length__c, '
				 + ' 		Partner_Price_Per_Seat_Business__c, '
				 + ' 		Partner_Price_Per_Seat_Enterprise__c, '		
				 + ' 		Partner_Price_Per_Seat_Unlimited__c '						 
			 	 + '	FROM Account ';			 	 

		System.debug('Box_AccountDAO: Query: ' + q); 
	 	return q;
	}
	
	public static Account getAccountFromKey(String key, String value, Boolean isNumber) {
		System.debug('Box_AccountDAO: Querying Account by key...');		
		
		Account a;
		if (key != null && value != null && !key.equals('') && !value.equals('')) {
			// Special treatment for partner external IDs
			if (key.equals(getParamKeys().get('externalaccountid'))) {
				key = 'Id';
				value = Box_AccountPartnerKeyDAO.getAccountIdFromPartnerKey(value);
			}
			
			// Check if number or string
			if (!isNumber) {
				value = '\'' + value + '\'';
			}
			// Build query
			System.debug('Box_AccountDAO: Looking for ' + value + ' on the account ' + key + ' field...');
			String q = getQuery() + ' '
			         + ' WHERE ' + key + ' = ' + value + ' ';
	        System.debug('Box_AccountDAO: Final query: ' + q);	        
			         
			// Execute query         
         	List<Account> accounts = (List<Account>)Database.query(q);
         	if (accounts == null || accounts.size() == 0) {
				throw new CustomException('Error: no account found for ' + value + '.');
			} else if (accounts.size() > 1) {
				throw new CustomException('Error: multiple accounts found for ' + value + '.');
			} else {				
				a = accounts[0];
				System.debug('Box_AccountDAO: Account found: ' + a);
			}		
		} else {			
			throw new CustomException('Error: invalid parameters.');
		}		
		return a;
	}
	
	public static Account findAccountFromSalesTransaction(Box_SalesTransaction salesTransaction, Boolean updateAccount) {
		System.debug('Box_AccountDAO: Finding account from box sales transaction...');		
		
		// Make sure we have all we need
		if (salesTransaction == null) {
			throw new CustomException('Error: Cannot find an account. Transaction is null.');
		} 
		
		// Get variables ready
		Account account;		
		
		if (salesTransaction == null || salesTransaction.external_account_id == null || salesTransaction.external_account_id.equals('')) {
			throw new CustomException('Error: Cannot find an account. External account id is null.');
		}
		
		// Find by reseller id
		try { 
			account = getAccountFromKey(getParamKeys().get('externalaccountid'), salesTransaction.external_account_id, false); 
		} catch (Exception ex) {
			throw new CustomException('Error: No account found for partner external id ' + salesTransaction.external_account_id);
		}
		
		if (updateAccount) {
			Box_AccountFactory.translateSalesTransactionToAccount(salesTransaction, account);
		}
								
		return account;
	}
	
	public static Account findPartnerFromRunningUser() {
		System.debug('Box_AccountDAO: Finding partner account from running user...');
		
		if (partner == null) {
			User u = [SELECT Id, Reseller_ID__c FROM User WHERE Id = :UserInfo.getUserId()];
			
			// Must have reseller ID!
			if (u.Reseller_ID__c == null) {
				throw new CustomException('Error: No reseller ID associated with current user ' + UserInfo.getUserId());
			}
			
			try {		
				partner = getAccountFromKey('Reseller_ID__c', String.valueOf(u.Reseller_ID__c.setScale(1)), true); 
			} catch (Exception e) {
				throw new CustomException('Error: No account found for reseller ' + u.Reseller_ID__c);
			}
		} 
		
		return partner;	
	}
	
	public static Account findPartnerFromSalesTransaction(Box_SalesTransaction salesTransaction) {
		System.debug('Box_AccountDAO: Finding partner account from box sales transaction...');		
		
		if (partner == null) {
			// Make sure we have all we need
			if (salesTransaction == null) {
				throw new CustomException('Error: Cannot find an account. Transaction is null.');
			} 
			
			try {
				partner = findPartnerFromRunningUser();
			} catch (Exception e) {		
				// Find by reseller id
				try {
					partner = getAccountFromKey(getParamKeys().get('resellerid'), String.valueOf(Decimal.valueOf(salesTransaction.partner_id).setScale(1)), true); 
				} catch (Exception ex) {
					throw new CustomException('Error: No partner account found.');
				}
			}
		}
								
		return partner;
	}
	
	public static Account findPartnerFromTenant(Tenant__c tenant) {
		System.debug('Box_AccountDAO: Finding partner account from tenant...');
		
		if (partner == null) {
			// First, try by the associated opportunities
			String q = Box_OpportunityDAO.getQuery()
				   	 + ' WHERE ' + Box_OpportunityDAO.getParamKeys().get('tenant') + ' = \'' + tenant.Id + '\' '
				   	 + ' ORDER BY Opportunity.CreatedDate DESC '
				   	 + ' LIMIT 1 ';
			Opportunity o = (Opportunity)Database.query(q); 
			if (o != null && o.Box_Partner_Account__c != null) {
				partner = o.Box_Partner_Account__r; 
			} 
			
			// Now go by running user 
			if (partner == null) {
				partner = findPartnerFromRunningUser();
			}
		}
		return partner;
	}

	public static Double getPartnerPricePerSeat(String plan, Account partnerAccount) {
		Double pps;
		System.debug('Box_AccountDAO: Getting partner price per seat...');
		if (plan != null && !plan.equals('')) {
			if (plan.toLowerCase().equals(Box_EnterpriseAccountTypeEnum.BUSINESS.name().toLowerCase())) {
				pps = partnerAccount.Partner_Price_Per_Seat_Business__c; 
			} else if (plan.toLowerCase().equals(Box_EnterpriseAccountTypeEnum.ENTERPRISE.name().toLowerCase())) {
				pps = partnerAccount.Partner_Price_Per_Seat_Enterprise__c;
			} else if (plan.toLowerCase().equals(Box_EnterpriseAccountTypeEnum.ENTERPRISE_UNLIMITED.name().toLowerCase())) {
				pps = partnerAccount.Partner_Price_Per_Seat_Unlimited__c;
			}
		}
		System.debug('Box_AccountDAO: PPS: ' + pps);
		return pps;
	}

}