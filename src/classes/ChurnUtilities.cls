/**
 * Methods to provide utility functions for churn.
 *
 * @author Kyle Vermeer <kvermeer@box.com>
 * @revision 1.0 Kyle Vermeer 4/4/2014 Inital Creation
 */
public class ChurnUtilities {

    // Constants
    public static final String CHURN_OPP_STAGE = 'Cancellation - Churn';
    public static final String CONTACT_METHOD_MOST_RECENT_CHURN = 'Renewal';

    // Properties 
    public static CloneToChurnSettings__c settings {
        get {
            if (settings == null) {
                settings = CustomSettings.getCloneToChurnSettings();
            }
            return settings;
        }
        set;
    }

    /* Public API */
    
    /**
     * Clones an opp for churning.
     *
     * This process requires a original opp to clone and a closed won renewal opp to function correctly.
     *
     * @param {Id} oppId - Id of original opp to clone
     * @param {ErrorTracker} et - ErrorTracker for tracking what went wrong, if anything.  Optional.
     * @return {Id} - Id of cloned churn opp.
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    public static Id cloneToChurn(Id oppId, ErrorTracker et) {
        if (oppId == null) { // Check for null input
            System.debug('Null oppId provided.');
            if (et != null) {
                et.addError('Null oppId provided.');
            }
            return null;
        }
        // Create churned opp
        Opportunity churnedOpp = createChurnedOpp(oppId,et);
        if (churnedOpp != null) {
            try { // Try to insert the cloned opp
                insert churnedOpp;
                churnedOpp.Contact_Method_Most_Recent__c = CONTACT_METHOD_MOST_RECENT_CHURN;
                update churnedOpp;
                return churnedOpp.Id;
            }
            catch (Exception e) {
                System.debug('Issue inserting cloned opp.');
                new LoggedException(e, 'Issue inserting cloned opp', 'ChurnUtilities', new List<Id> { oppId });
                if (et != null) et.addError('Issues inserting cloned opp.  Reason: ' + e.getMessage());
                return null;
            }
        }
        else { // ChurnedOpp was null.
            System.debug('Churned opp was null');
            if (et != null) et.addError('Unable to create the Churned Opp.');
            return null;
        }    
    }

    /* Private Methods */

    /**
     * Contains the logic to clone provided opp, then churn the newly created opp.
     *
     * @param {Id} oppId - Id of opp to clone
     * @param {ErrorTracker} et - for tracking potential errors. Optional.
     * @return {Opportunity} - newly created churned opp
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    @TestVisible
    private static Opportunity createChurnedOpp(Id oppId, ErrorTracker et) {
         if (oppId == null) { // Check for null input
            System.debug('Null oppId provided.');
            if (et != null) {
                et.addError('Null oppId provided.');
            }
            return null;
        }
        // Get original opp for cloning
        Opportunity originalOpp = getOriginalOpportunity(oppId, et);
        if (originalOpp == null) { // This is bad if we can't retrieve the original opp
            return null;
        }
        // Clone the opp
        Opportunity clonedOpp = originalOpp.clone(false,true,false,false);
        // Get fields manipulations from original opp
        clonedOpp = translateFieldsFromOriginalOpp(originalOpp, clonedOpp);
        if (clonedOpp == null) { // Trouble grabbing fields from original opp
            if (et != null) et.addError('Trouble grabbing fields from Original Opp');
            return null;
        }
        // Get Renewal opp and do field manipulations
        Opportunity renewalOpp = findRenewalOpp(originalOpp.AccountId, et);
        clonedOpp = translateFieldsFromRenewalOpp(renewalOpp, clonedOpp);
        if (clonedOpp == null) { // Trouble grabbing fields for Renewal Opp
            if (et != null) et.addError('Trouble grabbing fields from Renewal Opp');
            return null;
        }
        // Get Risk and do field manipulations
        Risk__c risk = findRisk(originalOpp.AccountID, et);
        clonedOpp = translateFieldsFromRisk(risk, clonedOpp);
        // Do Churn related field manipulations
        clonedOpp = applyChurnFields(clonedOpp);
        return clonedOpp;
    }

    /**
     * Just returns the original opp with fields needed for churn process.
     *
     * @param {Id} originalOppId - Id of opp to be queried
     * @param {ErrorTracker} et - for tracking any errors. Optional
     * @return {Opportunity} - opp with Id provided, with all fields needed for churn process.
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    private static Opportunity getOriginalOpportunity(Id originalOppId, ErrorTracker et) {
        if (originalOppId == null) {
            System.debug('Null required input originalOppId');
            return null;
        }
        try {
            Opportunity originalOpp = [SELECT Id, Name, CloseDate, Seats_Sold__c, Amount, ARR__c, NRR__c, AccountId, OwnerId,
                                              Fee_Frequency__c, Payment_Method__c, Account_Type_Sold__c, Box_Enterprise_ID__c, MRR_Annualized__c
                                         FROM Opportunity
                                        WHERE Id = :originalOppId];
            return originalOpp;
        }
        catch (Exception e) { // Had problem querying opp
            System.debug('Issue querying for opp.');
            new LoggedException(e, 'Issues querying for original Opp.', 'ChurnUtilities', new List<Id> { originalOppId });
            if (et != null) et.addError('Issue querying for opp to clone.');
            return null;
        }
    }

    /**
     * Translates the appropriate fields from the original opp to the cloned opp for the churn process.
     *
     * @param {Opportunity} originalOpp - opp from which the fields are being taken
     * @param {Opportunity} clonedOpp - cloned opp that will eventually be churned
     * @return {Opportunity} - clonedOpp with updated fields, same object as the clonedOpp parameter
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    private static Opportunity translateFieldsFromOriginalOpp(Opportunity originalOpp, Opportunity clonedOpp) {
        if (originalOpp == null || clonedOpp == null) { // Check for null inputs
            System.debug('Null required input. OriginalOpp: ' + originalOpp + '; clonedOpp: ' + clonedOpp);
            return null;
        }
        clonedOpp.Name = clonedOpp.Name + settings.Churn_Opp_Name_Appendage__c;
        clonedOpp.Original_Close_Date__c = originalOpp.CloseDate;
        clonedOpp.Seats_Sold__c = originalOpp.Seats_Sold__c;
        clonedOpp.Amount = originalOpp.Amount;
        clonedOpp.ARR__c = originalOpp.ARR__c;
        clonedOpp.Fee_Frequency__c = originalOpp.Fee_Frequency__c;
        clonedOpp.Payment_Method__c = originalOpp.Payment_Method__c;
        clonedOpp.Account_Type_Sold__c = originalOpp.Account_Type_Sold__c;
        clonedOpp.Box_Enterprise_ID__c = originalOpp.Box_Enterprise_ID__c;
        clonedOpp.MRR_Annualized__c = originalOpp.MRR_Annualized__c; 
        User originalOppOwner = [SELECT Id, isActive
                                   FROM User
                                  WHERE Id = :originalOpp.OwnerId];
        if (originalOppOwner.isActive) { // If active, use that opp owner
            clonedOpp.OwnerId = originalOpp.OwnerId;
        }
        else { // If not active, use NRU
            clonedOpp.OwnerId = settings.Inactive_User_Replacement_Id__c;
        }
        return clonedOpp;
    }

    /**
     * Gets the most recent closed won renewal opp for the provided account.
     *
     * @param {Id} accountId - Id of account for which we want to find the most recent renewal
     * @param {ErrorTracker} et - error tracking in case something goes wrong.  Optional
     * @return {Opportunity} - renewal opp with fields neccessary for churn process
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    @TestVisible
    private static Opportunity findRenewalOpp(Id accountId, ErrorTracker et) {
        if (accountId == null) { // Check for null input
            System.debug('accoundId provided was null!');
            if (et != null) et.addError('accoundId provided was null!');
            return null;
        }
        try { // Try to query for renewal Opps
            List<Opportunity> renewalOpps = [SELECT Id, CloseDate, Renewal_Date_Renewals__c, Renewal_Manager__c, 
                                                    Link_to_Contract__c
                                               FROM Opportunity
                                              WHERE AccountId = :accountId
                                                AND StageName = 'Closed Won'
                                                AND Renewal_Manager__c != null
                                           ORDER BY CloseDate DESC];
            if (renewalOpps.isEmpty()) { // Coudn't find any renewal opps
                System.debug('No renewal Opp could be found');
                if (et != null) et.addError('No renewal Opp could be found');
                return null;
            }
            else { // Renewal opps were found, return the most recent one
                Opportunity renewalOpp = renewalOpps.get(0); // get most recent
                return renewalOpp;
            }
        }
        catch (Exception e) { // Error during the query
            System.debug('Error querying for renewal Opps.');
            new LoggedException(e, 'Error querying for renewal Opps.', 'ChurnUtilities');
            if (et != null) et.addError('Error querying for renewal Opps.');
            return null;
        }
    }

    /**
     * Translates fields from the renewal opp to the cloned (churn) opp.
     *
     * @param {Opportunity} renewalOpp - Renewal opp.
     * @param {Opportunity} clonedOpp - Cloned, churn opp.
     * @return {Opportunity} - clonedOpp, with fields from renewalOpp
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    private static Opportunity translateFieldsFromRenewalOpp(Opportunity renewalOpp, Opportunity clonedOpp) {
        if (renewalOpp == null || clonedOpp == null) {
            System.debug('Null required input.  renewalOpp: ' + renewalOpp + '; clonedOpp: ' + clonedOpp);
            return null;
        }
        clonedOpp.CloseDate = renewalOpp.CloseDate;
        clonedOpp.Renewal_Date_Renewals__c = renewalOpp.Renewal_Date_Renewals__c;
        clonedOpp.Renewal_Manager__c = renewalOpp.Renewal_Manager__c;
        clonedOpp.Link_To_Contract__c = renewalOpp.Link_To_Contract__c;
        return clonedOpp;
    }

    /**
     * Find the most recent risk for the given accountId.
     *
     * @param {Id} accountId - id of account to find risk for
     * @param {ErrorTracker} et - error tracker to watch for errors
     * @return {Risk__c} - most recent risk on account provided
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    @TestVisible
    private static Risk__c findRisk(Id accountId, ErrorTracker et) {
        if (accountId == null) { // check for null input
            System.debug('accountId provided was null!');
            if (et != null) et.addError('accountId provided was null!');
            return null;
        }
        try { // Try to query for most resent risk
            List<Risk__c> risks = [SELECT Id, Primary_Churn_Reason__c, Primary_Churn_Reason_Sub_reason__c,
                                          Post_Churn_Solution__c, Post_Churn_Solution_Sub_reason__c, Churn_Specifics__c
                                     FROM Risk__c
                                    WHERE Account__c = :accountId
                                 ORDER BY CreatedDate DESC];
            if (risks.isEmpty()) { // Couldn't find any risks
                System.debug('No risks could be found.');
                return null;
            }
            else { // Risks were found, take the most recent one
                Risk__c risk = risks.get(0); // get most recent
                return risk;
            }
        }
        catch (Exception e) { // Error during the query
            System.debug('Error quering for risks.');
            new LoggedException(e, 'Error querying for risks.', 'ChurnUtilities');
            if (et != null) et.addError('Error querying for risks');
            return null;
        }
    }

    /**
     * Translates fields from the risk to the cloned (churn) Opportunity
     * 
     * @param {Risk__c} risk - risk from which to translate fields
     * @param {Opportunity} clonedOpp - opp to translate fields to
     * @return {Opportunity} - clonedOpp with new fields from risk
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    private static Opportunity translateFieldsFromRisk(Risk__c risk, Opportunity clonedOpp) {
        if (risk == null || clonedOpp == null) { // We will allow for null inputs here, just return clonedOpp
            System.debug('Null inputs. Risk: ' + risk + '; clonedOpp: ' + clonedOpp);
            return clonedOpp;
        }
        clonedOpp.Primary_Churn_Reason__c = risk.Primary_Churn_Reason__c;
        clonedOpp.Primary_Churn_Reason_Detail__c = risk.Primary_Churn_Reason_Sub_reason__c;
        clonedOpp.Post_Churn_Solution__c = risk.Post_Churn_Solution__c;
        clonedOpp.Post_Churn_Solution_Sub_reason__c = risk.Post_Churn_Solution_Sub_reason__c;
        clonedOpp.Churn_Specifics__c = risk.Churn_Specifics__c;
        return clonedOpp;
    }

    /**
     * This makes fields updates that are constant for all churn opps.
     *
     * @param {Opportunity} clonedOpp - cloned (churn) opp
     * @return {Opportunity} - clonedOpp with new churn fields updated
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    private static Opportunity applyChurnFields(Opportunity clonedOpp) {
        if (clonedOpp == null) {
            System.debug('Null required input clonedOpp');
            return null;
        }
        clonedOpp.Renewal_Amount__c = null;
        clonedOpp.NRR__c = null;
        clonedOpp.Contact_Method_Most_Recent__c = CONTACT_METHOD_MOST_RECENT_CHURN;
        clonedOpp.Rep_Quota_Relief__c = true;
        clonedOpp.StageName = CHURN_OPP_STAGE;
        return clonedOpp;
    }
}