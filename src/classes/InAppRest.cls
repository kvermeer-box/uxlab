@RestResource(urlMapping='/processInAppUpgrade/*')
global class InAppRest {

	public static InAppRestSettings__c settings = InAppRestSettings__c.getInstance('default');
	
	// General Constants
	public static final String CONTACT_METHOD_MOST_RECENT    = settings.Contact_Method_Most_Recent__c;
	public static final String EXCLUDED_OPP_STAGES_LIST      = settings.Excluded_Opp_Stages__c;
	public static final String IN_APP_OPP_NAME_APPEND        = settings.Opp_Name_Append_Text__c;  
	public static final String CLOSED_WON_PICKLIST_VALUE     = settings.Closed_Won_Picklist_Value__c;
	public static final String CLOSED_WON_OPP_RECORD_TYPE_ID = settings.Closed_Won_Opportunity_Record_Type_Id__c;
	public static final String BUSINESS_PBE_ID               = settings.Business_Price_Book_Entry_Id__c;
	public static final String CONVERTED_CONTACT_OPP_STAGE   = settings.Converted_Contact_Opp_Stage__c;	
	public static final String OPP_ACCOUNT_TYPE_SOLD         = 'Business';	
	
	// Mapping values
	public static final String FEE_FREQUENCY_MAPPING         = settings.Fee_Frequency_Mapping__c;
	public static final String PRIOR_ACCOUNT_TYPE_MAPPING    = settings.Prior_Account_Type_Mapping__c;
	public static final String DEFAULT_LEAD_CONVERTED_STATUS = settings.Default_Lead_Converted_Status__c;
	public static final String DEFAULT_OBJECTS_OWNER_ID      = settings.Default_Objects_Owner_Id__c;
	
	// Status code values
	public static final String CLOSED_WON_STATUS_CODE         = settings.Closed_Won_Status_Code__c; 
	public static final String CLOSED_WON_ALREADY_STATUS_CODE = settings.Closed_Won_Already_Status_Code__c;	
	public static final String INVALID_ZUORA_STATUS_CODE      = settings.Invalid_Zuora_Status_Code__c;
	public static final String NO_OPPORTUNITY_STATUS_CODE     = settings.No_Opportunity_Status_Code__c; 
	public static final String NO_ENTERPRISE_ID_STATUS_CODE   =	settings.No_Enterprise_Id_Status_Code__c; 
	public static final String NO_EMAIL_ADDRESS_STATUS_CODE   = settings.No_Email_Address_Status_Code__c;
	public static final String SCRIPT_ERROR_STATUS_CODE       = settings.Script_Error_Status_Code__c;
	public static final String DUPLICATE_RECORD_STATUS_CODE   = 'duplicate_record_found';
	
	// Closed Won validation constants
	public static final String  CLOSED_WON_SUBSCRIPTION_STATUS     = settings.Closed_Won_Subscription_Status__c;
	public static final String  CLOSED_WON_PAYMENT_METHOD_TYPE     = settings.Closed_Won_Payment_Method_Type__c;
	public static final String  CLOSED_WON_LAST_TRANSACTION_STATUS = settings.Closed_Won_Last_Transaction_Status__c;
	public static final Decimal LAST_PAYMENT_EVENT_DATE_DELTA      = settings.Last_Payment_and_Event_Date_Delta__c;
	public static final String  CLOSED_WON_LAST_PAYMENT_STATUSES   = settings.Closed_Won_Last_Payment_Statuses__c;	

	// Campaign constants
	public static final String ASSOCIATE_CAMPAIGN_ID = settings.Associated_Campaign_ID__c;
	public static final String CAMPAIGN_STATUS       = 'Responded';
	
	@HttpPost 
	global static InApp processInAppUpgrade (InApp inAppRecord) {
		return processSingleInAppUpgrade(inAppRecord);		
	}  
	
	/**
	 * Step 1: Create Opportunity in Salesforce
	 * Step 2: Validate data in Opportunity fields
	 * Step 3: Set Status Code based on Zuora information
	 * Step 4: Close out new, valid Opportunities 
	 */
	global static InApp processSingleInAppUpgrade(InApp inAppRecord) {
		
		System.debug('InAppRest POST request received.');
		
		// Data confirmation step - only for existing Opportunities
		if (inAppRecord != null && inAppRecord.enterpriseId != null && !inAppRecord.enterpriseId.equals('')) {
			System.debug('Initial In-App record: ' + String.valueOf(inAppRecord));
			if (inAppRecord.email != null && !inAppRecord.email.equals('')) {				
				try {										
					// Step 0: Check for duplicate leads, contacts, and opps (by enterprise ID)
					Lead lead = duplicateLeadCheck(inAppRecord);
					Contact contact;
					if (lead == null) {
						contact = duplicateContactCheck(inAppRecord);
					}
					duplicateOppCheck(inAppRecord);				
																							
					// Step 1: Create opportunity from lead or contact
					Opportunity opp;
					if (contact == null) {
						opp = createConvertedLeadOpportunity(inAppRecord, lead);
					} else {
						opp = createOpportunityFromContact(inAppRecord, contact);
					}
						
					if (opp != null) {		
						
						// We always do this to help Dary
						opp.Name = opp.Name + IN_APP_OPP_NAME_APPEND;
						update opp;
														
						// Step 2: Validate data in Opportunity fields
						confirmOpportunityData(opp, inAppRecord);
						
						// Step 3: Set Status Code based on Zuora information
						determineInAppStatusCode(opp, inAppRecord);
						
						// Step 4: Close out new, valid Opportunities 
						updateOpportunityAndCreateTenant(opp, inAppRecord);

						// Step 5: FCCRM Association
						// FCRM.FCR_SupportAPI.AssociateOpportunitiesToResponses(new List<Opportunity>{opp}); 

						// Db.execute
						if (inAppRecord.readOnly == null || !inAppRecord.readOnly) {
							update opp;
							
							// update Account
							Account a = new Account(Id = opp.AccountId);
							a.Box_Enterprise_ID__c = inAppRecord.enterpriseId;
							update a;
							
							inAppRecord.readOnly = false;
							System.debug('Opportunity has been saved to the database!.');
						} else {
							inAppRecord.readOnly = true;		
							System.debug('Read only mode: Opp will not be saved to the database.');	
						}																				
					} else {
						inAppRecord.statusCode = NO_OPPORTUNITY_STATUS_CODE;
						inAppRecord.errorMsg = 'No Opportunity found in Salesforce with id: ' + inAppRecord.opportunityId;
						System.debug('No Opportunity found in Salesforce with id: ' + inAppRecord.opportunityId);
					}									
				} catch (Exception e) {
					if (inAppRecord.statusCode == null || inAppRecord.statusCode.equals('')) { 				
						inAppRecord.statusCode = SCRIPT_ERROR_STATUS_CODE;
					}
					inAppRecord.errorMsg = e.getStackTraceString() + ': ' + e.getMessage();
					System.debug('Error: ' + e.getStackTraceString() + ': ' + e.getMessage());
				} 		
			} else {
				inAppRecord.statusCode = NO_EMAIL_ADDRESS_STATUS_CODE;
				inAppRecord.errorMsg = 'No email address.';
				System.debug('No email address.');
			}	
		} else {
			inAppRecord.statusCode = NO_ENTERPRISE_ID_STATUS_CODE;
			inAppRecord.errorMsg = 'No Enterprise ID.';		
			System.debug('No Enterprise ID.');	
		}
				
		System.debug('Final In-App record: ' + String.valueOf(inAppRecord));		
		return inAppRecord;
	}	
	
	public static void duplicateOppCheck(InApp inAppRecord) {
		System.debug('Checking the system for opportunities with the same enterprise ID...');
		if (inAppRecord != null && inAppRecord.enterpriseId != null && !inAppRecord.enterpriseId.equals('')) {
			List<Opportunity> duplicateOpps = [SELECT Id, Box_Enterprise_ID__c FROM Opportunity WHERE Box_Enterprise_ID__c = :inAppRecord.enterpriseId];
			if (duplicateOpps != null && duplicateOpps.size() > 0) {
				String errorMsg = 'Error: duplicate opp(s) found: ';
				for (Opportunity o : duplicateOpps) {
					errorMsg += o.Id + ' ';
				}
				inAppRecord.statusCode = DUPLICATE_RECORD_STATUS_CODE;
				throw new CustomException(errorMsg);
			}
		}
	}
	
	public static Lead duplicateLeadCheck(InApp inAppRecord) {
		System.debug('Checking the system for leads with the same email...');
		Lead lead;
		if (inAppRecord != null && inAppRecord.email != null && !inAppRecord.email.equals('')) {
			List<Lead> duplicateLeads = [SELECT Id, Email FROM Lead WHERE IsConverted = false AND Email = :inAppRecord.email];
			if (duplicateLeads == null || duplicateLeads.size() == 0) {
				System.debug('No duplicate leads found. Moving on...');
			} else if (duplicateLeads.size() == 1) {
				lead = duplicateLeads[0];				
				System.debug('One lead found: ' + lead.Id + '. Using this lead moving forward...');
			} else {					
				String errorMsg = 'Error: Multiple duplicate leads found: ';
				for (Lead l : duplicateLeads) {
					errorMsg += l.Id + ' ';
				}
				inAppRecord.statusCode = DUPLICATE_RECORD_STATUS_CODE;
				throw new CustomException(errorMsg);
			}			
		}		
		return lead;
	}
	
	public static void associateCampaign(Lead lead, Contact contact) {
		System.debug('Associating campaign to lead/contact...');
		
		if ((lead != null || contact != null) && ASSOCIATE_CAMPAIGN_ID != null && !ASSOCIATE_CAMPAIGN_ID.equals('') && CAMPAIGN_STATUS != null && !CAMPAIGN_STATUS.equals('')) {
			CampaignMember c = new CampaignMember();
			c.CampaignId = ASSOCIATE_CAMPAIGN_ID;
			c.Status = CAMPAIGN_STATUS;
			if (lead == null) {
				c.ContactId = contact.Id;
			} else {
				c.LeadId = lead.Id;
			}
			try {
				insert c;
				System.debug('Campaign is now associated.');
			} catch (Exception e) {
				System.debug('Error associating to campaign: '+ e.getStackTraceString() + ': ' + e.getMessage() + '\nMoving on...');
			}
		}
	}
	
	public static Contact duplicateContactCheck(InApp inAppRecord) {
		System.debug('Checking the system for contacts with the same email...');
		Contact contact;
		if (inAppRecord != null && inAppRecord.email != null && !inAppRecord.email.equals('')) {
			List<Contact> duplicateContacts = [SELECT Id, Account.Id, Account.Name, Account.Total_Account_Value__c, Email FROM Contact WHERE Name = :inAppRecord.Email OR Email = :inAppRecord.email];
			if (duplicateContacts == null || duplicateContacts.size() == 0) {
				System.debug('No duplicate contacts found. Moving on...');
			} else if (duplicateContacts.size() == 1) {
				if (duplicateContacts[0].Account.Total_Account_Value__c == null || duplicateContacts[0].Account.Total_Account_Value__c == 0) {
					contact = duplicateContacts[0];
					System.debug('One contact found: ' + contact.Id + '. Using this contact moving forward...');
				} else {
					throw new CustomException('Error: duplicate contact found on Account with TAV > 0. ID: ' + duplicateContacts[0].Id);
				}
			} else {					
				String errorMsg = 'Error: Multiple duplicate contacts found: ';
				for (Contact c : duplicateContacts) {
					errorMsg += c.Id + ' ';
				}
				inAppRecord.statusCode = DUPLICATE_RECORD_STATUS_CODE;
				throw new CustomException(errorMsg);
			}			
		}		
		return contact;
	}
	
	public static Opportunity createOpportunityFromContact(InApp inAppRecord, Contact contact) {
		System.debug('Creating opportunity from contact...');
		
		// Step 0: Associate contact to campaign
		associateCampaign(null, contact); 
		
		// Step 1: Create opp
		Opportunity opp = new Opportunity();
		opp.Name = contact.Account.Name;
		opp.AccountId = contact.Account.Id;
		opp.CloseDate = Date.today();
		opp.StageName = CONVERTED_CONTACT_OPP_STAGE;
		insert opp;
		System.debug('Opportunity created. Creating opportunity contact role...');
		
		// Step 2: Associate contact
		if (contact != null) {
			OpportunityContactRole ocr = new OpportunityContactRole();
			ocr.ContactId = contact.Id;
			ocr.IsPrimary = true;
			ocr.OpportunityId = opp.Id; 
			insert ocr;
			System.debug('Opportunity contact role inserted.');
		}
		
		// Step 3: Query opp fields
		opp = queryOpportunityFields(opp.Id);
		
		// Step 4: Set opportunity return variables
		setOpportunityReturnVariables(opp, inAppRecord);
		return opp;
	}
	
	/**
	 * Step 1: Create lead
	 * Step 2: Convert lead
	 * Step 3: Query opp fields
	 * Step 4: Set opp return variables
	 */
	public static Opportunity createConvertedLeadOpportunity(InApp inAppRecord, Lead lead) {		
		System.debug('Beginning the create converted lead opportunity process...');
		
		// Step 1: Create lead			
		if (lead == null) {
			lead = createLead(inAppRecord);
		} else {
			lead = confirmLeadFields(lead, inAppRecord);
		}
		
		// Step 1.5: Associate lead to campaign
		associateCampaign(lead, null);
		
		// Step 2: Convert lead
		Id oppId = convertLead(lead);

		// Step 3: Query opp fields
		Opportunity opp = queryOpportunityFields(oppId);
		
		// Step 4: Set opportunity return variables
		setOpportunityReturnVariables(opp, inAppRecord);

		return opp;
	}
	
	public static Lead createLead(InApp inAppRecord) {
		System.debug('Creating new lead...');
		Lead l;		
		if (inAppRecord.enterpriseId != null && !inAppRecord.enterpriseId.equals('') && inAppRecord.email != null && !inAppRecord.email.equals('')) {
			l = new Lead();			
			l = confirmLeadFields(l, inAppRecord);
		}
		return l;
	}
	
	public static Lead confirmLeadFields(Lead l, InApp inAppRecord) {
		System.debug('Confirming lead fields...');
		if (l != null && inAppRecord.enterpriseId != null && !inAppRecord.enterpriseId.equals('') && inAppRecord.email != null && !inAppRecord.email.equals('')) {
			l.LastName                   = inAppRecord.email;			
			l.Company                    = inAppRecord.email;
			l.Box_Enterprise_ID__c       = inAppRecord.enterpriseId;
			// l.Contact_Method_Original__c = CONTACT_METHOD_MOST_RECENT;
			l.Contact_Method__c          = CONTACT_METHOD_MOST_RECENT;
			l.Industry                   = 'Other';
			l.Do_Not_Assign__c           = true;
			if (Test.isRunningTest())
				l.Country = 'United States';
			if (l.Id != null) {
				update l;
			} else {
				insert l;
			}
			System.debug('Lead name: ' + l.LastName + ', Company: ' + l.Company + ', Enterprise ID: ' + l.Box_Enterprise_ID__c);
		}
		return l;
	}
	
	public static Id convertLead(Lead l) {
		System.debug('Converting lead...');
		Id oppId;
		
		if (l != null) {			
			Database.LeadConvert lc = new Database.LeadConvert();									
			lc.setLeadId(l.Id);
			lc.setConvertedStatus(DEFAULT_LEAD_CONVERTED_STATUS);
			lc.setOwnerId(DEFAULT_OBJECTS_OWNER_ID);
			
			// See if there is an exact account match
			Account a;
			a = findMatchingAccount(l);												
			if (a != null) {
				lc.setAccountId(a.Id);
			} 
			
			Database.LeadConvertResult lcr = Database.convertLead(lc);			
			if (lcr.isSuccess()) {
				oppId = lcr.getOpportunityId();
				System.debug('Successful lead conversion!');
				System.debug('Setting primary contact role...');
				OpportunityContactRole ocr = [SELECT Id FROM OpportunityContactRole WHERE OpportunityId = : oppId];
				ocr.IsPrimary = true;
				update ocr;
				System.debug('Primary contact role set!');
			}
		}
		
		return oppId;
	}
	
	public static Account findMatchingAccount(Lead l) {
		System.debug('Checking if account already exists...');
		Account a;
		if (l != null) {
			List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name = :l.Company];
			if (accounts != null && accounts.size() == 1) {
				a = accounts[0];
				System.debug('Found matching account: ' + a.Name);
			} else {
				System.debug('No matches found. Pewp!');
			}
		}
		return a;
	}
	
	public static Opportunity queryOpportunityFields(Id oppId) {
		System.debug('Querying opportunity fields...');
		Opportunity opp;
		if (oppId != null) {
			opp = [SELECT Id, Name, StageName, Rep_Quota_Relief__c, Account.Id, Account.Name, Account.OwnerId, Account.Owner.Name FROM Opportunity WHERE Id = :oppId];
			System.debug('Found opportunity: ' + opp.Name);
		}
		return opp;
	}
	
	public static void setOpportunityReturnVariables(Opportunity opp, InApp inAppRecord) {
		System.debug('Setting opportunity return variables...');
		
		if (opp != null) {
			inAppRecord.opportunityId = opp.Id;
			if (opp.Account.Id != null) {
				inAppRecord.accountId = opp.Account.Id;
			}
			if (opp.Account.Name != null) {
				inAppRecord.accountName = opp.Account.Name;
			}
			if (opp.Account.Owner.Id != null) {
				inAppRecord.accountOwnerId = opp.Account.Owner.Id;
			}
			if (opp.Account.Owner.Name != null) {
				inAppRecord.accountOwnerName = opp.Account.Owner.Name;
			}
			System.debug('The following return variables were set: \n'
							+ 'Opp id: ' + inAppRecord.opportunityId + '\n'
							+ 'Account id: ' + inAppRecord.accountId + '\n'
							+ 'Account name: ' + inAppRecord.accountName + '\n'
							+ 'Account owner id: ' + inAppRecord.accountOwnerId + '\n'
							+ 'Account owner name: ' + inAppRecord.accountOwnerName + '\n');							
		}
	}
	
	public static void confirmOpportunityData(Opportunity opp, InApp inAppRecord) {
		System.debug('Attempting data validation for opportunity: ' + inAppRecord.opportunityId);
				
		confirmEnterpriseId(opp, inAppRecord);
		confirmSeatsSold(opp, inAppRecord);
		confirmGbSold(opp, inAppRecord);
		opp.Contact_Method_Most_Recent__c = CONTACT_METHOD_MOST_RECENT;					
		confirmPriorAccountType(opp, inAppRecord);				
		confirmArr(opp, inAppRecord);	
		confirmPaymentMethod(opp, inAppRecord);									 
		confirmFeeFrequency(opp, inAppRecord);
		confirmRepQuotaRelief(opp, inAppRecord);	
		opp.Account_Type_Sold__c = OPP_ACCOUNT_TYPE_SOLD;				

		System.debug('Data confirmed for opportunity: ' + inAppRecord.opportunityId + '.\n'
					+ 'Seats_Sold__c: ' + opp.Seats_Sold__c + '\n'
					+ 'GB_Sold__c: ' + opp.GB_Sold__c + '\n'
					+ 'Contact_Method_Most_Recent__c: ' + opp.Contact_Method_Most_Recent__c + '\n'
					+ 'Prior_Account_Type_Category__c: ' + opp.Prior_Account_Type_Category__c + '\n'
					+ 'Amount: ' + opp.Amount + '\n'
					+ 'Quota_Relief__c: ' + opp.Quota_Relief__c + '\n'
					+ 'Payment_Method__c: ' + opp.Payment_Method__c + '\n'
					+ 'Fee_Frequency__c: ' + opp.Fee_Frequency__c + '\n'
					+ 'Rep_Quota_Relief__c: ' + opp.Rep_Quota_Relief__c);
	}
	
	public static void confirmEnterpriseId(Opportunity opp, InApp inAppRecord) {
		System.debug('Confirming enterprise id...');
		if (inAppRecord.enterpriseId != null && !inAppRecord.enterpriseId.equals('')) {
			opp.Box_Enterprise_ID__c = inAppRecord.enterpriseId;
			System.debug('Enterprise id: ' + inAppRecord.enterpriseId);
		}
	}
	
	public static void confirmSeatsSold(Opportunity opp, InApp inAppRecord) {
		System.debug('Confirming seats sold...');
		if (inAppRecord.seatsSold != null && !inAppRecord.seatsSold.equals('')) {
			opp.Seats_Sold__c = Integer.valueOf(inAppRecord.seatsSold);
			System.debug('Seats sold: ' + opp.Seats_Sold__c);
		}		
	}
	
	public static void confirmGbSold(Opportunity opp, InApp inAppRecord) {
		System.debug('Confirming GB sold...');
		if (inAppRecord.gbSold != null && !inAppRecord.gbSold.equals('')) {
			opp.GB_Sold__c    = Integer.valueOf(inAppRecord.gbSold);
			System.debug('GB sold: ' + opp.GB_Sold__c);
		}
	}
	
	public static void confirmPriorAccountType(Opportunity opp, InApp inAppRecord) {
		System.debug('Confirming prior account type...');
		
		if (inAppRecord.priorAccountTypeCategory != null && !inAppRecord.priorAccountTypeCategory.equals('')) {
			opp.Upsold_from_Account_Type__c = inAppRecord.priorAccountTypeCategory; 
		}
		
		/*
		List<String> priorAccountTypeSubList = new List<String>();
		Map<String, String> priorAccountTypeMap = new Map<String, String>();
		List<String> priorAccountTypeList = PRIOR_ACCOUNT_TYPE_MAPPING.split(';');
		for (String s : priorAccountTypeList) {
			priorAccountTypeSubList = null;
			priorAccountTypeSubList = s.split(',');
			priorAccountTypeMap.put(priorAccountTypeSubList[0], priorAccountTypeSubList[1]);
		}
		if (inAppRecord.priorAccountTypeCategory != null && !inAppRecord.priorAccountTypeCategory.equals('')) {
			opp.Upsold_from_Account_Type__c      = priorAccountTypeMap.get(inAppRecord.priorAccountTypeCategory);
			inAppRecord.priorAccountTypeCategory = priorAccountTypeMap.get(inAppRecord.priorAccountTypeCategory);
			System.debug('Prior account type: ' + opp.Upsold_from_Account_Type__c);
		}
		*/	
	}
	
	public static void confirmArr(Opportunity opp, InApp inAppRecord) {  
		System.debug('Confirming arr...');
		if (inAppRecord.arr != null && !inAppRecord.arr.equals('')) {
			opp.Amount          = Double.valueOf(inAppRecord.arr);
			opp.Quota_Relief__c = Double.valueOf(inAppRecord.arr); 
			System.debug('Amount, Quota relief: ' + opp.Amount);
		} 
	}
	
	public static void confirmPaymentMethod(Opportunity opp, InApp inAppRecord) {
		System.debug('Confirming payment method...');
		if (inAppRecord.paymentMethodType != null && !inAppRecord.paymentMethodType.equals('')) {
			opp.Payment_Method__c = inAppRecord.paymentMethodType;
			System.debug('Payment method: ' + opp.Payment_Method__c);
		}
	}
	
	public static void confirmFeeFrequency(Opportunity opp, InApp inAppRecord) {
		System.debug('Confirming fee frequency...');
		List<String> feeFrequencySubList    = new List<String>();															
		Map<String, String> feeFrequencyMap = new Map<String, String>();
		List<String> feeFrequencyList       = FEE_FREQUENCY_MAPPING.split(';');
		for (String s : feeFrequencyList) {
			feeFrequencySubList = null;
			feeFrequencySubList = s.split(',');
			feeFrequencyMap.put(feeFrequencySubList[0], feeFrequencySubList[1]);
		}										
		if (inAppRecord.feeFrequency != null && !inAppRecord.feeFrequency.equals('')) {
			opp.Fee_Frequency__c     = feeFrequencyMap.get(inAppRecord.feeFrequency);
			inAppRecord.feeFrequency = feeFrequencyMap.get(inAppRecord.feeFrequency);
			System.debug('Fee frequency: ' + opp.Fee_Frequency__c);
		}	
	}
	
	public static void confirmRepQuotaRelief(Opportunity opp, InApp inAppRecord) {
		System.debug('Confirming rep quote relief...');
		if (opp.Rep_Quota_Relief__c == null || opp.Rep_Quota_Relief__c == false) {
			opp.Rep_Quota_Relief__c = false;
			System.debug('Rep quota relief: ' + opp.Rep_Quota_Relief__c);
		}
	}
	
	public static void determineInAppStatusCode(Opportunity opp, InApp inAppRecord) {
		System.debug('Time to determine the in app status code...');
		
		Boolean validClosedWonOpp = isOppClosedWonValid(opp, inAppRecord);		
		setInAppStatusCode(opp, inAppRecord, validClosedWonOpp);				
	}
	
	public static Boolean isOppClosedWonValid(Opportunity opp, InApp inAppRecord) {		
		System.debug('Setting closed won validity booleans...');
		Boolean isValid = false;
		
		Boolean validSubscriptionStatus = false;
		Boolean validPaymentType        = false;
		Boolean validTransactionStatus  = false;
		Boolean validPaymentDate        = false;
		Boolean validPaymentStatus      = false;				
		if (inAppRecord.subscriptionStatus != null && inAppRecord.subscriptionStatus.equals(CLOSED_WON_SUBSCRIPTION_STATUS)) {
			validSubscriptionStatus = true;
			System.debug('Valid subscription status!');
		}				
		if (inAppRecord.paymentMethodType != null && inAppRecord.paymentMethodType.equals(CLOSED_WON_PAYMENT_METHOD_TYPE)) {
			validPaymentType = true;
			System.debug('Valid payment type!');
		}
		if (inAppRecord.lastTransactionStatus != null && inAppRecord.lastTransactionStatus.equals(CLOSED_WON_LAST_TRANSACTION_STATUS)) {
			validTransactionStatus = true;
			System.debug('Valid transaction status!');
		}
		if (inAppRecord.lastPaymentDate != null && inAppRecord.eventDate != null) {			
			// if (DateTime.parse(inAppRecord.lastPaymentDate) > DateTime.parse(inAppRecord.eventDate).addSeconds(Integer.valueOf(LAST_PAYMENT_EVENT_DATE_DELTA))) {
			if (DateTime.parse(inAppRecord.lastPaymentDate).date() >= DateTime.parse(inAppRecord.eventDate).date()) {
				validPaymentDate = true;
				System.debug('Valid payment date!');
			}
		} 
		if (inAppRecord.lastPaymentStatus != null) {
			Set<String>  lastPaymentStatusesSet  = new Set<String>();
			List<String> lastPaymentStatusesList = CLOSED_WON_LAST_PAYMENT_STATUSES.split(';');
			lastPaymentStatusesSet.addAll(lastPaymentStatusesList);
			if (lastPaymentStatusesSet.contains(inAppRecord.lastPaymentStatus)) {
				validPaymentStatus = true;
				System.debug('Valid payment status!');	
			}					
		}		
		
		if (validSubscriptionStatus && validPaymentType && validTransactionStatus && validPaymentDate && validPaymentStatus) {
			isValid = true;
			System.debug('This opportunity is 100% closed won valid!');
		}
		
		return isValid;
	}
	
	public static void setInAppStatusCode(Opportunity opp, InApp inAppRecord, Boolean validClosedWonOpp) {
		System.debug('Setting the status code for the in app record...');
		
		// Setting up the set of stages that are already Closed Won											
		List<String> excludedOppStagesList = EXCLUDED_OPP_STAGES_LIST.split(';');
		Set<String>  excludedOppStagesSet  = new Set<String>();
		excludedOppStagesSet.addAll(excludedOppStagesList);

		// Determine Status Codes			
		// No need to change opps that are already closed won	
		// Opp will changed to "Closed Won" if it has all of the following properties:
		//   - Active Zuora Subscription
		//   - Active Box Account
		//   - Valid Payment Method
		//   - Payment Successfully processed after upgrade								
		if (excludedOppStagesSet.contains(opp.StageName)) {
			inAppRecord.statusCode = CLOSED_WON_ALREADY_STATUS_CODE;			
		} else if (validClosedWonOpp != null && validClosedWonOpp) {
			inAppRecord.statusCode = CLOSED_WON_STATUS_CODE;
		} else {
			inAppRecord.statusCode = INVALID_ZUORA_STATUS_CODE;
		}
		System.debug('Status code: ' + inAppRecord.statusCode);
	}
	
	public static void updateOpportunityAndCreateTenant(Opportunity opp, InApp inAppRecord) {
		System.debug('Updating opportunity if it should be closed won...');
		
		// Step 1: Update Opportunities that should be Closed Won			
		if (inAppRecord.statusCode != null && inAppRecord.statusCode.equals(CLOSED_WON_STATUS_CODE)) {
			opp.RecordTypeId = CLOSED_WON_OPP_RECORD_TYPE_ID;
			opp.StageName = CLOSED_WON_PICKLIST_VALUE;
			determineOpportunityCloseDate(opp, inAppRecord);			
			
			System.debug('New opportunity name: ' + opp.Name + '\n'
							+ 'Stage: ' + opp.StageName + '\n'
							+ 'Close date: ' + Date.today() + '\n'
							+ 'Record type id: ' + opp.RecordTypeId);	
			
			// Step 2: Add opportunity line items				
			// addOpportunityLineItems(opp, inAppRecord);
			
			// Step 3: Create a tenant object				
			// createTenant(opp, inAppRecord);				

		}	
	}
	
	public static void addOpportunityLineItems(Opportunity opp, InApp inAppRecord) {
		System.debug('Adding opportunity line items...');
		if (opp != null && inAppRecord != null ) {
			OpportunityLineItem oli = new OpportunityLineItem();
			oli.OpportunityId = opp.Id;
			oli.PricebookEntryId = BUSINESS_PBE_ID;
			if (inAppRecord.seatsSold != null && !inAppRecord.seatsSold.equals('') && inAppRecord.arr != null && !inAppRecord.arr.equals('')) {
				oli.Quantity = Integer.valueOf(inAppRecord.seatsSold);
				oli.TotalPrice = Double.valueOf(inAppRecord.arr);
			}
			insert oli;
			System.debug('Opportunity line item created: ' + oli.id + '\n'
							+ 'Opportunity id: ' + oli.OpportunityId + '\n'
							+ 'Price book entry id: ' + oli.PricebookEntryId + '\n'
							+ 'Quantity: ' + oli.Quantity + '\n'
							+ 'Unit price: ' + oli.UnitPrice);
			
			addOpportunityLineItemSchedules(oli, opp, inAppRecord);
		}
	}
	
	public static void addOpportunityLineItemSchedules(OpportunityLineItem oli, Opportunity opp, InApp inAppRecord) {
		System.debug('Adding opportunity line item schedules...');
		if (oli != null && opp != null && inAppRecord != null && inAppRecord.arr != null && !inAppRecord.arr.equals('')) {
			Double revenue = (Double.valueOf(inAppRecord.arr) / 12);
			Double totalRevenue = 0;
			if (opp.CloseDate != null) {
				List<OpportunityLineItemSchedule> olisches = new List<OpportunityLineItemSchedule>();
				for (Integer i = 0; i < 12; i++) {
					OpportunityLineItemSchedule olisch = new OpportunityLineItemSchedule();
					olisch.OpportunityLineItemId = oli.Id;
					olisch.Type = 'Revenue';
					olisch.ScheduleDate = opp.CloseDate.addMonths(i);
					olisch.Revenue = revenue;
					totalRevenue += revenue;
					olisches.add(olisch);					
				}
				
				// Double check total values
				if (totalRevenue != Double.valueOf(inAppRecord.arr)) {
					throw new CustomException('Error inserting opportunity line item schedules: Sum of opportunity line item schedule revenues do not equal ARR.');
				} else {
					System.debug('Opportunity line item schedules correctly sum to ' + inAppRecord.arr);
				}				
				
				// Insert into DB
				if (olisches != null && olisches.size() > 0) {
					insert olisches;
					System.debug(olisches.size() + ' opportunity line item schedules have been added.\n'
									+ 'Opportunity line item id: ' + oli.Id + '\n'
									+ 'Quantity: ' + inAppRecord.seatsSold + '\n'
									+ 'Initial schedule date: ' + opp.CloseDate + '\n'
									+ 'Revenue: ' + revenue);
				}
			}
		}			
	}
	
	public static void createTenant(Opportunity opp, InApp inAppRecord) {
		System.debug('Creating tenant...');
		if (opp != null && inAppRecord != null && inAppRecord.accountId != null && !inAppRecord.accountId.equals('')) {						
			Tenant__c t = new Tenant__c();
			t.Name = inAppRecord.enterpriseId;
			t.Account__c = inAppRecord.accountId;
			t.Admin_Email__c = inAppRecord.email;
			if (inAppRecord.seatsSold != null && !inAppRecord.seatsSold.equals('') ) {
				t.Seats_Allocated__c = Integer.valueOf(inAppRecord.seatsSold);
			}
			if (!inAppRecord.readOnly) {
				insert t;			
				System.debug('Tenant created: ' + t.Id + '\n'
							+ 'Account id: ' + inAppRecord.accountId + '\n'
							+ 'Admin email: ' + inAppRecord.email + '\n'
							+ 'Seats allocated: ' + inAppRecord.seatsSold);
			}
		}
	}
	
	public static void determineOpportunityCloseDate(Opportunity opp, InApp inAppRecord) {
		System.debug('Determining the close date for the opp...');
		
		if (opp != null && inAppRecord != null) {
			Date contractEffectiveDate = cleanDate(inAppRecord.contractEffectiveDate);
			Date trialEndDate = cleanDate(inAppRecord.trialEndDate);
			
			Date eventDate;			
			if (inAppRecord.eventDate != null && !inAppRecord.eventDate.equals('')) {
				eventDate = DateTime.parse(inAppRecord.eventDate).date();
			} 

			// Now begin date comparisons
			if (contractEffectiveDate == null && trialEndDate == null) {
				if (eventDate != null) {
					opp.CloseDate = eventDate; 
				} else {
					throw new CustomException('Error: Contract effective date, trial end date, and event date are all null.');
				}
			} else if (trialEndDate == null && contractEffectiveDate != null) {
				if (contractEffectiveDate < Date.today()) {
					if (eventDate != null) {
						opp.CloseDate = eventDate;
					} else {
						opp.CloseDate = contractEffectiveDate;
					}
				} else {
					opp.CloseDate = contractEffectiveDate;
				}
			} else if (contractEffectiveDate == null && trialEndDate != null) {
				if (trialEndDate < Date.today() && eventDate != null) {
					opp.CloseDate = eventDate;
				} else {		
					throw new CustomException('Error: Contract effective date is null.');
				}	
			} else {
				if (contractEffectiveDate.isSameDay(trialEndDate)) {
					opp.CloseDate = contractEffectiveDate;
				} else if (contractEffectiveDate < Date.today() && trialEndDate < Date.today()) {					
					opp.CloseDate = contractEffectiveDate;
				} else {
					throw new CustomException('Error: Contract effective date and trial end date do not match.'); 
				}
			}	
			System.debug('Opportunity close date: ' + opp.CloseDate);
		}			
	} 
	
	public static Date cleanDate(String d) {
		Date cleanDate;
		Date nullDate = DateTime.newInstance(0).date();
		if (d != null && !d.equals('')) {
			cleanDate = Date.parse(d);
			if (cleanDate.isSameDay(nullDate)) {
				cleanDate = null;
			}
		}
		return cleanDate;
	}	
	
	global class InApp {
		// Main inputs
		public String enterpriseId;
		public String email;
		
		// Debug variables
		public Boolean readOnly;
		
		// Data confimation variables
		public String seatsSold;                /* Integer */
		public String gbSold;                   /* Integer */
		public String priorAccountTypeCategory;
		public String arr;                      /* Double */
		public String paymentMethodType; 
		public String feeFrequency;
		
		// Closed Won variables
		public String subscriptionStatus;
		public String lastTransactionStatus;
		public String lastPaymentDate;          /* DateTime */
		public String eventDate;                /* DateTime */
		public String lastPaymentStatus;
		
		// Close date variables 		
		public String contractEffectiveDate;
		public String trialEndDate;				
		
		// Return variables
		public String statusCode;		
		public String errorMsg;
		public String opportunityId;
		public String accountId;
		public String accountName;
		public String accountOwnerId;
		public String accountOwnerName;
	}

}