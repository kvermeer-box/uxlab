public class Territory_LeadAcctEmployeeSizeCalculator {

	public static Set<String> getSoqlFields() {
		System.debug(System.LoggingLevel.ERROR, 'Territory_LeadAcctEmployeeSizeCalculator: Getting soql fields...');
		Set<String> soqlFields = new Set<String>();
		soqlFields.add('Territory_Routing_Account__r.Id');
		soqlFields.add('Territory_Routing_Account__r.Normalized_Employees__c');
		return soqlFields;
	}

	public static Integer calculateLeadEmployeeSize(Lead lead) {
    	System.debug(System.LoggingLevel.ERROR, 'Territory_LeadAcctEmployeeSizeCalculator: Calculating employee size...');
    	Integer employeeSize;
    	if (lead.Territory_Routing_Account__r != null) {
    		if (lead.Territory_Routing_Account__r.Normalized_Employees__c != null) {
        		employeeSize = lead.Territory_Routing_Account__r.Normalized_Employees__c.intValue();
    		}
    	} 
        System.debug(System.LoggingLevel.ERROR, 'Territory_LeadAcctEmployeeSizeCalculator: Employee size: ' + employeeSize);
        return employeeSize;
    }

}