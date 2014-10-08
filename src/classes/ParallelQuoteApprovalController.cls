/**
 * ParallelQuoteApprovalController
 *
 * Description:
 *   This class is a custom controller for the purpose of creating Quote Approvals.
 *   Provided the id of quote, it will determine which approvals are neccessary and
 *   spawn the respective approvals.
 *
 * Public API:
 * 
 *   (constructor) ParallelQuoteApprovalController()
 *   PageReference launchQuoteApprovals()
 *
 * Revision History:
 *   
 *   Kyle Vermeer           1/7/2014        Initial Creation
 *   Kyle Vermeer           1/15/2014       Made to work with QuoteApprovalDataSource
 *
 */
public class ParallelQuoteApprovalController {


    /* Constants */
    
    // URL Parameters
    private static final String ID_PARAMTER_IDENTIFIER = 'id';
    private static final String DATASOURCE_TYPE_PARAMETER_IDENTIFIER = 'datasourceType';

    private static final String  DATASOURCE_TYPE_ZQUOTE = 'zquote';

    // Error Messages
    private static final String ERROR_MESSAGE_OLD_APPROVALS = 'Trouble turning old approvals to inactive';
    private static final String ERROR_MESSAGE_CANT_UPDATE_QUOTE = 'Trouble updating Quote';

    // Constants

    private static final String PROCESS_LAUNCH = 'launch';
    private static final String PROCESS_RECALL = 'recall';
    private static final String PROCESS_UNLOCK = 'unlock';
    

    // Private Member Variables
    private final QuoteApproval_DataSource dataSource; // set in constructor
    private String status = 'Creating Quote Approvals';
    private Boolean success;
    private String quoteFieldName;
    public ErrorTracker et;
    Integer numQuoteApprovalsCreated = 0;
    Integer numQuoteApprovalsRecalled = 0;

    /* Public API */

    /**
     * Only used for remoting.
     *
     * @return {ParallelQuoteAPprovalController}
     * @author Kyle Vermeer 5/1/14
     */
    public ParallelQuoteApprovalController(){

    }

    /**
     * Constructor for controller instance
     *
     * @param {String} datasourceId - Id of datasource to use
     * @param {String} datasourceType - type of datasource to use, currently we only support 'zquote'
     * @return {ParallelQuoteApprovalController}
     */
    public ParallelQuoteApprovalController(String datasourceId, String datasourceType) {
        this.et = new ErrorTracker();
        if (datasourceId == null) { // Check for null required inputs
            System.debug('Null datasource id provided.');
            et.addError('Null datasource id provided');
        }
        // Create datasource
        if (datasourceType == DATASOURCE_TYPE_ZQUOTE || datasourceType == null) {
            this.dataSource = new QuoteApproval_ZQuoteDataSource(dataSourceId);
            this.quoteFieldName = this.dataSource.getQuoteApprovalFieldName();
            if (!this.datasource.didRetrieveDataSourceSuccessfully()) { // If datasource couldn't be accessed, add error!
                et.addError('Could not retrieve quote!');
            }
        }
        else { // If an unknown datasource is provided.
            et.addError('Unknown dataource type: ' + datasourceType);
        }
    }

    @RemoteAction
    public static String launchQuoteApprovals(String datasourceId, String datasourceType) {
        ParallelQuoteApprovalController controller = new ParallelQuoteApprovalController(datasourceId, datasourceType);
        controller.launchQuoteApprovals();
        return controller.createResponseJSON(PROCESS_LAUNCH);
    }

    /**
     * This method launches all the quote approvals for the current quote.  
     *
     * It first determines which approvals are necessary, then launches those approvals.
     * 
     * @return {Boolean} - true if approvals were launched successfully, false otherwise
     * @author Kyle Vermeer 5/1/2014
     */
    public Boolean launchQuoteApprovals() {
        // Launch approvals
        if (this.dataSource.didRetrieveDataSourceSuccessfully()) { // Was able to retrieve quote from id in URL
            prepareQuoteForApprovals();
            QuoteApproval_Decider quoteApprovalDecider = new QuoteApproval_Decider(this.datasource, this.et);
            List<Quote_Approval__c> quoteApprovalsList = quoteApprovalDecider.getApprovalsNeeded();
            if (quoteApprovalsList.size() <= 0) { // Should be auto-approved
                return approveQuote(this.datasource);
            } 
            else { // Requires approval
                this.numQuoteApprovalsCreated = quoteApprovalsList.size();
                try {
                    insert quoteApprovalsList;
                    sendApprovalRequests(quoteApprovalsList);
                    return true;
                }
                catch (Exception e) {
                    et.addError('Trouble inserting new approvals!');
                    new LoggedException(e,'Trouble inserting new approvals','ParallelQuoteApprovalController', new List<Id> {this.dataSource.getDataSourceId()});
                    return false;
                }
                
            }
        }
        // If the data source wasn't grabbed successfully, nothing could have gone right
        return false;
    }

    @RemoteAction
    public static String recallQuoteApprovals(String datasourceId, String datasourceType) {
        ParallelQuoteApprovalController controller = new ParallelQuoteApprovalController(datasourceId, datasourceType);
        controller.recallQuoteApprovals();
        return controller.createResponseJSON(PROCESS_RECALL);
    }

    @RemoteAction
    public static String unlockQuote(String datasourceId, String datasourceType) {
        ParallelQuoteApprovalController controller = new ParallelQuoteApprovalController(datasourceId, datasourceType);
        controller.unlockQuote();
        return controller.createResponseJSON(PROCESS_UNLOCK);
    }
    
    /**
     * Method: recallQuoteApprovals()
     * Description:
     *   This method recalls all the active quote approvals for the quote.
     * Inputs:
     *   None
     * Return:
     *   PageRefernce - location to go after processing is complete
     */
    public Boolean recallQuoteApprovals() {
        if (this.dataSource.didRetrieveDataSourceSuccessfully()) { // Was able to retrieve quote from id in URL
            return this.unlockQuote();
        }
        return false;
    }

    /**
     * This method unlocks the quote and turns all active quote to inactive.
     * 
     * @return {Boolean} - true on success, false otherwise
     * @author Kyle Vermeer 5/2/14
     */
    public Boolean unlockQuote() {
        if (this.dataSource.didRetrieveDataSourceSuccessfully()) {
            try {
                Id dataSourceId = this.dataSource.getDataSourceId();
                // Get approvals
                String query = 'SELECT Id' +
                                ' FROM Quote_Approval__c' +
                               ' WHERE ' + this.quoteFieldName + ' = :dataSourceId' +
                                 ' AND Active__c = true';
                System.debug('Query: ' + query);
                List<Quote_Approval__c> oldApprovals = Database.query(query);
                
                // Inactivate all old approvals          
                if (!oldApprovals.isEmpty()) { // If there are no active approvals, no need to do anything  
                    for (Quote_Approval__c currentApproval : oldApprovals) {
                        currentApproval.Active__c = false;
                    }
                    update oldApprovals;
                    this.numQuoteApprovalsRecalled = oldApprovals.size();
                }

                // Set Record Type
                if (this.dataSource.getPurchaseType() == QuoteApproval_Utils.QuotePurchaseType.QUOTE_PURCHASE_TYPE_NEW) {
                    this.dataSource.setRecordType(QuoteApproval_Utils.QuoteRecordType.QUOTE_RECORD_TYPE_NEW);
                }
                else {
                    this.dataSource.setRecordType(QuoteApproval_Utils.QuoteRecordType.QUOTE_RECORD_TYPE_UPSELL);
                }
                // Set Status
                this.dataSource.setStatus(QuoteApproval_Utils.QuoteStatus.QUOTE_STATUS_REVOKED);
                // Save datasource
                return this.dataSource.saveDataSource();
            } catch (Exception e) {
                et.addError('Issue recalling approvals. Contact Sales Systems.');
                LoggedException loggedE = new LoggedException(e,'Issue recalling approvals','ParallelQuoteApprovalController');
                return false;
            }
        }
        // datasource wasn't retrieved
        return false;
    }

    // Get status
    public String getStatus() {
        return status;
    }

    // Get success
    public Boolean getSuccess() {
        return success;
    }

    /////////////////////////
    // Private Methods
    ////////////////////////

    /* Updates the quote to change it into an Approved state.  Returns true on success, false otherwise */
    private boolean approveQuote(QuoteApproval_DataSource ds) {
        // First update status and record type
        /*
        ds.setStatus(QuoteApprovalUtils.QUOTE_APPROVED_STATUS);
        ds.setRecordType( QuoteApprovalUtils.getRecordTypeId(ds.getDataSourceObjectName(),'Approved') );
        return ds.saveDataSource();
        */
        return true;
    }

    /**
     * Prepares a quote for approval. After this method is called, a quote is ready for new approvals.
     *
     * @return {Boolean} - true if quote was successfully prepared, false otherwise
     * @author Kyle Vermeer 5/1/14
     */
    private Boolean prepareQuoteForApprovals() {
        QuoteApproval_DataSource ds = this.dataSource;
        // Set to Locked and update the status
        ds.setRecordType(QuoteApproval_Utils.QuoteRecordType.QUOTE_RECORD_TYPE_LOCKED);
        ds.setStatus(QuoteApproval_Utils.QuoteStatus.QUOTE_STATUS_IN_REVIEW);
        Boolean turnedOffOldApprovals = turnOldApprovalsToInactive();
        return (turnedOffOldApprovals && ds.saveDataSource());
    }

    /**
     * Deactivates all old approvals for the datasource.
     *
     * Note that this method both sets the old approvals to Active__c = false and also recalls the actual
     * salesforce approvals tied to them.
     *
     * @return {Boolean} - true if successful, false if errors occured
     * @author Kyle Vermeer
     * @revision Kyle Vermeer 5/1/14 Updated method for ZQuotes
     */
    private Boolean turnOldApprovalsToInactive() {
        try {
            Id dataSourceId = this.dataSource.getDataSourceId();
            if (dataSourceId == null) { // Make sure datasource id is not null
                System.debug('Datasource Id was null, cannot turn of old approvals.');
                return false;
            }
            // Get approvals
            String query = 'SELECT Id, Active__c,' + this.quoteFieldName +
                            ' FROM Quote_Approval__c' +
                           ' WHERE ' + this.quoteFieldName + ' = :dataSourceId' +
                             ' AND Active__c = true';
            System.debug('Query: ' + query);
            List<Quote_Approval__c> oldApprovals = Database.query(query);
                               
            if (oldApprovals.isEmpty()) { // If there are no active approvals, return true   
                return true;
            } 
            else { // Set old active approvals to inactive
                Set<Id> quoteApprovalIds = new Set<ID>();
                for (Quote_Approval__c currentApproval : oldApprovals) {
                    currentApproval.Active__c = false;
                    quoteApprovalIds.add(currentApproval.Id);
                }
                // Recall the actual approvals (salesforce approvals, not Quote_Approval__c)
                QuoteApproval_Utils.recallApprovals(quoteApprovalIds);
                update oldApprovals;
                this.numQuoteApprovalsRecalled = quoteApprovalIds.size();
                return true;
            }
        } catch (Exception e) { // Trouble with queries or recalling approvals
            this.et.addError(ERROR_MESSAGE_OLD_APPROVALS);
            LoggedException loggedE = new LoggedException(e,ERROR_MESSAGE_OLD_APPROVALS,'ParallelQuoteApprovalController');
            return false;
        }
    }


    /* Given a list of Quote_Approval__c, launches those approvals. Returns true on success, false otherwise */ 
    private Boolean sendApprovalRequests(List<Quote_Approval__c> quoteApprovals) {
        // Iterate through approvals, launch one by one
        for (Quote_Approval__c currentApproval : quoteApprovals) {
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setObjectId(currentApproval.Id);
            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(request);
            if (!result.isSuccess()) {
                return false;
            }
        }
        return true;
    }

    /**
     * Translates the quote approval process results into a JSON response.
     *
     * @param {String} process - 'launch', 'recall', or 'unlock'
     * @return {String} - json representation of quote approval launching results
     * @author Kyle Vermeer 5/1/14
     */
    public String createResponseJSON(String process) {
        // Bring member variales into local variables to avoid any confusion
        String datasourceId = this.datasource.getDataSourceId();
        Integer numQuoteApprovals = this.numQuoteApprovalsCreated; 
        ErrorTracker et = this.et;
        // Write json object
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        if (dataSourceId != null) { // write a json field for datasource
            gen.writeIdField('dataSourceId', dataSourceId);
        }
        else { // If datasource is null, just send it over as null
            gen.writeNullField('dataSourceId');
        }
        Integer quoteApprovalDelta = 0;
        if (process == PROCESS_LAUNCH) {
            quoteApprovalDelta = this.numQuoteApprovalsCreated;
        }
        else if (process == PROCESS_RECALL || process == PROCESS_UNLOCK) {
            quoteApprovalDelta = this.numQUoteAPprovalsRecalled;
        } 
        gen.writeNumberField('numQuoteApprovals', quoteApprovalDelta);
        gen.writeBooleanField('success', !et.hasErrors());
        gen.writeObjectField('errors', et.getErrorList());
        gen.writeStringField('action', process);
        gen.writeEndObject();
        String jsonString = gen.getAsString();
        gen.close();
        return jsonString;
    }
}