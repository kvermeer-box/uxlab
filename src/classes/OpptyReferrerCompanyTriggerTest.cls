@isTest(SeeAllData=true)
private class OpptyReferrerCompanyTriggerTest {

    static testMethod void opptyUnitTest() {
        Account[] accnts = new Account[]{
    		new Account(Name = 'Test accnt1'),
    		new Account(Name = 'Test accnt2')
    	};
    	insert accnts;
    	Opportunity[] opptys = new Opportunity[]{
    		new Opportunity(Referral_Partner_ID__c = accnts[0].Id, Name = 'TestOppty1', StageName = 'Test1', CloseDate = Date.today()),
    		new Opportunity(Referral_Partner_ID__c = accnts[1].Id, Name = 'TestOppty2', StageName = 'Test2', CloseDate = Date.today())
    	};
    	insert opptys;
    	opptys = [SELECT Id, Referral_Partner_ID__c, Referrer_Partner_Company_2__c FROM Opportunity WHERE id IN :opptys];
    	System.assertEquals(opptys[0].Referrer_Partner_Company_2__c, accnts[0].Id);
    	System.assertEquals(opptys[1].Referrer_Partner_Company_2__c, accnts[1].Id);
    }
}