public class OpportunityFieldUpdate {

    public Opportunity searchResults {get;set;}
    public string searchText {get;set;}
    public string searchText2 {get;set;}   
    public String InputCTNValue {get;set;}
    public String CTNValue {get;set;}
    public String opptystage {get;set;} 
    public Id Cid{get;set;} 
    public String Cemail{get;set;} 
    public String FirstName{get;set;} 
    public String LastName{get;set;} 
    public String oppconRoleId {get;set;}
    Public String UserName {get; set;}
    public String dealstat{get;set;}
        
    public OpportunityFieldUpdate(){}
    
    public PageReference extendDealReg(){
    	String oldRequest;
    	Datetime oldDate;
    	try {
    		oldRequest = searchResults.Deal_Reg_Extension_Requested__c;
	    	searchResults.Deal_Reg_Extension_Requested__c = 'Yes' ;
	    	oldDate = searchResults.Extension_Requested_Date_Time__c;
	    	searchResults.Extension_Requested_Date_Time__c= Datetime.now();
	        update searchResults;
	     } Catch (DMLException e) {
	     	searchResults.Deal_Reg_Extension_Requested__c = oldRequest;
	     	searchResults.Extension_Requested_Date_Time__c = oldDate;
	        ApexPages.addMessages(e);
	        return null;
	    }
	        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Your deal reg extension request has been submitted.'));
	    return null;
    }
    
    public PageReference search() {
    String qry = 'select Id, Registration_ID__c, ATTUID__c, Owner.Alias,Name,Account.NAME, AccountId, Box_Partner_Account__c,Opportunity_Type__c,CloseDate,StageName,Account_Type_Sold__c,' + 
                 'Deal_Reg_Approval_Status__c, Deal_Reg_Extension_Requested__c,Deal_Reg_Expiration_Date__c,Deal_Reg_Rejection_Reason__c,' +
                 'Partner_Submitter_Name__c,Partner_Submitter_Phone__c,Partner_Submitter_Email__c,Why_Box__c,Sales_Rep_Channel_only__c,' +
                 'Box_Enterprise_ID__c,Box_Entity__c,Seats_Sold__c, Partner_External_ID__c,Deal_Reg_Submission_Date__c, Extension_Requested_Date_Time__c,' +
                 'Deal_Reg_Approval_Rejection_Date_Time__c,Extension_Approval_Rejection_Date_Time__c from Opportunity ' +
                 'where Registration_ID__c =:searchText AND ATTUID__c =:searchText2 AND Registration_ID__c != null AND ATTUID__c !=null  LIMIT 1';

    if (!Database.query(qry).isEmpty()){
    searchResults = Database.query(qry);
    CTNValue = searchResults.Partner_External_ID__c;
    opptystage = searchResults.StageName;
    dealstat=searchResults.Deal_Reg_Approval_Status__c;
   
    List<OpportunityContactRole> oppccr = [Select Id,Contact.email,Contact.FirstName, Contact.LastName,Contact.id 
                                           from OpportunityContactRole where OpportunityId  =: searchResults.id AND IsPrimary = true];
    if(!oppccr.IsEmpty()){
        Cid=oppccr[0].Contact.id;
        oppconRoleId = oppccr[0].id;
        Cemail=oppccr[0].Contact.email;
        FirstName = oppccr[0].Contact.FirstName;
        LastName  = oppccr[0].Contact.LastName;
    }
    
    List<User> UsNm = [Select Id, Name from User where Id =: searchResults.Sales_Rep_Channel_only__c];
    if(!UsNm.isEmpty()){
        UserName = UsNm[0].Name;
    }    
    }
    else
    {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'No opportunity Found'));
    }
  
    return null;
    }
  
   public PageReference save() {
       if(opptystage == 'Closed Won' || opptystage == 'Closed Lost' || dealstat=='Pending' ){
           ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'This deal registration CTN or admin email address cannot be edited if the deal registration has a pending status, is already closed, or is an add-on order to an existing Box instance.'));
           return null;
       }
       if(CTNValue.length() != 10){
           Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.fatal, 'CTN Must contain a valid 10 digit number (no spaces, dashes).'));                
           return null;                
       }
       else{
            Pattern isnumbers = Pattern.Compile('^[2-9][0-9]+$');
            Matcher postalMatch = isnumbers.matcher(CTNValue);
            if(!postalMatch.Matches()){
                    Apexpages.addMessage(new Apexpages.Message(
                Apexpages.severity.fatal,
                'CTN Must contain a valid 10 digit number (no spaces, dashes).'     ));                
            return null;
            }
       }
         
/**** Start 02/19/2014 */
        List<Contact> oldEmail = [SELECT Email FROM Contact where Id =:Cid];
        if(!oldEmail.IsEmpty()){
            if(Cemail != oldEmail[0].Email){
                List<Contact> ConExistingEmail = [SELECT Id From Contact WHERE  Email =: Cemail AND AccountId !=: searchResults.AccountId];
                if(!ConExistingEmail.isEmpty())           
                {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Your requested change for the admin email address cannot be completed since this email address is associated to another account record.'));
                    return null;
                }
            }   
        }
        if(!oldEmail.IsEmpty() && Cemail !=null){
            string eDomainNew = Cemail.substringAfter('@');
            string eDomainOld = oldEmail[0].Email.substringAfter('@');
            if(eDomainNew != eDomainOld){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'The domain of the new admin email address that you submitted must match the previous admin email address domain that is associated to this deal registration.'));
                return null;        
            }
        }   
/**** End 02/19/2014 */        
               
        List<Partner_Key_Account__c> PartnerKeyValidation = [Select Id From Partner_Key_Account__c 
                                                              WHERE Key__c =: CTNValue AND Account__c  !=: searchResults.AccountId];
        if(PartnerKeyValidation.isEmpty())
        { 
            if(InputCTNValue == null){
                    upsertPartnerKey(searchResults); 
                  
                        upsertContact(searchResults); 
                           
            }
            else{ 
                    upsertPartnerKey(searchResults); 
                    
                        upsertContact(searchResults); 
                            
            }
           }else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Given Partner Key is already being used '));    
            return null ;
         } 
    
    try {
    searchResults.Partner_External_ID__c = CTNValue ;
    searchResults.Box_Entity__c='Box, Inc';
           update searchResults;
     } Catch (DMLException e) {
        ApexPages.addMessages(e);
        return null;
    }
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Deal Reg Is updated Succesfully '));
    //return new PageReference('/DealRegDataUpdate');
    return null;
  }

 //================
       private Partner_Key_Account__c upsertPartnerKey(Opportunity OppId){
        Partner_Key_Account__c upsertPartnerKey;
        Opportunity opty_qtr =  [select Id, Account.Name, AccountId, Box_Partner_Account__c from Opportunity where Id=:OppId.Id];
        
        List<Partner_Key_Account__c> PtrId = [select Id from Partner_Key_Account__c where Account__c =:opty_qtr.AccountId 
                                              AND Partner__c =: opty_qtr.Box_Partner_Account__c LIMIT 1];
                                             
        if(PtrId.size()>0){
            upsertPartnerKey = new Partner_Key_Account__c(
                                    Id = PtrId[0].Id,
                                    Account__c = opty_qtr.AccountId, 
                                    Partner__c = opty_qtr.Box_Partner_Account__c, 
                                    Key__c = CTNValue);
            try { Update upsertPartnerKey; }   
            catch (Exception x) { apexpages.addmessages(x);}
        }
        else{ 
            upsertPartnerKey = new Partner_Key_Account__c(
                                    Account__c = opty_qtr.AccountId, 
                                    Partner__c = opty_qtr.Box_Partner_Account__c, 
                                    Key__c =CTNValue);
            try { Insert upsertPartnerKey; }   
            catch (Exception x) { apexpages.addmessages(x);}        
        }
        
        return upsertPartnerKey;
    }
//===================
private Contact upsertContact(Opportunity OppId){
       List<Contact> existingCon = [Select Id from Contact where Email =: Cemail LIMIT 1]; 
       if(existingCon.size()>0){
           Contact upsertContact = new Contact(
                                   Id = existingCon[0].Id,
                                   AccountId = searchResults.AccountId,
                                   Email = Cemail);
           database.upsert(upsertContact );
           OpportunityContactRole upsertOpptyConRole = new OpportunityContactRole (
                                                       Id = oppconRoleId,
                                                       IsPrimary = true, 
                                                       OpportunityId = searchResults.id,
                                                       Contactid = existingCon[0].Id);
           database.upsert (upsertOpptyConRole);                                            
           return null; 
       }          
       else {
           Contact insertContact = new Contact(
                                   FirstName = FirstName,
                                   LastName = LastName,
                                   AccountId = searchResults.AccountId,
                                   Email = Cemail);
           database.insert (insertContact );          
                                                  
           OpportunityContactRole upsertOpptyConRole2 = new OpportunityContactRole (
                                                        Id = oppconRoleId, 
                                                        IsPrimary = true,
                                                        OpportunityId = searchResults.id,
                                                        Contactid = insertContact.Id);
           try { upsert upsertOpptyConRole2 ; }   
           catch (Exception x) { apexpages.addmessages(x);}
           return null;
       }  
}
//==================

}