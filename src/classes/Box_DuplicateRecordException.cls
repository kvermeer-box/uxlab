global class Box_DuplicateRecordException extends Exception {

	public List<SObject> duplicates;

	public Box_DuplicateRecordException(List<SObject> duplicates) {
		this.duplicates = duplicates;
	}
	
	public Box_DuplicateRecordException(List<SObject> duplicates, String message) {
		this(message);
		this.duplicates = duplicates;
	}

}