public class WebTrialLogServices
{
    @TestVisible private static Boolean logExceptionEmailSent = false;
    public static Web_Trial_Log__c buildWebTrialLog()
    {
        if (RestContext.request == null || RestContext.request.requestBody == null)
        {
            System.debug('Null Request or request body.  Request: ' + RestContext.request);
            return null;
        }
        Web_Trial_Log__c webTrialLog = new Web_Trial_Log__c( Request__c = RestContext.request.requestBody.toString() );
        System.debug('Web Trial Log: ' + webTrialLog);
        return webTrialLog;
    }

    public static void sendLogExceptionEmail( String exceptionMessage, WebTrialRest.WebTrial webTrial )
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { Label.Web_Trial_Log_Error_Mail });
        mail.setSaveAsActivity( false );
        mail.setSubject('DML Exception on Web Trial Log');

        String emailBody = 'Exception Message: ' + exceptionMessage;
        emailBody += webTrial.errorMsg != NULL ? '\nResponse Error Message: ' + webTrial.errorMsg : NULL;
        emailBody += webTrial.statusCode != NULL ? '\nResponse Status Code: ' + webTrial.statusCode : NULL;
        emailBody += '\nRequest: ' + RestContext.request.requestBody.toString();

        mail.setPlainTextBody(emailBody);

        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        logExceptionEmailSent = true;
    }
}