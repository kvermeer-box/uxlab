/**
 * Helper methods for Marketing Activity Trigger
 *
 * @author Kyle Vermeer 5/22/14
 */
public class MarketingActivityTriggerHelper {
    
    public static void beforeInsert(List<Marketing_Activity__c> newValues) {
        populateAccountInsert(newValues);
    }

    public static void afterInsert(Map<Id, Marketing_Activity__c> newMap) {}

    public static void beforeUpdate(Map<Id, Marketing_Activity__c> oldMap, Map<Id, Marketing_Activity__c> newMap) {
        populateAccountUpdate(oldMap, newMap);
    }

    public static void afterUpdate(Map<Id, Marketing_Activity__c> oldMap, Map<Id, Marketing_Activity__c> newMap) {}

    public static void beforeDelete(Map<Id, Marketing_Activity__c> oldMap) {}

    public static void afterDelete(Map<Id, Marketing_Activity__c> oldMap) {}

    public static void afterUndelete(Map<Id, Marketing_Activity__c> newMap) {}

    /**
     * Populates the Account__c field on the Marketing Activity with the account of the connected contact
     *
     * @param {List<Marketing_Activity__c>} activities - Trigger.new
     */
    private static void populateAccountInsert(List<Marketing_Activity__c> activities) {
        populateAccount(activities);
    }

    /**
     * Populates the Account__c field on the Marketing Activity with the account of the connected contact
     *
     * @param {Map<Id,Marketing_Activity__c>} oldMap - Trigger.oldMap
     * @param {Map<Id,Marketing_Activity__c>} newMap - Trigger.newMap
     */
    private static void populateAccountUpdate(Map<Id, Marketing_Activity__c> oldMap, Map<Id, Marketing_Activity__c> newMap) {
        List<Marketing_Activity__c> activitiesToUpdate = new List<Marketing_Activity__c>();
        for (Marketing_Activity__c currentActivity : newMap.values()) {
            Marketing_Activity__c oldActivity = oldMap.get(currentActivity.Id);
            if (currentActivity.Contact__c != oldActivity.Contact__c) {
                activitiesToUpdate.add(currentActivity);
            }
        }
        populateAccount(activitiesToUpdate);
    }

    /**
     * Populates the Account__c field on the Marketing Activity with the account of the connected contact
     *
     * @param {List<Marketing_Activity__c>} activitiesToUpdate - activities that need their accounts updated
     */
    private static void populateAccount(List<Marketing_Activity__c> activitiesToUpdate) {
        if (activitiesToUpdate == null) { // Check for null inputs
            System.debug('null list of activitiesToUpdate provided.');
            return;
        }
        Set<Id> contact = new Set<Id>();
        for (Marketing_Activity__c currentActivity : activitiesToUpdate) {
            contact.add(currentActivity.Contact__c);
        }
        List<Contact> contactsRequeried = [SELECT Id, AccountId
                                             FROM Contact
                                            WHERE Id IN :contact];
        Map<Id, Contact> contactMap = new Map<Id, Contact>(contactsRequeried);
        // For each activity provided, set Account__c to the account of the contact
        for (Marketing_Activity__c currentActivity : activitiesToUpdate) {
            System.debug('Current Activity: ' + currentActivity);
            System.debug('Account: ' + currentActivity.Contact__r.AccountId);
            Contact currentContact = contactMap.get(currentActivity.Contact__c);
            Id accountId = null;
            if (currentContact != null) {
                accountId = currentContact.AccountId;
            }
            System.debug('Account: ' + accountId);
            currentActivity.Account__c = accountId;
        }
    }
}