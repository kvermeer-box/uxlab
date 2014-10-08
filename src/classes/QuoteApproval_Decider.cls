/**
 * This class contains the logic for deciding what quote approvals should be launched.
 *
 * @author Kyle Vermeer 4/25/2014
 */
public class QuoteApproval_Decider {

    //////////////////////////////
    // Private Member Variables
    //////////////////////////////

    // The datasource to detemine which approvals are needed
    private QuoteApproval_DataSource datasource;
    // Stored to prevent re-querying this value
    private String ownerRoleName;
    // ErrorTracker that gather debug and error info
    private ErrorTracker et;
    
    ///////////////////
    // Constructors
    ///////////////////

    /**
     * Constructor for QuoteApproval_Decider
     *
     */
    public QuoteApproval_Decider(QuoteApproval_DataSource datasource, ErrorTracker et) {
        this.datasource = datasource;
        this.et = et;
        if (this.datasource.didRetrieveDataSourceSuccessfully()) {
            Id ownerId = this.datasource.getOwnerId();
            User qOwner = [SELECT UserRole.Name FROM User WHERE Id = :ownerId];
            this.ownerRoleName = qOwner.UserRole.Name;
        } 
    }

    ///////////////////
    // Public API
    ///////////////////

    /**
     * Returns a List of all the approvals neccessary for this quote.
     *
     * @return {List<Quote_Approval__c>} - List of all Quote Approvals needed.
     */
    public List<Quote_Approval__c> getApprovalsNeeded() {
        return generateQuoteApprovalsNeeded();
    }

    /////////////////////
    // Private Methods
    /////////////////////

    /**
     * This methods determines which approvals are needed for the datasource.
     *
     * @return {List<Quote_Approval__c>} - List of quote approvals for datasource
     */
    private List<Quote_Approval__c> generateQuoteApprovalsNeeded() {
        List<Quote_Approval__c> quoteApprovals = new List<Quote_Approval__c>();
        // Auto approve renewals
        List<String> autoApprovedRolesList = QuoteApproval_Utils.AUTO_APPROVED_ROLES.split(';');
        for (String autoApprovedRole : autoApprovedRolesList) {
            if (this.ownerRoleName.contains(autoApprovedRole)) {
                return quoteApprovals;
            }
        }
        // Product Approvals
        List<Quote_Approval__c> productApprovals = getProductApprovals();
        quoteApprovals.addAll(productApprovals);

        // Rops
        Quote_Approval__c ropsApproval = getRopsApproval();
        if (ropsApproval != null) {
            quoteApprovals.add(ropsApproval);
        }

        // Renewal Date
        Quote_Approval__c renewalDateApproval = getRenewalDateApproval();
        if (renewalDateApproval != null) {
            quoteApprovals.add(renewalDateApproval);
        }

        // If there are any errors, don't launch those approvals!
        if (this.et.hasErrors()) {
            quoteApprovals.clear();
        }

        return quoteApprovals;
    }

    /**
     * Determines all product approvals necessary and filters them, then returns the list fo approvals.
     *
     * @return {List<Quote_Approval__c>} - quote approvals necessary
     */
    private List<Quote_Approval__c> getProductApprovals() {
        List<Quote_Approval__c> approvalsNeeded = new List<Quote_Approval__c>();
        // Get product discount map
        Map<String, List<Quote_Approval__c>> allApprovalsMap = createProductTypeToApprovalsMap();
        // Filter out less important approvals

        // Filter out previously discounted licenses
        List<Quote_Approval__c> licenseApprovals = allApprovalsMap.get(QuoteApproval_Utils.PRODUCT_TYPE_LICENSE);
        if (licenseApprovals != null && licenseApprovals.size() != 0) {
            Integer numberOfQuoteApprovals = licenseApprovals.size();
            System.debug('Number of quote approvals: ' + numberOfQuoteApprovals);
            for (Integer i = numberOfQuoteApprovals-1; i >= 0; i--) {
                Quote_Approval__c approval = licenseApprovals.get(i);
                if (this.datasource.hasLicenseBeenDiscountedMorePreviously((Double)approval.Discount__c)) {
                    System.debug('Removing approval!');
                    licenseApprovals.remove(i);
                }
            }
        }
        // for now, just sending all approvals
        for (List<Quote_Approval__c> currentApprovalList : allApprovalsMap.values()) {
            approvalsNeeded.addAll(currentApprovalList);
        }
        return approvalsNeeded;
    }

    /**
     * Returns a map from type (License, Professional Services, etc.) to the list of quote approvals for that type.
     *
     * @return Map<String, List<Quote_Approval__c>> - map from produc type (License, Professional Services, etc.) to approvals for that type
     */
    private Map<String, List<Quote_Approval__c>> createProductTypeToApprovalsMap() {
        Map<String, List<Quote_Approval__c>> typeToApprovalMap = new Map<String, List<Quote_Approval__c>>();
        // Get map from approval process codes to all products that use that approval process
        Map<String, List<QuoteApproval_Utils.ProductDiscount>> productDiscountMap = this.datasource.getProductDiscountMap();
        if (productDiscountMap == null) { // Make sure the product discount map isn't null
            et.addError('Trouble creating a list of the discounts on each product');
            return null;
        }
        // Get a set of all necessary approval codes
        Set<String> approvalProcessCodes = productDiscountMap.keySet();
        SalesApproverDirectory directory = new SalesApproverDirectory(this.et);
        // Get a map from approvalProcessCode to all the buckets for that approval process
        Map<String,List<Product_Discount_Matrix_Entry__c>> codeToBuckets = getApprovalProcessToBuckets(approvalProcessCodes);
        // For each approval process code, determine approvals required
        for (String approvalProcessCode : productDiscountMap.keySet()) {
            List<QuoteApproval_Utils.ProductDiscount> productDiscounts = productDiscountMap.get(approvalProcessCode);
            List<Product_Discount_Matrix_Entry__c> bucketsForCode = codeToBuckets.get(approvalProcessCode);
            if (bucketsForCode == null) {
                System.debug('No buckets for this code!');
            }
            // For each discount for this code, determine the bucket
            for (QuoteApproval_Utils.ProductDiscount currentProductDiscount : productDiscounts) {
                Quote_Approval__c quoteApproval = createQuoteApprovalForProduct(currentProductDiscount, bucketsForCode, directory);
                if (quoteApproval != null) { // if not null, add to map
                    // Get current list for approval type
                    List<Quote_Approval__c> approvalsForType = typeToApprovalMap.get(quoteApproval.Type__c);
                    if (approvalsForType == null) { // If list is null, create it!
                        approvalsForType = new List<Quote_Approval__c>();
                        typeToApprovalMap.put(quoteApproval.Type__c, approvalsForType);
                    }
                    // Add current approval to list of approals for current type
                    System.debug('Adding approval: ' + quoteApproval);
                    approvalsForType.add(quoteApproval);
                }
            }
        }
        return typeToApprovalMap;
    }

    /**
     * This method creates a Quote_Approval__c object for a product discount.
     *
     * @param {QuoteApproval_Utils.ProductDiscount} productDiscount - The product discount used to create the Quote Approval
     * @param {List<Product_Discount_Matrix_Entry__c>} buckets - A list of discount matrix entries buckets for the approval process code speficied by the product discount
     * @param {SalesApproverDirectory} directory - directory of sales approver for quick look up
     * @return {Quote_Approval__c} - A quote approval that has not yet been inserted into the database
     */
    private Quote_Approval__c createQuoteApprovalForProduct(QuoteApproval_Utils.ProductDiscount productDiscount, List<Product_Discount_Matrix_Entry__c> buckets, SalesApproverDirectory directory) {
        if (productDiscount == null || buckets == null) { // Check for null inputs
            System.debug('Null required input! productDiscount: ' + productDiscount + '; buckets: ' + buckets);
            return null;
        }
        // Initialize Approval
        Quote_Approval__c approval = new Quote_Approval__c(ZQuote__c = this.datasource.getDataSourceId(), 
                                                           Active__c = true,
                                                           Discount__c = productDiscount.discount,
                                                           Status__c = QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_IN_PROGRESS);
        Decimal quantity = productDiscount.quantity;
        Boolean requiresSomeApproval = false;
        System.debug('Discount: ' + approval.Discount__c + '; Quantity: ' + quantity);
        // Loop through each bucket to find the right one
        for (Product_Discount_Matrix_Entry__c currentBucket : buckets) {
            // Once we've found the right bucket, determine what levels of approvals the quote needs
            if (currentBucket.Min_Seats__c <= quantity && currentBucket.Max_Seats__c >= quantity) {
                if (approval.Discount__c >= currentBucket.Min_Discount_for_Manager_Approval__c) {
                    approval.Requires_Manager_Approval__c = true;
                    requiresSomeApproval = true;
                }
                if (approval.Discount__c >= currentBucket.Min_Discount_for_Level_1_Approval__c) {
                    approval.Requires_Level_1_Approval__c = true;
                    requiresSomeApproval = true;
                }
                if (approval.Discount__c >= currentBucket.Min_Discount_for_Level_2_Approval__c) {
                    approval.Requires_Level_2_Approval__c = true;
                    requiresSomeApproval = true;
                }
                if (approval.Discount__c >= currentBucket.Min_Discount_for_Level_3_Approval__c) {
                    approval.Requires_Level_3_Approval__c = true;
                    requiresSomeApproval = true;        
                }
                if (approval.Discount__c >= currentBucket.Min_Discount_for_Level_4_Approval__c) {
                    approval.Requires_Level_4_Approval__c = true;
                    requiresSomeApproval = true;
                }
                approval.Approval_Process_Code__c = currentBucket.Approval_Process_Code__c;
                approval.Approver_Code__c = currentBucket.Sales_Approver_Code__c;
                approval.Type__c = currentBucket.Product_Type__c;
            }
        }
        // If the approval needs some approval, fill in the approvers
        if (requiresSomeApproval) {
            String userID = this.datasource.getOwnerId();
            String theater = UserRoleUtils.getTheater(this.ownerRoleName);
            String salesDivision = UserRoleUtils.getSegment(this.ownerRoleName);
            String team = UserRoleUtils.getTeam(this.ownerRoleName);
            Sales_Approver_Matrix_Entry__c salesApproverEntry = directory.getEntry(approval.Approver_Code__c, theater, salesDivision, team);
            if (salesApproverEntry == null) {
                // If this approval only requires manager approval, just provide that
                if (!approval.Requires_Level_1_Approval__c && !approval.Requires_Level_2_Approval__c && !approval.Requires_Level_3_Approval__c && !approval.Requires_Level_4_Approval__c) {
                    approval.Manager__c = this.datasource.getManagerId();
                }
                else { // if it requires more than manager approval, throw an error
                    et.addError('Could not find list of approvers for Sales Approver Code: ' + approval.Approver_Code__c + '; Theater: ' + theater + '; Sales Division: ' + salesDivision + '; Team: ' + team);
                    return null;
                }
            }
            else { // salesApproverEntry is not null
                approval.Manager__c = this.datasource.getManagerId();
                approval.Level_1_Approver__c = salesApproverEntry.Level_1_Approver__c;
                approval.Level_2_Approver__c = salesApproverEntry.Level_2_Approver__c;
                approval.Level_3_Approver__c = salesApproverEntry.Level_3_Approver__c;
                approval.Level_4_Approver__c = salesApproverEntry.Level_4_Approver__c;
            }
            return approval;
        }
        else {
            System.debug('Doesn\'t require any approval!');
            return null;
        }
    }

    /**
     * Creates a map that groups Product_Discount_Matrix_Entries by approval process codes, for the codes provided.
     *
     * @param {Set<String>} approvalProcessCodes - code for which the query the discount entries
     * @return {Map<String,List<Product_Discount_Matrix_Entry__c>>} - map that groups PDMEs by approval code
     * @author Kyle Vermeer
     */
    private Map<String,List<Product_Discount_Matrix_Entry__c>> getApprovalProcessToBuckets(Set<String> approvalProcessCodes) {
        if (approvalProcessCodes == null) { // Check for null inputs
            System.debug('Null input provided.');
            return null;
        }
        Map<String,List<Product_Discount_Matrix_Entry__c>> processCodeToBuckets = new Map<String,List<Product_Discount_Matrix_Entry__c>>();
        if (approvalProcessCodes.isEmpty()) { // If empty input, just return empty list
            return processCodeToBuckets;
        }
        else { // Non-empty list, querying for Product Discount Matrix Entries, then group them by approval process code
            try {
                List<Product_Discount_Matrix_Entry__c> pdmes = [SELECT Id, Min_Seats__c, Max_Seats__c, Approval_Process_Code__c,
                                                                       Min_Discount_for_Manager_Approval__c,
                                                                       Min_Discount_for_Level_1_Approval__c,
                                                                       Min_Discount_for_Level_2_Approval__c,
                                                                       Min_Discount_for_Level_3_Approval__c,
                                                                       Min_Discount_for_Level_4_Approval__c,
                                                                       Product_Type__c,
                                                                       Sales_Approver_Code__c
                                                                  FROM Product_Discount_Matrix_Entry__c
                                                                 WHERE Approval_Process_Code__c IN :approvalProcessCodes
                                                              ORDER BY Min_Seats__c];
                // Now group matrix entries by approval process code (in map)
                for (Product_Discount_Matrix_Entry__c currentPdme : pdmes) {
                    String code = currentPdme.Approval_Process_Code__c;
                    List<Product_Discount_Matrix_Entry__c> entriesForThisCode = processCodeToBuckets.get(code);
                    if (entriesForThisCode == null) { // No entries for this code yet, create the list
                        entriesForThisCode = new List<Product_Discount_Matrix_Entry__c>();
                        processCodeToBuckets.put(code,entriesForThisCode);
                    }
                    // Add entry to list
                    entriesForThisCode.add(currentPdme);
                }
            }
            catch (Exception e) {
                et.addError('Issue querying for Product Discount Matrix Entries.');
                new LoggedException(e,'Issue querying for Product Discount Matrix Entries.','QuoteApproval_Decider', new List<Id> {this.datasource.getDataSourceId()});

            }
        }
        return processCodeToBuckets;
    }

    /**
     * Returns a Quote Approval if the datasource requires Revenue Ops approval.
     *
     * @return {Quote_Approval__c} - the ROPs quote approval
     */
    private Quote_Approval__c getRopsApproval() {
        String paymentTerms = this.datasource.getPaymentTerms();

        // Check if payment terms doesn't require approval
        List<String> noApprovalPaymentTermsList = QuoteApproval_Utils.PAYMENT_TERMS_WITH_NO_APPROVAL.split(';');
        Boolean requiresApproval = true;
        if (paymentTerms == null) {
            requiresApproval = false;
        }
        for (String noApprovalPaymentTerms : noApprovalPaymentTermsList) {
            if (paymentTerms == noApprovalPaymentTerms) {
                requiresApproval = false;
            }
        }

        if (requiresApproval) { // Does require approval
            Quote_Approval__c quoteApproval = new Quote_Approval__c(ZQuote__c = this.datasource.getDataSourceId(), 
                                                                    Active__c = true, 
                                                                    Type__c = QuoteApproval_Utils.APPROVAL_TYPE_ROPS,
                                                                    Status__c = QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_IN_PROGRESS,
                                                                    Manager__c = this.datasource.getManagerId(),
                                                                    Payment_Terms__c = paymentTerms);
            return quoteApproval;
        }
        else { // Doesn't require approval
            return null;
        }
    }

    /**
     * Returns a renewal date approval if we are unconfident about the renewal date
     *
     * @return {Quote_Approval__c} - the renewal date approval
     */
     private Quote_Approval__c getRenewalDateApproval() {
        String confidenceLevel = this.datasource.getDataConfidenceLevel();
        System.debug('Confidence LEVEL: ' + confidenceLevel);
        QuoteApproval_Utils.QuotePurchaseType purchaseType = this.datasource.getPurchaseType();

        // If data confidence is not storng and is upsell, requires SOPS approval
        if (confidenceLevel != QuoteApproval_Utils.QUOTE_DATA_CONFIDENCE_LEVEL_STRONG && 
            purchaseType == QuoteApproval_Utils.QuotePurchaseType.QUOTE_PURCHASE_TYPE_UPSELL) {
            Quote_Approval__c quoteApproval = new Quote_Approval__c(ZQuote__c = this.datasource.getDataSourceId(), 
                                                                    Active__c = true, 
                                                                    Type__c = QuoteApproval_Utils.APPROVAL_TYPE_SOPS,
                                                                    Status__c = QuoteApproval_Utils.QUOTE_APPROVAL_STATUS_IN_PROGRESS);
            return quoteApproval;
        }
        return null;
    }

    /**
     * This class allows for O(1) lookup of sales approvers for any theater, sales division, and team combo.
     *
     * Using this class and caching it in memory allows one to only use one SOQL query for all sales approver queries.
     *
     * @author Kyle Vermeer 5/2/14
     */
    @TestVisible
    private class SalesApproverDirectory {
        
        //////////////////////////////
        // Private Member Variables
        //////////////////////////////
        private Map<String,Map<String,Map<String,Map<String,Sales_Approver_Matrix_Entry__c>>>> directoryMap;
        private ErrorTracker et;

        ////////////////////
        // Constructors
        ////////////////////

        /**
         * Use the constructor to limit the number of approver codes you look for.
         *
         * @return {SalesApproverDirectory}
         */
        @TestVisible
        public SalesApproverDirectory(List<String> approverCodes, ErrorTracker et) {
            this.et = et;
            initialize(approverCodes);
        }

        /**
         * Use this constructor when there is no need to limit the number of apporver codes you are querying.
         *
         * @return {SalesApproverDirectory}
         */
        public SalesApproverDirectory(ErrorTracker et) {
            this.et = et;
            initialize(null);
        }

        ///////////////////
        // Public API
        ///////////////////

        /**
         * Return the corresponding Sales_Approver_Matrix_Entry__c for the approver code, theater, sales division, and team.
         *
         * @param {String} approverCode - approver code for entry
         * @param {String} theater - theater for entry
         * @param {String} salesDivision - sales division for entry
         * @param {String} team - team for entry
         * @return {Sales_Approver_Matrix_Entry__c} - sales approver matrix entry for provided parameters.
         */
        @TestVisible
        public Sales_Approver_Matrix_Entry__c getEntry(String approverCode, String theater, String salesDivision, String team) {
            if (approverCode == null) {
                System.debug('Null approver code provided!');
                return null;
            }
            // Find Theater map
            Map<String,Map<String,Map<String,Sales_Approver_Matrix_Entry__c>>> theaterEntries = directoryMap.get(approverCode);
            if (theaterEntries == null) {
                System.debug('Could not find any entries for approver code: ' + approverCode);
                return null;
            }
            // Find Sales Division map
            Map<String,Map<String,Sales_Approver_Matrix_Entry__c>> salesDivisionEntries = theaterEntries.get(theater);
            if (salesDivisionEntries == null) { // If no entry for specific theater, try wildcard;
                salesDivisionEntries = theaterEntries.get(QuoteApproval_Utils.QUERY_WILDCARD_STRING);
                if (salesDivisionEntries == null) { // Still null, can't move forward
                    System.debug('No entries for specific theater: ' + theater + ' and no wildcard option!');
                    return null;
                }
            }
            // Find team map
            Map<String,Sales_Approver_Matrix_Entry__c> teamEntries = salesDivisionEntries.get(salesDivision);
            if (teamEntries == null) { // If no entry for specific sales division, try wildcard
                teamEntries = salesDivisionEntries.get(QuoteApproval_Utils.QUERY_WILDCARD_STRING);
                if (teamEntries == null) { // Still null, can't move forward
                    System.debug('No entries for specific sales division: ' + salesDivision + ' and no wildcard option!');
                    return null;
                }
            }
            // Find the salesApproverEntry
            Sales_Approver_Matrix_Entry__c salesApproverEntry = teamEntries.get(team);
            if (salesApproverEntry == null) { // If no entry for specific team, try wildcard
                salesApproverEntry = teamEntries.get(QuoteApproval_Utils.QUERY_WILDCARD_STRING);
                if (salesApproverEntry == null) { // Still null, can't move forward
                    System.debug('No entries for specific team: ' + team + ' and no wildcard option!');
                    return null;
                }
            }
            // Return the found entry
            return salesApproverEntry;
        }

        //////////////////////
        // Private Methods
        //////////////////////

        /**
         * Intializes the SalesApproverDirectory by populating internal data.
         *
         * This method makes 1 SOQL query
         *
         * @param {List<String>} approverCodes - Approver codes that should be gathered
         */
        private void initialize(List<String> approverCodes) {
            this.directoryMap = new Map<String,Map<String,Map<String,Map<String,Sales_Approver_Matrix_Entry__c>>>>();
            List<Sales_Approver_Matrix_Entry__c> salesApproverEntries = null;
            try {
                String query = 'SELECT Id, Approver_Code__c, Theater__c, Team__c, Sales_Division__c, Level_1_Approver__c, Level_2_Approver__c, ' +
                                       'Level_3_Approver__c, Level_4_Approver__c' +
                                ' FROM Sales_Approver_Matrix_Entry__c';
                if (approverCodes != null && !approverCodes.isEmpty()) {
                    query += ' WHERE Approver_Code__c IN :approverCodes';
                }
                System.debug('Sales Approver Query: ' + query);
                salesApproverEntries = Database.query(query);
            }
            catch (Exception e) {
                this.et.addError('Issue querying for Sales Approver Matrix Entries!');
                new LoggedException(e,'Issue querying for Sales Approver Matrix Entries!','QuoteApproval_Decider');
            }
            if (salesApproverEntries != null) {
                for (Sales_Approver_Matrix_Entry__c currentEntry : salesApproverEntries) {
                    insertSalesApproverEntryToMap(currentEntry);
                }
            }
        }

        /**
         * Insert Sales_Approver_Matrix_Entry into internal map.  Only this method should be called to populate internal map.
         *
         * @param {Sales_Approver_Matrix_Entry__c} entry - entry to insert into internal map
         */
        private void insertSalesApproverEntryToMap(Sales_Approver_Matrix_Entry__c entry) {
            if (entry == null) { // check for null inputs
                System.debug('Null entry provided!');
                return;
            }
            // Get approval code
            String approvalCode = entry.Approver_Code__c;
            // Get directory for that approval code
            Map<String,Map<String,Map<String,Sales_Approver_Matrix_Entry__c>>> directoryForApprovalCode = directoryMap.get(approvalCode);
            if (directoryForApprovalCode == null) { // if directory doesn't exist yet, add it
                directoryForApprovalCode = new Map<String,Map<String,Map<String,Sales_Approver_Matrix_Entry__c>>>();
                directoryMap.put(approvalCode, directoryForApprovalCode);
            }
            insertIntoApprovalCodeDirectory(entry, directoryForApprovalCode);
        }

        /**
         * Insert Sales_Approver_Matrix_Entry into internal map at the approval code level.  Not to be called except by parent method.
         *
         * @param {Sales_Approver_Matrix_Entry__c} entry - entry to insert into internal map
         * @param {Map<String,Map<String,Map<String,Sales_Approver_Matrix_Entry__c>>>} directory - the approval code layer of the internal map for approval code in entry
         */
        private void insertIntoApprovalCodeDirectory(Sales_Approver_Matrix_Entry__c entry, Map<String,Map<String,Map<String,Sales_Approver_Matrix_Entry__c>>> directory) {
            if (entry == null || directory == null) { // check for null inputs
                System.debug('Null required input provided. entry: ' + entry + '; directory: ' + directory);
                return;
            }
            // Get theater
            String theater = entry.Theater__c;
            // Get directory for theater
            Map<String,Map<String,Sales_Approver_Matrix_Entry__c>> directoryForTheater = directory.get(theater);
            if (directoryForTheater == null) { // If directory doesn't exist yet, add it
                directoryForTheater = new Map<String,Map<String,Sales_Approver_Matrix_Entry__c>>();
                directory.put(theater, directoryForTheater);
            }
            insertIntoTheaterDirectory(entry, directoryForTheater);
        }

        /**
         * Insert Sales_Approver_Matrix_Entry into internal map at the theater level.  Not to be called except by parent method.
         *
         * @param {Sales_Approver_Matrix_Entry__c} entry - entry to insert into internal map
         * @param {Map<String,Map<String,Sales_Approver_Matrix_Entry__c>>} directory - the approval code layer of the internal map for approval code, theater in entry
         */
        private void insertIntoTheaterDirectory(Sales_Approver_Matrix_Entry__c entry, Map<String,Map<String,Sales_Approver_Matrix_Entry__c>> directory) {
            if (entry == null || directory == null) { // Check for null inputs
                System.debug('Null required input provided. entry: ' + entry + '; directory: ' + directory);
                return;
            }
            // Get Sales Division
            String salesDivision = entry.Sales_Division__c;
            // Get directory for sales division
            Map<String,Sales_Approver_Matrix_Entry__c> directoryForSalesDivision = directory.get(salesDivision);
            if (directoryForSalesDivision == null) { // If directory doesn't exist yet, add it
                directoryForSalesDivision = new Map<String,Sales_Approver_Matrix_Entry__c>();
                directory.put(salesDivision, directoryForSalesDivision);
            }
            insertIntoSalesDivisionDirectory(entry, directoryForSalesDivision);
        }

        /**
         * Insert Sales_Approver_Matrix_Entry into internal map at the sales division level.  Not to be called except by parent method.
         *
         * @param {Sales_Approver_Matrix_Entry__c} entry - entry to insert into internal map
         * @param {Map<String, Sales_Approver_Matrix_Entry__c>} directory - the approval code layer of the internal map for approval code, theater, sales division in entry
         */
        private void insertIntoSalesDivisionDirectory(Sales_Approver_Matrix_Entry__c entry, Map<String, Sales_Approver_Matrix_Entry__c> directory) {
            if (entry == null || directory == null) { // Check for null inputs
                System.debug('Null required input provided. entry: ' + entry + '; directory: ' + directory);
                return;
            }
            // Get Team
            String team = entry.Team__c;
            // Insert sales approver matrix entry into directory
            directory.put(team, entry);
        }
    }
}