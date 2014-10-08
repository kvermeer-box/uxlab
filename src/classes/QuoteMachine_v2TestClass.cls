@isTest(seeAllData=true)
private class QuoteMachine_v2TestClass
{
    static testMethod void myUnitTest() {
    	
        // This is the setup
        Account a = new Account();
        a.BillingCountry = 'United States';
        a.Name = 'Account';
        insert a;
        
        Contact c = new Contact();
        c.LastName = 'Contact';
        c.AccountId = a.Id;
        insert c;
        
        Opportunity o = new Opportunity();
        o.Name = 'Opportunity';
        o.AccountId = a.Id;
        o.CloseDate = Date.today();
        o.StageName = 'Finalizing Closure';
        o.Amount = 100;
        insert o;
        
        Quote q1 = new Quote();
        q1.OpportunityId = o.Id;
        q1.RecordTypeId = '012600000009VgB';
        q1.Name = 'q1';
        q1.Order_Start_Date__c = Date.today();
        q1.Order_End_Date__c = Date.today().addYears(1);
        q1.Payment_Frequency__c = 'Monthly';
        q1.Payment_Method__c = 'Check';
        q1.Payment_Terms__c = 'Net 30';
        insert q1;
        
        QuoteLineItem qli1 = new QuoteLineItem();

        Test.startTest();
        
        // Initiate Add Products sequence in 3.. 2.. 1..
        Test.SetCurrentPageReference(New PageReference('Page.QuoteMachine_AddProductsPage'));
        PageReference pageRef = ApexPages.currentPage();        
        pageRef.getParameters().put('addTo', q1.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(qli1);        
        QuoteMachine_AddProductsController apc = new QuoteMachine_AddProductsController(sc);
                
        // Choosing a product - business
        apc.selectedProductId = '01u6000000574Dc';        
        apc.setProductId();
        apc.qli.Quantity = 1000;
        apc.specialSave();
        
        // Annoying stuff
        QuoteMachine_AddProductsController.getConsultingId();
        QuoteMachine_AddProductsController.getContentMigrationId();
        QuoteMachine_AddProductsController.getDefaultImage();
        QuoteMachine_AddProductsController.getPremierSupportId();
        apc.vforceRefreshProducts();
        apc.addBonusProducts();
        
        // Time to do upsells
        Opportunity o2 = new Opportunity();
        o2.Name = 'o2';
        o2.AccountId = a.Id;
        o2.CloseDate = Date.today().addDays(-1);
        o2.StageName = 'Closed Won';
        o2.Amount = 100;
        o2.Upsold_from_Account_Type__c = 'Business';
        o2.Account_Type_Sold__c = 'Business';
        o2.Fee_Frequency__c = 'Three Year Deal';
        insert o2;
                
        Quote q2 = new Quote();
        q2.Name = 'q2';
        q2.OpportunityId = o2.Id;
        q2.RecordTypeId = '012600000009VgG';        
        
        Test.SetCurrentPageReference(New PageReference('Page.QuoteMachine_UpsellCreatorController_v2'));
        PageReference pageRef2 = ApexPages.currentPage(); 
        pageRef2.getParameters().put('oppid', o.Id);
        pageRef2.getParameters().put('accid', a.Id);
        pageRef2.getParameters().put('recordType', '012600000009VgG');
        ApexPages.StandardController sc2 = new ApexPages.StandardController(q2);        
        QuoteMachine_UpsellCreatorController_v2 ucc = new QuoteMachine_UpsellCreatorController_v2(sc2);
        
        // Annoying stuff
        ucc.customSave(); 
        q2.Order_Start_Date__c = Date.today();
        ucc.customSave(); 
        q2.Order_End_Date__c = Date.today().addYears(3);
        ucc.customSave(); 
        q2.Payment_Frequency__c = 'Annual';
        ucc.customSave(); 
        q2.Payment_Method__c = 'Credit Card';
        ucc.customSave(); 
        q2.Payment_Terms__c = 'Due Upon Receipt';
        ucc.customSave(); 
        Test.stopTest();

        /*
        // Zuora data grabber        
        Zuora__Subscription__c s = new Zuora__Subscription__c();
        s.Zuora__Account__c = a.Id;
        s.Zuora__Status__c = 'Active';
        s.Name = 'Subscription';
        s.Zuora__TermStartDate__c = Date.today();
        s.Zuora__InitialTerm__c = '12 months';
        insert s;
        
        Zuora__SubscriptionProductCharge__c rp = new Zuora__SubscriptionProductCharge__c();
        rp.Name = 'Rate Plan';
        rp.Zuora__BillingPeriod__c = 'Three Years';
        rp.Zuora__ProductName__c = 'Enterprise';
        rp.Zuora__ProductSKU__c = 'SKU-00000404';
        rp.Zuora__Subscription__c = s.Id;
        insert rp;
            		          
		ApexPages.StandardController sc3 = new ApexPages.StandardController(q2);        
        QuoteMachine_UpsellCreatorController_v2 ucc2 = new QuoteMachine_UpsellCreatorController_v2(sc3); 
        */  
        
        // Now purchase contracts
        /*
        Purchase_Contract__c pc = new Purchase_Contract__c();
        pc.Account__c = a.Id;
        pc.Status__c = 'Active';
        pc.Payment_Frequency__c = '3-Years';
        insert pc;
        
        Purchase__c p = new Purchase__c();
        p.Purchase_Contract__c = pc.Id;
        p.Product__c = '01t60000001xreD';
        p.Product_Status__c = 'Active';
        p.Purchase_Start_Date__c = Date.today().addDays(-1);
        p.Purchase_End_Date__c = p.Purchase_Start_Date__c.addYears(3);
        p.Purchase_Type__c = 'New Agreement';
        p.Quantity__c = 1000;
        p.Revenue_Type__c = 'ARR';
        p.Sales_Price__c = 20.0;
        insert p;
        
        ApexPages.StandardController sc4 = new ApexPages.StandardController(q2);        
        QuoteMachine_UpsellCreatorController_v2 ucc3 = new QuoteMachine_UpsellCreatorController_v2(sc4);          
        
        // Now test the waterfall date trigger
        q1.Order_Start_Date__c = Date.today().addDays(10);
        update q1;

		// Now to test upsells in the add products page
		QuoteLineItem qli2 = new QuoteLineItem();
		
		insert q2;
        Test.SetCurrentPageReference(New PageReference('Page.QuoteMachine_AddProductsPage'));
        PageReference pageRef3 = ApexPages.currentPage();        
        pageRef3.getParameters().put('addTo', q2.Id);
        ApexPages.StandardController sc5 = new ApexPages.StandardController(qli2);        
        QuoteMachine_AddProductsController apc2 = new QuoteMachine_AddProductsController(sc5);    	
        
        // Choosing a product - business
        apc.selectedProductId = '01u6000000574Eu';        
        apc.setProductId();
        apc.qli.Percentage_of_Contract_Price__c = 10.0;
        apc.returnToQuote = true;
        apc.specialSave();
        */
    }
}