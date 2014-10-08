trigger Territory_Stage1AssignmentRuleTriggers on Territory_Stage_1_Assignment_Rule__c (before insert, before update, before delete, after insert, after delete, after update) {

	// Execute triggers
	if (Trigger.isBefore) {
		if (Trigger.isInsert) {
			 
			// Trigger 1: Input validator
			Territory_S1InputValidator validator = new Territory_S1InputValidator(Trigger.new);
			validator.validate();
			 
		} else if (Trigger.isUpdate) {
			
			// Trigger 1: Input validator
			Territory_S1InputValidator validator = new Territory_S1InputValidator(Trigger.new);
			validator.validate();
			
		} else if (Trigger.isDelete) {
			
		}		
	} else if (Trigger.isAfter) {
		if (Trigger.isInsert) {			
			
			// Trigger 1: Parent/child counter
			Territory_S1ChildCounter childCounter = new Territory_S1ChildCounter(Trigger.newMap, null);  
			childCounter.processChildCounts();
					
		} else if (Trigger.isUpdate) {
						
			// Trigger 1: Parent/child counter
			Territory_S1ChildCounter childCounter = new Territory_S1ChildCounter(Trigger.newMap, Trigger.oldMap);
			childCounter.processChildCounts();
						
		} else if (Trigger.isDelete) {			
			
			// Trigger 1: Parent/child counter
			Territory_S1ChildCounter childCounter = new Territory_S1ChildCounter(Trigger.oldMap, null);
			childCounter.processChildCounts();
						
		}
	}
	
}