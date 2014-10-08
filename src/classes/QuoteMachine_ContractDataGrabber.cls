global class QuoteMachine_ContractDataGrabber {

	QuoteMachine_ContractSpec contractSpec;
	QuoteMachine_ContractSpec originalContractSpec;
	
	public QuoteMachine_ContractDataGrabber(QuoteMachine_ContractSpec contractSpec) {
		this.contractSpec = contractSpec;
		this.originalContractSpec = (contractSpec == null) ? new QuoteMachine_ContractSpec() : contractSpec.clone();
	}
	
	public QuoteMachine_ContractSpec setContractSpecData(String accountId) {
		System.debug('Updating the contract spec with purchase contract data...');

		// Make a new contractSpec if necessary
		if (contractSpec == null) {
			contractSpec = new QuoteMachine_ContractSpec();
		}

		// First find the contract
    	Purchase_Contract__c contract;
    	contract = getPurchaseContract(accountId);
    	
    	// Now we can start setting the contractSpec fields
    	setContractSpecLicenseTier(contract);
    	setContractSpecPaymentFrequency(contract);
    	setContractSpecDates(contract);
    	
    	// Stamp a data source if necessary
    	contractspec.checkEqualityAndStampDataSource(originalContractspec, contract); 
    	
    	return contractSpec;
    }
    
    private Purchase_Contract__c getPurchaseContract(String accountId) {
    	System.debug('Attempting to find the active purchase contract for account ' + accountId);
    	
    	Purchase_Contract__c contract;
    	List<Purchase_Contract__c> contracts = [SELECT Id, Name, Contract_Activation_Date__c, Contract_Expiration_Date__c, License_Type__c, Payment_Frequency__c 
    												FROM Purchase_Contract__c 
													WHERE Account__c = :accountId
														AND Status__c = 'Active'];
														
    	if (contracts != null && contracts.size() == 1) {
    		contract = contracts[0];
    		System.debug('Contract found: ' + contract.Id);	
    	}
    	return contract;
    }
    
    private void setContractSpecLicenseTier(Purchase_Contract__c contract) {
    	System.debug('Attempting to find contract license tier...');
    	
    	if (contractSpec.licenseTier == null) {
    		if (contract != null && contract.License_Type__c != null) {
    			contractSpec.licenseTier = mapcontractLicenseTypeToLicenseTier(contract);
    			System.debug('License tier: ' + contract.License_Type__c);
    		}
    	}
    }
    
    private LicenseTier mapcontractLicenseTypeToLicenseTier(Purchase_Contract__c contract) {
    	System.debug('Mapping contract license type to LicenseTier object...');
    	
    	LicenseTier lt;
    	if (contract != null && contract.License_Type__c != null) {
    		if (contract.License_Type__c.toUppercase().contains('UNLIMITED')) {
    			lt = LicenseTier.ENTERPRISE_UNLIMITED;
    		} else if (contract.License_Type__c.toUppercase().contains('ENTERPRISE')) {
    			lt = LicenseTier.ENTERPRISE;
    		} else if (contract.License_Type__c.toUppercase().contains('BUSINESS')) {
    			lt = LicenseTier.BUSINESS;
    		}
    	}
    	System.debug('License tier: ' + lt);
    	return lt;
    }
    
    private void setContractSpecPaymentFrequency(Purchase_Contract__c contract) {
    	System.debug('Attempting to find contract payment frequency...');
    	
    	if (contractSpec.paymentFrequency == null) {
    		if (contract != null && contract.Payment_Frequency__c != null) {
    			contractSpec.paymentFrequency = mapContractPaymentFrequencytoPaymentFrequency(contract);
    			System.debug('Payment frequency: ' + contract.Payment_Frequency__c);
    		}
    	}
    }
    
    private PaymentFrequency mapContractPaymentFrequencytoPaymentFrequency(Purchase_Contract__c contract) {
    	System.debug('Mapping contract payment frequency to PaymentFrequency object...');
    	
    	PaymentFrequency pf;
    	if (contract != null && contract.Payment_Frequency__c != null) {
    		if (contract.Payment_Frequency__c.toUppercase().equals('MONTHLY')) {
    			pf = PaymentFrequency.MONTHLY;
    		} else if (contract.Payment_Frequency__c.toUppercase().equals('ANNUAL')) {
    			pf = PaymentFrequency.ANNUAL;
    		} else if (contract.Payment_Frequency__c.toUppercase().equals('QUARTERLY')) {
    			pf = PaymentFrequency.QUARTERLY;
    		} else if (contract.Payment_Frequency__c.toUppercase().equals('BI-ANNUAL')) {
    			pf = PaymentFrequency.SEMI_ANNUAL;
    		} else if (contract.Payment_Frequency__c.toUppercase().equals('2-YEARS')) {
    			pf = PaymentFrequency.TWO_YEAR_DEAL;
    		} else if (contract.Payment_Frequency__c.toUppercase().equals('3-YEARS')) {
    			pf = PaymentFrequency.THREE_YEAR_DEAL;
    		}
    	}
    	System.debug('Payment frequency: ' + pf);
    	return pf;
    }

	private void setContractSpecDates(Purchase_Contract__c contract) {
		System.debug('Attempting to find contract dates...');
		
		if (contract != null && contractSpec.startDate == null && contractSpec.endDate == null) {
			if (contract.Contract_Activation_Date__c != null && contract.Contract_Expiration_Date__c != null) {
				contractSpec.startDate = contract.Contract_Activation_Date__c;
				contractSpec.endDate = contract.Contract_Expiration_Date__c;
				System.debug('Both contract dates set: ' + contractSpec.startDate + ' - ' + contractSpec.endDate);
			}
		}
	}

}