/**
 * Methods for creating OnlineSales_Structs
 *
 * @author Kyle Vermeer 9/19/14
 */
public class OnlineSales_StructCreator {
    
    private ErrorTracker et;
    private OnlineSales_Message message;

    public OnlineSales_StructCreator(OnlineSales_Message message, ErrorTracker et) {
        this.et = et;
        this.message = message;
    }

    /**
     * Create an OnlineSalesStruct for further processing from an Account
     *
     * @param Account matchingAccount - the account that matches the OnlineSales_Message
     * @param Id defaultCampaignId - default campaign id for this transaction
     * @return OnlineSalesStruct - struct containing all objects needed for processing the OnlineSales_Message
     */
    public OnlineSalesStruct createStructFromAccount(Account matchingAccount, Id defaultCampaignId) {
        Contact newContact = new Contact(Email = this.message.userLogin, AccountId = matchingAccount.Id);
        populateContactName(newContact, this.message.userName);
        try {
            insert newContact;   
        }
        catch( Exception e ) {
            et.addError('Unable to create contact. Error: ' + e.getMessage());
            return null;
        }
        Opportunity newOpp = createOpp(matchingAccount.Name, matchingAccount.Id, newContact.Id);
        if( newOpp == null ) { // If there was trouble creating the oppm return null;
            return null;
        }
        OnlineSales_CampaignAssociation campaignAssociation = new OnlineSales_CampaignAssociation(this.et);
        campaignAssociation.associateCampaignNoActiveResponse(newContact.Id, newOpp.Id, defaultCampaignId);
        OnlineSalesStruct struct = new OnlineSalesStruct(matchingAccount.Id, newOpp.Id, newContact.Id);
        return struct;
    }

    /**
     * Create an OnlineSalesStruct for further processing from an Opportunity
     *
     * @param Opportunity matchingOpportunity - the opportunity that matches the OnlineSales_Message
     * @param Id defaultCampaignId - default campaign id for this transaction
     * @return OnlineSalesStrcut - struct containing all objects needed for processing the OnlineSales_Message
     */
    public OnlineSalesStruct createStructFromOpportunity(Opportunity matchingOpportunity, Id defaultCampaignId) {
        Contact newContact = new Contact(Email = this.message.userLogin, AccountId = matchingOpportunity.AccountId);
        populateContactName(newContact, this.message.userName);
        try {
            insert newContact;   
        }
        catch( Exception e ) {
            et.addError('Unable to create contact. Error: ' + e.getMessage());
            return null;
        }
        Opportunity newOpp = createOpp(matchingOpportunity.Account.Name, matchingOpportunity.AccountId, newContact.Id);
        if( newOpp == null ) { // If there was trouble creating the oppm return null;
            return null;
        }
        OnlineSales_CampaignAssociation campaignAssociation = new OnlineSales_CampaignAssociation(this.et);
        campaignAssociation.associateCampaignNoActiveResponse(newContact.Id, newOpp.Id, defaultCampaignId);
        OnlineSalesStruct struct = new OnlineSalesStruct(matchingOpportunity.AccountId, newOpp.Id, newContact.Id);
        return struct;
    }

    /**
     * Create an OnlineSalesStruct for further processing from a contact
     *
     * @param Contact matchingContact - the contact found that matches the OnlineSales_Message
     * @param Id defaultCampaignId - default campaign id for this transaction
     * @return OnlineSalesStruct - struct containing all objects needed for processing the OnlineSalesMessage
     */
    public OnlineSalesStruct createStructFromContact(Contact matchingContact, Id defaultCampaignId) {
        Id accountId = matchingContact.AccountId;
        Account accountFromContact = [SELECT Id, Name, OwnerId FROM Account WHERE Id = :accountId];
        // Campaign
        List<CampaignMember> activeResponses = FCRM.FCR_SupportAPI.GetActiveResponses(new List<Id> { matchingContact.Id });
        Opportunity newOpp = null;
        OnlineSales_CampaignAssociation campaignAssociation = new OnlineSales_CampaignAssociation(this.et);
        if( !activeResponses.isEmpty() ) { // if there is an active response
            campaignAssociation.associateDefaultCampaignContactWithActiveResponse(matchingContact.Id, defaultCampaignId);
            newOpp = createOpp(accountFromContact.Name, accountFromContact.Id, matchingContact.Id);
            if( newOpp == null ) { // If there was trouble creating the oppm return null;
                return null;
            }
            campaignAssociation.associateActiveResponse(newOpp.Id, activeResponses[0]);
        }
        else { // no active response
            newOpp = createOpp(accountFromContact.Name, accountFromContact.Id, matchingContact.Id);
            if( newOpp == null ) { // If there was trouble creating the oppm return null;
                return null;
            }
            campaignAssociation.associateCampaignNoActiveResponse(matchingContact.Id, newOpp.Id, defaultCampaignId);
        }
        // END CAMPAIGN
        OnlineSalesStruct struct = new OnlineSalesStruct(accountFromContact.Id, newOpp.Id, matchingContact.Id);
        return struct;
    }

    /**
     * Create an OnlineSalesStruct for further processing from a lead
     *
     * @param Lead matchingLead - the lead found that matches the OnlineSales_Message
     * @param Id defaultCampaignId - default campaign id for this transaction
     * @return OnlineSalesStruct - struct containing all objects needed for processing the OnlineSales_Message
     */
    public OnlineSalesStruct createStructFromLead(Lead matchingLead, Id defaultCampaignId) {
        OnlineSalesStruct struct = null;
        OnlineSales_CampaignAssociation campaignAssociation = new OnlineSales_CampaignAssociation(this.et);
        CampaignMember activeResponse = campaignAssociation.getActiveResponseLead(matchingLead);
        if( activeResponse != null ) {
            campaignAssociation.associateDefaultCampaignWithLead(matchingLead.Id, defaultCampaignId);
            struct = convertLead(matchingLead, activeResponse);
        }
        else {
            struct = convertLead(matchingLead, activeResponse);
            campaignAssociation.associateCampaignNoActiveResponse(struct.contactId, struct.opportunityId, defaultCampaignId);
        }
        return struct;
    }

    /**
     * Create a new opp from an account and contact
     *
     * @param String oppName - name for opp
     * @param Id accountId - id for account of this opp
     * @param Id contactId - id for primary contact of this opp
     */
    private Opportunity createOpp(String oppName, Id accountId, Id contactId) {
        try {
            Opportunity newOpp = new Opportunity(Name = oppName, AccountId = accountId, CloseDate = this.message.getTransactionDateAsDate(),
                                             StageName = OnlineSales_Constants.OPP_STAGENAME_SUBMITTED);
            insert newOpp;
            OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = newOpp.Id, ContactId = contactId, IsPrimary = true);
            insert ocr;
            return newOpp;
        }
        catch( Exception e ) {
            et.addError('Trouble creating opp! Error: ' + e.getMessage());
            return null;
        }
    }

    /**
     * Converts lead with appropriate campaign attribution
     *
     * @param Lead l - lead to convert
     * @param CampaignMember activeResponse - active response for lead, may be null if no active response
     * @return OnlineSalesStruct - struct populated with items from lead convert
     */
    private OnlineSalesStruct convertLead(Lead l, CampaignMember activeResponse) {
        Database.LeadConvert leadConvert = new Database.LeadConvert();
        leadConvert.setLeadId(l.Id);
        if( activeResponse != null ) {
            leadConvert.setConvertedStatus(OnlineSales_Constants.LEAD_CONVERTED_STATUS_OPP);
        }
        else {
            leadConvert.setConvertedStatus(OnlineSales_Constants.LEAD_CONVERTED_STATUS_NO_OPP);
            leadConvert.setDoNotCreateOpportunity(true);
        }
        
        leadConvert.setOwnerId(OnlineSales_Constants.getSopsToReassignUserId());
        // If the lead has been domain matched to an account, use that for lead conversion
        if( l.Account__c != null ) { 
            leadConvert.setAccountId(l.Account__c);
        }
        try {
            Database.LeadConvertResult conversionResult = Database.convertLead(leadConvert);
            if( conversionResult.isSuccess() ) { // Successful lead conversion
                if( activeResponse != null ) { // Only will be an opp if there is an active response
                    String oppId = conversionResult.getOpportunityId();
                    OpportunityContactRole ocr = [SELECT Id FROM OpportunityContactRole WHERE OpportunityId = : oppId];
                    ocr.IsPrimary = true;
                    update ocr;
                }
            }
            else { // Error occured converting lead
                for( Database.Error currentError : conversionResult.getErrors() ) {
                    et.addError(currentError.getMessage());
                }
                // There was an error, return null
                return null;
            }
            OnlineSalesStruct struct = null;
            if( activeResponse != null ) {
                struct = new OnlineSalesStruct(conversionResult.getAccountId(), conversionResult.getOpportunityId(), conversionResult.getContactId());
            }
            else {
                Account acc = [SELECT Id, Name FROM Account WHERE Id = :conversionResult.getAccountId()];
                Opportunity newOpp = createOpp(acc.Name, acc.Id, conversionResult.getContactId());
                struct = new OnlineSalesStruct(conversionResult.getAccountId(), newOpp.Id, conversionResult.getContactId());
            }
            return struct;
        }
        catch( Exception e ) {
            et.addError('Error converting lead! Error: ' + e.getMessage());
            return null;
        }
    }

    /**
     * Populates the provided contact's first and last name fields
     *
     * @param Contact c - contact to populate
     * @param String name - name, will split by spaces to determine first and last names
     */
    private void populateContactName(Contact c, String name) {
        if( c != null && name != null) {
            if( name.contains(' ') ) {
                String[] namesList = name.split(' ');
                c.FirstName = namesList[0];
                c.LastName = namesList[namesList.size()-1];
            }
            else {
                c.LastName = name;
            }
        }
    } 

    /**
     * This struct represents the possible objects to be processed during an Online Sales Transaction
     */
    public class OnlineSalesStruct {
        public Lead lead;
        public Id accountId;
        public Id opportunityId;
        public Id contactId;

        public OnlineSalesStruct(Id accountId, Id opportunityId, Id contactId) {
            this.accountId = accountId;
            this.opportunityId = opportunityId;
            this.contactId = contactId;
        }
    }
}