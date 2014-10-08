/**
 * This class provides a class of Exception that will be logged as a object for later reference.
 * 
 * Email notifications for this object are controlled at the workflow level. Subclass of Exception.
 *
 * @author Kyle Vermeer <kvermeer@box.com>
 * @version 1.2
 *
 * @revision 1.0 Kyle Vermeer 12/16/2013 Initial Creation
 * @revision 1.1 Kyle Vermeer 1/16/2014 No longer attempts to send e-mails during unit tests
 * @revision 1.2 Kyle Vermeer 2/27/2014 Documentation + Transition e-mails to workflows
 */
public class LoggedException extends Exception {

    private static final String OBJECT_ID_DELIMITER = ';';

    private static final String EMAIL_RECIPIENTS = 'kvermeer@box.com;rwu@box.com;ayoung@box.com;cmills@box.com';
  
    /**
     * Constructor without objectIds array.
     *
     * @param Exception e - Exception to be logged
     * @param String message - Message from developer to be displayed to User
     * @param String className - Classname in which the exception was thrown
     */
    public LoggedException(Exception e, String message, String className) {
        // Super Constructor
        this(message);
        logException(e, message,className, null);    
    }

    /**
     * Constructor with objectIds array.
     *
     * @param Exception e - Exception to be logged
     * @param String message - Message from developer to be displayed to User
     * @param String className - Classname in which the exception was thrown
     * @param String[] objectIds - Ids of objects that caused the exception to be thrown
     */
    public LoggedException(Exception e, String message, String className, String[] objectIds) {
        // Super Constructor
        this(message);
        logException(e, message,className,objectIds);
    }

    /**
     * Inserts a LoggedException__c object
     *
     * @param Exception e - Exception to be logged
     * @param String message - Message from developer to be displayed to User
     * @param String className - Classname in which the exception was thrown
     * @param String[] objectIds - Ids of objects that caused the exception to be thrown
     */
    private void logException(Exception e, String message, String className, String[] objectIds) {
        List<String> recipients = EMAIL_RECIPIENTS.split(';');
        System.debug('Error caught: ' + e.getStackTraceString() + ': ' + e.getMessage());
        LoggedException__c logE = new LoggedException__c(Message__c = e.getMessage(), Class_Name__c = className,
                                                     Error_Time__c = Datetime.now(), Exception_Type__c = e.getTypeName(),
                                                     Stack_Trace__c = e.getStackTraceString(), Logged_Message__c=message);
        // If objects Ids has entries, populate those
        if (objectIds != null && objectIds.size() > 0) {
            String concatenatedObjectIds = String.join(objectIds,OBJECT_ID_DELIMITER);
            logE.Object_Ids__c = concatenatedObjectIds;
        }
        insert logE;
    }
}