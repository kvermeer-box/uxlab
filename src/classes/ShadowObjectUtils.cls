/**
 * Utils for shadow objects
 *
 * @author Kyle Vermeer 5/3/14
 */
public class ShadowObjectUtils {

    public class SalesRequestShadowShell {
        public String accountId;
        public String opportunityId;
        public String requestId;
        public String requestType;
        public String request;
        public String status;
        public String dominatorId;
        public String leadId;
        public String contactId;
        public String riskId;

        public SalesRequestShadowShell(String accountId, String oppId, String requestId, String requestType, String request,
                                       String status, String dominatorId, String leadId, String contactId) {
            this.accountId = accountId;
            this.opportunityId = oppId;
            this.requestId = requestId;
            this.requestType = requestType;
            this.request = request;
            this.status = status;
            this.dominatorId = dominatorId;
            this.leadId = leadId;
            this.contactId = contactId;
        }

        public void setRisk(String riskId) {
            this.riskId = riskId;
        }
    }

    /**
     * Create shadow objects for the shells provided.
     *
     * @param {List<SalesRequestShadowShell>} shells - ShadowObjectUtils.SalesRequestShadowShells containing data for shadows
     */
    public static void createShadowObjects(List<SalesRequestShadowShell> shells) {
        if (shells == null) {
            System.debug('Null list provided.');
            return;
        }
        List<Sales_Request_Shadow__c> shadows = new List<Sales_Request_Shadow__c>();
        List<Id> requestIds = new List<Id>();
        for (SalesRequestShadowShell currentShell : shells) {
            Sales_Request_Shadow__c currentShadow = new Sales_Request_Shadow__c();
            currentShadow = populateShadow(currentShadow, currentShell);
            shadows.add(currentShadow);
            requestIds.add(currentShell.requestId);
        }
        try {
            insert shadows;
        }
        catch (Exception e) {
            new LoggedException(e, 'Trouble inserting shadow objects', 'ShadowObjectUtils', requestIds);
        }
    }

    public static void syncShadowObjects(List<SalesRequestShadowShell> shells) {
        if (shells == null) {
            System.debug('Null list provided.');
            return;
        }
        List<Id> requestIds = new List<Id>();
        for (SalesRequestShadowShell currentShell : shells) {
            requestIds.add(currentShell.requestId);
        }
        // Get list of revelant shadow objects, then create request id --> shadow map for quick look-up
        List<Sales_Request_Shadow__c> shadows = [SELECT Id, Request_Id__c FROM Sales_Request_Shadow__c WHERE Request_Id__c IN :requestIds];
        Map<String,Sales_Request_Shadow__c> idToShadow = new Map<String, Sales_Request_Shadow__c>();
        for (Sales_Request_Shadow__c currentShadow : shadows) {
            idToShadow.put(currentShadow.Request_Id__c, currentShadow);
        }

        // Update values on shadow objects
        for (SalesRequestShadowShell currentShell : shells) {
            Sales_Request_Shadow__c shadowObject = idToShadow.get(currentShell.requestId);
            if (shadowObject == null) {
                shadowObject = new Sales_Request_Shadow__c();
            }
            populateShadow(shadowObject, currentShell);
        }

        // Now DML update the shadow object
        try {
            if (!shadows.isEmpty()) {
                 update shadows;
            }
        }
        catch (Exception e) {
            new LoggedException(e,'Trouble updating shadow objects','ShadowObjectUtils',requestIds);
        }
    }

    public static void deleteShadowObjects(List<Id> requestIds) {
        if (requestIds == null) {
            System.debug('empty list of requests to delete');
            return;
        }
        List<Sales_Request_Shadow__c> shadows = [SELECT Id, Request_Id__c FROM Sales_Request_Shadow__c WHERE Request_Id__c IN :requestIds];
        try {
            if (!shadows.isEmpty()) {
                delete shadows;
            }
        }
        catch (Exception e) {
            new LoggedException(e,'Trouble deleting shadow objects','ShadowObjectUtils',requestIds);
        }
    }

    private static Sales_Request_Shadow__c populateShadow(Sales_Request_Shadow__c shadow, SalesRequestShadowShell shell) {
        shadow.Account__c = shell.accountId;
        shadow.Dominator__c = shell.dominatorId;
        shadow.Opportunity__c = shell.opportunityId;
        shadow.Request__c = shell.request;
        shadow.Request_Id__c = shell.requestId;
        shadow.Request_Type__c = shell.requestType;
        shadow.Status__c = shell.status;
        shadow.Lead__c = shell.leadId;
        shadow.Contact__c = shell.contactId;
        shadow.Risk__c = shell.riskId;
        return shadow;
    }
}