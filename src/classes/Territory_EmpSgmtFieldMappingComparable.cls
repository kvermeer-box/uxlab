public class Territory_EmpSgmtFieldMappingComparable implements Comparable {
	
	public Territory_Employee_Segment_Field_Mapping__c mapping;
	
	public Territory_EmpSgmtFieldMappingComparable(Territory_Employee_Segment_Field_Mapping__c mapping) {
		this.mapping = mapping;
	}

	public Integer compareTo(Object compareTo) {
		Territory_EmpSgmtFieldMappingComparable compareToMapping = (Territory_EmpSgmtFieldMappingComparable)compareTo;
		
		// 0 is equal, 1 is greater, -1 is less than
		Integer returnValue = 0;
		
		// Nonnumbers are always bigger than numbers
		if (!mapping.Max_Employee_Segment__c.isNumeric() && compareToMapping.mapping.Max_Employee_Segment__c.isNumeric()) {
			returnValue = 1; 
		} else if (mapping.Max_Employee_Segment__c.isNumeric() && !compareToMapping.mapping.Max_Employee_Segment__c.isNumeric()) {
			returnValue = -1;
		// Number comparison
		} else if (mapping.Max_Employee_Segment__c.isNumeric() && compareToMapping.mapping.Max_Employee_Segment__c.isNumeric()) {
			Integer mappingValue = Integer.valueOf(mapping.Max_Employee_Segment__c);
			Integer compareValue = Integer.valueOf(compareToMapping.mapping.Max_Employee_Segment__c);
			if (mappingValue > compareValue) {
				returnValue = 1;
			} else if (mappingValue < compareValue) {
				returnValue = -1;
			}
		// The rest will be evaluated by normal string comparison
		} else if (mapping.Max_Employee_Segment__c > compareToMapping.mapping.Max_Employee_Segment__c) {
			returnValue = 1;
		} else if (mapping.Max_Employee_Segment__c < compareToMapping.mapping.Max_Employee_Segment__c) {
			returnValue = -1;
		}
		
		return returnValue;
	}

}