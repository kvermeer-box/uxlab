public class BoxOutController {

    public Opportunity opp;
    public Id boxOutRecordTypeId;

    public Boolean amountReqPassed = false;
    public Boolean competitorReqPassed = false;
    public Boolean stageReqPassed = false;

    private static final BoxOut_Settings__c settings = CustomSettings.getBoxOutSettings('default');

    private static final String RED_HEX = '#FF2222';
    private static final String GREEN_HEX = '#22AA22';
    private static final String BLACK_HEX = '#000000';

    private static final String RENEWAL = 'Renewal';

    private static final String VALID_BUTTON_TEXT = (settings != null) ? settings.Button_Text_Valid_Opp__c : null;
    private static final String INVALID_BUTTON_TEXT = (settings != null) ? settings.Button_Text_Invalid_Opp__c : null;
    private static final String NO_OPP_BUTTON_TEXT = (settings != null) ? settings.Button_Text_No_Opp__c : null;

    private static final String VALID_BUTTON_CURSOR = (settings != null) ? settings.Valid_Cursor__c : null;
    private static final String INVALID_BUTTON_CURSOR = (settings != null) ? settings.Invalid_Cursor__c : null;

    private static final List<String> VALID_COMPETITORS = (settings != null && settings.BoxOut_Competitors__c != null) ? settings.BoxOut_Competitors__c.split(';') : new List<String>();
    private static final List<String> INVALID_STAGES = (settings != null && settings.NOT_Accepted_Opp_Stages__c != null) ? settings.NOT_Accepted_Opp_Stages__c.split(';') : new List<String>();

    private static final String OPPORTUNITY_FIELD_ID = 'CF00N60000002Jhqy';//={!Opportunity.Name}&CF00N60000002Jhqy_lkid
    private static final String OPPORTUNITY_OWNER_FIELD_ID = 'CF00N60000002M4xV';
    private static final String ACCOUNT_FIELD_ID = 'CF00N60000002Jwvo';
    private static final String ACCOUNT_OWNER_FIELD_ID = 'CF00N60000002M4xP';
    private static final String BOX_RESELLER_ACCOUNT_FIELD_ID = 'CF00N60000002M5hI';
    private static final String SALES_DIVISION_FIELD_ID = '00N60000002M4xb';
    private static final String COMPETITION_DETAILS_FIELD_ID = '00N60000002M4xS';
    private static final String SALES_ENGINEER_FIELD_ID = 'CF00N60000002L79H';
    private static final String BOX_EXECUTIVE_SPONSOR_FIELD_ID = '00N60000002M4xQ';
    private static final String CUSTOMER_SUCCESS_MANAGER_FIELD_ID = '00N60000002M4xo';
    private static final String PRIMARY_COMPETITORY_FIELD_ID = '00N60000002M4xZ';
  

    public Sales_Request__c salesRequest;
  
    public BoxOutController() {
        RecordType recordType = [SELECT Id From RecordType WHERE SObjectType= 'Sales_Request__c' and Name = 'BoxOut'];
        salesRequest = new Sales_Request__c(RecordTypeId = recordType.Id);
        boxOutRecordTypeId = recordType.Id;
    }

    public Sales_Request__c getSalesRequest() {
        return salesRequest;
    }

    private Boolean isValidOpp()
    {
        if (amountReqPassed && competitorReqPassed && stageReqPassed) {
            return true;
        }
        else {
            return false;
        }
    }

    public void validateOpp() {
        if (salesRequest.Opportunity__c != null) {
            Id oppId = salesRequest.Opportunity__c;
            opp = [SELECT Name, Sales_Division__c, Competitor_We_Lost_To__c, StageName, Amount, CurrencyIsoCode, Owner.Name, OwnerId,
                          AccountId, Account.Name, Account.Owner.Name, Account.OwnerId, Competition_Details__c, Sales_Engineer_Lookup__r.Name, 
                          Sales_Engineer_Lookup__c, Executive_Sponsor__c, Account.Customer_Success_Manager__r.Name,
                          Box_Partner_Account__r.Name, Box_Partner_Account__c, Renewal_Amount__c
                          // , Account.Executive_Sponsor__c
                     FROM Opportunity
                    WHERE Id = :oppId];
            Decimal amountUSD = 0;
            if (opp.Sales_Division__c == RENEWAL) {
                amountUSD = CurrencyUtils.convertAmountToUSD(opp.Renewal_Amount__c, opp.CurrencyISOCode);
            } else {
                amountUSD = CurrencyUtils.convertAmountToUSD(opp.Amount, opp.CurrencyISOCode);
            }
            amountReqPassed = validateAmountThreshold(opp.Sales_Division__c, amountUSD);
            competitorReqPassed = validateCompetitorReq(opp.Competitor_We_Lost_To__c);
            stageReqPassed = validateStageReq(opp.StageName);
        }
    }

    /* Is the amount above the threshold for the appropriate sales division? */
    private Boolean validateAmountThreshold(String segment, Decimal amount) {
        if (segment == null || amount == null) { // Check for null inputs
            System.debug('Segment or amount null. Segment: ' + segment + '; amount: ' + amount);
            return false;
        }
        try {
            Amount_Threshold__c threshold = [SELECT Threshold_Amount__c
                                               FROM Amount_Threshold__c
                                              WHERE Program__c = 'BoxOut'
                                                AND Category__c = :segment];
            if (amount >= threshold.Threshold_Amount__c) { // Above threshold
                return true;
            }
            else { // Below threshold
                System.debug('Amount less then threshold amount.');
                System.debug('Amount: ' + amount + '.  Theshold Amount: ' + threshold.Threshold_Amount__c);
                return false;
            }
        }
        catch (QueryException e) { // If couldn't find the entry, print debug statement and return false
            System.debug('Could not find Amount_Threshold__c entry for BoxOut Program with Segement: ' + segment);
            return false;
        }
    }

    /* Is the primaryCompetitor for this opp on the valid competitor list? */
    private Boolean validateCompetitorReq(String primaryCompetitor)
    {
        if (primaryCompetitor == null) { // Check for null inputs
            System.debug('Primary Competitor provided was null.');
            return false;
        }
        // Very simply determine if valid competitor list contains the provided competitor
        for (String currentValidCompetitor : VALID_COMPETITORS) {
            if (currentValidCompetitor == primaryCompetitor) {
                return true;
            }
        }
        // If none of the valid competitors match, then the provided competitor is invalid
        return false;
    }

    /* Is the stage valid for a BoxOut Request? */
    private Boolean validateStageReq(String stageName)
    {
        if (stageName == null) { // Check for null inputs
            System.debug('StageName provided was null.');
            return false;
        }
        // Very simply determine if invalid stage list contains the provided stage
        for (String currentInvalidStage : INVALID_STAGES) {
            if (currentInvalidStage == stageName) {
                return false;
            }
        }
        // If it isn't a invalid stage, it must be a valid stage!
        return true;
    }

    public String getAmountReqColor() {
        if (amountReqPassed) {
            return GREEN_HEX;
        }
        else if (salesRequest.Opportunity__c!=null) {
            return RED_HEX;
        }
        else {
            return BLACK_HEX;
        }
    }

    public String getCompetitorReqColor() {
        if (competitorReqPassed) {
            return GREEN_HEX;
        }
        else if (salesRequest.Opportunity__c!=null) {
            return RED_HEX;
        }
        else {
            return BLACK_HEX;
        }
    }

    public String getStageReqColor() {
        if (stageReqPassed) {
            return GREEN_HEX;
        }
        else if (salesRequest.Opportunity__c!=null) {
            return RED_HEX;
        }
        else {
            return BLACK_HEX;
        }
    }

    public String getButtonColor() {
        if (isValidOpp()) {
            return GREEN_HEX;
        }
        else {
            return RED_HEX;
        }
    }

    public String getButtonText() {
        if (isValidOpp()) {
            return VALID_BUTTON_TEXT;
        }
        else if (salesRequest.Opportunity__c != null) {
            return INVALID_BUTTON_TEXT;
        }
        else {
            return NO_OPP_BUTTON_TEXT;
        }
    }

    public String getButtonCursor() {
        if (isValidOpp()) {
            return VALID_BUTTON_CURSOR;
        }
        else {
            return INVALID_BUTTON_CURSOR;
        }
    }

    public String getUrl() {
        if (isValidOpp()) {
            return '/a1H/e?RecordType=' + boxOutRecordTypeId + getURLComponentsForAutoPopulate();
        } 
        else {
            return '/apex/BoxOutRequest';
        }
    }

    public String getURLComponentsForAutoPopulate() {
        String urlAppend = '';
        if (opp.Name != null) {
            urlAppend += '&' + OPPORTUNITY_FIELD_ID + '=' + EncodingUtil.urlEncode(opp.Name,'UTF-8') + '&' + OPPORTUNITY_FIELD_ID + '_lkid=' + opp.Id;
        }
        if (opp.Owner != null && opp.Owner.Name !=null) {
            urlAppend += '&' + OPPORTUNITY_OWNER_FIELD_ID + '=' + EncodingUtil.urlEncode(opp.Owner.Name,'UTF-8') + '&' + OPPORTUNITY_OWNER_FIELD_ID + '_lkid=' + opp.OwnerId;
        }
        if (opp.Account != null && opp.Account.Name != null) {
            urlAppend += '&' + ACCOUNT_FIELD_ID + '=' + EncodingUtil.urlEncode(opp.Account.Name, 'UTF-8') + '&' + ACCOUNT_FIELD_ID + '_lkid=' + opp.AccountId;
        }
        if (opp.Account !=  null && opp.Account.Owner != null && opp.Account.Owner.Name != null) {
            urlAppend += '&' + ACCOUNT_OWNER_FIELD_ID + '=' + EncodingUtil.urlEncode(opp.Account.Owner.Name, 'UTF-8') + '&' + ACCOUNT_OWNER_FIELD_ID + '_lkid=' + opp.Account.OwnerId;
        }
        if (opp.Box_Partner_Account__c != null) {
            urlAppend += '&' + BOX_RESELLER_ACCOUNT_FIELD_ID + '=' + EncodingUtil.urlEncode(opp.Box_Partner_Account__r.Name, 'UTF-8') + '&' + BOX_RESELLER_ACCOUNT_FIELD_ID + '_lkid=' + opp.Box_Partner_Account__c;
        }
        if (opp.Sales_Division__c != null) {
            urlAppend += '&' + SALES_DIVISION_FIELD_ID + '=' + EncodingUtil.urlEncode(opp.Sales_Division__c, 'UTF-8');
        }
        if (opp.Competition_Details__c != null) {
            urlAppend += '&' + COMPETITION_DETAILS_FIELD_ID + '=' + EncodingUtil.urlEncode(opp.Competition_Details__c, 'UTF-8');
        }
        if (opp.Sales_Engineer_Lookup__r != null) {
            urlAppend += '&' + SALES_ENGINEER_FIELD_ID + '=' + EncodingUtil.urlEncode(opp.Sales_Engineer_Lookup__r.Name, 'UTF-8') + '&' + SALES_ENGINEER_FIELD_ID + '=' + EncodingUtil.urlEncode(opp.Sales_Engineer_Lookup__c, 'UTF-8');
        }
        /*
        if (opp.Account.Executive_Sponsor__c != null) {
            urlAppend += '&' + BOX_EXECUTIVE_SPONSOR_FIELD_ID + '=' + EncodingUtil.urlEncode(opp.Account.Executive_Sponsor__c, 'UTF-8');
        }
        */
        if (opp.Account.Customer_Success_Manager__r != null) {
            urlAppend += '&' + CUSTOMER_SUCCESS_MANAGER_FIELD_ID + '=' + EncodingUtil.urlEncode(opp.Account.Customer_Success_Manager__r.Name, 'UTF-8');
        }
        if (opp.Competitor_We_Lost_To__c != null) {
            urlAppend += '&' + PRIMARY_COMPETITORY_FIELD_ID + '=' + EncodingUtil.urlEncode(opp.Competitor_We_Lost_To__c, 'UTF-8');
        }
        return urlAppend;
    }
}