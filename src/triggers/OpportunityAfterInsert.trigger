trigger OpportunityAfterInsert on Opportunity (after insert) {
             
	QualificationNoteUtility.createNote(Trigger.new); 
 
}