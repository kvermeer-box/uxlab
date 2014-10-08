/**
 * This class provides constants and utility methods for the Quote Approval system.
 *
 * @author Kyle Vermeer <kvermeer@box.com> 4/24/2014
 */

public class QuoteApproval_Utils {

    ////////////////////
    // Enums
    ////////////////////
    
    public enum QuotePurchaseType {
        QUOTE_PURCHASE_TYPE_NEW,
        QUOTE_PURCHASE_TYPE_UPSELL,
        QUOTE_PURCHASE_TYPE_RENEWAL,
        QUOTE_PURCHASE_TYPE_UNKNOWN
    }

    public enum QuoteRecordType {
        QUOTE_RECORD_TYPE_NEW,
        QUOTE_RECORD_TYPE_UPSELL,
        QUOTE_RECORD_TYPE_LOCKED,
        QUOTE_RECORD_TYPE_APPROVED
    }

    public enum QuoteStatus {
        QUOTE_STATUS_DRAFT,
        QUOTE_STATUS_IN_REVIEW,
        QUOTE_STATUS_REJECTED,
        QUOTE_STATUS_REVOKED,
        QUOTE_STATUS_APPROVED
    }

    ////////////////////
    // Structs
    ////////////////////

    public class ProductDiscount {

        public String approvalProcessCode;
        public Integer quantity;
        public Double discount;
        public String productId;
    }

    private static final Quote_Approval_Settings__c settings = CustomSettings.getQuoteApprovalSettings();

    //////////////////////
    // Public Constants
    //////////////////////

    public static final String QUERY_WILDCARD_STRING = '*';
    public static final String AUTO_APPROVED_ROLES = (settings != null) ? settings.Teams_For_Auto_Approve__c : 'Renewals;';
    // Approval Types
    public static final String APPROVAL_TYPE_LICENSE = 'License';
    public static final String APPROVAL_TYPE_UNLIMITED_STORAGE = 'Unlimited Storage';
    public static final String APPROVAL_TYPE_BOX_CONSULTING = 'Box Consulting';
    public static final String APPROVAL_TYPE_SCALE = 'Scale';
    public static final String APPROVAL_TYPE_ROPS = 'ROPS';
    public static final String APPROVAL_TYPE_SOPS = 'Renewal Date';
    public static final String APPROVAL_TYPE_PREMIER_SUPPORT = 'Premier Support';
    // Sales Approver Product Types
    public static final String PRODUCT_TYPE_LICENSE = 'License';
    public static final String PRODUCT_TYPE_BOX_CONSULING = 'Box Consulting';
    public static final String PRODUCT_TYPE_PREMIER_SUPPORT = 'Premier Support';
    // Rops Approval Settings
    public static final String PAYMENT_TERMS_WITH_NO_APPROVAL = (settings != null) ? settings.Payment_Terms_For_Auto_Approve__c : 'Net 30';
    // Quote Statuses
    public static final String QUOTE_APPROVED_STATUS = 'Approved';
    public static final String QUOTE_REJECTED_STATUS = 'Rejected';
    public static final String QUOTE_REVOKED_STATUS = 'Draft';
    public static final String QUOTE_IN_REVIEW_STATUS = 'In Review';
    public static final String QUOTE_APPROVED_RECORD_TYPE_ID = '012600000009W4m';
    // Quote Purchase Type
    public static final String QUOTE_PURCHASE_TYPE_UPSELL = 'Upsell';
    public static final String QUOTE_PURCHASE_TYPE_NEW_ARGREEMENT = 'New Agreement';
    // Quote Data Confidence Level
    public static final String QUOTE_DATA_CONFIDENCE_LEVEL_WEAK = 'Weak';
    public static final String QUOTE_DATA_CONFIDENCE_LEVEL_MEDIUM = 'Medium';
    public static final String QUOTE_DATA_CONFIDENCE_LEVEL_STRONG = 'Strong';
    // Quote Approval Statues
    public static final String QUOTE_APPROVAL_STATUS_IN_PROGRESS = 'In Progress';
    public static final String QUOTE_APPROVAL_STATUS_APPROVED = 'Approved';
    public static final String QUOTE_APPROVAL_STATUS_REJECTED = 'Rejected';
    public static final String QUOTE_APPROVAL_STATUS_REVOKED = 'Revoked';

    private static final String REVOKED_BY_OTHER_APPROVAL_PROCESS_COMMENT = 'This approval was revoked because another active approval was either revoked or rejected.';

    /////////////////
    // Public API
    /////////////////


    /**
     * Method: recallApprovals()
     * Availability: public, static
     * Description:
     *   Recalls approvalRequests for the given Quote_Approval__c ids
     *   provided.  Returns true on success, false otherwise. Note, this
     *   only recalls the system approvals, it does not update the Quote_Approval__c
     *   objects themselves.
     * Inputs:
     *   Set<Id> approvalIds - Set of Quote_Approvals__c that should be recalled.
     * Return:
     *   Id - Id of record type.
     */  
    public static boolean recallApprovals(Set<ID> approvalIds){

        boolean success = true;

        List<ProcessInstanceWorkitem> processInstanceWorkitemList = getProcessInstanceWorkitems(approvalIds);
        
        if (processInstanceWorkitemList==null || processInstanceWorkitemList.size()==0)
            return success;
        
        List<Approval.ProcessWorkitemRequest> processRequests  = new List<Approval.ProcessWorkitemRequest>();
        
        // Create ProcessWorkItemRequests to revoke the approval requests
        for(ProcessInstanceWorkitem processInstanceWorkitem : processInstanceWorkitemList){
            
            Approval.ProcessWorkitemRequest  workItemReq = new Approval.ProcessWorkitemRequest();
            workItemReq.setWorkitemId(processInstanceWorkitem.ID);
            workItemReq.setAction('Removed');
            workItemReq.setComments(REVOKED_BY_OTHER_APPROVAL_PROCESS_COMMENT);
                
            // Submit the approval request for the account
            processRequests.add(workItemReq);
        }

        // Check to make sure the recalling was a success
        if(processRequests.size()>0){
            List<Approval.ProcessResult> results =   Approval.process(processRequests,false);
            for(Approval.ProcessResult result: results){
                if(!result.isSuccess()){
                    success = false;
                    for (Database.error err : result.getErrors()){
                        System.debug('Approval Recall Error: err.getMessage()');
                    }
                }   
            }
        }
        return success;
    }

    /////////////////////
    // Private Methods
    /////////////////////

    /* Given a list of approval ids, returns the list of processInstanceWorkItems related to them */
    private static List<ProcessInstanceWorkitem> getProcessInstanceWorkitems(Set<ID> approvalIds){

        if (approvalIds==null || approvalIds.size()==0)
            return new List<ProcessInstanceWorkitem>();

        List<ProcessInstanceWorkitem> processInstanceWorkitemList = 
            [Select p.Id, p.ProcessInstanceId, p.ProcessInstance.TargetObjectId 
                from ProcessInstanceWorkitem p 
                where p.ProcessInstance.TargetObjectId in :approvalIds AND p.ProcessInstance.status='Pending'];
        
        return processInstanceWorkitemList;
    }
}