public class Territory_S1InputValidator {

	public List<Territory_Stage_1_Assignment_Rule__c> rulesInContext;
	public Map<Id, Territory_Stage_1_Assignment_Rule__c> allAssignmentRulesMap;
	
	private List<String> assignmentFields;

	public Territory_S1InputValidator(List<Territory_Stage_1_Assignment_Rule__c> rulesInContext) {
		this.rulesInContext = rulesInContext;
		allAssignmentRulesMap = Territory_S1RulesDAO.getAllRulesMap();
	}
	
	public void validate() { 
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1InputValidator: Validating inputs for ' + rulesInContext.size() + ' rules...');		
		validateEntryMethods();
		validateAssignmentRecords();
		validateSingleEndpoints();
		validateQueueRecords();
	}
	
	private void validateEntryMethods() {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1InputValidator: Validating entry methods...');
		
		// Get tier one entry method
		String tierOneEntryMethod;
		Map<String, Territory_Stage_1_Assignment_Rule__c> allParentRules = Territory_S1RulesDAO.getAllParentRulesMapByKey();
		for (String key : allParentRules.keySet()) {
			String method = allParentRules.get(key).Entry_Method__c;
			if (!method.startsWith('<<')) {
				tierOneEntryMethod = method;
				break;	
			}			
		}
		
		// Validate entry method for all rules
		for (Territory_Stage_1_Assignment_Rule__c rule : rulesInContext) {
			validateEntryMethod(rule, tierOneEntryMethod);
		}
	}
	
	private void validateQueueRecords() {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1InputValidator: Validating queue records...');
		List<Territory_Stage_1_Assignment_Rule__c> rulesWithQueues = new List<Territory_Stage_1_Assignment_Rule__c>();
		for (Territory_Stage_1_Assignment_Rule__c rule : rulesInContext) {
			if (rule.Assigned_Queue__c != null) {
				rulesWithQueues.add(rule);
			}
		}
		if (rulesWithQueues != null && rulesWithQueues.size() > 0) {
			System.debug(System.LoggingLevel.ERROR, 'Territory_S1InputValidator: Some of these rules have queues...');
			// Get a map of all queues
			List<QueueSObject> allQueues = [SELECT Id, QueueId FROM QueueSObject];
			Map<String, QueueSObject> allQueuesMap = new Map<String, QueueSObject>();
			for (QueueSObject q : allQueues) {
				String fifteenDigitQueueId = String.valueOf(q.QueueId).mid(0, 15);
				allQueuesMap.put(fifteenDigitQueueId, q);
			}
			// Iterate across rules with queues and validate
			for (Territory_Stage_1_Assignment_Rule__c rule : rulesWithQueues) {
				String fifteenDigitQueueId = rule.Assigned_Queue__c.mid(0, 15);
				QueueSObject queue = allQueuesMap.get(fifteenDigitQueueId);
				if (queue == null) {					
					rule.Assigned_Queue__c.addError('This queue does not exist! 15 or 18 digit IDs are accepted. Current characters: ' + rule.Assigned_Queue__c.length());
					System.debug(System.LoggingLevel.ERROR, 'Error! Queue ' + rule.Assigned_Queue__c + ' does not exist. 15 or 18 digit IDs are OK.');
				}
			}
		}
	}
	
	private void validateEntryMethod(Territory_Stage_1_Assignment_Rule__c rule, String tierOneEntryMethod) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1InputValidator: Validating entry method for ' + rule.Id);
		
		// First get the parent		
		Territory_Stage_1_Assignment_Rule__c parent = allAssignmentRulesMap.get(rule.Parent_Assignment_Rule__c);
		if (parent != null) {
			if (parent.Child_Assignment_Rules__r != null && parent.Child_Assignment_Rules__r.size() > 0) {
				// A child assignment rule exists, make sure it has the same entry method
				Territory_Stage_1_Assignment_Rule__c firstChild = parent.Child_Assignment_Rules__r[0];
				if (firstChild.Entry_Method__c != rule.Entry_Method__c) {
					rule.Entry_Method__c.addError('Entry method must be equal to its siblings\' (' + firstChild.Entry_Method__c + ')');				
					System.debug(System.LoggingLevel.ERROR, 'Error! Entry method chosen: ' + rule.Entry_Method__c + ' , Entry method required: ' + firstChild.Entry_Method__c);
				}
			}
		} else {
			if (tierOneEntryMethod != null && !rule.Entry_Method__c.startsWith('<<') && !rule.Entry_Method__c.equals(tierOneEntryMethod)) {
				rule.Entry_Method__c.addError('Entry method must be equal to its siblings\' (' + tierOneEntryMethod + ')');				
					System.debug(System.LoggingLevel.ERROR, 'Error! Entry method chosen: ' + rule.Entry_Method__c + ' , Entry method required: ' + tierOneEntryMethod);
			}
		}
	}	
	
	private void validateAssignmentRecords() {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1InputValidator: Validating number of assignment records for each rule...');
		
		// Validate records individually
		for (Territory_Stage_1_Assignment_Rule__c rule : rulesInContext) {
			validateAssignmentRecord(rule);
		}
	}
	
	private void validateAssignmentRecord(Territory_Stage_1_Assignment_Rule__c rule) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1InputValidator: Validating assignment records for ' + rule.Id);
				
		// Count the number of populated assignment fields
		Integer populatedFieldCount = 0; 
		for (String f : getAssignmentFields()) {
			// Increment
			if (rule.get(f) != null) {
				populatedFieldCount++;
			}
			// 1 is the max number of populated fields
			if (populatedFieldCount > 1) {
				rule.addError('Only one assignment field may be populated.');
				System.debug(System.LoggingLevel.ERROR, 'Error: more than one assignment field is populated on record ' + rule.Id);
			}
		}		
	}
	
	private List<String> getAssignmentFields() {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1InputValidator: Getting assignment fields...');
		
		// Don't want to redo work
		if (assignmentFields != null) {
			return assignmentFields;
		} else {
			assignmentFields = new List<String>();
			// Get info on general s1 object
			Schema.DescribeSObjectResult s1RuleObject = Schema.getGlobalDescribe().get('Territory_Stage_1_Assignment_Rule__c').getDescribe();
		
			// Get all assignment fields on s1 object
			Map<String, Schema.SObjectField> s1RuleObjectFields = s1RuleObject.fields.getMap();
			for (String field : s1RuleObjectFields.keySet()) {
				String fieldApiName = s1RuleObjectFields.get(field).getDescribe().getName();
				if (fieldApiName.startsWith('Assigned')) {
					assignmentFields.add(fieldApiName);
				}
			}
		}
		
		System.debug(System.LoggingLevel.ERROR, 'Assignment fields that will be evaluated: ' + String.join(assignmentFields, ', '));
		return assignmentFields;
	}
	
	private void validateSingleEndpoints() {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1InputValidator: Validating single endpoints...');
		
		for (Territory_Stage_1_Assignment_Rule__c rule : rulesInContext) {
			validateSingleEndpoint(rule);
		}
	}
	
	private void validateSingleEndpoint(Territory_Stage_1_Assignment_Rule__c rule) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1InputValidator: Validating there is no more than one endpoint for record ' + rule.Id);
		
		// If there is a parent, the parent should not assign to any records 
		if (rule.Parent_Assignment_Rule__c != null) {
			if (Trigger.isInsert) {
				Territory_Stage_1_Assignment_Rule__c parent = allAssignmentRulesMap.get(rule.Parent_Assignment_Rule__c);
				for (String f : getAssignmentFields()) {
					// Make sure the parent doens't have any assignment fields populated
					if (parent.get(f) != null) {
						rule.addError('Children assignment rules cannot be added to a rule that has assignment values.');
						break;
					}
				}	
			}	
		}
		
		// If there are children, the rule should not assign to any records
		if (rule.Child_Rules__c != null && rule.Child_Rules__c > 0) {
			for (String f : getAssignmentFields()) {
				if (rule.get(f) != null) {					
					rule.addError('Assignment values cannot be added to a rule that has child assignment rules.');
					break;
				}
			}
		}
	}

}