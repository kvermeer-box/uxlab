/**
 * Object defining the JSON agreement for OnlineSales transactions
 *
 * @author Kyle Vermeer 8/20/14
 */
public class OnlineSales_Message {

    // webtrial, upgrade, expansion
    public String purchaseMethod { get; set; }
    // positive integer representing admin's Box userId
    public Integer userId  { get; set; }
    // valid email for admin user
    public String userLogin  { get; set; }
    // user's name
    public String userName { get; set; }
    // Used to specify trial status (live_deal, potential_deal, trial)
    public String trialStatusAfter  { get; set; }
    // Unix timestamp of time transaction occured
    public Long transactionDate  { get; set; }
    // eID that identifies the enterprise in Box, positive Integer
    public Integer enterpriseId  { get; set; }
    // true if credit card is required, false otherwise   
    public Boolean isCCRequired  { get; set; }
    // email domains for company
    public String[] emailsDomains  { get; set; }
    // A bcp47 tag representing language
    public String languageCode;
    // subdomain of enterprise (email)
    public String enterpriseSubdomain;
    // Name of enterprise (i.e. Box, Inc.)
    public String enterpriseName;
    // An array of Strings representing custom features of the customer
    public String[] customFeaturesJSON;
    // True if the enterprise is deactivated, false otherwise
    public Boolean isDeactivated;
    // Unix Timestamp for the trial start date
    public Long trialStartDate;
    // Unix Timestamp for the trial end date
    public Long trialEndDate;
    // Billing period --> Month, Annual, etc.
    public String billingPeriod;
    // Currency ISO Code
    public String currencyCode;
    // Number of seats after the transaction
    public Integer enterpriseSeatsAfter;
    // Number of seats purchased (will always be positive)
    public Integer enterpriseSeatsPurchased;
    // object representing discount
    public String discountsJSON;
    // hash for referrer (i.e. 'nonprofit' for the URL www.box.com/nonprofit)
    public String referrerHash;
    // SKU before transaction
    public String tierBefore;
    // SKU after transaction
    public String tierAfter;
    // Custom plan before transaction
    public String customPlanBefore;
    // Custom plan after transaction
    public String customPlanAfter;
    // RR after transaction
    public Decimal arrAfter;
    // RR after transaction
    public Decimal arrBefore;

    // ZUORA Fields

    // Unix Timestamp of last payment date
    public Integer lastPaymentDate;
    public String subscriptionStatus;
    public String paymentMethodType;
    public String lastTransactionStatus;
    public String lastPaymentStatus;
    

    // Type of discount (i.e. percent_off)
    public String discountType {
        get {
            // TODO: FILL IN
            return null;
        }
    }
    // Length of discount (in months)
    public Integer discountLength {
        get {
            // TODO: FILL IN
            return null;
        }
    }
    // value of discount, related to discountType
    public Integer discountValue {
        get {
            // TODO: FILL IN
            return null;
        }
    }

    public Date getTransactionDateAsDate() {
        if( this.transactionDate == null ) {
            return null;
        }
        DateTime transactionDateTime = DateTime.newInstance(this.transactionDate);
        Date transactionDate = Date.newInstance(transactionDateTime.year(), transactionDateTime.month(), transactionDateTime.day());
        return transactionDate;
    }
    public Date getTrialStartDateAsDate() {
        if( this.trialStartDate == null ) {
            return null;
        }
        DateTime trialStartDateTime = DateTime.newInstance(this.trialStartDate);
        Date trialStartDate = Date.newInstance(trialStartDateTime.year(), trialStartDateTime.month(), trialStartDateTime.day());
        return trialStartDate;
    }

    public Date getTrialEndDateAsDate() {
        if( this.trialEndDate == null ) {
            return null;
        }
        DateTime trialEndDateTime = DateTime.newInstance(this.trialEndDate);
        Date trialEndDate = Date.newInstance(trialEndDateTime.year(), trialEndDateTime.month(), trialEndDateTime.day());
        return trialEndDate;
    }

    /**
     * Used for logging messages
     *
     * @param Box_Online_Sales_Message__c loggedMessage - message to popualte
     * @return Box_Online_Sales_Message__c - message with fields populated
     */
    public Box_Online_Sales_Message__c populateParsedData(Box_Online_Sales_Message__c loggedMessage) {
        loggedMessage.arrAfter__c = this.arrAfter;
        loggedMessage.arrBefore__c = this.arrBefore;
        loggedMessage.billingPeriod__c = this.billingPeriod;
        loggedMessage.currencyCode__c = this.currencyCode;
        if( this.customFeaturesJSON != null ) {
            String customFeaturesString = '';
            for( String customFeature : customFeaturesJSON ) {
                customFeaturesString = customFeaturesString + customFeature + ';';
            }
            loggedMessage.customFeaturesJSON__c = customFeaturesString;
        }
        loggedMessage.customPlanAfter__c = this.customPlanAfter;
        loggedMessage.customPlanBefore__c = this.customPlanBefore;
        loggedMessage.discountsJSON__c = this.discountsJSON;
        if( this.emailsDomains != null ) {
            String emailDomainsString = '';
            for( String emailDomain : this.emailsDomains ) {
                emailDomainsString = emailDomainsString + emailDomain + ';';
            }
            loggedMessage.emailDomains__c = emailDomainsString;
        }
        loggedMessage.enterpriseId__c = this.enterpriseId;
        loggedMessage.enterpriseName__c = this.enterpriseName;
        loggedMessage.enterpriseSeatsAfter__c = this.enterpriseSeatsAfter;
        loggedMessage.enterpriseSeatsPurchased__c = this.enterpriseSeatsPurchased;
        loggedMessage.enterpriseSubdomain__c = this.enterpriseSubdomain;
        loggedMessage.isCCRequired__c = this.isCCRequired;
        loggedMessage.isDeactivated__c = this.isDeactivated;
        loggedMessage.languageCode__c = this.languageCode;
        loggedMessage.referrerHash__c = this.referrerHash;
        loggedMessage.tierAfter__c = this.tierAfter;
        loggedMessage.tierBefore__c = this.tierBefore;
        loggedMessage.transactionDate__c = this.transactionDate;
        loggedMessage.trialEndDate__c = this.trialEndDate;
        loggedMessage.trialStartDate__c = this.trialStartDate;
        loggedMessage.trialStatusAfter__c = this.trialStatusAfter;
        loggedMessage.userId__c = this.userId;
        loggedMessage.userLogin__c = this.userLogin;
        loggedMessage.userName__c  =this.userName;
        loggedMessage.Transaction_Date_Human__c = getTransactionDateAsDate();
        loggedMessage.Trial_Start_Date_Human__c = getTrialStartDateAsDate();
        loggedMessage.Trial_End_Date_Human__c = getTrialEndDateAsDate();
        return loggedMessage;
    }
}