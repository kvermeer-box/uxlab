/***************************************************************************************************************************************
    Class:          DealRegController
    
    Description:    Insert acct, opp, campaing member, opp contact role.
                    Controller for the Deal Registration Wizard.
    
    Author:         Jeremy Henson                   
     
    Revision Hist:  J.Henson, 12/12/2012,   Initial Version
                    J.Henson, 3/13/2013,    Added logic to prevent submission when a pending opp exists
                                            Restrict CTN to 10 chars & require when ATT cust is 'Yes'
                                            Refactored some hard coded oppty record type IDs (unknown modification)
                    J.Henson, 4/12/2013,    Updated logic to match accounts based on Partner_Key_Account__c
                    J.Henson, 4/25/2013,    Updated API to v26 to allow udpate of ID fields on sObject instances (for matching)
                                            Removed the "caching" of matches to allow for previous clicks to rematch records
                    J.Henson, 5/01/2013,    Added cookie to persist the partner ID, which is just a random double value
                                            


****************************************************************************************************************************************/

public without sharing class DealRegController {    

//  Form fields & objects
//  --------------------------------------------------------------------    
    public Opportunity  opp                     {get; set;}
    public Contact      c                       {get; set;}
    public Account      a                       {get; set;}      
    public String       InputKeyValue           {get; set;}
    public String       PartnerId               {get; set;}
    public boolean      contactexist            {get; set;}
    public boolean contactexistWithActiveOpps   {get; set;}
    public boolean isATTCustomer                {get; set;}
    public String isPrimarySalesRep             {get; set;}
    public decimal      conversion              {get; set;}
    public boolean      typeCheck               {get; set;}
    
//  Const
//  --------------------------------------------------------------------        
    public DealRegController(){   

        this.opp = new Opportunity();
        this.c = new Contact();
        this.a = new Account(BillingCountry = 'United States');
        //this.a.isExcludedFromRealign=true;
        
    //  Validate the partner ID if the user is a guest        
        if(Userinfo.getUserType() == 'Guest'){          
            
        //  Grab the account that matches the partner ID provided in the URL
            try{
                
                String resellerID;
                a.isATT__c = 'Yes';
            //  Create the cookie if a ID is provided in the URL
                if(Apexpages.currentPage().getParameters().get('partnerid') != null){
                    
                    resellerID = Apexpages.currentPage().getParameters().get('partnerid');                  
                    createCookie(resellerID);               
                } else if(getCookie() != null){
                    resellerID = getCookie();
                }

                Account partnerAccount = [select id from Account where Reseller_ID__c =: Double.valueof(resellerID)];
                this.partnerId = partnerAccount.id;
            
                
                              
            } catch (Exception x){                      
                apexpages.addmessage(new apexpages.message(
                    Apexpages.severity.fatal, 'Invalid ID Provided'
                ));
            } 
        }
                          
    }
    
    public PageReference populateSalesRepInfo(){
        if( isPrimarySalesRep == 'Yes' ){
            User u = [SELECT Id, FirstName, LastName, Email, Phone FROM User WHERE Id =: Userinfo.getUserId() ];
            opp.Partner_Submitter_Name__c = u.FirstName + ' ' + u.LastName;
            opp.Partner_Submitter_Email__c = u.Email;
            opp.Partner_Submitter_Phone__c = u.Phone;
        }
        return null;
    }
    
    public PageReference PopulateisATT(){
            if(opp.isATT__c != 'Yes'){
                opp.isATT__c = 'Yes';   
            }
            
        return null;
    }
    
//  Create partnerID cookie
//  --------------------------------------------------------------------
    private void createCookie(String resellerID){
             
    //  create a new cookie with partner ID 
    //  path 'null', maxAge '-1', and isSecure 'false'.         
        Cookie partnerCookie = new Cookie('partnerCookie', resellerID , null , -1 , false);
    
    // Set the new cookie for the page
        ApexPages.currentPage().setCookies(new Cookie[]{partnerCookie});
        
    }    

//  get partnerID cookie
//  --------------------------------------------------------------------    
    public String getCookie() {     
        Cookie partnerCookie = ApexPages.currentPage().getCookies().get('partnerCookie');
        if(partnerCookie == null)return null;       
        else return partnerCookie.getValue();   
    }   

//  Nav
//  --------------------------------------------------------------------
    public Integer CurrentStep {get; set;}  //  Track the current step, so a user cannot navigate directly via URL
    
    public PageReference step1(){   CurrentStep = 1; 
                                    DebugLogger.write('DealRegController', 'step1()');          
                                    return Page.DealRegStep1;  }       
    
    public PageReference step2(){           

        DebugLogger.write('DealRegController', 'step2()');
        
    
    //  Check if ATTUI is 6 chars (unath sites users only)
        if(Userinfo.getUserType() == 'Guest'){
            if(opp.ATTUID__c != null && opp.ATTUID__c.length() != 6){
                Apexpages.addMessage(new Apexpages.Message(
                        Apexpages.severity.fatal,
                        'ATTUID Must contain a valid 6 digit ID (no spaces, dashes).'
                ));                
                return null;                
            }
           
        }                
            
    //  Proceed 
        CurrentStep = 2; 
        return Page.DealRegStep2;
        
    }
    
    public PageReference step3(){           

        DebugLogger.write('DealRegController', 'step3()');
        
    //  Require BAN if ATT Cust is YES
        if(a.Current_AT_T_Customer__c == 'Yes' && InputKeyValue == null){
            apexpages.addmessage(new Apexpages.message(Apexpages.severity.fatal,'Please input CTN'));
            return null;
        } 
        opp.isATT__c = 'Yes';
        //Set Non-standard BSA to true for AT&T
        //opp.Non_Box_BSA__c = true;   
    
    //  Check if InputKeyValue is 10 chars (unath sites users only)
        if(a.Current_AT_T_Customer__c == 'Yes' && Userinfo.getUserType() == 'Guest'){
            if(InputKeyValue.length() != 10){
                Apexpages.addMessage(new Apexpages.Message(
                        Apexpages.severity.fatal,
                        'CTN Must contain a valid 10 digit number (no spaces, dashes).  if you cannot provide a billing CTN at this time, please select "No" in the "Does this customer have a valid AT&T Billing CTN?" field.'
                ));                
                return null;                
            }
            else{
                Pattern isnumbers = Pattern.Compile('^[2-9][0-9]+$');
                Matcher postalMatch = isnumbers.matcher(InputKeyValue);
                if(!postalMatch.Matches()){
                    Apexpages.addMessage(new Apexpages.Message(
                        Apexpages.severity.fatal,
                        'CTN Must contain a valid 10 digit number (no spaces, dashes).  if you cannot provide a billing CTN at this time, please select "No" in the "Does this customer have a valid AT&T Billing CTN?" field.'
                    ));                
                    return null;
                }
            }
             
        }
    // Validate for the domain not from att.com
        if(Userinfo.getUserType() == 'Guest' && c.Email != null && c.Email.contains('att.com')){
                c.Email.addError('Customer domain required. Please submit a non-att.com email address.');  
                return null;   
        }
    // Validate that only a 5 digit # is entered for postal code
        if(Userinfo.getUserType() == 'Guest' && a.BillingPostalCode != null && !Pattern.matches('^[0-9]{5,5}$', a.BillingPostalCode)){
                a.BillingPostalCode.addError('Please provide a properly formatted US Zip Code');  
                return null;   
        }
        
    //  Check if the BAN entered has more than 1 oppty in 
        if(InputKeyValue != null){
            try{
                  Partner_Key_Account__c accKey = [select Id, Account__c, Partner__c from Partner_Key_Account__c where Key__c =:InputKeyValue];
                  Integer ApprovedCount = [select count() from Opportunity 
                        where AccountId = :accKey.Account__c
                        and RecordTypeId =: OppRecordType()
                        and IsClosed = false 
                        and Deal_Reg_Approval_Status__c != 'Rejected'];
                                            
                if(ApprovedCount > 0){
                    apexpages.addmessage(new Apexpages.message(Apexpages.severity.fatal,'Your Deal Registration cannot be processed at this time.  There is an existing deal registration that has not completed for the customer CTN that you are attempting to register.  Please contact Box Sales at dealregistrations@box.com if you need assistance or have additional questions.'));
                    return null;                    
                }
            } catch (Exception x){
                //  if ban is not matched                           
            }
        }
            
    //  Proceed 
        CurrentStep = 3; 
        return Page.DealRegStep3;
        
    }
    
    public Pagereference setATTCustomer(){
        isATTCustomer = a.Current_AT_T_Customer__c == 'Yes';
        system.debug( isATTCustomer );
        return null;
    }
    
//  Nav (Authenticated version)
//  --------------------------------------------------------------------
    public PageReference UserStep1(){   CurrentStep = 1; 

                                        DebugLogger.write('DealRegController', 'UserStep1()');
                                        return Page.UserDealRegStep1;  }   
    public PageReference UserStep2() {

        DebugLogger.write('DealRegController', 'UserStep2()');
        User u = [Select Email, FirstName, LastName, AccountId From User where id =: userinfo.getUserId()];
        if( c.Email == u.Email ){
            Apexpages.addMessage( new Apexpages.Message( Apexpages.Severity.ERROR, System.Label.Customer_Contact_Email_Address ) );
            return null;
        }
        if(c.Email.substring(c.Email.lastIndexOf('@')) == opp.Partner_Submitter_Email__c.substring(opp.Partner_Submitter_Email__c.lastIndexOf('@'))){
            Apexpages.addMessage( new Apexpages.Message( Apexpages.Severity.ERROR, 'Please provide the customer email address. The customer email domain should not be the same as your company email domain.' ) );
            return null;
        }
        
        if(c.Email.contains('box.com') || c.Email.contains('box.net') ){
            Apexpages.addMessage( new Apexpages.Message( Apexpages.Severity.ERROR, 'Invalid customer email Address.' ) );
            return null;
        }
        
        opp.isATT__c = 'No';
        if( isPrimarySalesRep == 'None' ){
            Apexpages.addMessage( new Apexpages.Message( Apexpages.Severity.ERROR, 'Are you the Sales Rep : Value Required' ) );
            return null;
        }
        CurrentStep = 2; return Page.UserDealRegStep2;  
    }


//  Get oppty record type
//  --------------------------------------------------------------------    
    String oppRecordType;
    private String OppRecordType(){
        if(oppRecordType == null){
            RecordType RT = [select id from RecordType where DeveloperName = 'Partner_Deal_Reg_Reseller'];
            oppRecordType = RT.id;          
        }
        return oppRecordType;
    }
    


//  Return the matching the Key Record (with customer & partner acct IDs)
//  --------------------------------------------------------------------
    private Partner_Key_Account__c findMatchingKey(){
        
        Partner_Key_Account__c key = new Partner_Key_Account__c();     
        try{
            key = [Select Account__c, Partner__c, Key__c from Partner_Key_Account__c
                    where Key__c =: InputKeyValue];
        } catch (Exception x){
                                DebugLogger.write('DealRegController', 'findMatchingKey().x = '+x); 
                                
                                } //  when no match is found


        DebugLogger.write('DealRegController', 'findMatchingKey().key = '+key);  

        return key;

    }

//  Return the matching contact record, or the new contact being created
//  --------------------------------------------------------------------
    private Contact matchingContact(){        
        try{
            Contact match = [select id, AccountId from Contact where email =: c.email];
            contactexist = null != match.id;
            c.id = match.id;
            c.AccountId = match.accountid;

            DebugLogger.write('DealRegController', 'matchingContact().match = '+match);  


        } catch (Exception x){
                                DebugLogger.write('DealRegController', 'matchingContact().x = '+x); 
                                
                                }        //  when no match is found just return the original        
        
        return c;
    }

//  Upsert Contact
//  --------------------------------------------------------------------    
    private Contact upsertContact(){

    //  Set the ID to the matched account if we didnt match the contact
        if(matchingContact().AccountId == null)
            matchingContact().AccountId = upsertAccount().Id;
    
    //  Upsert the contact   
        try                 {   upsert c;                                   }   
        catch (Exception x) {   apexpages.addmessages(x); 
                                DebugLogger.write('DealRegController', 'upsertContact().c = '+c);  
                                DebugLogger.write('DealRegController', 'upsertContact().x = '+x);    
                                return null;    }
        
        return c;

    }

//  Return account that matches the key, or existing contact, or create
//  --------------------------------------------------------------------       
    public Account upsertAccount;
    private Account upsertAccount(){

        if(upsertAccount == null){

        //  Try to find the account based on the key
            if(findMatchingKey().account__c != null){
                upsertAccount = new Account(id = findMatchingKey().account__c);                            
            
        //  Try to find the account based on the contact match
            } else if(matchingContact().AccountId != null) {
                upsertAccount = new Account(id = matchingContact().AccountId);

        //  Use the new account data entered to create an account
            } else {
                upsertAccount = a.Clone(false,true);
                try                 {   insert upsertAccount;       }
                catch (Exception x) {   apexpages.addmessages(x);   
                                        DebugLogger.write('DealRegController', 'upsertAccount().upsertAccount = '+upsertAccount);  
                                        DebugLogger.write('DealRegController', 'upsertAccount().x = '+x);
                
                }
            }
                                
        }
        return upsertAccount;
    }

//  Insert the Oppty
//  --------------------------------------------------------------------       
    private Opportunity insertOppty(){

        opp.RecordTypeId = OppRecordType();
        opp.AccountId = upsertAccount().id;
        opp.StageName = 'Received / Prospecting';
        opp.Name = a.Name + ' - ' + 'Reseller' + ' - ' + getOpportunityPartnerName();
        opp.Customer_Contact_First_Name__c = c.FirstName;
        opp.Customer_Contact_Last_Name__c = c.LastName;
        opp.Customer_Contact_Phone__c = c.Phone;
        opp.Customer_Contact_Title__c = c.Title;
        opp.Customer_Contact_Street_Address__c = a.BillingStreet;
        opp.Customer_Contact_City__c = a.BillingCity;
        opp.Customer_Contact_State__c = a.BillingPostalCode;
        opp.Customer_Contact_State__c = a.BillingState;
        opp.Customer_Contact_Zip_Code__c = a.BillingPostalCode;
        opp.Customer_Contact_Country__c = a.BillingCountry;
        opp.Customer_Contact_Email__c = c.Email;
        opp.Registration_ID__c = 'BOX'+''+ Datetime.now().format('MMyy') +''+String.valueof(Math.random()).replace('0.','').substring(0,6);
        opp.Box_Partner_Account__c = getOpportunityPartnerId();
        opp.Partner_External_ID__c = inputkeyvalue;
        opp.Deal_Registration_Source__c = getDrs().Deal_Reg_Source__c;
        opp.Contact_Method__c = getDrs().Contact_Method_Most_Recent__c;        
        opp.Distributor__c = getOpportunityPartnerDistributor();
        opp.Contact_Method_Most_Recent__c = 'Reseller Program';
        opp.Partner_Inputted_Customer_Company__c = a.Name;
        opp.Payment_Method__c='Other';
        opp.Deal_Registration_Source__c='Reseller';
            
        if(opp.CurrencyIsoCode == 'USD')conversion = getDRS().USD_Conversion__c;
        if(opp.CurrencyIsoCode == 'JPY')conversion = getDRS().YEN_Conversion__c;
        if(opp.CurrencyIsoCode == 'GBP')conversion = getDRS().GBP_Conversion__c;
        if(opp.CurrencyIsoCode == 'EUR')conversion = getDRS().Euro_Conversion__c;
        if(conversion == null)          conversion = getDRS().USD_Conversion__c;
                
        convertProductType();
        if((opp.CurrencyIsoCode == 'USD'||opp.CurrencyIsoCode == null) && opp.Amount > 10000)opp.Amount = 10000;
        if(opp.CurrencyIsoCode == 'JPY' && opp.Amount > 980300)opp.Amount = 980300;
        if(opp.CurrencyIsoCode == 'EUR' && opp.Amount > 8400)opp.Amount = 8400;
        if(opp.CurrencyIsoCode == 'GBP' && opp.Amount > 7200)opp.Amount = 7200;
        
        opp.Channel_Amount__c = opp.Amount;
    
    //  Set the partner user if not guest user        
        if(userinfo.getUserType() != 'Guest'){
            opp.Box_Partner_User__c = Userinfo.getUserId();
            
        } else if(Userinfo.getUserType() == 'Guest'){ 
            opp.Box_Entity__c='Box, Inc';
            opp.Non_Box_BSA__c=true;    
            opp.Box_Partner_User__c =System.Label.AT_TPartner;
        }
               
    //  Insert the oppty
        try{   
            insert opp;     
        } catch (Exception x) {   
                                            
            DebugLogger.write('DealRegController', 'upsertContact().opp = '+opp);  
            DebugLogger.write('DealRegController', 'upsertContact().x = '+x); 
            
            
        //  If record type is not avail, change the language of the message
            if(x.getMessage().contains('List has no rows for assignment to SObject'))
                x.setMessage('No Record Type with name Partner_Deal_Reg_Reseller');            
            else apexpages.addmessages(x);            
        }

        return opp;

    }
    
    private void convertProductType(){

        if(opp.Box_Products__c == 'Legacy - Business'){
            opp.Amount = opp.Seats_Sold__c * (getDrs().Legacy_Business_Account_licenses__c * conversion);
            opp.Retail_ARR__c = opp.Seats_Sold__c * (getDrs().Legacy_Business_Account_licenses__c * conversion);
            opp.Channel_Amount__c = opp.Seats_Sold__c * (getDrs().Legacy_Business_Account_licenses__c * conversion);
            opp.Account_Type_Sold__c = opp.Box_Products__c;
            } else
        if(opp.Box_Products__c == 'Legacy - Enterprise'){
            opp.Amount = opp.Seats_Sold__c * (getDrs().Legacy_Enterprise_Account_licenses__c * conversion);
            opp.Retail_ARR__c =  opp.Seats_Sold__c * (getDrs().Legacy_Enterprise_Account_licenses__c * conversion);
            opp.Channel_Amount__c =  opp.Seats_Sold__c * (getDrs().Legacy_Enterprise_Account_licenses__c * conversion);
            opp.Account_Type_Sold__c = opp.Box_Products__c;
            } else 
        if(opp.Box_Products__c == 'Legacy – Enterprise – Unlimited Ext Users'){
            opp.Amount = opp.Seats_Sold__c * (getDrs().Legacy_Enterprise_Unlimited_licenses__c * conversion);
            opp.Retail_ARR__c = opp.Seats_Sold__c * (getDrs().Legacy_Enterprise_Unlimited_licenses__c * conversion);
            opp.Channel_Amount__c = opp.Seats_Sold__c * (getDrs().Legacy_Enterprise_Unlimited_licenses__c * conversion);
            opp.Account_Type_Sold__c = opp.Box_Products__c;
            } else 
        if(opp.Box_Products__c == 'Business Account licenses'){
            opp.Amount = opp.Seats_Sold__c * (getDrs().Business_Account_licenses__c * conversion);
            opp.Retail_ARR__c = opp.Seats_Sold__c * (getDrs().Business_Account_licenses__c * conversion);
            opp.Channel_Amount__c = opp.Seats_Sold__c * (getDrs().Business_Account_licenses__c * conversion);
            opp.Account_Type_Sold__c = 'Legacy - Business';
            } else
        if(opp.Box_Products__c == 'Enterprise Account licenses'){
            opp.Amount = opp.Seats_Sold__c * (getDrs().Enterprise_Account_licenses__c * conversion);
            opp.Retail_ARR__c =  opp.Seats_Sold__c * (getDrs().Enterprise_Account_licenses__c * conversion);
            opp.Channel_Amount__c =  opp.Seats_Sold__c * (getDrs().Enterprise_Account_licenses__c * conversion);
            opp.Account_Type_Sold__c = 'Legacy - Enterprise';
            } else 
        if(opp.Box_Products__c == 'Enterprise Unlimited Account licenses'){
            opp.Amount = opp.Seats_Sold__c * (getDrs().Enterprise_Unlimited_Account_licenses__c * conversion);
            opp.Retail_ARR__c = opp.Seats_Sold__c * (getDrs().Enterprise_Unlimited_Account_licenses__c * conversion);
            opp.Channel_Amount__c = opp.Seats_Sold__c * (getDrs().Enterprise_Unlimited_Account_licenses__c * conversion);
            opp.Account_Type_Sold__c = 'Legacy – Enterprise – Unlimited Ext Users';
            } else 
        if(opp.Box_Products__c == 'Business Plus'){
            opp.Amount = (getDrs().Buisness_Plus__c * conversion) * opp.Seats_Sold__c ;
            opp.Retail_ARR__c = (getDrs().Buisness_Plus__c * conversion) * opp.Seats_Sold__c ;
            opp.Channel_Amount__c = (getDrs().Buisness_Plus__c * conversion) * opp.Seats_Sold__c ;
            opp.Account_Type_Sold__c = opp.Box_Products__c;
            } else 
        if(opp.Box_Products__c == 'Business'){
            opp.Amount = opp.Seats_Sold__c * (getDrs().Business__c * conversion);
            opp.Retail_ARR__c = opp.Seats_Sold__c * (getDrs().Business__c * conversion);
            opp.Channel_Amount__c = opp.Seats_Sold__c * (getDrs().Business__c * conversion);
            opp.Account_Type_Sold__c = opp.Box_Products__c;
            } else 
        if(opp.Box_Products__c == 'Elite'){
            opp.Amount = opp.Seats_Sold__c * (getDrs().Elite__c * conversion);
            opp.Retail_ARR__c = opp.Seats_Sold__c * (getDrs().Elite__c * conversion);
            opp.Channel_Amount__c = opp.Seats_Sold__c * (getDrs().Elite__c * conversion);
            opp.Account_Type_Sold__c = opp.Box_Products__c;
            } else 
        if(opp.Box_Products__c == 'Enterprise'){
            opp.Amount = opp.Seats_Sold__c * (getDrs().Enterprise__c * conversion);
            opp.Retail_ARR__c = opp.Seats_Sold__c * (getDrs().Enterprise__c * conversion);
            opp.Channel_Amount__c = opp.Seats_Sold__c * (getDrs().Enterprise__c * conversion);
            opp.Account_Type_Sold__c = opp.Box_Products__c;
        }

    }

//  Get the Custom setting values for Deal Reg User Type
//  --------------------------------------------------------------------

    private Deal_Reg_Custom_Setting__c getDrs(){
        string u = userinfo.getUserType();
        system.debug('UserType:::::::::::::::::::::::' + u);
        Deal_Reg_Custom_Setting__c drs = Deal_Reg_Custom_Setting__c.getInstance(u);
        return drs;
    }


    
    //  Return the logged in users account, or the partner key for unauth
//  --------------------------------------------------------------------   
    private String getOpportunityPartnerId(){

    //  Check the account on the user
        User u = [select AccountId from User where id =: UserInfo.getUserId()];

    //  Return the users account if its populated
        if(u.AccountId != null)return u.AccountId;

    //  Return null if a key value has not been entered
        if(InputKeyValue == null || InputKeyValue == '')return PartnerId;

    //  Return the partner key account otherwise
        else return  upsertPartnerKey().Partner__c; 
            

    }
    
       //  Return Partner Account Name
//  --------------------------------------------------------------------   
    private String getOpportunityPartnerName(){

    //  Check the account on the user
        if(getOpportunityPartnerId() == null) return null;
        
        Account aname = [select Name, Primary_Distributor__c from Account where id =: getOpportunityPartnerID()];

    //  Return the users account if its populated
        if(aname.Name != null)return aname.Name;

    //  Return the partner key account otherwise
        else return  null; 
            

    }
   
      //  Return Partner Account Distributor
//  --------------------------------------------------------------------   
    private String getOpportunityPartnerDistributor(){

    //  Check the account on the user
        if(getOpportunityPartnerId() == null) return null;
        
        Account aname = [select Name, Primary_Distributor__c from Account where id =: getOpportunityPartnerID()];

    //  Return the users account if its populated
        if(aname.Primary_Distributor__c != null)return aname.Primary_Distributor__c;

    //  Return the partner key account otherwise
        else return  null; 
            

    }

    
    



//  Insert a new Key
//  --------------------------------------------------------------------        
    Partner_Key_Account__c upsertPartnerKey;
    private Partner_Key_Account__c upsertPartnerKey(){

        if(upsertPartnerKey == null){
        
            upsertPartnerKey = new Partner_Key_Account__c(
                                                    Account__c = upsertAccount().id, 
                                                    Partner__c = partnerId,    //'001g00000047FdP', //TODO SET THIS AS THE PARTNER ACCT IN URL
                                                    Key__c = InputKeyValue
                                            );

            try                 {   upsert upsertPartnerKey key__c; }   
            catch (Exception x) {   apexpages.addmessages(x);       
            
                                    DebugLogger.write('DealRegController', 'upsertPartnerKey().upsertPartnerKey = '+upsertPartnerKey);  
                                    DebugLogger.write('DealRegController', 'upsertPartnerKey().x = '+x); 
            
                                }
        }
        return upsertPartnerKey;

    }

//  Create oppty team member
//  --------------------------------------------------------------------  
    private Boolean createOpptyTeamMember(){
        Boolean success = true;
        OpportunityTeamMember m = new OpportunityTeamMember(
                                        UserId = Userinfo.getUserId(),
                                        TeamMemberRole = 'Partner', 
                                        OpportunityId = opp.id
                                        
                                        );
        
        try                 {   insert m;                                   }
        catch (Exception x) {   apexpages.addmessages(x);   
            
                                DebugLogger.write('DealRegController', 'createOpptyTeamMember().m = '+m);  
                                DebugLogger.write('DealRegController', 'createOpptyTeamMember().x = '+x);
            
                                return false;   }

        return true;
    }

//  Create oppty share (must be called from trigger as well to maintain when owner changes)
//  --------------------------------------------------------------------  
    public static void createOpptyShares(Opportunity [] shareOpptys){
        if (shareOpptys == null || shareOpptys.isEmpty()) { // check for null or empty input
            System.debug('Null or empty input. shareOpptys: ' + shareOpptys);
            return;
        }
        // Create an oppty share for opportunities and box partner users
        List<OpportunityShare> shares = new List<OpportunityShare>{};
        for(Opportunity opp : shareOpptys){
            if (opp.Box_Partner_User__c != null) {
                shares.add(new OpportunityShare(
                        UserOrGroupId = opp.Box_Partner_User__c, 
                        OpportunityId = opp.id, 
                        OpportunityAccessLevel = 'Edit'));
            }
        }
        try {
             Boolean allOrNone = false;
            database.insert(shares,allOrNone);  //  Bypass errors when user is deactive  
        }
        catch (Exception e) {
            new LoggedException(e,'Issue inserting opportunity shares!','DealRegController');
        }
    }  


//  Submit
//  --------------------------------------------------------------------    
    public PageReference submit(){
    
    //  Check if CTN have existing BOX SOC’s
        if(typeCheck == true){
            opp.Opportunity_Type__c = 'Upsell';
        }
        else{
            opp.Opportunity_Type__c = 'New';
        }
        system.debug('Custom Region-----------'+a.Customer_Region__c);
        
    
    //Correct Customer Region and Channel rep
    if(a.Customer_Region__c == 'Africa' || a.Customer_Region__c == 'Europe - Benelux' || 
    a.Customer_Region__c == 'Europe - Eastern Europe' || a.Customer_Region__c == 'Europe - Nordics' || 
    a.Customer_Region__c == 'Israel' || a.Customer_Region__c == 'Middle East'){
        opp.Theater__c = 'EMEA';
        //opp.Sales_Rep_Channel_only__c = '00560000001xZLr';
        opp.Box_Entity__c='Box UK';
        
    }
    else if(a.Customer_Region__c == 'US - Alabama' || a.Customer_Region__c == 'US - Florida' || 
    a.Customer_Region__c == 'US - Georgia' || a.Customer_Region__c == 'US - Illinois' || 
    a.Customer_Region__c == 'US - Indiana' || a.Customer_Region__c == 'US - Iowa' || 
    a.Customer_Region__c == 'US - Kentucky' || a.Customer_Region__c == 'US - Michigan' || 
    a.Customer_Region__c == 'US - Minnesota' || a.Customer_Region__c == 'US - Nebraska' || 
    a.Customer_Region__c == 'US - North Dakota' || a.Customer_Region__c == 'US - Ohio' || 
    a.Customer_Region__c == 'US - South Dakota' || a.Customer_Region__c == 'US - Tennessee' || 
    a.Customer_Region__c == 'US - Wisconsin'){
        opp.Theater__c = 'NATAM';
        //opp.Sales_Rep_Channel_only__c = '00560000002sXjM';
        opp.Box_Entity__c='Box, Inc';
    }
    else if(a.Customer_Region__c == 'US - Connecticut' || a.Customer_Region__c == 'US - Delaware' || 
    a.Customer_Region__c == 'US - Maine' || a.Customer_Region__c == 'US - Maryland' || 
    a.Customer_Region__c == 'US - Massachusetts' || a.Customer_Region__c == 'US - New Hampshire' || 
    a.Customer_Region__c == 'US - New Jersey' || a.Customer_Region__c == 'US - New York' || 
    a.Customer_Region__c == 'US - North Carolina' || a.Customer_Region__c == 'US - Pennsylvania' || 
    a.Customer_Region__c == 'US - Rhode Island' || a.Customer_Region__c == 'US - South Carolina' || 
    a.Customer_Region__c == 'US - Vermont' || a.Customer_Region__c == 'US - Virginia' || 
    a.Customer_Region__c == 'US - Washington' || a.Customer_Region__c == 'US - West Virginia' || 
    a.Customer_Region__c == 'Canada - Other'){
        opp.Theater__c = 'NATAM';
        //opp.Sales_Rep_Channel_only__c = '00560000001ui4T';
        opp.Partner_External_ID__c = a.Customer_Region__c;
        opp.Box_Entity__c='Box, Inc';
    }
    else if(a.Customer_Region__c == 'US - Louisiana' || a.Customer_Region__c == 'US - Mississippi' || 
    a.Customer_Region__c == 'US - New Mexico' || a.Customer_Region__c == 'US - Oklahoma' || 
    a.Customer_Region__c == 'US - Texas' || a.Customer_Region__c == 'Latin America'
    || a.Customer_Region__c == 'US - Colorado' ||  a.Customer_Region__c == 'US - Kansas'
    || a.Customer_Region__c == 'US - Missouri'){
        opp.Theater__c = 'NATAM';
        //opp.Sales_Rep_Channel_only__c = '00560000001voZR';
        opp.Box_Entity__c='Box, Inc';
    }
    else if(a.Customer_Region__c == 'US - Alaska' || a.Customer_Region__c == 'US - Arizona' || 
    a.Customer_Region__c == 'US - California'  || 
    a.Customer_Region__c == 'US - Hawaii' || a.Customer_Region__c == 'US - Idaho' || 
    a.Customer_Region__c == 'US - Montana' || a.Customer_Region__c == 'US - Nevada' || 
    a.Customer_Region__c == 'US - Oregon' || a.Customer_Region__c == 'US - Utah' || 
    a.Customer_Region__c == 'US - Wyoming' || a.Customer_Region__c == 'Canada - BC,AB,SK'){
        opp.Theater__c = 'NATAM';
        //opp.Sales_Rep_Channel_only__c = '00560000001HE1H';
        opp.Box_Entity__c='Box, Inc';
    }
    else if(a.Customer_Region__c == 'Asia/APAC-Other' || a.Customer_Region__c == 'Australia'){
        opp.Theater__c = 'APAC';
        //opp.Sales_Rep_Channel_only__c = '00560000001HE1H';
        opp.Box_Entity__c='Box UK';
    }
    else if(a.Customer_Region__c == 'Europe - Austria' || a.Customer_Region__c == 'Europe - Germany' || 
    a.Customer_Region__c == 'Europe - Liechtenstein' || a.Customer_Region__c == 'Europe - Switzerland'){
        opp.Theater__c = 'EMEA';
        //opp.Sales_Rep_Channel_only__c = '00560000001wpG4';
        opp.Box_Entity__c='Box UK';
    }
    else if(a.Customer_Region__c == 'Europe - Ireland' || a.Customer_Region__c == 'Europe - United Kingdom'){
        opp.Theater__c = 'EMEA';
        //opp.Sales_Rep_Channel_only__c = '00560000001vUZB';
        opp.Box_Entity__c='Box UK';
    }
    else if(a.Customer_Region__c == 'Europe - France' || a.Customer_Region__c == 'Europe - Greece' || 
    a.Customer_Region__c == 'Europe - Iberian Peninsula' || a.Customer_Region__c == 'Europe - Italy'){
        opp.Theater__c = 'EMEA';
        //opp.Sales_Rep_Channel_only__c = '00560000001whhW';
        opp.Box_Entity__c='Box UK';
    }
    /*else if(a.Customer_Region__c == 'Not Listed/Other'){
        opp.Sales_Rep_Channel_only__c = '00560000001FyKa&srKp';
    }*/
    else if(a.Customer_Region__c == 'Asia/Japan'){
        opp.Theater__c = 'APAC';
        //opp.Sales_Rep_Channel_only__c = '00560000001v0md';
        opp.Box_Entity__c='Box UK';
    }
    system.debug('Theater-----------'+opp.Theater__c);
                
    //  Create a savepoint in case of error so we can rollback     
        Savepoint sp = Database.setSavepoint();

    //  Valdiate close date
        if (opp.CloseDate < Date.Today()) {
            opp.CloseDate.addError('Estimated Order Date cannot occur in the past.');
            return null;
        }
    //  Validate that # Estimate Lic are > 0    
       
         if(opp.Seats_Sold__c != null && opp.Seats_Sold__c < 1){              
               opp.Seats_Sold__c.addError('You must proivde a number greater than 0 for Estimated Licenses.');               
               return null;                
        }
                    

    //  First upsert the account based on the KEY
        if(upsertAccount().id == null){    
            return resetRecords(sp);                        
        }

    //  If Partner ID is provided (UnAuth Version)   
        if(InputKeyValue != null && InputKeyValue != ''){

        //  If Key Exists
            if( findMatchingKey() != null && findMatchingKey().Account__c != null){

            //  Display Error if Key account does not match contact account
                if(matchingContact().id != null && (matchingContact().accountid != findMatchingKey().Account__c)){
                    Apexpages.addmessage(
                        new ApexPages.Message(Apexpages.severity.fatal,'The contact provided does not match the Customer CTN # provided.  Please, update the contact information or the CTN #')
                    );
                                
                    return resetRecords(sp);    
                }               

            }

        //  Associate existng key with the partner or create a new key
            if(upsertPartnerKey()==null){   
                return resetRecords(sp);    
            }           

        }

    //  Upsert the contact
        if(upsertContact() == null){    
             return resetRecords(sp);           
        }
        
        system.debug(contactexist);
        contactexistWithActiveOpps = false;
        
        // if a matching contact is found
        if( contactexist == true ){
            // get all campaignmembers active responses for that contact
            List<CampaignMember> activeResponsesForExistingContact = FCRM.FCR_SupportAPI.GetActiveAndOpActiveResponses( new List<Id>{ c.Id } );
            if( activeResponsesForExistingContact!=null && !activeResponsesForExistingContact.isEmpty() ){
                // if an active response is found , check if the active response is associated to an opportunity
                List<CampaignMember> activeResponsesCMsWithOpp = [ SELECT Id, FCRM__FCR_Admin_Opportunity_Status__c 
                                                            FROM CampaignMember 
                                                            WHERE Id IN :activeResponsesForExistingContact AND FCRM__FCR_Admin_Opportunity_Status__c = 1];
                if( activeResponsesCMsWithOpp != null && !activeResponsesCMsWithOpp.isEmpty() ){
                    contactexistWithActiveOpps = true;
                    // set the passive mode in contect.
                    if( !FCRM.FCR_SupportAPI.IsPassiveMode( ) ){
                        FCRM.FCR_SupportAPI.SetPassiveModeInContext();
                    }
                }
            }
        }
        
    //  Insert the oppty
        if(insertOppty().id == null){
            return resetRecords(sp);    
          
        }

    //  Insert a team member / share if its not the site guest
        if(userInfo.getUserType() != 'Guest'){
        //  createOpptyShares(new List<Opportunity>{opp});           
            if(!createOpptyTeamMember()){
                    return resetRecords(sp);    

            }
        }
              
        
    //  Find the campaign mapping definition
        Campaign_Map_Definition__c CMD = Campaign_Map_Definition__c.getInstance('Primary'); 
        
    //  See if the matching field is populated
        String querystr = 'select '+CMD.Object_Field__c+' from '+CMD.Object_Type__c+' where id = \''+upsertAccount.id+'\'';
        sObject so;         
        try{
            so =  database.query(querystr);
        } catch (Exception x){
            apexpages.addmessages(x);  
            DebugLogger.write('DealRegController', 'submit().so = '+so);  
            DebugLogger.write('DealRegController', 'submit().x = '+x);
            return resetRecords(sp);    
        }
        
    //  If there is no campaign ID on the account, assign the default, else assign the account campaign
        String assigncampaign;
        if(so.get(CMD.object_Field__c) == null || so.get(CMD.object_Field__c) == ''){
            assigncampaign = cmd.Default_Campaign__c;
        } else {
             assigncampaign = (String)so.get(CMD.object_Field__c);                          
        }

    //  Enter managed package code                      
        FCRM.FCR_SupportAPI.TreatNextCampaignAssociationsAsResponsePrompts();
        CampaignMember CM = new CampaignMember();
        cm.ContactId = c.id;
        cm.CampaignId = assigncampaign;
        //cm.Contact_Method_Most_Recent__c = 'Reseller Program';
        
        // Modified 4/26 by Dan Appleman for FCRM
        // This change allows any user to create cascades on repeat responses
        cm.FCRM__FCR_Admin_Response_Control__c = 2;

    //  Insert oppty contact role
        insert opptyContactRole();

    //  Insert campaing member & Oppty contact role              
        try{
            system.debug(cm.FCRM__FCR_Admin_Response_Control__c);
            insert cm;          
                        
        }catch (Exception x){
        //  Dont throw error if contact is already part of the campaign
            if(!x.getMessage().contains('This entity is already a member of this campaign')){
                apexpages.addmessages(x);
                DebugLogger.write('DealRegController', 'submit().cm = '+cm);  
                DebugLogger.write('DealRegController', 'submit().x = '+x);
                return resetRecords(sp);    
            }
        }   
        
        system.debug([SELECT FCRM__FCR_Admin_Response_Control__c from CampaignMember where iD =: cm.Id] );
        if( contactexistWithActiveOpps ){
            
            cm.FCRM__FCR_Opportunity__c = opp.Id;
            cm.FCRM__FCR_Admin_Response_Control__c = 8;
            cm.Open_Status_Date__c = Datetime.now();
            update cm;
        }
        system.debug([SELECT FCRM__FCR_Admin_Response_Control__c from CampaignMember where iD =: cm.Id] );
    //  Enter managed package code
        List<Opportunity> opps = new List<Opportunity>{};
        opps.add(opp);
        // Don't do the association again if we've just done it using the Admin_Response_Control - DA 6/26/13
        if(!contactexistWithActiveOpps) FCRM.FCR_SupportAPI.AssociateOpportunitiesToResponses(opps);            
        system.debug([SELECT FCRM__FCR_Admin_Response_Control__c from CampaignMember where iD =: cm.Id] );
        return null;
        
    }

//  Oppty Contact Role
//  --------------------------------------------------------------------    
    private OpportunityContactRole opptyContactRole(){
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = c.id;
        ocr.IsPrimary = true;
        ocr.Role = 'Primary';
        ocr.OpportunityId = opp.id; 
               
        DebugLogger.write('DealRegController', 'opptyContactRole().ocr = '+ocr); 
        return ocr;
    }


//  Submit (Logged in User Version)
//  --------------------------------------------------------------------
    public PageReference authUserSubmit(){
        return submit(); 
    }
    
    
//  Clear out the record IDs on rollback
//  --------------------------------------------------------------------    
    private PageReference resetRecords(Savepoint sp){
        Database.rollback(sp);
        a = a.clone(false);
        c = c.clone(false);
        opp = opp.clone(false);     
        return null;
    }
    

/*  TEST COVERAGE
    -----------------------------------------------------------------------------------------------------   */
    
    @isTest private static void testDealRegController(){
        
    //  Insert a campaign
        Campaign c = new Campaign();
        c.Name = 'test';    
        insert c;
        
    //  Insert Custom Settings
        Campaign_Map_Definition__c  CMD = new Campaign_Map_Definition__c(
            name = 'Primary',
            Object_Type__c = 'Account',
            Object_Field__c = 'Campaign__c',
            Default_Campaign__c = c.id      
        );
        insert CMD;
    
    //  Grab the site guest user (cant create one)
        User u = [select id from user where UserType = 'Guest' and isactive = true limit 1];               

    //  Insert an account & contact
        Account a = new Account(name='tester');
        insert a;
        Contact con = new Contact(email = 'test@test.com', lastname = 'test', accountid = a.id);
        insert con;
   //   Insert Custom setting for Deal Reg Custom Settings
        Deal_Reg_Custom_Setting__c drs = new Deal_Reg_Custom_Setting__c(name='Guest', Deal_Reg_Source__c = 'unauth', Contact_Method_Most_Recent__c = 'unauth', 
                                            Legacy_Business_Account_licenses__c = 10,   Legacy_Enterprise_Account_licenses__c = 20, 
                                            Legacy_Enterprise_Unlimited_licenses__c = 50, USD_Conversion__c = 1, Business_Account_licenses__c = 1,
                                            Enterprise_Account_licenses__c = 1, Enterprise_Unlimited_Account_licenses__c = 1, Buisness_Plus__c = 1,
                                            Business__c = 1, Elite__c = 1, Enterprise__c = 1);
        insert drs;
        
         Deal_Reg_Custom_Setting__c drs2 = new Deal_Reg_Custom_Setting__c(name='Standard', Deal_Reg_Source__c = 'unauth', Contact_Method_Most_Recent__c = 'unauth', 
                                            Legacy_Business_Account_licenses__c = 10,   Legacy_Enterprise_Account_licenses__c = 20, 
                                            Legacy_Enterprise_Unlimited_licenses__c = 50);
        insert drs2;

    //  Set the page
        Pagereference p = Page.DealRegStep1;
        test.setCurrentPage(p);
        p.getParameters().put('partnerid','3980955827');


    //  Const
        DealRegController d;        
        
        system.runas(u){
        
            d = new DealRegController();
            
            d.isPrimarySalesRep = 'Yes';
            d.populateSalesRepInfo();

            d.populateisATT();

        //  Submit with no data     
            d.step1();
            
        //  Populate Acct data  
            d.a.Name = 'tester';        
            d.step2();
            
        //  Fail ATTUID Length
            d.opp.ATTUID__c = '12345';
            d.step2();
            
        //  Fail CTN validation
            d.c.FirstName = 'test';
            d.c.LastName = 'test';      
            d.a.Current_AT_T_Customer__c = 'Yes';   
            d.c.Email = 'test@test.com';     
            d.step3();
    
        //  Fail CTN length validation              
            d.InputKeyValue = '123';        
            d.step3();        
            
        //  succeed CTN len
            d.InputKeyValue = '1234567890';        
            d.step3();
            
       //   Fail Billing Zip Code
            d.a.BillingPostalCode = 'asd';
            d.step3();
            
       //   Succeed Billing Zip Code
            d.a.BillingPostalCode = '95608';
            d.step3();
            
        //  Populate Opp Data
            d.opp.Partner_Submitter_Name__c = 'test name';            
            
        //  Submit with bad close date
            d.opp.CloseDate = system.today() - 10;
            d.submit();

        //  Submit with bad seats sold
            d.opp.CloseDate = system.today();
            d.opp.Seats_Sold__c = 0; 
            d.submit();

        //  submit with good data
            d.opp.Seats_Sold__c = 1;
            d.submit();


        }
    
    //  Test a CTN duplicate fail
        d = new DealRegController();
        
        system.runAs(u){
       
        //  Attempt to submit an opp for the same CTN
            d.a.Name = 'tester';
            d.c.LastName = 'testlast';
            d.InputKeyValue = '1234567890';
            d.opp.Partner_Submitter_Name__c = 'test';
            d.opp.CloseDate = system.today();                 
            d.step3();
         
        } 
        
     //  Test no CTN #
        d = new DealRegController();
        
        system.runAs(u){
       
        //  Attempt to submit an opp for the same CTN
            d.a.Name = 'tester';
            d.InputKeyValue = '1234567899';
            d.c.LastName = 'testlast';
            d.c.Email = 'test@test.com';     
            d.opp.Partner_Submitter_Name__c = 'test';
            d.opp.CloseDate = system.today();
            d.opp.Partner_Submitter_Email__c= 'test@testd.com';                
            d.step3();
         
        }                                       
        
    //  Auth version
        d.userstep1();
        d.userstep2();
        d.authUserSubmit();
                
    //  Test Get cookie
        d.getCookie();

    //  Test convert prod type
        List<String> productTypes = new List<String>{'Legacy - Business', 'Legacy - Enterprise','Legacy – Enterprise – Unlimited Ext Users', 
                                                    'Business Account licenses', 'Enterprise Account licenses',
                                                    'Enterprise Unlimited Account licenses', 'Business Plus',
                                                    'Business','Elite', 'Enterprise'};

        system.runAs(u){
            d = new DealRegController();
            d.conversion = 1;
            d.opp.Seats_Sold__c = 1;
            for(string productType : productTypes){
                d.opp.Box_Products__c = productType;
                d.convertProductType();
            }
        }


    }
    
    

}