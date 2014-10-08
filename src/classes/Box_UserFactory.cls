global with sharing class Box_UserFactory {
	
	public static Contact createContactFromSalesTransaction(Box_SalesTransaction salesTransaction) {
		System.debug('Box_UserFactory: Creating contact from sales transaction...');
		
		Contact contact;
		if (salesTransaction == null) {
			throw new CustomException('Error: Cannot create contact from null sales transaction.');	
		}		
										
		// Make sure we have all inputs
		if (salesTransaction == null || salesTransaction.enterprise == null || salesTransaction.enterprise.administered_by == null) {
			throw new CustomException('Error: Valid admin could not be found.');
		} else if (salesTransaction.enterprise.administered_by.name == null || salesTransaction.enterprise.administered_by.name.equals('')) {
			throw new CustomException('Error: Name not specified. Cannot create contact.');
		} else if (salesTransaction.enterprise.administered_by.login == null || salesTransaction.enterprise.administered_by.login.equals('')) {
			throw new CustomException('Error: Email not specified. Cannot create contact.');
		}
			
		// Create an account 
		Account account = Box_AccountFactory.findOrCreateAccountFromSalesTransaction(salesTransaction, true); 

		// Create a new contact	
		contact = new Contact();
		contact.AccountId = account.Id;		
		contact = translateSalesTransactionToContact(salesTransaction, contact);
		insert contact;
		Box_UserPartnerKeyFactory.upsertPartnerKey(salesTransaction.external_contact_id, contact.Id);
		System.debug('Box_UserFactory: Contact created.' + contact);

		return contact;
	}
	
	public static Contact findOrCreateContactFromSalesTransaction(Box_SalesTransaction salesTransaction, Boolean updateContact) {
		System.debug('Box_UserFactory: Finding or creating contact from sales transaction...');	
		
		Contact contact;
		if (salesTransaction == null) {
			throw new CustomException('Error: Cannot find or create contact from sales transaction.');
		}		
		
		// Try finding first, then create	
		try {
			contact = Box_UserDAO.findContactFromSalesTransaction(salesTransaction, updateContact);
			if (updateContact) {
				contact = translateSalesTransactionToContact(salesTransaction, contact);
				update contact;
			}
		} catch (Exception e) {
			contact = createContactFromSalesTransaction(salesTransaction);
		}
		return contact;
	}
	
	public static Contact translateSalesTransactionToContact(Box_SalesTransaction salesTransaction, Contact contact) {
		System.debug('Box_UserFactory: Translating sales transaction into contact...');
		
		if (contact == null) {
			throw new CustomException('Error: Cannot translate objects when contact is null.');
		} else if (salesTransaction == null) {
			throw new CustomException('Error: Cannot translate objects when sales transaction is null');
		}
						
		// Get variables ready
		Box_User user = salesTransaction.enterprise.administered_by;
	
		// Update the contact
		if (user.id != null)           { contact.Box_User_ID__c = user.id;  }
		if (user.login != null)        { contact.Email = user.login;        }
		if (user.phone_number != null) { contact.Phone = user.phone_number; }
		
		// Format the contact's name
		translateBoxNameToContactName(user, contact);
		
		// Pop in the key
		if (salesTransaction.external_contact_id != null) { Box_UserPartnerKeyFactory.upsertPartnerKey(salesTransaction.external_contact_id, contact.Id); }
		
		System.debug('Box_UserFactory: Contact: ' + contact);
		return contact;
	}
	
	private static Contact translateBoxNameToContactName(Box_User user, Contact contact) {
		System.debug('Box_UserFactory: Translating box user name to contact name...');
		
		if (user == null) {
			throw new CustomException('Error: Cannot translate name when user is null.');
		} else if (contact == null) {
			throw new CustomException('Error: Cannot translate name when contact is null.');
		} else if (user.name == null || user.name.equals('')) {
			throw new CustomException('Error: Cannot translate name when name is null.');
		}
		
		// Format the contact's name
		List<String> name = user.name.split(' ', 2);
		if (name != null && name.size() == 1) {
			contact.LastName = name[0];
		} else if (name.size() == 2) {
			contact.FirstName = name[0];
			contact.LastName = name[1];
		}		
		return contact;
	}
	
}