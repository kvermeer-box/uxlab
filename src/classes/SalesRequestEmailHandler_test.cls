@isTest
private class SalesRequestEmailHandler_test {
  
  @isTest static void testCreateSalesRequest() 
  {
    String value_append = ' Value';
    Map<String,String> tag_map = createTagMap(value_append);
    User sender = createSender();
    
    String from_address = sender.email;
    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

    Test.startTest();
    Id sales_request_id = SalesRequestEmailHandler_email.createSalesRequest(tag_map,
                                                                            from_address,
                                                                            SalesRequestEmailHandler_email.REQUIRED_TAGS_LIST,
                                                                            result);
    Test.stopTest();
    System.assertNotEquals(sales_request_id,null,'Sales Request Created Id should not be null');
    Sales_Request__c sales_request = [SELECT Summary__c, RecordTypeId, How_can_we_help__c, Request_Type__c, Severity__c
                                      FROM Sales_Request__c
                                      WHERE Id = :sales_request_id LIMIT 1];
    System.assertEquals(sales_request.Summary__c, 
                        SalesRequestEmailHandler_email.FIELD_NAME_SUMMARY + value_append, 
                        'Summary_c incorrect.');
    System.assertEquals(sales_request.How_can_we_help__c, 
                        SalesRequestEmailHandler_email.FIELD_NAME_HOW_CAN_WE_HELP + value_append, 
                        'How_can_we_help__c incorrect.');
    System.assertEquals(sales_request.Request_Type__c,
                        SalesRequestEmailHandler_email.FIELD_NAME_REQUEST_TYPE + value_append,
                        'Request_Type__c incorrect.');
    System.assertEquals(sales_request.Severity__c,
                        SalesRequestEmailHandler_email.FIELD_NAME_SEVERITY + value_append,
                        'Request_Type__c incorrect.');
  }

  @isTest static void testCreateSalesRequest_NullInputs()
  {
    String value_append = ' Value';
    Map<String,String> tag_map = createTagMap(value_append);
    // Create user to send the e-mail
    User sender = createSender();
    String from_address = sender.email;
    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
    
    Test.startTest();
    Id sales_request_id_null_tag_map = SalesRequestEmailHandler_email.createSalesRequest(null,
                                                                                         from_address,
                                                                                         SalesRequestEmailHandler_email.REQUIRED_TAGS_LIST,
                                                                                         result);
    Id sales_request_id_null_from_address = SalesRequestEmailHandler_email.createSalesRequest(tag_map,
                                                                                              null,
                                                                                              SalesRequestEmailHandler_email.REQUIRED_TAGS_LIST,
                                                                                              result);
    Id sales_request_id_null_result = SalesRequestEmailHandler_email.createSalesRequest(tag_map,
                                                                                        from_address,
                                                                                        SalesRequestEmailHandler_email.REQUIRED_TAGS_LIST,
                                                                                        null);
    Id sales_request_id_null_required_tags = SalesRequestEmailHandler_email.createSalesRequest(tag_map,
                                                                                               from_address,
                                                                                               null,
                                                                                               result);
    Test.stopTest();

    System.assertEquals(sales_request_id_null_tag_map,null,'Tag map provided was null, null should be returned.');
    System.assertEquals(sales_request_id_null_from_address,null,'From address provided was null, null should be returned.');
    System.assertEquals(sales_request_id_null_result,null,'Result provided was null, null should be returned.');
    System.assertNotEquals(sales_request_id_null_required_tags,null,'Required tags was null, but Id should still be returned.');
  }

  @isTest static void testCreateSalesRequest_FromAddressNotAUser()
  {
    String value_append = ' Value';
    Map<String,String> tag_map = createTagMap(value_append);
    tag_map.remove(SalesRequestEmailHandler_email.FIELD_NAME_SUMMARY);
    System.debug('Bro: ' + tag_map.get(SalesRequestEmailHandler_email.FIELD_NAME_SUMMARY));
    // Fake email
    String from_address = 'Im not an email';
    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
    
    Test.startTest();
    Id sales_request_id_invalid_from_address = SalesRequestEmailHandler_email.createSalesRequest(tag_map,
                                                                                           from_address,
                                                                                           SalesRequestEmailHandler_email.REQUIRED_TAGS_LIST,
                                                                                           result);
    Test.stopTest();

    System.assertEquals(sales_request_id_invalid_from_address,null,'From Address didn\'t match a user, null should be returned.');
  }

  @isTest static void testCheckRecordType()
  {
    String record_type_sfdc = 'SFDC Request';
    String record_type_se = 'SE Request';
    Test.startTest();
    Id record_type_id_sfdc = SalesRequestEmailHandler_email.checkRecordType(record_type_sfdc);
    Id record_type_id_se = SalesRequestEmailHandler_email.checkRecordType(record_type_se);
    Test.stopTest();
    // Get Describe Result maps to find true IDs
    Schema.DescribeSObjectResult describe_result = Sales_Request__c.sObjectType.getDescribe();
    Map<String,Schema.RecordTypeInfo> record_type_info_map = describe_result.getRecordTypeInfosByName();
    Id describe_result_record_type_id_sfdc = record_type_info_map.get(record_type_sfdc).getRecordTypeId();
    Id describe_result_record_type_id_se = record_type_info_map.get(record_type_se).getRecordTypeId();
    System.assertEquals(describe_result_record_type_id_se,record_type_id_se,'SE Request ID should match.');
    System.assertEquals(describe_result_record_type_id_sfdc,record_type_id_sfdc,'SFDC Request ID should match.');
  }

  @isTest static void testCheckRecordType_InvalidRecordType()
  {
    String record_type_invalid = 'I\'ll never be a record type!';
    
    Test.startTest();
    Id record_type_id_invalid = SalesRequestEmailHandler_email.checkRecordType(record_type_invalid);
    Test.stopTest();
    
    // Get Describe Result maps to find true IDs
    Schema.DescribeSObjectResult describe_result = Sales_Request__c.sObjectType.getDescribe();
    Map<String,Schema.RecordTypeInfo> record_type_info_map = describe_result.getRecordTypeInfosByName();
    Id describe_result_record_type_id_default = record_type_info_map.get(SalesRequestEmailHandler_email.DEFAULT_RECORD_TYPE).getRecordTypeId();
    System.assertEquals(describe_result_record_type_id_default,record_type_id_invalid,'Invalid record types should be changed to defaul record type.');
  }

  @isTest static void testCheckRequestType()
  {
    String valid_request_type = 'Error / Bug';
    String invalid_request_type = null;
    
    Test.startTest();
    String valid_request_type_checked = SalesRequestEmailHandler_email.checkRequestType(valid_request_type);
    String invalid_request_type_checked = SalesRequestEmailHandler_email.checkRequestType(invalid_request_type);
    Test.stopTest();

    System.assertEquals(valid_request_type_checked,valid_request_type,'Valid request types shouldn\'t be changed.');
    System.assertEquals(invalid_request_type_checked,SalesRequestEmailHandler_email.DEFAULT_REQUEST_TYPE,'Invalid request types should be made default.');
  }

  @isTest static void testCheckSeverity()
  {
    String valid_severity = 'High';
    String invalid_severity = null;
    
    Test.startTest();
    String valid_severity_checked = SalesRequestEmailHandler_email.checkSeverity(valid_severity);
    String invalid_severity_checked = SalesRequestEmailHandler_email.checkSeverity(invalid_severity);
    Test.stopTest();

    System.assertEquals(valid_severity_checked,valid_severity,'Valid severity shouldn\'t be changed.');
    System.assertEquals(invalid_severity_checked,SalesRequestEmailHandler_email.DEFAULT_SEVERITY,'Invalid severity should be made default.');
  }

  @isTest static void testSendSuccessEmail()
  {
    String value_append = ' Value';
    Map<String,String> tag_map = createTagMap(value_append);
    User sender = createSender();
    
    String from_address = sender.email;
    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

    Test.startTest();
    Id sales_request_id = SalesRequestEmailHandler_email.createSalesRequest(tag_map,
                                                                            from_address,
                                                                            SalesRequestEmailHandler_email.REQUIRED_TAGS_LIST,
                                                                            result);
    Messaging.SingleEmailMessage mail = SalesRequestEmailHandler_email.sendSuccessEmail(sales_request_id,from_address);
    Test.stopTest();

    System.assertNotEquals(mail,null,'Sales request was created correctly, success mail shouldn\'t be null.');
  }

  @isTest static void testSendSuccessEmail_NullInputs()
  {
    String value_append = ' Value';
    Map<String,String> tag_map = createTagMap(value_append);
    User sender = createSender();
    
    String from_address = sender.email;
    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

    Test.startTest();
    Id sales_request_id = SalesRequestEmailHandler_email.createSalesRequest(tag_map,
                                                                            from_address,
                                                                            SalesRequestEmailHandler_email.REQUIRED_TAGS_LIST,
                                                                            result);
    Messaging.SingleEmailMessage mail_null_addresss = SalesRequestEmailHandler_email.sendSuccessEmail(sales_request_id,null);
    Messaging.SingleEmailMessage mail_null_request_id = SalesRequestEmailHandler_email.sendSuccessEmail(null,from_address);
    Test.stopTest();

    System.assertEquals(mail_null_addresss,null,'Null address provided, should return null.');
    System.assertNotEquals(mail_null_request_id,null,'If sales request id is null, should still return success message.');
    System.assert(mail_null_request_id.subject.contains('Trouble Retrieving it'),
      'If sales request id is null, success message should say there was trouble getting record.');
  }

  @isTest static void testHandleInboundEmail()
  {
    Messaging.inboundEmail email = new Messaging.inboundEmail();
    String email_body = '<request>' +
                          '<Summary>Help Me!</Summary>' +
                          '<How can we help>Just help!</How can we help>' +
                        '</request>';
    User sender = createSender();
    email.plainTextBody = email_body;
    email.fromAddress = sender.email;
    Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
    SalesRequestEmailHandler_email email_object = new SalesRequestEmailHandler_email();
    Test.startTest();
    Messaging.InboundEmailResult result = email_object.handleInboundEmail(email,env);
    Test.stopTest();
    System.assertNotEquals(result,null,'Result should never be null.');
    System.debug('Result: ' + result);
    System.assert(result.success,'Valid email provided, should be successful.');
  }

  static Map<String,String> createTagMap(String value_append)
  {
    Map<String,String> tag_map = new Map<String,String>();
    // Populate tag map
    tag_map.put(SalesRequestEmailHandler_email.FIELD_NAME_SUMMARY ,
                SalesRequestEmailHandler_email.FIELD_NAME_SUMMARY  + value_append);
    tag_map.put(SalesRequestEmailHandler_email.FIELD_NAME_HOW_CAN_WE_HELP,
                SalesRequestEmailHandler_email.FIELD_NAME_HOW_CAN_WE_HELP + value_append);
    tag_map.put(SalesRequestEmailHandler_email.FIELD_NAME_REQUEST_TYPE,
                SalesRequestEmailHandler_email.FIELD_NAME_REQUEST_TYPE + value_append);
    tag_map.put(SalesRequestEmailHandler_email.FIELD_NAME_SEVERITY,
                SalesRequestEmailHandler_email.FIELD_NAME_SEVERITY + value_append);
    return tag_map;
  }

  static User createSender()
  {
    // Create user to send the e-mail
    Id sender_id = TestDataFactory_hlpr.createUserSimple();
    User sender = [SELECT Id, Email
                   FROM User
                   WHERE Id = :sender_id LIMIT 1];
    return sender;
  }
  
}