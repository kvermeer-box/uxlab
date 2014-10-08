/**
 * Trigger functionality for Box Consulting
 *
 * @author Kyle Vermeer 6/10/14
 */
public class BoxConsultingTriggerHelper {

    ////////////////
    // Public API
    ////////////////

    /**
     * Before insert trigger functionality
     *
     * @param {List<Box_Consulting__c>} newList - Trigger.new
     */
    public static void beforeInsert(List<Box_Consulting__c> newList) {}
    
    /**
     * After insert trigger functionality
     *
     * @param {Map<Id,Box_Consulting__c>} newMap - Trigger.newMap
     */
    public static void afterInsert(Map<Id,Box_Consulting__c> newMap) {
        createShadowObjects(newMap.values());
    }
    
    /**
     * Before update trigger functionality
     *
     * @param {Map<Id,Box_Consulting__c>} oldMap - Trigger.oldMap
     * @param {Map<Id,Box_Consulting__c>} newMap - Trigger.newMap
     */
    public static void beforeUpdate(Map<Id,Box_Consulting__c> oldMap, Map<Id,Box_Consulting__c> newMap) {}

    /**
     * After update trigger functionality
     *
     * @param {Map<Id,Box_Consulting__c>} oldMap - Trigger.oldMap
     * @param {Map<Id,Box_Consulting__c>} newMap - Trigger.newMap
     */
    public static void afterUpdate(Map<Id,Box_Consulting__c> oldMap, Map<Id,Box_Consulting__c> newMap) {
        syncShadowObjects(newMap.values());
    }
   
    /**
     * Before delete trigger functionality
     *
     * @param {Map<Id,Box_Consulting__c>} oldMap - Trigger.oldMap
     */
    public static void beforeDelete(Map<Id,Box_Consulting__c> oldMap) {}

    /**
     * After delete trigger functionality
     *
     * @param {Map<Id,Box_Consulting__c>} oldMap - Trigger.oldMap
     */
    public static void afterDelete(Map<Id,Box_Consulting__c> oldMap) {
        deleteShadowObjects(oldMap.values());
    }

    /**
     * After Undelete trigger functionality
     *
     * @param {Map<Id,Box_Consulting__c>} newMap - Trigger.newMap
     */
    public static void afterUndelete(Map<Id,Box_Consulting__c> newMap) {}

    private static void createShadowObjects(List<Box_Consulting__c> newValues) {
        List<ShadowObjectUtils.SalesRequestShadowShell> shells = createShadowShells(newValues);
        ShadowObjectUtils.createShadowObjects(shells);
    }

    private static void syncShadowObjects(List<Box_Consulting__c> newValues) {
        List<ShadowObjectUtils.SalesRequestShadowShell> shells = createShadowShells(newValues);
        ShadowObjectUtils.syncShadowObjects(shells);
    }

    private static void deleteShadowObjects(List<Box_Consulting__c> oldValues) {
        List<Id> requestIds = new List<Id>();
        for (Box_Consulting__c currentSR : oldValues) {
            requestIds.add(currentSR.Id);
        }
        ShadowObjectUtils.deleteShadowObjects(requestIds);
    }

    private static List<ShadowObjectUtils.SalesRequestShadowShell> createShadowShells(List<Box_Consulting__c> newValues) {
        List<ShadowObjectUtils.SalesRequestShadowShell> shells = new List<ShadowObjectUtils.SalesRequestShadowShell>();
        for (Box_Consulting__c currentBC : newValues) {
            ShadowObjectUtils.SalesRequestShadowShell currentShell = new ShadowObjectUtils.SalesRequestShadowShell(
                currentBC.Account__c, 
                currentBC.Opportunity__c, 
                currentBC.Id, 
                'Box Consulting', 
                '', 
                currentBC.Status__c, 
                null,
                null,
                null
            );
            shells.add(currentShell);
        }
        return shells;
    }
}