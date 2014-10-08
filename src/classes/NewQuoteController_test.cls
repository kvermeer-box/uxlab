/**
* Class: NewQuoteController_test
*
*/

@isTest
private class NewQuoteController_test {
    
    // seeAllData used to avoid "Please upload Zuora WSDL at first"
    @isTest(seeAllData=true)
    static void constructorBasicTest() {
        TestFactory.prepareProductCatalog(TestFactory.rateplannames);

        Account acc = TestFactory.makeAccount();
        Opportunity opp = TestFactory.makeOpportunity(acc);
        ZQU__Quote__c quote = new ZQU__Quote__c(Name = 'New ZQuote', ZQU__Opportunity__c = opp.Id);

        // New 
        ApexPages.currentPage().getParameters().put('quotetype', 'New');
        ApexPages.currentPage().getParameters().put('oppid', opp.Id);
        ApexPages.StandardController controller = new ApexPages.StandardController(quote);
        NewQuoteController quoteController = new NewQuoteController(controller);

        // Amend
        Zuora__Subscription__c subscription = Z_TestUtils.createZSubscription(acc.Id, true);
        ApexPages.currentPage().getParameters().put('billingaccountId', acc.Id);
        ApexPages.currentPage().getParameters().put('existsubscriptionid', subscription.Id);
        ApexPages.currentPage().getParameters().put('quotetype', 'Amend');

        NewQuoteController amendQuoteController = new NewQuoteController(controller);

        // Renew
        ApexPages.currentPage().getParameters().put('quotetype', 'Renew');

        NewQuoteController renewQuoteController = new NewQuoteController(controller);
    }

    // seeAllData used to avoid "Please upload Zuora WSDL at first"
    @isTest(seeAllData=true)
    static void saveTest() {
        TestFactory.prepareProductCatalog(TestFactory.rateplannames);

        Account acc = TestFactory.makeAccount();
        Opportunity opp = TestFactory.makeOpportunity(acc);
        ZQU__Quote__c quote = new ZQU__Quote__c(Name = 'New ZQuote', ZQU__Opportunity__c = opp.Id);
        ApexPages.StandardController controller = new ApexPages.StandardController(quote);

        // New 
        ApexPages.currentPage().getParameters().put('quotetype', 'New');
        ApexPages.currentPage().getParameters().put('oppid', opp.Id);
        NewQuoteController quoteController = new NewQuoteController(controller);

        quoteController.save();      

        // Amend
        Zuora__Subscription__c subscription = Z_TestUtils.createZSubscription(acc.Id, true);
        ApexPages.currentPage().getParameters().put('billingaccountId', acc.Id);
        ApexPages.currentPage().getParameters().put('existsubscriptionid', subscription.Id);
        ApexPages.currentPage().getParameters().put('quotetype', 'Amend');

        NewQuoteController amendQuoteController = new NewQuoteController(controller);

        amendQuoteController.save();

        // Renew
        ApexPages.currentPage().getParameters().put('quotetype', 'Renew');

        NewQuoteController renewQuoteController = new NewQuoteController(controller);

        renewQuoteController.save();

        // init quote
        quoteController.initQuote();
        amendQuoteController.initQuote();
        
        renewQuoteController.initQuote();

        // update quote
        quoteController.updateQuote();

        // cancel quote
        quoteController.cancel();
        
        quoteController.translateBillingPeriod(null);
        quoteController.translateBillingPeriod('24');

        quoteController.getBillingPeriod(subscription);
        quoteController.getBillingPeriod(null);

        quoteController.setDealType();
        quote.Deal_Type__c = 'ELA';
        quoteController.setDealType();

        NewQuoteController.translatePaymentMethod('BankTransfer');
        NewQuoteController.translatePaymentMethod('CreditCard');
        NewQuoteController.translatePaymentMethod('CreditCardReferenceTransaction');
        NewQuoteController.translatePaymentMethod('DebitCard');
        NewQuoteController.translatePaymentMethod('WireTransfer');
        NewQuoteController.translatePaymentMethod('ELSE');
        NewQuoteController.translatePaymentMethod(null);
         
    }

}