@isTest
global class TreasuryHTTPCreateTest implements HttpCalloutMock {
    // Implement this interface method
    
    //Step 1: Create Folder
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('https://api.box.com/2.0/folders/', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"id":"12345"}');
        res.setStatusCode(200);
        return res;
    }
    
    
}