/**
 * Interface for classes that will serve as a data source of Quote Approvals
 *
 * @author Kyle Vermeer 4/23/2014
 */

public interface QuoteApproval_DataSource {

    // Returns a Map from Approval Process Code to ProductDiscount for that code
    Map<String, List<QuoteApproval_Utils.ProductDiscount>> getProductDiscountMap();

    // Returns true if the object was safetly queried and returned
    Boolean didRetrieveDataSourceSuccessfully();

    // Returns Id of datasource object
    Id getDataSourceId();

    // Returns the Id of the Opportunity Owner for the Quote
    Id getOwnerId();

    // Returns the Id of the Manager of the Opportunity Owner for the Quote
    Id getManagerId();

    // Returns the payment terms of the quote
    String getPaymentTerms();

    // Returns data confidence level of quote
    String getDataConfidenceLevel();

    // Returns the name of the sObject used as the datasource
    String getDataSourceObjectName();

    // Returns the name of the the datasource field on quote approvals
    String getQuoteApprovalFieldName();

    // Attempts to save (update) the data source
    Boolean saveDataSource();

    // Sets recordtype of datasource
    void setRecordType(QuoteApproval_Utils.QuoteRecordType recordType);

    // Sets status of datasource
    void setStatus(QuoteApproval_Utils.QuoteStatus status);

    // Returns the data source.
    SObject getDataSource();

    // New agreement or Upsell
    QuoteApproval_Utils.QuotePurchaseType getPurchaseType();

    // Have we discounted more than the provided percentage more before?
    Boolean hasLicenseBeenDiscountedMorePreviously(Double discountPercentage);
}