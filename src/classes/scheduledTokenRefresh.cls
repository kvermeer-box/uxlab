global class scheduledTokenRefresh implements Schedulable {
    /*
    *Scheduled class to call the Box api and get new refresh / access tokens
    *
    */
   
   public static String CRON_EXP = '0 10 * * * ?';
   
   
   global void execute(SchedulableContext SC) {
       updateTokens();     
   }
   
   @future(callout=true)
   public static void updateTokens(){
       //app info for authenticating 
        String clientID = '305h84vhx548n0o2odv5bwbew85js9vm';
        String clientSecret = 'koTqcRHtZRsArlkWizPgcO2Kf6dSx4Uu';
        //look up value of existing refresh token
        Token__c myToken = [SELECT Name, Value__c FROM Token__c WHERE Name='Refresh'];
        Token__c myAccessToken = [SELECT Name, Value__c FROM Token__c WHERE Name='Access'];
        String refreshToken = myToken.Value__c;
        String accessToken = myAccessToken.Value__c;
        System.debug('Refresh Token ' + refreshToken);
        System.debug('Access Token ' + accessToken);
        
        //variables for storing data
        String BoxJSON = '';
        String debugTxt = '';
      
        if (Test.isRunningTest()) {
            Test.setMock(HTTPCalloutMock.class, new TreasuryTokenRefreshTest());
        }
        
        //callout to Box API to get new tokens
        HttpRequest reqRefresh = new HttpRequest();
        reqRefresh.setMethod('POST');
        String endpointRefresh = 'https://www.box.com/api/oauth2/token';
        reqRefresh.setEndpoint(endpointRefresh);
        String requestBody = ('grant_type=refresh_token&refresh_token=' + refreshToken + '&client_id=' + clientID + '&client_secret=' + clientSecret);
        reqRefresh.setBody(requestBody);
        System.debug('Body of refresh request: ' + requestBody);
        //Create Http, send request
        Http httpRefresh = new Http();
        Boolean successRefresh = false;
        while (successRefresh == false){
            try{
                HTTPResponse resRefresh = httpRefresh.send(reqRefresh);
                BoxJSON = resRefresh.getBody();
                System.debug('Body of refresh response: ' + BoxJSON);
                successRefresh = true;
            } 
            catch (System.Exception e){
                System.debug('Error refreshing: ' + string.valueof(e));
                if (Test.isRunningTest()){
                    successRefresh = true;
                }
            }
        }
       
        //initialize parser to parse refresh and access tokens
        JSONParser parserTokens = JSON.createParser(BoxJSON);
        //loop through tokens to be parsed

        while (parserTokens.nextToken() != null){
            //save values associated with id
            if (parserTokens.getCurrentToken() == JSONToken.FIELD_Name){
                String fieldName = parserTokens.getText();
                parserTokens.nextToken();
                //save access and refresh tokens
                if (fieldName == 'access_token'){                    
                    accessToken = parserTokens.getText();
                    }
                if (fieldName == 'refresh_token'){
                    refreshToken = parserTokens.getText();
                    }        
           }
       }
       
       System.debug('Initial refresh: ' + myToken.Value__c + '// New refresh: ' + refreshToken);
       if(refreshToken == myToken.Value__c){
           refreshToken = 'ERROR REFRESHING';
           accessToken = 'ERROR REFRESHING';
       }else{
           //save new refresh token value
            myToken.Value__c = refreshToken;
            myAccessToken.Value__c = accessToken;
       }

        
        //update Token variables 
        try {
            update myToken;
            update myAccessToken;
        } catch (DmlException e) {
            debugTxt = (debugTxt + 'Error updating refresh token: ' + string.valueof(e));
            System.debug('Error updated tokens: ' + string.valueof(e));
        }
        
   }
}