public class Territory_EntryValueField {
	
	public String fieldName;
	
	// Should the field be truncated?
	public Integer truncateSize; 
	
	public Territory_EntryValueField(String fieldName, Integer truncateSize) {
		this.fieldName = fieldName;
		if (truncateSize == null || truncateSize == 0) {
			this.truncateSize = 255;
		} else {
			this.truncateSize = truncateSize;
		}
	}
	 
}