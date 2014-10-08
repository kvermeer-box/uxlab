public class BoxOutRequestTriggerHelper {

    ////////////////
    // Public API
    ////////////////

    /**
     * Before insert trigger functionality
     *
     * @param {List<BoxOut_Request__c>} newList - Trigger.new
     */
    public static void beforeInsert(List<BoxOut_Request__c> newList) {}
    
    /**
     * After insert trigger functionality
     *
     * @param {Map<Id,BoxOut_Request__c>} newMap - Trigger.newMap
     */
    public static void afterInsert(Map<Id,BoxOut_Request__c> newMap) {
        createShadowObjects(newMap.values());
    }
    
    /**
     * Before update trigger functionality
     *
     * @param {Map<Id,BoxOut_Request__c>} oldMap - Trigger.oldMap
     * @param {Map<Id,BoxOut_Request__c>} newMap - Trigger.newMap
     */
    public static void beforeUpdate(Map<Id,BoxOut_Request__c> oldMap, Map<Id,BoxOut_Request__c> newMap) {}

    /**
     * After update trigger functionality
     *
     * @param {Map<Id,BoxOut_Request__c>} oldMap - Trigger.oldMap
     * @param {Map<Id,BoxOut_Request__c>} newMap - Trigger.newMap
     */
    public static void afterUpdate(Map<Id,BoxOut_Request__c> oldMap, Map<Id,BoxOut_Request__c> newMap) {
        syncShadowObjects(newMap.values());
    }
   
    /**
     * Before delete trigger functionality
     *
     * @param {Map<Id,BoxOut_Request__c>} oldMap - Trigger.oldMap
     */
    public static void beforeDelete(Map<Id,BoxOut_Request__c> oldMap) {}

    /**
     * After delete trigger functionality
     *
     * @param {Map<Id,BoxOut_Request__c>} oldMap - Trigger.oldMap
     */
    public static void afterDelete(Map<Id,BoxOut_Request__c> oldMap) {
        deleteShadowObjects(oldMap.values());
    }

    /**
     * After Undelete trigger functionality
     *
     * @param {Map<Id,BoxOut_Request__c>} newMap - Trigger.newMap
     */
    public static void afterUndelete(Map<Id,BoxOut_Request__c> newMap) {}

    private Static Map<Id,String> recordTypeIdToRecordTypeName {
        get {
            if (recordTypeIdToRecordTypeName == null) {
                recordTypeIdToRecordTypeName = new Map<Id,String>();
                List<RecordType> recordTypes = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'BoxOut_Request__c'];
                System.debug('Record Types: ' + recordTypes);
                for (RecordType currentRecordType : recordTypes) {
                    recordTypeIdToRecordTypeName.put(currentRecordType.Id, currentRecordType.Name);
                }
            }
            return recordTypeIdToRecordTypeName;
        }
        set;
    }

    private static void createShadowObjects(List<BoxOut_Request__c> newValues) {
        List<ShadowObjectUtils.SalesRequestShadowShell> shells = createShadowShells(newValues);
        ShadowObjectUtils.createShadowObjects(shells);
    }

    private static void syncShadowObjects(List<BoxOut_Request__c> newValues) {
        List<ShadowObjectUtils.SalesRequestShadowShell> shells = createShadowShells(newValues);
        ShadowObjectUtils.syncShadowObjects(shells);
    }

    private static void deleteShadowObjects(List<BoxOut_Request__c> oldValues) {
        List<Id> requestIds = new List<Id>();
        for (BoxOut_Request__c currentSR : oldValues) {
            requestIds.add(currentSR.Id);
        }
        ShadowObjectUtils.deleteShadowObjects(requestIds);
    }

    private static List<ShadowObjectUtils.SalesRequestShadowShell> createShadowShells(List<BoxOut_Request__c> newValues) {
        List<ShadowObjectUtils.SalesRequestShadowShell> shells = new List<ShadowObjectUtils.SalesRequestShadowShell>();
        for (BoxOut_Request__c currentBO : newValues) {
            System.debug('Map: ' + recordTypeIdToRecordTypeName);
            ShadowObjectUtils.SalesRequestShadowShell currentShell = new ShadowObjectUtils.SalesRequestShadowShell(
                currentBO.Account__c, 
                currentBO.Opportunity__c, 
                currentBO.Id, 
                'BoxOut Request', 
                currentBO.Competitor__c, 
                currentBO.Status__c, 
                currentBO.Dominator__c,
                null,
                null
            );
            if (currentBO.Risk__c != null) {
                currentShell.setRisk(currentBO.Risk__c);
            }
            shells.add(currentShell);
        }
        return shells;
    }
}