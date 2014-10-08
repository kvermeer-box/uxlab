/**
 * Test class from Domain_CleanUp
 *
 * @author Kyle Vermeer 7/3/14
 */
@isTest
private class Domain_CleanUp_test {

    @isTest static void cleanUp_test() {

        // Populate Data
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Account_Domain__c accDomainWithAccount = new Account_Domain__c(Account__c = acc.Id, Domain__c = 'apple.com', Reference_Count__c = 1);
        insert accDomainWithAccount;
        Account_Domain__c accDomain = new Account_Domain__c(Domain__c = 'box.com', Reference_Count__c = 2);
        insert accDomain;

        // Test
        Test.startTest();
        Domain_CleanUp cleanUpBatch = new Domain_CleanUp();
        Database.executeBatch(cleanUpBatch);
        Test.stopTest();

        // Assertions
        List<Account_Domain__c> accountDomains = [SELECT Id FROM Account_Domain__c];
        System.assertEquals(1, accountDomains.size(), 'Only one domain has an account, so only one should remain!');
    }
}