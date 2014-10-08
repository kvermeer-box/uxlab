public class Territory_MaxLeadSummaryComparable implements Comparable {

	public Territory_MaxLeadSummary summary;
	
	public Territory_MaxLeadSummaryComparable(Territory_MaxLeadSummary summary) {
		this.summary = summary;
	}

	public Integer compareTo(Object compareTo) {
		Territory_MaxLeadSummaryComparable comparable = (Territory_MaxLeadSummaryComparable)compareTo;
		
		Integer returnValue = 0;
		
		// Most recent dates go to index 0
		if (summary.createdDateGmt > comparable.summary.createdDateGmt) {
			returnValue = -1;
		} else if (summary.createdDateGmt > comparable.summary.createdDateGmt) {
			returnValue = 1;
		// Equality is the interesting one. Sort order wins if it is nonnull or greater. We create a sort order when batches of routed leads are inserted with the same createdate
		} else {
			if (summary.sortOrder != null && comparable.summary.sortOrder == null) {
				returnValue = -1;
			} else if (summary.sortOrder == null && comparable.summary.sortOrder != null) {
				returnValue = 1;
			} else if (summary.sortOrder > comparable.summary.sortOrder) {
				returnValue = -1;
			} else if (summary.sortOrder < comparable.summary.sortOrder) {
				returnValue = 1;
			}
		}
		return returnValue;
	}

}