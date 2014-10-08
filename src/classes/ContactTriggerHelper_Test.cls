@isTest
private class ContactTriggerHelper_Test {


	static testMethod void testNonQuoteContact() {

  		Account acct = new Account(Name='Test Account');
  		insert acct;
  		      
  		Contact testContact = new Contact(LastName = 'Smith', 
	  										AccountId=acct.Id, 
								            Email = 'ContactTriggerTest@box.com.test', 
								            MailingStreet = '123 Main St.', 
								            MailingState = 'CA', 
								            MailingPostalCode = '94087', 
								            MailingCountry = 'United States', 
								            MailingCity = 'Sunnyvale'); 
        
        insert testContact;
        
		// ok to update contact
        update testContact;
        
        // ok to delete contact
        delete testContact;
        
	}
	

	static testMethod void testQuoteContact1() {

        Account acct = Z_TestUtils.createAccount(true);
        Opportunity opp = Z_TestUtils.createOpportunity(acct.Id, true);
        zqu__Quote__c quote = Z_TestUtils.createZQuote(opp.Id, true);
        
        Id billToId = quote.zqu__BillToContact__c;
        Id soldToId = quote.zqu__SoldToContact__c;


        quote.Live_Quote__c = true;
		quote.Approval_Status__c = 'In Review';
		update quote;
		
		// user can't update a contact that is been approved or has been approved

		try{
			
        	update new Contact(Id=billToId, MailingStreet='888 Main Street');
        	
		}catch(Exception e){
			
		}
 		


	}

	static testMethod void testQuoteContact2() { 
  
        Account acct = Z_TestUtils.createAccount(true);
        Opportunity opp = Z_TestUtils.createOpportunity(acct.Id, true);
        zqu__Quote__c quote = Z_TestUtils.createZQuote(opp.Id, true);

        Id billToId = quote.zqu__BillToContact__c;
        Id soldToId = quote.zqu__SoldToContact__c;
        
      

        // user can't delete a contact that is used on a qoute
        try{
        	
        	delete new Contact(Id=billToId);
        	
        }catch(Exception e){
        	
        }
         try{
            
            delete new Contact(Id=soldToId);
            
        }catch(Exception e){
            
        }
  	}


}