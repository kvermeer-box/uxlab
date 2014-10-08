public class Box_TestDealRegGenerator {

    public String partner_id {get; set;}
    public String account_id {get; set;}
    
    public Account partner {get; set;}
    public Account account {get; set;}
    public Opportunity opportunity {get; set;}
    
    public Box_TestDealRegGenerator() {}
    
    public Box_TestDealRegGenerator(String accountId) {
        this.account_id = accountId;
    }
            
    public void generateDealReg() {
    
        partner = null;
        account = null;
        opportunity = null;
    
        // findOrCreatePartner();
        findOrCreateAccount();
        findOrCreateOpportunity();
    
    }
    
    public String generateDealRegRest() {    
        generateDealReg();
        return account_id;    
    }
    
    private Integer generateRandomNumber() {
        return (Math.random() * 1000000000).intValue();
    }
    
    public void clear() {
        // partner_id = null;
        account_id = null;
        partner = null;
        account = null;
        opportunity = null;
    }  
    
    private void findOrCreatePartner() {
        try {
            partner = Box_AccountDAO.getAccountFromKey(Box_AccountDAO.getParamKeys().get('resellerid'), partner_id, true);
        } catch (Exception e) {
            System.debug('Cannot find partner, creating...');
            // Create partner
            if (partner_id == null || partner_id.equals('')) {
                partner_id = String.valueOf(generateRandomNumber());
            }
            Account a = new Account();
            a.Name = partner_id ;
            a.Reseller_ID__c = Integer.valueOf(partner_id);
            a.RecordTypeId = '012J0000000CofX';
            a.Partner_Price_Per_Seat_Business__c = 15.00;
            a.Partner_Price_Per_Seat_Enterprise__c = 25.00;
            a.Partner_Price_Per_Seat_Unlimited__c = 35.00;                        
            a.Partner_Order_Length__c = 'One year';
            insert a;            
            partner = a;
        }    
    }
    
    private void findOrCreateAccount() {
        try {
            account = Box_AccountDAO.getAccountFromKey(Box_AccountDAO.getParamKeys().get('externalaccountid'), account_id, false);
        } catch (Exception e) {
            System.debug('Cannot find account, creating...');        
            // Create account
            if (account_id == null || account_id.equals('')) {
                account_id = String.valueOf(generateRandomNumber());
            } 
            Account a = new Account();
            a.Name = account_id;
            a.RecordTypeId = '012600000009TjS';
            insert a;            
            
            Box_AccountPartnerKeyFactory.upsertPartnerKey(account_id, a.Id);
            account = a;
        }
    }
    
    private void findOrCreateOpportunity() {
        try {
            opportunity = Box_OpportunityDAO.getOpportunityFromKey(Box_OpportunityDAO.getParamKeys().get('externalaccountid'), account_id);
        } catch (Exception e) {
            System.debug('Cannot find opportunity, creating...');        
            
            Integer randomNum = Math.round(Math.random() * 10000000);
            
            // Create contact
            Contact c = new Contact();
            c.FirstName = 'Contact';
            c.LastName = account_id;
            c.AccountId = account.Id;
            c.Contact_Status__c = 'Pending';
            c.Email = randomNum + '@' + randomNum + '.com';
            insert c;
            
            // Create opp
            Opportunity o = new Opportunity();
            o.AccountId = account.Id;
            o.Name = 'Deal Reg Opportunity ' + account_id;
            o.ForecastCategoryName = 'Omitted';
            o.StageName = 'Prospecting';
            o.Amount = 100;
            o.RecordTypeId = Box_CustomSettings.getOpportunityPartnerRecordTypeId();
            o.Deal_Reg_Approval_Status__c = 'Approved';
            o.Approval_Stage__c = 'Approved';
            o.CloseDate = Date.today();
            o.Retail_ARR__c = 0;
            o.Payment_Method__c = 'Credit Card';
            o.Contact_Method__c = 'Event';
            insert o;
            
            // Opportunity contact role
            OpportunityContactRole ocr = new OpportunityContactRole();
            ocr.ContactId = c.Id;
            ocr.OpportunityId = o.Id;
            ocr.IsPrimary = true;
            insert ocr;
            
            opportunity = o;
        }
    }

}