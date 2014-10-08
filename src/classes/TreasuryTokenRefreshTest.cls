@isTest
global class TreasuryTokenRefreshTest implements HttpCalloutMock {
    // Implement this interface method
    
    
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('https://www.box.com/api/oauth2/token', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        System.debug('Test Refresh Token Request Body ' + req.getBody());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"access_token":"12345", "refresh_token":"12345"}');
        res.setStatusCode(200);
        return res;
    }
    
    
}