global class QuoteMachine_OpportunityDataGrabber {

	QuoteMachine_ContractSpec contractSpec;
	QuoteMachine_ContractSpec originalContractSpec;
	
	public QuoteMachine_OpportunityDataGrabber(QuoteMachine_ContractSpec contractSpec) {
		this.originalContractSpec = (contractSpec == null) ? new QuoteMachine_ContractSpec() : contractSpec.clone();
		this.contractSpec = contractSpec;
	}
    
    public QuoteMachine_ContractSpec setContractSpecData(String accountId) {
    	System.debug('Updating the contract spec with opportunity data...');
    	
    	// Make a new contractSpec if necessary
    	if (contractSpec == null) {
    		contractSpec = new QuoteMachine_ContractSpec();
    	}
    	
    	// First find the opportunity
    	Opportunity opp;
    	opp = getOriginalOpp(accountId);
    	
    	// Now we can start setting the contract spec fields
    	setContractSpecLicenseTier(opp);
    	setContractSpecPaymentFrequency(opp);
    	setContractSpecDates(opp);
    	
    	// Determine the validity of the contractSpec
    	setContractValidity();
    	
    	// Stamp a data source if necessary
    	contractspec.checkEqualityAndStampDataSource(originalContractspec, opp);    	
    	
    	return contractSpec;
    }
    
    private Opportunity getOriginalOpp(String accountId) {
        System.debug('Searching for the oldest Closed Won opp...');
        List<Opportunity> opps = [SELECT Id, Name, Account_Type_Sold__c, Fee_Frequency__c, CloseDate, Account.Name FROM Opportunity WHERE AccountId = :accountId AND StageName = 'Closed Won' ORDER BY CloseDate ASC];
        if (opps != null && opps.size() > 0) {
        	System.debug('Oldest closed won opp found: ' + opps[0].Name);
            return opps[0];
        } else {
            return null;
        }
    }   
    
    private void setContractValidity() {
    	System.debug('Determining the validity of this subscription...');
    	
    	if (!originalContractSpec.equals(contractSpec)) {
    		contractSpec.setConfidenceLevelWeak();
    	}
    }
    
    private void setContractSpecLicenseTier(Opportunity opp) {
    	System.debug('Attempting to find the license tier from opp...');
    	
    	if (contractSpec.licenseTier == null) {
    		if (opp != null && opp.Account_Type_Sold__c != null) {
    			if (opp.Account_Type_Sold__c.toUppercase().contains('BUSINESS')) {
                    contractSpec.licenseTier = LicenseTier.BUSINESS;
                    System.debug('License tier found: ' + LicenseTier.BUSINESS);
                }       
                if (opp.Account_Type_Sold__c.toUppercase().contains('ENTERPRISE')) {
                    contractSpec.licenseTier = LicenseTier.ENTERPRISE;
                    System.debug('License tier found: ' + LicenseTier.ENTERPRISE);
                }
                if (opp.Account_Type_Sold__c.toUppercase().contains('UNLIMITED')) {
                    contractSpec.licenseTier = LicenseTier.ENTERPRISE_UNLIMITED;
                    System.debug('License tier found: ' + LicenseTier.ENTERPRISE_UNLIMITED);
                }
    		}
    	}
    }

	private void setContractSpecPaymentFrequency(Opportunity opp) {
		System.debug('Attempting to find the payment frequency from opp...');
		
		if (contractSpec.paymentFrequency == null) {
			if (opp != null && opp.Fee_Frequency__c != null) {
				contractSpec.paymentFrequency = mapPaymentFrequencyFromOppFeeFrequency(opp.Fee_Frequency__c);
			}
		}
	}
	
	private PaymentFrequency mapPaymentFrequencyFromOppFeeFrequency(String s) {
        System.debug('Mapping opp payment frequency...');
        PaymentFrequency pf;
        if (s != null) {
            if (s.equals('Monthly')) {
                pf = PaymentFrequency.MONTHLY;
            } else if (s.equals('Quarterly')) {
                pf = PaymentFrequency.QUARTERLY;
            } else if (s.equals('Semi-Annual')) {
                pf = PaymentFrequency.SEMI_ANNUAL;
            } else if (s.equals('Annual')) {
                pf = PaymentFrequency.ANNUAL;
            } else if (s.equals('Two Year Deal')) {
                pf = PaymentFrequency.TWO_YEAR_DEAL;
            } else if (s.equals('Three Year Deal')) {
                pf = PaymentFrequency.THREE_YEAR_DEAL;
            }
        }    
        return pf;
    }
    
    private void setContractSpecDates(Opportunity opp) {
    	System.debug('Attempting to find contract spec dates from opp...');
    	
    	if (contractSpec.startDate == null && contractSpec.endDate == null) {
    		Date startDate = getContractSpecStartDateFromOpp(opp);
    		Date endDate = getContractSpecEndDateFromOpp(opp, startDate);
    		if (startDate != null && endDate != null) {
    			contractSpec.startDate = startDate;
    			contractSpec.endDate = endDate;
    			System.debug('Both contract spec dates set: ' + startDate + ' - ' + endDate);	
    		}    		
    	}
    }       
	
	private Date getContractSpecStartDateFromOpp(Opportunity opp) {
		System.debug('Attempting to find contract spec start date from opp...');
		
		Date startDate;
		if (contractSpec.startDate == null) {
			if (opp != null && opp.CloseDate != null) {
				startDate = opp.CloseDate;
				System.debug('Start date: ' + startDate);
			}
		}
		return startDate;
	}
	
	private Date getContractSpecEndDateFromOpp(Opportunity opp, Date startDate) {
		System.debug('Attempting to find contract spec end date from opp...');
		
		Date endDate;
		if (contractSpec.endDate == null && startDate != null && opp != null) {
			if (opp != null && opp.Fee_Frequency__c != null) {
				if (opp.Fee_Frequency__c.equals('Two Year Deal')) {
	                endDate = QuoteMachine_DateUtils.calculateEndDateFromStartDateAndTerm(startDate, 24);
	            } else if (opp.Fee_Frequency__c.equals('Three Year Deal')) {
	                endDate = QuoteMachine_DateUtils.calculateEndDateFromStartDateAndTerm(startDate, 36);
	            } else {
	                endDate = QuoteMachine_DateUtils.calculateEndDateFromStartDateAndTerm(startDate, 12);
	            }
	        // Default!!!    
	        } else {
	            endDate = QuoteMachine_DateUtils.calculateEndDateFromStartDateAndTerm(startDate, 12);
	        }
		}
		return endDate;
	}

}