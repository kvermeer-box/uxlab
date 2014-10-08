@isTest
private class LeadTriggerHandler_test {
    
    @isTest static void attachMarketingActivityFromConvertedLeads_basic() {
        // Implement test code
        Lead testLead = new Lead(LastName = 'LastNameTest', Company = 'CompanyTest');
        insert testLead;
        Marketing_Activity__c marketingActivity = new Marketing_Activity__c(Name = 'Test Activity', Lead__c = testLead.Id);
        insert marketingActivity;

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(testLead.Id);

        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess(),'Lead converted did not succeed');

        Marketing_Activity__c contactMarketingActivity = [SELECT Id, Name FROM Marketing_Activity__c WHERE Contact__c = :lcr.getContactId() LIMIT 1];
        System.assert(contactMarketingActivity != null, 'No marketing activity could be found for contact!');
        System.assertEquals(marketingActivity.Id, contactMarketingActivity.Id, 'Lead\'s marketing activity Id was different than the contact\'s marketing activity Id');
    }
    
}