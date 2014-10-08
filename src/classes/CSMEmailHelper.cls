/**
 * CSMEMailHelper
 *
 * Description:
 *   Utility methods to help populate the CSMEmail field on Opportunities.
 *
 * Public API:
 *
 *   static void updateCSMEmail(List<Opportunity> opps)
 *   static void updateCSMEmailOfChildren(Map<Id,Account> oldMap, List<Account> newValues) 
 *
 * Revision History:
 *  
 *   Kyle Vermeer           2/4/2014        Initial Creation
 */
public class CSMEmailHelper {

    public static Integer iteration = 0;
    
    /**
     * Given a list of opps, updates their CSM_Email__c field based on the Account.
     *
     * @param {List<Opportunity>} opps - List of opps to be updated
     * @param {Boolean} shouldDMLUpdate - flag to determine if opps need a DML update
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    public static void updateCSMEmail(List<Opportunity> opps, Boolean shouldDMLUpdate) {
        if (opps == null || opps.size() <= 0) { // Check for null or empty input
            System.debug('Null or empty input. Opps: ' + opps);
            return;
        }
        System.debug('Iteration: ' + iteration);
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        // Get all Account Ids of parent accounts
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity currentOpp : opps) {
            accountIds.add(currentOpp.AccountId);
        }
        // Get parent accounts
        Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id, Customer_Success_Manager__r.Email, Customer_Success_Manager__c
                                                            FROM Account
                                                           WHERE Id IN :accountIds]);
        // For each opp, update CSM_Email__c field
        for (Opportunity currentOpp : opps) {
            Account currentAccount = accountMap.get(currentOpp.AccountId);
            System.debug('currentOpp Account: ' + currentAccount);
            if (currentAccount != null && currentAccount.Customer_Success_Manager__c != null) { // Parent has a CSM
                currentOpp.CSM_Email__c = currentAccount.Customer_Success_Manager__r.Email;
                oppsToUpdate.add(currentOpp);
            }
        }
        // DML update, if neccessary
        if (shouldDMLUpdate) {
            update oppsToUpdate;
        }
    }

    /**
     * Determines if the Customer_Success_Manager__c if any of the accounts has changed, if so, updates the CSM_Email__c
     * field of the opps.
     *
     * This is a trigger utility function, only to be called after update of Accounts.
     *
     * @param {Map<Id,Account>} oldMap - Trigger.oldMap
     * @param {List<Account>} newValues - Trigger.new
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    public static void updateCSMEmailOfChildren(Map<Id,Account> oldMap, List<Account> newValues) {
        // only go through one iteration
        if (iteration > 0) {
            System.debug('Past iteration one.  Iteration: ' + iteration);
            return;
        }
        System.debug('Entering updateCSMEmailOfChildren... ');
        if (oldMap == null || newValues == null) {
            System.debug('Null input. oldMap: ' + oldMap + '; newValues: ' + newValues);
            return;
        }
        // First find all accounts that had CSM changed
        Set<Id> accountsWithCSMChanged = new Set<Id>();
        for (Account currentAccount : newValues) {
            Account oldAccount = oldMap.get(currentAccount.Id);
            System.debug('old CSM: ' + oldAccount.Customer_Success_Manager__c + '; New CSM: ' + currentAccount.Customer_Success_Manager__c);
            if (currentAccount.Customer_Success_Manager__c != oldAccount.Customer_Success_Manager__c) { // CSM changed
                accountsWithCSMChanged.add(currentAccount.Id);
            }
        }

        if (accountsWithCSMChanged != null && accountsWithCSMChanged.size() >= 0) {
            List<Opportunity> oppsToHaveCSMChanged = [SELECT Id, CSM_Email__c, AccountId
                                                        FROM Opportunity
                                                       WHERE AccountId IN :accountsWithCSMChanged
                                                         AND isClosed = false];
            CSMEmailHelper.updateCSMEmail(oppsToHaveCSMChanged,true);
        }
        if (Trigger.isUpdate) {
            iteration += 1;
        }
    }
    
}