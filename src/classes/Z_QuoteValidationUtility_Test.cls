@isTest
private class Z_QuoteValidationUtility_Test {


 	public static String SUBSCRIPTION_TYPE_NEW_SUBSCRIPTION 	= 'New Subscription';
 	public static String SUBSCRIPTION_TYPE_RENEW_SUBSCRIPTION 	= 'Renew Subscription';
 	public static String SUBSCRIPTION_TYPE_AMEND_SUBSCRIPTION 	= 'Amend Subscription';


	static testMethod void testQuoteValidationCheckMinimum1() {

		Account acct = new Account(Name='Test Account');
  		insert acct;
  		  
  		Contact testContact1 = new Contact(LastName = 'Connery', 
	  										AccountId=acct.Id,
	  										MailingCountry = 'United States'); 
   
  		Contact testContact2 = new Contact(LastName = 'Bourne', 
	  										AccountId=acct.Id,  
	  										MailingStreet = 'PO Box 888',
								            MailingCity = 'Sunnyvale', 
								            MailingState = 'CA', 
								            MailingPostalCode = '94087', 
	  										MailingCountry = 'United States'); 
	  										  
  		Contact testContact3 = new Contact(LastName = 'Brown', 
	  										AccountId=acct.Id, 
								            Email = 'ContactTriggerTest2@box.com.test', 
								            MailingStreet = '123 Main St.', 
								            MailingCity = 'Sunnyvale',
								            MailingState = 'CA', 
								            MailingPostalCode = '94087', 
								            MailingCountry = 'United States');
						            
		insert testContact1;
		insert testContact2;
		insert testContact3;
		
		List <ApexPages.Message> messages; 
										            
        Opportunity opp = Z_TestUtils.createOpportunity(acct.Id, true);
        zqu__Quote__c quote = Z_TestUtils.createZQuote(opp.Id, true);
        
        
        // New Subscription
        quote.zqu__SubscriptionType__c  = SUBSCRIPTION_TYPE_NEW_SUBSCRIPTION;
        quote.zqu__PaymentMethod__c = 'Check';
        quote.zqu__PaymentTerm__c	= 'Net 30';
        quote.zqu__BillToContact__c = testContact1.Id;
        quote.zqu__SoldToContact__c = testContact1.Id;
		quote.zqu__Currency__c = 'USD';
		quote.zqu__InitialTerm__c = 12;
		quote.Payment_Frequency__c = 'Annual';
		quote.NRR__c = 0;
		quote.Box_MRR__c = 0;
		quote.MRR_New__c = 0;
        update quote;
 
 		messages = Z_QuoteValidationUtility.validateQuote(quote.Id);
 		

 		// Rewew Subscription
        quote.zqu__SubscriptionType__c  = SUBSCRIPTION_TYPE_RENEW_SUBSCRIPTION;
        quote.zqu__PaymentMethod__c = 'Check';
        quote.zqu__PaymentTerm__c	= 'Net 30';
        quote.zqu__BillToContact__c = testContact1.Id;
        quote.zqu__SoldToContact__c = testContact1.Id;
        quote.zqu__Currency__c = 'USD';  
        quote.zqu__InitialTerm__c = 12;
		quote.Payment_Frequency__c = 'Annual';
		quote.NRR__c = 0;
		quote.Box_MRR__c = 0;
		quote.MRR_New__c = 0;
        update quote;
 
 		messages = Z_QuoteValidationUtility.validateQuote(quote.Id);


		// Amend Subscription - New Box Subscription
        quote.zqu__SubscriptionType__c  = SUBSCRIPTION_TYPE_AMEND_SUBSCRIPTION;
        quote.Change_License_Product__c = true;
        quote.zqu__PaymentMethod__c = 'Check';
        quote.zqu__PaymentTerm__c	= 'Net 30';
        quote.zqu__BillToContact__c = testContact1.Id;
        quote.zqu__SoldToContact__c = testContact1.Id;
        quote.zqu__Currency__c = 'USD';
		quote.zqu__InitialTerm__c = 12;
		quote.Payment_Frequency__c = 'Annual';
		quote.NRR__c = 0;
		quote.Box_MRR__c = 0;
		quote.MRR_New__c = 0;
        update quote;
 
 		messages = Z_QuoteValidationUtility.validateQuote(quote.Id);

		// Amend Subscription - Existing Box Subscription
        quote.zqu__SubscriptionType__c  = SUBSCRIPTION_TYPE_AMEND_SUBSCRIPTION;
        quote.Change_License_Product__c = false;
        quote.zqu__PaymentMethod__c = 'Check';
        quote.zqu__PaymentTerm__c	= 'Net 30';
        quote.zqu__BillToContact__c = testContact1.Id;
        quote.zqu__SoldToContact__c = testContact1.Id;
        quote.zqu__Currency__c = 'USD';
		quote.zqu__InitialTerm__c = 12;
		quote.Payment_Frequency__c = 'Annual';
		quote.NRR__c = 0;
		quote.Box_MRR__c = 0;
		quote.MRR_New__c = 0;
        update quote;
 
 		messages = Z_QuoteValidationUtility.validateQuote(quote.Id);

	}



	static testMethod void testQuoteValidationCheckMinimum2() {

		Account acct = new Account(Name='Test Account');
  		insert acct;
  		  
  		Contact testContact1 = new Contact(LastName = 'Connery', 
	  										AccountId=acct.Id,
	  										MailingCountry = 'United States'); 
   
  		Contact testContact2 = new Contact(LastName = 'Bourne', 
	  										AccountId=acct.Id,  
	  										MailingStreet = 'PO Box 888',
								            MailingCity = 'Sunnyvale', 
								            MailingState = 'CA', 
								            MailingPostalCode = '94087', 
	  										MailingCountry = 'United States'); 
	  										  
  		Contact testContact3 = new Contact(LastName = 'Brown', 
	  										AccountId=acct.Id, 
								            Email = 'ContactTriggerTest2@box.com.test', 
								            MailingStreet = '123 Main St.', 
								            MailingCity = 'Sunnyvale',
								            MailingState = 'CA', 
								            MailingPostalCode = '94087', 
								            MailingCountry = 'United States');
						            
		insert testContact1;
		insert testContact2;
		insert testContact3;
		
		List <ApexPages.Message> messages; 
										            
        Opportunity opp = Z_TestUtils.createOpportunity(acct.Id, true);
        zqu__Quote__c quote = Z_TestUtils.createZQuote(opp.Id, true);
        
        
        // New Subscription
        quote.zqu__SubscriptionType__c  = SUBSCRIPTION_TYPE_NEW_SUBSCRIPTION;
        quote.zqu__PaymentMethod__c = 'Check';
        quote.zqu__PaymentTerm__c	= 'Net 30';
        quote.zqu__BillToContact__c = testContact1.Id;
        quote.zqu__SoldToContact__c = testContact1.Id;
		quote.zqu__Currency__c = 'USD';
		quote.zqu__InitialTerm__c = 12;
		quote.Payment_Frequency__c = 'Annual';
		quote.NRR__c = 3000;
		quote.Box_MRR__c = 3000;
		quote.MRR_New__c = 3000;
        update quote;
 
 		messages = Z_QuoteValidationUtility.validateQuote(quote.Id);
 		

 		// Rewew Subscription
        quote.zqu__SubscriptionType__c  = SUBSCRIPTION_TYPE_RENEW_SUBSCRIPTION;
        quote.zqu__PaymentMethod__c = 'Check';
        quote.zqu__PaymentTerm__c	= 'Net 30';
        quote.zqu__BillToContact__c = testContact1.Id;
        quote.zqu__SoldToContact__c = testContact1.Id;
        quote.zqu__Currency__c = 'USD';  
        quote.zqu__InitialTerm__c = 12;
		quote.Payment_Frequency__c = 'Annual';
		quote.NRR__c = 3000;
		quote.Box_MRR__c = 3000;
		quote.MRR_New__c = 3000;
        update quote;
 
 		messages = Z_QuoteValidationUtility.validateQuote(quote.Id);


		// Amend Subscription - New Box Subscription
        quote.zqu__SubscriptionType__c  = SUBSCRIPTION_TYPE_AMEND_SUBSCRIPTION;
        quote.Change_License_Product__c = true;
        quote.zqu__PaymentMethod__c = 'Check';
        quote.zqu__PaymentTerm__c	= 'Net 30';
        quote.zqu__BillToContact__c = testContact1.Id;
        quote.zqu__SoldToContact__c = testContact1.Id;
        quote.zqu__Currency__c = 'USD';
		quote.zqu__InitialTerm__c = 12;
		quote.Payment_Frequency__c = 'Annual';
		quote.NRR__c = 3000;
		quote.Box_MRR__c = 3000;
		quote.MRR_New__c = 3000;
        update quote;
 
 		messages = Z_QuoteValidationUtility.validateQuote(quote.Id);

		// Amend Subscription - Existing Box Subscription
        quote.zqu__SubscriptionType__c  = SUBSCRIPTION_TYPE_AMEND_SUBSCRIPTION;
        quote.Change_License_Product__c = false;
        quote.zqu__PaymentMethod__c = 'Check';
        quote.zqu__PaymentTerm__c	= 'Net 30';
        quote.zqu__BillToContact__c = testContact1.Id;
        quote.zqu__SoldToContact__c = testContact1.Id;
        quote.zqu__Currency__c = 'USD';
		quote.zqu__InitialTerm__c = 12;
		quote.Payment_Frequency__c = 'Annual';
		quote.NRR__c = 3000;
		quote.Box_MRR__c = 3000;
		quote.MRR_New__c = 3000;
        update quote;
 
 		messages = Z_QuoteValidationUtility.validateQuote(quote.Id);

	}


	/* contacts have no addresses */
	/* no payment term */
	/* quote name length */
	static testMethod void testQuoteValidation1() {

		Account acct = new Account(Name='Test Account');
  		insert acct;
  		  
  		Contact testContact1 = new Contact(LastName = 'Connery', 
	  										AccountId=acct.Id,
	  										MailingCountry = 'United States'); 
   
  		Contact testContact2 = new Contact(LastName = 'Bourne', 
	  										AccountId=acct.Id,  
	  										MailingStreet = 'PO Box 888',
								            MailingCity = 'Sunnyvale', 
								            MailingState = 'CA', 
								            MailingPostalCode = '94087', 
	  										MailingCountry = 'United States'); 
	  										  
  		Contact testContact3 = new Contact(LastName = 'Brown', 
	  										AccountId=acct.Id, 
								            Email = 'ContactTriggerTest2@box.com.test', 
								            MailingStreet = '123 Main St.', 
								            MailingCity = 'Sunnyvale',
								            MailingState = 'CA', 
								            MailingPostalCode = '94087', 
								            MailingCountry = 'United States');
						            
		insert testContact1;
		insert testContact2;
		insert testContact3;
		
		List <ApexPages.Message> messages; 
										            
        Opportunity opp = Z_TestUtils.createOpportunity(acct.Id, true);
        zqu__Quote__c quote = Z_TestUtils.createZQuote(opp.Id, true);
        
        quote.name = '123456789012345678901234567890123456789012345678901234567890123456789012345678';
        quote.zqu__PaymentMethod__c = 'Check';
        quote.zqu__PaymentTerm__c	= null;
        quote.zqu__BillToContact__c = testContact1.Id;
        quote.zqu__SoldToContact__c = testContact1.Id;
		quote.zqu__Currency__c = 'USD';
		
        update quote;
 
 		messages = Z_QuoteValidationUtility.validateQuote(quote.Id);
 	}

	
	/* sold to contact has po box US address */	
	/* no payment frequency */
	/* no payment method */
	/* verify ELA */
	static testMethod void testQuoteValidation2() {

		Account acct = new Account(Name='Test Account');
  		insert acct;
  		  
  		Contact testContact1 = new Contact(LastName = 'Connery', 
	  										AccountId=acct.Id,
	  										MailingCountry = 'United States'); 

  		Contact testContact2 = new Contact(LastName = 'Bourne', 
	  										AccountId=acct.Id,
	  										MailingStreet = 'PO Box 888',
								            MailingCity = 'Sunnyvale', 
								            MailingState = 'CA', 
								            MailingPostalCode = '94087', 
	  										MailingCountry = 'United States'); 
	  										
  		Contact testContact3 = new Contact(LastName = 'Brown', 
	  										AccountId=acct.Id, 
								            Email = 'ContactTriggerTest2@box.com.test', 
								            MailingStreet = '123 Main St.', 
								            MailingCity = 'Sunnyvale',
								            MailingState = 'CA', 
								            MailingPostalCode = '94087', 
								            MailingCountry = 'United States');
						            
		insert testContact1;
		insert testContact2;
		insert testContact3;

		List <ApexPages.Message> messages; 
		            
        Opportunity opp = Z_TestUtils.createOpportunity(acct.Id, true);
        zqu__Quote__c quote = Z_TestUtils.createZQuote(opp.Id, true);

        quote.zqu__SubscriptionType__c  = SUBSCRIPTION_TYPE_NEW_SUBSCRIPTION;
        quote.Payment_Frequency__c 	= null;
        quote.zqu__PaymentMethod__c = null;
        quote.zqu__BillToContact__c = testContact1.Id;
        quote.zqu__SoldToContact__c = testContact2.Id;

        update quote;
 
 		messages = Z_QuoteValidationUtility.validateQuote(quote.Id);


        quote.zqu__SubscriptionType__c  = SUBSCRIPTION_TYPE_NEW_SUBSCRIPTION;
        quote.Payment_Frequency__c 	= null;
        quote.zqu__PaymentMethod__c = null;
        quote.zqu__BillToContact__c = testContact1.Id;
        quote.zqu__SoldToContact__c = testContact2.Id;
		quote.Seats_Sold__c = 1;
		quote.zqu__InitialTerm__c = 12;
		quote.ELA__c = true;
        update quote;

 		messages = Z_QuoteValidationUtility.validateQuote(quote.Id);
 
	}
 
}