global with sharing class Box_OpportunityFactory {

    private static String OPPORTUNITY_CLOSED_WON_STAGE = 'Closed Won';
    private static String OPPORTUNITY_CLOSED_LOST_STAGE = 'Closed Lost';
    private static String OPPORTUNITY_CHURN_STAGE = 'Cancellation - Churn';
    private static String OPPORTUNITY_CHURN_REASON_SUSPEND = 'Billing: Non-payment';    
    private static String OPPORTUNITY_DEAL_REG_APPROVAL_STATUS_APPROVED = 'Approved';

    public static Opportunity closeDealRegOpportunity(Opportunity opportunity, Box_SalesTransaction salesTransaction, Account partner, Tenant__c originalTenant, Tenant__c tenant) {
        System.debug('Box_OpportunityFactory: Closing opportunity from sales transaction...');
        
        if (opportunity == null) {               
            throw new CustomException('Error: Cannot edit opportunity when opportunity is null');
        } else if (salesTransaction == null) {
            throw new CustomException('Error: Cannot create adjustment opportunity when sales transaction is null');
        }       
        
        // Translate
        opportunity = translateSalesTransactionToOpportunity(opportunity, salesTransaction, partner, originalTenant, null, tenant);
        update opportunity;
                
        return opportunity;
    }

    public static Opportunity createChurnOpportunity(Box_SalesTransaction salesTransaction, Account partner, Tenant__c originalTenant, Tenant__c tenant) {
        System.debug('Box_OpportunityFactory: Creating churn opportunity from sales transaction...');

        // First get a contact
        Contact contact = Box_UserFactory.findOrCreateContactFromSalesTransaction(salesTransaction, true);
        
        // Create opportunity
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = contact.AccountId;
        opportunity.Account = contact.Account;
        opportunity = translateSalesTransactionToOpportunity(opportunity, salesTransaction, partner, originalTenant, contact, tenant);
        // opportunity.Deal_Reg_Approval_Status__c = 'Approved'; 
        
        // Set the partner submitter email
    	opportunity.Partner_Submitter_Email__c = getLastPartnerSubmitterEmail(opportunity, partner);
        
        insert opportunity;
        
        // Insert OpportunityContactRole
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.OpportunityId = opportunity.Id;
        ocr.ContactId = contact.Id;
        ocr.IsPrimary = true;
        insert ocr;
        
        return opportunity;
    }
    
    private static Opportunity translateSalesTransactionToOpportunity(Opportunity opportunity, Box_SalesTransaction salesTransaction, Account partner, Tenant__c originalTenant, Contact contact, Tenant__c tenant) {
        System.debug('Box_OpportunityFactory: Translating sales transaction to opportunity...');
        Box_Enterprise enterprise = salesTransaction.enterprise;
        
        // Standard fields
        if (opportunity.Name == null) { opportunity.Name = enterprise.administered_by.login; }
        opportunity.CloseDate = Date.Today();
        opportunity.RecordTypeId = Box_CustomSettings.getOpportunityPartnerRecordTypeId();
        
        // AccountId
        if (opportunity.AccountId == null) {
            opportunity.AccountId = tenant.Account__r.Id;
        }       
        
        // Box partner account
        if (partner != null) {
        	opportunity.Box_Partner_Account__c = partner.Id;
        } 
        
        // Debug mode
        if (salesTransaction.debug_mode != null && salesTransaction.debug_mode) {
            opportunity.ForecastCategoryName = 'Omitted';
        }
        
        // Seats, Amount, ARR, Stage
        opportunity = calculateRevenueFields(opportunity, salesTransaction, partner, originalTenant); 
        
        // Tenant
        if (tenant != null && tenant.Id != null) {
            opportunity.Tenant__c = tenant.Id;
        }

        // Enterprise ID
        if (enterprise.id != null) { opportunity.Box_Enterprise_ID__c = salesTransaction.enterprise.id; }
        
        // Account type sold
        opportunity.Account_Type_Sold__c = mapEnterpriseAccountTypeToOppAccountTypeSold(salesTransaction.enterprise.account_type);
        
        System.debug('Box_OpportunityFactory: Opportunity fully translated: ' + opportunity);
        return opportunity;
    }
    
    public static String mapEnterpriseAccountTypeToOppAccountTypeSold(String accountType) {
        String accountTypeSold;
        if (accountType != null) {
            if (accountType.toLowerCase().equals(Box_EnterpriseAccountTypeEnum.BUSINESS.name().toLowerCase())) {
                accountTypeSold = 'Business';
            } else if (accountType.toLowerCase().equals(Box_EnterpriseAccountTypeEnum.ENTERPRISE.name().toLowerCase())) {
                accountTypeSold = 'Enterprise';
            } else if (accountType.toLowerCase().equals(Box_EnterpriseAccountTypeEnum.ENTERPRISE_UNLIMITED.name().toLowerCase())) {
                accountTypeSold = 'Enterprise - Unlimited Ext Users';
            }
        }
        return accountTypeSold;
    }

    private static Opportunity calculateRevenueFields(Opportunity opportunity, Box_SalesTransaction salesTransaction, Account partner, Tenant__c originalTenant) {
        System.debug('Box_OpportunityFactory: Calculating opportunity revenue fields (seats, amount, arr, and stage)...');
        
        if (opportunity != null && salesTransaction != null && partner != null) {                               
            // Make sure we have the inputs we need
            if (salesTransaction.enterprise == null) {
                throw new CustomException('Error: Cannot calculate opportunity without an enterprise.');
            } else if (salesTransaction.enterprise.seats == null || salesTransaction.enterprise.seats.equals('')) {
                throw new CustomException('Error: Cannot calculate opportunity without an enterprise seat count.');
            } 
            
            System.debug('Box_OpportunityFactory: salesTransaction: ' + salesTransaction);
            System.debug('Box_OpportunityFactory: opportunity: ' + opportunity);
            System.debug('Box_OpportunityFactory: partner: ' + partner);
            System.debug('Box_OpportunityFactory: originalTenant: ' + originalTenant);
            
            // This is not an upsell              
            if (originalTenant == null) { 
                // These are easy 
                opportunity.Seats_Sold__c = calculateSeatDifferential(salesTransaction, originalTenant);
                opportunity.Amount = Integer.valueOf(salesTransaction.enterprise.seats) * Box_AccountDAO.getPartnerPricePerSeat(salesTransaction.enterprise.account_type, partner) * 12;
                opportunity.Commissionable_Amount__c = calculateCommissionableAmount(salesTransaction, originalTenant);
                opportunity.ARR__c = opportunity.Amount;
                
                // Now to do stage
                if (salesTransaction.state == null || salesTransaction.state == Box_TransactionState.initiate) {
                    opportunity.StageName = OPPORTUNITY_CLOSED_WON_STAGE;
                } else if (salesTransaction.state == Box_TransactionState.cancel || salesTransaction.state == Box_TransactionState.suspend) {
                    opportunity.StageName = OPPORTUNITY_CLOSED_LOST_STAGE;
                }
            // Incremental change / upsell
            } else {
                // Seats sold is the difference between new and old
                opportunity.Seats_Sold__c = calculateSeatDifferential(salesTransaction, originalTenant);
                 
                // Amount is the absolute value of the new TAV minus old TAV
                Double tavDelta = calculateTavDelta(opportunity.Account, salesTransaction, originalTenant, partner);
                opportunity.Amount = Math.abs(tavDelta);
                opportunity.Commissionable_Amount__c = calculateCommissionableAmount(salesTransaction, originalTenant);
                opportunity.ARR__c = opportunity.Amount; 
                
                // Calculate stage - positive Amount is closed won, negative is churn
                if (tavDelta > 0) {
                    opportunity.StageName = OPPORTUNITY_CLOSED_WON_STAGE;
                } else {
                    opportunity.StageName = OPPORTUNITY_CHURN_STAGE;
                }
            }
        }
        return opportunity;
    }
    
    private static Integer calculateSeatDifferential(Box_SalesTransaction salesTransaction, Tenant__c originalTenant) {
        System.debug('Box_OpportunityFactory: Calculating seats...');
        
        Integer seats = Integer.valueOf(salesTransaction.enterprise.seats);
        if (isActivating(salesTransaction, originalTenant)) {
        	// Activations are total number of seats
        	seats = Integer.valueOf(salesTransaction.enterprise.seats);
        } else if (isDeactivating(salesTransaction, originalTenant)) {
        	// Deactivations are the negative of the current amount of seats
        	seats = Integer.valueOf(originalTenant.Seats_Allocated__c) * (-1);
        } else {
        	// In all other cases, take the difference
        	seats = Integer.valueOf(salesTransaction.enterprise.seats) - Integer.valueOf(originalTenant.Seats_Allocated__c);
        }
        
        /*
        if (originalTenant != null && originalTenant.Deal_Status__c != null) {
            // Standard upsell
            if (originalTenant.Deal_Status__c.equals(Box_EnterpriseDealStatusEnum.LIVE_DEAL.name().toLowerCase())) {
                seats = Integer.valueOf(salesTransaction.enterprise.seats) - Integer.valueOf(originalTenant.Seats_Allocated__c);            
            // Going from trial to live
            } else {
                seats = Integer.valueOf(salesTransaction.enterprise.seats);
            }                        
        }
        */
        
        return seats;
    }
    
    private static boolean isActivating(Box_SalesTransaction salesTransaction, Tenant__c originalTenant) {
    	System.debug('Box_OpportunityFactory: Checking if this is an activation...');
    	boolean isActivating = false;
    	if (originalTenant == null) {
    		isActivating = true;
    	} else if (salesTransaction != null) {
    		// Original tenant is trial or deactivated
    		if ((originalTenant.Deal_Status__c != null && !originalTenant.Deal_Status__c.toLowerCase().equals(Box_EnterpriseDealStatusEnum.LIVE_DEAL.name().toLowerCase())) 
    			|| (originalTenant.Active_Status__c != null && originalTenant.Active_Status__c.toLowerCase().equals(Box_ActiveStatus.deactivated.name().toLowerCase()))) {
    			// Sales transaction is not a deactivation and is a live deal (not a trial)
    			if ((salesTransaction.state == null || salesTransaction.state == Box_TransactionState.initiate)
    				&& (salesTransaction.enterprise.deal_status == null || salesTransaction.enterprise.deal_status.toLowerCase().equals(Box_EnterpriseDealStatusEnum.LIVE_DEAL.name().toLowerCase()))) {
    				isActivating = true;
    			}
    		}
    	}
    	System.debug('Box_OpportunityFactory: Is Activating = ' + isActivating);
    	return isActivating;
    }
    
    private static boolean isDeactivating(Box_SalesTransaction salesTransaction, Tenant__c originalTenant) {
    	System.debug('Box_OpportunityFactory: Checking if this is a deactivation...');
    	boolean isDeactivating = false;
    	if (salesTransaction != null && originalTenant != null) {
    		// Original tenant is live (not a trial) and active
    		if (originalTenant.Deal_Status__c != null && originalTenant.Deal_Status__c.toLowerCase().equals(Box_EnterpriseDealStatusEnum.LIVE_DEAL.name().toLowerCase()) 
    			&& originalTenant.Active_Status__c != null && originalTenant.Active_Status__c.toLowerCase().equals(Box_ActiveStatus.active.name().toLowerCase())) {    			
    			// Sales transaction is a cancel or suspend
    			if (salesTransaction.state == Box_TransactionState.cancel || salesTransaction.state == Box_TransactionState.suspend) {
    				isDeactivating = true;
    			}	
			}
    	}
    	System.debug('Box_OpportunityFactory: Is Deactivating = ' + isDeactivating);
    	return isDeactivating;
    }    
    
    private static Double calculateCommissionableAmount(Box_SalesTransaction salesTransaction, Tenant__c originalTenant) {
    	System.debug('Box_OpportunityFactory: Calculating commissionable amount...');
    	
    	Double commissionableAmount;
    	if (isActivating(salesTransaction, originalTenant)) {
    		// For activations
    		commissionableAmount = Integer.valueOf(salesTransaction.enterprise.seats) * Box_PricebookEntryDAO.getUnitPrice(salesTransaction.enterprise.account_type) * 12;
    	} else if (isDeactivating(salesTransaction, originalTenant)) {
    		// For deactivations
    		commissionableAmount = Integer.valueOf(originalTenant.Seats_Allocated__c) * Box_PricebookEntryDAO.getUnitPrice(originalTenant.Account_Type__c) * 12;
    	} else {
    		// For incremental sales
    		Double currentListPrice = originalTenant.Seats_Allocated__c * Box_PricebookEntryDAO.getUnitPrice(originalTenant.Account_Type__c) * 12;
    		Double newListPrice = Integer.valueOf(salesTransaction.enterprise.seats) * Box_PricebookEntryDAO.getUnitPrice(salesTransaction.enterprise.account_type) * 12;
    		commissionableAmount = newListPrice - currentListPrice;
    	}
    	
    	System.debug('Box_OpportunityFactory: Commissionable amount: ' + commissionableAmount);
    	return Math.abs(commissionableAmount);
    }
    
    private static Integer getSeatCount(Tenant__c tenant, Box_SalesTransaction salesTransaction) {
    	System.debug('Box_OpportunityFactory: Calculating seat count...');
    	Integer seats;
        if (salesTransaction.enterprise.seats == null) {
            seats = Integer.valueOf(tenant.Seats_Allocated__c);
        } else {
            seats = Integer.valueOf(salesTransaction.enterprise.seats);
        }
        return seats;
    }
    
    private static String getAccountType(Tenant__c tenant, Box_SalesTransaction salesTransaction) {
    	System.debug('Box_OpportunityFactory: Calculating account type...');
        String accountType;
        if (salesTransaction.enterprise.account_type == null) {
            accountType = tenant.Account_Type__c;
        } else {
            accountType = salesTransaction.enterprise.account_type;
        }
        return accountType;
    }
    
    public static Double calculateTavDelta(Account account, Box_SalesTransaction salesTransaction, Tenant__c tenant, Account partner) {
        System.debug('Box_OpportunityFactory: Calculating TAV delta...');

        // Get seat count and accountType
        Integer seats = getSeatCount(tenant, salesTransaction);        
        String accountType = getAccountType(tenant, salesTransaction);
    
        // Calculate!
        Double tavDelta;
        if (salesTransaction.state != null && (salesTransaction.state == Box_TransactionState.cancel || salesTransaction.state == Box_TransactionState.suspend)) {
            // For churns, the delta is simply negative TAV. 
            tavDelta = Math.abs(account.Total_Account_Value__c) * (-1);
        } else {
            Double newTav = seats * Box_AccountDAO.getPartnerPricePerSeat(accountType, partner) * 12;
            tavDelta = newTav - account.Total_Account_Value__c;
        }

        System.debug('Box_OpportunityFactory: TAV delta is ' + tavDelta);       
        return tavDelta;
    }
    
    private static String getLastPartnerSubmitterEmail(Opportunity opportunity, Account partner) {
 		System.debug('Box_OpportunityFactory: Retrieving last partner submitter email...');
 		
 		String lastPartnerSubmitterEmail;
 		try {
 			Opportunity bestOpportunityWithPartnerSubmitterEmail = [SELECT Id, Partner_Submitter_Email__c
	 																	FROM Opportunity
	 																	WHERE Opportunity.Account.Id = :opportunity.AccountId
	 																		AND Opportunity.Box_Partner_Account__c = :partner.Id
	 																		AND Opportunity.Deal_Reg_Approval_Status__c = 'Approved'
	 																		AND Partner_Submitter_Email__c != null	 																			 																	
	 																		ORDER BY CreatedDate DESC LIMIT 1];
	 																		
 			lastPartnerSubmitterEmail = bestOpportunityWithPartnerSubmitterEmail.Partner_Submitter_Email__c;
 			System.debug('Box_OpportunityFactory: Last partner submitter email found: ' + lastPartnerSubmitterEmail);
 		} catch (Exception e) {
 			System.debug(e.getMessage());
 		}   	
 		
 		return lastPartnerSubmitterEmail;
    }
    
}