@isTest
private class QualificationNoteUtility_Test {

    static testMethod void testLeadConversion() {
    	
    	List<Lead> leadList = new List<Lead>();
    	
		Lead testLead1 = new Lead( 
	        Employees__c = 600,
	        Contact_Method__c = 'Event',   
	        Email = 'QualificationNoteUtility_Test1@box.com',  
	        Upsell_Opportunity__c = true,
	        Purchase_Time_Frame__c = '< 1 month',
	        Title = 'CEO',
	        About_the_Company__c = 'Insurance',
	        Number_of_Users__c = 120,
	        Scope_of_Deployment__c = 'Companywide',
	        Number_of_Upsell_Users__c = 10,
	        FirstName = 'A',
	        LastName = 'P',
	        Company = 'Plutzer 1',
	        Country = 'United States',
			of_Users__c = '100',
			Budget_Buying_Process__c = 'test',
			Business_Use_Case_Objective_Need__c = 'test',
			Compelling_Event_Urgency__c = 'test',
			Competition_qual__c = 'test',
			Current_IT_Environment__c = 'test',
			Decision_Maker_Authority__c = 'test', 
			Next_Steps_Follow_Up_Question__c = 'test',
			Opp_Details__c = 'test',
			Opp_Source__c = 'test',
			Pain_qual__c = 'test',
			Timeframe_in_months__c = '6'
		);
		
		Lead testLead2 = new Lead( 
	        Employees__c = 300,
	        Contact_Method__c = 'Event',   
	        Email = 'QualificationNoteUtility_Test2@box.com',  
	        Upsell_Opportunity__c = true,
	        Purchase_Time_Frame__c = '< 6 month',
	        Title = 'CIO',
	        About_the_Company__c = 'Software',
	        Number_of_Users__c = 120,
	        Scope_of_Deployment__c = 'Companywide',
	        Number_of_Upsell_Users__c = 10,
	        FirstName = 'K',
	        LastName = 'V',
	        Company = 'Vermeer 1',
	        Country = 'United States',
			of_Users__c = '200',
			Budget_Buying_Process__c = 'test',
			Business_Use_Case_Objective_Need__c = 'test',
			Compelling_Event_Urgency__c = 'test',
			Competition_qual__c = 'test',
			Current_IT_Environment__c = 'test',
			Decision_Maker_Authority__c = 'test', 
			Next_Steps_Follow_Up_Question__c = 'test',
			Opp_Details__c = 'test',
			Opp_Source__c = 'test',
			Pain_qual__c = 'test',
			Timeframe_in_months__c = '3'
		);
		
		leadList.add(testLead1);
		leadList.add(testLead2);
		
		insert leadList;
		
		LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
		
		Database.LeadConvert lc1 = new Database.LeadConvert();
		lc1.setLeadId(testLead1.id);
		lc1.setConvertedStatus(convertStatus.MasterLabel);
		Database.LeadConvertResult lcr1 = Database.convertLead(lc1);

		System.assert(lcr1.isSuccess());
	
	
		Database.LeadConvert lc2 = new Database.LeadConvert();
		lc2.setLeadId(testLead2.id);
		lc2.setConvertedStatus(convertStatus.MasterLabel);
		Database.LeadConvertResult lcr2 = Database.convertLead(lc2);

		System.assert(lcr2.isSuccess());

    }


	/* Create US Opps */
    static testMethod void testCreateOpps() {
  

		Account acct = new Account (Name='Cupertino 95014 Account 1', 
										BillingCity = 'Cupertino', 
										BillingPostalCode = '95014', 
										BillingState = 'CA', 
										BillingCountry = 'United States', 
										No_Employees__c = 1001);
		insert acct;
		
 		Contact testContact = new Contact (FirstName='Test Jon', LastName='Smith', accountId=acct.Id);
		insert testContact;
		
    	for(Contact c: [Select of_Users__c, Budget_Buying_Process__c, Business_Use_Case_Objective_Need__c,
								Compelling_Event_Urgency__c, Competition__c, Current_IT_Environment__c, 
								Decision_Maker_Authority__c, Next_Steps_Follow_Up_Question__c, 
								Opp_Details__c, Opp_Source__c, Pain__c, Timeframe_in_months__c,
								account.name
							from Contact 
								Where Id =:testContact.Id]){
									
		
			testContact=c;
		}
		
 		// Create opps
		Opportunity opp = new Opportunity(Name='Cupertino 95014 Opp 1', AccountId=acct.Id, StageName='Prospecting',
                                     Account_Type_Sold__c='Business', CloseDate=Date.today().addDays(10));
		insert opp;
		
		OpportunityContactRole ocr = new OpportunityContactRole(ContactId=testContact.Id, IsPrimary=true, OpportunityId=opp.Id);
		insert ocr;

    	boolean containsNote = QualificationNoteUtility.containsNote(testContact);				
 		Qualification_Note__c note = QualificationNoteUtility.copyNote(opp.Id, testContact);
										
		 
	}
}