/**
 * Controller for the RestTestingTool Visualforce Page
 *
 * @author Kyle Vermeer 8/26/2014
 */
public class RestTestingTool {

    private static final String HTTP_POST = 'POST';

    public Rest_Test_Tool_Endpoint__c endpoint { get; set; }
    public Rest_Test_Tool_Endpoint_Field__c[] fields { get; set; }
    
    public RestTestingTool() {
        this.endpoint = [SELECT Id, Name, Endpoint_Path__c, 
                                (SELECT Rest_Test_Tool_Endpoint_Field__c.Id, Rest_Test_Tool_Endpoint_Field__c.Name, Rest_Test_Tool_Endpoint_Field__c.Field_Data_Type__c, Rest_Test_Tool_Endpoint_Field__c.Default_Value__c 
                                   FROM Rest_Test_Tool_Endpoint__c.Rest_Test_Tool_Endpoint_Fields__r
                               ORDER BY Sort_Priority__c ASC) 
                          FROM Rest_Test_Tool_Endpoint__c LIMIT 1];
        this.fields = this.endpoint.Rest_Test_Tool_Endpoint_Fields__r;
    }

    @RemoteAction 
    public static String sendRequest(String request, String endpoint) {

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod(HTTP_POST);
        req.setHeader('Content-Type', 'application/json');
        System.debug('Request: ' + request);
        req.setBody(request);
        req.setTimeout(120000);
 
        String sessionId = UserInfo.getSessionId();

        String authorizationHeader = 'Bearer ' + sessionId;
        req.setHeader('Authorization', authorizationHeader);

        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug('Body: ' + res.getBody());
        return res.getBody();
    }
}