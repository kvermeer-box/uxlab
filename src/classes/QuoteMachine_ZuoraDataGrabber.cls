global class QuoteMachine_ZuoraDataGrabber {

	QuoteMachine_ContractSpec contractSpec;
	QuoteMachine_ContractSpec originalContractSpec;
	
	private final String INVALID_INITIAL_TERM = '50 Months';
	
	public QuoteMachine_ZuoraDataGrabber(QuoteMachine_ContractSpec contractSpec) {
		this.contractSpec = contractSpec;
		this.originalContractSpec = (contractSpec == null) ? new QuoteMachine_ContractSpec() : contractSpec.clone();
	}
    
    public QuoteMachine_ContractSpec setContractSpecData(String accountId) {
		System.debug('Updating the contract spec with Zuora data...');

		// Make a new contractSpec if necessary
		if (contractSpec == null) {
			contractSpec = new QuoteMachine_ContractSpec();
		}

		// First find the subscription
    	Zuora__Subscription__c subscription;
    	subscription = getSubscription(accountId);
    	
    	// Now get the subscription product charge
    	Zuora__SubscriptionProductCharge__c subscriptionProductCharge;
    	subscriptionProductCharge = getSubscriptionProductCharge(subscription);
    	
    	// Now we can start setting the contractSpec fields
    	setContractSpecLicenseTier(subscriptionProductCharge);
    	setContractSpecPaymentFrequency(subscriptionProductCharge);
    	setContractSpecDates(subscription, subscriptionProductCharge);
    	
    	// Check validity
    	setContractValidity(subscription);
    	
    	// Stamp a data source if necessary
    	contractspec.checkEqualityAndStampDataSource(originalContractspec, subscription); 
    	
    	return contractSpec;
    }
    
    private Zuora__Subscription__c getSubscription(String accountId) {
    	System.debug('Attempting to find the subscription for account ' + accountId + '...');
    	
    	Zuora__Subscription__c subscription;
    	if (accountId != null && !accountId.equals('')) { 
    		List<Zuora__Subscription__c> subscriptions = [SELECT Id, Name, Zuora__ContractEffectiveDate__c, Zuora__InitialTerm__c, Zuora__Account__r.Name, Zuora__NextRenewalDate__c,
	                                                            (Select Id, Zuora__RatePlanName__c, Zuora__ProductSKU__c, Zuora__BillingPeriod__c, Zuora__ExtendedAmount__c, 
	                                                            	Zuora__Price__c, Zuora__Quantity__c, Zuora__ProductName__c From Zuora__Subscription_Product_Charges__r)
	                                                        FROM Zuora__Subscription__c WHERE Zuora__Status__c = 'Active' AND Zuora__Account__c = :accountId];
	                                                        
			if (subscriptions != null && subscriptions.size() == 1) {
				subscription = subscriptions[0];
				System.debug('Active subscription found.');
			}	                                			                        
    	}
    	
    	return subscription;
    }    
    
    private void setContractValidity(Zuora__Subscription__c subscription) {
    	System.debug('Determining the validity of this subscription...');
    	
    	if (subscription != null) {
	    	// Check if it is an invalid initial term
	    	if (INVALID_INITIAL_TERM.equals(subscription.Zuora__InitialTerm__c)) {
	    		// Now check if we used any data from this invalid subscription
	    		if (!originalContractSpec.equals(contractSpec)) {
	    			contractSpec.setConfidenceLevelWeak();
	    		}
	    	}
    	}
    }
    
    private Zuora__SubscriptionProductCharge__c getSubscriptionProductCharge(Zuora__Subscription__c subscription) {
    	System.debug('Attempting to find the subscription product charge...');
    	
    	Zuora__SubscriptionProductCharge__c subscriptionProductCharge;
    	if (subscription != null && subscription.Zuora__Subscription_Product_Charges__r != null) {
    		for (Zuora__SubscriptionProductCharge__c spc : subscription.Zuora__Subscription_Product_Charges__r) {
    			if (spc.Zuora__ProductName__c != null) {    				    				
    				// Get the spc whose product has licenses
    				if (spc.Zuora__ProductName__c.toUppercase().contains('BUSINESS') || spc.Zuora__ProductName__c.toUppercase().contains('ENTERPRISE') || spc.Zuora__ProductName__c.toUppercase().contains('UNLIMITED')) {
    					subscriptionProductCharge = spc;
    					System.debug('Spc found.');
    					break;
    				}     				    				
    			}
    		}
    	}
    	return subscriptionProductCharge;
    }
    
    private void setContractSpecLicenseTier(Zuora__SubscriptionProductCharge__c spc) {
    	System.debug('Attempting to find the spc license tier...');
    	
    	// We don't want to override existing values, since they may be from better sources
    	if (contractSpec.licenseTier == null) {
	    	if (spc != null && spc.Zuora__ProductName__c != null && !spc.Zuora__ProductName__c.equals('')) {
	    		if (spc.Zuora__ProductName__c.toUppercase().contains('UNLIMITED')) {
	    			contractSpec.licenseTier = LicenseTier.ENTERPRISE_UNLIMITED;
	    			System.debug('License tier found: ' + LicenseTier.ENTERPRISE_UNLIMITED);
	    		} else if (spc.Zuora__ProductName__c.toUppercase().contains('ENTERPRISE')) {
	    			contractSpec.licenseTier = LicenseTier.ENTERPRISE;
	    			System.debug('License tier found: ' + LicenseTier.ENTERPRISE);
	    		} else if (spc.Zuora__ProductName__c.toUppercase().contains('BUSINESS')) {
	    			contractSpec.licenseTier = LicenseTier.BUSINESS;
	    			System.debug('License tier found: ' + LicenseTier.BUSINESS);
	    		}
	    	}
    	}
    }
    
    private void setContractSpecPaymentFrequency(Zuora__SubscriptionProductCharge__c spc) {
    	System.debug('Attempting to find the spc payment frequency...');
    	
    	if (contractSpec.paymentFrequency == null) {
    		if (spc != null && spc.Zuora__BillingPeriod__c != null && !spc.Zuora__BillingPeriod__c.equals('')) {
    			contractSpec.paymentFrequency = mapSpcPaymentFrequencyToQuotePaymentFrequency(spc.Zuora__BillingPeriod__c);
    			System.debug('Payment frequency: ' + contractSpec.paymentFrequency);
    		} 
    	}
    }
    
    private PaymentFrequency mapSpcPaymentFrequencyToQuotePaymentFrequency(String s) {
        System.debug('Mapping spc payment frequency...');
        if (s.equals('Annual')) {
            return PaymentFrequency.ANNUAL;
        } else if (s.equals('Month')) {
            return PaymentFrequency.MONTHLY;
        } else if (s.equals('Quarter')) {
            return PaymentFrequency.QUARTERLY;
        } else if (s.equals('Semi-Annual')) {
            return PaymentFrequency.SEMI_ANNUAL;
        } else if (s.equals('Two Years')) {
            return PaymentFrequency.TWO_YEAR_DEAL;
        } else if (s.equals('Three Years')) {
            return PaymentFrequency.THREE_YEAR_DEAL;
        } else {
            return null;
        }
    }    
    
    private void setContractSpecDates(Zuora__Subscription__c subscription, Zuora__SubscriptionProductCharge__c spc) {
    	System.debug('Attempting to find the contract spec dates...');    	
    	
    	if (contractSpec.startDate == null && contractSpec.endDate == null) {
    		Date startDate = getContractSpecStartDateFromSubscription(subscription);
    		Date endDate = getContractSpecEndDateFromSubscription(subscription, spc, startDate);
    		if (startDate != null && endDate != null) {
    			contractSpec.startDate = startDate;
    			contractSpec.endDate = endDate;
    			System.debug('Both contract spec dates set: ' + startDate + ' - ' + endDate);
    		}
    	}
    }
    
    private Date getContractSpecStartDateFromSubscription(Zuora__Subscription__c subscription) {
    	System.debug('Attempting to find the subscription start date...');
    	
    	Date startDate;
    	if (contractSpec.startDate == null) {
    		if (subscription != null && subscription.Zuora__ContractEffectiveDate__c != null) {
    			startDate = subscription.Zuora__ContractEffectiveDate__c;
    			System.debug('Start date: ' + contractSpec.startDate);
    		}
    	}
    	return startDate;
    }
    
    private Date getContractSpecEndDateFromSubscription(Zuora__Subscription__c subscription, Zuora__SubscriptionProductCharge__c spc, Date startDate) {
    	System.debug('Attempting to find the subscription end date...');
    	
    	Date endDate;
    	
    	if (contractSpec.endDate == null) {
    		// First choice is renewal date
    		if (subscription != null && subscription.Zuora__NextRenewalDate__c != null) {
    			endDate = subscription.Zuora__NextRenewalDate__c;
    		}
    	
    		// Let's try getting the date from subscriptions 
    		if (endDate == null && startDate != null) {
	    		if (subscription != null && subscription.Zuora__InitialTerm__c != null) {
	    			List<String> termList = subscription.Zuora__InitialTerm__c.split(' ');
	    			if (termList != null && !termList[0].equals('null') && (Integer.valueOf(termList[0]) <= 12 || Integer.valueOf(termList[0]) == 24 || Integer.valueOf(termList[0]) == 36)) {
			            endDate = QuoteMachine_DateUtils.calculateEndDateFromStartDateAndTerm(startDate, Integer.valueOf(termList[0]));		            
			        } 
	    		}
    		}
    		
    		// If no luck, try the spc (this may not be necessary...)
    		if (endDate == null && spc != null) {
    			if (spc.Zuora__BillingPeriod__c != null) {
	                if (spc.Zuora__BillingPeriod__c.equals('Two Years')) {
	                    endDate = QuoteMachine_DateUtils.calculateEndDateFromStartDateAndTerm(startDate, 24);
	                } else if (spc.Zuora__BillingPeriod__c.equals('Three Years')) {
	                    endDate = QuoteMachine_DateUtils.calculateEndDateFromStartDateAndTerm(startDate, 36);
	                } else {
	                    endDate = QuoteMachine_DateUtils.calculateEndDateFromStartDateAndTerm(startDate, 12);
	                }
	            // Default 12!!!    
	            } else {
	                endDate = QuoteMachine_DateUtils.calculateEndDateFromStartDateAndTerm(startDate, 12);
	            }         
    		}    		
    	}    	
    	
    	return endDate;
    }    	    
    
}