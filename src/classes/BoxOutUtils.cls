/**
 * Contains utility methods for BoxOut functionality.
 *
 * Includes methods to determine if opp is a valid BoxOut opp.
 *
 * @author Kyle Vermeer <kvermeer@box.com>
 * @version 1.0
 *
 * @revision 1.0 Kyle Vermeer 3/12/14
 * @revision 1.1. Kyle Vermeer 5/2/14
 * @revision 1.2 Kyle Vermeer 6/10/14
 */

public class BoxOutUtils {

    /* Static Properties */

    // Property for BoxOut Settings
    private static BoxOutV2_Settings__c settings {
        get {
            // Lazy instantiation
            if (settings == null) {
                settings = CustomSettings.getBoxOutV2Settings();
            }
            return settings;
        }
    }

    // Property abstracting probability
    private static Integer MIN_PROBABILITY = (Integer) settings.Minimum_Opp_Probability__c;

    // Property abstracting valid competitor list
    public static List<String> VALID_COMPETITORS {
        get {
            // Lazy instantiation
            if (VALID_COMPETITORS == null) {
                if (settings.BoxOut_Competitors__c == null) { // If settings values are null, just pass empty list
                    VALID_COMPETITORS = new List<String>();
                } else { 
                    VALID_COMPETITORS = settings.BoxOut_Competitors__c.split(';');
                }
            }
            return VALID_COMPETITORS;
        }  
    }

    // Property abstracting Thesholds
    public static Map<String,Decimal> THRESHOLD_MAP {
        get {
            // Lazy instantiation
            if (THRESHOLD_MAP == null) {
                try {
                    // Create Map, then populate it with sales division to amount mappings
                    THRESHOLD_MAP = new Map<String,Decimal>();
                    List<Amount_Threshold__c> thresholds = [SELECT Category__c, Threshold_Amount__c
                                                              FROM Amount_Threshold__c
                                                             WHERE Program__c = 'BoxOut'];
                    for (Amount_Threshold__c currentThreshold : thresholds) {
                        THRESHOLD_MAP.put(currentThreshold.Category__c, currentThreshold.Threshold_Amount__c);
                    }
                }
                catch (QueryException e) { // If couldn't find the entry, print debug statement and return false
                    new LoggedException(e, 'Trouble Querying AmountThresholds', 'BoxOutUtils');
                    // Return empty map
                    return new Map<String,Decimal>();
                }
            }
            return THRESHOLD_MAP;
        }
    }
    
    /**
     * Given an oppId, determines if the opp is qualified for BoxOut.
     *
     * @param {Id} oppId - Id of opp to check
     * @return {Boolean} - True if opp is valid for BoxOut, false otherwise
     * @author Kyle Vermeer <kvermeer@box.com>
     * @since 1.0
     */
    @TestVisible
    private static Boolean isQualifiedBoxOutOpp(Opportunity opp) {
        if (opp == null) { // Check for null inputs
            System.debug('Opp provided was null!');
            return false;
        }
        Decimal amountUSD = 0;
        if (opp.Sales_Division__c == UserRoleUtils.RENEWAL_SALES_DIVISION) {
            amountUSD = CurrencyUtils.convertAmountToUSD(opp.Renewal_Amount__c, opp.CurrencyISOCode);
        } else {
            amountUSD = CurrencyUtils.convertAmountToUSD(opp.Amount, opp.CurrencyISOCode);
        }
        Boolean amountReqPassed = validateAmountThreshold(opp.Sales_Division__c, amountUSD);
        Boolean competitorReqPassed = validateCompetitorReq(opp.Competitor_We_Lost_To__c);
        Boolean stageReqPassed = validateStageReq((Integer)opp.Probability);
        Boolean hasPreviousBoxOutRequests = hasPreviousBoxOutRequest(opp.BoxOut_Requests__r);
        return (amountReqPassed && competitorReqPassed && stageReqPassed && !hasPreviousBoxOutRequests);
    }

    /**
     * Give a list of opp ids, returns the opportunities that qualify for BoxOut
     *
     * @param {List<Id>} oppsToCheck - Ids of opportunities that we want to check for BoxOut qualification
     * @return {List<Opportunity>} - opps that have qualified for BoxOut
     * @author Kyle Vermeer 5/2/14
     */
    public static List<Opportunity> getQualfiedBoxOutOpps(List<Id> oppsToCheck) {
        if (oppsToCheck == null) {
            System.debug('Null input provided!');
            return null;
        }
        try {
            List<Opportunity> qualifiedOpps = new List<Opportunity>();
            if (oppsToCheck.isEmpty()) { // If the list is empty, don't waste any queries, just return empty list
                return qualifiedOpps;
            }
            // Query potential boxout opps
            List<Opportunity> potentialOpps = [SELECT Name, Sales_Division__c, Competitor_We_Lost_To__c, Probability, Amount, CurrencyIsoCode,
                                                      (SELECT Id FROM BoxOut_Requests__r), Renewal_Amount__c
                                                 FROM Opportunity
                                                WHERE Id IN :oppsToCheck];
            for (Opportunity opp : potentialOpps) { // for each opp
                if (isQualifiedBoxOutOpp(opp)) { // check if it is qualified
                    qualifiedOpps.add(opp); // if so, add it to the qualified list
                }
            }
            // return qualified opps
            return qualifiedOpps;
        }
        catch (Exception e) {
            System.debug('Exception getting qualified boxOutOpps');
            new LoggedException(e,'Exception getting qualified boxOutOpps','BoxOutUtils');
            return null;
        }
    }

    /**
     * Is the stage valid for a BoxOut Request? 
     *
     * @private
     * @static
     * @param {Integer} probability - Probability of opp
     * @return {Boolean} True if stage is valid, false otherwise
     * @author Kyle Vermeer <kvermeer@box.com>
     * @since 1.0
     */
    @TestVisible
    public static Boolean validateStageReq(Integer probability)
    {
        if (probability == null) { // Check for null inputs
            System.debug('Probability provided was null.');
            return false;
        }
        // Very simply determine if invalid stage list using the probability
        if (probability >= MIN_PROBABILITY) {
            return true;
        }
        else { // If it isn't a valid stage, it must be an invalid stage!
            return false;
        }
    }

    /**
     * Is the primaryCompetitor for this opp on the valid competitor list?
     *
     * @private
     * @static
     * @param {String} competitor - Primary Competitor of opp
     * @return {Boolean} True if competitor is valid, false otherwise
     * @author Kyle Vermeer <kvermeer@box.com>
     * @since 1.0
     */
    @TestVisible
    public static Boolean validateCompetitorReq(String competitor)
    {
        if (competitor == null) { // Check for null inputs
            System.debug('Primary Competitor provided was null.');
            return false;
        }
        // Very simply determine if valid competitor list contains the provided competitor
        for (String currentValidCompetitor : VALID_COMPETITORS) {
            if (currentValidCompetitor == competitor) {
                return true;
            }
        }
        // If none of the valid competitors match, then the provided competitor is invalid
        return false;
    }

    /**
     * Is the amount above the threshold for the appropriate sales division?
     *
     * @private
     * @static
     * @param {String} salesDivision - Sales Division for Opp (ESB, Corporate, etc...)
     * @param {Decimal} amount - Opp amount in USD
     * @return {Boolean} True if amount is valid, false otherwise
     * @author Kyle Vermeer <kvermeer@box.com>
     * @since 1.0
     */
    @TestVisible
    public static Boolean validateAmountThreshold(String salesDivision, Decimal amount) {
        if (salesDivision == null || amount == null) { // Check for null inputs
            System.debug('Sales Division or amount null. salesDivision: ' + salesDivision + '; amount: ' + amount);
            return false;
        }
        // Grab threshold amount from threshold map, then compare it to amount
        Decimal thresholdAmount = THRESHOLD_MAP.get(salesDivision);
        if (thresholdAmount == null) { // No entry found
            System.debug('Could NOT find threshold entry for sales division: ' + salesDivision);
            return false;
        }
        else if (amount >= thresholdAmount) { // Above threshold
            return true;
        }
        else { // Below threshold
            System.debug('Amount less then threshold amount.');
            System.debug('Amount: ' + amount + '.  Theshold Amount: ' + thresholdAmount);
            return false;
        }
    }

    /**
     * Did this opp already have a BoxOut Request?
     *
     * @private
     * @static
     * @param {List<BoxOut_Request__c>} requests - list of previous BoxOut requests
     * @return Boolean - True if there has been a previous BoxOut Request, false otherwise
     * @author Kyle Vermeer <kvermeer@box.com>
     * @since 1.0
     */
    @TestVisible
    private static Boolean hasPreviousBoxOutRequest(List<BoxOut_Request__c> requests) {
        if (requests == null) {
            System.debug('Null list provided!');
            return true;
        }
        if (requests.size() > 0) {
            return true;
        } else {
            return false;
        }
    }
}