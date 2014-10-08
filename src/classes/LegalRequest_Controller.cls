/**
 * Controller for LegalRequest page
 *
 * @author Kyle Vermeer 6/11/14
 */
public class LegalRequest_Controller {
	
    public String oppId;
    public String accountId;
    public String oppName;
    public String accountName;

    @TestVisible
    public static final String OPP_PARAMETER_NAME = 'oppId';
    @TestVisible
    public static final String ACC_PARAMETER_NAME = 'accId';

    public static final String OPPORTUNITY_FIELD_ID = '00N60000002Jhqy';
    public static final String ACCOUNT_FIELD_ID = '00N60000002Jwvo';

    public LegalRequest_Controller() {
		initialize();
	}

    public void initialize() {
        this.oppId = ApexPages.currentPage().getParameters().get(OPP_PARAMETER_NAME);
        this.accountId = ApexPages.currentPage().getParameters().get(ACC_PARAMETER_NAME);

        try {
            Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Id = :this.oppId];
            this.oppName = opp.Name;
        }
        catch (Exception e) {
            // Ignore it
        }
        try {
            Account acc = [SELECT Id, Name FROM Account WHERE Id = :this.accountId];
            this.accountName = acc.Name;
        }
        catch (Exception e) {
            // Ignore it
        }
    }

    public String urlParameters {
        get {
            String parameters = '';
            if (this.oppId != null && this.oppName != null) {
                parameters += '&CF' + OPPORTUNITY_FIELD_ID + '=' + this.oppName;            
                parameters += '&CF' + OPPORTUNITY_FIELD_ID + '_lkid' + '=' + this.oppId;
            }
            if (this.accountId != null && this.accountName != null) {
                parameters += '&CF' + ACCOUNT_FIELD_ID + '=' + this.accountName;            
                parameters += '&CF' + ACCOUNT_FIELD_ID + '_lkid' + '=' + this.accountId;
            }
            return parameters;
        }
        set;
    }
}