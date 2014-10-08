global class Box_CustomSettings {

	private static final PRM_Settings__c settings = PRM_Settings__c.getInstance('default');	
	
	// Record types
	private static String DEFAULT_OPPORTUNITY_PARTNER_RECORD_TYPE_ID;
	private static String DEFAULT_ACCOUNT_RECORD_TYPE_ID = '012600000009TjX';
	private static String DEFAULT_ACCOUNT_PARTNER_RESELLER_RECORD_TYPE_ID = '012600000009X6b';
	
	// Trial lengths
	private static Integer DEFAULT_TRIAL_LENGTH;
	private static Integer DEFAULT_EXTENDED_LENGTH;
	
	public static Integer getDefaultTrialLength() {
		if (DEFAULT_TRIAL_LENGTH == null) {
			if (settings == null || settings.Default_Trial_Length__c == null) {
				DEFAULT_TRIAL_LENGTH = 14;
			} else {
				DEFAULT_TRIAL_LENGTH = Integer.valueOf(settings.Default_Trial_Length__c);
			}
		}
		return DEFAULT_TRIAL_LENGTH;
	}
	
	public static Integer getDefaultExtendedTrialLength() {
		if (DEFAULT_EXTENDED_LENGTH == null) {
			if (settings == null || settings.Default_Extended_Trial_Length__c == null) {
				DEFAULT_EXTENDED_LENGTH = 30;
			} else {
				DEFAULT_EXTENDED_LENGTH = Integer.valueOf(settings.Default_Extended_Trial_Length__c);
			}
		}
		return DEFAULT_EXTENDED_LENGTH;
	}

	public static String getOpportunityPartnerRecordTypeId() {
		if (DEFAULT_OPPORTUNITY_PARTNER_RECORD_TYPE_ID == null) {
			if (settings == null || settings.Opportunity_Deal_Reg_Record_Type_ID__c == null) {
				DEFAULT_OPPORTUNITY_PARTNER_RECORD_TYPE_ID = '012600000009X6c';
			} else {
				DEFAULT_OPPORTUNITY_PARTNER_RECORD_TYPE_ID = settings.Opportunity_Deal_Reg_Record_Type_ID__c;
			}
		}
		return DEFAULT_OPPORTUNITY_PARTNER_RECORD_TYPE_ID;
	}
	
	public static String getAccountRecordTypeId() {
		return DEFAULT_ACCOUNT_RECORD_TYPE_ID;
	}
	
	public static String getPartnerResellerRecordTypeId() {
		return DEFAULT_ACCOUNT_PARTNER_RESELLER_RECORD_TYPE_ID;
	}

}