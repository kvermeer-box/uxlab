/**
 * Methods for searching for data in our instance related to an OnlineSales_Message
 *
 * @author Kyle Vermeer 9/19/14
 */
public class OnlineSales_DataSearch {

    private ErrorTracker et;

    public OnlineSales_DataSearch(ErrorTracker et) {
        this.et = et;
    }
    /**
     * Search for a contact with the matching email
     *
     * @param String email - email to search for
     * @return Contact - contact with the matching email
     */
    public Contact searchForContact(String email) {
        if( email == null ) { // First check for null inputs
            this.et.addWarning('A null email was provided.  Could not find Contact.');
            return null;
        }
        // Try to query for contact with matching email
        Contact matchingContact = null;
        try {
            matchingContact = [SELECT Id, AccountId, Email FROM Contact WHERE Email = :email LIMIT 1];
        }
        catch (Exception e) {
            System.debug('Unable to find a contact for the provided email: ' + email);
        }
        return matchingContact;
    }

    /**
     * Search for a lead with the matching email
     *
     * @param String email - email to search for
     * @return Lead - lead with the matching email
     */
    public Lead searchForLead(String email) {
        if( email == null ) { // First check for null inputs
            this.et.addWarning('A null email was provided.  Could not find Lead.');
            return null;
        }
        // Try to query for Lead with matching email
        Lead matchingLead = null;
        try {
            matchingLead = [SELECT Id, Account__c, Company, Email FROM Lead WHERE Email = :email LIMIT 1];
        }
        catch (Exception e) {
            System.debug('Unable to find a lead for the provided email: ' + email);
        }
        return matchingLead;
    }

    /**
     * Search for an opportunity with the matching email
     *
     * @param Integer eId - enterprise ID to search for
     * @return Opportunity - opp with the matching eId
     */
    public Opportunity searchForOppByEID(Integer eId) {
        if( eId == null ) { // First check for null input
            this.et.addWarning('A null eid was provided.  Could not find Opportunity.');
            return null;
        }
        String eIdString = String.valueOf(eId);
        // Try to query for Opportunity with matching eId
        Opportunity matchingOpp = null;
        try {
            matchingOpp = [SELECT Id, AccountId, Box_Enterprise_ID__c, Account.Name FROM Opportunity WHERE Box_Enterprise_ID__c = :eIdString LIMIT 1];
        }
        catch (Exception e) {
            System.debug('Unable to find an opportunity for the provided eID');
        }
        return matchingOpp;
    }

    /**
     * Search for an account with the matching email
     *
     * @param Integer eId - enterprise ID to search for
     * @return Account - account with the matching eId
     */
    public Account searchForAccountByEID(Integer eId) {
        if( eId == null ) { // First check for null input
            this.et.addWarning('A null eid was provided. Could not find Account.');
            return null;
        }
        String eIdString = String.valueOf(eId);
        // Try to query for Account with matching eId
        Account matchingAccount = null;
        try {
            matchingAccount = [SELECT Id, Box_Enterprise_ID__c, OwnerId, Name FROM Account WHERE Box_Enterprise_ID__c = :eIdString LIMIT 1];
        }
        catch (Exception e) {
            System.debug('Unable to find an account for the provided eID');
        }
        return matchingAccount;
    }

    /**
     * Search for an account with domain matching
     *
     * @param String email - email to use as input for domain matching
     * @return Account - account that was found for the provided email
     */
    public Account searchForAccountByDomainMapping(String email) {
        if( email == null ) { // First check for null input
            this.et.addWarning('A null email was provided.  Could not find Account.');
            return null;
        }
        Id matchingAccountId = Domain_Utilities.getAccountForEmail(email);
        Account matchingAccount = null;
        if( matchingAccountId != null ) { // If we found an id, query the account
            try {
                matchingAccount = [SELECT Id, Name, Box_Enterprise_Id__c FROM Account WHERE Id = :matchingAccountId LIMIT 1];
            }
            catch (Exception e) {
                System.debug('Could not find account, even though we had an account ID from Domain Matching');
                et.addError('Could not find account, even though we had an account ID from Domain Matching');
            }
        }
        return matchingAccount;
    }

    /**
     * Create a lead based on the information from the OnlineSales_Message
     *
     * @param OnlineSales_Message message - message containing information about the Online Sales Transaction
     */
    public Lead createLeadForConversion(OnlineSales_Message message) {
        if( message == null ) { // Check for null input
            this.et.addWarning('A null message was provided.  Can\'t create a lead!');
            return null;
        }
        Lead newLead = new Lead();
        populateLeadName(newLead, message.userName);
        populateLeadEId(newLead, message.enterpriseId);
        newLead.Company = message.enterpriseName;
        if (newLead.Company == null || newLead.Company == '') { // If there was no enterprise name, use email as company instead
            newLead.Company = message.userLogin;
        }
        newLead.Email = message.userLogin;
        newLead.CurrencyISOCode = message.currencyCode;
        try {
            insert newLead;
        }
        catch (Exception e) {
            et.addError('Trouble creating lead.  Error: ' + e.getMessage());
        }
        return newLead;
    }

    /**
     * Populates the provided lead's first and last name fields
     *
     * @param Lead l - lead to populate
     * @param String name - name, will split by spaces to determine first and last names
     */
    private void populateLeadName(Lead l, String name) {
        if( name != null && l != null ) { // Make sure the input isn't null before attempting to set name
            if( name.contains(' ') ) {
                String[] namesList = name.split(' ');
                l.FirstName = namesList[0];
                l.LastName = namesList[namesList.size()-1];
            }
            else {
                l.LastName = name;
            }
        }
    }

    /**
     * Populates the provided lead's eId
     *
     * @param Lead l - lead to populate
     * @param Integer eId - enterprise Id
     */
    private void populateLeadEId(Lead l, Integer eId) {
        if( l != null && eId != null ) { // check for null inputs
            String eIdString = String.valueOf(eId);
            l.Box_Enterprise_Id__c = eIdString;
        }
    }

}