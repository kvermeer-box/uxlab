@isTest

public class SalesRequestCreatorbyPeterTest 
{ 
   static testMethod void TestinBoundEmail() {

  // create a new email and envelope object
  Messaging.InboundEmail email = new Messaging.InboundEmail() ;
  Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

  // setup the data for the email
  email.subject = 'Test Job Applicant';
  email.fromname = 'FirstName LastName';
  env.fromAddress = 'someaddress@email.com';
  email.plainTextBody ='test body';
  email.fromaddress ='someaddress@email.com';
  
  User user = new User();
  user.firstname='test';
  user.Lastname='test';
  user.username='test';

Boolean containsReport=true;
Boolean containsErrorBug=true;
Boolean containsLeadRouting=true;
Boolean containsLoginPermissions=true;
Boolean containsNewHire=true;
Boolean containsForecast=true;
Boolean containsConfig=true;



string myPlainText= 'testbody';
String RegexStringCustom = '^([a/-zA/-Z0/-9._/-/+]+@box[.](com|net))!!';   
Pattern RegexPatternCustom = Pattern.compile(RegexStringCustom);
Matcher RegexMatcherCustom = RegexPatternCustom.matcher(myPlainText);
List<String> boxEmailsWithExclaimation = new List<String>();

// add an Binary attachment
  
  Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
      attachment.body = blob.valueOf('my attachment text');
      attachment.fileName = 'textfileone.txt';
      attachment.mimeTypeSubType = 'text/plain';
      email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
 
  // add an Text atatchment
  
  Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
      attachmenttext.body = 'my attachment text';
      attachmenttext.fileName = 'textfiletwo3.txt';
      attachmenttext.mimeTypeSubType = 'texttwo/plain';
      email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
          
          

Sales_Request__c SalesRequest = new Sales_Request__c();
SalesRequest.SFDC_Admin_Tier__c = 'T1';
SalesRequest.Dominator__c = '00560000001v0tyAAA';
SalesRequest.How_can_we_help__c = 'EMAIL BODY:';
SalesRequest.RecordTypeId = '012600000009VZU';
SalesRequest.Relevant_Email_Subject__c = 'test subject';
       

  // call the email service class and test it with the data in the testMethod
  SalesRequestCreatorbyPeter testInbound = new SalesRequestCreatorbyPeter();
  testInbound.handleInboundEmail(email, env);

}

   }