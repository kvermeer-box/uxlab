public class PrepareNewQuoteController{

    private Zuora.zApi api = new Zuora.zApi();
    private final Opportunity opp;
    private final String CRMId;
    private final Map <String,List<SelectOption>> cachedSubOptions = new Map <String,List<SelectOption>>();

    public Boolean initFailed                          {get; private set;}
 
    public String  selectedAccountType                 {get;set;}
    public String  selectedAccount                     {get;set;}
    public String  selectedSubscription                {get;set;}
    public String  selectedSubscriptionType            {get;set;}
    public String  selectedAmendmentType               {get;set;}
    public List<SelectOption> billingAccountList       {get;set;}
    public List<SelectOption> subscriptionList         {get;set;}

    public PrepareNewQuoteController(ApexPages.StandardController controller) {

        this.initFailed = true;

        final String oppId = controller.getId();
        
        if (null == oppId || '' == oppId) {
            appendErrorMessage('Need to specify the id of opportunity to create a quote.');
            return;
        }

        final List<Opportunity> oppList = [SELECT Id, Account.Id FROM Opportunity WHERE Id = :oppId limit 1];

        if (oppList.size() != 1) {
            appendErrorMessage('Invalid opportunity specified to create a quote.');
            return;
        }

        this.opp = oppList[0];
        this.CRMId = this.opp.Account.Id;

        try {
            Zuora.zApi.LoginResult lr = Test.isRunningTest() ? new Zuora.zApi.LoginResult() : api.zlogin();

        } catch (Zuora.zAPIException e) {
            appendErrorMessage(e.getMessage());
            return;
        }
        this.initFailed = false;

    }

	// this is called by PrepareNewQuote page
	// button  = New Box Quote  
    public PageReference onload() {
        try {
 
            this.loadBillingAccountList();

        } catch (Zuora.zAPIException e) {
            appendErrorMessage(e.getMessage());
            return null;
        }

        return null;
    }

 
    
    public PageReference onSelectAccount() {

        try {


            this.loadSubscriptionList();

            /* Box: Default select subscription */
            this.selectedSubscriptionType = 'existing';
            this.selectDefaultSubscription();


        } catch (Zuora.zAPIException e) {
            appendErrorMessage(e.getMessage());
            return null;
        }

        return null;
    }


    public PageReference cancel() {

        PageReference oppPage = new ApexPages.StandardController(this.opp).view();
        oppPage.setRedirect(true);
        return oppPage;
    }

    public PageReference goNewQuote() {

		if(selectedAccountType==null || selectedAccountType==''){
			appendErrorMessage('Please select the type of sale.');
            return null;
		}
 

        if(selectedAccountType=='existing'){
            if(this.selectedAccount == null || this.selectedAccount == ''){ 
                appendErrorMessage('Please select an existing Box Enterprise ID.');
                return null;
            }
        }


     	PageReference  newQuotePage = Page.NewQuote;
            
        String quoteType = 'New';
            
        if ('amend' == selectedAmendmentType ) {
                quoteType = 'Amend';
        } else if ('renew' == selectedAmendmentType) {
                quoteType = 'Renew';
        }

        newQuotePage.getParameters().put('quoteType', quoteType);
        
        if(quoteType!='New'){
	        newQuotePage.getParameters().put('billingaccountid', this.selectedAccount);
	        newQuotePage.getParameters().put('existsubscriptionid', this.selectedSubscription);
        }
        newQuotePage.getParameters().put('oppid', String.valueOf(this.opp.Id).substring(0,15));
        newQuotePage.setRedirect(true);

        return newQuotePage;
    }



    public PageReference onSelectAccountType() {

        if ('new' == this.selectedAccountType) {
        
            this.selectedSubscriptionType = 'new';
        
        } else {
        
            try {
        
                this.loadBillingAccountList();
        
            } catch (Zuora.zAPIException e) {
                appendErrorMessage(e.getMessage());
                return null;
            }

            this.selectDefaultAccount();
        }
        return null;
    }


    private void selectDefaultAccount() {
        if (this.billingAccountList != null && this.billingAccountList.size() > 0) {
            this.selectedAccount = this.billingAccountList[0].getValue();
        }

        this.onSelectAccount();
    }


    public PageReference onSelectSubscriptionType() {
        if ('existing' == this.selectedSubscriptionType) {
            try {
                this.loadSubscriptionList();
            } catch (Zuora.zAPIException e) {
                appendErrorMessage(e.getMessage());
                return null;
            }
        this.selectDefaultSubscription();        }
        return null;
    }
    private void selectDefaultSubscription() {
        if (this.subscriptionList.size() > 0) {

            this.selectedAmendmentType = 'amend';
            this.selectedSubscription = this.subscriptionList[0].getValue();
        }
    }

    private void loadBillingAccountList() {
        if (this.CRMId == null){
	 		return;
        }

        //already queried from Zuora, no need to query again
        if (this.billingAccountList != null){
            return;
        }else{

            //query from Zuora and build the billing account picklist
            this.billingAccountList = new List<SelectOption> ();

            String acczoql = 'SELECT AccountNumber, Name, EnterpriseID__c, Currency FROM Account WHERE Status = \'Active\' AND CrmId LIKE \''
                                + this.CRMId.substring(0, 15) + '%\'';

            List <Zuora.zObject> acclist;

            if(Test.isRunningTest()){

                accList=getTestingBillingAccountList();

            }else{

                try {
                    acclist = api.zquery(acczoql);
                } catch (Zuora.zAPIException e) {
                        throw e;
                }

            }

            for(Zuora.zObject acc: acclist) {

                String accvalue = (String)acc.getValue('Id');
                String enterpriseId = (String)acc.getValue('EnterpriseID__c');

                if (enterpriseId==null || enterpriseId=='null'){
                    enterpriseId=' ';

                }

                String currencyCode = (String)acc.getValue('Currency');

                if (currencyCode==null || currencyCode=='null'){
                    currencyCode=' ';

                }

                String acclabel = acc.getValue('Name')
                                    // +  ', Acct#:' + acc.getValue('AccountNumber')
                                    +  ' (Currency: ' + currencyCode + ', ' + 'Enterprise ID: ' + enterpriseId + ')';

                SelectOption accso = new SelectOption (accvalue, acclabel);
                this.billingAccountList.add(accso);
             }
        }
    }


    //query the subscription from zuora and build the picklist
    private void loadSubscriptionList() {

        this.subscriptionList = new  List<SelectOption>();

        if(this.selectedAccount == null){ 
            return;
        }

        List<SelectOption> suboptionlist = this.cachedSubOptions.get(this.selectedAccount);

            if (suboptionlist != null)
                this.subscriptionList = suboptionlist;
            else{

                suboptionlist = new List<SelectOption> ();

                String subzoql = 'SELECT Id, Name, ContractEffectiveDate, TermType, Status FROM Subscription WHERE TermType=  \'TERMED\' AND Status = \'Active\' AND AccountId = \''
                                    + this.selectedAccount + '\'';

                List<Zuora.zObject> subscriptionList;

                if(Test.isRunningTest()){ 

                        subscriptionList=getTestingSubscriptionList();

                }else{ 
                    try {
                        subscriptionList = api.zquery(subzoql);
                    } catch (Zuora.zAPIException e) {
                        throw e;
                    }
                }

                for(Zuora.zObject sub : subscriptionList) {

                    String subvalue = (String)sub.getValue('Id');
                    DateTime cedatetime = (DateTime)sub.getValue('ContractEffectiveDate');
                    String sublabel = (String)sub.getValue('Name')
                                        +  ', Status: ' + (String)sub.getValue('Status')
                                        +  ', Contract Effective Date: ' +  cedatetime.date().format();

                    SelectOption subso = new SelectOption (subvalue,sublabel);
                    suboptionlist.add(subso);
                }

                if (suboptionlist.size() > 0){
                    this.cachedSubOptions.put(this.selectedAccount, suboptionlist);
                    this.subscriptionList = suboptionlist;
                }
        }

    }


    static private void appendErrorMessage(String message) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
    }


    //////////////////
    // Test methods
    //////////////////
    private static List<Zuora.ZObject> getTestingBillingAccountList() {

        List<Zuora.ZObject> billingAccountList = new List<Zuora.ZObject>();

        Zuora.zObject billingAccount = new Zuora.zObject('Account');
        billingAccount.setValue('Id','111111');
        billingAccount.setValue('Name','Boeing');
        billingAccount.setValue('EnterpriseID__c','aaaaaa');
        billingAccount.setValue('Currency','USD');
        billingAccount.setValue('PaymentTerm','Monthly');

        billingAccountList.add(billingAccount);

        return billingAccountList;
    }

    private static List<Zuora.ZObject> getTestingSubscriptionList() {
        
        List<Zuora.ZObject> subscriptionList = new List<Zuora.ZObject>();

        Zuora.ZObject sub = new Zuora.ZObject('Subscription');
        sub.setValue('ContractEffectiveDate', DateTime.newInstanceGmt(2014, 7, 2));
        sub.setValue('TermStartDate', DateTime.newInstanceGmt(2014, 7, 2));
        sub.setValue('TermEndDate', DateTime.newInstanceGmt(2015, 7, 2));
        sub.setValue('Name', 'Boeing Subcription');
        sub.setValue('Version', 3);
        sub.setValue('InitialTerm', 2);
        sub.setValue('RenewalTerm', 2);
        sub.setValue('Id', '222222');
        sub.setValue('Status', 'Active');
        subscriptionList.add(sub);

        return subscriptionList;
    }


}