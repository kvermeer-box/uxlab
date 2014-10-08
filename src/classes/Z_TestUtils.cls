@isTest
public class Z_TestUtils {
	
    public static User ADMIN_USER
    {
        get{
            if ( null == ADMIN_USER ){
                ADMIN_USER = [SELECT Id FROM User WHERE Profile.Name = 'Box: System Administrator' AND IsActive=true LIMIT 1 ];
            }
            return ADMIN_USER;
        }
        private set;
    }
    
    static Integer currentZuoraId {
        get {
            if(currentZuoraId == null) {
                currentZuoraId = 1;
            } else {
                currentZuoraId++;
            }

            return currentZuoraId;
        }

        private set;
    }


    static Sobject adminIffyInsert(Sobject record, Boolean doInsert) {
        if(doInsert) {
            System.runAs(ADMIN_USER) {
                insert record;
            }
        }

        return record;
    }

    static Sobject iffyInsert(Sobject record, Boolean doInsert) {
        if(doInsert) {
            insert record;
        }

        return record;
    }

    static List<Sobject> iffyInsert(List<Sobject> records, Boolean doInsert) {
        if(doInsert) {
            insert records;
        }

        return records;
    }
 
    public static Opportunity createOpportunity(Id accountId, Boolean doInsert) {
        Opportunity opp = new Opportunity(
            Name = 'Liara',
            AccountId = accountId,
            CloseDate = Date.today().addMonths(1),
            StageName = 'Discovery / Trial'
        );

        return (Opportunity)iffyInsert(opp, doInsert);
    }

    public static Account createAccount(Boolean doInsert) {
        Account acc = new Account(
            Name = 'Z-Quote Account'
        );

        return (Account)iffyInsert(acc, doInsert);
    }

    public static Zuora__CustomerAccount__c createZAccount(String billingAccountId, Id accountId, Boolean doInsert) {
        Zuora__CustomerAccount__c acc = new Zuora__CustomerAccount__c(
            Name = 'Mordin',
            Zuora__External_Id__c = billingAccountId,
            Zuora__Account__c = accountId
        );

        return (Zuora__CustomerAccount__c)iffyInsert(acc, doInsert);
    }

    public static zqu__ZProduct__c createZProduct(Boolean doInsert) {
        String zuoraId = String.valueOf(currentZuoraId);

        zqu__ZProduct__c product = new zqu__zProduct__c (
            zqu__SKU__c = zuoraId,
            zqu__ZuoraId__c = zuoraId,
            zqu__Deleted__c = false,
            zqu__EffectiveStartDate__c = Date.Today().addMonths(-1),
            zqu__EffectiveEndDate__c = Date.Today().addMonths(1)
        );

        return (zqu__ZProduct__c)iffyInsert(product, doInsert);
    }

    public static zqu__ZProduct__c createZProduct(String sku, String zuoraId, Boolean doInsert) {
        zqu__ZProduct__c product = new zqu__zProduct__c (
            zqu__SKU__c = sku,
            zqu__ZuoraId__c = String.valueOf(currentZuoraId),
            zqu__Deleted__c = false,
            zqu__EffectiveStartDate__c = Date.Today().addMonths(-1),
            zqu__EffectiveEndDate__c = Date.Today().addMonths(1)
        );

        return (zqu__ZProduct__c)iffyInsert(product, doInsert);
    }

    public static List<zqu__ZProduct__c> createZProducts(Integer n, Boolean doInsert) {
        List<zqu__ZProduct__c> products = new List<zqu__ZProduct__c>();

        for(Integer i = 0; i < n; i++) {
            products.add(createZProduct(false));
        }

        return (List<zqu__ZProduct__c>)iffyInsert(products, doInsert);
    }

    public static zqu__ProductRatePlan__c createZProductRatePlan(Id zproductId, Boolean doInsert) {
        String zuoraId = String.valueOf(currentZuoraId);

        zqu__ProductRatePlan__c zproductRatePlan = new zqu__ProductRatePlan__c (
            Name = 'Rate Plan '+zuoraId,
            zqu__ZProduct__c = zproductId,
            zqu__ZuoraId__c = zuoraId,
            zqu__EffectiveStartDate__c = Date.Today().addMonths(-1),
            zqu__EffectiveEndDate__c = Date.Today().addMonths(1),
            zqu__Deleted__c = false
        );

        return (zqu__ProductRatePlan__c)iffyInsert(zproductRatePlan, doInsert);
    }

    public static zqu__ProductRatePlan__c createZProductRatePlan(Id zproductId, String zuoraId, Boolean doInsert) {
        zqu__ProductRatePlan__c zproductRatePlan = new zqu__ProductRatePlan__c (
            zqu__ZProduct__c = zproductId,
            zqu__ZuoraId__c = String.valueOf(currentZuoraId),
            zqu__Deleted__c = false,
            zqu__EffectiveStartDate__c = Date.Today().addMonths(-1),
            zqu__EffectiveEndDate__c = Date.Today().addMonths(1)
        );

        return (zqu__ProductRatePlan__c)iffyInsert(zproductRatePlan, doInsert);
    }

    public static List<zqu__ProductRatePlan__c> createProductRatePlans(List<zqu__ZProduct__c> products, Boolean doInsert) {
        List<zqu__ProductRatePlan__c> productRatePlans = new List<zqu__ProductRatePlan__c>();

        for(zqu__ZProduct__c product : products) {
            productRatePlans.add(createZProductRatePlan(product.Id, false));
        }

        return (List<zqu__ProductRatePlan__c>)iffyInsert(productRatePlans, doInsert);
    }

    public static zqu__ProductRatePlanCharge__c createZProductRatePlanCharge(Id productRatePlanId, Boolean doInsert) {
        zqu__ProductRatePlanCharge__c zproductRatePlanCharge = new zqu__ProductRatePlanCharge__c (
              zqu__ProductRatePlan__c = productRatePlanId
            , zqu__ZuoraId__c = String.valueOf(currentZuoraId)
        );

        return (zqu__ProductRatePlanCharge__c)iffyInsert(zproductRatePlanCharge, doInsert);
    }

    public static zqu__ProductRatePlanCharge__c createZProductRatePlanCharge(Id productRatePlanId, String name, Boolean doInsert) {
        zqu__ProductRatePlanCharge__c zproductRatePlanCharge = new zqu__ProductRatePlanCharge__c (
              Name = name
            , zqu__ProductRatePlan__c = productRatePlanId
            , zqu__ZuoraId__c = String.valueOf(currentZuoraId)
            , zqu__Model__c = 'model'
            , zqu__Type__c = 'type'
            , zqu__UOM__c = 'uom'
            , zqu__DefaultQuantity__c = 1
            , zqu__MinQuantity__c = 0
            , zqu__MaxQuantity__c = 500
            , zqu__RecurringPeriod__c = 'Monthly'
            , zqu__Deleted__c = false
        );

        return (zqu__ProductRatePlanCharge__c)iffyInsert(zproductRatePlanCharge, doInsert);
    }

    public static List<zqu__ProductRatePlanCharge__c> createProductRatePlanCharges(List<zqu__ProductRatePlan__c> productRatePlans, Boolean doInsert) {
        List<zqu__ProductRatePlanCharge__c> productRatePlanCharges = new List<zqu__ProductRatePlanCharge__c>();

        for(zqu__ProductRatePlan__c productRatePlan : productRatePlans) {
            productRatePlanCharges.add(createZProductRatePlanCharge(productRatePlan.Id, false));
        }

        return (List<zqu__ProductRatePlanCharge__c>)iffyInsert(productRatePlanCharges, doInsert);
    }

    public static zqu__ProductRatePlanChargeTier__c createProductRatePlanChargeTier(Id zproductRatePlanChargeId, String quoteCurrency, Boolean doInsert) {
        zqu__ProductRatePlanChargeTier__c tier = new zqu__ProductRatePlanChargeTier__c(
           zqu__ProductRatePlanCharge__c = zproductRatePlanChargeId,
           zqu__Currency__c = quoteCurrency,
           zqu__Deleted__c = false,
           zqu__ZuoraId__c = String.valueOf(currentZuoraId)
        );

        return(zqu__ProductRatePlanChargeTier__c)iffyInsert(tier, doInsert);
    }

    public static zqu__ProductRatePlanChargeTier__c createProductRatePlanChargeTier(Id zproductRatePlanChargeId, Boolean doInsert) {
        zqu__ProductRatePlanChargeTier__c tier = new zqu__ProductRatePlanChargeTier__c(
           zqu__ProductRatePlanCharge__c = zproductRatePlanChargeId,
           zqu__Currency__c = 'USD',
           zqu__Deleted__c = false,
           zqu__ZuoraId__c = String.valueOf(currentZuoraId),
           zqu__PriceFormat__c = 'Flat Fee',
           zqu__Tier__c = 1,
           zqu__StartingUnit__c = 0,
           zqu__EndingUnit__c = 1
        );

        return(zqu__ProductRatePlanChargeTier__c)iffyInsert(tier, doInsert);
    }

  	private static integer contactKey = 100000;

    public static Contact createContact(Boolean doInsert, Id accountId) {
    	
    	contactKey++;
    	
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = String.valueOf(contactKey),
            Email = String.valueOf(contactKey) + '@box.com.test',
            AccountId = accountId,
            MailingStreet = '123 Main St.', 
            MailingState = 'CA', 
            MailingPostalCode = '94087', 
            MailingCountry = 'United States', 
            MailingCity = 'Sunnyvale' 
        );

        return (Contact)iffyInsert(contact, doInsert);
    }

    public static zqu__Quote__c createZQuote(Id opportunityId, Boolean doInsert) {
        Id accountId = [SELECT AccountId FROM Opportunity WHERE Id = :opportunityId].AccountId;
        Id contactId = createContact(true, accountId).Id;

        zqu__Quote__c zquote = new zqu__Quote__c(
            zqu__Opportunity__c = opportunityId,
            zqu__StartDate__c = Date.Today(),
            zqu__Is_Charge_Expired__c = false,
            zqu__Currency__c = 'USD',
            Payment_Frequency__c = 'Monthly',
            zqu__SoldToContact__c = contactId,
            zqu__BillToContact__c = contactId
        );

        return (zqu__Quote__c)iffyInsert(zquote, doInsert);
    }

    public static zqu__QuoteCharge__c createZQuoteCharge(Id quoteId, Id productRatePlanChargeId, Boolean doInsert) {
        zqu__QuoteCharge__c quoteCharge = new zqu__QuoteCharge__c(
            zqu__Quote__c = quoteId,
            zqu__ProductRatePlanCharge__c = productRatePlanChargeId,
            zqu__Currency__c = 'USD',
            zqu__Total__c = 100
        );

        return (zqu__QuoteCharge__c)iffyInsert(quoteCharge, doInsert);
    }




    public static Zuora__Subscription__c createZSubscription(Id accountId, Boolean doInsert) {
        Zuora__Subscription__c subscription = new Zuora__Subscription__c(
            Zuora__Account__c = accountId
        );

        return (Zuora__Subscription__c)iffyInsert(subscription, doInsert);
    }

    public static Zuora__SubscriptionProductCharge__c createZSubscriptionProductCharge(Id subscriptionId,  String productSKU, Id accountId, Boolean doInsert) {
        Zuora__SubscriptionProductCharge__c subscription = new Zuora__SubscriptionProductCharge__c(
            Zuora__Subscription__c  = subscriptionId,
            Zuora__ProductSKU__c = productSKU,
            Zuora__Account__c = accountId
        );

        return (Zuora__SubscriptionProductCharge__c)iffyInsert(subscription, doInsert);
    }

    public static Product_Conflict__c createProductConflict(Id product1, Id product2, Boolean doInsert) {
        Product_Conflict__c conflict = new Product_Conflict__c(
            Product__c = product1,
            Incompatible_Product__c = product2
        );

        return (Product_Conflict__c)iffyInsert(conflict, doInsert);
    }

    public static Product_Conflict__c createProductConflictForRatePlans(Id rateplan1, Id rateplan2, Boolean doInsert) {
        Product_Conflict__c conflict = new Product_Conflict__c(
            Product_Rate_Plan__c = rateplan1,
            Incompatible_Product_Rate_Plan__c = rateplan2
        );

        return (Product_Conflict__c)iffyInsert(conflict, doInsert);
    }

    public static Product_Dependency__c createProductDependency(Id parent, Id child, Boolean doInsert) {
        Product_Dependency__c dependency = new Product_Dependency__c(
           Product__c = parent,
           Dependent_Product__c = child
        );

        return (Product_Dependency__c)iffyInsert(dependency, doInsert);
    }

    public static Product_Pairing__c createProductPairing(Id productRatePlanId, Id productRatePlanToAddId, Boolean doInsert) {
        Product_Pairing__c productPairing = new Product_Pairing__c(
           Product_Rate_Plan__c = productRatePlanId,
           Product_Rate_Plan_To_Add__c = productRatePlanToAddId,
           Maximum_Total__c = 100,
           Minimum_Total__c = 10
        );

        return (Product_Pairing__c)iffyInsert(productPairing, doInsert);
    }

    public static Product_Group_Member__c createProductGroupMember(Id productId, Id productGroupId, Boolean doInsert) {
        Product_Group_Member__c member = new Product_Group_Member__c(
            Product__c = productId,
            Product_Group__c = productGroupId
        );

        return (Product_Group_Member__c)iffyInsert(member, doInsert);
    }

    public static Product_Group__c createProductGroup(Boolean doInsert) {
        Product_Group__c pgroup = new Product_Group__c(
            Name = 'Product Group'
        );

        return (Product_Group__c)iffyInsert(pgroup, doInsert);
    }

    public static Product_Rule__c createProductRule(Id ratePlanId, String errorMessage, Integer max, Integer min, Id productGroupId, Boolean doInsert) {
        Product_Rule__c rule = new Product_Rule__c(
           Product_Rate_Plan__c = ratePlanId,
           Error_Message__c = errorMessage,
           Max_Quantity__c = max,
           Min_Quantity__c = min,
           Product_Group__c = productGroupId
        );

        return (Product_Rule__c)iffyInsert(rule, doInsert);
    }

    public static Pricing_Rule__c createPricingRule(Id productId, Id autoSetProductId, Integer percent, Boolean doInsert) {
        Pricing_Rule__c rule = new Pricing_Rule__c(
           Product__c = productId,
           Auto_Set_Product__c = autoSetProductId,
           Percent__c = percent
        );

        return (Pricing_Rule__c)iffyInsert(rule, doInsert);
    }

    public static zqu__QuoteAmendment__c createQuoteAmendment(Id quoteId, Boolean doInsert) {
        zqu__QuoteAmendment__c quoteAmendment = new zqu__QuoteAmendment__c();
        quoteAmendment.zqu__Description__c = 'test amendment';
        quoteAmendment.zqu__TotalAmount__c = 150;
        quoteAmendment.zqu__Type__c = 'NewProduct';
        quoteAmendment.zqu__Quote__c = quoteId;
        return (zqu__QuoteAmendment__c)iffyInsert(quoteAmendment, doInsert);
    }

    public static zqu__QuoteRatePlan__c createQuoteRatePlan(Id quoteId, Id quoteAmendmentId, String productRateZuoraId, String subscriptionRateZuoraId, Boolean doInsert) {
        zqu__QuoteRatePlan__c quoteRatePlan = new zqu__QuoteRatePlan__c(
            Name = 'quote rate plan',
            zqu__Quote__c = quoteId,
            zqu__ProductRatePlanZuoraId__c = productRateZuoraId,
            zqu__SubscriptionRatePlanZuoraId__c =subscriptionRateZuoraId,
            zqu__QuoteAmendment__c = quoteAmendmentId
        );

        return (zqu__QuoteRatePlan__c)iffyInsert(quoteRatePlan, doInsert);
    }

    public static Amount_Threshold__c createAmountThreshold(Boolean doInsert) {
 
        Amount_Threshold__c threshold = new Amount_Threshold__c(
           Name = 'Premier Support Minimum USD',
           Threshold_Amount__c = 1,
           Program__c = 'Z-Quote',
           Currency_Code__c = 'USD' 
        );

        return (Amount_Threshold__c)adminIffyInsert(threshold, doInsert);
    }


    public static Amount_Threshold__c createCheckWireMinimumAmountThreshold(Boolean doInsert) {
 
        Amount_Threshold__c threshold = new Amount_Threshold__c(
           Name = 'Check Wire Minimum USD',
           Threshold_Amount__c = 1,
           Program__c = 'Z-Quote',
           Currency_Code__c = 'USD' 
        );

        return (Amount_Threshold__c)adminIffyInsert(threshold, doInsert);
    }

    public static List<SObject> replicate(SObject x, Integer n) {
        List<SObject> xs = new List<SObject>();
        for(Integer i = 0; i < n; i++) {
            xs.add(x.clone(false, true));
        }

        return xs;
    }

	/* 
   	Build the quote charge summary based on the charge
 	*/
	public static zqu__QuoteChargeSummary__c createQuoteChargeSummary(zqu.zCharge charge, String quoteRatePlanId, String oppId){
		
   		zqu__QuoteChargeSummary__c quoteChargeSummary = new zqu__QuoteChargeSummary__c();
   		
   		quoteChargeSummary.Name = charge.Name;
	   	quoteChargeSummary.zqu__QuoteRatePlan__c = quoteRatePlanId;
	   	
	   	if(charge.EFFECTIVE_PRICE!='-'){
	   		quoteChargeSummary.zqu__EffectivePrice__c = Decimal.valueOf(charge.EFFECTIVE_PRICE);
	   	}
	   	
	   	if(charge.TOTAL!='-'){
	   		quoteChargeSummary.zqu__TotalPrice__c = Decimal.valueOf(charge.TOTAL);
	   	}
	   	if(charge.DISCOUNT!='-'){
	   		quoteChargeSummary.zqu__Discount__c = Decimal.valueOf(charge.DISCOUNT);
	   	}
	   	quoteChargeSummary.zqu__Quantity__c = charge.QUANTITY == '-' ? null : Decimal.valueOf(charge.QUANTITY);
	   	if(charge.Model == 'Flat Fee Pricing'){
	    	quoteChargeSummary.zqu__Quantity__c = -1; 
	   	}
   		quoteChargeSummary.zqu__Model__c = charge.MODEL;
   		quoteChargeSummary.zqu__Opportunity__c = oppId;
   		quoteChargeSummary.zqu__Period__c = charge.PERIOD == '-' ? null : charge.PERIOD;
   		quoteChargeSummary.zqu__Type__c = charge.CHARGE_TYPE;
   		quoteChargeSummary.zqu__UOM__c = charge.UNIT_OF_MEASURE;
   		if(charge.LIST_TOTAL!='-'){
   			quoteChargeSummary.zqu__ListTotal__c = Decimal.valueOf(charge.LIST_TOTAL);
   		}
   		if(charge.LIST_TOTAL!='-'){
   			quoteChargeSummary.zqu__ListPrice__c = Decimal.valueOf(charge.LIST_PRICE);
   		}
   		
   		if(charge.TOTAL!='-'){
   			quoteChargeSummary.zqu__TCV__c = Decimal.valueOf(charge.TOTAL);
   		}
   		quoteChargeSummary.zqu__MRR__c = 0;
   		 
		insert quoteChargeSummary;
		
   		return quoteChargeSummary;
 	}

    public static zqu__QuoteRatePlanCharge__c createQuoteRatePlanCharge(Id quoteId, zqu__QuoteRatePlan__c quoteRatePlan) {
        
        zqu__QuoteRatePlanCharge__c quoteRatePlanCharge = new zqu__QuoteRatePlanCharge__c(
            Name = 'quote rate plan charge',
            zqu__QuoteRatePlan__c = quoteRatePlan.Id
        );

        insert quoteRatePlanCharge;

        return quoteRatePlanCharge;
    }
     
}