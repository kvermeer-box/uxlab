/**
 * Trigger Handler for Sales Ops and Rev Ops Requests
 *
 * @author Kyle Vermeer 8/22/14
 */
public class SalesOpsAndRevOpsRequestTriggerHelper {

    private static final String SALES_OPS_AND_REV_OPS_REQUEST = 'Sales Ops & Revenue Ops Request';
    // If changed out of this status, set first response
    private static final String FIRST_RESPONSE_GATE_STATUS = 'Unassigned';

    private static final Integer MILLISECONDS_IN_SECOND = 1000;
    private static final Integer SECONDS_IN_HOUR = 3600;

    private static BusinessHours defaultBusinessHours {
        get {
            if( defaultBusinessHours == null ) {
                defaultBusinessHours = [SELECT Id FROM BusinessHours WHERE isDefault = true];
            }
            return defaultBusinessHours;
        }
        set;
    }
    ////////////////
    // Public API
    ////////////////

    /**
     * Before insert trigger functionality
     *
     * @param {List<Sales_Ops_Revenue_Ops_Request__c>} newList - Trigger.new
     */
    public static void beforeInsert(List<Sales_Ops_Revenue_Ops_Request__c> newList) {}
    
    /**
     * After insert trigger functionality
     *
     * @param {Map<Id,Sales_Ops_Revenue_Ops_Request__c>} newMap - Trigger.newMap
     */
    public static void afterInsert(Map<Id,Sales_Ops_Revenue_Ops_Request__c> newMap) {
        createShadowObjects(newMap.values());
    }
    
    /**
     * Before update trigger functionality
     *
     * @param {Map<Id,Sales_Ops_Revenue_Ops_Request__c>} oldMap - Trigger.oldMap
     * @param {Map<Id,Sales_Ops_Revenue_Ops_Request__c>} newMap - Trigger.newMap
     */
    public static void beforeUpdate(Map<Id,Sales_Ops_Revenue_Ops_Request__c> oldMap, Map<Id,Sales_Ops_Revenue_Ops_Request__c> newMap) {
        updateTicketDuration(oldMap, newMap);
        updateTimeToFirstResponse(oldMap, newMap);
    }

    /**
     * After update trigger functionality
     *
     * @param {Map<Id,Sales_Ops_Revenue_Ops_Request__c>} oldMap - Trigger.oldMap
     * @param {Map<Id,Sales_Ops_Revenue_Ops_Request__c>} newMap - Trigger.newMap
     */
    public static void afterUpdate(Map<Id,Sales_Ops_Revenue_Ops_Request__c> oldMap, Map<Id,Sales_Ops_Revenue_Ops_Request__c> newMap) {
        syncShadowObjects(newMap.values());
    }
   
    /**
     * Before delete trigger functionality
     *
     * @param {Map<Id,Sales_Ops_Revenue_Ops_Request__c>} oldMap - Trigger.oldMap
     */
    public static void beforeDelete(Map<Id,Sales_Ops_Revenue_Ops_Request__c> oldMap) {}

    /**
     * After delete trigger functionality
     *
     * @param {Map<Id,Sales_Ops_Revenue_Ops_Request__c>} oldMap - Trigger.oldMap
     */
    public static void afterDelete(Map<Id,Sales_Ops_Revenue_Ops_Request__c> oldMap) {
        deleteShadowObjects(oldMap.values());
    }

    /**
     * After Undelete trigger functionality
     *
     * @param {Map<Id,Sales_Ops_Revenue_Ops_Request__c>} newMap - Trigger.newMap
     */
    public static void afterUndelete(Map<Id,Sales_Ops_Revenue_Ops_Request__c> newMap) {}

    private Static Map<Id,String> recordTypeIdToRecordTypeName {
        get {
            if (recordTypeIdToRecordTypeName == null) {
                recordTypeIdToRecordTypeName = new Map<Id,String>();
                List<RecordType> recordTypes = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Sales_Ops_Revenue_Ops_Request__c'];
                System.debug('Record Types: ' + recordTypes);
                for (RecordType currentRecordType : recordTypes) {
                    recordTypeIdToRecordTypeName.put(currentRecordType.Id, currentRecordType.Name);
                }
            }
            return recordTypeIdToRecordTypeName;
        }
        set;
    }

    private static void createShadowObjects(List<Sales_Ops_Revenue_Ops_Request__c> newValues) {
        List<ShadowObjectUtils.SalesRequestShadowShell> shells = createShadowShells(newValues);
        ShadowObjectUtils.createShadowObjects(shells);
    }

    private static void syncShadowObjects(List<Sales_Ops_Revenue_Ops_Request__c> newValues) {
        List<ShadowObjectUtils.SalesRequestShadowShell> shells = createShadowShells(newValues);
        ShadowObjectUtils.syncShadowObjects(shells);
    }

    private static void deleteShadowObjects(List<Sales_Ops_Revenue_Ops_Request__c> oldValues) {
        List<Id> requestIds = new List<Id>();
        for (Sales_Ops_Revenue_Ops_Request__c currentSR : oldValues) {
            requestIds.add(currentSR.Id);
        }
        ShadowObjectUtils.deleteShadowObjects(requestIds);
    }

    private static List<ShadowObjectUtils.SalesRequestShadowShell> createShadowShells(List<Sales_Ops_Revenue_Ops_Request__c> newValues) {
        List<ShadowObjectUtils.SalesRequestShadowShell> shells = new List<ShadowObjectUtils.SalesRequestShadowShell>();
        for (Sales_Ops_Revenue_Ops_Request__c currentRequest : newValues) {
            String recordTypeName = SalesOpsAndRevOpsRequestTriggerHelper.recordTypeIdToRecordTypeName.get(currentRequest.RecordTypeId);
            ShadowObjectUtils.SalesRequestShadowShell currentShell = new ShadowObjectUtils.SalesRequestShadowShell(
                currentRequest.Account__c, 
                currentRequest.Opportunity__c, 
                currentRequest.Id, 
                SALES_OPS_AND_REV_OPS_REQUEST, 
                recordTypeName, 
                currentRequest.Status__c, 
                currentRequest.Dominator__c,
                currentRequest.Lead__c,
                currentRequest.Contact__c
            );
            shells.add(currentShell);
        }
        return shells;
    }

    private static void updateTicketDuration(Map<Id,Sales_Ops_Revenue_Ops_Request__c> oldMap, Map<Id,Sales_Ops_Revenue_Ops_Request__c> newMap) {
        List<Sales_Ops_Revenue_Ops_Request__c> requestsToUpdateTicketDuration = new List<Sales_Ops_Revenue_Ops_Request__c>();
        for (Sales_Ops_Revenue_Ops_Request__c request : newMap.values()) {
            Sales_Ops_Revenue_Ops_Request__c oldRequest = oldMap.get(request.Id);
            if (oldRequest.Completed_Date__c == null && request.Completed_Date__c != null) {
                requestsToUpdateTicketDuration.add(request);
            }
        }
        // Only continue if there are some requests to update
        if (!requestsToUpdateTicketDuration.isEmpty()) {
            BusinessHours bh = defaultBusinessHours;
            for (Sales_Ops_Revenue_Ops_Request__c request : requestsToUpdateTicketDuration) {
                Long difference = BusinessHours.diff(bh.Id, request.CreatedDate, request.Completed_Date__c);
                Long seconds = difference / MILLISECONDS_IN_SECOND;
                Long hours = seconds / SECONDS_IN_HOUR;
                request.Ticket_Duration__c = hours;
            }
        }
    }

    private static void updateTimeToFirstResponse(Map<Id,Sales_Ops_Revenue_Ops_Request__c> oldMap, Map<Id,Sales_Ops_Revenue_Ops_Request__c> newMap) {
        Sales_Ops_Revenue_Ops_Request__c[] requestsToUpdate = new Sales_Ops_Revenue_Ops_Request__c[] {};
        for( Sales_Ops_Revenue_Ops_Request__c currentRequest : newMap.values() ) {
            Sales_Ops_Revenue_Ops_Request__c oldRequest = oldMap.get(currentRequest.Id);
            // if status is changed out of gate status, add to list to update
            if( oldRequest.Status__c != currentRequest.Status__c && currentRequest.Status__c != FIRST_RESPONSE_GATE_STATUS && currentRequest.Time_to_First_Response__c == null ) {
                requestsToUpdate.add(currentRequest);
            }
        }

        if( !requestsToUpdate.isEmpty() ) {
            BusinessHours bh = defaultBusinessHours;
            for( Sales_Ops_Revenue_Ops_Request__c request : requestsToUpdate ) {
                Long difference = BusinessHours.diff(bh.Id, request.CreatedDate, Datetime.now());
                Long seconds = difference / MILLISECONDS_IN_SECOND;
                Long hours = seconds / SECONDS_IN_HOUR;
                request.Time_to_First_Response__c = hours;
            }
        }
    }
}