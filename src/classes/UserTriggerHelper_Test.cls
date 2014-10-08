@isTest
private class UserTriggerHelper_Test {

	/* create partner portal account with 1 portal user */
	@isTest static void testNewContact() {
	
		Profile partnerProfile;
		
		for(Profile p : [SELECT Id ,Name, UserLicenseId, UserType 
									FROM Profile 
										Where UserType ='PowerPartner' order by CreatedDate desc limit 1]){
			partnerProfile=p;	
		}
	
		
		
		Group partnerGroup;
		
		for(Group g : [select id, name, developername from Group 
									where type = 'Regular' and name =: partnerProfile.name] ){
		
			partnerGroup=g;								
		}
		
		if(partnerGroup==null){
			partnerGroup = new Group(Name=partnerProfile.name);
			insert partnerGroup;
		}
		
		Account acct1 = new Account (Name='Partner Account', 
										BillingPostalCode = '94087', 
										BillingCountry = 'United States', 
										No_Employees__c = 10);
		
		insert acct1;	
		
		acct1.IsPartner=true;
		update acct1;
		
		Contact contact1 = new Contact(	FirstName = 'Test', 
										LastName = 'Partner', 
										Email='partnerUserTest@box.com',
										AccountId = acct1.Id);
		insert contact1;
		
		
		
		User u = new User(	alias = 'ZZZTEST', 
							email=contact1.email, 
				            emailencodingkey='UTF-8', 
				            firstname=contact1.firstname,
				            lastname=contact1.lastname, 
				            languagelocalekey='en_US', 
				            localesidkey='en_US', 
				            profileid = partnerProfile.Id, 
				            contactId=contact1.Id,
				            timezonesidkey='America/Los_Angeles', 
				            username=contact1.email);
    	insert u;
    	
    	GroupMember grpMember;
    	
    	for(GroupMember gm : [Select Id, GroupId, UserOrGroupId From GroupMember
											where UserOrGroupId =: u.id
													and GroupId =: partnerGroup.id] ){
    		grpMember=gm;	
    	}
    	
    	System.assert(grpMember!=null);
    	
    	/* update contact */
    	update contact1;

		
	}




}