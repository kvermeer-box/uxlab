/**
* Class: NewQuoteController
*
*/
public class NewQuoteController {

 	public static String SUBSCRIPTION_TYPE_NEW_SUBSCRIPTION 	= 'New Subscription';
 	public static String SUBSCRIPTION_TYPE_RENEW_SUBSCRIPTION 	= 'Renew Subscription';
 	public static String SUBSCRIPTION_TYPE_AMEND_SUBSCRIPTION 	= 'Amend Subscription';

    public final zqu__Quote__c quote          {get;set;}
    public final Opportunity   opp            {get;set;}
    public final List<Contact> contacts       {get;set;}  //contacts for selection
    public final  String  billingAccountID    {get; set;}
    public final  String  existSubscriptionID {get; set;}
    public final  String  quoteType           {get; set;}
    public Boolean initFailed                 {get; private set;}
  
    
    private final ApexPages.StandardController controller;
    private final Zuora.zApi api = new Zuora.zApi();

    public final Zuora__CustomerAccount__c billingAccount	{get; set;}
	public final Zuora__Subscription__c subscription		{get; set;}
	public String existingPaymentFrequency					{get; set;}
	public String existingContractTerm						{get; set;}

    public Boolean isELA {
        get;
        set;
    }


    public NewQuoteController(ApexPages.StandardController stdcontroller) {

        this.initFailed = true;
        this.controller = stdcontroller;
        //get values parsed in zuora billingaccountId, subscriptionid, quotetype
        //initialize and initial some value for your new quote page here
        this.quote = (zqu__Quote__c)stdcontroller.getRecord();
        
        if (null != quote.id) {
            throw new zqu.ZQException('Should Not specify id in the url.');
        }

        this.quoteType = this.getParameter('quotetype');
        if ('' == this.quoteType) {
            throw new zqu.ZQException('Need to specify the quotetype in the url.');
        }

        final String oppId = this.getParameter('oppid');
        if ('' == oppId) {
            throw new zqu.ZQException('Need to specify the oppid in the url.');
        }

 
        
        final List<Opportunity> oppIdList = [select Account.BillingCountry, Account.BillingPostalCode, Account.BillingState,
                                                    Account.BillingCity, Account.BillingStreet, Account.Id,
                                                    AccountId, Account.Name, Name, CurrencyIsoCode
                                                from Opportunity
                                                    where Id =:oppId limit 1];
        if (oppIdList.size() != 1) {
            throw new zqu.ZQException('Invalid oppid.');
        }
        this.opp = oppIdList[0];

        this.quote.zqu__Opportunity__r = this.opp;
        this.quote.zqu__Opportunity__c = this.opp.Id;
        //this.quote.Name = 'Sample Quote Name';
        this.quote.Name = this.opp.Name;


        /* Box */
        this.billingAccountID = this.getParameter('billingaccountid');
        this.existSubscriptionID = this.getParameter('existsubscriptionid');

        if ('' != billingAccountId) {
            billingAccount = getCustomerBillingAccount(this.billingAccountId);
        }
		if ('' != existSubscriptionId) {
			subscription = getZuoraSubscription(existSubscriptionId);			
		}
        
        

        if ('Amend' == this.quoteType || 'Renew' == this.quoteType) {
        	
            //Box: initialized above
            //this.billingAccountID = this.getParameter('billingaccountid');
            if ('' != billingAccountId) {
                this.quote.zqu__ZuoraAccountId__c = this.billingAccountId;
            } else {
                throw new zqu.ZQException('Need to specify the billingaccountid for ' + this.quoteType + ' in the url.');
            }

            //this.existSubscriptionID = this.getParameter('existsubscriptionid');
            if ('' != existSubscriptionId) {
                this.quote.zqu__existSubscriptionID__c = existSubscriptionId;
            } else {
                throw new zqu.ZQException('Need to specify the existsubscriptionid for ' + this.quoteType + ' in the url.');
            }

            try {
                
                if (!Test.isRunningTest()) {
                    api.zlogin();
                }
                Zuora.zObject acczobj = this.getBillingAccount(billingAccountID);
                
                System.debug('>>>>>>>>>Zuora Billing Account='+acczobj);
                
	            if (acczobj != null) {
	            	this.quote.zqu__Currency__c = (String)acczobj.getValue('Currency');
	            	this.quote.CurrencyIsoCode = (String)acczobj.getValue('Currency');
	                this.quote.zqu__PaymentTerm__c = (String)acczobj.getValue('PaymentTerm');
	                System.debug('>>>>>>>PaymentTerm='+(String)acczobj.getValue('PaymentTerm'));
                }
                
				final Zuora.zObject subzobj = this.getSubscription(existSubscriptionId);
				
	            System.debug('>>>>>>>>>Zuora Subscription='+subzobj);        
	            
                if (null != subzobj) {
                        
                        if ('Amend' == this.quoteType) {
               				this.quote.zqu__StartDate__c = ((Datetime)subzobj.getValue('TermStartDate')).date();
                        } else {
                        	// 'Renew'
                           this.quote.zqu__StartDate__c = ((Datetime)subzobj.getValue('TermEndDate')).date();
                        }

                        this.quote.zqu__Hidden_Subscription_Name__c = (String)subzobj.getValue('Name');
                        this.quote.zqu__SubscriptionVersion__c = (Integer)subzobj.getValue('Version');
                        this.quote.zqu__SubscriptionTermStartDate__c = ((Datetime)subzobj.getValue('TermStartDate')).date();
                        this.quote.zqu__SubscriptionTermEndDate__c = ((Datetime)subzobj.getValue('TermEndDate')).date();

				 		// calculate # of months in the existing subscription term
				 		
				 		if(this.quote.zqu__SubscriptionTermStartDate__c != null 
				 				&& this.quote.zqu__SubscriptionTermEndDate__c != null){
				 			
				 			this.quote.Subscription_Term__c = this.quote.zqu__SubscriptionTermStartDate__c.monthsBetween(this.quote.zqu__SubscriptionTermEndDate__c);
				 			
				 		}


                        /* Box */
	                    this.quote.zqu__InitialTerm__c = (Integer)subzobj.getValue('InitialTerm');
	                    this.quote.zqu__RenewalTerm__c = (Integer)subzobj.getValue('RenewalTerm');

                        this.quote.Contract_Term__c = String.valueOf(this.quote.zqu__InitialTerm__c);
                        this.quote.Renewal_Term__c  = String.valueOf(this.quote.zqu__RenewalTerm__c);

 
	                        
	                    this.existingContractTerm = this.quote.Contract_Term__c;

	            }
            } catch(Exception e) {
                if (Test.isRunningTest()) { // Test, just log
                    System.debug('EXCEPTION: ' + e);
                }
                else { // Not test, throw exception
                    throw new zqu.ZQException(e.getMessage());
                }
            }
        }

        //must assign correct subscription type and record type base on quote type here
        Schema.DescribeSObjectResult dsr = Schema.SObjectType.zqu__Quote__c;
        if('New' == this.quoteType){
                this.quote.zqu__SubscriptionType__c = 'New Subscription';
            Schema.RecordTypeInfo defaultrtinfo = dsr.getRecordTypeInfosByName().get('Default');
            this.quote.RecordtypeId = defaultrtinfo.getRecordTypeId();
        }else if('Amend' == this.quoteType){
                this.quote.zqu__SubscriptionType__c = 'Amend Subscription';
                Schema.RecordTypeInfo amdrtinfo = dsr.getRecordTypeInfosByName().get('Amendment');
                this.quote.RecordtypeId = amdrtinfo.getRecordTypeId();
                this.quote.zqu__Amendment_Name__c =  this.opp.Name;
        }else if('Renew' == this.quoteType){
                this.quote.zqu__SubscriptionType__c = 'Renew Subscription';
            Schema.RecordTypeInfo renewrtinfo = dsr.getRecordTypeInfosByName().get('Renewal');
            this.quote.RecordtypeId = renewrtinfo.getRecordTypeId();
            this.quote.zqu__Amendment_Name__c =  this.opp.Name;
        }
        //get the list of contact that under the opportunity account for selection
        this.contacts = [SELECT Id, FirstName, LastName, Email, Phone, Title, Name FROM Contact WHERE AccountId = :opp.Account.Id];

        //Box init values
        initQuote();

        this.initFailed = false;
    }

    /* Box: init quote fields */
    public void initQuote(){

        //default deal type to Standard

        if (this.quote.Deal_Type__c == null) {
           this.quote.Deal_Type__c = 'Standard'; 
        }
        
        // default start date  
		if('New' == this.quoteType || 'Amend' == this.quoteType){
        	this.quote.zqu__StartDate__c = System.today();
		}
		
		// hide discount on amend subscription quotes
    	if('Amend' == this.quoteType){
		            		
		 	this.quote.Hide_Discounts_from_Quote_PDF__c = true;           		
		}

        // default quote expiration date to last date of month
        Integer numberDays = date.daysInMonth(System.today().year(), System.today().month());
        this.quote.zqu__ValidUntil__c = date.newinstance(System.today().year(), System.today().month(), numberDays);

        // set currency from billing account or opp
        if(this.quote.zqu__Currency__c!=null){
 
			this.quote.CurrencyIsoCode = this.quote.zqu__Currency__c;
        
        }else{
         
			this.quote.zqu__Currency__c = this.opp.CurrencyIsoCode;
			this.quote.CurrencyIsoCode = this.opp.CurrencyIsoCode;
        }

        // default subscription term type
        this.quote.zqu__Subscription_Term_Type__c = 'Termed';

        //default auto-renewal to True
        this.quote.zqu__AutoRenew__c = true;

        if(billingAccount != null){

			this.quote.zqu__PaymentMethod__c    = translatePaymentMethod(this.billingAccount.Zuora__DefaultPaymentMethod__c);

            this.quote.zqu__PaymentTerm__c      = this.billingAccount.Zuora__PaymentTerm__c;

			//default bill to and sold to
			this.quote.zqu__BillToContact__c = getContactId(billingAccount.Zuora__BillToName__c);
			this.quote.zqu__SoldToContact__c = getContactId(billingAccount.Zuora__SoldToName__c);

        } 

		if(subscription!=null){
			
			this.quote.Payment_Frequency__c = translateBillingPeriod(getBillingPeriod(subscription));
 			this.existingPaymentFrequency	= this.quote.Payment_Frequency__c;
		}
		
 
	        	
		if(this.quote.zqu__SubscriptionType__c == SUBSCRIPTION_TYPE_AMEND_SUBSCRIPTION
			&& this.quote.Subscription_Term__c > 0){
		
			//this.quote.Contract_Term_Calculation__c = this.quote.Subscription_Term__c;	
	        this.quote.zqu__InitialTerm__c = this.quote.Subscription_Term__c;
 			this.quote.Contract_Term__c = String.valueOf(this.quote.zqu__InitialTerm__c);
	                    	
		}else if(this.quote.zqu__SubscriptionType__c == SUBSCRIPTION_TYPE_RENEW_SUBSCRIPTION
			&& this.quote.zqu__RenewalTerm__c >0){
			
			//this.quote.Contract_Term_Calculation__c = this.quote.zqu__RenewalTerm__c;
			this.quote.zqu__InitialTerm__c = this.quote.zqu__RenewalTerm__c;
 			this.quote.Contract_Term__c = String.valueOf(this.quote.zqu__InitialTerm__c);
		}
	  
	

    }

    /* Box: validate quote */
    private void validateQuote(){
    
		validateContacts(); 
		
		/* On existing EID, reps should not able to select 'Short Term' as deal type */
        if('New' != this.quoteType && this.quote.Deal_Type__c == 'Short Term'){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.Z_INVALID_SHORT_TERM_DEAL));	
		}
 
		// determine whether contract term or payment frequency has changed
		
		if(this.quote.Change_Payment_Frequency__c){
			
			if (this.existingPaymentFrequency == this.quote.Payment_Frequency__c){
							
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'If you selected Change Payment Frequency, you must change payment frequency!'));		 
			}
		}
		
		if(this.quote.Change_Contract_Term__c){
			
	 		if(this.existingContractTerm == this.quote.Contract_Term__c){
	 			
	 			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'If you selected Change Contract Term, you must change contract term!'));
	 		}	 		 
 		}
	 		  
		if(this.quote.deal_type__c=='ELA' && this.quote.Enterprise_wide_Deployment__c==false){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'If you selected ELA, you must select Enterprise-wide Deployment!'));
		}
    }
    
    private void validateContacts(){
    
    	boolean valid=true;
    	
    	Id billToAccountId;
    	Id soldToAccountId;
    	
    	for(Contact c : [select id, accountid 
    							from contact 
    								where id=: this.quote.zqu__BillToContact__c 
    										or id=: this.quote.zqu__SoldToContact__c]){
    											
    											
    		if(c.Id == this.quote.zqu__BillToContact__c){
    			billToAccountId=c.accountId;	
    		}
    		if(c.Id == this.quote.zqu__SoldToContact__c){
    			soldToAccountId=c.accountId;	
    		}
    		
    											
		}//end-for

		if(billToAccountId!=opp.AccountId){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Z_INVALID_BILL_TO_CONTACT_ACCOUNT));	
		}
		if(soldToAccountId!=opp.AccountId){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Z_INVALID_SOLD_TO_CONTACT_ACCOUNT));		
		}
    	
    	return;	
    	
    	
    }

    /* Box: update quote fields */
    public void updateQuote(){

        // Make renewal term same as initial term
        this.quote.Renewal_Term__c = this.quote.Contract_Term__c;

        if(this.quote.Contract_Term__c != null ){
            this.quote.zqu__InitialTerm__c = Integer.valueOf(this.quote.Contract_Term__c);
        }


		// update renewal term
		if(this.quote.zqu__InitialTerm__c==36 && this.quote.payment_frequency__c == 'Three Years'){
        
        	this.quote.zqu__RenewalTerm__c	= 36;
            this.quote.Renewal_Term__c		= '36'; 
		
		}else if(this.quote.zqu__InitialTerm__c==24 && this.quote.payment_frequency__c == 'Two Years'){
            
            this.quote.zqu__RenewalTerm__c	= 24;
            this.quote.Renewal_Term__c		= '24'; 
            
    	}else{

            this.quote.zqu__RenewalTerm__c	= 12;
            this.quote.Renewal_Term__c		= '12'; 
        }
        
        // get subscription info
        
        if(this.quote.zqu__ExistSubscriptionID__c!=null){
 	        
	        Z_QuoteSubscription quoteSubscription= new Z_QuoteSubscription(this.quote.zqu__ExistSubscriptionID__c);
	        
	        this.quote.Subscription_Quantity__c 		= quoteSubscription.getQuantity();
	        this.quote.Subscription_ARR__c 				= quoteSubscription.getARR();
	        this.quote.Subscription_Extended_Amount__c 	= quoteSubscription.getExtendedAmount();
	        this.quote.Subscription_Billing_Period__c 	= quoteSubscription.getBillingPeriod();        
        }
        
 
    }

    public PageReference cancel() {
    
    	PageReference oppPage = new ApexPages.StandardController(this.opp).view();
        oppPage.setRedirect(true);
        return oppPage;
    }


    public PageReference save(){
 
        // Box: update quote fields prior to save
        updateQuote();


        validateQuote();

		
		if(apexpages.hasMessages()){
			return null;
		}		
    	
    	

        if('Renew' == this.quoteType){

            try{
                zqu.zQuoteUtil.renewQuote(this.quote);
            } catch(zqu.ZQException e){
                appendErrorMessage(e.getMessage());
                return null;
            }   
        }

        final System.Savepoint quoteSavePoint = Database.setSavepoint();

        try {
        	
            if(this.quote.Change_License_Product__c 
            	|| this.quote.Change_Payment_Frequency__c
            	|| this.quote.Change_Contract_Term__c
            	|| this.quote.Add_Premier_Support_Cloud_Connect__c
            	|| this.quoteType == 'Renew'){
 
                this.quote.processing__c = true;
 
            }
        	
            Database.upsert(this.quote);


            if(this.quote.Change_License_Product__c 
            	|| this.quote.Change_Payment_Frequency__c
            	|| this.quote.Change_Contract_Term__c
            	|| this.quote.Add_Premier_Support_Cloud_Connect__c){
 
 
				Z_SubscriptionUtility.clearSubscription(this.quote.Id);
 

            }else if('Renew' == this.quoteType){
 
            		Z_ChargeGroupUtility.processRenewalSubscription(this.quote.Id);
	 
            }

            final PageReference quoteDetailPage = new ApexPages.Standardcontroller(this.quote).view();
            quoteDetailPage.setRedirect(true);
            return quoteDetailPage;

        } catch (DMLException e) {
            Database.rollback(quoteSavePoint);
            appendErrorMessage(e.getMessage());
            return null;
        }

    }

    private Id getContactId(String name){

        Id foundContactId;

		if(this.contacts!=null && name!=null){
			
			for(Contact c:contacts){
			
				if(c.name == name){
					foundContactId = c.Id;	
				}
			}//end-for
			
		}//end-if

        return foundContactId;

    }

    private String getParameter(String paraname){
        if(ApexPages.currentPage().getParameters().get(paraname) != null){
                return String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get(paraname));
        }else{
                return '';
        }
    }

    public Zuora.zObject getSubscription(String subscriptionId){
        final Zuora.zObject subzobj;
        if (Test.isRunningTest()) { // Running a test, spoof the sub
            subzobj = getTestingSubscription();
        }
        else { // Not running a test, do normal stuff
            final String zoqlsubscription = 'Select Id, Name, Version, AccountId, OriginalId,ContractEffectiveDate,TermStartDate,TermEndDate,RenewalTerm,InitialTerm,TermType from Subscription where Id = \'' + subscriptionId + '\'';
            final List <Zuora.zObject> subzobjs = api.zquery(zoqlsubscription);
            if(subzobjs.size() == 1)
                subzobj = subzobjs[0];
        }
        return subzobj;
    }

    public Zuora.zObject getBillingAccount(String billingaccountId){
        final Zuora.zObject acczobj;
        if (Test.isRunningTest()) { // Running a test, spoof the billing account
            acczobj = getTestingBillingAccount();
        } 
        else { // Not running a test, do normal stuff
            final String zoqlacc = 'SELECT BillToId,SoldToId,Currency,DefaultPaymentMethodId,PaymentTerm from Account where Id=\'' + billingaccountId  + '\'';
            final List <Zuora.zObject> acczobjs = api.zquery(zoqlacc);
            if(acczobjs.size() == 1){
                acczobj = acczobjs[0];
            } 
        }
       
        return acczobj;
    }

    public String translateBillingPeriod(String billingPeriod){
    	
    	String paymentFrequency=billingPeriod;
    	
    	if (billingPeriod==null){
    		return paymentFrequency;
    	}
    	
		Billing_Period_Mapping__c billingPeriodMappings = Billing_Period_Mapping__c.getInstance(billingPeriod);
		
		if(billingPeriodMappings!=null){
			paymentFrequency=billingPeriodMappings.Payment_Frequency__c;	
		}
		
		return paymentFrequency;
    	
    }	


    public String getBillingPeriod(Zuora__Subscription__c zSubscription){
    	
    	String billingPeriod;
    	
    	if (zSubscription==null || zSubscription.Zuora__Subscription_Product_Charges__r==null){
    		return null;
    	}
    	
    	for(Zuora__SubscriptionProductCharge__c spc : zSubscription.Zuora__Subscription_Product_Charges__r){
    	
    		if(spc.Zuora__BillingPeriod__c!=null){
    			billingPeriod=spc.Zuora__BillingPeriod__c;
    			break;	
    		}
    		
    	}	
    	
    	return billingPeriod;
    	
    }

    public Zuora__Subscription__c getZuoraSubscription(String subscriptionId){

		Zuora__Subscription__c zSubscription;
 
		for(Zuora__Subscription__c sub : [Select z.Zuora__Zuora_Id__c, z.Zuora__TermStartDate__c, 
															z.Zuora__TermEndDate__c, z.Zuora__TCV__c, 
															z.Zuora__SubscriptionEndDate__c, z.Zuora__MRR__c, 
															z.Zuora__InitialTerm__c, z.Zuora__CustomerAccount__c, 
															z.Name, z.Id, 
																(Select Name, Zuora__BillingPeriod__c, 
																		Zuora__Price__c, Zuora__ProductSKU__c, 
																		Zuora__Quantity__c, Zuora__RatePlanDescription__c, 
																		Zuora__RatePlanName__c, Zuora__Type__c, 
																		Zuora__Zuora_Id__c, Status__c, Box_Discount__c, 
																		Zuora__RatePlanId__c 
																	From Zuora__Subscription_Product_Charges__r) 
																From Zuora__Subscription__c z 
																	Where Zuora__Zuora_Id__c =: subscriptionId]){
		
			
			zSubscription = sub;
																			
		}//end-for
		
		return zSubscription;

    	
    }



    public Zuora__CustomerAccount__c getCustomerBillingAccount(String billingaccountId){

        Zuora__CustomerAccount__c zBillingAccount;

        for(Zuora__CustomerAccount__c acct : [Select z.Zuora__Status__c, z.Zuora__SoldToName__c, z.Zuora__SoldToId__c,
                                                z.Zuora__PaymentTerm__c,
                                                z.Zuora__PaymentMethod_Type__c,
                                                z.Zuora__Default_Payment_Method__c, z.Zuora__DefaultPaymentMethod__c, z.Zuora__BillToWorkPhone__c,
                                                z.Zuora__BillToWorkEmail__c, z.Zuora__BillToState__c, z.Zuora__BillToPostalCode__c,
                                                z.Zuora__BillToName__c, z.Zuora__BillToCountry__c, z.Zuora__BillToCity__c, z.Zuora__BillToAddress2__c,
                                                z.Zuora__BillToAddress1__c, z.Id, z.EnterpriseID__c, z.Zuora__Currency__c, z.Zuora__Zuora_Id__c
                                                From Zuora__CustomerAccount__c z
                                                    Where z.Zuora__Zuora_Id__c =: billingAccountId]){

            zBillingAccount = acct;
        }

        return zBillingAccount;
    }
    
    public static String translatePaymentMethod(String paymentMethod){
    
    	String translatedPaymentMethod;
    	
    	if(paymentMethod==null || paymentMethod.length()==0){
    		return paymentMethod;
    	}
    	
		if (paymentMethod.equalsIgnoreCase('BankTransfer')){
	
			translatedPaymentMethod = 'Bank Transfer'; 
	
		} else if (paymentMethod.equalsIgnoreCase('CreditCard')){
	
			translatedPaymentMethod = 'Credit Card';
	
		} else if (paymentMethod.equalsIgnoreCase('CreditCardReferenceTransaction')){
	
			translatedPaymentMethod = 'Credit Card Reference Transaction'; 
	
		} else if (paymentMethod.equalsIgnoreCase('DebitCard')){
	
			translatedPaymentMethod = 'Debit Card'; 
	
		} else if (paymentMethod.equalsIgnoreCase('WireTransfer')){
	
			translatedPaymentMethod = 'Wire Transfer';
	
		}else{
	
			translatedPaymentMethod = paymentMethod;	
	
		}
		
		return translatedPaymentMethod;
    	
    	
    }

    public void setDealType() {
        System.debug('Deal Type: ' + quote.Deal_Type__c);
        if (quote.Deal_Type__c == 'ELA') {
            this.isELA = true;
        }
        else {
            this.isELA = false;
        }
    }

    private static void appendErrorMessage(String message) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
    }

    //////////////////
    // Test methods
    //////////////////
    private static Zuora.ZObject getTestingBillingAccount() {
        Zuora.zObject billingAccount = new Zuora.zObject('Account');
        billingAccount.setValue('Currency','USD');
        billingAccount.setValue('PaymentTerm','Monthly');
        return billingAccount;
    }

    private static Zuora.ZObject getTestingSubscription() {
        Zuora.ZObject sub = new Zuora.ZObject('Subscription');
        sub.setValue('TermStartDate', DateTime.newInstanceGmt(2014, 4, 2));
        sub.setValue('TermEndDate', DateTime.newInstanceGmt(2015, 4, 2));
        sub.setValue('Name', 'Kyle Sub');
        sub.setValue('Version', 3);
        sub.setValue('InitialTerm', 2);
        sub.setValue('RenewalTerm', 2);
        return sub;
    }
     
}