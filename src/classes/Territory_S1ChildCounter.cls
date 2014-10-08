public class Territory_S1ChildCounter {

	// Context variables
	public Map<Id, Territory_Stage_1_Assignment_Rule__c> rulesInContext;
	public Map<Id, Territory_Stage_1_Assignment_Rule__c> oldRulesInContext; 
	
	// Evaluation variables 
	public Map<Id, Territory_Stage_1_Assignment_Rule__c> parentRulesToUpdateMap;	
	public Map<Id, Territory_Stage_1_Assignment_Rule__c> allAssignmentRulesMap; 
	
	public Territory_S1ChildCounter(Map<Id, Territory_Stage_1_Assignment_Rule__c> rulesInContext, Map<Id, Territory_Stage_1_Assignment_Rule__c> oldRulesInContext) {
		
		// We track old and new rules to identify if the count needs updating
		this.rulesInContext = rulesInContext;
		this.oldRulesInContext = oldRulesInContext;
		
		// These will help us later 
		this.parentRulesToUpdateMap = new Map<Id, Territory_Stage_1_Assignment_Rule__c>();
		this.allAssignmentRulesMap = Territory_S1RulesDAO.getRefreshedAllRulesMap();  
	}
	
	public void processChildCounts() {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1ChildCounter: Processing child counts for ' + rulesInContext.keySet().size() + ' s1 assignment rules...');
		
		// Process each record
		for (Id ruleId : rulesInContext.keySet()) {
			if (needsProcessing(ruleId)) {
				Territory_Stage_1_Assignment_Rule__c parent = getProcessedParentChildCount(rulesInContext.get(ruleId));
				if (parent != null && parent.Child_Rules__c != null) {
					parentRulesToUpdateMap.put(parent.Id, parent);
				}
			}
		}
		
		// Update Salesforce
		if (parentRulesToUpdateMap != null && parentRulesToUpdateMap.keySet().size() > 0) {
			System.debug(System.LoggingLevel.ERROR, 'Territory_S1ChildCounter: Total parents to update: ' + parentRulesToUpdateMap.keySet().size());
			List<Territory_Stage_1_Assignment_Rule__c> rulesToUpdate = new List<Territory_Stage_1_Assignment_Rule__c>();
			rulesToUpdate.addAll(parentRulesToUpdateMap.values());
			update rulesToUpdate;
			System.debug(System.LoggingLevel.ERROR, rulesToUpdate.size() + ' parent rules updated.');
		}
	}
	
	private boolean needsProcessing(Id ruleId) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1ChildCounter: Determining if ' + ruleId + ' should NOT be processed...');
				
		boolean needsProcessing = true;
		// Inserts and deletes will always be processed
		if (Trigger.isUpdate) {
			// Check if the record's child rules count has changed			
			Integer newChildCount = rulesInContext.get(ruleId).Child_Rules__c == null ? null : rulesInContext.get(ruleId).Child_Rules__c.intValue();
			Integer oldChildCount = oldRulesInContext.get(ruleId).Child_Rules__c == null ? null : oldRulesInContext.get(ruleId).Child_Rules__c.intValue();
			if (newChildCount == oldChildCount) {
				needsProcessing = false;
				System.debug(System.LoggingLevel.ERROR, 'Territory_S1ChildCounter: New child count: ' + newChildCount + '. Old child count: ' + oldChildCount + '. We will NOT process this record.');
			} 
		} 
		
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1ChildCounter: Process ' + ruleId + ': ' + needsProcessing);
		return needsProcessing;
	}
	
	private Territory_Stage_1_Assignment_Rule__c getProcessedParentChildCount(Territory_Stage_1_Assignment_Rule__c rule) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1ChildCounter: Processing child count for rule ' + rule.Id + '\'s parent.');
		
		// Get parent and its children
		Territory_Stage_1_Assignment_Rule__c parent;
		if (rule.Parent_Assignment_Rule__c != null) {
			parent = allAssignmentRulesMap.get(rule.Parent_Assignment_Rule__c);
			if (parent != null) {
				System.debug(System.LoggingLevel.ERROR, 'Parent: ' + parent.Id);
				if (parent.Child_Assignment_Rules__r != null && parent.Child_Assignment_Rules__r.size() > 0) {
					
					// Step 1: Calculate children directly underneath
					parent.Child_Rules__c = parent.Child_Assignment_Rules__r.size();
					
					// Step 2: Calculate grandchildren and stuffs
					for (Territory_Stage_1_Assignment_Rule__c child : parent.Child_Assignment_Rules__r) {
						if (child.Child_Rules__c != null) {
							parent.Child_Rules__c += child.Child_Rules__c;
						}
					}
					
					System.debug(System.LoggingLevel.ERROR, 'Territory_S1ChildCounter: Parent ' + parent.Id + ' has ' + parent.Child_Rules__c + ' children.');
				} else {
					parent.Child_Rules__c = 0;
					System.debug(System.LoggingLevel.ERROR, 'Territory_S1ChildCounter: Parent has no children  =(  QQ!');
				}
			}
		}
		return parent;
	}
 
}