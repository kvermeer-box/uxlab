/**
 * Trigger Handler for Sales Requests
 *
 * @author Kyle Vermeer 5/3/14
 */
public class SalesRequestTriggerHelper {
    
    private static final String OPS_AND_BILLING = 'Ops & Billing Request';

    ////////////////
    // Public API
    ////////////////

    /**
     * Before insert trigger functionality
     *
     * @param {List<Sales_Request__c>} newList - Trigger.new
     */
    public static void beforeInsert(List<Sales_Request__c> newList) {}
    
    /**
     * After insert trigger functionality
     *
     * @param {Map<Id,Sales_Request__c>} newMap - Trigger.newMap
     */
    public static void afterInsert(Map<Id,Sales_Request__c> newMap) {
        createShadowObjects(newMap.values());
    }
    
    /**
     * Before update trigger functionality
     *
     * @param {Map<Id,Sales_Request__c>} oldMap - Trigger.oldMap
     * @param {Map<Id,Sales_Request__c>} newMap - Trigger.newMap
     */
    public static void beforeUpdate(Map<Id,Sales_Request__c> oldMap, Map<Id,Sales_Request__c> newMap) {}

    /**
     * After update trigger functionality
     *
     * @param {Map<Id,Sales_Request__c>} oldMap - Trigger.oldMap
     * @param {Map<Id,Sales_Request__c>} newMap - Trigger.newMap
     */
    public static void afterUpdate(Map<Id,Sales_Request__c> oldMap, Map<Id,Sales_Request__c> newMap) {
        syncShadowObjects(newMap.values());
    }
   
    /**
     * Before delete trigger functionality
     *
     * @param {Map<Id,Sales_Request__c>} oldMap - Trigger.oldMap
     */
    public static void beforeDelete(Map<Id,Sales_Request__c> oldMap) {}

    /**
     * After delete trigger functionality
     *
     * @param {Map<Id,Sales_Request__c>} oldMap - Trigger.oldMap
     */
    public static void afterDelete(Map<Id,Sales_Request__c> oldMap) {
        deleteShadowObjects(oldMap.values());
    }

    /**
     * After Undelete trigger functionality
     *
     * @param {Map<Id,Sales_Request__c>} newMap - Trigger.newMap
     */
    public static void afterUndelete(Map<Id,Sales_Request__c> newMap) {}

    private Static Map<Id,String> recordTypeIdToRecordTypeName {
        get {
            if (recordTypeIdToRecordTypeName == null) {
                recordTypeIdToRecordTypeName = new Map<Id,String>();
                List<RecordType> recordTypes = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Sales_Request__c'];
                System.debug('Record Types: ' + recordTypes);
                for (RecordType currentRecordType : recordTypes) {
                    recordTypeIdToRecordTypeName.put(currentRecordType.Id, currentRecordType.Name);
                }
            }
            return recordTypeIdToRecordTypeName;
        }
        set;
    }

    private static void createShadowObjects(List<Sales_Request__c> newValues) {
        List<ShadowObjectUtils.SalesRequestShadowShell> shells = createShadowShells(newValues);
        ShadowObjectUtils.createShadowObjects(shells);
    }

    private static void syncShadowObjects(List<Sales_Request__c> newValues) {
        List<ShadowObjectUtils.SalesRequestShadowShell> shells = createShadowShells(newValues);
        ShadowObjectUtils.syncShadowObjects(shells);
    }

    private static void deleteShadowObjects(List<Sales_Request__c> oldValues) {
        List<Id> requestIds = new List<Id>();
        for (Sales_Request__c currentSR : oldValues) {
            requestIds.add(currentSR.Id);
        }
        ShadowObjectUtils.deleteShadowObjects(requestIds);
    }

    private static List<ShadowObjectUtils.SalesRequestShadowShell> createShadowShells(List<Sales_Request__c> newValues) {
        List<ShadowObjectUtils.SalesRequestShadowShell> shells = new List<ShadowObjectUtils.SalesRequestShadowShell>();
        for (Sales_Request__c currentSR : newValues) {
            System.debug('Current SR Record Type: ' + currentSR.RecordTypeId);
            System.debug('Map: ' + recordTypeIdToRecordTypeName);
            String recordTypeName = SalesRequestTriggerHelper.recordTypeIdToRecordTypeName.get(currentSR.RecordTypeId);
            ShadowObjectUtils.SalesRequestShadowShell currentShell;
            if (recordTypeName == OPS_AND_BILLING) {
                currentShell = new ShadowObjectUtils.SalesRequestShadowShell(
                                        currentSr.Account__c, 
                                        currentSR.Opportunity__c, 
                                        currentSR.Id, 
                                        recordTypeName, 
                                        currentSR.Sales_Request_Type__c, 
                                        currentSR.Status__c, 
                                        currentSR.Dominator__c,
                                        currentSR.Lead__c,
                                        currentSR.Contact__c
                                    );
            }
            else {
                currentShell = new ShadowObjectUtils.SalesRequestShadowShell(
                    currentSr.Account__c, 
                    currentSR.Opportunity__c, 
                    currentSR.Id, 
                    recordTypeName, 
                    currentSR.Request_Type__c, 
                    currentSR.Status__c, 
                    currentSR.Dominator__c,
                    currentSR.Lead__c,
                    currentSR.Contact__c
                );
            }
           
            shells.add(currentShell);
        }
        return shells;
    }
}