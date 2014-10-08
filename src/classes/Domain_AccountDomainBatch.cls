/**
 * Batch class to create and update Account_Domain__c to correctly reflect domain counts per Account
 *
 * @author Kyle Vermeer 6/19/14
 */
public class Domain_AccountDomainBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {

    public Integer summaryCount;
    public Integer deletionCount;

    //////////////////////
    // BATCHABLE
    //////////////////////


    String query;

    public Domain_AccountDomainBatch() {
        query = 'SELECT Id FROM Account';
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        this.summaryCount = 0;
        this.deletionCount = 0;
        return Database.getQueryLocator(query);
    }

   public void execute(Database.BatchableContext BC, List<sObject> scope) {

        // Don't run if Domain Counting is turned off
        if (!Domain_Mapping_Settings__c.getInstance().Domain_Counting_Turned_On__c) {
            System.debug('Domain Counting is turned off!');
            return;
        }
        // First count accounts and domains
        Map<Id, Map<String, Integer>> accountDomainCountMap = createAccountDomainCountMap((List<Account>) scope);
        // Then query for the old Account_Domains__c's
        Map<Id, Map<String,Account_Domain__c>> oldAccountDomainCountMap = getAccountDomainMap(accountDomainCountMap.keySet());
        // Finally find the delta
        List<Account_Domain__c> accountDomainsForUpsert = getChangedAccountDomains(oldAccountDomainCountMap, accountDomainCountMap);
        if (!accountDomainsForUpsert.isEmpty()) {
            upsert accountDomainsForUpsert;
        }
        List<Account_Domain__c> accountDomainsToDelete = getAccountDomainsToDelete(oldAccountDomainCountMap, accountDomainCountMap);
        if (!accountDomainsToDelete.isEmpty()) {
            System.debug('Deleting: ' + accountDomainsToDelete);
            delete accountDomainsToDelete;
        }
        this.summaryCount += accountDomainsForUpsert.size();
        this.deletionCount += accountDomainsToDelete.size();
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('Summary Count: ' + this.summaryCount);
        System.debug('Deletion Count: ' + this.deletionCount);
        // Clean up Account_Domain__c's with no Account
        Domain_CleanUp cleanUpBatch = new Domain_CleanUp();
        Database.executeBatch(cleanUpBatch);
    }

    //////////////////////
    // SCHEDULEABLE
    //////////////////////

    public void execute(SchedulableContext sc) {
        Domain_AccountDomainBatch batchClass = new Domain_AccountDomainBatch();
        Database.executeBatch(batchClass);
    }

    ///////////////////////
    // Private Methods
    ///////////////////////

    /**
     * This method creates a map from account ids to a (map of domains to domain counts)
     *
     * @param {List<Account>} accounts - the accounts to have their domains counted, must have contacts queried
     * @return {Map<Id, Map<String, Integer>>} - a map from account ids to a (map of domains to domain counts)
     */
    @TestVisible
    private Map<Id, Map<String, Integer>> createAccountDomainCountMap(List<Account> accounts) {
        Map<Id, Map<String, Integer>> accountDomainCountMap = new Map<Id, Map<String, Integer>>();
        if (accounts == null || accounts.isEmpty()) { // Check input
            System.debug('Accounts null or empty: ' + accounts);
            return accountDomainCountMap;
        }
        List<Contact> contacts = [SELECT Id, Email, AccountId FROM Contact WHERE AccountId IN :accounts];
        Map<Id, List<Contact>> accountIdToContacts= new Map<Id, List<Contact>>();
        for (Contact currentContact : contacts) {
            List<Contact> contactsForAccount = accountIdToContacts.get(currentContact.AccountId);
            if (contactsForAccount == null) {
                contactsForAccount = new List<Contact>();
                accountIdToContacts.put(currentContact.AccountId, contactsForAccount);
            }
            contactsForAccount.add(currentContact);
        }
        for (Account curAccount : accounts) { // For each account
            // Create a map from domain to domain count
            Map<String, Integer> domainCountsForAccount = new Map<String, Integer>();
            accountDomainCountMap.put(curAccount.Id, domainCountsForAccount);
            List<Contact> contactsForAccount = accountIdToContacts.get(curAccount.Id);
            // No contacts for Account
            if (contactsForAccount == null) {
                continue;
            }
            // Now go through all the contacts, and count their domain in the domain count map
            for (Contact curContact : contactsForAccount) { // for each contact on that account
                // Populate domain counts maps
                String fullDomain = Domain_Utilities.getFullDomain(curContact.Email);
                String baseDomain = Domain_Utilities.getBaseDomain(curContact.Email);
                if (fullDomain != baseDomain) { // Only count either the full domain or the base
                    // Get count for domain
                    Integer countForDomain = domainCountsForAccount.get(fullDomain);
                    if (countForDomain == null) { // If an entry doesn't exist yet, create it!
                        countForDomain = 0;
                    }
                    // Increment current entry
                    countForDomain = countForDomain + 1;
                    domainCountsForAccount.put(fullDomain, countForDomain);
                }
                else if (baseDomain != null) {
                    // Get count for domain
                    Integer countForDomain = domainCountsForAccount.get(baseDomain);
                    if (countForDomain == null) { // If an entry doesn't exist yet, create it!
                        countForDomain = 0;
                    }
                    // Increment current entry
                    countForDomain =  countForDomain + 1;
                    domainCountsForAccount.put(baseDomain, countForDomain);
                }
            }
        }
        return accountDomainCountMap;
    }

    /**
     * This method creates a map from account ids to a (map of domains to Account_Domain__c)
     *
     * @param {Set<Id>} accountIds - set of ids for accounts from which to grab domains
     * @return {Map<Id, Map<String, Account_Domain__c>>} - Map from account ids to a (map of domains to Account_Domain__c)
     */
     @TestVisible
     private Map<Id, Map<String, Account_Domain__c>> getAccountDomainMap(Set<Id> accountIds) {
        Map<Id, Map<String, Account_Domain__c>> oldAccountDomainCountMap = new Map<Id, Map<String, Account_Domain__c>>();
        if (accountIds == null || accountIds.isEmpty()) {
            System.debug('Account ids to search for is null or empty: ' + accountIds);
            return oldAccountDomainCountMap;
        }
        List<Account_Domain__c> oldAccountDomains = [SELECT Id, Account__c, Domain__c, Reference_Count__c
                                                       FROM Account_Domain__c
                                                      WHERE Account__c IN :accountIds];
        oldAccountDomainCountMap = new Map<Id, Map<String, Account_Domain__c>>();
        for (Account_Domain__c oldAccountDomain : oldAccountDomains) {
            Map<String, Account_Domain__c> domainsForAccountMap = oldAccountDomainCountMap.get(oldAccountDomain.Account__c);
            if (domainsForAccountMap == null) {
                domainsForAccountMap = new Map<String, Account_Domain__c>();
                oldAccountDomainCountMap.put(oldAccountDomain.Account__c, domainsForAccountMap);
            }
            domainsForAccountMap.put(oldAccountDomain.Domain__c, oldAccountDomain);
        }
        return oldAccountDomainCountMap;
     }

    /**
     * This method gathers a list of Account_Domain__c's that either need to be insert or updated to reflect current domain counts
     *
     * @param {Map<Id, Map<String, Account_Domain__c>>} oldAccountDomains - Map from Account ids to (map from domains to Account Domains) that currently exist in the system
     * @param {Map<Id, Map<String, Integer>>} newAccountDomains - Map from Account ids to (map from domains to domain count) that are what should currently be set
     * @return {List<Account_Domain__c>} - Account_Domain__c that need to be updated or inserted
     */
    @TestVisible
    private List<Account_Domain__c> getChangedAccountDomains(Map<Id, Map<String, Account_Domain__c>> oldAccountDomains, Map<Id, Map<String, Integer>> newAccountDomainCounts) {
        List<Account_Domain__c> accountDomainsToUpsert = new List<Account_Domain__c>();
        for (Id currentAccountId : newAccountDomainCounts.keySet()) {
            Map<String, Account_Domain__c> oldDomainMappingsForAccount = oldAccountDomains.get(currentAccountId);
            Map<String, Integer> newDomainCountsForAccount = newAccountDomainCounts.get(currentAccountId);
            if (oldDomainMappingsForAccount == null) {
                for (String currentDomain : newDomainCountsForAccount.keySet()) {
                    Account_Domain__c accountDomain = new Account_Domain__c(Account__c = currentAccountId, Domain__c = currentDomain, Reference_Count__c = newDomainCountsForAccount.get(currentDomain));
                    accountDomainsToUpsert.add(accountDomain);
                }
            }
            else {
                for (String currentDomain : newDomainCountsForAccount.keySet()) {
                    Account_Domain__c oldAccountDomain = oldDomainMappingsForAccount.get(currentDomain);
                    Integer newDomainCount = newDomainCountsForAccount.get(currentDomain);
                    if (oldAccountDomain == null) {
                        Account_Domain__c newAccountDomain = new Account_Domain__c(Account__c = currentAccountId, Domain__c = currentDomain, Reference_Count__c = newDomainCountsForAccount.get(currentDomain));
                        accountDomainsToUpsert.add(newAccountDomain);
                    }
                    else if (oldAccountDomain.Reference_Count__c != newDomainCount) {
                        oldAccountDomain.Reference_Count__c = newDomainCount;
                        accountDomainsToUpsert.add(oldAccountDomain);
                    }
                }
            }
        }
        return accountDomainsToUpsert;
    }

    /**
     * This method gathers a list of Account_Domain__c's that either need to be deleted
     *
     * @param {Map<Id, Map<String, Account_Domain__c>>} oldAccountDomains - Map from Account ids to (map from domains to Account Domains) that currently exist in the system
     * @param {Map<Id, Map<String, Integer>>} newAccountDomains - Map from Account ids to (map from domains to domain count) that are what should currently be set
     * @return {List<Account_Domain__c>} - Account_Domain__c that need to be deleted
     */
    @TestVisible
    private List<Account_Domain__c> getAccountDomainsToDelete(Map<Id, Map<String, Account_Domain__c>> oldAccountDomains, Map<Id, Map<String, Integer>> newAccountDomainCounts) {
        List<Account_Domain__c> accountDomainsToDelete = new List<Account_Domain__c>();
        for (Id oldAccountId : oldAccountDomains.keyset()) {
            Map<String, Account_Domain__c> oldDomainMappingsForAccount = oldAccountDomains.get(oldAccountId);
            Map<String, Integer> newDomainCountsForAccount = newAccountDomainCounts.get(oldAccountId);
            if (newDomainCountsForAccount == null) {
                accountDomainsToDelete.addAll(oldDomainMappingsForAccount.values());
            }
            else {
                for (String currentDomain : oldDomainMappingsForAccount.keySet()) {
                    Integer newDomainCount = newDomainCountsForAccount.get(currentDomain);
                    Account_Domain__c oldAccountDomain = oldDomainMappingsForAccount.get(currentDomain);
                    if (newDomainCount == null || newDomainCount == 0) {
                        accountDomainsToDelete.add(oldAccountDomain);
                    }
                }
            }
        }
        return accountDomainsToDelete;
    }
}