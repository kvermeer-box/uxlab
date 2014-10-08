@isTest(onInstall=True)
private class TestDiscOrgOwnerFix {

    static testMethod void TestOwnerFix() {
        User usr = new User(Alias = 'talias', Email = 'test999@xyzzy.com', FirstName='Joe', LastName= 'testname',  TimeZoneSidKey = 'America/Los_Angeles', UserName = 'test999@testxyzzy.com', UserPermissionsMarketingUser=true,    LocaleSidKey='en_US', EmailEncodingKey='UTF-8', LanguageLocaleKey = 'en_US');
        usr.ProfileID = UserInfo.getProfileId();
        insert usr;
        
		DiscOrgOwnerSetting__c config = DiscOrgOwnerSetting__c.getInstance('default');
		if(config==null) 
		{
			config = new DiscOrgOwnerSetting__c();
			config.name = 'default';
		}
		config.OwnerIds__c = usr.id;
		
		Database.Upsert(config);

        Account testaccount = new Account(Name= 'testact1');
        testaccount.BillingCountry = 'United States';
        insert testaccount;
        
		// Owner is the Hoover API user
        Contact ct = new Contact(LastName = 'testlastname', OwnerID=usr.id, AccountID = testaccount.id);
		Test.StartTest();
		insert ct;
		Test.StopTest();
		
		// Make sure owner has been reassigned to account owner (which is current user)
		Contact ctres = [SELECT ID, OwnerID from Contact where id = :ct.id];
		System.AssertEquals(UserInfo.getUserId(), ctres.OwnerID);        
        
    }
}