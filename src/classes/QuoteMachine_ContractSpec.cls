global class QuoteMachine_ContractSpec {
	
	// Important fields
	public LicenseTier licenseTier;
	public PaymentFrequency paymentFrequency;
	public Date startDate;
	public Date endDate;	
	
	// Data fields
	public String confidenceLevel;
	public String dataSources;
	
	public final String WEAK = 'Weak';
	public final String MEDIUM = 'Medium';
	public final String STRONG = 'Strong';
	
	public QuoteMachine_ContractSpec() {
		setConfidenceLevelStrong();
	}
	
	public void setConfidenceLevelWeak() {
		System.debug('Setting confidence level to WEAK');
		this.confidenceLevel = WEAK;	
	}
	
	public void setConfidenceLevelMedium() {
		System.debug('Setting confidence level to MEDIUM');
		this.confidenceLevel = MEDIUM;	
	}
	
	public void setConfidenceLevelStrong() {
		System.debug('Setting confidence level to STRONG');
		this.confidenceLevel = STRONG;	
	}
		
	public boolean equals(QuoteMachine_ContractSpec spec) {
		System.debug('Checking to see if contract spec was modified...');
		
		boolean isDifferent = true;
		if (spec == null) {
			isDifferent = false;
		} else {
			if (this.licenseTier != spec.licenseTier) {
				isDifferent = false;
			} 
			if (this.paymentFrequency != spec.paymentFrequency) {
				isDifferent = false;
			}
			if (this.startDate != spec.startDate) {
				isDifferent = false;
			}
			if (this.endDate != spec.endDate) {
				isDifferent = false;
			}
		}
		
		System.debug('Contract spec was modified? ' + isDifferent);
		return isDifferent;		
	}
	
	public void checkEqualityAndStampDataSource(QuoteMachine_ContractSpec spec, sObject obj) {
		System.debug('Checking equality and stamping a data source if needed...');
		
		// Check for changes
		if (obj != null) {
			if (!this.equals(spec)) {
				// Update data source
				String dataSource = String.valueOf(obj.get('Name')) + '<name>' + obj.Id + '<id>';
				if (this.dataSources == null) {
					this.dataSources = dataSource;
				} else {
					this.dataSources += dataSource;
				}
				System.debug('Added data source: ' + dataSource);
			}
		}
	}
	
	public boolean notFullyPopulated() {
		boolean notFullyPopulated = false;
		if (licenseTier == null || paymentFrequency == null || startDate == null || endDate == null) {
			System.debug('There are unpopulated fields on this contract spec!');
			notFullyPopulated = true;
		}
		return notFullyPopulated;
	}	
}