/**
 * Constants related to Box Online Sales
 *
 * @author Kyle Vermeer 08/29/2014
 */
public class OnlineSales_Constants {

    public enum TransactionResultCode {
        SUCCESS,
        INVALID_DATA_PROVIDED,
        TROUBLE_FINDING_OR_CREATING_DATA,
        UNABLE_TO_CREATE_OPP,
        TROUBLE_UPDATING_FIELDS
    }

    public static final String PAYMENT_FREQUENCY_MONTHLY = 'Monthly';

    public static final String OPP_NAME_ADDENDUM_EXPANSION = ' In-App Expansion';
    public static final String OPP_NAME_ADDENDUM_UPGRADE = ' In-App Upgrade';
    public static final String OPP_STAGENAME_SUBMITTED = 'Submitted From Online Sales';
    public static final String LEAD_CONVERTED_STATUS_NO_OPP = 'Converted - No Opportunity';
    public static final String LEAD_CONVERTED_STATUS_OPP = 'Qualified - New Opportunity';
    public static final String OPP_STAGENAME_CLOSED_WON = 'Closed Won';

    public static final String TRANSACTION_TYPE_EXPANSION = 'Expansion';
    public static final String TRANSACTION_TYPE_UPGRADE = 'Upgrade';

    private static Id onlineSalesUserId = null;
    private static Id sopsToReassignUserId = null;
    private static Set<Id> illegalOnlineSalesUsersIds = null;

    public static Id getBoxOnlineSalesUserId() {
        if( onlineSalesUserId == null ) { // lazy instantiation
            onlineSalesUserId = Online_Sales_Settings__c.getInstance().Box_Online_Sales_User__c;
        }
        return onlineSalesUserId;
    }

    public static Id getSopsToReassignUserId() {
        if( sopsToReassignUserId == null ) { // lazy instantiation
            sopsToReassignUserId = Online_Sales_Settings__c.getInstance().Sops_To_Reassign_User_Id__c;
        }
        return sopsToReassignUserId;
    }

    public static Set<Id> getIllegalBoxOnlineSalesOwnerIds() {
        if( illegalOnlineSalesUsersIds == null ) { // lazy instantiation
            illegalOnlineSalesUsersIds = new Set<Id>();
            String illegalUsersString = Online_Sales_Settings__c.getInstance().Illegal_Online_Sales_Opp_Owners__c;
            // split list delimited by semi-colons
            String[] illegalUsersStringList = illegalUsersString.split(';');
            // attempt to add each id to the list
            for( String illegalUserId : illegalUsersStringList ) {
                try {
                    illegalOnlineSalesUsersIds.add(illegalUserId);
                }
                catch( Exception e ) {
                    System.debug('String: ' + illegalUserId + ' could not be transformed into an ID.  Ignoring it as illegal OnlineSalesOwner.');
                }
            }
        }
        return illegalOnlineSalesUsersIds;
    }

    /**
     * This map covers the mapping from Box billingPeriod to Salesforce Payment Frequency
     *
     * @return Map<String, String> - map from Box billingPeriod to Salesforce Payment Frequency
     */
    public static Map<String, String> billingPeriodToPaymentFrequency {
        get {
            if( billingPeriodToPaymentFrequency == null ) {
                billingPeriodToPaymentFrequency = new Map<String, String>{
                    'annual' => 'Annual',
                    'month' => PAYMENT_FREQUENCY_MONTHLY,
                    'quarter' => 'Quarterly',
                    'semi-annual' => 'Semi-Annual',
                    'two years' => 'Two Year Deal',
                    'three years' => 'Three Year Deal'
                };
            }
            return billingPeriodToPaymentFrequency;
        }
        set;
    }

    /**
     * This map covers the mapping from Salesforce Payment Frequency to Salesforce Contract Term
     *
     * @return Map<String, Integer> - map from Salesforce Payment Frequency to Salesforce Contract Term
     */
    public static Map<String, Integer> paymentFrequencyToContractTerm {
        get {
            if( paymentFrequencyToContractTerm == null ) {
                paymentFrequencyToContractTerm = new Map<String, Integer>{
                    'Monthly' => 1,
                    'Annual' => 12,
                    'Quarterly' => 12,
                    'Semi-Annual' => 12,
                    'Two Year Deal' => 12,
                    'Three Year Deal' => 12
                };
            }
            return paymentFrequencyToContractTerm;
        }
        set;
    }

    /**
     * This map covers the mappings from tier to Account Type Sold
     *
     * @return Map<String, String> - map from tier to Account Type Sold
     */
    public static Map<String, String> tierToAccountTypeSold {
        get {
            if( tierToAccountTypeSold == null ) {
                tierToAccountTypeSold = new Map<String, String> {
                    'developer' => null,
                    'slave' => null,
                    'lite' => null,
                    'professional' => 'Personal Pro',
                    'starter' => 'Starter',
                    'business' => 'Business',
                    'business_plus' => 'Business Plus',
                    'enterprise' => 'Enterprise',
                    'elite' => 'Elite'
                };
            }
            return tierToAccountTypeSold;
        }
        set;
    }

    /**
     * Returns the id of the default campaign for in app upgrades
     *
     * @return Id - Id of the default campaign for in app upgrades
     */
    public static Id getInAppUpgradeCampaignId() {
        return Online_Sales_Settings__c.getInstance().In_App_Upgrade_Campaign_Id__c;
    }

    /**
     * Returns the id of the default campaign for in app expansions
     *
     * @return Id - Id of the default campaign for in app expansions
     */
    public static Id getExpansionCampaignId() {
        return Online_Sales_Settings__c.getInstance().Expansion_Campaign_Id__c;
    }
}