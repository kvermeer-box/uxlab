public class BoxOutV2Controller {

    // URL Hacking
    // TODO: NOT able to fetch field IDs dynamically yet (Describe API doesn't support), when that is available, should update this!
    private static final String OPPORTUNITY_FIELD_ID = 'CF00N60000002u9AV'; // DONE
    private static final String OPPORTUNITY_OWNER_FIELD_ID = 'CF00N60000002u9AS';
    private static final String ACCOUNT_FIELD_ID = 'CF00N60000002u9AF';
    private static final String ACCOUNT_OWNER_FIELD_ID = 'CF00N60000002u9AE';
    private static final String BOX_RESELLER_ACCOUNT_FIELD_ID = 'CF00N60000002u9AH';
    //private static final String SALES_DIVISION_FIELD_ID = '00N11000000QPcM';
    private static final String COMPETITION_DETAILS_FIELD_ID = '00N60000002u9AI';
    private static final String SALES_ENGINEER_FIELD_ID = 'CF00N60000002u9AZ';
    private static final String BOX_EXECUTIVE_SPONSOR_FIELD_ID = '00N60000002u9AG';
    private static final String CUSTOMER_SUCCESS_MANAGER_FIELD_ID = 'CF00N60000002u9AM';
    //private static final String PRIMARY_COMPETITORY_FIELD_ID = '00N60000002M4xZ';

    @RemoteAction
    public static String submitRequest(String oppId) {
        if (oppId == null || oppId == '') {
            return createJSONResponse(null,false,'No opp was selected!');
        }
        Opportunity opp = getOpp(oppId);
        if (opp == null) {
            // Return error JSON
            return createJSONResponse(null,false,'There was trouble finding the opp!');
        } else {
            String urlParameters = getURLParameters(opp);
            if (urlParameters == null) {
                // Return error JSON
                return createJSONResponse(urlParameters,false,'There was trouble fetching data from opp!');
            }
            // Return success JSON
            return createJSONResponse(urlParameters,true,null);
        }
    }

    private static Opportunity getOpp(String oppId) {
        try {
            Opportunity opp = [SELECT Name, Sales_Division__c, Competitor_We_Lost_To__c, StageName, Amount, CurrencyIsoCode, 
                                      Owner.Name, OwnerId, AccountId, Account.Name, Account.Owner.Name, Account.OwnerId, 
                                      Competition_Details__c, Sales_Engineer_Lookup__r.Name, Sales_Engineer_Lookup__c, 
                                      Executive_Sponsor__c, Account.Customer_Success_Manager__r.Name, Box_Partner_Account__r.Name, 
                                      Box_Partner_Account__c, Renewal_Amount__c, Account.Executive_Sponsor__c
                                 FROM Opportunity
                                WHERE Id = :oppId];
            return opp;
        } catch (Exception e) {
            new LoggedException(e,'Trouble Querying opp','BoxOutV2Controller', new List<Id> { oppId });
            System.debug('Exception: ' + e);
            return null;
        }
    }

    private static String getURLParameters(Opportunity opp) {
        if (opp == null) {
            System.debug('Null opp passed in!');
            return null;
        }
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
        /*
        if (opp.Sales_Division__c != null) {
            urlAppend += '&' + SALES_DIVISION_FIELD_ID + '=' + EncodingUtil.urlEncode(opp.Sales_Division__c, 'UTF-8');
        }
        */
        if (opp.Competition_Details__c != null) {
            urlAppend += '&' + COMPETITION_DETAILS_FIELD_ID + '=' + EncodingUtil.urlEncode(opp.Competition_Details__c, 'UTF-8');
        }
        if (opp.Sales_Engineer_Lookup__r != null) {
            urlAppend += '&' + SALES_ENGINEER_FIELD_ID + '=' + EncodingUtil.urlEncode(opp.Sales_Engineer_Lookup__r.Name, 'UTF-8') + '&' + SALES_ENGINEER_FIELD_ID + '=' + EncodingUtil.urlEncode(opp.Sales_Engineer_Lookup__c, 'UTF-8');
        }
       
        if (opp.Account.Executive_Sponsor__c != null) {
            urlAppend += '&' + BOX_EXECUTIVE_SPONSOR_FIELD_ID + '=' + EncodingUtil.urlEncode(opp.Account.Executive_Sponsor__c, 'UTF-8');
        }
        
        if (opp.Account.Customer_Success_Manager__r != null) {
            urlAppend += '&' + CUSTOMER_SUCCESS_MANAGER_FIELD_ID + '=' + EncodingUtil.urlEncode(opp.Account.Customer_Success_Manager__r.Name, 'UTF-8');
        }
        /*
        if (opp.Competitor_We_Lost_To__c != null) {
            urlAppend += '&' + PRIMARY_COMPETITORY_FIELD_ID + '=' + EncodingUtil.urlEncode(opp.Competitor_We_Lost_To__c, 'UTF-8');
        }
        */
        return urlAppend;
    }

    private static String createJSONResponse(String urlParameters, Boolean success, String errorText) {
        String jsonString = '{ "success" : ' + success;
        if (success) {
            jsonString += ', "url" : "/a1n/e?' + urlParameters + '"';
        } else {
            jsonString += ', "error" : "' + errorText + '"';
        }
        jsonString += ' }';
        return jsonString;
    }
}