public class Territory_S1RulesComparable implements Comparable {
 
	public Territory_Stage_1_Assignment_Rule__c rule;
	
	public Territory_S1RulesComparable(Territory_Stage_1_Assignment_Rule__c rule) {
		this.rule = rule;
	}

	public Integer compareTo(Object compareTo) {
		Territory_S1RulesComparable compareToRule = (Territory_S1RulesComparable)compareTo;
		
		// 0 is equal, 1 is greater, -1 is less than
		Integer returnValue = 0;
		
		// Take care of nulls, just in case
		if (rule.Entry_Value__c == null && compareToRule.rule.Entry_Value__c == null) {
			returnValue = 0;
		} else if (rule.Entry_Value__c != null && compareToRule.rule.Entry_Value__c == null) {
			returnValue = 1;
		} else if (rule.Entry_Value__c == null && compareToRule.rule.Entry_Value__c != null) {
			returnValue = -1; 
		// Both values are non-null
		} else {			
			// Nonnumbers are always bigger than numbers
			if (!rule.Entry_Value__c.isNumeric() && compareToRule.rule.Entry_Value__c.isNumeric()) {
				returnValue = 1; 
			} else if (rule.Entry_Value__c.isNumeric() && !compareToRule.rule.Entry_Value__c.isNumeric()) {
				returnValue = -1;
			// Number comparison
			} else if (rule.Entry_Value__c.isNumeric() && compareToRule.rule.Entry_Value__c.isNumeric()) {
				Integer ruleValue = Integer.valueOf(rule.Entry_Value__c);
				Integer compareValue = Integer.valueOf(compareToRule.rule.Entry_Value__c);
				if (ruleValue > compareValue) {
					returnValue = 1;
				} else if (ruleValue < compareValue) {
					returnValue = -1;
				}
			// The rest will be evaluated by normal string comparison
			} else if (rule.Entry_Value__c > compareToRule.rule.Entry_Value__c) {
				returnValue = 1;
			} else if (rule.Entry_Value__c < compareToRule.rule.Entry_Value__c) {
				returnValue = -1;
			}
		}
		return returnValue;
	}

}