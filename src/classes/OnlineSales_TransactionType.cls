/**
 * Interface for each Online Sales Transaction Type
 *
 * @author Kyle Vermeer 08/29/2014
 */
public abstract class OnlineSales_TransactionType {

    protected OnlineSales_Message message { get; set; }

    protected ErrorTracker et {
        get {
            if (et == null) {
                et = new ErrorTracker();
            }
            return et;
        } 
        set;
    }

    /**
     * Processes the message for this transaction type.  Returns a TransactionResult detailing what occured.
     *
     * @param ErrorTracker et - error tracker for this process
     * @return TransactionResult - result status code
     */
    public TransactionResult processMessage() {
        FCRM.FCR_SupportAPI.SetPassiveModeInContext();
        // 1. Search for related data in instance
        SObject dataSearchResult = searchForRelatedData();
        if( dataSearchResult == null ) { // Error --> Could not find related data and was unable to create a new lead
            return new TransactionResult(null, OnlineSales_Constants.TransactionResultCode.TROUBLE_FINDING_OR_CREATING_DATA, this.et);
        }
        // 2. Created all neccessary objects for processing
        OnlineSales_StructCreator.OnlineSalesStruct struct = createStructFromRelatedObject(dataSearchResult);
        if( struct == null ) { // Error --> Could not create opportunity or related data
            return new TransactionResult(null, OnlineSales_Constants.TransactionResultCode.UNABLE_TO_CREATE_OPP, this.et);
        }
        // 3. Process (update fields) on related objects
        boolean updateSuccess = processStructObjects(struct);
        if( updateSuccess ) { // Success
            return new TransactionResult(struct, OnlineSales_Constants.TransactionResultCode.SUCCESS, this.et);
        }
        else {
            return new TransactionResult(null, OnlineSales_Constants.TransactionResultCode.TROUBLE_UPDATING_FIELDS, this.et);
        }
    }

    /**
     * Searches for an object related to this message.  Returns null if nothing could be found or created.
     *
     * Potential return types are:
     *     - Account
     *     - Contact
     *     - Lead
     *     - Opportunity
     *
     * @return SObject - the most relevant data found in our instance for this message
     */
    @TestVisible
    protected SObject searchForRelatedData() {
        OnlineSales_DataSearch dataSearch = new OnlineSales_DataSearch(this.et);
        // 1. Search for Contact
        Contact matchingContact = dataSearch.searchForContact(this.message.userLogin);
        if( matchingContact != null ) {
            return matchingContact;
        }
        // 2. Search for Lead and Convert
        Lead matchingLead = dataSearch.searchForLead(this.message.userLogin);
        if( matchingLead != null ) {
            return matchingLead;
        }
        // 3. Search for EID
        // 3a. Search for Opp by EID
        Opportunity matchingOppEID = dataSearch.searchForOppByEID(this.message.enterpriseId);
        if( matchingOppEID != null ) {
            return matchingOppEID;
        }
        // 3b. Search for Account by EID
        Account matchingAccountEID = dataSearch.searchForAccountByEID(this.message.enterpriseId);
        if( matchingAccountEID != null ) {
            return matchingAccountEID;
        }
        // 4. Domain Mapping for Account
        Account matchingAccountDM = dataSearch.searchForAccountByDomainMapping(this.message.userLogin);
        if( matchingAccountDM != null ) {
            return matchingAccountDM;
        }
        // 5. Create Lead
        Lead newLead = dataSearch.createLeadForConversion(this.message);
        System.debug('CPU Time (After Creating Lead): ' + Limits.getCpuTime());
        if( newLead != null ) {
            return newLead;
        }

        // If we reached this point, an error occured
        System.debug('No related data found, and there must have been an error creating a lead.  That is bad!');
        return null;
    }

    /**
     * Struct containing objects to process
     *
     * @param OnlineSales_StructCreator.OnlineSalesStruct struct - struct containing objects to process
     * @return boolean - if objects were updated successfully
     */
    protected boolean processStructObjects(OnlineSales_StructCreator.OnlineSalesStruct struct) {
        try { // Attempt to update account
            Account accToUpdate = setFieldsOnAccount(struct.accountId);
            update accToUpdate;
        }
        catch( Exception e ) {
            this.et.addError('Trouble updating account fields! Error: ' + e.getMessage());
            return false;
        }
        try { // Attempt to update opp
            Opportunity oppToUpdate = setFieldsOnOpportunity(struct.opportunityId);
            update oppToUpdate;
        }
        catch( Exception e ) {
            this.et.addError('Trouble updating opp fields! Error: ' + e.getMessage());
            return false;
        }
        try {
            Contact contactToUpdate = new Contact(Id = struct.contactId);
            contactToUpdate.OwnerId = getAccountOwnerId(struct.accountId);
            update contactToUpdate;
        }
        catch( Exception e ) {
            this.et.addError('Trouble updating contact fields!  Error: ' + e.getMessage());
            return false;
        }
        // If no errors, return success
        return true;
    }

    /**
     * This method converts the related object to an online sales struct for processing
     *
     * @param SObject relatedObject - the object related to the incoming OnlineSales_Message
     * @return OnlineSales_StructCreator.OnlineSalesStruct - struct containing objects that need to be populated with OnlineSales_Message data
     */
    protected OnlineSales_StructCreator.OnlineSalesStruct createStructFromRelatedObject(SObject relatedObject) {
        if( relatedObject == null ) { // check for null inputs
            et.addError('Null realtedObject passed, going to be unable to create an Opportunity!');
            return null;
        }
        OnlineSales_StructCreator structCreator = new OnlineSales_StructCreator(this.message, this.et);
        OnlineSales_StructCreator.OnlineSalesStruct struct = null;
        if( relatedObject instanceOf Contact ) {
            struct = structCreator.createStructFromContact((Contact)relatedObject, getDefaultCampaignId());
        }
        else if( relatedObject instanceOf Lead ) {
            struct = structCreator.createStructFromLead((Lead)relatedObject, getDefaultCampaignId());
        }
        else if( relatedObject instanceOf Account ) {
            struct = structCreator.createStructFromAccount((Account)relatedObject, getDefaultCampaignId());
        }
        else if( relatedObject instanceOf Opportunity ) {
            struct = structCreator.createStructFromOpportunity((Opportunity)relatedObject, getDefaultCampaignId());
        }
        else {
            et.addError('Unable to process related object type: ' + relatedObject.getSObjectType());
            struct = null;
        }
        return struct;
    }

    /**
     * Update fields on Opportunity with OnlineSales_Message. DOES NOT DML UPDATE THE OPP
     *
     * @param Id opportunityId - id of Opportunity to update
     * @return Opportunity - opp with updated fields
     */
    protected Opportunity setFieldsOnOpportunity(Id opportunityId) {
        Opportunity oppToUpdate = [SELECT Id, Name, AccountId FROM Opportunity WHERE Id = :opportunityId];
        oppToUpdate.CloseDate = this.message.getTransactionDateAsDate();
        if( this.message.enterpriseId != null ) {
            oppToUpdate.Box_Enterprise_Id__c = String.valueOf(this.message.enterpriseId);
        }
        oppToUpdate.Name = oppToUpdate.Name + getOppNameAddendum();
        if( this.message.billingPeriod != null ) {
            oppToUpdate.Fee_Frequency__c = OnlineSales_Constants.billingPeriodToPaymentFrequency.get(this.message.billingPeriod.toLowerCase());
        }
        oppToUpdate.Payment_Term__c = OnlineSales_Constants.paymentFrequencyToContractTerm.get(oppToUpdate.Fee_Frequency__c);
        oppToUpdate.CurrencyISOCode = this.message.currencyCode;
        oppToUpdate.StageName = OnlineSales_Constants.OPP_STAGENAME_CLOSED_WON;
        oppToUpdate.Account_Type_Sold__c = OnlineSales_Constants.tierToAccountTypeSold.get(this.message.tierAfter);
        oppToUpdate.Rep_Quota_Relief__c = true;
        oppToUpdate.Seats_Sold__c = this.message.enterpriseSeatsPurchased;
        oppToUpdate.OwnerId = getOpportunityOwnerId(oppToUpdate.Id);
        Decimal recurringRevenue = this.message.arrAfter;
        if( this.message.arrBefore != null ) {
            recurringRevenue = recurringRevenue - this.message.arrBefore;
        }
        if( oppToUpdate.Fee_Frequency__c == OnlineSales_Constants.PAYMENT_FREQUENCY_MONTHLY ) {
            oppToUpdate.MRR_Annualized__c = recurringRevenue;
            oppToUpdate.ARR__c = null;
        }
        else {
            oppToUpdate.ARR__c = recurringRevenue;
        }
        
        oppToUpdate.Amount = recurringRevenue;
        return oppToUpdate;
    }

    /**
     * Update fields on Account with OnlineSales_Message. DOES NOT DML UPDATE THE ACCOUNT
     *
     * @param Id accountId - id of Account to update
     * @return Account - account with updated fields
     */
    protected Account setFieldsOnAccount(Id accountId) {
        Account accToUpdate = [SELECT Id, Box_Enterprise_Id__c, Billing_Theater__c FROM Account WHERE Id = :accountId];
        if( accToUpdate.Box_Enterprise_Id__c == null && this.message.enterpriseId != null ) {
            accToUpdate.Box_Enterprise_Id__c = String.valueOf(this.message.enterpriseId);
        }
        accToUpdate.OwnerId = getAccountOwnerId(accountId);
        return accToUpdate;
    }

    protected Id getAccountOwnerId(Id accountId) {
        if( accountId == null ) {
            return OnlineSales_Constants.getSopsToReassignUserId();
        }
        Account account = [SELECT Id, OwnerId, Owner.isActive FROM Account WHERE Id = :accountId LIMIT 1];
        // If the account owner is an illegal owner or inactive, use Sops To Reassign User
        if( OnlineSales_Constants.getIllegalBoxOnlineSalesOwnerIds().contains(account.OwnerId) || !account.Owner.isActive ) {
            return OnlineSales_Constants.getSopsToReassignUserId();
        }
        else {
            return account.OwnerId;
        }
    }

    /* Abstract Methods */

    abstract String getTransactionType();
    abstract String getOppNameAddendum();
    abstract Id getOpportunityOwnerId(Id oppId);
    abstract Id getDefaultCampaignId();

    

    /**
     * This struct represents a return value for the transaction process, including objects affected and an error code
     */
    public class TransactionResult {
        public Id opportunityId;
        public Id accountId;
        public Id contactId;
        public ErrorTracker et;
        public OnlineSales_Constants.TransactionResultCode resultCode;

        public TransactionResult(OnlineSales_StructCreator.OnlineSalesStruct struct, OnlineSales_Constants.TransactionResultCode resultCode, ErrorTracker et) {
            if( struct != null ) {
                this.accountId = struct.accountId;
                this.opportunityId = struct.opportunityId;
                this.contactId = struct.contactId;
            }
            this.et = et;
            this.resultCode = resultCode;
        }
    }
}