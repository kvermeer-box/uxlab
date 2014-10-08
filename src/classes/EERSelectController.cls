public class EERSelectController {

    private static final String ACCOUNT_ID_PARAMETER_IDENTIFIER = 'accountId';
    private static final String OPPORTUNITY_ID_PARAMETER_IDENTIFIER = 'opportunityId';
    private static final String RISK_ID_PARAMETER_IDENTIFIER = 'riskId';
    private Opportunity opp = null;
    private Account acct = null;
    private Risk__c risk = null;


    private static final String LOOKUP_FIELD_PREFIX = 'CF';
    private static final String LOOKUP_FIELD_ID_ADDENDUM = '_lkid';
    private static final String OPPORTUNITY_FIELD_ID = '00N60000002uF8A';
    private static final String ACCOUNT_FIELD_ID = '00N60000002uF7L';
    private static final String RISK_FIELD_ID = '00N60000002uF8M';
    
    public EERSelectController() {
        String oppId = ApexPages.currentPage().getParameters().get(OPPORTUNITY_ID_PARAMETER_IDENTIFIER);
        String accountId = ApexPages.currentPage().getParameters().get(ACCOUNT_ID_PARAMETER_IDENTIFIER);
        String riskId = ApexPages.currentPage().getParameters().get(RISK_ID_PARAMETER_IDENTIFIER);
        // Query for object
        try {
            if (oppId != null) {
                opp = [SELECT Id, Name
                         FROM Opportunity
                        WHERE Id = :oppId];
            } 
            if (accountId != null) {
                acct = [SELECT Id, Name
                          FROM Account
                         WHERE Id = :accountId];
            }
            if (riskId != null) {
                risk = [SELECT Id, Name
                          FROM Risk__c
                         WHERE Id = :riskId];
            }
        }
        catch (Exception e) {
            System.debug('Issue querying for object! Exception: ' + e);
            new LoggedException(e,'Issue querying for object','EERSelectController');
        }
    }

    public String autoPopulateParameters {
        get {
            String queryParameters = '';
            if (opp != null) {
                queryParameters += '&' + LOOKUP_FIELD_PREFIX + OPPORTUNITY_FIELD_ID + '=' + opp.Name;
                queryParameters += '&' + LOOKUP_FIELD_PREFIX + OPPORTUNITY_FIELD_ID + LOOKUP_FIELD_ID_ADDENDUM + '=' + opp.Id;
            }
            if (acct != null) {
                String name = acct.Name;
                String id = acct.Id;
                queryParameters += '&' + LOOKUP_FIELD_PREFIX + ACCOUNT_FIELD_ID + '=' + name;
                queryParameters += '&' + LOOKUP_FIELD_PREFIX + ACCOUNT_FIELD_ID + LOOKUP_FIELD_ID_ADDENDUM + '=' + id;
            }
            if (risk != null) {
                String name = risk.Name;
                String id = risk.Id;
                queryParameters += '&' + LOOKUP_FIELD_PREFIX + RISK_FIELD_ID + '=' + name;
                queryParameters += '&' + LOOKUP_FIELD_PREFIX + RISK_FIELD_ID + LOOKUP_FIELD_ID_ADDENDUM + '=' + id;
            }
            return queryParameters;
        }
        set;
    }
}