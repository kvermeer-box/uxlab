/**
 * Controller supporting the QuoteApproval_List Visualforce page
 *
 * @author Kyle Vermeer <kvermeer@box.com> 5/5/14
 */
public class QuoteApproval_ListExtension {
   
    private final Zqu__Quote__c currentQuote;

    private List<ApprovalDisplay> activeApprovals;
    private List<ApprovalDisplay> allApprovals;

    private boolean onlyShowActive;

    private static final String ONLY_ACTIVE_BUTTON_TEXT = 'Show Inactive Approvals';
    private static final String ALL_BUTTON_TEXT = 'Only Show Active';

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public QuoteApproval_ListExtension(ApexPages.StandardController stdController) {
        this.currentQuote = (Zqu__Quote__c)stdController.getRecord();
        onlyShowActive = true;
    }

    private List<ApprovalDisplay> getActiveApprovals() {
        if (activeApprovals == null) {
            List<Quote_Approval__c> approvalsList = [SELECT Id, Status__c, Type__c, Active__c, Current_Approver__c, ZQuote__c, Payment_Frequency__c
                                                       FROM Quote_Approval__c
                                                      WHERE ZQuote__c = :this.currentQuote.Id
                                                        AND Active__c = true];
            activeApprovals = new List<ApprovalDisplay>();
            for (Quote_Approval__c currentApproval : approvalsList) {
                activeApprovals.add(new ApprovalDisplay(currentApproval));
            }
        }
        return activeApprovals;
    }

    private List<ApprovalDisplay> getAllApprovals() {
        if (allApprovals == null) {
            List<Quote_Approval__c> approvalsList = [SELECT Id, Status__c, Type__c, Active__c, Current_Approver__c, ZQuote__c, Payment_Frequency__c
                                                       FROM Quote_Approval__c
                                                      WHERE ZQuote__c = :this.currentQuote.Id
                                                   ORDER BY CreatedDate DESC];
            allApprovals = new List<ApprovalDisplay>();
            for (Quote_Approval__c currentApproval : approvalsList) {
                allApprovals.add(new ApprovalDisplay(currentApproval));
            }
        }
        return allApprovals;
    }

    public List<ApprovalDisplay> getApprovals() {
        if (onlyShowActive) {
            return getActiveApprovals();
        }
        else {
            return getAllApprovals();
        }
    }

    public void toggleShowActive() {
        this.onlyShowActive = !this.onlyShowActive;
    }

    public String getButtonText() {
        if (this.onlyShowActive) {
            return ONLY_ACTIVE_BUTTON_TEXT;
        }
        else {
            return ALL_BUTTON_TEXT;
        }
    }

    public boolean getApprovalsEmpty() {
        if (this.getApprovals().size() <= 0) {
            return true;
        }
        else {
            return false;
        }
    }

    private static final String IN_PROGRESS_COLOR = '#766201';
    private static final String REVOKED_COLOR = '#8B0000';
    private static final String REJECTED_COLOR = '#8B0000';
    private static final String APPROVED_COLOR = '#458B00';
    private static final String ERROR_COLOR = '#000000';

    public class ApprovalDisplay {
        public Quote_Approval__c approval;
        public String color;

        public ApprovalDisplay(Quote_Approval__c approval) {
            this.approval = approval;
            this.color = hexForApproval(approval);
        }

        private String hexForApproval(Quote_Approval__c approval) {
            if (approval.Status__c == QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_IN_PROGRESS) {
                return IN_PROGRESS_COLOR;
            }
            else if (approval.Status__c == QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_REVOKED) {
                return REVOKED_COLOR;
            }
            else if (approval.Status__c == QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_REJECTED) {
                return REJECTED_COLOR;
            }
            else if (approval.Status__c == QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_APPROVED) {
                return APPROVED_COLOR;
            }
            else {
                // ERROR
                return ERROR_COLOR;
            }
        }

        public String getColor() {
            return this.color;
        }

        public Quote_Approval__c getApproval() {
            return this.approval;
        }
    }
}