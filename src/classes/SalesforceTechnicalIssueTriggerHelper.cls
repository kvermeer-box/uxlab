/**
 * Trigger Handler for Salesforce Technical Issues
 *
 * @author Kyle Vermeer 8/15/14
 */
public class SalesforceTechnicalIssueTriggerHelper {
    
    private static final String SALESFORCE_TECHNICAL_ISSUE = 'Salesforce Technical Issue';

    private static final Integer MILLISECONDS_IN_SECOND = 1000;
    private static final Integer SECONDS_IN_HOUR = 3600;

    public static BusinessHours sfdcBusinessHours {
        get {
            if( sfdcBusinessHours == null ) {
                sfdcBusinessHours = [SELECT Id FROM BusinessHours WHERE Name = 'SFDC Admin Business Hours'];
            }
            return sfdcBusinessHours;
        }
        set;
    }

    ////////////////
    // Public API
    ////////////////

    /**
     * Before insert trigger functionality
     *
     * @param {List<Salesforce_Technical_Issue__c>} newList - Trigger.new
     */
    public static void beforeInsert(List<Salesforce_Technical_Issue__c> newList) {}
    
    /**
     * After insert trigger functionality
     *
     * @param {Map<Id,Salesforce_Technical_Issue__c>} newMap - Trigger.newMap
     */
    public static void afterInsert(Map<Id,Salesforce_Technical_Issue__c> newMap) {
        createShadowObjects(newMap.values());
    }
    
    /**
     * Before update trigger functionality
     *
     * @param {Map<Id,Salesforce_Technical_Issue__c>} oldMap - Trigger.oldMap
     * @param {Map<Id,Salesforce_Technical_Issue__c>} newMap - Trigger.newMap
     */
    
    private static void updateTicketDuration(Map<Id,Salesforce_Technical_Issue__c> oldMap, Map<Id,Salesforce_Technical_Issue__c> newMap) {
        /**
        * Added by Cody Mills as part of the request to add the ticket duration field 
        * from the SalesOpsAndRevOpsReuqest object trigger to the
        * Salesforce Technical Issue Object trigger (on completion update)
        */
        List<Salesforce_Technical_Issue__c> requestsToUpdateTicketDuration = new List<Salesforce_Technical_Issue__c>();
        for (Salesforce_Technical_Issue__c request : newMap.values()) {
            Salesforce_Technical_Issue__c oldRequest = oldMap.get(request.Id);
            if (oldrequest.Status__c != 'Completed' && request.Status__c == 'Completed') {
                request.Completed_Date__c = Datetime.now();
                requestsToUpdateTicketDuration.add(request);
            }
            if (oldrequest.Status__c == 'Completed' && request.Status__c != 'Completed') {
                request.Completed_Date__c = NULL;
                request.Ticket_Duration__c = NULL;
            }
        }
        // Only continue if there are some requests to update
        if (!requestsToUpdateTicketDuration.isEmpty()) {
            BusinessHours bh = sfdcBusinessHours;
            for (Salesforce_Technical_Issue__c request : requestsToUpdateTicketDuration) {
                Long difference = BusinessHours.diff(bh.Id, request.CreatedDate, request.Completed_Date__c);
                Long seconds = difference / MILLISECONDS_IN_SECOND;
                Double hours = (Double)seconds / SECONDS_IN_HOUR;
                //if (hours == NULL) hours = 0;
                request.Ticket_Duration__c = hours;
            }
        }
    }

    public static void beforeUpdate(Map<Id,Salesforce_Technical_Issue__c> oldMap, Map<Id,Salesforce_Technical_Issue__c> newMap) {
        updateTicketDuration(oldMap, newMap);
    }



    /**
     * After update trigger functionality
     *
     * @param {Map<Id,Salesforce_Technical_Issue__c>} oldMap - Trigger.oldMap
     * @param {Map<Id,Salesforce_Technical_Issue__c>} newMap - Trigger.newMap
     */
    public static void afterUpdate(Map<Id,Salesforce_Technical_Issue__c> oldMap, Map<Id,Salesforce_Technical_Issue__c> newMap) {
        syncShadowObjects(newMap.values());
    }
   
    /**
     * Before delete trigger functionality
     *
     * @param {Map<Id,Salesforce_Technical_Issue__c>} oldMap - Trigger.oldMap
     */
    public static void beforeDelete(Map<Id,Salesforce_Technical_Issue__c> oldMap) {}

    /**
     * After delete trigger functionality
     *
     * @param {Map<Id,Salesforce_Technical_Issue__c>} oldMap - Trigger.oldMap
     */
    public static void afterDelete(Map<Id,Salesforce_Technical_Issue__c> oldMap) {
        deleteShadowObjects(oldMap.values());
    }

    /**
     * After Undelete trigger functionality
     *
     * @param {Map<Id,Salesforce_Technical_Issue__c>} newMap - Trigger.newMap
     */
    public static void afterUndelete(Map<Id,Salesforce_Technical_Issue__c> newMap) {}

    private static void createShadowObjects(List<Salesforce_Technical_Issue__c> newValues) {
        List<ShadowObjectUtils.SalesRequestShadowShell> shells = createShadowShells(newValues);
        ShadowObjectUtils.createShadowObjects(shells);
    }

    private static void syncShadowObjects(List<Salesforce_Technical_Issue__c> newValues) {
        List<ShadowObjectUtils.SalesRequestShadowShell> shells = createShadowShells(newValues);
        ShadowObjectUtils.syncShadowObjects(shells);
    }

    private static void deleteShadowObjects(List<Salesforce_Technical_Issue__c> oldValues) {
        List<Id> requestIds = new List<Id>();
        for (Salesforce_Technical_Issue__c currentSR : oldValues) {
            requestIds.add(currentSR.Id);
        }
        ShadowObjectUtils.deleteShadowObjects(requestIds);
    }

    private static List<ShadowObjectUtils.SalesRequestShadowShell> createShadowShells(List<Salesforce_Technical_Issue__c> newValues) {
        List<ShadowObjectUtils.SalesRequestShadowShell> shells = new List<ShadowObjectUtils.SalesRequestShadowShell>();
        for (Salesforce_Technical_Issue__c currentSR : newValues) {
            ShadowObjectUtils.SalesRequestShadowShell currentShell;
            currentShell = new ShadowObjectUtils.SalesRequestShadowShell(
                currentSr.Account__c, 
                currentSR.Opportunity__c, 
                currentSR.Id, 
                SALESFORCE_TECHNICAL_ISSUE, 
                currentSR.Request_Type__c, 
                currentSR.Status__c, 
                currentSR.Dominator__c,
                currentSR.Lead__c,
                currentSR.Contact__c
            );
           
            shells.add(currentShell);
        }
        return shells;
    }
}