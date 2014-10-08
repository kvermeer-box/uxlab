/**
 * SubsidiaryAccountCounter
 *
 * Description:
 *   This class contains logic for calculating the subsidiary counts for accounts.
 *   It finds extracts accounts that should have their subsidiary counts changed,
 *   then recounts the number of subsidiaries and updates the accounts.
 *
 * Public API:
 *
 *   static void markParentAccountsForSubsidiaryRecount(Map<Id,Account> oldMap, List<Account> newValues, Boolean isUpdate)
 *   static void recalculateSubsidiaryCount(Map<Id,Account> oldMap, List<Account> newValues)
 *
 * Revision History:
 *
 *   Kyle Vermeer           1/22/2014           Intial Creation
 *   Kyle Vermeer           2/3/2014            Look at Billing_Theater__c instead of Theater__c. 'NA' instead of 'NATAM'
 *   Kyle Vermeer           2/20/2014           Only count subsids with Account_hierarchy__c set to Subsidiary
 */

public class SubsidiaryAccountCounter {

    /* Constants */
    private static final String NA = 'NA';
    private static final String EMEA = 'EMEA';
    private static final String APAC = 'APAC';
    private static final String LATAM = 'LATAM';


    /* Public API */

    /**
     * Method: markParentAccoutnsForSubsidiaryRecount()
     * Availability: public, static
     * Description:
     *   Sets Recalculate_Subsidiary_Counts__c to true on all accounts that need to have their
     *   subsidiary counts updated.
     * Inputs:
     *   Map<Id,Account> oldMap - Trigger.oldMap
     *   List<Account> newValues - Trigger.new
     *   Boolean isUpdate - Trigger.isUpdate
     * Return:
     *   None
     */
    public static void markParentAccountsForSubsidiaryRecount(Map<Id,Account> oldMap, List<Account> newValues, Boolean isUpdate) {
        Set<Id> accountsToMark = new Set<Id>();
        if (isUpdate) {
            // Get parent accounts of that need to have their subsids recalced
            accountsToMark = getParentAccountsThatNeedSubsidaryRecalculationUpdate(oldMap,newValues);
        }
        else { // Insertion or Deletion
            if (oldMap == null) { // Insertion
                // Get parent acoounts that need to ahve their subsids recalced
                accountsToMark = getParentAccountsThatNeedSubsidaryRecalculationInsertDelete(newValues);
            }
            else { // Deletion
                // Get parent acoounts that need to ahve their subsids recaled
                accountsToMark = getParentAccountsThatNeedSubsidaryRecalculationInsertDelete(oldMap.values());
            }
        }
        markParentAccounts(accountsToMark);
    }

    /**
     * Method: recalculateSubsidiaryCount()
     * Availability: public, static
     * Description:
     *   Checks if Recalculate_Subsidiary_Counts__c is true on provided accounts.  If so,
     *   this method recounts the subsidiary counts of those accounts and updates them.
     * Inputs:
     *   Map<Id,Account> oldMap - Trigger.oldMap
     *   List<Account> newValues - Trigger.new
     * Return:
     *   None
     */
    public static void recalculateSubsidiaryCount(Map<Id,Account> oldMap, List<Account> newValues) {
        // Get accounts that should be recalculated
        List<Account> accountsToRecalculate = getAccountsToRecalculate(newValues);
        // Recalculate
        calculateSubsidiaryCount(accountsToRecalculate);
    }


    /* Private Methods */

    /* Returns a list of accounts (from the given list of accounts) that have Recalculate_Subsidiary_Counts__c 
       set to true */
    private static List<Account> getAccountsToRecalculate(List<Account> accounts) {
        List<Account> accountsToRecalculate = new List<Account>();
        if (accounts == null) { // Check for null input
            System.debug('Null input. accounts: ' + accounts);
            return accountsToRecalculate;
        }
        // Check each account for flag
        for (Account currentAccount : accounts) {
            if (currentAccount.Recalculate_Subsidiary_Counts__c) {
                accountsToRecalculate.add(currentAccount);
            }
        }
        return accountsToRecalculate;
    }

    /* Given a list of accounts, recalculates their subsidiary count fields */
    private static void calculateSubsidiaryCount(List<Account> accounts) {
        Map<Id,Account> accountMap = new Map<Id,Account>();
        if (accounts == null || accounts.size() <= 0) { // Check for null or empty input
            System.debug('Null or empty input. accounts: ' + accounts);
            return;
        }
        for (Account currentAccount : accounts) {
            accountMap.put(currentAccount.Id,currentAccount);
        }
        List<Account> subsidiaryAccounts = [SELECT Id, parentId, Billing_Theater__c, Subsidiary_Count_NA__c, Subsidiary_Count_APAC__c,
                                                   Subsidiary_Count_EMEA__c, Subsidiary_Count_LATAM__c, Subsidiary_Count_Misc__c
                                              FROM Account
                                             WHERE parentId IN :accountMap.keyset()
                                               AND Account_hierarchy__c = 'Subsidiary'];
        // Map from parentId to subsidiary accounts
        Map<Id,List<Account>> parentToSubsidiaryMap = new Map<Id,List<Account>>();
        for (Account currentSubsidiaryAccount : subsidiaryAccounts) {
            List<Account> subsidiaryAccountsForParent = parentToSubsidiaryMap.get(currentSubsidiaryAccount.parentId);
            if (subsidiaryAccountsForParent == null) { // If list doesn't exist, make it!
                subsidiaryAccountsForParent = new List<Account>();
                parentToSubsidiaryMap.put(currentSubsidiaryAccount.parentId,subsidiaryAccountsForParent);
            }
            subsidiaryAccountsForParent.add(currentSubsidiaryAccount);
        }

        // For each parent account, count up subsidiary accounts into their theater buckets
        for (Id parentAccountId : accountMap.keySet()) {
            Account parentAccount = accountMap.get(parentAccountId);
            Integer subsidsNA = 0, subsidsEMEA = 0, subsidsAPAC = 0, subsidsLATAM = 0, subsidsMisc = 0;
            // Go through each subsidiary account and add count to correct bucket
            List<Account> subsidiaryAccountsForParent = parentToSubsidiaryMap.get(parentAccountId);
            if (subsidiaryAccountsForParent != null) {
                for (Account currentSubsidiaryAccount: subsidiaryAccountsForParent) {
                    // First add count on subsids (recursive count)
                    // Need to make sure subsid counts aren't null
                    if (currentSubsidiaryAccount.Subsidiary_Count_NA__c == null) {
                        currentSubsidiaryAccount.Subsidiary_Count_NA__c = 0;
                    }
                    subsidsNA += (Integer) currentSubsidiaryAccount.Subsidiary_Count_NA__c;
                    if (currentSubsidiaryAccount.Subsidiary_Count_EMEA__c == null) {
                        currentSubsidiaryAccount.Subsidiary_Count_EMEA__c = 0;
                    }
                    subsidsEMEA += (Integer) currentSubsidiaryAccount.Subsidiary_Count_EMEA__c;
                    if (currentSubsidiaryAccount.Subsidiary_Count_APAC__c == null) {
                        currentSubsidiaryAccount.Subsidiary_Count_APAC__c = 0;
                    }
                    subsidsAPAC += (Integer) currentSubsidiaryAccount.Subsidiary_Count_APAC__c;
                    if (currentSubsidiaryAccount.Subsidiary_Count_LATAM__c == null) {
                        currentSubsidiaryAccount.Subsidiary_Count_LATAM__c = 0;
                    }
                    subsidsLATAM += (Integer) currentSubsidiaryAccount.Subsidiary_Count_LATAM__c;
                    if (currentSubsidiaryAccount.Subsidiary_Count_Misc__c == null) {
                        currentSubsidiaryAccount.Subsidiary_Count_Misc__c = 0;
                    }
                    subsidsMisc += (Integer) currentSubsidiaryAccount.Subsidiary_Count_Misc__c;

                    // Then add current account into correct category
                    if (currentSubsidiaryAccount.Billing_Theater__c == NA) {
                        subsidsNA += 1;
                    }
                    else if (currentSubsidiaryAccount.Billing_Theater__c == EMEA) {
                        subsidsEMEA += 1;
                    }
                    else if (currentSubsidiaryAccount.Billing_Theater__c == APAC) {
                        subsidsAPAC += 1;
                    }
                    else if (currentSubsidiaryAccount.Billing_Theater__c == LATAM) {
                        subsidsLATAM += 1;
                    } 
                    else {
                        subsidsMisc += 1;
                    }
                }
            }
            parentAccount.Subsidiary_Count_NA__c = subsidsNA;
            parentAccount.Subsidiary_Count_EMEA__c = subsidsEMEA;
            parentAccount.Subsidiary_Count_APAC__c = subsidsAPAC;
            parentAccount.Subsidiary_Count_LATAM__c = subsidsLATAM;
            parentAccount.Subsidiary_Count_Misc__c = subsidsMisc;
            parentAccount.Recalculate_Subsidiary_Counts__c = false;
            System.debug('Parent Account: ' + parentAccount);
        }
    }

    /* Gets ids of all accounts that have either had a child added or removed.  Looks at parentId of provided accounts. */
    private static Set<Id> getParentAccountsThatNeedSubsidaryRecalculationUpdate(Map<Id,Account> oldMap, List<Account> newValues) {
        Set<Id> parentAccountIds = new Set<Id>();
        if (newValues == null || oldMap == null) { // Check for null inputs
            System.debug('Null input.  oldMap: ' + oldMap + '; newValues: ' + newValues);
            return parentAccountIds;
        }
        // Find all accounts with changed parentId
        for (Account currentAccount : newValues) {
            Account oldAccount = oldMap.get(currentAccount.Id);
            if (oldAccount == null) {
                System.debug('Couldn\'t find old account!');
                continue;
            }
            System.debug('Current Theater: ' + currentAccount.Billing_Theater__c + '; Old Theater: ' + oldAccount.Billing_Theater__c);
            if (currentAccount.parentId != oldAccount.parentId) { // Account Id has changed
                // Both, or just one parentId can be added.  Avoiding adding null to the set
                if (currentAccount.parentId != null) { // Add current accounts parentId
                    parentAccountIds.add(currentAccount.parentId);
                }
                if (oldAccount.parentId != null) { // Add old accounts parentId
                    parentAccountIds.add(oldAccount.parentId);
                }
            } 
            // Also if the accounts subsidiary counts have changed and the account has a parent
            else if (currentAccount.parentId != null &&
                        (currentAccount.Subsidiary_Count_NA__c != oldAccount.Subsidiary_Count_NA__c ||
                         currentAccount.Subsidiary_Count_EMEA__c != oldAccount.Subsidiary_Count_EMEA__c ||
                         currentAccount.Subsidiary_Count_APAC__c != oldAccount.Subsidiary_Count_APAC__c ||
                         currentAccount.Subsidiary_Count_LATAM__c != oldAccount.Subsidiary_Count_LATAM__c
                        )
                    ) {
                parentAccountIds.add(currentAccount.parentId);
            }
            // Finally, if Theater changed and it has a parent
            else if (currentAccount.parentId != null && currentAccount.Billing_Theater__c != oldAccount.Billing_Theater__c) {
                parentAccountIds.add(currentAccount.parentId);
            } else {
                System.debug('Checked everything!');
            }
        }
        return parentAccountIds;
    }

    /* Gets the ids of all accounts that have had a child inserted or deleted. Looks at the parentId of provided accounts. */
    private static Set<Id> getParentAccountsThatNeedSubsidaryRecalculationInsertDelete(List<Account> accounts) {
        System.debug('Accounts: ' + accounts);
        Set<Id> parentAccountIds = new Set<Id>();
        if (accounts == null) { // Check for null input
            System.debug('Null input. Accounts: ' + accounts);
            return parentAccountIds;
        }
        /* Add all non-null parentIds for inserted or deleting accounts. */
        for (Account currentAccount : accounts) {
            if (currentAccount.parentId != null) { // Don't add null ids to set
                parentAccountIds.add(currentAccount.parentId);
            }
        }
        return parentAccountIds;
    }

    /* Sets Recalculate_Subsidiary_Counts__c to true on all provided accounts. */
    private static void markParentAccounts(Set<Id> accountsToMark) {
        if (accountsToMark == null || accountsToMark.size() <= 0) {
            System.debug('Null or empty set provided. accountsToMark: ' + accountsToMark);
            return;
        }
        try {


            List<Account> accounts = [SELECT Id, Recalculate_Subsidiary_Counts__c
                                        FROM Account
                                       WHERE Id in :accountsToMark];
            if (accounts == null || accounts.size() <= 0) { // Trouble Querying
                System.debug('Queried accounts null or empty, despite being provided some ids. Accounts: ' + accounts);
                return;
            }
            for (Account currentAccount : accounts) {
                currentAccount.Recalculate_Subsidiary_Counts__c = true;
            }
            System.debug('MARKED: ' + accounts);
            update accounts;
        } catch (Exception e) {
            // TODO: Grab LoggedException from production!
            /*LoggedException le = new LoggedException(e,'Trouble querying or inserting accounts for subsidiary recalculation.',
                                                    'SubsidaryAccountCounter',new List<Id>(accountsToMark));
            */

        }
    }


}