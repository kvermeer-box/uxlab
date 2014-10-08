global class QuoteMachine_UpsellIntegrator {

	Quote quote {get; set;}	
	
	public QuoteMachine_UpsellIntegrator(Quote quote) { 
		this.quote = quote;
	}
	
	public Quote integrateQuoteData(String accountId) {
		System.debug('Beginning the contract spec integration process...');
		
		// First get a contractSpec
		QuoteMachine_ContractSpec contractSpec;		
		contractSpec = getFinalContractSpec(accountId);
		
		// Now update the quote
		quote = updateQuoteFields(contractSpec);
		
		return quote;
	}
	
	private QuoteMachine_ContractSpec getFinalContractSpec(String accountId) {
		System.debug('Getting contractSpec data from all sources...');
		
		QuoteMachine_ContractSpec contractSpec = new QuoteMachine_ContractSpec();
						
		// Order is important. Priority level: contract > zuora > opp
		QuoteMachine_ContractDataGrabber contractData = new QuoteMachine_ContractDataGrabber(contractSpec);
		contractSpec = contractData.setContractSpecData(accountId);
		
		QuoteMachine_ZuoraDataGrabber zuoraData = new QuoteMachine_ZuoraDataGrabber(contractSpec);
		contractSpec = zuoraData.setContractSpecData(accountId);
		
		QuoteMachine_OpportunityDataGrabber oppData = new QuoteMachine_OpportunityDataGrabber(contractSpec);
		contractSpec = oppData.setContractSpecData(accountId);
		
		// Check for null (invalid) contracts
		setContractValidity(contractSpec);
		
		return contractSpec;
	}	
	
	private void setContractValidity(QuoteMachine_ContractSpec contractSpec) {
    	System.debug('Determining the validity of this subscription...');
    	
    	if (contractSpec != null && contractSpec.equals(new QuoteMachine_ContractSpec())) {
    		contractSpec.setConfidenceLevelWeak();
    	} else if (contractSpec.notFullyPopulated()) {
    		contractSpec.setConfidenceLevelWeak();
    	}
    }
	
	private Quote updateQuoteFields(QuoteMachine_ContractSpec contractSpec) {
		System.debug('Updating quote fields with contractSpec data...');
		
		if (contractSpec != null) {
			if (contractSpec.licenseTier != null) {
				quote.Original_Product_Tier__c = mapLicenseTierToQuoteProductTier(contractSpec.licenseTier);
			}
			if (contractSpec.paymentFrequency != null) {
				quote.Original_Payment_Frequency__c = mapPaymentFrequencyToQuotePaymentFrequency(contractSpec.paymentFrequency);
			}
			if (contractSpec.startDate != null) {
				quote.Original_Contract_Start_Date__c = contractSpec.startDate;
			}
			if (contractSpec.endDate != null) {
				quote.Original_Contract_Renewal_Date__c = contractSpec.endDate;
			}
			if (contractSpec.confidenceLevel != null) {
				quote.Confidence_Level__c = contractSpec.confidenceLevel;
			}
			if (contractSpec.dataSources != null) {
				quote.Original_Data_Sources__c = contractSpec.dataSources;
			}
		}		
		
		String debug;
		debug  = 'New quote field values:\n';
		debug += 'Original product tier: ' + quote.Original_Product_Tier__c + '\n';
		debug += 'Original payment frequency: ' + quote.Original_Payment_Frequency__c + '\n';
		debug += 'Original start date: ' + quote.Original_Contract_Start_Date__c + '\n';
		debug += 'Original end date: ' + quote.Original_Contract_Renewal_Date__c + '\n';
		debug += 'Confidence level: ' + quote.Confidence_Level__c + '\n';
		debug += 'Data sources: ' + quote.Original_Data_Sources__c + '\n';
		System.debug(debug);
		
		// update quote;
		return quote;
	}
	
	private String mapLicenseTierToQuoteProductTier(LicenseTier lt) {
		System.debug('Mapping contractSpec LicenseTier to quote product tier...');
				
		String productTier;		
		if (lt != null) {
			if (lt == LicenseTier.BUSINESS) {
				productTier = 'Business';				
			} else if (lt == LicenseTier.ENTERPRISE) {
				productTier = 'Enterprise';
			} else if (lt == LicenseTier.ENTERPRISE_UNLIMITED) {
				productTier = 'Enterprise Unlimited';
			}
		}
		
		if (productTier != null && !productTier.equals('')) {
			System.debug('New product tier: ' + productTier);
		}
		
		return productTier;
	}	

	private String mapPaymentFrequencyToQuotePaymentFrequency(PaymentFrequency paymentFreq) {
		System.debug('Mapping contractSpec PaymentFrequency to quote payment frequency...');
		
		String pf;
		if (paymentFreq != null) {
			if (paymentFreq == PaymentFrequency.MONTHLY) {
				pf = 'Monthly';
			} else if (paymentFreq == PaymentFrequency.ANNUAL) {
				pf = 'Annual';
			} else if (paymentFreq == PaymentFrequency.QUARTERLY) {
				pf = 'Quarterly';
			} else if (paymentFreq == PaymentFrequency.SEMI_ANNUAL) {
				pf = 'Bi-Annual';
			} else if (paymentFreq == PaymentFrequency.TWO_YEAR_DEAL) {				
				pf = '2-Years';
			} else if (paymentFreq == PaymentFrequency.THREE_YEAR_DEAL) {
				pf = '3-Years';
			}
		}
		
		if (pf != null && !pf.equals('')) {
			System.debug('New payment frequency: ' + pf);
		}
		
		return pf;
	}

}