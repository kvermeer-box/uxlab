/**
 * Utility methods for accessing box via OAuth2
 *
 * @author Kyle Vermeer <kvermeer@box.com>
 */
public class Box_OAuth2Utils {

    private class TokenReponse {
        public String access_token;
        public Integer expires_in;
        public String token_type;
    }

    private static final PRM_Settings__c settings = PRM_Settings__c.getInstance('default');
    private static final String OAUTH_AUTHORIZATION_ENDPOINT = (settings != null) ? settings.OAuth_Authorization_Endpoint__c : '';
    private static final String OAUTH_CLIENT_ID = (settings!= null) ? settings.OAuth_Client_ID__c : '';
    private static final String OAUTH_CLIENT_SECRET = (settings != null) ? settings.OAuth_Client_Secret__c : '';

    private static final String POST = 'POST';
    private static final String GRANT_TYPE = 'client_credentials';
    private static final String SUBJECT_TYPE = 'Reseller';

    private static final String ATT_BOX_RESELLER_ID = '553';
    private static final String ATT_SFDC_RESELLER_ID = '3980955827';
    
    /**
     * Gets authorization token from Box for resellerId
     *
     * @param {String} resellerId - Id of reseller
     * @return {String} - authorization token from Box
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    public static String getAuthToken(String resellerId) {
        HttpRequest req = new HttpRequest();
        if (resellerId == ATT_SFDC_RESELLER_ID) {
            resellerId = ATT_BOX_RESELLER_ID;
        }
        req.setMethod(POST);
        req.setEndpoint(OAUTH_AUTHORIZATION_ENDPOINT);
        String bodyData = 'grant_type=' + GRANT_TYPE;
        bodyData += '&client_id=' + OAUTH_CLIENT_ID;
        bodyData += '&client_secret=' + OAUTH_CLIENT_SECRET;
        bodyData += '&box_subject_id=' + resellerId;
        bodyData += '&box_subject_type=' + SUBJECT_TYPE;
        System.debug('BODY DATA: ' + bodyData);
        req.setBody(bodyData);
        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            System.debug('Response: ' + res);
            System.debug('Response Body: ' + res.getBody());
            TokenReponse tokenObject = (TokenReponse) JSON.deserialize(res.getBody(), TokenReponse.class);
            return tokenObject.access_token;
        }
        catch (Exception e) {
            System.debug('Issue with OAuth Token Request. Exception: ' + e);
            new LoggedException(e,'Box_OAuth2Utils','Issue with OAuth Token Request.');
            throw e;
            return null;
        }
    }

    public class AuthTokenHTTPCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse fakeResponse = new HttpResponse();
            fakeResponse.setHeader('Content-Type','application/json');
            fakeResponse.setBody('{"access_token":"TestToken","expires_in":3722,"restricted_to":[],"token_type":"bearer"}');
            fakeResponse.setStatusCode(200);
            return fakeResponse;
        }
    }
}