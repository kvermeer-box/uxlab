/**
 * Contains logic to handle QuoteApproval trigger functionality.
 *
 * @author Kyle Vermeer 5/4/14
 */
public class QuoteApproval_TriggerHandler {
 
    ///////////////
    // Constants
    ///////////////
    private static final String REVOKED_BY_OTHER_APPROVAL_PROCESS_COMMENT = 'This approval was revoked because another active approval was either revoked or rejected.';
    
    /* Public API */

    /**
     * Creates a map from status to quote approval for approvals that just changed status
     *
     * @param {Map<Id,Quote_Approval__c>} oldMap - Trigger.oldMap
     * @param {Map<Id,Quote_Approval__c>} newMap - Trigger.newMap
     * @return {Map<String, List<Quote_Approval__c>>} - map from status to quote approvals that changed to that status
     * @author Kyle Vermeer 5/4/14
     */
    private static Map<String, List<Quote_Approval__c>> getChangedStatusApprovals(Map<Id, Quote_Approval__c> oldMap, Map<Id,Quote_Approval__c> newMap) {
        Map<String, List<Quote_Approval__c>> statusToApprovals = new Map<String, List<Quote_Approval__c>>();
        // pre-populate
        statusToApprovals.put(QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_APPROVED, new List<Quote_Approval__c>());
        statusToApprovals.put(QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_REVOKED, new List<Quote_Approval__c>());
        statusToApprovals.put(QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_REJECTED, new List<Quote_Approval__c>());
        // For each approval, check if it's status just changed
        for (Quote_Approval__c currentApproval : newMap.values()) {
            Quote_Approval__c oldApproval = oldMap.get(currentApproval.Id);
            if (currentApproval.Status__c != oldApproval.Status__c && currentApproval.Active__c) {
                // Get list for status
                List<Quote_Approval__c> approvalsForStatus = statusToApprovals.get(currentApproval.Status__c);
                if (approvalsForStatus == null) { // if list is null, create it and insert it into map
                    approvalsForStatus = new List<Quote_Approval__c>();
                    statusToApprovals.put(currentApproval.Status__c, approvalsForStatus);
                }
                // Add approval to list for status
                approvalsForStatus.add(currentApproval);
            } 
        }
        return statusToApprovals;
    }

    public static void handleChangedApprovals(Map<Id, Quote_Approval__c> oldMap, Map<Id, Quote_Approval__c> newMap) {
        // Get approvals that changed status
        Map<String, List<Quote_Approval__c>> changedApprovals = getChangedStatusApprovals(oldMap, newMap);
        Map<Id,QuoteApproval_DataSource> approvalToDatasource = getApprovalToQuoteMap(newMap.values());
        List<Quote_Approval__c> approvedQuoteApprovals = changedApprovals.get(QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_APPROVED);
        List<Quote_Approval__c> revokedQuoteApprovals = changedApprovals.get(QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_REVOKED);
        List<Quote_Approval__c> rejectedQuoteApprovals = changedApprovals.get(QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_REJECTED);
        // approve quotes
        List<QuoteApproval_DataSource> quotesToBeApproved = getFullyApprovedQuotes(approvedQuoteApprovals, approvalToDatasource);
        approveQuotes(quotesToBeApproved);
        // revoke quotes
        rejectOrRevokeAllSiblingApprovals(revokedQuoteApprovals, QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_REVOKED, approvalToDatasource);
        // reject quotes
        rejectOrRevokeAllSiblingApprovals(rejectedQuoteApprovals, QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_REJECTED, approvalToDatasource);
    }

    private static Map<Id,QuoteApproval_DataSource> getApprovalToQuoteMap(List<Quote_Approval__c> quoteApprovals) {
        Set<Id> datasourceIds = new Set<Id>();
        for (Quote_Approval__c currentApproval : quoteApprovals) {
            dataSourceIds.add(currentApproval.ZQuote__c);
        }
        List<QuoteApproval_DataSource> datasources = QuoteApproval_ZQuoteDataSource.massQueryDataSources(new List<Id>(dataSourceIds));
        Map<Id, QuoteApproval_DataSource> idToDatasourceMap = new Map<Id, QuoteApproval_DataSource>();
        for (QuoteApproval_DataSource currentDatasource : datasources) {
            idToDatasourceMap.put(currentDatasource.getDataSourceId(),currentDatasource);
        }
        Map<Id, QuoteApproval_DataSource> approvalToQuote = new Map<Id, QuoteApproval_DataSource>();
        for (Quote_Approval__c currentApproval : quoteApprovals) {
            QuoteApproval_DataSource datasource = idToDatasourceMap.get(currentApproval.ZQuote__c);
            approvalToQuote.put(currentApproval.Id, datasource);
        }
        return approvalToQuote;
    }
    /**
     * Method: handleApprovedApprovals
     * Description:
     *   This method finds any approvals that have just been approved, then checks all its siblings to see if the parent
     *   quote should be approved.
     * Inputs:
     *   Map<Id, Quote_Approval__c> oldMap - Trigger.oldMap
     *   List<Quote_Approval__c> newValues - Trigger.new
     * Return:
     *   None
     */
     /*
    public static void handleApprovedApprovals(Map<Id, Quote_Approval__c> oldMap, List<Quote_Approval__c> newValues) {
        List<Quote_Approval__c> newlyApproved = getNewlyXApprovals(oldMap, newValues, QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_APPROVED);
        List<QuoteApproval_DataSource> fullyApprovedQuoteIds = getFullyApprovedQuotes(newlyApproved);
        approveQuotes(fullyApprovedQuoteIds);
    }
    */

    /**
     * Method: handleRejectedApprovals
     * Description:
     *   This method finds any approvals that have just been rejected, then revokes all its sibling approvals and updates the quote.
     * Inputs:
     *   Map<Id, Quote_Approval__c> oldMap - Trigger.oldMap
     *   List<Quote_Approval__c> newValues - Trigger.new
     * Return:
     *   None
     */
     /*
    public static void handleRejectedApprovals(Map<Id, Quote_Approval__c> oldMap, List<Quote_Approval__c> newValues) {
        List<Quote_Approval__c> newlyRejected = getNewlyXApprovals(oldMap, newValues, QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_REJECTED);
        rejectOrRevokeAllSiblingApprovals(newlyRejected, QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_REJECTED);
    }
    */

    /**
     * Method: handleRevokedApprovals
     * Description:
     *   This method finds any approvals that have just been revoked, then revokes all its sibling approvals and updates the quote.
     * Inputs:
     *   Map<Id, Quote_Approval__c> oldMap - Trigger.oldMap
     *   List<Quote_Approval__c> newValues - Trigger.new
     * Return:
     *   None
     */
     /*
    public static void handleRevokedApprovals(Map<Id, Quote_Approval__c> oldMap, List<Quote_Approval__c> newValues) {
        List<Quote_Approval__c> newlyRevoked = getNewlyXApprovals(oldMap, newValues, QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_REVOKED);
        rejectOrRevokeAllSiblingApprovals(newlyRevoked, QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_REVOKED);
    }
    */

    /* Private Methods */

    /* Returns a list of Quote_Approval__c that have all just had their Status__c field changed to whatever
       status is provided as the "quoteApprovalStatus" argument. */
    private static List<Quote_Approval__c> getNewlyXApprovals(Map<Id, Quote_Approval__c> oldMap, List<Quote_Approval__c> newValues, 
                                                              String quoteApprovalStatus) {
        List<Quote_Approval__c> newlyApprovedApprovals = new List<Quote_Approval__c>();
        for (Quote_Approval__c currentApproval : newValues) {
            Quote_Approval__c oldApproval = oldMap.get(currentApproval.Id);
            if (currentApproval.Status__c == quoteApprovalStatus && oldApproval.Status__c != quoteApprovalStatus) {
                newlyApprovedApprovals.add(currentApproval);
            } 
        }
        System.debug(newlyApprovedApprovals.size() +' newly ' + quoteApprovalStatus + ' approvals');
        return newlyApprovedApprovals;
    }

    private static void rejectOrRevokeAllSiblingApprovals(List<Quote_Approval__c> approvalList, String quoteApprovalStatus, Map<Id, QuoteApproval_Datasource> approvalToDatasource) {
        Set<QuoteApproval_Datasource> datasources = new Set<QuoteApproval_Datasource>();
        Set<Id> approvalIds = new Set<Id>();
        Set<Id> datasourceIds = new Set<Id>();
        for (Quote_Approval__c currentApproval : approvalList) {
            QuoteApproval_Datasource datasource = approvalToDatasource.get(currentApproval.Id);
            datasourceIds.add(datasource.getDataSourceId());
            if (!datasources.contains(dataSource)) datasources.add(datasource);
            approvalIds.add(currentApproval.Id);
        }
        List<Quote_Approval__c> allSiblingApprovals = [SELECT Id, Active__c, Status__c, ZQuote__c
                                                       FROM Quote_Approval__c
                                                       WHERE ZQuote__c in :datasourceIds AND Active__c = true
                                                       AND   Id NOT in :approvalIds
                                                       AND   Status__c = :QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_IN_PROGRESS];

        // Get Ids of all sibling approvals
        Set<Id> siblingApprovalIds = new Set<Id>();
        for (Quote_Approval__c currentApproval : allSiblingApprovals) {
            siblingApprovalIds.add(currentApproval.Id);
        }

        // Recall siblings
        Boolean recallSuccess = QuoteApproval_Utils.recallApprovals(siblingApprovalIds);
        // Change all In Progress Siblings to revoked
        List<Quote_Approval__c> updatedApprovals = new List<Quote_Approval__c>();
        for (Quote_Approval__c quoteApproval : allSiblingApprovals) {
            if (quoteApproval.Status__c == QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_IN_PROGRESS) {
                quoteApproval.Status__c = QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_REVOKED;
                System.debug('Approval: ' + quoteApproval);
                updatedApprovals.add(quoteApproval);
            }
        }
        if (updatedApprovals != null && updatedApprovals.size() > 0) {
            update updatedApprovals;
        } 

        List<SObject> datasourcesSObjects = new List<SObject>();
        for (QuoteApproval_DataSource currentDS : datasources) {
            if (quoteApprovalStatus == QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_REVOKED) {
                currentDS.setStatus(QuoteApproval_Utils.QuoteStatus.QUOTE_STATUS_REVOKED);
            }
            else {
                currentDS.setStatus(QuoteApproval_Utils.QuoteStatus.QUOTE_STATUS_REJECTED);
            }
            QuoteApproval_Utils.QuotePurchaseType currentPurchaseType = currentDS.getPurchaseType();
            if (currentPurchaseType == QuoteApproval_Utils.QuotePurchaseType.QUOTE_PURCHASE_TYPE_NEW) {
                currentDS.setRecordType(QuoteApproval_Utils.QuoteRecordType.QUOTE_RECORD_TYPE_NEW);
            }
            else {
                currentDS.setRecordType(QuoteApproval_Utils.QuoteRecordType.QUOTE_RECORD_TYPE_UPSELL);
            }
            datasourcesSObjects.add(currentDS.getDataSource());
        }
        try {
            update datasourcesSObjects;
        }
        catch (Exception e) {
            new LoggedException(e,'Trouble updated datasources','QuoteApproval_TriggerHandler');
        }
        
    }

    /* Given a list of newly approved quote approvals, returns a list of parent quotes that have been fully approved.
       Fully approved is defined as all quote approvals for the quote being approved. */
    private static List<QuoteApproval_DataSource> getFullyApprovedQuotes(List<Quote_Approval__c> newlyApproved, Map<Id, QuoteApproval_DataSource> approvalToDatasource) {
        Set<Id> quoteIds = new Set<Id>();
        Set<QuoteApproval_DataSource> dsList = new Set<QuoteApproval_DataSource>();
        for (Quote_Approval__c currentApproval : newlyApproved) {
            QuoteApproval_DataSource datasource = approvalToDatasource.get(currentApproval.Id);
            quoteIds.add(dataSource.getDatasourceId());
            dsList.add(datasource);
        }

        // Get all active approvals on all those quotes
        List<Quote_Approval__c> approvals = [SELECT Id, Active__c, Status__c, ZQuote__c
                                             FROM Quote_Approval__c
                                             WHERE ZQuote__c in :quoteIds
                                             AND   Active__c = true];

        Map<Id,List<Quote_Approval__c>> quoteToApprovalMap = new Map<Id,List<Quote_Approval__c>>();

        // Populate map from Quote Id to all its quote approvals
        for (Quote_Approval__c currentApproval : approvals) {
            List<Quote_Approval__c> siblingApprovals = quoteToApprovalMap.get(currentApproval.ZQuote__c);

            // If entry doesn't exist, add it!
            if (siblingApprovals == null) {
                siblingApprovals = new List<Quote_Approval__c>();
                quoteToApprovalMap.put(currentApproval.ZQuote__c,siblingApprovals);
            }
            // Always add current approval to list
            siblingApprovals.add(currentApproval);
        }

        List<QuoteApproval_DataSource> fullyApprovedQuoteDataSources = new List<QuoteApproval_DataSource>();
        // Check if each quote is fully approved
        for (QuoteApproval_DataSource currentDS : dsList) {
            List<Quote_Approval__c> approvalsForQuote = quoteToApprovalMap.get(currentDS.getDataSourceId());
            Boolean isFullyApproved = true;
            // If somehow there are no approvals, don't approve it
            if (approvalsForQuote.isEmpty()) {
                isFullyApproved = false;
            }
            for (Quote_Approval__c currentApproval : approvalsForQuote) {
                // If one is not approved, refuse it
                if (currentApproval.Status__c != QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_APPROVED) {
                    isFullyApproved = false;
                    break;
                }
            }

            // Only if it is fully approved should you add it to the list
            if (isFullyApproved) {
                fullyApprovedQuoteDataSources.add(currentDS);
            } else {
                System.debug('Not Fully approved quote: ' + currentDS.getDataSourceId());
            }
        }

        return fullyApprovedQuoteDataSources;
    }

    /* Give a list of quote ids, approves the quotes */
    private static void approveQuotes(List<QuoteApproval_DataSource> dsList) {

        List<SObject> datasources = new List<SObject>();
        for (QuoteApproval_DataSource currentDS : dsList) {
            currentDS.setStatus(QuoteApproval_Utils.QuoteStatus.QUOTE_STATUS_APPROVED);
            currentDS.setRecordType(QuoteApproval_Utils.QuoteRecordType.QUOTE_RECORD_TYPE_APPROVED);
            datasources.add(currentDS.getDataSource());
        }
        update datasources;
    }   
}