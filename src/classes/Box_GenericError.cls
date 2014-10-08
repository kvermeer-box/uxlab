public class Box_GenericError {
	
	String error;
		
	public Box_GenericError(String message) {
		this.error = message;
	}		
	
	public static Blob parseGenericException(Exception e) {
		Blob blobReturn;
		Box_GenericError g = new Box_GenericError(e.getMessage());
		blobReturn = Blob.valueOf(JSON.serialize(g));
		return blobReturn;
	}
	
}