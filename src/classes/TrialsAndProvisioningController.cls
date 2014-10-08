/***************************************************************************************************************************************
        Class:                  TrialsAndProvisioningController
        
        Description:    Search for a deal registration & redirect the user to the provisioning page
        
        Author:                 Jeremy Henson                                   
         
        Revision Hist:  J.Henson, 12/12/2012, Initial Version
****************************************************************************************************************************************/
public class TrialsAndProvisioningController {

        public String searchATT         {get; set;}
        public String searchDeal        {get; set;}
        public String Prevstage        {get; set;}
        public Opportunity opp          {get; set;}
        public OpportunityContactRole OCR {get; set;}
        
        
        public PageReference FindDeal(){
                
                // Checking required fields in the controller because otherwise error messages are too verbose
                if (searchATT == null || searchATT.length() == 0) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ATTUID is required.'));
                    return null;
                }
        
                if (searchDeal == null || searchDeal.length() == 0) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Deal Registration ID is required.'));
                    return null;                    
                }
        
                if (searchATT != null && searchAtt.length() != 6) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ATTUID must be six characters.'));
                    return null;                    
                }
                
                try{
                        opp = [select id,stagename, accountid, name, Registration_ID__c, Account.Reseller_ID__c, Account.Name, (Select ContactId, Contact.Email From OpportunityContactRoles where IsPrimary = true) 
                                                from opportunity where Registration_ID__c =: searchDeal and ATTUID__c =: searchATT limit 1];
                             Prevstage=opp.stagename;                                            
                
                } catch (Exception x){
                        apexpages.addmessage(new Apexpages.Message(Apexpages.severity.info,'No results found'));
                        return null;
                }                       
                
                if(opp.OpportunityContactRoles.size() != 0){                    
                        ocr = opp.opportunitycontactroles[0];
                } else {
                        apexpages.addmessage(new Apexpages.Message(Apexpages.severity.info,'No primary contact on deal registration. Please contact support.'));
                }
                
                
                return Provision();
                
                
        }

        public pageReference Provision(){
                
                Pagereference redirect = Page.Box_TenantCreator;
                redirect.getParameters().put('contactid',ocr.contactid);
                redirect.getParameters().put('regid',opp.Registration_ID__c);
                redirect.getParameters().put('oppid',opp.id);
                redirect.getParameters().put('showheader','false');
                redirect.getParameters().put('CF00N60000002Jm96_lkid',opp.AccountId);
                redirect.getParameters().put('redirect','false');
                
                String name = ocr.Contact.Email;
                /*if (opp.Account.Reseller_ID__c != null) {
                    name += ' ' + opp.Account.Reseller_ID__c;
                }*/
                name = opp.Account.Name;
                
                if(Prevstage == 'Received / Prospecting'){
                	
                	opp.StageName='Discovery / Trial';
                	
                }
                
                if(opp.StageName == 'Discovery / Trial'){
                Update opp;
                }
                
                redirect.getParameters().put('name', name);
                
                redirect.setRedirect(true);
                return redirect;
                
        }
        
        public PageReference previous() {
            return Page.partnerportal;
        }        
        
/*      TEST COVERAGE
        -----------------------------------------------------------------------------------------------------   */
        
        @isTest private static void testTrialsAndProvisioningController(){
                
        //      Create an oppty
                Account a = new Account(Name = 'test account');
                insert a;
                Opportunity opp = new Opportunity(Name = 'test', ATTUID__c = '012345', Registration_ID__c = '012345', stagename = 'New', CloseDate = System.today(), Box_Partner_Account__c = a.Id);
                insert opp;

        //      Create a contact
                Contact c = new Contact(lastname = 'test');
                insert c;
                
        //      Insert a contact role
                OpportunityContactRole OCR = new OpportunityContactRole(OpportunityId = opp.id, ContactId = c.id, IsPrimary = true);
                insert OCR;             
                
        //      Const
                TrialsAndProvisioningController t = new TrialsAndProvisioningController();
                                                
        //      Set vars (good search)
                t.searchATT = '012345';
                t.searchDeal = '012345';

        //      Search
                t.FindDeal();
                        
        //      Set vars (no results)
                t.searchATT = 'BOGUS';
                t.searchDeal = 'BOGUS';

        //      Search
                t.FindDeal();   
                
        //      Set vars (null results)
                t.searchATT = null;
                t.searchDeal = null;
                
        //      Search
        
                t.FindDeal();
                
        //      Set vars (Deal Null results)
                t.searchATT = '12345';
                t.searchDeal = null;
                
        //      Search
        
                t.FindDeal();
                
         //      Set vars (Att != 6 results)
                t.searchATT = '123456';
                t.searchDeal = null;
                
        //      Search
        
                t.FindDeal();
                
       //      Set vars (Att != 6 results)
                t.searchATT = null;
                t.searchDeal = '123456';
                
        //      Search
        
                t.FindDeal();

                
                
        }
                        
        

}