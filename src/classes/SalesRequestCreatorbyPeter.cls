//author: pnoges@box.com
/** 

ROADMAP: Introduce this tool to all *Box.com Users.
-introduce threading based on SR# http://sforcehacks.blogspot.com/2012/01/email-to-case-can-create-too-many-cases.html  http://sforcehacks.blogspot.ca/2012/01/email-to-case-custom-email-handler.html
    Define what constitutes a threadID.  Perhaps its an 18 or 15 digit Production Salesforce URL
    Before inserting a SR, store all threadID matches in both the subject and body into an Array.
    If there is 1 unique threadID in the Array, then Query the SR table and insert a Comment to the existing SR
    If there is 2+ unique threadID in the Array, Insert a new SR for simplicity sake.
    Re-use existing !r !e !l logic by programming that IF the FROMADDRESS is Peter Noges (let's just say) then Update the existing or new SR appropriately.
-make the endpoint accessible to all *box.com senders
-add the SFDC endpoint as a user in a public google group (e.g. Salessystems@box.com)
-Revisit the Workflow Alerts, problems w/ WOrkflow alerts, test plan for workflow alerts, and templates.
**/


//Current build:  This tool only accepts emails from Peter and that's because the Email Service is declaratively configured that way.

//7.8.2014 //special thanks to https://www.salesforce.com/us/developer/docs/apexcode/Content/apex_classes_email_inbound_using.htm //Special thanks to Kyle Vermeer and http://docs.oracle.com/javase/1.5.0/docs/api/index.html?java/util/regex/Pattern.html //https://developer.salesforce.com/forums?id=906F00000008wiYIAQ //https://www.salesforce.com/us/developer/docs/apexcode/Content/apex_classes_pattern_and_matcher_matcher_methods.htm#apex_System_Matcher_group
global class SalesRequestCreatorbyPeter implements Messaging.InboundEmailHandler {
global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, 
Messaging.InboundEnvelope envelope){
// Create an InboundEmailResult object for returning the result of the Apex Email Service
Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

String myPlainText= '';
String myPlainTextSubject= '';
String myPlainTextFromAddress= '';
String myPlainTextFromAddressSFDCID= '';
// Add the email plain text into the local variable 
myPlainText = email.plainTextBody;
myPlainTextSubject = email.subject;
myPlainTextFromAddress = email.fromaddress;

//************REGEX#1 searching for box.com emails    Kyles first //String RegexStringStandard = '<([^\\s@]*@box.com)>'; //kyles other String RegexStringStandard = '<(\\S*@box.com)>';   // abc  acbababcdasd
//String RegexStringStandard = '(\\S*@box.com)';   // abc  acbababcdasd
//Pattern RegexPatternStandard = Pattern.compile(RegexStringStandard);
//Matcher RegexMatcherStandard = RegexPatternStandard.matcher(myPlainText);
//List<String> boxEmails = new List<String>();
// ***************iterate through matches
//while (RegexMatcherStandard.find()) {
  // *******************when match found, add to array
//  boxEmails.add(RegexMatcherStandard.group());
//}
//System.debug('Number of matches: ' + boxEmails.size());
//System.debug('boxEmails Matches: ' + boxEmails);
      

//REGEX 2 broken,  http://docs.oracle.com/javase/tutorial/essential/regex/groups.html will be my best friend.  //maybe this though idk if its accurate, http://javahungry.blogspot.com/2014/01/email-validation-regular-expression-with-example-in-java.html     //maybe this too, http://www.ubotstudio.com/forum/index.php?/topic/13754-regex-to-find-email-addresses-at-specific-domain/ //REGEX#2 searching for !! keyword box.com emails. THIS IS BROKEN. see http://stackoverflow.com/questions/22232633/regexp-extract-number-thats-wrapped-in
String RegexStringCustom = '^([a/-zA/-Z0/-9._/-/+]+@box[.](com|net))!!';   
Pattern RegexPatternCustom = Pattern.compile(RegexStringCustom);
Matcher RegexMatcherCustom = RegexPatternCustom.matcher(myPlainText);
List<String> boxEmailsWithExclaimation = new List<String>();
// iterate through matches
while (RegexMatcherCustom.find()) {
  // when match found, add to array
  boxEmailsWithExclaimation.add(RegexMatcherCustom.group(1));
}
System.debug('Number of matchesWithExclaimation: ' + boxEmailsWithExclaimation.size());
System.debug('boxEmailsWithExclaimation matchesWithExclaimation: ' + boxEmailsWithExclaimation);
    
// New Sales Request object to be created
Sales_request__c SalesRequest = new Sales_Request__c();
SalesRequest.SFDC_Admin_Tier__c = 'T1'; //T1 is easy SFDC Admin Work //T2 is SFDC Admin supporting a PM work //T3 is PM work
SalesRequest.Dominator__c = '00560000001v0tyAAA';
SalesRequest.How_can_we_help__c = myPlainTextSubject + ' ' + 'EMAIL BODY:' + ' ' + myPlainText;
SalesRequest.RecordTypeId = '012600000009VZU';
SalesRequest.Relevant_Email_Subject__c = myPlainTextSubject;
Boolean containsReport=myPlainText.contains('!r');
Boolean containsErrorBug=myPlainText.contains('!e');
Boolean containsLeadRouting=myPlainText.contains('!l');
Boolean containsLoginPermissions=myPlainText.contains('!a');
Boolean containsNewHire=myPlainText.contains('!n');
Boolean containsForecast=myPlainText.contains('!f');
Boolean containsConfig=myPlainText.contains('!c');

//if the REGEX picks up that there are emails in the format xxxxxx@box.com!!, then query the User Table for the most recent logged in User.

    if (boxEmailsWithExclaimation.size()>0) {
      List<User> ccUserWithExclaimation = [SELECT Id FROM User WHERE isactive=true AND id!='00560000001v0tyAAA' AND ((username IN :boxEmailsWithExclaimation) OR email IN :boxEmailsWithExclaimation) order by lastlogindate desc Limit 1];
      System.debug('List<User>QUERY Size boxEmailsWithExclaimation.size() is:' + ccUserWithExclaimation.size());
      //if the Query return reults, then assign the Additional CC field.
      if (ccUserWithExclaimation.size() > 0) {
      System.debug('ccUser.Size is greater than zero and consists of:' + ccUserWithExclaimation);
      SalesRequest.Additional_CC__c = ccUserWithExclaimation[0].id;
      }
    }

//    
//    if(boxEmailsWithExclaimation.size() < 1){
//    //no @box.com!! addresses found.
//    //add all matches from the boxEmails List to the Relevant_Email_Addresses__c field.
//        List<User> ccUser = [SELECT Id FROM User WHERE isactive=true AND id!='00560000001v0tyAAA' AND ((username IN :boxEmails) OR email IN :boxEmails) order by lastlogindate desc Limit 1];
//        System.debug('List<User>QUERY Size boxEmailsWithExclaimation.size() is:' + ccUser.size());
//        if (ccUser.size() > 0) {
//          for (Integer j=0; j<boxEmails.size(); j++){
//          System.debug('ccUser.Size is greater than zero and consists of:' + ccUser);
//          SalesRequest.Relevant_Email_Addresses__c += ';' + ccUser[j].email + ';';
//          }
//        }
//      
//    }
if (containsReport == true && ((containsErrorBug==true) || (containsLeadRouting==true) || (containsLoginPermissions==true)|| (containsNewHire==true)|| (containsForecast==true) || (containsConfig==true))) {
  SalesRequest.Request_Type__c ='Uncategorized';
} else if (containsReport == true){
SalesRequest.Request_Type__c ='Dashboards and reporting';
}
else if (containsErrorBug == true && ((containsReport==true) || (containsLeadRouting==true) || (containsLoginPermissions==true) || (containsNewHire==true) || (containsForecast==true) || (containsConfig==true))) {
  SalesRequest.Request_Type__c ='Uncategorized';
} else if (containsErrorBug == true){
  SalesRequest.Request_Type__c ='Error / bug';
}
 else if (containsLeadRouting == true && ((containsReport==true) || (containsErrorBug=true) || (containsLoginPermissions=true) || (containsNewHire=true) || (containsForecast=true) || (containsConfig==true))) {
    SalesRequest.Request_Type__c ='Uncategorized';
} else if (containsLeadRouting==true){
SalesRequest.Request_Type__c ='Lead Flow';
}   
else if (containsLoginPermissions == true && ((containsErrorBug==true) || (containsLeadRouting==true) || (containsReport==true) || (containsNewHire==true) || (containsForecast==true) || (containsConfig==true))) {
SalesRequest.Request_Type__c ='Uncategorized';
} else if (containsLoginPermissions==true){
SalesRequest.Request_Type__c ='Logins and permissions';
}
else if (containsNewHire == true && ((containsReport==true) || (containsLeadRouting==true) || (containsLoginPermissions==true) || (containsErrorBug==true) || (containsForecast==true) || (containsConfig==true)) ){
  SalesRequest.Request_Type__c ='Uncategorized';
} else if (containsNewHire == true) {
SalesRequest.Request_Type__c ='New Hire';
}
else if (containsForecast==true && ((containsNewHire==true) || (containsLoginPermissions==true) || (containsLeadRouting==true) || (containsErrorBug==true) || (containsReport==true) || (containsConfig==true)) ){
 SalesRequest.Request_Type__c ='Uncategorized';
} else if (containsForecast==true) {
  SalesRequest.Request_Type__c ='Forecast/Roles';
}
else if (containsConfig==true && ((containsNewHire==true) || (containsLoginPermissions==true) || (containsLeadRouting==true) || (containsErrorBug==true) || (containsReport==true) || (containsForecast==true)) ){
 SalesRequest.Request_Type__c ='Uncategorized';
} else if (containsConfig==true) {
  SalesRequest.Request_Type__c ='Configuration';
}
 else {
   SalesRequest.Request_Type__c ='Uncategorized';
}
    SalesRequest.Severity__c ='Low';
    //SalesRequest.Secret_SOPs_Notes__c
    SalesRequest.Status__c ='Unassigned'; 
     // Insert the new Sales Request
     insert SalesRequest;    
     System.debug('New Sales Request Object: ' + SalesRequest );   

//SAVE ATTACHMENTS, IF ANY
//THIS References the SalesRequest.id which is why it must come after the "insert SalesRequest"
if (email.textAttachments != null && email.textAttachments.size()>0){

for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments){
    Attachment attachment = new Attachment();
    attachment.Name = tAttachment.fileName;
    attachment.Body = Blob.valueOf(tAttachment.body);
    attachment.ParentId = SalesRequest.Id;
     insert attachment;
}
}
if (email.binaryAttachments!=null && email.binaryAttachments.size()>0){
for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
  Attachment attachment = new Attachment();
 
  attachment.Name = bAttachment.fileName;
  attachment.Body = bAttachment.body;
  attachment.ParentId = SalesRequest.Id;
  insert attachment;
}
}
   // Set the result to true. No need to send an email back to the user 
   // with an error message
   result.success = true;
   // Return the result for the Apex Email Service
   return result;
  }
}