@isTest
global class Box_TestMockResponse implements HttpCalloutMock {
	
	public Box_Enterprise enterprise;
	
	public Box_TestMockResponse(String enterpriseJson) {
		this.enterprise = (Box_Enterprise)JSON.deserialize(enterpriseJson, Box_Enterprise.class);
	}

	global HTTPResponse respond(HTTPRequest req) {
		System.debug('Creating a mock response...');
		
		// Adjust the salesTransaction
		if (enterprise.id == null || enterprise.id.equals('')) { enterprise.id = String.valueOf((Math.random() * 1000000L).intValue()); }
		if (enterprise.administered_by.id == null || enterprise.administered_by.id.equals('')) { enterprise.administered_by.id = String.valueOf((Math.random() * 1000000L).intValue()); }
		
        // Create a fake response     
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(JSON.serialize(enterprise));
        res.setStatusCode(200);
        
        System.debug('Mock body: ' + JSON.serialize(enterprise));
        return res;
    }

}