trigger triggerApprovalProcess on Quote (after update) { 
	
	// Prevent repeat executions
	static Integer iteration = 0;
	
	// Constants
	final String CONFIDENCE_LEVEL_STRONG  = 'Strong';
	final String DRAFT_STATUS_IN_PROGRESS = 'In Review';
	
	iteration++;
	if (iteration != 1) {
		return;
	} else {		
		System.debug('Evaluating which quotes to submit for approval...');		
		
		// Multiple quotes to submit in a single execution is technically impossible.
		List<Quote> quotesToSubmit = new List<Quote>();
		
		// Iteratate across quotes
		for (Quote q : Trigger.new) {			
			
			// SOPs approval
			String oldConfidence = Trigger.oldMap.get(q.Id).Confidence_Level__c;
			String newConfidence = Trigger.newMap.get(q.Id).Confidence_Level__c;
			String draftStatus   = Trigger.newMap.get(q.Id).Status;
			if (DRAFT_STATUS_IN_PROGRESS.equals(draftStatus) && !CONFIDENCE_LEVEL_STRONG.equals(oldConfidence) && CONFIDENCE_LEVEL_STRONG.equals(newConfidence)) {				
				quotesToSubmit.add(q);
				System.debug(q.Id + ' will be submitted for approval...');
				continue;
			}
			
			// Insert other approval process here
		}		
		
		// Submission process
		if (quotesToSubmit != null && quotesToSubmit.size() > 0) {			
			System.debug('More than one quote needs to be submitted for approval. Beginning submission process...');
			List<Approval.ProcessSubmitRequest> reqs = new List<Approval.ProcessSubmitRequest>();
			for (Quote q : quotesToSubmit) {
				Approval.ProcessSubmitRequest r = new Approval.ProcessSubmitRequest();
				r.setObjectId(q.Id);
				reqs.add(r);
			}
			// Submit. One failure will not ruin the entire batch
			List<Approval.ProcessResult> results = Approval.process(reqs, false);
		}
	}

}