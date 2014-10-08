global with sharing class Box_UserDAO {

	public static Map<String, String> getParamKeys() {
		Map<String, String> paramKeyMap = new Map<String, String>();
		paramKeyMap = new Map<String, String>();
		paramKeyMap.put('email', 'Email');
		return paramKeyMap; 
	} 
	
	public static String getQuery() {
		System.debug('Box_UserDAO: Getting the base SOQL query for contacts...');
		
		String q = ' SELECT Id,' 
				 + ' 		Account.Id, '
				 + ' 		Account.Name, '
				 + ' 		Account.Total_Account_Value__c, '
			 	 + ' 		FirstName, '			 	
			 	 + ' 		LastName, '
			 	 + ' 		Email, '				 
   				 + ' 		Phone '
			 	 + '	FROM Contact ';			 	 

		System.debug('Box_UserDAO: Query: ' + q);
	 	return q;
	} 
	
	public static Contact getContactFromKey(String key, String value) {
		System.debug('Box_UserDAO: Querying contacts by key...');		
		
		Contact c;
		if (key != null && value != null && !key.equals('') && !value.equals('')) {
			// Build query
			System.debug('Box_UserDAO: Looking for ' + value + ' on the contact ' + key + ' field...');
			String q = getQuery() + ' '
			         + ' WHERE ' + key + ' = \'' + value + '\' ';
	        System.debug('Box_UserDAO: Final query: ' + q);	        
			         
			// Execute query         
         	List<Contact> contacts = (List<Contact>)Database.query(q);
         	if (contacts == null || contacts.size() == 0) {
				throw new CustomException('Error: no contact found for ' + value + '.');
			} else if (contacts.size() > 1) {
				throw new Box_DuplicateRecordException(contacts);
			} else {				
				c = contacts[0];
				System.debug('Box_UserDAO: Contact found: ' + c);
			}		
		} else {			
			throw new CustomException('Error: invalid parameters.');
		}		
		return c;
	}
	
	public static Contact findContactFromSalesTransaction(Box_SalesTransaction salesTransaction, Boolean updateContact) {
		System.debug('Box_UserDAO: Finding contact from sales transaction...');			
		
		// Make sure we have all inputs
		if (salesTransaction == null) {
			throw new CustomException('Error: Cannot find contact from null sales transaction.');
		} 
		
		// Get variables ready
		Contact contact;		
		
		if (salesTransaction == null || salesTransaction.enterprise == null || salesTransaction.enterprise.administered_by == null 
			|| salesTransaction.enterprise.administered_by.login == null || salesTransaction.enterprise.administered_by.login.equals('')) {
			throw new CustomException('Error: Email (login) not specified. Cannot create contact.');
		} 
		
		// Attempt to find contact
		try {
			contact = getContactFromKey(getParamKeys().get('email'), salesTransaction.enterprise.administered_by.login);	
		} catch (Box_DuplicateRecordException d) {
			// Dupes found. Find the tenant, then the admin.
			Tenant__c tenant = Box_TenantDAO.findTenantFromSalesTransaction(salesTransaction);
			contact = tenant.Admin__r;			
		} catch (Exception e) {
			throw new CustomException('Error: No contact found with email address ' + salesTransaction.enterprise.administered_by.login);
		}
		
		if (updateContact) {
			Box_UserFactory.translateSalesTransactionToContact(salesTransaction, contact);
		}
		
		return contact;	
	}

}