/**
 * Helper Class for the EnterpriseKeyManagement Trigger
 *
 * @author Kyle Vermeer 7/2/14
 */
public class EnterpriseKeyManagementTriggerHelper {

    ////////////////
    // Public API
    ////////////////

    /**
     * Before insert trigger functionality
     *
     * @param {List<Enterprise_Key_Management__c>} newList - Trigger.new
     */
    public static void beforeInsert(List<Enterprise_Key_Management__c> newList) {}
    
    /**
     * After insert trigger functionality
     *
     * @param {Map<Id,Enterprise_Key_Management__c>} newMap - Trigger.newMap
     */
    public static void afterInsert(Map<Id,Enterprise_Key_Management__c> newMap) {
        createShadowObjects(newMap.values());
    }
    
    /**
     * Before update trigger functionality
     *
     * @param {Map<Id,Enterprise_Key_Management__c>} oldMap - Trigger.oldMap
     * @param {Map<Id,Enterprise_Key_Management__c>} newMap - Trigger.newMap
     */
    public static void beforeUpdate(Map<Id,Enterprise_Key_Management__c> oldMap, Map<Id,Enterprise_Key_Management__c> newMap) {}

    /**
     * After update trigger functionality
     *
     * @param {Map<Id,Enterprise_Key_Management__c>} oldMap - Trigger.oldMap
     * @param {Map<Id,Enterprise_Key_Management__c>} newMap - Trigger.newMap
     */
    public static void afterUpdate(Map<Id,Enterprise_Key_Management__c> oldMap, Map<Id,Enterprise_Key_Management__c> newMap) {
        syncShadowObjects(newMap.values());
    }
   
    /**
     * Before delete trigger functionality
     *
     * @param {Map<Id,Enterprise_Key_Management__c>} oldMap - Trigger.oldMap
     */
    public static void beforeDelete(Map<Id,Enterprise_Key_Management__c> oldMap) {}

    /**
     * After delete trigger functionality
     *
     * @param {Map<Id,Enterprise_Key_Management__c>} oldMap - Trigger.oldMap
     */
    public static void afterDelete(Map<Id,Enterprise_Key_Management__c> oldMap) {
        deleteShadowObjects(oldMap.values());
    }

    /**
     * After Undelete trigger functionality
     *
     * @param {Map<Id,Enterprise_Key_Management__c>} newMap - Trigger.newMap
     */
    public static void afterUndelete(Map<Id,Enterprise_Key_Management__c> newMap) {}

    private Static Map<Id,String> recordTypeIdToRecordTypeName {
        get {
            if (recordTypeIdToRecordTypeName == null) {
                recordTypeIdToRecordTypeName = new Map<Id,String>();
                List<RecordType> recordTypes = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Enterprise_Key_Management__c'];
                System.debug('Record Types: ' + recordTypes);
                for (RecordType currentRecordType : recordTypes) {
                    recordTypeIdToRecordTypeName.put(currentRecordType.Id, currentRecordType.Name);
                }
            }
            return recordTypeIdToRecordTypeName;
        }
        set;
    }

    private static void createShadowObjects(List<Enterprise_Key_Management__c> newValues) {
        List<ShadowObjectUtils.SalesRequestShadowShell> shells = createShadowShells(newValues);
        ShadowObjectUtils.createShadowObjects(shells);
    }

    private static void syncShadowObjects(List<Enterprise_Key_Management__c> newValues) {
        List<ShadowObjectUtils.SalesRequestShadowShell> shells = createShadowShells(newValues);
        ShadowObjectUtils.syncShadowObjects(shells);
    }

    private static void deleteShadowObjects(List<Enterprise_Key_Management__c> oldValues) {
        List<Id> requestIds = new List<Id>();
        for (Enterprise_Key_Management__c currentSR : oldValues) {
            requestIds.add(currentSR.Id);
        }
        ShadowObjectUtils.deleteShadowObjects(requestIds);
    }

    private static List<ShadowObjectUtils.SalesRequestShadowShell> createShadowShells(List<Enterprise_Key_Management__c> newValues) {
        List<ShadowObjectUtils.SalesRequestShadowShell> shells = new List<ShadowObjectUtils.SalesRequestShadowShell>();
        for (Enterprise_Key_Management__c currentBO : newValues) {
            System.debug('Map: ' + recordTypeIdToRecordTypeName);
            ShadowObjectUtils.SalesRequestShadowShell currentShell = new ShadowObjectUtils.SalesRequestShadowShell(
                currentBO.Account__c, 
                currentBO.Opportunity__c, 
                currentBO.Id,
                'Enterprise Key Management', 
                null, 
                currentBO.Status__c, 
                currentBO.Dominator__c,
                null,
                null
            );
            shells.add(currentShell);
        }
        return shells;
    }
}