@isTest
private class QuotaUploadTriggerHelper_Test {


	@isTest static void testUploadQuota() {
	
	
		Quota_Upload__c qu = new Quota_Upload__c();
		qu.Employee_ID__c ='test';
		qu.Employee_Name__c = 'rob smith';
		qu.quota__c = 30000;
		qu.Start_Date__c = Date.newInstance(2015, 2, 1);
		qu.Manager__c = 'melissa jones';
		qu.Segment__c = 'channel';
		
		insert qu;
		
		
		update qu;	
		
	}
}