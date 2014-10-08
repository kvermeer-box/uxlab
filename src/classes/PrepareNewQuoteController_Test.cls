@isTest
private class PrepareNewQuoteController_Test {

    static Opportunity opportunity;

    static void setup() {
        Account account = Z_TestUtils.createAccount(true);
        opportunity = Z_TestUtils.createOpportunity(account.Id, true);
    }

    @isTest(seeAllData=true)
    static void testNewAccount() {

        setup();

        Test.startTest();

            ApexPages.StandardController stdController = new ApexPages.StandardController(opportunity);
            
            PrepareNewQuoteController ctl = new PrepareNewQuoteController(stdController);

            PageReference loadPageReference = ctl.onload();

            ctl.selectedAccountType='new'; 

            PageReference selectAccountTypePageRef = ctl.onSelectAccountType();

            PageReference newQuotePageRef = ctl.goNewQuote();
            
            PageReference cancelPageRef = ctl.cancel();

        Test.stopTest();
 
    }

    @isTest(seeAllData=true)
    static void testExistingAccountAmend() {

        setup();

        Test.startTest();

            ApexPages.StandardController stdController = new ApexPages.StandardController(opportunity);

            PrepareNewQuoteController ctl = new PrepareNewQuoteController(stdController);

            PageReference loadPageReference = ctl.onload();

            ctl.selectedAccountType='existing';

            PageReference selectAccountTypePageRef = ctl.onSelectAccountType();

            PageReference selectAccountPageRef = ctl.onSelectAccount();

            PageReference newQuotePageRef = ctl.goNewQuote();

            PageReference cancelPageRef = ctl.cancel();

        Test.stopTest();
 
    }  

    @isTest(seeAllData=true)
    static void testExistingAccountRenew() {

        setup();

        Test.startTest();

            ApexPages.StandardController stdController = new ApexPages.StandardController(opportunity);
            
            PrepareNewQuoteController ctl = new PrepareNewQuoteController(stdController);

            PageReference loadPageReference = ctl.onload();

            ctl.selectedAccountType='existing';

            PageReference selectAccountTypePageRef = ctl.onSelectAccountType();

            PageReference selectAccountPageRef = ctl.onSelectAccount();

            PageReference newQuotePageRef = ctl.goNewQuote();

            PageReference cancelPageRef = ctl.cancel();

            ctl.onSelectSubscriptionType();

            if (ctl.billingAccountList == null) {
                ctl.billingAccountList = new List<SelectOption>();
            }
            SelectOption accso = new SelectOption ('val', 'label');
            ctl.billingAccountList.add(accso);
            ctl.selectedAccount = accso.getValue();
            ctl.onSelectAccount();


        Test.stopTest();
 
    }    
}