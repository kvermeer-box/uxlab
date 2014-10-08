trigger Territory_TriggerLeadAssignment on Lead (after insert, after update) {

	private static Integer iteration = 0;
	
	// Emergency shutoff buttons are important
	if (!Territory_CustomSettings.getDeactivateStage1Rules()) {

		List<Lead> leads = Territory_S1LeadsDAO.getLeadsWithQueriedData(Trigger.new);
		
		// Prevent this trigger from firing multiple times in the same execution
		if (iteration == 0) {
			iteration++;
			
			// Only certain leads will be assigned 
			List<Lead> leadsToAssign = new List<Lead>();
			
			// Filter out leads that shouldn't be assigned 
			for (Lead lead : leads) {
				
				Boolean assignLead = false;
				
				// Inserted leads first
				if (Trigger.isInsert) {
					if (lead.Trigger_Assignment__c) {
						assignLead = true;
					}				
				// Updated leads now
				} else if (Trigger.isUpdate) {
					// Only add leads that just changed their assignment value to TRUE
					Boolean oldAssignmentValue = Trigger.oldMap.get(lead.Id).Trigger_Assignment__c;
					Boolean newAssignmentValue = Trigger.newMap.get(lead.Id).Trigger_Assignment__c;
					if (!oldAssignmentValue && newAssignmentValue) {
						assignLead = true;
					}				  
				}
				
				// Undo the assignment value so it can be assigned again
				if (assignLead) {
					Lead editableLead = lead.clone(true, true, false, true);
					leadsToAssign.add(editableLead);
				}		
			}
			
			// Assign this shit
			if (leadsToAssign != null && leadsToAssign.size() > 0) {
				Territory_S1AssignLeads leadAssigner = new Territory_S1AssignLeads(leadsToAssign);
				leadAssigner.massAssign();
			}
			
		}
		
	}
	
}