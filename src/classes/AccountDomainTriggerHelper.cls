public class AccountDomainTriggerHelper {

    ///////////////////////////////
    // Trigger Handling Methods
    ///////////////////////////////

    /**
     * Before insert trigger functionality
     *
     * @param {List<Account_Domain__c>} Account_Domain__cList - Trigger.new
     */
    public static void beforeInsert(List<Account_Domain__c> accountDomainList) {}

    /**
     * After insert trigger functionality
     *
     * @param {List<Account_Domain__c>} newMap - Trigger.newMap
     */
    public static void afterInsert(Map<Id,Account_Domain__c> newMap) {}

    /**
     * Before update trigger funcionality
     *
     * @param {Map<Id,Account_Domain__c>} oldMap - Trigger.oldMap
     * @param {Map<Id,Account_Domain__c>} newMap - Trigger.newMap
     */
    public static void beforeUpdate(Map<Id,Account_Domain__c> oldMap,
                                    Map<Id,Account_Domain__c> newMap) {}

    /**
     * After update trigger functionality
     *
     * @param {Map<Id,Account_Domain__c>} oldMap - Trigger.oldMap
     * @param {Map<Id,Account_Domain__c>} newMap - Trigger.newMap
     */
    public static void afterUpdate(Map<Id,Account_Domain__c> oldMap,
                                   Map<Id,Account_Domain__c> newMap) {}

    /**
     * Before delete trigger functionality
     *
     * @param {Map<Id,Account_Domain__c>} oldMap - Trigger.oldMap
     */
    public static void beforeDelete(Map<Id,Account_Domain__c> oldMap) {}

    /**
     * After delete trigger functionality
     *
     * @param {Map<Id,Account_Domain__c>} oldMap - Trigger.oldMap
     */
    public static void afterDelete(Map<Id,Account_Domain__c> oldMap) {}

    /**
     * After Undelete trigger functionality
     *
     * @param {Map<Id,Account_Domain__c>} newMap - Trigger.newMap
     */
    public static void afterUndelete(Map<Id,Account_Domain__c> newMap) {}
}