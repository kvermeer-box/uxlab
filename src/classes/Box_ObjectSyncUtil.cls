global class Box_ObjectSyncUtil { 

    static final PRM_Settings__c settings = PRM_Settings__c.getInstance('default'); 
    static final String ERROR_RECIPIENTS = settings == null ? 'dliu@box.com' : settings.Error_Notification_List__c;
    
    final String BOX_API_DOMAIN      = settings == null ? 'https://dev-git.external.inside-box.net/api/' : settings.Box_API_Domain__c;
    final String BOX_API_VERSION     = settings == null ? '2.0' : settings.Box_API_Version__c; 
    final String BOX_API_KEY         = settings == null ? '6ljka4nnzlapletl147828oxdvn39gg5' : settings.Box_API_Key__c;
    final String BOX_AUTH_TOKEN      = settings == null ? 'by40xedzuugmw1a9rfyntwdiy26rahmk' : settings.Box_Authentication_Token__c;
    final String AUTH_BOX_API_KEY    = settings == null ? '6ljka4nnzlapletl147828oxdvn39gg5' : settings.Non_Box_API_Key__c;
    final String AUTH_BOX_AUTH_TOKEN = settings == null ? 'by40xedzuugmw1a9rfyntwdiy26rahmk' : settings.Non_Box_Authentication_Token__c;
    private static final Boolean useOAuth = (settings != null) ? settings.Use_OAuth__c : false;  

    private String constructUrl(String api) {
        System.debug('Constructing url...');
        String url = BOX_API_DOMAIN + BOX_API_VERSION + api;
        System.debug('Url constructed: ' + url);
        return url; 
    }
    private Boolean isATTPartner;
    
    public Box_ObjectSyncUtil(){
        this.isATTPartner = false;  
    }
    
    public Box_ObjectSyncUtil( Boolean isATTPartner){
        this.isATTPartner = isATTPartner;
    }
    private String constructAuthorizationHeader() {
        System.debug('Constructing header...');
        System.debug(isATTPartner);
        String header = 'BoxAuth ';
        if( isATTPartner ){
            header += 'api_key=' + BOX_API_KEY;
            header += '&auth_token=' + BOX_AUTH_TOKEN;
        }else {
            header += 'api_key=' + AUTH_BOX_API_KEY;
            header += '&auth_token=' + AUTH_BOX_AUTH_TOKEN;
        }       
        System.debug('Header constructed.');
        system.debug('Header is : '+ header);
        return header;
    }

    private HttpRequest constructHttpRequest(String json, String api, String method) {
        return constructHttpRequest(json, api, method, null);
    }

    /**
     * Creates the HTTP request to Box
     *
     * @param {String} json - json for request
     * @param {String} api - which API to use (used to contruct the URL)
     * @param {String} method - REST method to use
     * @param {String} resellerId - resellerId to authenticate as... may be null if not using OAuth
     * @return {HttpRequest} - request to send out
     * @author David Liu
     * @revision Kyle Vermeer 4/22/2014 Added changes for OAuth
     */
    private HttpRequest constructHttpRequest(String json, String api, String method, String resellerId) {
        System.debug('Constructing httprequest...');
        HttpRequest req = new HttpRequest();
        if (api != null && !api.equals('')) {
            // Set endpoint
            String endpoint = constructUrl(api);
            req.setEndpoint(endpoint);
            
            // Create header
            String authorizationHeader;
            if (useOAuth && resellerId != null) {
                authorizationHeader = 'Bearer ' + Box_OAuth2Utils.getAuthToken(resellerId);
            }
            else {
                authorizationHeader = constructAuthorizationHeader();
            }
            req.setHeader('Authorization', authorizationHeader);         
            
            // Set the method
            method = method == null ? 'GET' : method;
            req.setMethod(method);
            System.debug('Method: ' + method);
            
            // Create the body, if needed
            if(!method.toUpperCase().equals('GET') && json != null && !json.equals('')) {
                req.setBody(json);              
                System.debug('Body: ' + json);
            }           
            System.debug('HttpRequest creation successful.');
        } 
        return req;
    }

    public HttpResponse syncToBox(String json, String api, String method) {
        return syncToBox(json, api, method, null);
    }

    public HttpResponse syncToBox(String json, String api, String method, String resellerId) {
        System.debug('Syncing Box object...');
        
        HttpResponse res;
        HttpRequest req;
        req = constructHttpRequest(json, api, method, resellerId); 
        
        if (req != null) {
            try {
                // Send this shit
                System.debug('Sending http ' + method + '...');
                Http http = new Http();
                if (!Test.isRunningTest()) {
                    res = http.send(req);
                    req.setTimeout(120000);
                    System.debug('Httpresponse: ' + res.getBody());
                }
            } catch (Exception e) {
                throw new CustomException(e.getMessage(), generateRecipientsList());
            }
        }
        if (!Test.isRunningTest()) {
            return res;
        } else {
            Box_TestMockResponse mock = new Box_TestMockResponse(json);
            return mock.respond(req);
        }   
    }
    
    public static String[] generateRecipientsList() {
        System.debug('Generating recipient list...');       
        String[] recipients;
        if (ERROR_RECIPIENTS != null && !ERROR_RECIPIENTS.equals('')) {
            recipients = ERROR_RECIPIENTS.split(';');
        }
        return recipients;
    }

}