@isTest(SeeAllData=true)
private class LeadReferrerCompanyTriggerTest {

    static testMethod void leadUnitTest() {
        Account[] accnts = new Account[]{
    		new Account(Name = 'Test accnt1'),
    		new Account(Name = 'Test accnt2')
    	};
    	insert accnts;
    	Lead[] leads = new Lead[]{
    		new Lead(Referrer_Partner_ID__c = accnts[0].Id, LastName = 'TestLead1', Company = 'TestLead1'),
    		new Lead(Referrer_Partner_ID__c = accnts[1].Id, LastName = 'TestLead2', Company = 'TestLead2')
    	};
    	insert leads;
    	leads = [SELECT Id, Referrer_Partner_ID__c, Referrer_Partner_Company_2__c FROM Lead WHERE id IN :leads];
    	System.assertEquals(leads[0].Referrer_Partner_Company_2__c, accnts[0].Id);
    	System.assertEquals(leads[1].Referrer_Partner_Company_2__c, accnts[1].Id);
    }
}