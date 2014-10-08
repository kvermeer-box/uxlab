/**
 * The return to the boxing gloves
 *
 * @author Kyle Vermeer 6/10/14
 */
public class BoxOutControllerV3 {

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

    private static final String OPPORTUNITY_FIELD_ID = 'CF00N60000002u9AV';//={!Opportunity.Name}&CF00N60000002Jhqy_lkid
    private static final String OPPORTUNITY_OWNER_FIELD_ID = 'CF00N60000002u9AS';
    private static final String ACCOUNT_FIELD_ID = 'CF00N60000002u9AF';
    private static final String ACCOUNT_OWNER_FIELD_ID = 'CF00N60000002u9AE';
    private static final String BOX_RESELLER_ACCOUNT_FIELD_ID = 'CF00N60000002u9AH';
    private static final String SALES_DIVISION_FIELD_ID = '00N60000002u9AY';
    private static final String COMPETITION_DETAILS_FIELD_ID = '00N60000002u9AI';
    private static final String SALES_ENGINEER_FIELD_ID = 'CF00N60000002u9AZ';
    private static final String BOX_EXECUTIVE_SPONSOR_FIELD_ID = '00N60000002u9AG';
    private static final String CUSTOMER_SUCCESS_MANAGER_FIELD_ID = '00N60000002u9AM';
    private static final String PRIMARY_COMPETITOR_FIELD_ID = '00N60000002u9AL';

    private static final String OPPORTUNITY_ID_PARAMETER = 'oppId';
  

    public BoxOut_Request__c salesRequest;
  
    public BoxOutControllerV3() {
        this.salesRequest = new BoxOut_Request__c();
        getInfoFromURL();
    }

    private void getInfoFromURL() {
        String oppId = ApexPages.currentPage().getParameters().get(OPPORTUNITY_ID_PARAMETER);
        if (oppId != null) {
            this.salesRequest.Opportunity__c = oppId;
            validateOpp();
        }
    }

    public BoxOut_Request__c getSalesRequest() {
        return this.salesRequest;
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

    public String validCompetitors {
        get {
            if (validCompetitors == null) {
                validCompetitors = '';
                List<String> competitors = BoxOutUtils.VALID_COMPETITORS;
                Integer competitorsLength = competitors.size();
                for (Integer i = 0; i < competitorsLength; i++) {
                    validCompetitors += competitors.get(i);
                    if (i != competitorsLength -1) {
                        validCompetitors += ', ';
                    }
                }
            }
            return validCompetitors;
        }
        set;
    }

    public void validateOpp() {
        if (this.salesRequest.Opportunity__c != null) {
            Id oppId = this.salesRequest.Opportunity__c;
            opp = [SELECT Name, Sales_Division__c, Competitor_We_Lost_To__c, StageName, Amount, CurrencyIsoCode, Owner.Name, OwnerId,
                          AccountId, Account.Name, Account.Owner.Name, Account.OwnerId, Competition_Details__c, Sales_Engineer_Lookup__r.Name, 
                          Sales_Engineer_Lookup__c, Executive_Sponsor__c, Account.Customer_Success_Manager__r.Name,
                          Box_Partner_Account__r.Name, Box_Partner_Account__c, Renewal_Amount__c
                          , Account.Executive_Sponsor__c, Probability
                     FROM Opportunity
                    WHERE Id = :oppId];
            Decimal amountUSD = 0;
            if (opp.Sales_Division__c == RENEWAL) {
                amountUSD = CurrencyUtils.convertAmountToUSD(opp.Renewal_Amount__c, opp.CurrencyISOCode);
            } else {
                amountUSD = CurrencyUtils.convertAmountToUSD(opp.Amount, opp.CurrencyISOCode);
            }
            // Validate Amount
            amountReqPassed = BoxOutUtils.validateAmountThreshold(opp.Sales_Division__c, amountUSD);
            // Validate Competitor
            competitorReqPassed = BoxOutUtils.validateCompetitorReq(opp.Competitor_We_Lost_To__c);
            // Validate Stage
            stageReqPassed = BoxOutUtils.validateStageReq((Integer)opp.Probability);
        }
    }

    public String getAmountReqColor() {
        if (amountReqPassed) {
            return GREEN_HEX;
        }
        else if (this.salesRequest.Opportunity__c!=null) {
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
        else if (this.salesRequest.Opportunity__c!=null) {
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
        else if (this.salesRequest.Opportunity__c!=null) {
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
        else if (this.salesRequest.Opportunity__c != null) {
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
            return '/a1n/e?' + getURLComponentsForAutoPopulate();
        } 
        else {
            return '#';
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
            urlAppend += '&' + PRIMARY_COMPETITOR_FIELD_ID + '=' + EncodingUtil.urlEncode(opp.Competitor_We_Lost_To__c, 'UTF-8');
        }
        return urlAppend;
    }

}