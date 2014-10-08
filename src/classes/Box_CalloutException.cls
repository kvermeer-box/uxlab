global class Box_CalloutException extends Exception {
	
	private HttpResponse response;
	private Box_HttpResponseError error;
	
	public Box_CalloutException(HttpResponse response) {	
		this.response = response;
		this.error = (Box_HttpResponseError)JSON.deserialize(response.getBody(), Box_HttpResponseError.class);
		this.setMessage(error.message);
	}
	
	public HttpResponse getHttpResponse() {
		return response; 
	}
	
	public Box_HttpResponseError getHttpResponseError() {
		return error;
	}

}