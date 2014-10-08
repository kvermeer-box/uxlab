/*   Copyright (c) 2013 Zuora, Inc.
 *
 *   Permission is hereby granted, free of charge, to any person obtaining a copy of
 *   this software and associated documentation files (the "Software"), to use copy,
 *   modify, merge, publish the Software and to distribute, and sublicense copies of
 *   the Software, provided no fee is charged for the Software.  In addition the
 *   rights specified above are conditioned upon the following:
 *
 *   The above copyright notice and this permission notice shall be included in all
 *   copies or substantial portions of the Software.
 *
 *   Zuora, Inc. or any other trademarks of Zuora, Inc.  may not be used to endorse
 *   or promote products derived from this Software without specific prior written
 *   permission from Zuora, Inc.
 *
 *   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *   FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL
 *   ZUORA, INC. BE LIABLE FOR ANY DIRECT, INDIRECT OR CONSEQUENTIAL DAMAGES
 *   (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 *   ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 *
 *   IN THE EVENT YOU ARE AN EXISTING ZUORA CUSTOMER, USE OF THIS SOFTWARE IS GOVERNED
 *   BY THIS AGREEMENT AND NOT YOUR MASTER SUBSCRIPTION AGREEMENT WITH ZUORA.
 */

public class Z_ProductSelector {

    // ------------------------------------------------------------------------
    // --- Public Constants ---
    // ------------------------------------------------------------------------

    /* Pagination for the select table for products */
    public final static Integer PRODUCT_TABLE_PAGE_SIZE = 20;


    /* Pagination for the select table for rate plans */
    public final static Integer RATEPLAN_TABLE_PAGE_SIZE = 10;


    // ------------------------------------------------------------------------
    // --- Public VF Attributes ---
    // ------------------------------------------------------------------------

    /* Boolean to render the main form if init successful */
    public Boolean initSuccess { get; set; }


    /* The quote context */
    public zqu__Quote__c quote { get; set; }


    /* Query String for product search */
    public String productSearchString { get; set; }


    /* Product List to display */
    public List<zqu__ZProduct__c> productList {
        get {
            return productSet.getRecords();
        }
        set;
    }


    /* Product set to display (with pagination) */
    public ApexPages.StandardSetController productSet { get; set; }


    /* Product section info */
    public String productSectionInfo {
        get {
            Integer upperProduct = 0;

            if (productSet.getPageNumber() * productSet.getPageSize() < productSet.getResultSize())
                upperProduct = productSet.getPageNumber() * productSet.getPageSize();
            else
                upperProduct = productSet.getResultSize();

            return 'Showing ' + ((productSet.getPageNumber() - 1) * productSet.getPageSize() + 1)
                    + ' to ' + upperProduct + ' of ' + productSet.getResultSize();
        }
        set;
    }


    /* Product pagination previous */
    public Boolean productHasPrevious {
        get {
            return productSet.getHasPrevious();
        }
        set;
    }


    /* Product pagination next */
    public Boolean productHasNext {
        get {
            return productSet.getHasNext();
        }
        set;
    }


    /* Product ID (SFDC) selected */
    public String selProductId { get; set; }


    /* Rate Plan List to display */
    public List<zqu__ProductRatePlan__c> ratePlanList {
        get {
            if (ratePlanSet != null) {
                return ratePlanSet.getRecords();
            }
            return null;
        }
        set;
    }


    /* Rate plan set to display (with pagination) */
    public ApexPages.StandardSetController ratePlanSet { get; set; }


    /* Rate Plan section info */
    public String ratePlanSectionInfo {
        get {
            Integer upperRatePlan = 0;

            if (ratePlanSet.getPageNumber() * ratePlanSet.getPageSize() < ratePlanSet.getResultSize())
                upperRatePlan = ratePlanSet.getPageNumber() * ratePlanSet.getPageSize();
            else
                upperRatePlan = ratePlanSet.getResultSize();

            return 'Showing ' + ((ratePlanSet.getPageNumber() - 1) * ratePlanSet.getPageSize() + 1)
                    + ' to ' + upperRatePlan + ' of ' + ratePlanSet.getResultSize();
        }
        set;
    }


    /* Rate Plan pagination previous */
    public Boolean ratePlanHasPrevious {
        get {
            return ratePlanSet.getHasPrevious();
        }
        set;
    }


    /* Product pagination next */
    public Boolean ratePlanHasNext {
        get {
            return ratePlanSet.getHasNext();
        }
        set;
    }


    /* Rate Plan ID (SFDC) selected */
    public String selRatePlanId { get; set; }


    /* Boolean to indicate to render the rate plan panel */
    public Boolean showRatePlan { get; set; }


    /* Rate Plan search string */
    public String ratePlanSearchString { get; set; }


    /* Boolean to indicate to render the quote charge panel */
    public Boolean showChargeGroup { get; set; }


    /* Boolean to indicate whether charge group is a percent product */
    public Boolean isPercentProduct { get; set; }

    /* The charge group for the selected rate plan */
    public zqu.ZChargeGroup chargeGroup { get; set; }

    public List<ChargeRow> chargeRows { get; set; }
    public class ChargeRow {
        public zqu.zCharge charge { get; set; }
        public Decimal discount {
            get {
                return (Decimal) charge.chargeObject.get('Box_Discount__c');
            }

            set {
                charge.chargeObject.put('Box_Discount__c', value);
            }
        }

        public Decimal listPrice {
            get {
                return (Decimal) charge.chargeObject.get('List_Price__c');
            }

            set {
                charge.chargeObject.put('List_Price__c', value);
            }
        }

        public ChargeRow(zqu.zCharge charge, Decimal discount, Decimal listPrice) {
            this.charge = charge;
            this.discount = discount;
            this.listPrice = listPrice;
        }
    }

    /* List of WrapperOptions for the product filtering */
    public List<WrapperOptions> productWrapperOptionsList {
        get {
            if (productWrapperOptionsList == null)
                productWrapperOptionsList = prepareProductFilter();
            return productWrapperOptionsList;
        }
        set;
    }

    // workaround the callout limit since each get charge groups does 6 callouts
    public List<zqu.ZChargeGroup> chargeGroups { get; set; }
    public static List<zqu.ZChargeGroup> staticChargeGroups { get; set; }
    public static List<zqu.ZChargeGroup> getStaticChargeGroups(Id quoteId) {
        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = new Set<String>
            { 'Box_Discount__c'
            , 'List_Price__c'
            };

        if(staticChargeGroups == null && quoteId != null) {
            staticChargeGroups = zqu.zQuoteUtil.getChargeGroups(quoteId);
        }

        return staticChargeGroups;
    }

    /* List of WrapperOptions for the rate plan filtering */
    public List<WrapperOptions> ratePlanWrapperOptionsList { get; set; }

    
    public Boolean doNotShow { get; set; }

    // ------------------------------------------------------------------------
    // --- Private Attributes ---
    // ------------------------------------------------------------------------

    /* Standard Controller for context validation */
    private ApexPages.StandardController controller;


    /* Previously selected product ID (SFDC) to differentiate product
        selection to rate plan search (during refresh rate plan) */
    private String previousProductId;


    // ------------------------------------------------------------------------
    // --- Public Methods ---
    // ------------------------------------------------------------------------

    /**
     *  Constructor
     */
    public Z_ProductSelector(ApexPages.StandardController stdController) {

        // First, do not display the form
        initSuccess = false;

        this.controller = stdController;

        if (!validate()){
            return;
        }

        chargeGroups = getStaticChargeGroups(quote.Id);

        refreshProducts();

        showRatePlan = false;

        showChargeGroup = false;

        initSuccess = true;

    }

    /**
     *  Cancel button
     */
    public PageReference stndCancel() {
        return controller.cancel();
    }

    /**
     *  Refresh products in the catalog
     */
    public void refreshProducts() {

        // Retrieve the list of product to query
        Set<Id> productIds = getFilteredZProductIds(
            quote.zqu__Currency__c,
            quote.zqu__StartDate__c
        );

        // Filter this initial list if a search is entered
        if (String.isNotBlank(productSearchString)) {
            productIds = searchProducts(productIds, quote.zqu__StartDate__c);
        }

        // Get the list of product to display
        productSet = new ApexPages.StandardSetController([
            SELECT
                Name,
                zqu__SKU__c,
                zqu__Description__c
            FROM
                zqu__ZProduct__c
            WHERE
                Id IN :productIds
            ORDER BY
                Name ASC
        ]);

        productSet.setPageSize(PRODUCT_TABLE_PAGE_SIZE);

        // Don't display the rate plan panel
        showRatePlan = false;

        showChargeGroup = false;

        // Refresh the selected product
        selProductId = '';

        System.debug('SelRatePlanId = ' + selRatePlanId);

    }


    /**
     *  Move the product set forward (next page)
     */
    public void nextProductPage() {

        if (productSet.getHasNext()) {
            productSet.next();
        }

    }


    /**
     *  Move the product set backward (previous page)
     */
    public void previousProductPage() {

        if (productSet.getHasPrevious()) {
            productSet.previous();
        }

    }


    /**
     *  Refresh the rate plans panel
     */
    public void refreshRatePlans() {
        // Check if it's a new product selected or "just" the search
        if (selProductId != previousProductId) {

            // Set it as the new product selected
            previousProductId = selProductId;

            // Reconstruct the list of wrapper for the rate plans
            ratePlanWrapperOptionsList = prepareRatePlanFilter(selProductId);

        }

        // Get the IDs for all the product rate plans corresponding
        List<Id> ratePlanIds = getFilteredRatePlanIds(
            selProductId,
            quote.zqu__Currency__c,
            quote.zqu__StartDate__c
        );

        // Filter this initial list if a search is entered
        if (String.isNotBlank(ratePlanSearchString)) {
            ratePlanIds = searchRatePlans(ratePlanIds, quote.zqu__StartDate__c);
        }

        // Get the list of rate plan to display
        ratePlanSet = new ApexPages.StandardSetController([
            SELECT
                Name,
                zqu__Description__c
            FROM
                zqu__ProductRatePlan__c
            WHERE
                Id IN :ratePlanIds
            ORDER BY
                Name ASC
        ]);

        ratePlanSet.setPageSize(RATEPLAN_TABLE_PAGE_SIZE);

        showRatePlan = true;

        showChargeGroup = false;

        /* Box: auto-select rate plan */
        if(ratePlanIds.size() == 1) {
            selRatePlanId = ratePlanIds[0];
            refreshChargeGroup();
        }
        else {
            selRatePlanId = '';
        }
    }


    /**
     *  Move the rate plan set forward (next page)
     */
    public void nextRatePlanPage() {

        if (ratePlanSet.getHasNext()) {
            ratePlanSet.next();
        }

    }


    /**
     *  Move the product set backward (previous page)
     */
    public void previousRatePlanPage() {

        if (ratePlanSet.getHasPrevious()) {
            ratePlanSet.previous();
        }

    }


    /**
     *  Refresh the charge group panel
     */
    public void refreshChargeGroup() {
        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = new Set<String>
            { 'Box_Discount__c'
            , 'List_Price__c'
            };

        List<Pricing_Rule__c> pricingRule = PricingRules.checkPricingRules(chargeGroups, selProductId);
        if(!pricingRule.isEmpty()) {
            chargeGroup = PricingRules.getChargeGroup(chargeGroups, pricingRule[0], quote.Id, selRatePlanId);
            isPercentProduct = true;
        }
        else {
            chargeGroup = zqu.ZQuoteUtil.getChargeGroups(quote.Id, new List<Id>{ selRatePlanId })[0];
        }

        chargeRows = new List<ChargeRow>();
        for(zqu.zCharge charge : chargeGroup.zCharges) {
            Decimal total = String.isEmpty(charge.TOTAL) || charge.TOTAL == '-' ? 0 : Decimal.valueOf(charge.TOTAL);
            chargeRows.add(new ChargeRow(charge, 0, total) );
        }

        showChargeGroup = true;

    }


    // --- Methods called by JS onChange ---

    /**
     * On discount change
     */
    public void discountChange() {
        List<zqu.zCharge> charges = zqu.zQuoteUtil.calculateChargesOnDiscountChange(
            chargeGroup.zCharges
        );
        chargeGroup.zCharges = charges;
    }


    /**
     * On quantity change
     */
    public void quantityChange() {

        List<zqu.zCharge> charges = zqu.zQuoteUtil.calculateChargesOnQuantityChange(
            chargeGroup.zCharges
        );
        
        chargeGroup.zCharges = charges;
    }


    /**
     * On effective price change
     */
    public void effectiveChange() {
        List<zqu.zCharge> charges = zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(
            chargeGroup.zCharges
        );
        chargeGroup.zCharges = charges;
    }


    /**
     * On total price change
     */
    public void totalChange() {
        List<zqu.zCharge> charges = zqu.zQuoteUtil.calculateChargesOnTotalChange(
            chargeGroup.zCharges
        );
        chargeGroup.zCharges = charges;
    }

    public void customDiscountChange() {
        PricingRules.updateTotalWithCustomDiscount(chargeGroup);
    }


    /**
     *  Save the charge groups to the quote
     */
    public PageReference saveCharges() {

        System.debug('>>>>>>>>>saveCharges<<<<<<<<<');

        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = new Set<String>
            { 'Box_Discount__c'
            , 'List_Price__c'
            };

        // Add the charges to the quote
        try {
            ProductPairingUtility.AddChargeGroup(chargeGroup, chargeGroups, quote);

            List<zqu.ZChargeGroup> chargeGroupAdded = zqu.ZQuoteUtil.addChargeGroups(
                new List<zqu.ZChargeGroup> { chargeGroup }
            );

        } catch (zqu.ZQException e) {
            appendMessage(ApexPages.Severity.ERROR, e.getMessage());
            return null;
        }

        // Get back to the quote
        PageReference pageRef = new PageReference('/' + quote.Id);
        return pageRef;
    }


    /**
     *  Save the charge groups and return to the product selector
     */
    public PageReference saveAndNewCharges() {

        System.debug('>>>>>>>>>saveAndNewCharges<<<<<<<<<');

        System.debug('>>>>>>>>>>>>saveAndNewCharges.chargeGroup='+chargeGroup);

        // Add the charges to the quote
        try {
            ProductPairingUtility.AddChargeGroup(chargeGroup, chargeGroups, quote);

            List<zqu.ZChargeGroup> chargeGroupAdded = zqu.ZQuoteUtil.addChargeGroups(
                new List<zqu.ZChargeGroup> { chargeGroup }
            );
        } catch (zqu.ZQException e) {
            appendMessage(ApexPages.Severity.ERROR, e.getMessage());
            return null;
        }

        // Get back to the quote
        PageReference pageRef = Page.Z_ProductSelector;
        pageRef.getParameters().put('Id', quote.Id);
        pageRef.setRedirect(true);

        return pageRef;
    }


    private void appendMessages(List<ApexPages.Message> messageList) {

        if(messageList==null){
            return;
        }

        for(ApexPages.Message msg:messageList){
            ApexPages.addMessage(msg);
        }
    }

    /**
     *  Note – This function is ONLY used from the Z_EditCharges VF page and will
     *  add a charge group to it.
     */
    public PageReference addGroup() {

        System.debug('>>>>>>>>>addGroup<<<<<<<<');

        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = new Set<String>
            { 'Box_Discount__c'
            , 'List_Price__c'
            };

        // Add the charges to the quote
        try {

            // Box
            appendMessages(Z_QuoteChargeValidationUtility.validate(quote.Id, chargeGroup));
            if(ApexPages.hasMessages()){
                return null;
            }

            // Box
            ProductPairingUtility.AddChargeGroup(chargeGroup, chargeGroups, quote);
            //

            List<zqu.ZChargeGroup> chargeGroupAdded = zqu.ZQuoteUtil.addChargeGroups(
                new List<zqu.ZChargeGroup> { chargeGroup }
            );

        } catch (zqu.ZQException e) {
            appendMessage(ApexPages.Severity.ERROR, e.getMessage());
            return null;
        }

        // Get back to the quote
        PageReference pageRef = Page.Z_EditCharges;
        pageRef.getParameters().put('id', quote.Id);
        pageRef.setRedirect(true);

        return pageRef;
    }


    /**
     *  When the product filtering option (picklist) are change
     */
    public void onProductFilterChange() {

        appendMessage(ApexPages.Severity.INFO, 'Current filter values are:');

        for (WrapperOptions wrapOptions : productWrapperOptionsList) {
            appendMessage(ApexPages.Severity.INFO, wrapOptions.fieldName + ' = ' + wrapOptions.value);
        }

    }

    // ------------------------------------------------------------------------
    // --- Private Methods ---
    // ------------------------------------------------------------------------

    /**
     * Display an error message back to the VF page
     */
    private static void appendMessage(ApexPages.Severity severity, String message) {
        ApexPages.addMessage(new ApexPages.Message(severity, message));
    }


    /**
     *  Validate the context
     */
    private Boolean validate() {

        if (null == controller.getRecord() || null == controller.getRecord().Id) {
            appendMessage(ApexPages.Severity.ERROR,
                    'Need to specify the quote id to select products');
            return false;
        }

        ID quoteId = controller.getRecord().Id;

        // Query the quote (for the context)
        List<zqu__Quote__c> quoteList = [
            SELECT
                Name,
                zqu__Currency__c,
                zqu__Status__c,
                zqu__StartDate__c,
                Payment_Frequency__c
            FROM
                zqu__Quote__c
            WHERE
                Id = :quoteId
        ];

        if (1 != quoteList.size()) {
            appendMessage(ApexPages.Severity.ERROR,
                    'No quote found with the ID passed in parameter');
            return false;
        }

        this.quote = quoteList[0];

        return true;
    }


    /**
     * Return the list of IDs from product found by the search
     */
    private Set <Id> searchProducts(Set <Id> prodids, Date zqStartDate) {

        Set <Id> productIds = new Set <Id>();

        try {
            String searchQuery = '*' + productSearchString + '*';

            searchQuery = 'FIND \'' + searchQuery + '\' IN ALL FIELDS RETURNING '
                    + 'zqu__zProduct__c(Id, Name, zqu__SKU__c, zqu__Description__c, '
                    + 'zqu__ZuoraId__c WHERE id in :prodids AND zqu__Deleted__c = false '
                    + 'AND zqu__EffectiveStartDate__c <= :zQStartDate AND '
                    +'zqu__EffectiveEndDate__c >= :zQStartDate ORDER BY Name ASC)';

            List < SObject > results = search.query(searchQuery)[0];

            for (SObject sobj: results) {
                productIds.add(sobj.Id);
            }

        } catch (Exception e) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(msg);
        }
        return productIds;
    }


    /**
     * Filter the product list
     */
    private Set < Id > getFilteredZProductIds(String zCurrency, Date zStartDate) {
        List < zqu__ZProduct__c > products;

        AggregateResult[] groupedResults = [
            SELECT
                zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__zProduct__r.Id
            FROM
                zqu__ProductRatePlanChargeTier__c
            WHERE
                zqu__Currency__c = : zCurrency
            AND
                zqu__Deleted__c = false
            GROUP BY
                zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__zProduct__r.Id
        ];

        Set < Id > productIds = new Set < Id > ();

        for (AggregateResult result: groupedResults) {
            productIds.add(result.Id);
        }

        // Apply Box filters
        productIds = ProductConflictUtility.removeConflictingProducts(productIds, quote.Id, chargeGroups);
        productIds = ProductDependenciesUtility.removeProductsWithMissingDependencies(productIds, quote.Id, chargeGroups);
        productIds = ProductLimitationsUtility.removeProductsExceedingLimit(productIds, quote.Id, chargeGroups);
        productIds = Z_ProductSelectorUtility.getFilteredZProductIds(productIds, quote.Id, chargeGroups);
        //

        String baseSoql = 'SELECT Id FROM zqu__ZProduct__c WHERE Id IN :productIds '
                + 'AND zqu__Deleted__c = false AND zqu__EffectiveStartDate__c <= :zStartDate '
                + 'AND zqu__EffectiveEndDate__c >= :zStartDate ';

        // CPQ filter fragment
        /*for (WrapperOptions wrap : productWrapperOptionsList) {
            if (wrap.value != 'N/A') {
                baseSoql += 'AND ' + wrap.fieldName + ' = \'' + wrap.value + '\' ';
            }
        }*/

        //baseSoql += productFilterFragment;
        baseSoql += ' ORDER BY zqu__SKU__c DESC LIMIT 10000 ';

        System.debug('#### soql query = ' + baseSoql);

        products = Database.query(baseSoql);
        productIds = new Set < Id > ();

        for (zqu__zProduct__c product: products) {
            productIds.add(product.Id);
        }

        return productIds;
    }


    /**
     * Return the list of IDs from rate plan found by the search
     */
    private List <Id> searchRatePlans(List <Id> rpIds, Date zqStartDate) {

        List <Id> ratePlanIds = new List <Id>();

        try {
            String searchQuery = '*' + ratePlanSearchString + '*';

            searchQuery = 'FIND \'' + searchQuery + '\' IN ALL FIELDS RETURNING '
                    + 'zqu__ProductRatePlan__c(Id, Name, zqu__Description__c, '
                    + 'zqu__ZuoraId__c WHERE id in :rpIds AND zqu__Deleted__c = false '
                    + 'AND zqu__EffectiveStartDate__c <= :zQStartDate AND '
                    +'zqu__EffectiveEndDate__c >= :zQStartDate ORDER BY Name ASC)';

            List < SObject > results = search.query(searchQuery)[0];

            for (SObject sobj: results) {
                ratePlanIds.add(sobj.Id);
            }

        } catch (Exception e) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(msg);
        }

        return ratePlanIds;
    }


    /**
     * Return the list of filtered product rate plan Ids
     */
    private List < Id > getFilteredRatePlanIds(Id zProductId, String zCurrency, Date zStartDate) {

        AggregateResult[] groupedResults = [
            SELECT
                zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.Id
            FROM
                zqu__ProductRatePlanChargeTier__c
            WHERE
                zqu__Currency__c = : zCurrency
            AND
                zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__zProduct__r.Id = : zProductID
            GROUP BY
                zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.Id
        ];

        List < ID > ratePlanIds = new List < ID > ();

        for (AggregateResult gr: groupedResults) {
            ratePlanIds.add(gr.Id);
        }
        /* Apply Box filters */
        System.debug('>>>>>>>ratePlanIds='+ratePlanIds);
        ratePlanIds = new List<Id>(QuoteBusinessRules.removeDuplicateRatePlans(new Set<Id>(ratePlanIds), chargeGroups));
        System.debug('>>>>>>>removeDuplicateRatePlans.ratePlanIds='+ratePlanIds);
        ratePlanIds = new List<Id>(ProductConflictUtility.removeConflictingRatePlans(new Set<Id>(ratePlanIds), quote.Id, chargeGroups));
        System.debug('>>>>>>>removeConflictingRatePlans.ratePlanIds='+ratePlanIds);
        ratePlanIds = new List<Id>(QuoteBusinessRules.removeCloudConnectImplementation(new Set<Id>(ratePlanIds), quote.Id));
        System.debug('>>>>>>>removeCloudConnectImplementation.ratePlanIds='+ratePlanIds);
        ratePlanIds = Z_ProductSelectorUtility.getFilteredRatePlanIds(ratePlanIds, zProductId, quote.Id);
        System.debug('>>>>>>>getFilteredRatePlanIds.ratePlanIds='+ratePlanIds);
        
        String baseSoql = 'SELECT Id FROM zqu__ProductRatePlan__c WHERE Id IN :ratePlanIds '
                + 'AND zqu__Deleted__c = false AND zqu__EffectiveStartDate__c <= :zStartDate '
                + 'AND zqu__EffectiveEndDate__c >= :zStartDate ';


        // CPQ filter fragment
        /*for (WrapperOptions wrap : ratePlanWrapperOptionsList) {
            if (wrap.value != 'N/A') {
                baseSoql += 'AND ' + wrap.fieldName + ' = \'' + wrap.value + '\' ';
            }
        }*/

        baseSoql += ' ORDER BY Name ASC LIMIT 10000 ';

        List < zqu__ProductRatePlan__c > ratePlans = Database.query(baseSoql);
        ratePlanIds = new List < Id > ();

        for (zqu__ProductRatePlan__c ratePlan: ratePlans) {
            ratePlanIds.add(ratePlan.Id);
        }

        System.debug('##### Retrieved ' + ratePlanIds.size() + ' rate plan(s)');

        return ratePlanIds;
    }

    /**
     *  Prepare the filter option for the product(s)
     */
    private List<WrapperOptions> prepareProductFilter() {

        // Get the map of SObjectField for the zqu__ZProduct__c object
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.zqu__ZProduct__c.fields.getMap();

        // Prepare the list of wrapper options to be returned
        List<WrapperOptions> wrapperOptionsList = new List<WrapperOptions>();

        // Loop through the fields and prepare the wrapper option
        for (String fieldName : fieldMap.keySet()) {

            // Only add the non-managed fields of type picklist
            if (!fieldName.contains('zqu__') && fieldMap.get(fieldName).getDescribe().getType() == Schema.DisplayType.Picklist) {

                WrapperOptions wrap = new WrapperOptions();

                wrap.fieldName = fieldName;
                wrap.fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
                wrap.value = ''; // TODO get the default picklist value here

                // Prepare the lisf of select option based on the picklist value(s)
                List<SelectOption> options = new List<SelectOption>();

                // Loop through the picklist values
                for (Schema.PicklistEntry entry : fieldMap.get(fieldName).getDescribe().getPicklistValues()) {
                    // Add it to the list of select options
                    options.add(new SelectOption(entry.getValue(), entry.getLabel()));

                    // Set the default value if any
                    if (entry.isDefaultValue())
                        wrap.value = entry.getValue();
                }

                // Set the list of options to the wrapper
                wrap.items = options;

                // Add it to the returned list
                wrapperOptionsList.add(wrap);

            }

        }

        return wrapperOptionsList;
    }

    /**
     *  Prepare the filter options for the rate plan based on the selected product
     */
    private List<WrapperOptions> prepareRatePlanFilter(String productId) {

        // Get the map of SObjectField for the zqu__ZProduct__c object
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.zqu__ProductRatePlan__c.fields.getMap();

        // Prepare the SOQL query
        String soql = 'SELECT Id';

        // Map to know if we should add the custom field picklist to the list of filter
        Map<String, Boolean> validFilterForSelectedProduct = new Map<String, Boolean>();

        // Loop through all the custom fields of type picklist, out of the managed package
        for (String fieldName : fieldMap.keySet()) {
            // Only add the non-managed fields of type picklist
            if (!fieldName.contains('zqu__') && fieldMap.get(fieldName).getDescribe().getType() == Schema.DisplayType.Picklist) {
                // Add it to the SOQL query string
                soql += ', ' + fieldName + ' ';
                // Add it to the map and default to false
                validFilterForSelectedProduct.put(fieldName, false);
            }
        }

        // Finish the SOQL query
        soql += 'FROM zqu__ProductRatePlan__c WHERE zqu__ZProduct__r.Id = :productId AND zqu__Deleted__c = false';

        // Query the product rate plan
        List<zqu__ProductRatePlan__c> prpList = Database.query(soql);

        // Now loop through all the fieldnames added to the map
        for (String fieldname : validFilterForSelectedProduct.keySet()) {
            // Loop through all the rate plans and look for the field name value
            for (zqu__ProductRatePlan__c prp : prpList) {
                // If the value is != than 'N/A' we set the map to TRUE (aka it's a relevant filter)
                if (prp.get(fieldname) != 'N/A') {
                    // Set to true and exit the loop
                    validFilterForSelectedProduct.put(fieldname, true);
                    System.debug('##### Added ' + fieldName + ' to the list of relevant filters');
                    break;
                }
            }
        }

        // Prepare the list of wrapper options to be returned
        List<WrapperOptions> wrapperOptionsList = new List<WrapperOptions>();

        // Now that the value are set, we can construct the relevant wrapper options
        for (String fieldName : validFilterForSelectedProduct.keySet()) {
            // It's a relevant filter?
            if (validFilterForSelectedProduct.get(fieldName)) {
                // Prepare a wrapper option
                WrapperOptions wrap = new WrapperOptions();

                wrap.fieldName = fieldName;
                wrap.fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
                wrap.value = ''; // will be defaulted for the default value from the picklist

                // Prepare the lisf of select option based on the picklist value(s)
                List<SelectOption> options = new List<SelectOption>();

                // Loop through the picklist values
                for (Schema.PicklistEntry entry : fieldMap.get(fieldName).getDescribe().getPicklistValues()) {
                    // Add it to the list of select options
                    options.add(new SelectOption(entry.getValue(), entry.getLabel()));

                    // Set the default value if any
                    if (entry.isDefaultValue())
                        wrap.value = entry.getValue();
                }

                // Set the list of options to the wrapper
                wrap.items = options;

                // Add it to the returned list
                wrapperOptionsList.add(wrap);
            }
        }

        return wrapperOptionsList;
    }


    // ------------------------------------------------------------------------
    // --- Wrapper(s) ---
    // ------------------------------------------------------------------------

    /**
     *  This is a wrapper that contains both the list of select options and
     *  the field to store the value selected
     */
    public class WrapperOptions {

        /* The field API name */
        public String fieldName { get; set; }

        /* The field label */
        public String fieldLabel { get; set; }

        /* The value selected in the picklist */
        public String value { get; set; }

        /* The list of select option to build the picklist */
        public List<SelectOption> items { get; set; }

    }

}