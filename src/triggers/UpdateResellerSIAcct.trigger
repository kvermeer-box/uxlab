trigger UpdateResellerSIAcct on Opportunity (after insert, after update) {
	  if(trigger.isInsert){
	  	OpportunityClosedWonRSIUpdate.AfterInsertUpdateResellerSIAcct(Trigger.newMap);
		}
       if(trigger.isUpdate){
 		OpportunityClosedWonRSIUpdate.AfterUpdateUpdateResellerSIAcct(Trigger.newMap,Trigger.oldMap);
		}

}