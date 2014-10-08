public class TreasuryCreateTokens{
     public static void createTokens(){
        Token__c RefreshToken = new Token__c();
        RefreshToken.Name = 'Refresh';
        RefreshToken.Value__c = '9QoA1yqhBG31ctdipWgbSrvZx0INH79st1R2ccUMt8TgQzvPbLiCy00CwlI6svfO';
       
       Token__c AccessToken = new Token__c();
       AccessToken.Name = 'Access';
       AccessToken.Value__c = '4oTmP2R7YVTr6357vczjwCH0jG4bgGyA';
         
         try{
            insert AccessToken;
             insert RefreshToken;
         }catch(System.Exception e){
            System.debug('Error creating tokens: ' + string.valueOf(e));   
         }
         
       
       
       
   }

}