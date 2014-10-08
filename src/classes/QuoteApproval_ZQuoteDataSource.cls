/**
 * ZQuote implementation of QuoteApproval_DataSource
 *
 * @author Kyle Vermeer <kvermeer@box.com> 4/23/2014
 */

public class QuoteApproval_ZQuoteDataSource implements QuoteApproval_DataSource {
	
    ///////////////////////////////
    // Private Static Variables
    ///////////////////////////////

    private static Map<String,String> recordTypeNameToId {
        get {
            if (recordTypeNameToId == null) {
                List<RecordType> recordTypes = [SELECT Name, Id
                                                  FROM RecordType
                                                 WHERE sObjectType = 'Zqu__Quote__c'
                                                   AND isActive = true];
                recordTypeNameToId = new Map<String,String>();
                for (RecordType rt : recordTypes) {
                    recordTypeNameToId.put(rt.Name, rt.Id);
                }
            }
            return recordTypeNameToId;
        }
    }

    ///////////////////////////////
    // Private Member Variables
    ///////////////////////////////

    /* Quote that serves as the underlying data source */
    private ZQU__Quote__c quote;
    /* True if data source was queried without issues, false otherwise. */
    private Boolean dataSourceRetrievedSuccessfully;
    /* Map holding product discount data */
    private Map<String, List<QuoteApproval_Utils.ProductDiscount>> productDiscountMap;

    //////////////////////////////
    // Private Constants
    //////////////////////////////
    private static final String QUOTE_STATUS_DRAFT = 'Draft';
    private static final String QUOTE_STATUS_IN_REVIEW = 'In Review';
    private static final String QUOTE_STATUS_REJECTED = 'Rejected';
    private static final String QUOTE_STATUS_REVOKED = 'Revoked';
    private static final String QUOTE_STATUS_APPROVED = 'Approved';

    private static final String QUOTE_RECORD_TYPE_NAME_NEW = 'Default';
    private static final String QUOTE_RECORD_TYPE_NAME_AMENDMENT = 'Amendment';
    private static final String QUOTE_RECORD_TYPE_NAME_LOCKED = 'Locked';
    private static final String QUOTE_RECORD_TYPE_NAME_APPROVED = 'Approved';

    private static final String ZQUOTE_API_NAME = 'ZQU__Quote__c';
    private static final String ZQUOTE_FIELD_NAME = 'ZQuote__c';


    //////////////////
    // Constructors
    //////////////////
    public QuoteApproval_ZQuoteDataSource(String datasourceId) {
        if (datasourceId == null) {
            System.debug('DatasourceId provided was null.');
            this.dataSourceRetrievedSuccessfully = false;
        }
        else {
            try { // Try to query for quote
                this.quote = [SELECT Id, zqu__Opportunity__r.OwnerId, zqu__Opportunity__r.Owner.ManagerId, 
                                     Zqu__PaymentTerm__c, ZQU__SubscriptionType__c, zqu__Opportunity__r.AccountId
                                FROM ZQU__Quote__c
                               WHERE Id = :datasourceId];

                this.dataSourceRetrievedSuccessfully = true;
            }
            catch (Exception e) { // Could not query datasource
                System.debug('Could not query data source.');
                LoggedException le = new LoggedException(e,'Could not query data source','QuoteApproval_ZQuoteDataSource',new List<Id>{});
                this.dataSourceRetrievedSuccessfully = false;
            }
        }
		
	}

    public QuoteApproval_ZQuoteDataSource(ZQU__Quote__c quote) {
        if (quote == null) { // Check for null input
            System.debug('Null quote provided.');
            this.dataSourceRetrievedSuccessfully = false;
        }
        else { // Non-null input
            this.quote = quote;
            dataSourceRetrievedSuccessfully = true;
        } 
    }

    public static List<QuoteApproval_DataSource> massQueryDataSources(List<Id> datasourceIds) {
        if (datasourceIds == null) { // Check for null inputs
            System.debug('Null required input!');
            return null;
        }
        List<QuoteApproval_DataSource> datasourceList = new List<QuoteApproval_DataSource>();
        if (datasourceIds.isEmpty()) { // if no ids are provided, return empty list
            System.debug('No ids provided!');
            return datasourceList;
        }
        else { // There are some ids
            try { // Try to query for datasource
                List<ZQU__Quote__c> quotes = [SELECT Id, zqu__Opportunity__r.OwnerId, zqu__Opportunity__r.Owner.ManagerId, 
                                                     Zqu__PaymentTerm__c, ZQU__SubscriptionType__c, zqu__Opportunity__r.AccountId
                                                FROM ZQU__Quote__c
                                               WHERE Id IN :datasourceIds];
                for (ZQU__Quote__c currentQuote : quotes) {
                    datasourceList.add(new QuoteApproval_ZQuoteDataSource(currentQuote));
                }
                return datasourceList;
            }
            catch (Exception e) { // Issues occured during querying
                System.debug('Issues querying datasource.');
                new LoggedException(e,'Issues querying datasource','QuoteApproval_ZQuoteDataSource', datasourceIds);
                return datasourceList;
            }
        }
    }

    ////////////////////////////////////////////
    // QuoteApproval_DataSource Implementation
    ////////////////////////////////////////////

    /**
     * Returns a map from quote approval process codes to the associated product discounts that use that approval code
     * 
     * @return {Map<String,QuoteApproval_Utils.ProductDiscount>>} - map from approval process code to product discounts
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    public Map<String, List<QuoteApproval_Utils.ProductDiscount>> getProductDiscountMap() {
        if (this.productDiscountMap == null) {
            this.productDiscountMap = new Map<String, List<QuoteApproval_Utils.ProductDiscount>>();
            List<zqu.ZChargeGroup> chargeGroups = zqu.ZQuoteUtil.getChargeGroups(quote.Id);
            this.productDiscountMap = getProductDiscountFromZChargeGroups(chargeGroups);
        }
        return this.productDiscountMap;
    }
    
    /**
     * Returns true if the object was safely queried and returned.
     *
     * @return {Boolean} - true if object was queried without issues, false otherwise
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    public Boolean didRetrieveDataSourceSuccessfully() {
        return this.dataSourceRetrievedSuccessfully;
    }

    /**
     * Returns Id of datasource object
     *
     * @return {Id} - Id of data source object. Null if there was an issue getting object.
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    public Id getDataSourceId() {
        if (this.didRetrieveDataSourceSuccessfully()) {
            return this.quote.Id;
        }
        else {
            return null;
        }
    }

    /**
     * Returns the Id of owner of the quote's opportunity.
     *
     * @return {Id} - Id of quote's opportunity's owner
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    public Id getOwnerId() {
        if (this.didRetrieveDataSourceSuccessfully()) {
            return this.quote.zqu__Opportunity__r.OwnerId;
        }
        else {
            return null;       
        }
    }

    /**
     * Returns the Id of the Manager of the Opportunity Owner for the Quote
     *
     * @return {Id} - Id of the manager of the Opportunity Owner for the Quote
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    public Id getManagerId() {
        if (this.didRetrieveDataSourceSuccessfully()) {
            return this.quote.zqu__Opportunity__r.Owner.ManagerId;
        }
        else {
            return null;
        }
    }

    /**
     * Returns the payment terms of the quote
     *
     * @return {String} - Payment Term of Quote
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    public String getPaymentTerms() {
        if (this.didRetrieveDataSourceSuccessfully()) {
            return this.quote.ZQU__PaymentTerm__c;
        }
        else {
            return null;
        }
    }

    /**
     * Due to the integration with Zuora, data confidence is now always strong
     *
     * @return {String} - Always QuoteApproval_Utils.QUOTE_DATA_CONFIDENCE_LEVEL_STRONG
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    public String getDataConfidenceLevel() {
        if (this.didRetrieveDataSourceSuccessfully()) {
            return QuoteApproval_Utils.QUOTE_DATA_CONFIDENCE_LEVEL_STRONG;
        }
        else {
            return null;
        }
    }

    /**
     * Returns the API name of the sObject used as the datasource
     *
     * @return {String} - API name of ZQuotes
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    public String getDataSourceObjectName() {
        return ZQUOTE_API_NAME;
    }

    /**
     * Returns the API name of the field on Quote_Approval__c that holds ZQuotes
     *
     * @return {String} - API Name of ZQuote field
     * @author Kyle Vermeer 5/1/14
     */
    public String getQuoteApprovalFieldName() {
        return ZQUOTE_FIELD_NAME;
    }

    /**
     * Attempts to save (update) the data source (DML)
     *
     * @return {Boolean} - True if successfully updated, false otherwise
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    public Boolean saveDataSource() {
        if (this.didRetrieveDataSourceSuccessfully()) {
            try { // Try to DML update the quote;
                update this.quote;
                return true;
            }
            catch (Exception e) {
                System.debug('Problem saving the quote!');
                LoggedException le = new LoggedException(e,'Trouble saving the quote!','QuoteApproval_ZQuoteDataSource', new List<Id> {this.quote.Id});
                return false;
            }
        }
        else {
            return false;
        }
    }

    /**
     * Returns the underlying SObject serving as the data source.  Useful for bulk updating.
     *
     * @return {SObject} - SObject that is serving as the datasource.
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    public SObject getDataSource() {
        if (this.didRetrieveDataSourceSuccessfully()) {
            return this.quote;
        }
        else {
            return null;
        }
    }

    /**
     * Returns the purchase type of the quote.
     *
     * @return {QuoteApproval_Utils.QuotePurchaseType} - Purchase Type (i.e. New, Upsell, etc.)
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    public QuoteApproval_Utils.QuotePurchaseType getPurchaseType() {
        if (this.didRetrieveDataSourceSuccessfully()) {
            if (this.quote.ZQU__SubscriptionType__c == 'New Subscription') {
                return QuoteApproval_Utils.QuotePurchaseType.QUOTE_PURCHASE_TYPE_NEW;
            }
            else if (this.quote.ZQU__SubscriptionType__c == 'Amend Subscription') {
                return QuoteApproval_Utils.QuotePurchaseType.QUOTE_PURCHASE_TYPE_UPSELL;
            }
            else if (this.quote.ZQU__SubscriptionType__c == 'Renew Subscription') {
                return QuoteApproval_Utils.QuotePurchaseType.QUOTE_PURCHASE_TYPE_RENEWAL;
            }
            else {
                return QuoteApproval_Utils.QuotePurchaseType.QUOTE_PURCHASE_TYPE_UNKNOWN;
            }
        }
        return null;
    }

    /**
     * Set the record type of the data source
     *
     * @param {QuoteApproval_Utils.QuoteRecordType} recordType - enum describing which record type to set
     * @author Kyle Vermeer 
     */
    public void setRecordType(QuoteApproval_Utils.QuoteRecordType recordType) {
        if (this.didRetrieveDataSourceSuccessfully()) {
            // Find correct record type
            String recordTypeId = null;
            if (recordType == QuoteApproval_Utils.QuoteRecordType.QUOTE_RECORD_TYPE_NEW) {
                recordTypeId = recordTypeNameToId.get(QUOTE_RECORD_TYPE_NAME_NEW);
            }
            else if (recordType == QuoteApproval_Utils.QuoteRecordType.QUOTE_RECORD_TYPE_UPSELL) {
                recordTypeId = recordTypeNameToId.get(QUOTE_RECORD_TYPE_NAME_AMENDMENT);
            }
            else if (recordType == QuoteApproval_Utils.QuoteRecordType.QUOTE_RECORD_TYPE_LOCKED) {
                recordTypeId = recordTypeNameToId.get(QUOTE_RECORD_TYPE_NAME_LOCKED);
            }
            else if (recordType == QuoteApproval_Utils.QuoteRecordType.QUOTE_RECORD_TYPE_APPROVED) {
                recordTypeId = recordTypeNameToId.get(QUOTE_RECORD_TYPE_NAME_APPROVED);
            }
            else { // None of the known record types
                System.debug('Unknow Record Type: ' + recordType);
            }
            // Now set record type
            if (recordTypeId != null) { // If we could successful grab record type from map
                System.debug('Setting record type to: ' + recordTypeId);
                this.quote.recordTypeId = recordTypeId;
            }
            else {
                System.debug('Could not find record type!');
            }
        }
    }

    /**
     * Sets the status of the data source
     *
     * @param {QuoteApproval_Utils.QuoteStatus} status - enum describing the type of status
     * @author Kyle Vermeer
     */
    public void setStatus(QuoteApproval_Utils.QuoteStatus status) {
        if (this.didRetrieveDataSourceSuccessfully()) {
            if (status == QuoteApproval_Utils.QuoteStatus.QUOTE_STATUS_DRAFT) {
                this.quote.Approval_Status__c = QUOTE_STATUS_DRAFT;
            }
            else if (status == QuoteApproval_Utils.QuoteStatus.QUOTE_STATUS_IN_REVIEW) {
                this.quote.Approval_Status__c = QUOTE_STATUS_IN_REVIEW;
            }
            else if (status == QuoteApproval_Utils.QuoteStatus.QUOTE_STATUS_REVOKED) {
                this.quote.Approval_Status__c = QUOTE_STATUS_REVOKED;
            }
            else if (status == QuoteApproval_Utils.QuoteStatus.QUOTE_STATUS_REJECTED) {
                this.quote.Approval_Status__c = QUOTE_STATUS_REJECTED;
            }
            else if (status == QuoteApproval_Utils.QuoteStatus.QUOTE_STATUS_APPROVED) {
                this.quote.Approval_Status__c = QUOTE_STATUS_APPROVED;
            }
            else {
                System.debug('Unknown status: ' + status);
            }
        }
    }

    /**
     * Returns true if the license has been discounted more (or equal) in the past, otherwise false.
     *
     * This method checks old quotes and ZQuotes on closed won opps for the account for their discounts.
     * Only considers live quotes.
     *
     * @param {Double} discountPercentage - current discount percent to compare against
     * @return {Boolean} - true if license has been discounted more (or equal) before, false otherwise
     */
    public Boolean hasLicenseBeenDiscountedMorePreviously(Double discountPercentage) {
        if (discountPercentage == null) {
            System.debug('Null discountPercentage provided.');
            return false;
        }
        Double highestDiscountClassicQuotes = this.getPreviousDiscountClassicQuotes();
        Double highestDiscountZQuotes = this.getPreviousDiscountZQuotes();
        System.debug('Highest Discount ZQUote: ' + highestDiscountZQuotes);
        System.debug('Highest Discount Quote: ' + highestDiscountClassicQuotes);
        if (highestDiscountClassicQuotes == null || highestDiscountZQuotes == null) {
            // If one is null, return false
            System.debug('Null discount. Classic Discount: ' + highestDiscountClassicQuotes + '. Highest Discount ZQuote: ' + highestDiscountZQuotes);
            return false;
        } 
        else {
            // Find highest discount from classic and ZQuotes
            Double highestDiscountPreviousDiscount = Math.max(highestDiscountClassicQuotes, highestDiscountZQuotes);
            if (highestDiscountPreviousDiscount >= discountPercentage && highestDiscountPreviousDiscount != 0.0) {
                return true;
            }
            else {
                return false;
            }
        }
        return null;
    }

    /**
     * Gets the highest license discount from any classic quotes on the account for this quote/opp.
     *
     * @return {Double} - discount in percentage form (70.7% would be 70.7)
     */
    private Double getPreviousDiscountClassicQuotes() {
        if (this.didRetrieveDataSourceSuccessfully()) {
            String AGGREGATE_FIELD_NAME = 'highestDiscount';
            // FIRST: Must be an upsell
            if (this.getPurchaseType() != QuoteApproval_Utils.QuotePurchaseType.QUOTE_PURCHASE_TYPE_UPSELL) {
                System.debug('This is not an upsell! It is a: ' + this.getPurchaseType());
                return 0.0;
            } else { // If it is an upsell
                Id accountId = this.quote.zqu__Opportunity__r.AccountId;
                List<AggregateResult> maxDiscountResults = [SELECT Id, MAX(Live_Quote__r.Total_License_Discount__c) highestDiscount
                                                              FROM Opportunity
                                                             WHERE AccountId = :accountId
                                                               AND (StageName = 'Closed Won' OR StageName = 'Bounty')
                                                          GROUP BY Id];
                // No previous quotes
                if (maxDiscountResults == null || maxDiscountResults.size() <= 0) {
                    return 0.0;
                }

                // We've assured there is at least 1
                AggregateResult maxDiscount = maxDiscountResults[0];
                // Return highest discount
                Double highestDiscount = (Double) maxDiscount.get(AGGREGATE_FIELD_NAME);
                return highestDiscount;
            }
        }
        else {
            return null;
        }
    }

    /**
     * Gets the highest license discount from any zquotes on the account for this quote/opp.
     *
     * @return {Double} - discount in percentage form (70.7% would be 70.7)
     */
    private Double getPreviousDiscountZQuotes() {
        if (this.didRetrieveDataSourceSuccessfully()) {
            String AGGREGATE_FIELD_NAME = 'highestDiscount';
            // FIRST: Must be an upsell
            if (this.getPurchaseType() != QuoteApproval_Utils.QuotePurchaseType.QUOTE_PURCHASE_TYPE_UPSELL) {
                System.debug('This is not an upsell! It is a: ' + this.getPurchaseType());
                return 0.0;
            } else { // If it is an upsell
                Id accountId = this.quote.zqu__Opportunity__r.AccountId;
                List<ZQU__Quote__c> zquotes = [SELECT Id, License_Discount__c
                                                              FROM ZQU__Quote__c
                                                             WHERE zqu__Opportunity__r.AccountId = :accountId
                                                               AND (zqu__Opportunity__r.StageName = 'Closed Won' OR zqu__Opportunity__r.StageName = 'Bounty')
                                                               AND Live_Quote__c = true
                                                          Order By License_Discount__c DESC];
                // No previous quotes
                if (zquotes == null || zquotes.size() <= 0) {
                    return 0.0;
                }

                ZQU__Quote__c mostDiscountedQuote = zquotes[0];
                // We've assured there is at least 1
                Double highestDiscount = (Double) mostDiscountedQuote.License_Discount__c;
                return highestDiscount;
            }
        }
        else {
            return null;
        }
    }

    /////////////////////
    // Private methods
    /////////////////////

    /**
     * Returns a Map from Approval Process Codes to their associated Product Discounts
     *
     * @param {List<zqu.ZChargeGroup>} chargeGroups - Charge Groups to grab the discounts and approval codes from
     * @return {Map<String,QuoteApproval_Utils.ProductDiscount>>} - map from approval process code to product discounts
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    private Map<String, List<QuoteApproval_Utils.ProductDiscount>> getProductDiscountFromZChargeGroups(List<zqu.ZChargeGroup> chargeGroups) {
        if (chargeGroups == null) { // Check for null inputs
            System.debug('Null chargeGroups provided.');
            return null;
        }
        // Create Map from charge group id to approval code
        Map<String,String> chargeGroupIdToApprovalCode = createMapFromChargeGroupIdToApprovalCode(chargeGroups);
        // Create Map
        return createProcessCodeToDiscountsMap(chargeGroups, chargeGroupIdToApprovalCode);
    }

    /**
     * Builds a map from chargeGroupIds to approval codes.
     *
     * To implement this, we perform the following steps:
     *      1. We have ChargeGroupIds
     *      2. Map RatePlanCharge --> ChargeGroupId
     *      3. Map RatePlan --> RatePlanCharge
     *      4. Rate Plans have approval codes
     *      5. Navigate Maps to associate from approval code to chargegroupId
     *      
     * @param {List<zqu.ZChargeGroup>} chargeGroups - List of charge groups
     * @return {Map<String,String>} - Map from chargeGroupIds to their associated approval codes
     * @author Kyle Vermeer 4/30/2014
     */     
    private Map<String, String> createMapFromChargeGroupIdToApprovalCode(List<zqu.ZChargeGroup> chargeGroups) {
        if (chargeGroups == null) {
            System.debug('Null required input!');
            return null;
        }
        System.debug('Charge groups: ' + chargeGroups);
        Map<String, String> chargeGroupIdToApprovalCode = new Map<String, String>();
        try {
            // Create Map from ratePlanIds to ChargeGroupIds
            Map<String, String> ratePlanChargeIdToChargeGroupId = new Map<String, String>();

            for (zqu.ZChargeGroup chargeGroup : chargeGroups) {
                // Don't approve removed or non-changed products!
                if (chargeGroup.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_REMOVEPRODUCT ||
                    chargeGroup.groupType == zqu.ZChargeGroup.TYPE_RENEWAL_REMOVEPRODUCT   ||
                    chargeGroup.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_ORIGINAL      ||
                    chargeGroup.groupType == zqu.ZChargeGroup.TYPE_RENEWAL_RENEWED) {
                    continue;
                }
                for (zqu.ZCharge charge : chargeGroup.ZCharges) {
                    String ratePlanChargeId = charge.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID;
                    System.debug('RatePlanChargeId ' + ratePlanChargeId);
                    ratePlanChargeIdToChargeGroupId.put(ratePlanChargeId,chargeGroup.GroupID);
                }
            }

            // Map from ratePlanId to RatePlanCharge
            Map<String, ZQU__ProductRatePlanCharge__c> ratePlanIdToRatePlanCharge = new Map<String, ZQU__ProductRatePlanCharge__c>();
            List<zqu__ProductRatePlanCharge__c> ratePlanChargeList = [SELECT Id, ZQU__ProductRatePlan__c
                                                                        FROM ZQU__ProductRatePlanCharge__c
                                                                       WHERE Id IN :ratePlanChargeIdToChargeGroupId.keySet()];
            for (ZQU__ProductRatePlanCharge__c ratePlanCharge : ratePlanChargeList) {
                System.debug('Product Rate Plan Id: ' + ratePlanCharge.ZQU__ProductRatePlan__c);
                ratePlanIdToRatePlanCharge.put(ratePlanCharge.ZQU__ProductRatePlan__c, ratePlanCharge);
            }


            // Get all rate plans to find the approval code for each rate plan
            List<zqu__ProductRatePlan__c> ratePlans = [ SELECT Id, Quote_Approval_Code__c
                                                          FROM ZQU__ProductRatePlan__c
                                                         WHERE Id in :ratePlanIdToRatePlanCharge.keySet()];
            // Now map from chargeGroupId to approval code
            for (ZQU__ProductRatePlan__c ratePlan : ratePlans) {
                System.debug('Rate Plan: ' + ratePlan);
                if (ratePlan.Quote_Approval_Code__c != null) { // If rate plan has an approval code
                    // Get approval code
                    String approvalCode = ratePlan.Quote_Approval_Code__c;
                    // Then find the chargeGroupId associated with this ratePlan
                    ZQU__ProductRatePlanCharge__c ratePlanCharge = ratePlanIdToRatePlanCharge.get(ratePlan.Id);
                    String chargeGroupId = ratePlanChargeIdToChargeGroupId.get(ratePlanCharge.Id);
                    // Finally map from chargeGroupId to approval code
                    System.debug('Charge Group Id: ' + chargeGroupId + '; Approval Code: ' + approvalCode);
                    chargeGroupIdToApprovalCode.put(chargeGroupId, approvalCode);
                }
            }
            return chargeGroupIdToApprovalCode;
        }
        catch (Exception e) {
            System.debug('Issue creating Process Code To Product Discount Map');
            new LoggedException(e,'Issue creating Process Code To Product Discount Map','QuoteApproval_ZQuoteDataSource', new List<Id> { this.quote.Id });
            return null;
        }
    }

     /**
     * Returns the populated Map from Approval Process Codes to their associated Product Discounts.  Return map is the same as the input map
     *
     * @param {List<zqu.ZChargeGroup>} chargeGroups - Charge Groups to grab the discounts and quantity and productId from
     * @param {Map<String,String>} chargeGroupIdToApprovalCode - map from charge group id to approval code associated with that rate plan
     * @return {Map<String,QuoteApproval_Utils.ProductDiscount>>} - map from approval process code to product discounts
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    private Map<String, List<QuoteApproval_Utils.ProductDiscount>> createProcessCodeToDiscountsMap(List<zqu.ZChargeGroup> chargeGroups, 
                                                                                                   Map<String, String> chargeGroupIdToApprovalCode) {
        if (chargeGroups == null || chargeGroupIdToApprovalCode == null) { // Check for null inputs
            System.debug('Required input null. chargeGroups: ' + chargeGroups + '; chargeGroupIdToApprovalCode: ' + chargeGroupIdToApprovalCode);
            return null;
        }
        Map<String, List<QuoteApproval_Utils.ProductDiscount>> processCodeToProductDiscount = new Map<String, List<QuoteApproval_Utils.ProductDiscount>>();
        // For each charge group (rate plan), create a product discount if it has an approval code, then add to map
        for (zqu.ZChargeGroup chargeGroup : chargeGroups) {
            // Get Approval Code
            String approvalCode = chargeGroupIdToApprovalCode.get(chargeGroup.GroupId);
            if (approvalCode != null) { // if there is an approval code, create the product disocunt
                zqu.ZCharge charge = chargeGroup.ZCharges[0]; // Always taking first charge, not sure what the use case of multiple charges would be
                // Populate product discount
                QuoteApproval_Utils.ProductDiscount productDiscount = new QuoteApproval_Utils.ProductDiscount();
                productDiscount.approvalProcessCode = approvalCode;
                System.debug('QUANITY: ' + charge.quantity);
                Integer quantity = null;
                Double discount = null;
                if (charge.quantity == '-') {
                    quantity = 1;
                }
                else {
                    quantity = Integer.valueOf(charge.quantity);
                }
                if (charge.discount == '-') {
                    discount = 0;
                }
                else {
                    discount = Double.valueOf(charge.discount);
                    if (discount < 0) { // We normalize this for strangley priced things like Premier Support
                        discount = 0;
                    }
                }
                productDiscount.quantity = quantity;
                productDiscount.discount = discount;
                // Add product discount to list of product discounts for that approval code
                List<QuoteApproval_Utils.ProductDiscount> productDiscounts = processCodeToProductDiscount.get(approvalCode);
                if (productDiscounts == null) {
                    productDiscounts = new List<QuoteApproval_Utils.ProductDiscount>();
                    processCodeToProductDiscount.put(approvalCode, productDiscounts);
                }
                productDiscounts.add(productDiscount);
                System.debug('Approval Code: ' + approvalCode + '; ProductDiscount: ' + productDiscount);
            }
        }
        return processCodeToProductDiscount;
    }

}