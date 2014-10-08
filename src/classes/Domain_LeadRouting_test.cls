@isTest
private class Domain_LeadRouting_test {
    
    private static Account accountA;
    private static Account accountB;
    private static Account accountC;

    private static void setup() {

        Domain_Mapping_Settings__c domainMappingSettings = Domain_Mapping_Settings__c.getInstance();
        domainMappingSettings.Domain_Mapping_Turned_On__c = true;
        insert domainMappingSettings;

        // Black listed domains
        Domain_Matching_BlackList_Domain__c blackListedDomain1 = new Domain_Matching_BlackList_Domain__c(Name = 'Gmail', Domain__c = 'gmail.com');
        Domain_Matching_BlackList_Domain__c blackListedDomain2 = new Domain_Matching_BlackList_Domain__c(Name = 'Hotmail', Domain__c = 'Hotmail.com');
        insert new List<Domain_Matching_BlackList_Domain__c> { blackListedDomain1, blackListedDomain2 };

        // Accounts
        List<Account> accountList = new List<Account>();
        accountA = new Account(Name = 'Test Account A');
        accountB = new Account(Name = 'Test Account B');
        accountC = new Account(Name = 'Test Account C', Exclude_From_Domain_Mapping__c = true);
        accountList.add(accountA);
        accountList.add(accountB);
        accountList.add(accountC);
        insert accountList;

        Account_Domain__c domainA1 = new Account_Domain__c(Account__c = accountA.Id, Domain__c = 'vermeer.com', Reference_Count__c = 2);
        Account_Domain__c domainA2 = new Account_Domain__c(Account__c = accountA.Id, Domain__c = 'plutzer.net', Reference_Count__c = 1);
        Account_Domain__c domainA3 = new Account_Domain__c(Account__c = accountA.Id, Domain__c = 'gmail.com', Reference_Count__c = 1);

        Account_Domain__c domainB1 = new Account_Domain__c(Account__c = accountB.Id, Domain__c = 'schmidt.com', Reference_Count__c = 2);
        Account_Domain__c domainB2 = new Account_Domain__c(Account__c = accountB.Id, Domain__c = 'vermeer.com', Reference_Count__c = 1);
        Account_Domain__c domainB3 = new Account_Domain__c(Account__c = accountB.Id, Domain__c = 'wulff.xxx', Reference_Count__c = 69);
        Account_Domain__c domainB4 = new Account_Domain__c(Account__c = accountB.Id, Domain__c = 'plutzer.net', Reference_Count__c = 1);

        Account_Domain__c domainC1 = new Account_Domain__c(Account__c = accountC.Id, Domain__c = 'vermeer.com', Reference_Count__c = 5);

        insert new List<Account_Domain__c> { domainA1, domainA2, domainA3, domainB1, domainB2, domainB3, domainB4, domainC1 };
    }

    @isTest static void getBlackListedDomain_test() {
        
        // Populate Data
        setup();

        // Test black listed domain fetching
        Test.startTest();
        Set<String> blackListedDomains = Domain_Utilities.getBlackListedDomains();
        Test.stopTest();

        // Assertions
        System.assertEquals(2, blackListedDomains.size(), 'There should be two black listed domains.');
    }
    
    @isTest static void getAccountDomainMap_test() {

        // Populate Data
        setup();

        // Test Account Domain Map fetching
        Test.startTest();
        Set<String> domains = new Set<String> { 'vermeer.com', 'wulff.xxx', 'gmail.com'};
        Map<String, Account_Domain__c> domainMap = Domain_LeadRouting.getAccountDomainMap(domains);
        Map<String, Account_Domain__c> nullMap = Domain_LeadRouting.getAccountDomainMap(null);
        Test.stopTest();

        // Assertions
        Account_Domain__c vermeerDomain = domainMap.get('vermeer.com');
        System.assertNotEquals(null, vermeerDomain, 'This domain should have an associated account domain!');
        System.assertEquals(accountA.Id, vermeerDomain.Account__c, 'vermeer.com should be associated with account A!');
    }

    @isTest static void attachLeadsToAccounts_test() {

        // Populate Data
        setup();

        Lead lead1 = new Lead(LastName = 'Lead 1', Company = 'Company 1', Email = 'kvermeer@vermeer.com');
        Lead lead2 = new Lead(LastName = 'Lead 2', Company = 'Company 2', Email = 'alex@plutzer.net');
        Lead lead3 = new Lead(LastName = 'Lead 3', Company = 'Company 3', Email = 'sexyPapa88@gmail.com');
        Lead lead4 = new Lead(LastName = 'Lead 4', Company = 'Company 4', Email = 'wulffBoy@wulff.xxx', Account__c = accountC.Id);
        List<Lead> leadList = new List<Lead> { lead1, lead2, lead3, lead4 };
        insert leadList;

        // Test full routing
        Test.startTest();
        Domain_LeadRouting.attachLeadsToAccounts(leadList);
        Test.stopTest();

        lead1 = [SELECT Id, Account__c FROM Lead WHERE Id = :lead1.Id];
        lead2 = [SELECT Id, Account__c FROM Lead WHERE Id = :lead2.Id];
        lead3 = [SELECT Id, Account__c FROM Lead WHERE Id = :lead3.Id];
        lead4 = [SELECT Id, Account__c FROM Lead WHERE Id = :lead4.Id];

        //Assertions
        System.assertEquals(accountA.Id, lead1.Account__c, 'vermeer.com should have be associated to Account A!');
        System.assertEquals(null, lead3.Account__c, 'gmail.com should have no been associated with any account, it is blacklisted!');
        System.assertEquals(accountC.Id, lead4.Account__c, 'This lead already had an account, it should not have been considered for another account!');
    }
}