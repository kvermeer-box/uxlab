/**
 * Trigger Functionality for Executive Engagements
 *
 * @author Kyle Vermeer 6/11/14
 */
public class ExecutiveEngagementTriggerHelper {

    private static final String EXECUTIVE_ENGAGEMENT = 'Executive Engagement';

    ////////////////
    // Public API
    ////////////////

    /**
     * Before insert trigger functionality
     *
     * @param {List<Executive_Engagement__c>} newList - Trigger.new
     */
    public static void beforeInsert(List<Executive_Engagement__c> newList) {}
    
    /**
     * After insert trigger functionality
     *
     * @param {Map<Id,Executive_Engagement__c>} newMap - Trigger.newMap
     */
    public static void afterInsert(Map<Id,Executive_Engagement__c> newMap) {
        createShadowObjects(newMap.values());
        syncRisks(newMap.values());
    }
    
    /**
     * Before update trigger functionality
     *
     * @param {Map<Id,Executive_Engagement__c>} oldMap - Trigger.oldMap
     * @param {Map<Id,Executive_Engagement__c>} newMap - Trigger.newMap
     */
    public static void beforeUpdate(Map<Id,Executive_Engagement__c> oldMap, Map<Id,Executive_Engagement__c> newMap) {}

    /**
     * After update trigger functionality
     *
     * @param {Map<Id,Executive_Engagement__c>} oldMap - Trigger.oldMap
     * @param {Map<Id,Executive_Engagement__c>} newMap - Trigger.newMap
     */
    public static void afterUpdate(Map<Id,Executive_Engagement__c> oldMap, Map<Id,Executive_Engagement__c> newMap) {
        syncShadowObjects(newMap.values());
        syncRisks(newMap.values());
    }
   
    /**
     * Before delete trigger functionality
     *
     * @param {Map<Id,Executive_Engagement__c>} oldMap - Trigger.oldMap
     */
    public static void beforeDelete(Map<Id,Executive_Engagement__c> oldMap) {}

    /**
     * After delete trigger functionality
     *
     * @param {Map<Id,Executive_Engagement__c>} oldMap - Trigger.oldMap
     */
    public static void afterDelete(Map<Id,Executive_Engagement__c> oldMap) {
        deleteShadowObjects(oldMap.values());
    }

    /**
     * After Undelete trigger functionality
     *
     * @param {Map<Id,Executive_Engagement__c>} newMap - Trigger.newMap
     */
    public static void afterUndelete(Map<Id,Executive_Engagement__c> newMap) {}

    private Static Map<Id,String> recordTypeIdToRecordTypeName {
        get {
            if (recordTypeIdToRecordTypeName == null) {
                recordTypeIdToRecordTypeName = new Map<Id,String>();
                List<RecordType> recordTypes = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Executive_Engagement__c'];
                System.debug('Record Types: ' + recordTypes);
                for (RecordType currentRecordType : recordTypes) {
                    recordTypeIdToRecordTypeName.put(currentRecordType.Id, currentRecordType.Name);
                }
            }
            return recordTypeIdToRecordTypeName;
        }
        set;
    }

    private static void createShadowObjects(List<Executive_Engagement__c> newValues) {
        List<ShadowObjectUtils.SalesRequestShadowShell> shells = createShadowShells(newValues);
        ShadowObjectUtils.createShadowObjects(shells);
    }

    private static void syncShadowObjects(List<Executive_Engagement__c> newValues) {
        List<ShadowObjectUtils.SalesRequestShadowShell> shells = createShadowShells(newValues);
        ShadowObjectUtils.syncShadowObjects(shells);
    }

    private static void deleteShadowObjects(List<Executive_Engagement__c> oldValues) {
        List<Id> requestIds = new List<Id>();
        for (Executive_Engagement__c currentSR : oldValues) {
            requestIds.add(currentSR.Id);
        }
        ShadowObjectUtils.deleteShadowObjects(requestIds);
    }

    private static List<ShadowObjectUtils.SalesRequestShadowShell> createShadowShells(List<Executive_Engagement__c> newValues) {
        List<ShadowObjectUtils.SalesRequestShadowShell> shells = new List<ShadowObjectUtils.SalesRequestShadowShell>();
        for (Executive_Engagement__c currentEE : newValues) {
            String recordTypeName = ExecutiveEngagementTriggerHelper.recordTypeIdToRecordTypeName.get(currentEE.RecordTypeId);
            ShadowObjectUtils.SalesRequestShadowShell currentShell = new ShadowObjectUtils.SalesRequestShadowShell(
                currentEE.Account__c, 
                currentEE.Opportunity__c, 
                currentEE.Id, 
                'Executive Engagement', 
                recordTypeName, 
                currentEE.Status__c, 
                currentEE.Dominator__c,
                null,
                null
            );
            currentShell.setRisk(currentEE.Risk__c);
            shells.add(currentShell);
        }
        return shells;
    }

    /**
     * Syncs fields between the Risk and Executive Engagement Objects
     *
     * @param {List<Executive_Engagement__c>} newValues = Trigger.new
     */
    private static void syncRisks(List<Executive_Engagement__c> newValues) {
        Map<Id, Executive_Engagement__c> riskToEE = new Map<Id, Executive_Engagement__c>();
        // First compile a map for all Executive Engagements with risks from the newValues parameter
        for (Executive_Engagement__c currentEE : newValues) {
            Id recordTypeId = currentEE.RecordTypeId;
            String recordTypeName = recordTypeIdToRecordTypeName.get(recordTypeId);
            Id riskForEE = currentEE.Risk__c;
            if( riskForEE != null ) { // Only if it has a risk
                riskToEE.put(riskForEE, currentEE);
            }
        }
        // Now we can grab the set of risks
        Set<Id> riskIds = riskToEE.keySet();
        if( !riskIds.isEmpty() ) { // If there is some executive engagement with a risk, see if anything has changed.
            Risk__c[] risks = [SELECT Id, Executive_Engagement_Box_Executive__c, Executive_Engagement_Created_Date__c, Executive_Engagement_Status__c
                                 FROM Risk__c
                                WHERE Id IN :riskIds];
            Risk__c[] risksToUpdate = new Risk__c[] {};
            // See if any of the values on the risks needs to be updated
            for( Risk__c currentRisk : risks ) {
                Executive_Engagement__c eeForRisk = riskToEE.get(currentRisk.Id);
                if( currentRisk.Executive_Engagement_Box_Executive__c != eeForRisk.Box_Executive__c || currentRisk.Executive_Engagement_Created_Date__c != eeForRisk.CreatedDate || currentRisk.Executive_Engagement_Status__c != eeForRisk.Status__c ) {
                    // Update fields, then add it to list for updating
                    currentRisk.Executive_Engagement_Box_Executive__c = eeForRisk.Box_Executive__c;
                    currentRisk.Executive_Engagement_Created_Date__c = eeForRisk.CreatedDate;
                    currentRisk.Executive_Engagement_Status__c = eeForRisk.Status__c;
                    risksToUpdate.add(currentRisk);
                }
            }
            // Only issue DML if there is something to update
            if( !risksToUpdate.isEmpty() ) {
                update risksToUpdate;
            }
        }                
    }
}