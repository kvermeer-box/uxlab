/**
* Class Name: SalesRequestEmailHandler_email
* SubClass Of: BasicXMLEmailHandler_email
* Description:
*   This class extends BasicXMLEmailHandler_email to handle inbound email to create Sales Requests.
*   Allows sales request of any record type to be created, but defaults to DEFAULT_RECORD_TYPE.
**/
global class SalesRequestEmailHandler_email extends BasicXMLEmailHandler_email implements Messaging.InboundEmailHandler {

  private static final String OBJECT_TYPE_NAME = 'request';

  // Possible Tags
  @TestVisible private static final String FIELD_NAME_SUMMARY = 'Summary';
  @TestVisible private static final String FIELD_NAME_RECORD_TYPE = 'Record Type';
  @TestVisible private static final String FIELD_NAME_HOW_CAN_WE_HELP = 'How can we help';
  @TestVisible private static final String FIELD_NAME_REQUEST_TYPE = 'Request Type';
  @TestVisible private static final String FIELD_NAME_SEVERITY = 'Severity';

  // Default Values
  @TestVisible private static final String DEFAULT_RECORD_TYPE = 'SFDC Request';
  @TestVisible private static final String DEFAULT_REQUEST_TYPE = 'Error / bug';
  @TestVisible private static final String DEFAULT_SEVERITY = 'Low';

  // Name that should be displayed on Success Response
  private static final String EMAIL_DISPLAY_NAME = 'Salesforce Automated Response';

  // Don't grab DLO as Kyle Wulff
  private static final String DLO_ALIAS = 'dlo';
  private static final String OUTGOING_FROM_ADDRESS = 'noreply@box.com';

  // Required and Optional Tag List
  @TestVisible private static final List<String> REQUIRED_TAGS_LIST = new String[] {FIELD_NAME_SUMMARY, FIELD_NAME_HOW_CAN_WE_HELP};
  @TestVisible private static final List<String> OPTIONAL_TAGS_LIST = new String[] {FIELD_NAME_REQUEST_TYPE, 
                                                                       FIELD_NAME_RECORD_TYPE, 
                                                                       FIELD_NAME_SEVERITY};
  
  /**
  * Entry Point for incoming email - this code is executed when e-mail is recieved.
  **/
  global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,
                                Messaging.InboundEnvelope env) {
    // Grab email body
    String email_text= email.plainTextBody;
    System.debug(email_text);

    // Specify the required versus the optional strings
    //List<String> required_tags = new String[] {FIELD_NAME_SUMMARY, FIELD_NAME_HOW_CAN_WE_HELP};
    List<String> optional_tags = new String[] {FIELD_NAME_REQUEST_TYPE, FIELD_NAME_RECORD_TYPE, FIELD_NAME_SEVERITY};
    
    // Parse the message and get data back in a Map from tags to data
    Map<String,String> tag_map = parseMessage(email_text,OBJECT_TYPE_NAME,REQUIRED_TAGS_LIST,OPTIONAL_TAGS_LIST);

    // Attempt to create Sales Request
    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
    Id sales_request_id = createSalesRequest(tag_map, email.fromAddress,REQUIRED_TAGS_LIST, result);
    if (result.success)
    {
      sendSuccessEmail(sales_request_id,email.fromAddress);
    }
    return result;
  }

  /**
  * Method: createSalesRequest
  * Decorators: private, static
  * Description:
  *   This method creates and inserts a sales request based on the tag map provided.  The
  *   sales request is "Created By" the person who sent the e-mail, which is why from_address
  *   is required.  If no user can be found with the specified e-mail address, the returned
  *   Messaging.InboundEmailResult will have its success set to 'false';
  * Inputs:
  *   Map<String,String> tag_map - This Map maps tag text to its value.  For example, in this example:
  *                               <request>
  *                                  <Name>Blah</Name>
  *                               </request>
  *                               "Name" would be the key for the value "Blah".
  *   String from_address - The e-mail address of the sender of the e-mail.
  *   List<String> required_tags - A list of tags that must included to create a Sales Request.
  *                                Used to tell user what fields must be provided.
  *   Messaging.InboundEmailResult result - If the sales request is successfully created, success is set
  *                                         to 'true'. Otherwise, success is set to 'false' and message is
  *                                         set to describe the error that occured.
  * Return:
  *   Id - Id of newly created Sales Request ... or null if creation failed.
  **/
  @TestVisible private static Id createSalesRequest(Map<String,String> tag_map, 
                                                                 String from_address,
                                                                 List<String> required_tags,
                                                                 Messaging.InboundEmailResult result)
  {
    if (result == null)
    {
      System.debug('Must pass in a valid Messaging.InboundEmailResult');
      return null;
    }
    if (tag_map != null)
    {
      // Attempt to create Sales Request
      Sales_Request__c sales_request = new Sales_Request__c();
      try {
        sales_request.Summary__c = tag_map.get(FIELD_NAME_SUMMARY);
        sales_request.RecordTypeId = checkRecordType(tag_map.get(FIELD_NAME_RECORD_TYPE));
        sales_request.How_can_we_help__c = tag_map.get(FIELD_NAME_HOW_CAN_WE_HELP);
        sales_request.Request_Type__c = checkRequestType(tag_map.get(FIELD_NAME_REQUEST_TYPE));
        sales_request.Severity__c = checkSeverity(tag_map.get(FIELD_NAME_SEVERITY));
        String like_string = '%' + from_address + '%';
        // Grab user that sent e-mail
        Id sender_id = [SELECT Id 
                        FROM User 
                        WHERE email Like :like_string
                        AND alias != :DLO_ALIAS LIMIT 1].Id;
        sales_request.CreatedById = sender_id;
        sales_request.OwnerId = sender_id;
        insert sales_request;
        return sales_request.Id;
      } catch (DMLException e)
      {
        // If DML Exception, send user an e-mail back describing problem
        System.debug(e.getMessage());
        result.message = 'There was an error creating your Sales Request. Please talk to Sales Systems.\n';
        result.message += 'DMLException: ' + e.getMessage();
        result.success= false;
        return null;
      } catch (QueryException e)
      {
        // If QueryException (Couldn't find user), send an e-mail back describing the problem
        System.debug(e.getMessage());
        result.message = 'There was an error creating your Sales Request. A user with the e-mail: ' + 
                          from_address + ' could not be found.\n';
        result.message += 'QueryException: ' + e.getMessage();
        result.success= false;
        return null;
      }
      result.success= true;
      return sales_request.Id;
    } else 
    {
      result.message = 'Your Sales Request could not be created.\n';
      result.message += 'Check that you included all the required tags: ';
      result.message += required_tags;
      result.success = false;
      return null;
    }
  }

  /**
  * Method: checkRecordType
  * Decorators: private, static
  * Description:
  *   This method checks if the provided record type is an actual record type for Sales Requests.  If
  *   it is a record type, the Id of that record type is returned.  Otherwise if it is not a valid record
  *   type, the default record type is returned.
  * Inputs:
  *   String provided_record_type - The string name of the record type provided in the e-mail.
  * Return:
  *   Id - If provided_record_type is a valid record type, this is the Id of that record type.  Otherwise
  *        if provided_record_type is not a valid record type, returns the Id of the default record type.
  **/
  @TestVisible private static Id checkRecordType(String provided_record_type)
  {
    // Get Describe Result of Sales Request object
    Schema.DescribeSObjectResult describe_result = Sales_Request__c.sObjectType.getDescribe();
    Map<String,Schema.RecordTypeInfo> record_type_info_map = describe_result.getRecordTypeInfosByName();
    // Is provided_record_type a valid record type?
    if (record_type_info_map.containsKey(provided_record_type))
    {
      // If so, return the Id for this record type
      Schema.RecordTypeInfo record_type_info = record_type_info_map.get(provided_record_type);
      return record_type_info.getRecordTypeId();
    } else
    {
      // Otherwise return the Id for the default record type
      Schema.RecordTypeInfo record_type_info = record_type_info_map.get(DEFAULT_RECORD_TYPE);
      if (record_type_info != null) return record_type_info.getRecordTypeId();
      else return null;
    }
  }

  /**
  * Method: checkRequestType
  * Decorators: private, static
  * Description:
  *   This method checks if a request type was provided.  If so, it returns the provided request type.
  *   Otherwise if no request type was provided, return DEFAULT_REQUEST_TYPE.
  * Inputs:
  *   String provided_request_type - The string name of the request type provided in the e-mail.
  * Return:
  *   String - If provided_record_type a non-blank string, return provided_request_type.  Otherwise
  *            return DEFAULT_REQUEST_TYPE.
  **/
  @TestVisible private static String checkRequestType(String provided_request_type)
  {
    // Check for null and blank strings
    if (String.isBlank(provided_request_type)) return DEFAULT_REQUEST_TYPE;
    else return provided_request_type;
  }

  /**
  * Method: checkSeverity
  * Decorators: private, static
  * Description:
  *   This method checks if a severity was provided.  If so, it returns the provided severity.
  *   Otherwise if no request type was provided, return DEFAULT_SEVERITY.
  * Inputs:
  *   String provided_severity - The string name of the severity provided in the e-mail.
  * Return:
  *   String - If provided_severity a non-blank string, return provided_severity.  Otherwise
  *            return DEFAULT_SEVERITY.
  **/
  @TestVisible private static String checkSeverity(String provided_severity)
  {
    // Check for null and blank strings
    if (String.isBlank(provided_severity)) return DEFAULT_SEVERITY;
    else return provided_severity;
  }

  /**
  * Method: sendSuccessEmail
  * Decorators: private, static
  * Description:
  *   This method creates and sends a success e-mail back to the user who sent an e-mail request.  The
  *   email details the Sales Request that was created.  Returns the e-mail that was sent.
  * Inputs:
  *   Id sales_request_id - Id of the sales request created.
  *   String reply_email_address - Address that e-mail should be sent to.
  * Return
  *   Messaging.SingleEmailMessage - Message that was sent to the user.  Null if there was no reply_email_address
  */
  @TestVisible private static Messaging.SingleEmailMessage sendSuccessEmail(Id sales_request_id, String reply_email_address)
  {
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    // If reply e-mail address is null, return null
    if (reply_email_address!= null) 
    {
      String[] toAddresses = new String[] {reply_email_address};
      mail.setToAddresses(toAddresses);
    } else return null;
    try {
      // Get Sales Request and populate e-mail body
      Sales_Request__c sales_request = [SELECT Id, Name, Summary__c, RecordTypeId, How_can_we_help__c, Request_Type__c, Severity__c
                                           FROM Sales_Request__c
                                           WHERE Id = :sales_request_id LIMIT 1];
      RecordType record_type = [SELECT Id, Name
                                FROM RecordType
                                WHERE Id = :sales_request.RecordTypeId LIMIT 1];
      mail.setSubject('Sales Request # ' + sales_request.Name + ' Created!');
      String response_body = 'Sales Request Created.\n\n';
      response_body += 'Name: Sales Request # ' + sales_request.Name + '\n\n';
      response_body += 'Id: ' + sales_request.Id + '\n\n';
      response_body += 'Record Type: ' + record_type.Name + '\n\n';
      response_body += 'Request Type: ' + sales_request.Request_Type__c + '\n\n';
      response_body += 'How can we help?\n' + sales_request.How_can_we_help__c + '\n\n';
      mail.setPlainTextBody(response_body);
     
    } catch (QueryException e)
    {
      // Trouble get sales request, send e-mail letting user know
      mail.setSubject('Created Sales Request, Trouble Retrieving it!');
      mail.setPlainTextBody('You\'re Sales Request was created, but we had trouble retrieving it.  Please contact ' +
        'Sales Systems for further assistance.');
    } finally {
       // Set From e-mail
      OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = :OUTGOING_FROM_ADDRESS];
      if ( owea.size() > 0 ) {
        mail.setOrgWideEmailAddressId(owea.get(0).Id);
      }
    }
    if (!Test.isRunningTest()) {
      // Send e-mail
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }
    return mail;
  }
}