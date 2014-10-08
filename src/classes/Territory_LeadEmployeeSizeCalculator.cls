public class Territory_LeadEmployeeSizeCalculator {	
	
	public static Set<String> getSoqlFields() {
		System.debug(System.LoggingLevel.ERROR, 'Territory_LeadEmployeeSizeCalculator: Getting soql fields...');
		Set<String> soqlFields = new Set<String>();
		soqlFields.add('NumberOfEmployees');
		soqlFields.add('Employees__c');
		return soqlFields;
	}

	public static Integer calculateLeadEmployeeSize(Lead lead) {
    	System.debug(System.LoggingLevel.ERROR, 'Territory_LeadEmployeeSizeCalculator: Calculating employee size...');
        Integer employeeSize;
        // Determine which number of employees to use
        if (lead.NumberOfEmployees != null && lead.NumberOfEmployees > 0) {
            employeeSize = lead.NumberOfEmployees;
        } else if (lead.Employees__c != null && lead.Employees__c > 0) {
            employeeSize = lead.Employees__c.intValue();      
        }       
        System.debug(System.LoggingLevel.ERROR, 'Territory_LeadEmployeeSizeCalculator: Employee size: ' + employeeSize);
        return employeeSize;
    }

}