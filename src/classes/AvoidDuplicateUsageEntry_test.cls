@isTest
private class AvoidDuplicateUsageEntry_test {
	
  /*
   * This test is purely to give test code coverage.
   */
	@isTest static void testInsertQuestion() {
    Response__c response = new Response__c(Response_Text__c = 'Sample Response Text');
    insert response;
    RFP__c rfp = new RFP__c(Due_Date__c=Datetime.now());
    insert rfp;
    Question__c question = new Question__c(Question__c='Just trying for code coverage.',Response__c=response.Id,
                                           RFP__c=rfp.Id, Override_Warning__c=false);
    insert question;
	}
	
}