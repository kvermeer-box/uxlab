global with sharing class Box_AccountFactory {

	public static Account createAccountFromSalesTransaction(Box_SalesTransaction salesTransaction) {
		System.debug('Box_AccountFactory: Creating account from box sales transaction...');
		 
		if (salesTransaction == null) {
			throw new CustomException('Error: Cannot create account when sales transaction is null.');
		}
		
		if (salesTransaction == null || salesTransaction.enterprise == null || salesTransaction.enterprise.administered_by == null 
			|| salesTransaction.enterprise.administered_by.login == null || salesTransaction.enterprise.administered_by.login.equals('')) { 
			throw new CustomException('Error: Cannot create account without an enterprise admin login.'); 
		} 
		
		// Create an account
		Account account = new Account();
		translateSalesTransactionToAccount(salesTransaction, account);
		insert account;
		Box_AccountPartnerKeyFactory.upsertPartnerKey(salesTransaction.external_account_id, account.Id);
		System.debug('Box_AccountFactory: Account created.');
		
		return account;
	} 
	
	public static Account findOrCreateAccountFromSalesTransaction(Box_SalesTransaction salesTransaction, Boolean updateAccount) { 
		System.debug('Box_AccountFactory: Finding or creating account from sales transaction...');	
		
		Account account;
		if (salesTransaction == null) {
			throw new CustomException('Error: Cannot find or create account from sales transaction.');
		}		
		
		// Try finding first, then create	
		try {
			account = Box_AccountDAO.findAccountFromSalesTransaction(salesTransaction, updateAccount);
			if (updateAccount != null && updateAccount) {
				account = translateSalesTransactionToAccount(salesTransaction, account);
				update account;
			} 
		} catch (Exception e) {
			account = createAccountFromSalesTransaction(salesTransaction);
		}
		return account;
	}
	
	public static Account translateSalesTransactionToAccount(Box_SalesTransaction salesTransaction, Account account) {
		System.debug('Box_AccountFactory: Translating sales transaction to account...');
		if (account != null) {
			account.RecordTypeId = Box_CustomSettings.getAccountRecordTypeId();
				
			// Update account name
			if (account.Name == null) {
				if (salesTransaction.enterprise.name != null) { 
					account.Name = salesTransaction.enterprise.name; 
				} else {
					account.Name = salesTransaction.enterprise.administered_by.login;
				}
			}		
			
			// Pop in the key
			if (salesTransaction.external_account_id != null && account.Id != null) { Box_AccountPartnerKeyFactory.upsertPartnerKey(salesTransaction.external_account_id, account.Id); }
		}
			
		return account;
	}
	
}