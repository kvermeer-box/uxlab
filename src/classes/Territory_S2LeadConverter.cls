public class Territory_S2LeadConverter {

	// Major variables
	private List<Lead> leads;
	private boolean buttonContext;

	// Retrofix variables
	private Map<Id, Lead> retroFixContactOwners;
	private Map<Id, Lead> retroFixAccountOwners;
	
	// Errors
	private List<String> errorMessages;

	private String WEB_TRIAL = 'WEB TRIAL';

	public Territory_S2LeadConverter(List<Lead> leads, boolean buttonContext) {
		this.leads = leads;
		this.buttonContext = buttonContext;
		retroFixContactOwners = new Map<Id, Lead>();
		retroFixAccountOwners = new Map<Id, Lead>();
		errorMessages = new List<String>();
	}

	public static Set<String> getLeadFieldsForConversion() {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2LeadConverter: Getting fields required for lead conversion..');
		
		Set<String> fieldsForConversion = new Set<String>();
		fieldsForConversion.add('Email');
		fieldsForConversion.add('Business_Web_Trial__c');		
		
		fieldsForConversion.add('Territory_Routing_Account__r.Id');
		fieldsForConversion.add('Territory_Routing_Account__r.Owner.Id');
		fieldsForConversion.add('Territory_Convert_to_Account__r.Id');
		fieldsForConversion.add('Territory_Convert_to_Contact__r.Id');
		fieldsForConversion.add('Territory_Convert_to_Contact__r.Account.Id');
		fieldsForConversion.add('Territory_Convert_to_Contact__r.Account.Owner.Id');
		fieldsForConversion.add('Territory_Do_Not_Assign_to_Territory__c');
		
		return fieldsForConversion;
	}

	public Map<Id, Database.LeadConvertResult> convertLeads() {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2LeadConverter: Converting batch of ' + leads.size() + ' leads..');
		Map<Id, Database.LeadConvertResult> leadConvertMap;
		
		// Filter...
		leads = dedupeLeads(leads);
		leads = validateLeadConversionInputs(leads);
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2LeadConverter: ' + leads.size() + ' leads will attempt to be converted..');
		
		// Prepare for conversion		
		List<Database.LeadConvert> leadConverts = createLeadConverts(leads);
		
		// Convert
		if (leadConverts != null && leadConverts.size() > 0) {
			List<Database.LeadConvertResult> leadConvertResults = Database.convertLead(leadConverts, false);
			leadConvertMap = createLeadConvertMap(leadConvertResults);
			System.debug(System.LoggingLevel.ERROR, 'Territory_S2LeadConverter: ' + leads.size() + ' leads converted.'); 
					
			// Associate opportunity contact roles
			List<OpportunityContactRole> oppContactRoles = setAllPrimaryContactRoles(leadConvertResults);			
		}
		
		// Retro fix account and contact owners, since their ownership was overridden
		retroFixObjectOwners(leadConvertMap);
		
		// Print errors
		printErrors();
		
		return leadConvertMap;
	}
	
	private void retroFixObjectOwners(Map<Id, Database.LeadConvertResult> leadConvertResults) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2LeadConverter: Retro fixing object owners..');
		
		// Return a list of contacts and their fixes
		List<Contact> contactsToFix = new List<Contact>();	
		if (retroFixContactOwners != null && retroFixContactOwners.size() > 0) {
			for (String id : retroFixContactOwners.keySet()) {
				Database.LeadConvertResult lcr = leadConvertResults.get(id);
				if (lcr != null) {
					Contact c = new Contact(Id = lcr.getContactId());
					c.OwnerId = retroFixContactOwners.get(id).OwnerId;
					contactsToFix.add(c);
					System.debug(System.LoggingLevel.ERROR, 'Territory_S2LeadConverter: ' + c.Id + '\'s owner will be fixed to ' + c.OwnerId);
				}
			}
		}
		
		// Return a list of accounts and their fixes
		List<Account> accountsToFix = new List<Account>();
		if (retroFixAccountOwners != null && retroFixAccountOwners.size() > 0) {
			for (String id : retroFixAccountOwners.keySet()) {
				Database.LeadConvertResult lcr = leadConvertResults.get(id);
				if (lcr != null) {
					Account a = new Account(Id = lcr.getAccountId());
					a.OwnerId = retroFixAccountOwners.get(id).OwnerId;
					accountsToFix.add(a);
					System.debug(System.LoggingLevel.ERROR, 'Territory_S2LeadConverter: ' + a.Id + '\'s owner will be fixed to ' + a.OwnerId);
				}
			}
		}
		
		// Save these bad boys
		if (contactsToFix != null && contactsToFix.size() > 0) {
			update contactsToFix;
		}
		if (accountsToFix != null && accountsToFix.size() > 0) {
			update accountsToFix;
		}
	}
	
	private List<OpportunityContactRole> setAllPrimaryContactRoles(List<Database.LeadConvertResult> leadConvertResults) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2LeadConverter: Setting primary contact roles on converted leads..');
		
		List<OpportunityContactRole> oppContactRoles;
		if (leadConvertResults != null) {
			// Get successfully converted leads
			Set<String> successfullyConvertedLeadIds = new Set<String>();
			for (Database.LeadConvertResult lcr : leadConvertResults) {
				if (lcr.getErrors() == null || lcr.getErrors().size() == 0) {
					successfullyConvertedLeadIds.add(lcr.getLeadId());
				} else {
					for (Database.Error e : lcr.getErrors()) {
						errorMessages.add('Error on lead ' + lcr.getLeadId() + ': ' + e.getMessage());
					}
				}
			}
			
			// Query contact roles
			if (successfullyConvertedLeadIds != null && successfullyConvertedLeadIds.size() > 0) {
				oppContactRoles = new List<OpportunityContactRole>();
				List<OpportunityContactRole> ocrs = [SELECT Id FROM OpportunityContactRole WHERE OpportunityId IN :successfullyConvertedLeadIds];
				if (ocrs != null && ocrs.size() > 0) {
					for (OpportunityContactRole ocr: ocrs) {
						ocr.IsPrimary = true;
						oppContactRoles.add(ocr);
					}					
					update oppContactRoles;
					System.debug(System.LoggingLevel.ERROR, 'Territory_S2LeadConverter: Primary boolean set on ' + oppContactRoles.size() + ' opportunity contact roles.');
				}
			}			
		}
		return oppContactRoles;
	}
	
	private void printErrors() {
		if (errorMessages != null && errorMessages.size() > 0) {
			for (String s : errorMessages) {
				System.debug(System.LoggingLevel.ERROR, 'Territory_S2LeadConverter: ' + s);
			}
		}
	}
	
	private List<Database.LeadConvert> createLeadConverts(List<Lead> leads) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2LeadConverter: Creating lead convert objects..');
		 
		List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
		for (Lead l : leads) { 
			// Create lead convert and set standard fields
			Database.LeadConvert lc = new Database.LeadConvert();
			lc.setLeadId(l.Id);                          
            lc.setOwnerId(l.OwnerId);
            lc.setConvertedStatus(Territory_CustomSettings.getLeadConvertedStatus());
            lc.setSendNotificationEmail(true);
            
            // Set routing method specific fields
            Territory_S2RoutingMethod routingMethod = Territory_S2RulesFinder.getLeadRoutingMethod(l);
            if (routingMethod == Territory_S2RoutingMethod.CONTACT) {
            	lc.setContactId(l.Territory_Convert_to_Contact__r.Id);
            	lc.setAccountId(l.Territory_Convert_to_Contact__r.Account.Id);
            	
            	// We need to fix the contact because the contact owner might not be the contact's account owner
            	retroFixContactOwners.put(l.Id, l);            	
            } else if (routingMethod == Territory_S2RoutingMethod.ACCOUNT_WITH_REASSIGNMENT) {
            	lc.setAccountId(l.Territory_Convert_to_Account__r.Id); 
            	
            	// We need to fix the convert to account because the owner might not be the routing account owner
            	retroFixAccountOwners.put(l.Id, l);
            } else if (routingMethod == Territory_S2RoutingMethod.ACCOUNT_WITHOUT_REASSIGNMENT) {
            	lc.setAccountId(l.Territory_Convert_to_Account__r.Id);
            	
            	// We need to fix the convert to account because the owner might not be the routing account owner
            	retroFixAccountOwners.put(l.Id, l);
            }
            leadConverts.add(lc);
		}
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2LeadConverter: Lead convert objects ' + leadConverts.size());
		return leadConverts;
	}
	
	private Map<Id, Database.LeadConvertResult> createLeadConvertMap(List<Database.LeadConvertResult> leadConvertResults) {
		Map<Id, Database.LeadConvertResult> leadConvertMap = new Map<Id, Database.LeadConvertResult>();
		for (Database.LeadConvertResult lcr : leadConvertResults) {
			if (lcr.getErrors() == null || lcr.getErrors().size() == 0) {
				leadConvertMap.put(lcr.getLeadId(), lcr);
			}
		}
		return leadConvertMap;
	}
	
	private List<Lead> dedupeLeads(List<Lead> leads) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2LeadConverter: Getting list of deduped leads..');
		
		List<Lead> dedupedLeads = new List<Lead>();
		Set<String> existingEmailAddresses = getExistingContactDupeEmailAddresses(leads);
		for (Lead l : leads) {
			if (l.Email != null && existingEmailAddresses.contains(l.Email)) {
				errorMessages.add('Error on lead ' + l.Id + ': Duplicate email address found - ' + l.Email);
				if (buttonContext) {
					System.debug(System.LoggingLevel.ERROR, 'Error: Duplicate email address found on a contact. Temporarily change the lead email address (add xyz) and try again.');
					throw new CustomException('Error: Duplicate email address found on a contact. Temporarily change the lead email address (add xyz) and try again.');
				}
			} else {
				dedupedLeads.add(l);
			}
		}
		return dedupedLeads;
	}
	
	private Set<String> getExistingContactDupeEmailAddresses(List<Lead> leads) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2LeadConverter: Getting set of existing email addresses from contacts..');
		Set<String> existingContactDupeEmailAddresses = new Set<String>();
		
		// Get a set of possible emails		
		Set<String> leadEmails = new Set<String>();
		for (Lead l : leads) {
			if (l.Email != null && l.Territory_Convert_to_Contact__c == null) {
				leadEmails.add(l.Email);
			}
		}
		
		// Query for contacts with matching emails
		List<Contact> contactsWithMatchingEmails = [SELECT Id, Email FROM Contact WHERE Email IN :leadEmails];
		for (Contact c : contactsWithMatchingEmails) {
			existingContactDupeEmailAddresses.add(c.Email);
		} 
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2LeadConverter: ' + existingContactDupeEmailAddresses.size() + ' contacts with existing email addresses.');
		
		return existingContactDupeEmailAddresses;
	}
	
	private List<Lead> validateLeadConversionInputs(List<Lead> leads) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2LeadConverter: Validating lead inputs for conversion..');
		
		List<Lead> validatedLeads = new List<Lead>();
		for (Lead l : leads) {
			if (l.Business_Web_Trial__c != null && l.Business_Web_Trial__c) {
				errorMessages.add('Error on lead ' + l.Id + ': Web trials cannot be routed.');
				if (buttonContext) {
					System.debug(System.LoggingLevel.ERROR, 'Error: Web trials cannot routed.');
					throw new CustomException('Error: Web trials cannot routed.');
				}
			/*	
			} else if (l.Number_of_Users__c == null || l.Number_of_Users__c == 0) {
				errorMessages.add('Error on lead ' + l.Id + ': "Number of Users" is required.');
				if (buttonContext) {
					System.debug(System.LoggingLevel.ERROR, 'Error: "Number of Users" is required.');
					throw new CustomException('Error: "Number of Users" is required.');
				}
			*/
			} else {
				validatedLeads.add(l);
			}
		}
		return validatedLeads;
	}

}