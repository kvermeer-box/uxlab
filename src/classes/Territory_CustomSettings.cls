public class Territory_CustomSettings {

	private static final TerritorySettings__c settings = TerritorySettings__c.getInstance('default');
	
	// General - Stage 1
	private static final Boolean DEACTIVATE_STAGE_1_ASSIGNMENT;
	private static final Decimal LIMITS_MAX_ROUTED_LEADS_AUDIT_DAYS;	
	
	// Mailman
	private static final String  MAILMAN_ID;
	private static final String  LEAD_CONVERTED_STATUS;
	
	// Stage 1 rules
	private static Territory_Stage_1_Assignment_Rule__c S1_ROOT_BLACK_HOLE_RULE;
	private static Territory_Stage_2_Assignment_Rule__c S2_ROOT_BLACK_HOLE_RULE;
	
	// Stage 2 rules
	private static Territory_Stage_2_Assignment_Rule__c S2_BLACK_HOLE_RULE;
	private static Territory_Stage_2_Assignment_Rule__c S2_DUPLICATE_CONTACT_RULE; 
	private static Territory_Stage_2_Assignment_Rule__c S2_NO_REASSIGNMENT_ACCOUNT_RULE;
	private static Territory_Stage_2_Assignment_Rule__c S2_INACTIVE_USER_IN_TERRITORY_RULE;
	
	public static Boolean getDeactivateStage1Rules() {
		if (settings == null) {
			return false;
		} else {
			return settings.Turn_Off_Stage_1_Assignment__c;
		} 
	}
	
	public static Decimal getRoutedLeadHistoryDays() {
		if (settings == null || settings.Routed_Leads_History__c == null) {
			return 30;
		} else {
			return settings.Routed_Leads_History__c;
		}
	}
	
	public static String getLeadConvertedStatus() {
		if (settings == null || settings.Lead_Converted_Status__c == null) {
			return 'Qualified - New Opportunity';
		} else {
			return settings.Lead_Converted_Status__c;
		}
	}
	
	public static String getMailmanId() {
		if (settings == null || settings.Mailman_ID__c == null) {
			return null;
		} else {
			return settings.Mailman_ID__c;
		}
	}
	
	/**
     *  S1 Black Hole
	 */
	public static void setS1BlackHoleRule(Territory_Stage_1_Assignment_Rule__c rule) {
		S1_ROOT_BLACK_HOLE_RULE = rule;
	}
	
	public static Territory_Stage_1_Assignment_Rule__c getS1BlackHoleRule() {
		return S1_ROOT_BLACK_HOLE_RULE;
	}
	
	/**
     *  S2 Black Hole
	 */
	public static void setS2BlackHoleRule(Territory_Stage_2_Assignment_Rule__c rule) {
		S2_BLACK_HOLE_RULE = rule;
	}
	
	public static Territory_Stage_2_Assignment_Rule__c getS2BlackHoleRule() {
		return S2_BLACK_HOLE_RULE;
	}
	
	/**
     *  S2 Duplicate Contact
	 */
	public static void setS2DuplicateContactRule(Territory_Stage_2_Assignment_Rule__c rule) {
		S2_DUPLICATE_CONTACT_RULE = rule;
	}
	
	public static Territory_Stage_2_Assignment_Rule__c getS2DuplicateContactRule() {
		return S2_DUPLICATE_CONTACT_RULE;
	}	
	
	/**
     *  S2 No Reassignment
	 */
	public static void setS2NoReassignmentAccountRule(Territory_Stage_2_Assignment_Rule__c rule) {
		S2_NO_REASSIGNMENT_ACCOUNT_RULE = rule;
	}
	
	public static Territory_Stage_2_Assignment_Rule__c getS2NoReassignmentAccountRule() {
		return S2_NO_REASSIGNMENT_ACCOUNT_RULE;
	}
	
	/**
     *  S2 Inactive User in Territory
	 */
	public static void setS2InactiveUserInTerritoryRule(Territory_Stage_2_Assignment_Rule__c rule) {
		S2_INACTIVE_USER_IN_TERRITORY_RULE = rule;
	}
	
	public static Territory_Stage_2_Assignment_Rule__c getS2InactiveUserInTerritoryRule() {
		return S2_INACTIVE_USER_IN_TERRITORY_RULE;
	}

}