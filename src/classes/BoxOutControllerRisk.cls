/**
 * BoxOut controller that allows for risks
 *
 * @author Kyle Vermeer 7/18/2014
 */
public class BoxOutControllerRisk {

    public Boolean amountReqPassed { get ; set; }
    public Boolean churnReasonReqPassed { get; set; }
    public Boolean churnSubReasonReqPassed { get; set; }

    private static final BoxOut_Settings__c settings = CustomSettings.getBoxOutSettings('default');

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
    private static final String RISK_FIELD_ID = 'CF00N60000002ughl';

    private static final String RISK_ID_PARAMETER = 'riskId';
  
    public BoxOut_Request__c salesRequest { get; set; }

    public BoxOutControllerRisk() {
        this.salesRequest = new BoxOut_Request__c();
        this.amountReqPassed = false;
        this.churnReasonReqPassed = false;
        this.churnSubReasonReqPassed = false;
        getURLInfo();
    }


    public Boolean isValidRisk {
        get {
            return amountReqPassed && churnReasonReqPassed && churnSubReasonReqPassed;
        }
    }

    private void getURLInfo() {
        String riskId = ApexPages.currentPage().getParameters().get(RISK_ID_PARAMETER);
        if (riskId != null) {
            this.salesRequest.Risk__c = riskId;
            validateRisk();
        }
    }

    public void validateRisk() {
        if (this.salesRequest.Risk__c != null) {
            Risk__c risk = [SELECT Id, ARR_at_Risk__c, Post_Churn_Solution__c, Post_Churn_Solution_Sub_reason__c, CurrencyISOCode FROM Risk__c where Id = :this.salesRequest.Risk__c];
            Decimal amountUSD = CurrencyUtils.convertAmountToUSD(risk.ARR_at_Risk__c, risk.CurrencyISOCode);
            // Check amount
            amountReqPassed = isValidAmount(amountUSD);
            // Check churn reasons
            churnReasonReqPassed = isValidChurnReason(risk.Post_Churn_Solution__c);
            churnSubReasonReqPassed = BoxOutUtils.validateCompetitorReq(risk.Post_Churn_Solution_Sub_reason__c);
        }
        else {
            amountReqPassed = false;
            churnReasonReqPassed = false;
            churnSubReasonReqPassed = false;
        }
    }

    private boolean isValidAmount(Decimal amountUSD) {
        System.debug('Amount to check: ' + amountUSD);
        return amountUSD >= 15000;
    }

    private boolean isValidChurnReason(String churnReason) {
        System.debug('Churn Reason to check: ' + churnReason);
        return churnReason == 'Competitor';
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

    public String getUrl() {
        if (this.isValidRisk) {
            return '/a1n/e?' + getURLComponentsForAutoPopulate(); 
        }
        else {
            return '#';
        }
    }

    public String getURLComponentsForAutoPopulate() {
        Account acc = null;
        Risk__c curRisk = null;
        String urlAppend = '';
        if (this.salesRequest.Risk__c != null) {
            curRisk = [SELECT Id, Name, Post_Churn_Solution_Sub_reason__c, Account__c FROM Risk__c WHERE Id = :salesRequest.Risk__c];
            acc = [SELECT Id, Name, Customer_Success_Manager__c, Customer_Success_Manager__r.Name, Owner.Name, Sales_Division__c FROM Account WHERE Id = :curRisk.Account__c];
            
            if (curRisk != null) {
                urlAppend += '&' + RISK_FIELD_ID + '=' + EncodingUtil.urlEncode(curRisk.Name, 'UTF-8') + '&' + RISK_FIELD_ID + '_lkid=' + curRisk.Id;
            }
            if (acc != null && acc.Name != null) {
                urlAppend += '&' + ACCOUNT_FIELD_ID + '=' + EncodingUtil.urlEncode(acc.Name, 'UTF-8') + '&' + ACCOUNT_FIELD_ID + '_lkid=' + acc.Id;
            }
            if (acc !=  null && acc.Owner != null && acc.Owner.Name != null) {
                urlAppend += '&' + ACCOUNT_OWNER_FIELD_ID + '=' + EncodingUtil.urlEncode(acc.Owner.Name, 'UTF-8') + '&' + ACCOUNT_OWNER_FIELD_ID + '_lkid=' + acc.OwnerId;
            }
            if (acc.Sales_Division__c != null) {
                urlAppend += '&' + SALES_DIVISION_FIELD_ID + '=' + EncodingUtil.urlEncode(acc.Sales_Division__c, 'UTF-8');
            }
            if (acc.Customer_Success_Manager__r != null) {
                urlAppend += '&' + CUSTOMER_SUCCESS_MANAGER_FIELD_ID + '=' + EncodingUtil.urlEncode(acc.Customer_Success_Manager__r.Name, 'UTF-8');
            }
            if (curRisk.Post_Churn_Solution_Sub_Reason__c != null) {
                urlAppend += '&' + PRIMARY_COMPETITOR_FIELD_ID + '=' + EncodingUtil.urlEncode(curRisk.Post_Churn_Solution_Sub_Reason__c, 'UTF-8');
            }
        }
        return urlAppend;
        
    }

}