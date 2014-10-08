@isTest
private class MarketingActivityTriggerHelper_test
{
    @isTest
    static void populateAccount_test()
    {
        //Test insert
        Account testAccount = new Account(Name = 'KV Test Account');
        insert testAccount;

        Contact testContact = new Contact(LastName = 'Test Last Name', AccountId = testAccount.Id);
        insert testContact;

        Marketing_Activity__c marketingActivity = new Marketing_Activity__c(Name = 'Test Activity', Contact__c = testContact.Id);
        insert marketingActivity;

        Marketing_Activity__c requeriedActivity = [SELECT Id, Account__c
                                                    FROM Marketing_Activity__c
                                                   WHERE Id = :marketingActivity.Id];

        System.assertEquals(testAccount.Id, requeriedActivity.Account__c);

        // Test update
        Account otherAccount = new Account(Name = 'Other KV Test Account');
        insert otherAccount;

        Contact otherContact = new Contact(LastName = 'Other Test Last Name', AccountId = otherAccount.Id);
        insert otherContact;

        marketingActivity.Contact__c = otherContact.id;
        update marketingActivity;

        Marketing_Activity__c requeriedActivitySecond = [SELECT Id, Account__c
                                                           FROM Marketing_Activity__c
                                                          WHERE Id = :marketingActivity.Id];

        System.assertEquals(otherAccount.Id, requeriedActivitySecond.Account__c);
    }
}