public class Territory_MaxLeadSummary {

	public Id userId;
	public DateTime createdDateGmt;
	public Integer sortOrder;
	
	public Territory_MaxLeadSummary(Id userId, DateTime createdDate, Integer sortOrder) {
		this.userId = userId;
		this.createdDateGmt = convertToGmt(createdDate);
		this.sortOrder = sortOrder;
	}
	
	public DateTime convertToGmt(DateTime createdDate) {
		return DateTime.valueOf(createdDate.getTime());
	}

	public override String toString() {		
		String value = 'Max Routed Lead Summary\n';
		value += 'User ID: ' + userId + '\n';
		value += 'CreatedDateGmt: ' + createdDateGmt + '\n';
		value += 'Sort Order: ' + sortOrder + '\n';
		value += '------------------------------\n';
		return value;
	}

}