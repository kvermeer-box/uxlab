@isTest
private class AccountTriggerHelper_Test {

	@isTest static void testNewAccount() {
  
  		Billing_Country__c billingCountry = new Billing_Country__c();
  		billingCountry.Name = 'France';
		  billingCountry.Billing_Theater__c = 'EMEA';
      billingCountry.Billing_Region__c = 'Southern';
      billingCountry.Billing_Subregion__c = 'France';
      insert billingCountry;
  
  		Account testAccount = new Account(Name='Test Account');
  		testAccount.BillingCountry = 'France';
  		insert testAccount;
  		
  		Account validateTestAccount=[select Id, Account_Hierarchy__c, BillingCountry, Billing_Region__c, 
  												Billing_Subregion__c, Billing_Theater__c 
  											from Account 
  												where Id =: testAccount.Id];

  		System.assertEquals(validateTestAccount.Billing_Region__c, billingCountry.Billing_Region__c);
  		System.assertEquals(validateTestAccount.Billing_Subregion__c, billingCountry.Billing_Subregion__c);
  		System.assertEquals(validateTestAccount.Billing_Theater__c, billingCountry.Billing_Theater__c);  

  	}

  	@isTest static void testUpdateAccount() { 
  		
      Billing_Country__c billingCountry = new Billing_Country__c();
  		billingCountry.Name = 'France';
		  billingCountry.Billing_Theater__c = 'EMEA';
      billingCountry.Billing_Region__c = 'Southern';
      billingCountry.Billing_Subregion__c = 'France';
      insert billingCountry;


  		Account testAccount = new Account(Name='Test Account');
  		insert testAccount;
  		
  		testAccount.BillingCountry = 'France';
  		update testAccount;
  		
  		Account validateTestAccount=[select Id, BillingCountry, Billing_Region__c, Billing_Subregion__c, Billing_Theater__c from Account where Id =: testAccount.Id];

  		System.assertEquals(validateTestAccount.Billing_Region__c, billingCountry.Billing_Region__c);
  		System.assertEquals(validateTestAccount.Billing_Subregion__c, billingCountry.Billing_Subregion__c);
  		System.assertEquals(validateTestAccount.Billing_Theater__c, billingCountry.Billing_Theater__c);    		  		
  	}
  

  
}