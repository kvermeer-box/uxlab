global class QuoteMachine_AddProductsController {

    public static QuoteMachineSettings__c settings = QuoteMachineSettings__c.getInstance('default');

    private static final String ACCOUNT_LICENSE_SUFFIX = ' Account license';
    public static final String BUSINESS_TIER = 'Business';
    public static final String BUSINESS_PLUS_TIER = 'Business Plus';
    public static final String ENTERPRISE_TIER = 'Enterprise';
    public static final String ENTERPRISE_UNLIMITED_TIER = 'Enterprise Unlimited';
    public static final String ELITE_TIER = 'Elite';

    public static final String SMART_START_PRODUCT_ID = '01t60000001xreS';
    public static final String QUICK_START_PRODUCT_ID = '01t60000001xreN';

    public static final String BUSINESS_LICENSES_PRODUCT_ID = '01t60000001xre8';
    public static final String BUSINESS_PLUS_LICENSES_PRODUCT_ID = '01t60000004JoeB';
    public static final String ENTERPRISE_LICENSES_PRODUCT_ID = '01t60000001xreD';
    public static final String ELITE_LICENSES_PRODUCT_ID = '01t60000004JoeC';
    public static final String UNLIMITED_LICENSES_PRODUCT_ID = '01t60000001xreI';
    public static final String CONSULTING_ID = '01t60000001xv4PAAQ';
    public static final String CONTENT_MIGRATION_ID = '01t60000001xreXAAQ';
    public static final String PREMIER_SUPPORT_ID = '01t60000001xrecAAA';
    public static final String ONE_TB_STORAGE_ID = '01t60000001xv0NAAQ';
    public static final String UNLIMITED_STORAGE_ID = '01t60000001xv0SAAQ';

    public static final String BOX_PLATFORM_BUILD_NAME = 'Box Platform - Build';
    public static final String BOX_PLATFORM_SCALE_NAME = 'Box Platform - Scale';
    public static final String BOX_PLATFORM_TRANSFORM_NAME = 'Box Platform - Transform';

    public static final String NEW_AGREEMENT_RECORD_TYPE_ID = '012600000009VgB';
    public static final String PRICEBOOK_SETTING_NAME_CURRENT = 'Current';
    public static Date LEGACY_DATE = Date.newInstance( 2013, 8, 21);

    public static final String VIEW_API_PRODUCT_FAMILY = 'View API';
    public static final String RECURRING_DOCUMENT_CONVERSIONS_LABEL = 'Monthly Document Conversions (1000\'s)';
    public static final String ONE_TIME_DOCUMENT_CONVERSIONS_LABEL = 'Document Conversions (1000\'s)';

    // Controller
    public Apexpages.StandardController controller;

    // Quote Line Item
    public QuoteLineItem qli {get; set;}
    public Double listPrice {get; set;}
    public Double annualLicensePriceOverride {get; set;}

    // Quote
    public Quote q {get; set;}

    // Pricebook Entry
    public List<PricebookEntry> productsList {get; set;}
    public List<PricebookEntry> viewAPIProductList {get; set;}
    public PricebookEntry selectedPriceBookEntry {get; set;}
    public String selectedProductId {get; set;}
    public Integer freebieProductsListSize {get; set;}
    
    // View API
    public Boolean isViewAPIProduct { get; set; }
    public String documentConversionLabel { get; set; }
    public Id viewAPIProductId { get; set; }
    public Boolean isBulkConversion { 
        get {
            // Check if current view API product == bulk conversion
            if (viewAPIProductId != null && 
                viewAPIProductId == CustomSettings.getViewAPISettings().Bulk_Conversion_Product_Id__c) {
                return true;
            }
            else {
                return false;
            }
        }
    }
    public Boolean isViewAPIPremierSupport { 
        get {
            // Check if current view API PRODUCT == premier support
            if (viewAPIProductId != null &&
                viewAPIProductId == CustomSettings.getViewAPISettings().View_API_Premier_Support_ID__c) {
                return true;
            }
            else {
                return false;
            }
        }
    }
    public Boolean isViewAPILicense { 
        get {
            // Its a license if its not the other View API products
            if (isViewAPIProduct != null && !isBulkConversion && !isViewAPIPremierSupport) {
                return true;
            }
            else {
                return false;
            }
        }
    }

    static Set<String> boxPlatformProductNames;
    public List<PricebookEntry> boxPlatformPbes {
        get {
            if(boxPlatformPbes == null) {
                boxPlatformPbes = [
                    SELECT Id, Name, Product2.Image_URL__c, Product2Id, Product2.Id, Product2.Name, UnitPrice, PriceBook2Id
                    FROM PricebookEntry
                    WHERE IsActive = true
                    AND Product2.Hide_from_Quote_Machine__c = false
                    AND Pricebook2.IsActive = true
                    AND PriceBook2Id = :priceBookId
                    AND CurrencyIsoCode = :q.CurrencyIsoCode
                    AND Product2.Name IN :boxPlatformProductNames
                    ORDER BY Product2.Display_Order__c ASC
                ];
            }

            return boxPlatformPbes;
        }

        private set;
    }

    @TestVisible Map<String, Id> nameToPlatformProductId {
        get {
            if(nameToPlatformProductId == null) {
                nameToPlatformProductId = new Map<String, Id>();

                for(PricebookEntry pricebookEntry : boxPlatformPbes) {
                    nameToPlatformProductId.put(pricebookEntry.Product2.Name, pricebookEntry.Id);
                }
            }

            return nameToPlatformProductId;
        }

        private set;
    }

    static {
        boxPlatformProductNames = new Set<String>
            { BOX_PLATFORM_BUILD_NAME
            , BOX_PLATFORM_SCALE_NAME
            , BOX_PLATFORM_TRANSFORM_NAME
            };
    }

    public Boolean lockSalesprice {
        get {
            return selectedProductId == nameToPlatformProductId.get(BOX_PLATFORM_BUILD_NAME);
        }
    }

    public Boolean showListPrice {
        get {
            Set<Id> blacklist = new Set<Id>
                { nameToPlatformProductId.get(BOX_PLATFORM_BUILD_NAME)
                , nameToPlatformProductId.get(BOX_PLATFORM_TRANSFORM_NAME)
                };

            return !blacklist.contains(selectedProductId);
        }
    }

    public Boolean isBoxPlatform {
        get {
            Set<Id> boxPlatformIds = new Set<Id>
                { nameToPlatformProductId.get(BOX_PLATFORM_BUILD_NAME)
                , nameToPlatformProductId.get(BOX_PLATFORM_SCALE_NAME)
                , nameToPlatformProductId.get(BOX_PLATFORM_TRANSFORM_NAME)
                };

            return boxPlatformIds.contains(selectedProductId);
        }
    }

    public Boolean showActionsPackage {
        get {
            return selectedProductId == nameToPlatformProductId.get(BOX_PLATFORM_SCALE_NAME);
        }
    }

    public Boolean showDiscount {
        get {
            Set<Id> blacklist = new Set<Id>
                { nameToPlatformProductId.get(BOX_PLATFORM_BUILD_NAME)
                , nameToPlatformProductId.get(BOX_PLATFORM_TRANSFORM_NAME)
                };

            return !blacklist.contains(selectedProductId);
        }
    }

    

    // Discount Double Check
    public Double discountedUnitPrice {get; set;}
    public Double subtotal {get; set;}
    public Double discount {get; set;}
    public Double total {get; set;}
    public Double annualSubtotal {get; set;}
    public Double annualTotal {get; set;}

    // Auto Association Products
    List<PricebookEntry> autoAssociateProducts {get; set;}
    @TestVisible Boolean ownsQuickSmartStart = false;

    // Misc
    public static String defaultImage = 'http://images.wikia.com/fantendo/images/0/0a/Pok%C3%A9monBulbasaur.png';
    public Boolean returnToQuote {get; set;}
    public Boolean isUpsell {get; set;}
    public Double originalListPrice {get; set;}
    public Boolean isEdit {get; set;}
    public Id initialProductId {get; set;}
    public Id pricebookId
    {
        get
        {
            if( pricebookId == NULL )
            {
                if( q.Pricebook2Id == NULL )
                {
                    priceBookId = q.CreatedDate < LEGACY_DATE ? Pricebook_Setting__c.getInstance( 'Legacy').Id__c
                                                             : Pricebook_Setting__c.getInstance( PRICEBOOK_SETTING_NAME_CURRENT ).Id__c;
                }
                else
                {
                    priceBookId = q.Pricebook2Id;
                }
            }
            return priceBookId;
        }
        private set;
    }

    public static String getDefaultImage() {
        return defaultImage;
    }

    public static String getConsultingId() {
        return CONSULTING_ID;
    }

    public static String getContentMigrationId() {
        return CONTENT_MIGRATION_ID;
    }

    public static String getPremierSupportId() {
        return PREMIER_SUPPORT_ID;
    }

    public QuoteMachine_AddProductsController(ApexPages.StandardController controller) {
        this.controller = controller;
        qli = (QuoteLineItem)controller.getRecord();
        getQuoteLineItemInfo();
        detectNewOrExistingRecord();
        q = getQuoteInfo();
        upsellOrNewAgreement();
        productsList = refreshProductsList();
        // Populate View API product list
        viewAPIProductList = getViewAPIProducts();
        freebieProductsListSize = calculateFreebieProductsListSize();
        isViewAPIProduct = false;
        if (isEdit) {
            setProductId();
        }
    }

    public void detectNewOrExistingRecord() {
        System.debug('Checking if this is a new or existing record...');
        if (qli.QuoteId == null) {
           qli.QuoteId = System.currentPageReference().getParameters().get('addTo');
           isEdit = false;
           System.debug('This is a new record.');
        } else {
           isEdit = true;
           System.debug('This is an existing record.');
        }
    }

    public void getQuoteLineItemInfo() {
        System.debug('Getting quote line item info...');
        if (qli.Id != null) {
            qli = [SELECT Id, QuoteId, PricebookEntryId, Quantity, PricebookEntry.Name, PricebookEntry.Id, PricebookEntry.UnitPrice, PricebookEntry.Product2.Id,
                            UnitPrice, Percentage_of_Contract_Price__c, List_Price__c, Number_of_GB__c, View_API_Sales_Price__c, Overage_Cost__c
                        FROM QuoteLineItem WHERE Id = :qli.Id];
        }
        selectedProductId = qli.PricebookEntryId;
    }

    public void upsellOrNewAgreement() {
        System.debug('Checking if this is an upsell...');
        isUpsell = false;
        if (q.RecordTypeId != NEW_AGREEMENT_RECORD_TYPE_ID) {
            System.debug('This is an upsell quote.');
            isUpsell = true;
            setUpgradeProduct();
        } else {
            System.debug('This is a new agreement quote.');
        }
    }

    public void setUpgradeProduct() {
        //TODO: make this a custom setting
        if (q.Purchase_Type__c != null && q.Purchase_Type__c.equals('Upgrade') && q.Business_Ent_Unlimited_Subtotal__c <= 0) {
            System.debug('Setting upgrade product...');
            if (q.Product_Tier__c == BUSINESS_TIER) {
                System.debug('Business Upgrade');
                selectedProductId = getPricebookEntryIdFromProduct(BUSINESS_LICENSES_PRODUCT_ID);
            } else if (q.Product_Tier__c == BUSINESS_PLUS_TIER ) {
                System.debug('Business Plus Upgrade');
                selectedProductId = getPricebookEntryIdFromProduct(BUSINESS_PLUS_LICENSES_PRODUCT_ID);
            } else if (q.Product_Tier__c == ENTERPRISE_TIER) {
                System.debug('Enterprise Upgrade');
                selectedProductId = getPricebookEntryIdFromProduct(ENTERPRISE_LICENSES_PRODUCT_ID);
            } else if (q.Product_Tier__c == ELITE_TIER) {
                System.debug('Elite Upgrade');
                selectedProductId = getPricebookEntryIdFromProduct(ELITE_LICENSES_PRODUCT_ID);
            } else if (q.Product_Tier__c == ENTERPRISE_UNLIMITED_TIER) {
                System.debug('Unlimited Upgrade');
                selectedProductId = getPricebookEntryIdFromProduct(UNLIMITED_LICENSES_PRODUCT_ID);
            }
            setProductId();
            qli.Quantity = q.Current_Seats__c;
        }
    }

    public Id getPricebookEntryIdFromProduct(String productId) {
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry
                                WHERE Product2.Id = :productId
                                    AND CurrencyIsoCode = :q.CurrencyIsoCode
                                    AND Pricebook2.IsActive = true
                                    AND Pricebook2Id = :priceBookId
                                    AND IsActive = true];
        return pbe.Id;
    }

    public PageReference vforceRefreshProducts() {
        update q;
        q = getQuoteInfo();
        setUpgradeProduct();
        productsList = refreshProductsList();
        selectedPriceBookEntry = null;
        freebieProductsListSize = calculateFreebieProductsListSize();
        return null;
    }

    public List<PricebookEntry> refreshProductsList() {
        System.debug('Refreshing products list...');
        String query = ' SELECT Id, Name, Product2.Image_URL__c, Product2Id, Product2.Id, Product2.Name, UnitPrice, PriceBook2Id FROM PricebookEntry ';
               query += ' WHERE IsActive = true ';
               query += ' AND Product2.Hide_from_Quote_Machine__c = false ';
               query += ' AND Pricebook2.IsActive = true ';
               query += ' AND PriceBook2Id = \'' + priceBookId + '\' ';
               query += ' AND CurrencyIsoCode = \'' + q.CurrencyIsoCode + '\' ';
               query += ' AND Product2.Family != \'' + VIEW_API_PRODUCT_FAMILY + '\' ';

        if ((q.Business_Ent_Unlimited_Subtotal__c == null || q.Business_Ent_Unlimited_Subtotal__c == 0) && q.RecordTypeId == NEW_AGREEMENT_RECORD_TYPE_ID) {
            query += ' AND Product2.Default_Product__c = true ';
        } else if (selectedProductId != null && (q.Purchase_Type__c != null && q.Purchase_Type__c.equals('Upgrade') && q.Business_Ent_Unlimited_Subtotal__c <= 0) || isEdit) {
            query += ' AND Id = \'' + selectedProductId + '\'';
        } else if (q.Business_Ent_Unlimited_Subtotal__c > 0 || q.Product_Tier__c != null) {
            query += ' AND (Product2.Default_Product__c = false ';
            query += ' OR Name LIKE \'%' + q.Product_Tier__c + ACCOUNT_LICENSE_SUFFIX + '%\' ) ';
        }

        // Storage products
        if (q.Product_Tier__c != null && q.Product_Tier__c.equals('Business')) {
            query += ' AND Product2.Id != \'' + UNLIMITED_STORAGE_ID + '\' ';
        } else {
            query += ' AND Product2.Id != \'' + ONE_TB_STORAGE_ID + '\' ';
        }

        // Prevent box platform products, we will handle them separately
        query += ' AND Product2.Name NOT IN :boxPlatformProductNames';

        query += ' ORDER BY Product2.Display_Order__c ASC';

        System.debug('Query: ' + query);
        List<PricebookEntry> newProductsList = Database.query(query);
        System.debug('New products list size: ' + newProductsList.size());

        List<PricebookEntry> cleanedProductsList = newProductsList;
        if (!isEdit) {
            cleanedProductsList = cleanProductsList(newProductsList);
        }
        return cleanedProductsList;
    }

    public List<PricebookEntry> getViewAPIProducts() {
        System.debug('Getting View API Products.');
        try {
            List<PricebookEntry> pricebookEntries = [SELECT Id, Name, Product2.Image_URL__c, Product2Id, Product2.Id,
                                                            Product2.Name, UnitPrice, PriceBook2Id
                                                       FROM PricebookEntry
                                                      WHERE IsActive = true
                                                        AND Product2.Hide_from_Quote_Machine__c = false
                                                        AND Pricebook2Id = :pricebookId
                                                        AND CurrencyIsoCode = :q.CurrencyIsoCode
                                                        AND Product2.Family = :VIEW_API_PRODUCT_FAMILY
                                                   ORDER BY Product2.Display_Order__c ASC];
            return pricebookEntries;
        } catch (Exception e) {
            new LoggedException(e, 'Trouble Querying for View API products', 'QuoteMachine_AddProductsPage', new List<ID> { q.Id });
            return new List<PricebookEntry>();
        }

    }

    public List<PricebookEntry> cleanProductsList(List<PricebookEntry> newProductsList) {
        // Remove dupes
        List<QuoteLineItem> qlis = q.QuoteLineItems;
        List<PricebookEntry> newProductsListNoDupes = new List<PricebookEntry>();
        for(PricebookEntry p : newProductsList) {
            Boolean isDupe = false;
            for (QuoteLineItem qli : qlis) {
                System.debug(qli.PricebookEntry.Name);

                // Quick/Smart Start check
                if (qli.PricebookEntry.Product2.Id == QUICK_START_PRODUCT_ID || qli.PricebookEntry.Product2.Id == SMART_START_PRODUCT_ID) {
                    ownsQuickSmartStart = true;
                }

                // This removes dupes
                if (qli.PricebookEntryId == p.Id) {
                    isDupe = true;
                    break;
                }
            }

            // Quick/Smart Start check
            if (ownsQuickSmartStart && (p.Product2.Id == QUICK_START_PRODUCT_ID || p.Product2.Id == SMART_START_PRODUCT_ID)) {
                isDupe = true;
            }
            if (isDupe) {
                continue;
            } else {
                newProductsListNoDupes.add(p);
            }
        }
        System.debug('New products list no dupes size: ' + newProductsListNoDupes.size());
        return newProductsListNoDupes;
    }

    public static List<Actions_Package__c> actionPackages {
        get {
            if(actionPackages == null) {
                actionPackages = [
                    SELECT Name, Start_Range__c, End_Range__c, Quantity__c
                    FROM Actions_Package__c
                    ORDER BY Start_Range__c
                ];
            }

            return actionPackages;
        }

        private set;
    }

    public static List<SelectOption> getActionPackageOptions() {
        List<SelectOption> selectOptions = new List<SelectOption>();

        for(Actions_Package__c actionPackage : actionPackages) {
            selectOptions.add(new SelectOption(formatQuantityForSelectOption(actionPackage.Quantity__c), actionPackage.Name));
        }

        return selectOptions;
    }

    static String formatQuantityForSelectOption(Decimal quantity) {
        return String.valueOf(quantity) + '.0';
    }

    public Integer calculateFreebieProductsListSize() {
        Integer size = 0;
        for (PricebookEntry p : productsList) {
            if (p.UnitPrice == 0) {
                size++;
            }
        }
        return size;
    }

    public Quote getQuoteInfo() {
        System.debug('Getting quote info...');
        List<Quote> quotes = [SELECT Id, Name, RecordTypeId, Pricebook2Id, Business_Ent_Unlimited_Subtotal__c, Business_Ent_Unlimited_Total__c, Purchase_Type__c, Current_Seats__c, Product_Tier__c, CreatedDate,
                                Opportunity.AccountId, Opportunity.Account.Box_Enterprise_ID__c, EnterpriseID__c, Payment_Frequency__c, Order_Start_Date__c, Order_End_Date__c, Pricebook2.Name, CurrencyIsoCode,
                                Business_Enterprise_Unlimited_Seats__c, Opportunity.Account.Total_Seats__c,
                                (SELECT PricebookEntryId, PricebookEntry.Name, PricebookEntry.Product2.Id FROM QuoteLineItems) currentProducts FROM Quote WHERE Id = :qli.QuoteId];
        return quotes[0];
    }

    public void setProductId() {
        System.debug('Selected Product Id: ' + this.selectedProductId);
        List<PricebookEntry> products = [SELECT Id, Name, Product2.Description, UnitPrice, Product2.Fixed_Price__c, Pricebook2Id,
                                                Product2.NumberOfRevenueInstallments, Product2.Percentage_of_Contract_Price__c,
                                                Product2.Default_Product__c, Product2.Name, Product2.Family, Product2.Id
                                            FROM PricebookEntry WHERE Id = :selectedProductId];

        selectedPriceBookEntry = products[0];
        qli.PricebookEntry = selectedPriceBookEntry;
        updateQuoteLineItemBackgroundFields();
        originalListPrice = qli.PricebookEntry.UnitPrice;
        if (!isEdit) {
            qli.PricebookEntryId = selectedPriceBookEntry.Id;
            clearFields();
            setDefaultFieldValues();
        }
        // Some View API config
        if (selectedPriceBookEntry.Product2.Family == VIEW_API_PRODUCT_FAMILY) {
            viewAPIProductId = selectedPriceBookEntry.Product2.Id;
            isViewAPIProduct = true;
            if (isBulkConversion) { // Bulk Conversion
                this.documentConversionLabel = ONE_TIME_DOCUMENT_CONVERSIONS_LABEL;
            }
            else if (isViewAPIPremierSupport) { // View API Premier Support
                // Do nothing right now
            }
            else { // License
                this.documentConversionLabel = RECURRING_DOCUMENT_CONVERSIONS_LABEL;
            }
        } else {
            isViewAPIProduct = false;
        }
        QuoteLineItemServices.setDefaultPrice(qli, selectedPriceBookEntry.Product2Id, getTotalSeats() );
    }

    public void setDefaultFieldValues() {
        System.debug('Setting default values...');
        listPrice = selectedPriceBookEntry.UnitPrice;
        if (!isEdit) {
            qli.UnitPrice = selectedPriceBookEntry.UnitPrice;
        }
        if (qli.PricebookEntry.Product2.Percentage_of_Contract_Price__c != null) {
            qli.UnitPrice = q.Business_Ent_Unlimited_Total__c * (qli.PricebookEntry.Product2.Percentage_of_Contract_Price__c / 100);
            qli.Percentage_of_Contract_Price__c = qli.PricebookEntry.Product2.Percentage_of_Contract_Price__c;
        }
    }

    public void calculateSubtotal() {
        System.debug('Calculating subtotal...');
        if (qli.Quantity == null) {
            qli.Quantity = 1;
        }

        qli.List_Price__c = selectedPriceBookEntry.UnitPrice;

        // Content Migration
        if (qli.Number_of_GB__c != null) {
            if (qli.Number_of_GB__c > 500) {
                subtotal = selectedPriceBookEntry.UnitPrice + qli.Number_of_GB__c - 500;
            } else {
                subtotal = selectedPriceBookEntry.UnitPrice;
            }
            qli.List_Price__c = subtotal;
        } else {
            subtotal = selectedPriceBookEntry.UnitPrice * qli.Quantity;
        }

        if (qli.PricebookEntry.Product2.NumberOfRevenueInstallments != null && qli.PricebookEntry.Product2.NumberOfRevenueInstallments == 12) {
            if (qli.PricebookEntry.Product2.Percentage_of_Contract_Price__c == null) {
                subtotal = ((subtotal * 12) / 365) * qli.Purchase_Start_Date__c.daysBetween(qli.Purchase_End_Date__c);
                annualSubtotal = (subtotal / qli.Purchase_Start_Date__c.daysBetween(qli.Purchase_End_Date__c)) * 365;
                qli.List_Price__c = selectedPriceBookEntry.UnitPrice;
            } else {
                subtotal = q.Business_Ent_Unlimited_Total__c * (qli.PricebookEntry.Product2.Percentage_of_Contract_Price__c / 100);
                qli.List_Price__c = subtotal;
            }
        }
    }

    void calculateTransformProductDetails() {
        qli.List_Price__c = qli.UnitPrice;
        qli.Discount__c = 0;
        qli.Quantity = 1;
    }

    public void calculateTotal() {
        if(selectedPriceBookEntry.Product2.Name == BOX_PLATFORM_TRANSFORM_NAME) {
            calculateTransformProductDetails();
            return ;
        }

        System.debug('Calculating total...');
        calculateSubtotal();
        if (qli.Discount__c == null) {
            qli.Discount__c = 0;
        }
        if (qli.UnitPrice == null) {
            qli.UnitPrice = selectedPriceBookEntry.UnitPrice;
        }
        if (qli.UnitPrice != selectedPriceBookEntry.UnitPrice) {
            discountedUnitPrice = qli.UnitPrice;
            qli.Discount__c = ((selectedPriceBookEntry.UnitPrice - qli.UnitPrice) / selectedPriceBookEntry.UnitPrice) * 100;
        } else {
            discountedUnitPrice = qli.UnitPrice * (1 - (qli.Discount__c / 100));
        }

        // Total license price override
        if (annualLicensePriceOverride != null && annualLicensePriceOverride != 0) {
            qli.Discount__c = ((annualSubtotal - annualLicensePriceOverride) / annualSubtotal) * 100;
            discountedUnitPrice = selectedPriceBookEntry.UnitPrice * (1 - (qli.Discount__c / 100));
        }

        // Premier Support special case
        if (qli.PricebookEntry.Product2.Percentage_of_Contract_Price__c != null) {
            qli.Discount__c = ((qli.PricebookEntry.Product2.Percentage_of_Contract_Price__c - qli.Percentage_of_Contract_Price__c) / qli.PricebookEntry.Product2.Percentage_of_Contract_Price__c) * 100;
        }
        discount = subtotal * (qli.Discount__c / 100);
        total = subtotal - discount;

        if (annualSubtotal != null) {
            annualTotal = annualSubtotal * (1 - (qli.Discount__c / 100));
        }
    }

    

    /**
     * This method is called when a user hits 'Save' after selecting a product in Quote Machine.
     *
     * @return {PageReference} - page location after save
     * @author David Liu
     * @author Kyle Vermeer 3/20/2014 Added View API bit
     */
    public PageReference specialSave() {
        System.debug('Saving record...');

        try {
            q.Pricebook2Id = pricebookId;
            update q;
            if (isViewAPIProduct) {
                viewAPIAddProduct();
            } 
            else { // Non View API
                // Save Quote first
                calculateTotal();
                if (qli.Discount__c <= 0) {
                    q.Hide_Discounts_from_Quote_DPF__c = true;
                }
            }
            update q;
            // Save
            if (isEdit) {
                update qli;
            }
            PageReference saveResults = controller.save();
            if (saveResults != null) {
                if (q.RecordTypeId == NEW_AGREEMENT_RECORD_TYPE_ID && !isEdit) {
                    addBonusProducts();
                }
                if (returnToQuote) {
                    return new PageReference('/' + qli.QuoteId);
                } else {
                    PageReference pageRef = new PageReference('/apex/QuoteMachine_AddProductsPage?retURL=' + qli.QuoteId + '&addTo=' + qli.QuoteId);
                    pageRef.setRedirect(true);
                    return pageRef;
                }
            } else {
                return saveResults;
            }
            
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;
        }
    }

    public void updateQuoteLineItemBackgroundFields() {
        System.debug('Updating qli background fields...');
        qli.Purchase_Start_Date__c = q.Order_Start_Date__c;
        qli.Purchase_End_Date__c   = q.Order_End_Date__c;
        qli.Revenue_Type__c        = mapPricebookEntryToRevenueType();
        if (qli.Revenue_Type__c == null || !qli.Revenue_Type__c.equals('ARR')) {
            qli.Purchase_End_Date__c = q.Order_Start_Date__c;
        }
        System.debug('Background fields have been updated');
    }

    public String mapPricebookEntryToRevenueType() {
        System.debug('Mapping Pricebook entry to a Revenue Type...');
        String revenueType;
        if (qli.PricebookEntry.Product2.NumberOfRevenueInstallments != null) {
                revenueType = 'ARR';
        } else {
                revenueType = 'NRR';
        }
        System.debug('Revenue type: ' + revenueType);
        return revenueType;
    }

    public void clearFields() {
        System.debug('Clearing fields...');
        if (q.Purchase_Type__c == null || (!q.Purchase_Type__c.equals('Upgrade') && q.Business_Ent_Unlimited_Subtotal__c <= 0)) {
            qli.Quantity = null;
        }
        qli.Discount = null;
        qli.Discount__c = null;
        qli.Number_of_GB__c = null;
        qli.Percentage_of_Contract_Price__c = null;
        discountedUnitPrice = null;
        subtotal = null;
        discount = null;
        annualLicensePriceOverride = null;
        total = null;
        annualSubtotal = null;
        annualTotal = null;
    }

    public void addBonusProducts() {
        System.debug('Adding bonus products...');
        if( q.CreatedDate >= LEGACY_DATE ) return;
        if (qli.PricebookEntry.Product2.Default_Product__c && !ownsQuickSmartStart) {
            autoAssociateProducts = [SELECT Id, Name, UnitPrice, Product2.Auto_Associate_Minimum_Contract_Value__c, Product2.Id FROM PricebookEntry
                                        WHERE Product2.Auto_Associate_Minimum_Contract_Value__c != null AND Pricebook2Id = :q.Pricebook2Id
                                            AND CurrencyIsoCode = :q.CurrencyIsoCode
                                        ORDER BY Product2.Auto_Associate_Minimum_Contract_Value__c DESC];
            System.debug('Number of auto-association products: ' + autoAssociateProducts.size());
            for (PricebookEntry pbe : autoAssociateProducts) {
                if (subtotal >= pbe.Product2.Auto_Associate_Minimum_Contract_Value__c) {
                    // TODO: Make sure they don't own any tickets
                    QuoteLineItem autoAddProduct = new QuoteLineItem();
                    autoAddProduct.Quantity = 1;
                    autoAddProduct.Discount__c = 0;
                    autoAddProduct.Discount = 0;
                    autoAddProduct.PricebookEntryId = pbe.Id;
                    autoAddProduct.UnitPrice = pbe.UnitPrice;
                    autoAddProduct.QuoteId = q.Id;
                    autoAddProduct.List_Price__c = pbe.UnitPrice;
                    autoAddProduct.Purchase_Start_Date__c = q.Order_Start_Date__c;
                    autoAddProduct.Purchase_End_Date__c = q.Order_Start_Date__c;
                    autoAddProduct.Revenue_Type__c = 'NRR';
                    insert autoAddProduct;
                    break;
                }
            }
        }
    }

    private Integer getTotalSeats()
    {
        return  Integer.valueOf(q.Business_Enterprise_Unlimited_Seats__c + q.Opportunity.Account.Total_Seats__c);
    }

    webservice static String updateOpportunityFields(String oppId, String quoteId) {
        System.debug('Rolling up quote fields to opportunity...');

        String message = 'Error updating Opportunity fields.';
        Opportunity opp;
        Quote quote;

        System.debug('Searching for opp with id ' + oppId + ' and quote with id ' + quoteId);
        List<Opportunity> oppList = [SELECT Id, Amount, Seats_Sold__c, Fee_Frequency__c, (SELECT Id, Live_Quote__c FROM Quotes) FROM Opportunity WHERE Id = :oppId];
        List<Quote> quoteList = [SELECT Id, Total_Price__c, Business_Enterprise_Unlimited_Seats__c, 
        									Payment_Frequency__c, Recurring_Annualized_Total__c, 
        									Current_ARR__c, Annualized_Total_Price__c, Box_Consulting__c  
    									FROM Quote 
    										WHERE Id = :quoteId];

        if (oppList != null && oppList.size() > 0 && quoteList != null && quoteList.size() > 0) {
            System.debug('Opp and quote identified.');
            opp = oppList[0];
            quote = quotelist[0];

            opp.Amount = quote.Recurring_Annualized_Total__c;
            opp.ARR__c = quote.Recurring_Annualized_Total__c;
            opp.NRR__c = quote.Annualized_Total_Price__c - quote.Recurring_Annualized_Total__c;
            opp.Live_Quote__c = quote.Id;
            opp.Box_Consulting__c = quote.Box_Consulting__c;
            
            // Make sure all associated quotes have Live Quote unchecked
            if (opp.Quotes != null && opp.Quotes.size() > 0) {
                List<Quote> quotes = new List<Quote>();
                for (Quote q : opp.Quotes) {
                    if (q.Id != quote.Id) {
                        q.Live_Quote__c = false;
                        quotes.add(q);
                    }
                }

                // Make sure the right quote has Live Quote checked
                quote.Live_Quote__c = true;
                quotes.add(quote);

                update quotes;
            }

            update opp;
            message = 'The following opportunity fields have been updated:\n\nAmount: $' + opp.Amount + '\nARR: $' + opp.ARR__c + '\nNRR: $' + opp.NRR__c;
            System.debug('Opportunity updated');
        }

        return message;
    }

    /**
     * Called by the controller when the quantity of View API products is changed. Refreshes View_API_Sales_Price__c.
     *
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    public void recalculateViewAPIPrice() {
        System.debug('Product ID for ViewAPI Price Recalc: ' + viewAPIProductId);
        if (viewAPIProductId == CustomSettings.getViewAPISettings().Bulk_Conversion_Product_Id__c) { // Bulk
            Decimal price = getPriceForBulkConversion();
            this.qli.View_API_Sales_Price__c = price;
        }
        else { // Bulk API
            Decimal price = PricingUtils.determinePrice(viewAPIProductId, (Integer)qli.Quantity, q.CurrencyIsoCode, pricebookId);
            System.debug('Price Calculated: ' + price);
            this.qli.View_API_Sales_Price__c = price;
        }
    }


    private Decimal getPriceForPremierSupport() {
        // TODO: implement
        return 0.0;
    }
    /**
     * Called to determine price for Bulk Conversion.  Returns 0 if something goes wrong.
     *
     * @return {Decimal} - price for Bulk Conversion
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    private Decimal getPriceForBulkConversion() {
        return getCurrentViewAPILicensePrice((Integer)qli.quantity) * CustomSettings.getViewAPISettings().Bulk_Conversion_Price_Factor__c;
    }

    /**
     * Called to determine price of the existing View API license on the quote.  Returns 0 if something goes wrong.
     *
     * @return {Decimal} - price for existing View API license
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    private Decimal getCurrentViewAPILicensePrice(Integer quantity) {
        try {
            List<QuoteLineItem> existingLineItems = [SELECT Id, PricebookEntry.Product2.Id, Quantity
                                                       FROM QuoteLineItem
                                                      WHERE QuoteId = :q.Id];
            if (existingLineItems.size() > 0) {
                // Look for a view in the existing line items
                Set<String> viewerIds = new Set<String>(CustomSettings.getViewAPISettings().Viewer_Ids__c.split(';'));
                for (QuoteLineItem currentLineItem : existingLineItems) {
                    System.debug('QLI Id: ' + currentLineItem.PricebookEntry.Product2.Id);
                    if (viewerIds.contains((String)currentLineItem.PricebookEntry.Product2.Id)) { // Viewer found
                        // Charge price depending on that viewer
                        Decimal viewerPrice = 0.0;
                        if (quantity != null) {
                            viewerPrice = PricingUtils.determinePrice(currentLineItem.PricebookEntry.Product2.Id, quantity, q.CurrencyIsoCode, pricebookId);
                        }
                        else {
                            viewerPrice = PricingUtils.determinePrice(currentLineItem.PricebookEntry.Product2.Id, (Integer)currentLineItem.Quantity, q.CurrencyIsoCode, pricebookId);
                        }
                        
                        return viewerPrice;
                    }
                }
                // No viewer found
                return 0.0;
            } else {
                // No other products
                return 0.0;
            }
        }
        catch (Exception e) { // Trouble
            new LoggedException(e, 'Trouble determining current View API License Price.', 'QuoteMachine_AddProductsController', new List<Id> { q.Id });
            System.debug('Trouble determining current View API License Price.');
            return 0.0;
        }
    }

    /**
     * This method helps handle the special case of adding a View API product
     *
     * @author Kyle Vermeer
     */
    public void viewAPIAddProduct() {
        // Mark it as a platform product
        qli.isPlatformProduct__c = true;
        q.Additional_Terms__c = '';
        if (isBulkConversion || isViewAPILicense) {
            Decimal listPrice = null;
            if (isBulkConversion) {
                listPrice = getPriceForBulkConversion();
            }
            else {
                listPrice = PricingUtils.determinePrice(viewAPIProductId, (Integer)qli.Quantity, q.CurrencyIsoCode, pricebookId);
            }
            // Compare list price versus provided price to determine discount
            Decimal listUnitPrice = (listPrice / qli.Quantity);
            Decimal unitPrice = qli.View_API_Sales_Price__c / qli.Quantity;
            Decimal discount = (1 - (unitPrice / listUnitPrice)) * 100;
            
            // Populate the qli fields
            qli.UnitPrice = unitPrice;
            qli.List_Price__c = listUnitPrice;
            qli.Discount__c = discount;

            // Add overage cost clause if its not a bulk conversion
            if (isViewAPILicense) {
                q.Additional_Terms__c = 'The overage cost per document is ' + qli.Overage_Cost__c + ' ' + q.CurrencyIsoCode + '. ';
                qli.Revenue_Type__c = 'ARR';
                // Add View API Premier Support
                if (qli.View_API_Sales_Price__c * 12 > CurrencyUtils.convertAmountFromUSD( CustomSettings.getViewAPISettings().Min_Amount_To_Add_Premier_Support__c, q.CurrencyIsoCode)) {
                    System.debug('View API Permier SUpport: ' + CustomSettings.getViewAPISettings().View_API_Premier_Support_ID__c);
                    System.debug('Pricebook: ' + q.Pricebook2Id);
                    PricebookEntry entry = [SELECT Id, Product2.Percentage_of_Contract_Price__c
                                              FROM PricebookEntry
                                             WHERE Product2Id = :CustomSettings.getViewAPISettings().View_API_Premier_Support_ID__c
                                               AND Pricebook2Id = :pricebookId
                                             LIMIT 1];

                    QuoteLineItem autoAddProduct = new QuoteLineItem();
                    autoAddProduct.Quantity = 1;
                    autoAddProduct.PricebookEntryId = entry.Id;
                    autoAddProduct.UnitPrice = 12* qli.View_API_Sales_Price__c * (entry.Product2.Percentage_of_Contract_Price__c / 100);
                    autoAddProduct.QuoteId = q.Id;
                    autoAddProduct.List_Price__c = autoAddProduct.UnitPrice;
                    autoAddProduct.Revenue_Type__c = 'ARR';
                    autoAddProduct.Purchase_Start_Date__c = q.Order_Start_Date__c;
                    autoAddProduct.Purchase_End_Date__c   = q.Order_End_Date__c;
                    autoAddProduct.isPlatformProduct__c = true;
                    insert autoAddProduct;
                }
            } 
            else { // Bulk Conversion
                qli.Revenue_Type__c = 'NRR';
            }
            
        }
        else if (isViewAPIPremierSupport) { // Premier Support
            // TODO: get current license price
            qli.Quantity = 1;
            Decimal licensePrice = getCurrentViewAPILicensePrice(null);
            System.debug('license Price: ' + licensePrice);
            if (licensePrice == 0.0) {
                qli.addError('Must have a license to add premier support.');
            }
            else {
                // TODO: determine discount
                Decimal salesPercent = qli.Percentage_of_Contract_Price__c;
                Decimal premierSupportPrice = salesPercent * (licensePrice/100) * 12;
                qli.UnitPrice = premierSupportPrice;
                qli.List_Price__c = premierSupportPrice;
            }
        }
        // Additional Terms
        q.Additional_Terms__c += 'The following definition is added to Section 1 of the BSA: ""Platform Action" is an API call made by a Customer to Box\'s public APIs through an API key licensed by the Customer or used on the Customer\'s behalf. Platform Actions do not include API calls made by the Box Service."';
        q.Additional_Terms__c += ' The following is added to the end of Section 2.1: "...and (d) allow Users to perform Platform Actions in accordance with and subject to the limits as set forth on the Order."';
    }



}