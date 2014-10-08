/**
 * Test class for Domain_AccountDomainBatch
 */
@isTest
private class Domain_AccountDomainBatch_test {

    private static Account accountA;
    private static Account accountB;

    private static void setup() {

        Domain_Mapping_Settings__c domainMappingSettings = Domain_Mapping_Settings__c.getInstance();
        domainMappingSettings.Domain_Counting_Turned_On__c = true;
        insert domainMappingSettings;

         // Populate Data
        List<Account> accountList = new List<Account>();
        accountA = new Account(Name = 'Test Account A');
        accountB = new Account(Name = 'Test Account B');
        accountList.add(accountA);
        accountList.add(accountB);
        insert accountList;

        Contact contactA1 = new Contact(LastName = 'Vermeer', Email = 'kvermeer@vermeer.com', AccountId = accountA.Id);
        Contact contactA2 = new Contact(LastName = 'Vermeer', Email = 'svermeer@vermeer.com', AccountId = accountA.Id);
        Contact contactA3 = new Contact(LastName = 'Plutzer', Email = 'plutzer@plutzer.net', AccountId = accountA.Id);
        Contact contactA4 = new Contact(LastName = 'Wulff', Email = 'kwulff@wulff.org', AccountId = accountA.Id);

        Contact contactB1 = new Contact(LastName = 'Schmidt', Email = 'aschmidt@schmidt.com', AccountId = accountB.Id);
        Contact contactB2 = new Contact(LastName = 'Schmidt', Email = 'jschimdt@schmidt.com', AccountId = accountB.Id);
        Contact contactB3 = new Contact(LastName = 'Vermeer', Email = 'pvermeer@vermeer.com', AccountId = accountB.Id);

        insert new List<Contact> { contactA1, contactA2, contactA3, contactA4, contactB1, contactB2, contactB3 };

        Account_Domain__c domainA1 = new Account_Domain__c(Account__c = accountA.Id, Domain__c = 'vermeer.com', Reference_Count__c = 2);
        Account_Domain__c domainA2 = new Account_Domain__c(Account__c = accountA.Id, Domain__c = 'plutzer.net', Reference_Count__c = 1);

        Account_Domain__c domainB1 = new Account_Domain__c(Account__c = accountB.Id, Domain__c = 'schmidt.com', Reference_Count__c = 2);
        Account_Domain__c domainB2 = new Account_Domain__c(Account__c = accountB.Id, Domain__c = 'vermeer.com', Reference_Count__c = 1);
        Account_Domain__c domainB3 = new Account_Domain__c(Account__c = accountB.Id, Domain__c = 'wulff.xxx', Reference_Count__c = 69);

        insert new List<Account_Domain__c> { domainA1, domainA2, domainB1, domainB2, domainB3 };
    }
    
    @isTest static void createAccountDomainCountMap_test() {

        // Populate Data
        setup();

        // Create map
        Test.startTest();
        Domain_AccountDomainBatch accountDomainBatchClass = new Domain_AccountDomainBatch();
        List<Account> accountsQueried = [SELECT Id, (SELECT Id, Email FROM Contacts) FROM Account];
        Map<Id, Map<String, Integer>> accountToDomainCountMap = accountDomainBatchClass.createAccountDomainCountMap(accountsQueried);
        Test.stopTest();

        // Test map for account A
        Map<String, Integer> domainCountMapA = accountToDomainCountMap.get(accountA.Id);
        System.assertNotEquals(null, domainCountMapA, 'There should be an entry for accountA');
        System.assertEquals(2, domainCountMapA.get('vermeer.com'), 'There should be 2 entries for this domain!');
        System.assertEquals(1, domainCountMapA.get('plutzer.net'), 'There should be 1 entry for this domain!');

        // Test map for account B
        Map<String, Integer> domainCountMapB = accountToDomainCountMap.get(accountB.Id);
        System.assertNotEquals(null, domainCountMapB, 'There should be an entry for accountB');
        System.assertEquals(2, domainCountMapB.get('schmidt.com'), 'There should be 2 entries for this domain!');
        System.assertEquals(1, domainCountMapB.get('vermeer.com'), 'There should be 1 entry for this domain!');
    }

    @isTest static void getAccountDomainMap_test() {
        
        // Populate Data
        setup();

        // Create map
        Test.startTest();
        Domain_AccountDomainBatch accountDomainBatchClass = new Domain_AccountDomainBatch();
        Map<Id, Map<String, Account_Domain__c>> accountToAccountDomainMap = accountDomainBatchClass.getAccountDomainMap(new Set<Id> { accountA.Id, accountB.Id });
        Test.stopTest();

        // Test map for account A
        Map<String, Account_Domain__c> accountDomainMapA = accountToAccountDomainMap.get(accountA.Id);
        System.assertNotEquals(null, accountDomainMapA, 'There should be an entry for accountA');
        Account_Domain__c vermeerDomainA = accountDomainMapA.get('vermeer.com');
        System.assertEquals(2, vermeerDomainA.Reference_Count__c, 'There should be 2 entries for this domain!');
        Account_Domain__c plutzerDomainA = accountDomainMapA.get('plutzer.net');
        System.assertEquals(1, plutzerDomainA.Reference_Count__c, 'There should be 1 entry for this domain!');

        // Test map for account B
        Map<String, Account_Domain__c> accountDomainMapB = accountToAccountDomainMap.get(accountB.Id);
        System.assertNotEquals(null, accountDomainMapB, 'There should be an entry for accountA');
        Account_Domain__c schmidtDomainB = accountDomainMapB.get('schmidt.com');
        System.assertEquals(2, schmidtDomainB.Reference_Count__c, 'There should be 2 entries for this domain!');
        Account_Domain__c vermeerDomainB = accountDomainMapB.get('vermeer.com');
        System.assertEquals(1, vermeerDomainB.Reference_Count__c, 'There should be 1 entry for this domain!');
    }

    @isTest static void getChangedAccountDomains_test() {

        // Populate data
        setup();
        
        // Find changed domains
        Test.startTest();
        Domain_AccountDomainBatch accountDomainBatchClass = new Domain_AccountDomainBatch();
        List<Account> accountsQueried = [SELECT Id, (SELECT Id, Email FROM Contacts) FROM Account];
        Map<Id, Map<String, Integer>> accountToDomainCountMap = accountDomainBatchClass.createAccountDomainCountMap(accountsQueried);
        Map<Id, Map<String, Account_Domain__c>> accountToAccountDomainMap = accountDomainBatchClass.getAccountDomainMap(new Set<Id> { accountA.Id, accountB.Id });
        List<Account_Domain__c> changedDomains = accountDomainBatchClass.getChangedAccountDomains(accountToAccountDomainMap, accountToDomainCountMap);
        Test.stopTest();

        // Check how many were changed
        System.assertEquals(1, changedDomains.size(), 'There should be 1 entries that were changed!');
    }

    @isTest static void getAccountDomainsToDelete_test() {

        // Populate data
        setup();

        // Find deleted domains
        Test.startTest();
        Domain_AccountDomainBatch accountDomainBatchClass = new Domain_AccountDomainBatch();
        List<Account> accountsQueried = [SELECT Id, (SELECT Id, Email FROM Contacts) FROM Account];
        Map<Id, Map<String, Integer>> accountToDomainCountMap = accountDomainBatchClass.createAccountDomainCountMap(accountsQueried);
        Map<Id, Map<String, Account_Domain__c>> accountToAccountDomainMap = accountDomainBatchClass.getAccountDomainMap(new Set<Id> { accountA.Id, accountB.Id });
        List<Account_Domain__c> deletedDomains = accountDomainBatchClass.getAccountDomainsToDelete(accountToAccountDomainMap, accountToDomainCountMap);
        Test.stopTest();

        // Check how many were deleted
        System.assertEquals(1, deletedDomains.size(), 'There should be 1 entries that were deleted!');
    }

    @isTest static void testBatch_test() {

        // Populate data
        setup();

        Test.startTest();
        Domain_AccountDomainBatch accountDomainBatchClass = new Domain_AccountDomainBatch();
        Database.executeBatch(accountDomainBatchClass);
        Test.stopTest();

        List<Account_Domain__c> accountDomains = [SELECT Id, Reference_Count__c, Domain__c, Account__r.Name, isDeleted FROM Account_Domain__c];
        System.debug('Account Domains: ' + accountDomains);
        System.assertEquals(5, accountDomains.size(), 'Only 5 account domains should remain');
    }

}