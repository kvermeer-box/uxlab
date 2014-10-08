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

public class Z_EditCharges {

    // ------------------------------------------------------------------------
    // --- Public VF Attributes ---
    // ------------------------------------------------------------------------

    /* Initialization successful (after validation) */
    public Boolean initSuccess { get; set; }


    /* The quote context */
    public zqu__Quote__c quote { get; set; }


    /* The list of quote amendments associated to the quote */
    public List<zqu__QuoteAmendment__c> quoteAmendmentList { get; set; }


    /* Boolean to indicate if we should display the product catalog */
    public Boolean displayProductCatalog { get; set; }


    /* Get which quote amendment to undo from the VF page */
    public Id quoteAmendmentToUndo { get; set; }


    /* The charge group list on the quote */
    public List<EditChargeGroupRow> editChargeGroupRowList { get; set; }


    /* The charge group that we are working on */
    public String selectedChargeGroup { get; set; }


    /* Enumeration to know which state the charge group is in */
    public enum EditMode { NO_EDIT, PARTIAL, FULL, DISCOUNT }


    /* Map to know which group is in which mode, the second parameter is the
    string value for the ENUM since VisualForce component can't access ENUM */
    public Map<String, String> groupEditMap { get; set; }


    /* Map to know whether the group is a subscription, and if so, used to not
    render delete*/
    public Map<String, Boolean> subscriptionMap { get; set; }


    /* To be added to the quote charge group */
    public zqu.ZChargeGroup toBeAddedChargeGroup { get; set; }

    // ------------------------------------------------------------------------
    // --- Private Attributes ---
    // ------------------------------------------------------------------------

    /* The controller passed in parameter */
    private ApexPages.StandardController controller;


    /* The map of quote amendments, to avoid querying multiple times */
    public Map<Id, zqu__QuoteAmendment__c> quoteAmendmentMap { get; set; }

    public class EditChargeGroupRow {
        public zqu.ZChargeGroup chargeGroup { get; set; }

        public List<EditChargeRow> editChargeRows { get; set; }

        public Boolean isPercentProduct { get; set; }

        // KV - added
        public Boolean isLicenseProduct { get; set; }

        // Added parameter
        public EditChargeGroupRow(zqu.ZChargeGroup chargeGroup, Boolean isPercentProduct, Boolean isLicenseProduct) {
            this.chargeGroup = chargeGroup;
            editChargeRows = new List<EditChargeRow>();
            for(zqu.zCharge charge : chargeGroup.zCharges) {
                editChargeRows.add(new EditChargeRow(charge));
            }
            this.isPercentProduct = isPercentProduct;
            this.isLicenseProduct = isLicenseProduct;
        }

        public Boolean isUpsellRow {
            get {
                if (this.chargeGroup.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_ORIGINAL ||
                    this.chargeGroup.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_UPDATEPRODUCT) {
                    return true;
                }
                else {
                    return false;
                }
            }
            set;
        }
    }

    public class EditChargeRow {
        public zqu.zCharge charge { get; set; }
        // KV Addition
        private Decimal originalPrice { get; set; }
        private Decimal originalQuantity { get; set; }
        private Decimal originalUpsellPrice { get; set; }
        private Decimal originalUpsellQuantity { get; set; }
        private Decimal originalTotal { get; set; }

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

        // KV - added
        public Decimal upsellPrice {
            get {
                Decimal valueToReturn = (Decimal) charge.chargeObject.get('Upsell_Price__c');
                System.debug('>>>>>>>1 charge.EFFECTIVE_PRICE='+charge.EFFECTIVE_PRICE);
                /*
                if (valueToReturn == null && charge.EFFECTIVE_PRICE.isNumeric()) {
                    valueToReturn = Decimal.valueOf(charge.EFFECTIVE_PRICE);
                }
                */
                if (valueToReturn == null) {
                    try {
                        valueToReturn = Decimal.valueOf(charge.EFFECTIVE_PRICE);
                    }
                    catch (Exception e) {
                        System.debug('It wasn\'t numeric! e: ' + e);
                        valueToReturn = 0.00;
                    }
                }
                // Clean the presentation
                if (valueToReturn == 0) {
                    valueToReturn = 0.00;
                }
                return valueToReturn;
            }
            set {
                charge.chargeObject.put('Upsell_Price__c', value);
            }
        }

        // KV - added
        public Decimal upsellQuantity {
            get {
                Decimal valueToReturn = (Decimal) charge.chargeObject.get('Upsell_Quantity__c');
                if (valueToReturn == null) {
                    valueToReturn = 0;
                }
                return valueToReturn;

            }
            set {
                charge.chargeObject.put('Upsell_Quantity__c', value);
            }
        }

        public Decimal getOriginalTotal() {
            return this.originalTotal;
        }

        public Decimal getOriginalPrice() {
            return this.originalPrice;
        }

        public Decimal getOriginalQuantity() {
            return this.originalQuantity;
        }

        public Decimal getOriginalUpsellPrice() {
            return this.originalUpsellPrice;
        }

        public Decimal getOriginalUpsellQuantity() {
            return this.originalUpsellQuantity;
        }

        public EditChargeRow(zqu.zCharge charge) {
            this.charge = charge;
            // Initialize original values
             System.debug('2>>>>>>>charge.EFFECTIVE_PRICE='+charge.EFFECTIVE_PRICE);
             
            try {
               this.originalPrice = Decimal.valueOf(charge.EFFECTIVE_PRICE);
               this.originalTotal = Decimal.valueOf(charge.TOTAL);
            }
            catch (Exception e) {
                // Effective Price wasn't a number
                this.originalPrice = 0.0;
                this.originalTotal = 0.0;
            }
           
            //this.originalPrice = Decimal.valueOf(charge.EFFECTIVE_PRICE);
            this.originalUpsellPrice = this.upsellPrice;
            if (charge.Quantity != '-') {
                this.originalQuantity = Decimal.valueOf(charge.QUANTITY);
                this.originalUpsellQuantity = this.upsellQuantity;
            }
            else {
                this.originalQuantity = 0;
                this.originalUpsellQuantity = 0;
            }
        }
    }

    public static List<EditChargeGroupRow> chargeGroupsToEditChargeGroupRows(List<zqu.ZChargeGroup> chargeGroups) {
        List<EditChargeGroupRow> editChargeGroupRows = new List<EditChargeGroupRow>();

        Map<Id, List<zqu.ZChargeGroup>> productIdToChargeGroups = ChargeGroupUtility.getProductIdToChargeGroups(chargeGroups, true);

        List<Pricing_Rule__c> pricingRuleRecords = PricingRules.getPricingRulesRelatedToProducts(productIdToChargeGroups.keySet());
        Set<Id> percentProductIds = Pluck.ids('Auto_Set_Product__c', pricingRuleRecords);

        // Get license product ids - KV
        Set<Id> licenseProductIds = PricingRules.getLicenseProductsIds();

        for(Id productId : productIdToChargeGroups.keySet()) {
            List<zqu.ZChargeGroup> relatedChargeGroups = productIdToChargeGroups.get(productId);
            Boolean isPercentProduct = percentProductIds.contains(productId);
            // determine license product - KV
            Boolean isLicenseProduct = licenseProductIds.contains(productId);

            for(zqu.ZChargeGroup chargeGroup : relatedChargeGroups) {
                // KV - Added additional parameter
                editChargeGroupRows.add(new EditChargeGroupRow(chargeGroup, isPercentProduct, isLicenseProduct));
            }
        }

        return editChargeGroupRows;
    }

    static List<zqu.ZChargeGroup> pluckChargeGroups(List<EditChargeGroupRow> editChargeGroupRows) {
        List<zqu.ZChargeGroup> chargeGroups = new List<zqu.ZChargeGroup>();

        for(EditChargeGroupRow editChargeGroupRow : editChargeGroupRows) {
            chargeGroups.add(editChargeGroupRow.chargeGroup);
        }

        return chargeGroups;
    }

    static List<zqu.ZChargeGroup> getPercentProductCharges(List<EditChargeGroupRow> editChargeGroupRows) {
        List<zqu.ZChargeGroup> percentProductCharges = new List<zqu.ZChargeGroup>();

        for(EditChargeGroupRow editChargeGroupRow : editChargeGroupRows) {
            if(editChargeGroupRow.isPercentProduct) {
                percentProductCharges.add(editChargeGroupRow.chargeGroup);
            }
        }

        return percentProductCharges;
    }

    // ------------------------------------------------------------------------
    // --- Public Methods ---
    // ------------------------------------------------------------------------

    /**
     *  Constructor
     */
    public Z_EditCharges(ApexPages.StandardController controller) {

        // Save the controller in attribute (for validation)
        this.controller = controller;

        // Before validation
        initSuccess = false;

        // Don't display the product catalog initially
        displayProductCatalog = false;

        // Validate the context
        if (!validate()) {
            return;
        }

        if(custPercentFieldsEmpty()) {
            populateCustomPercentProductFieldsOnPage();
        }

        getSubscriptionMap();

        initSuccess = true;
    }

    /**
     * Redirects to Z_ProductSelector
     */
    public PageReference productSelector() {
        PageReference Z_ProductSelector = Page.Z_ProductSelector;
        Z_ProductSelector.setRedirect(true);
        Z_ProductSelector.getParameters().put('id', quote.id);
        return Z_ProductSelector;
    }

    /**
     * On load (DML operations here)
     */
    public void onLoad() {
        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = new Set<String>
            { 'Box_Discount__c'
            , 'List_Price__c'
            , 'Upsell_Price__c'
            , 'Upsell_Quantity__c'
            };

        // If any, update the charge group
        if (String.isNotBlank(ApexPages.currentPage().getParameters().get('selected'))) {
            System.debug('##### Trying to refresh ' + ApexPages.currentPage().getParameters().get('selected'));

            System.debug('>>>>>>>>>>this.quote='+this.quote);

            for (EditChargeGroupRow editChargeGroupRow : editChargeGroupRowList) {
                zqu.ZChargeGroup chargeGroup = editChargeGroupRow.chargeGroup;

                if (chargeGroup.groupId == ApexPages.currentPage().getParameters().get('selected')) {
                    zqu.zQuoteUtil.updateChargeGroup(chargeGroup);
                }
            }
        }

        refreshAmendmentList();

    }


    /**
     *  Display the product catalog
     */
    public void doDisplayProductCatalog() {

        displayProductCatalog = true;

    }


    /**
     *  Cancel display product catalog
     */
    public void cancelDisplayProductCatalog() {

        displayProductCatalog = false;

    }


    /**
     *  Undo an amendment in DRAFT mode (not yet sent to Z-Billing)
     */
    public PageReference undoAmendment() {
        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = new Set<String>
            { 'Box_Discount__c'
            , 'List_Price__c'
            , 'Upsell_Price__c'
            , 'Upsell_Quantity__c'
            };

        System.debug('##### Trying to undo the quote amendment ID = ' + quoteAmendmentToUndo);

        // Get the amendment type
        String amendmentType = quoteAmendmentMap.get(quoteAmendmentToUndo).zqu__Type__c;

        // Retrieve the quote rate plan that correspond to the amendment
        List<zqu__QuoteRatePlan__c> quoteRatePlanList = [
            SELECT
                Name,
                zqu__ProductRatePlanZuoraId__c,
                zqu__SubscriptionRatePlanZuoraId__c
            FROM
                zqu__QuoteRatePlan__c
            WHERE
                zqu__QuoteAmendment__c = :quoteAmendmentToUndo
        ];

        // Test what we retrieved at least one quote rate plan
        if (quoteRatePlanList.size() == 0) {
            // abort
            appendMessage(ApexPages.Severity.ERROR, 'An error occurred while undoing the '
                + 'quote amendment. Please contact your administrator.');
            return null;
        }

        // Condition because the ZChargeGroup.groupId is different if it's of type
        // Add Product or Update/Remove Product
        if (amendmentType == 'NewProduct') {

            System.debug('##### This is an amendment of type New Product');

            // Get the quote rate plan ID since it's an Add Product amendment
            String quoteRatePlanId = quoteRatePlanList[0].Id;

            // Loop through the charge group and remove the one corresponding
            for (EditChargeGroupRow editChargeGroupRow : editChargeGroupRowList) {
                zqu.ZChargeGroup chargeGroup = editChargeGroupRow.chargeGroup;

                if (chargeGroup.groupId == quoteRatePlanId) {
                    // Undo this amendment
                    zqu.ZQuoteUtil.deleteChargeGroup(chargeGroup);
                    break;
                }
            }

        } else if (amendmentType == 'UpdateProduct' || amendmentType == 'RemoveProduct') {

            System.debug('##### This is an amendment of type Update/Remove Product');

            // Get the subscription rate plan ID since it's an Update/Remove Product amendment
            String subscriptionRatePlanId = quoteRatePlanList[0].zqu__SubscriptionRatePlanZuoraId__c;

            // Loop through the charge group and remove the one corresponding
            for (EditChargeGroupRow editChargeGroupRow : editChargeGroupRowList) {
                zqu.ZChargeGroup chargeGroup = editChargeGroupRow.chargeGroup;

                if (chargeGroup.groupId == subscriptionRatePlanId) {
                    // Undo this amendment
                    zqu.ZQuoteUtil.deleteChargeGroup(chargeGroup);
                    break;
                }
            }

        }

        // Display success message
        appendMessage(ApexPages.Severity.CONFIRM,
            'You successfuly removed the amendment from the quote');

        // Need to refresh the page because of "uncommitted work pending"
        PageReference pageRef = Page.Z_EditCharges;
        pageRef.getParameters().put('id', quote.Id);
        pageRef.setRedirect(true);

        return pageRef;
    }


    /**
     *  Delete the given charge group
     */
    public PageReference deleteGroup() {

        System.debug('##### Trying to delete the charge group ' + selectedChargeGroup);

        // appendMessage(ApexPages.Severity.INFO, Trying to delete the charge group ' + selectedChargeGroup);

        for (EditChargeGroupRow editChargeGroupRow : editChargeGroupRowList) {
            zqu.ZChargeGroup chargeGroup = editChargeGroupRow.chargeGroup;

            if (chargeGroup.groupId == selectedChargeGroup) {

                // Box
                ProductPairingUtility.DeleteChargeGroup(chargeGroup, pluckChargeGroups(editChargeGroupRowList), quote);

                // Delete the charge group
                zqu.ZQuoteUtil.deleteChargeGroups(new List<zqu.ZChargeGroup> { chargeGroup } );
                break;
            }
        }

        // Need to refresh the page because of "uncommitted work pending"
        PageReference pageRef = Page.Z_EditCharges;
        pageRef.getParameters().put('id', quote.Id);
        pageRef.setRedirect(true);

        return pageRef;
    }


    /**
     *  Undelete the given charge group
     */
    public PageReference unDeleteGroup() {

        System.debug('##### Trying to undelete the charge group ' + selectedChargeGroup);

        // appendMessage(ApexPages.Severity.INFO, Trying to undelete the charge group ' + selectedChargeGroup);

        for (EditChargeGroupRow editChargeGroupRow : editChargeGroupRowList) {
            zqu.ZChargeGroup chargeGroup = editChargeGroupRow.chargeGroup;

            if (chargeGroup.groupId == selectedChargeGroup) {
                // Delete the charge group
                zqu.ZQuoteUtil.deleteChargeGroups(new List<zqu.ZChargeGroup> { chargeGroup } );
                break;
            }
        }

        // Need to refresh the page because of "uncommitted work pending"
        PageReference pageRef = Page.Z_EditCharges;
        pageRef.getParameters().put('id', quote.Id);
        pageRef.setRedirect(true);

        return pageRef;
    }


    /**
     *  Edit the given charge group
     */
    public void editGroup() {
        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = new Set<String>
            { 'Box_Discount__c'
            , 'List_Price__c'
            , 'Upsell_Price__c'
            , 'Upsell_Quantity__c'
            };

        System.debug('#### Before ' + groupEditMap);

        // Cancel all editing mode for all the other charge group
        for (String groupId : groupEditMap.keySet()) {
            groupEditMap.put(groupId, EditMode.NO_EDIT.name());
        }

        if(custPercentFieldsEmpty()) {
            PricingRules.populateCustomPercentProductFields(pluckChargeGroups(editChargeGroupRowList));
        }

        System.debug('#### After ' + groupEditMap);

        for (EditChargeGroupRow editChargeGroupRow : editChargeGroupRowList) {
            zqu.ZChargeGroup chargeGroup = editChargeGroupRow.chargeGroup;

            // For the selected charge group
            if (chargeGroup.groupId == selectedChargeGroup) {
                if(editChargeGroupRow.isPercentProduct) {
                    groupEditMap.put(selectedChargeGroup, EditMode.DISCOUNT.name());
                }
                // If it's a newly added product, we can edit every field (discount, list price, etc.)
                else if (chargeGroup.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_NEWPRODUCT) {
                    groupEditMap.put(selectedChargeGroup, EditMode.FULL.name());
                }
                // Else, it's an original/updated product, we can only edit the quantity
                else {
                    groupEditMap.put(selectedChargeGroup, EditMode.FULL.name());
                }
                break;
            }
        }
    }

    /**
     *  Cancel edit charge group
     */
    public void cancelEditGroup() {
        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = new Set<String>
            { 'Box_Discount__c'
            , 'List_Price__c'
            , 'Upsell_Price__c'
            , 'Upsell_Quantity__c'
            };

        // Cancel all editing mode for all the other charge group
        for (String groupId : groupEditMap.keySet()) {
            groupEditMap.put(groupId, EditMode.NO_EDIT.name());
        }

        // Reload the charge groups from the DB
        editChargeGroupRowList = chargeGroupsToEditChargeGroupRows(zqu.ZQuoteUtil.getChargeGroups(quote.Id));

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
     *  Save edited charge group
     */
    public PageReference saveGroup() {

        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = new Set<String>
            { 'Box_Discount__c'
            , 'List_Price__c'
            , 'Upsell_Price__c'
            , 'Upsell_Quantity__c'
            };

        // Retrieve the selected charge group
        for (EditChargeGroupRow editChargeGroupRow : editChargeGroupRowList) {
            zqu.ZChargeGroup chargeGroup = editChargeGroupRow.chargeGroup;

            if (chargeGroup.groupId == selectedChargeGroup) {

                // Check to see if the quantity was set to 0, delete any chargeGroup that has 0 quantity
                Boolean quantitySetToZero = false;
                for (EditChargeRow currentChargeRow : editChargeGroupRow.editChargeRows) {
                    if (currentChargeRow.upsellQuantity == 0 && currentChargeRow.getOriginalUpsellQuantity() != 0) {
                        zqu.ZQuoteUtil.deleteChargeGroup(chargeGroup);
                        quantitySetToZero = true;
                        break;
                    }
                }

                // Only update the product if the quantity wasn't set to zero
                if (!quantitySetToZero) {
                    // Box
                    appendMessages(Z_QuoteChargeValidationUtility.validate(quote.Id, chargeGroup));
                    if(ApexPages.hasMessages()){
                        return null;
                    }

                    // Box
                    ProductPairingUtility.EditChargeGroup(chargeGroup, pluckChargeGroups(editChargeGroupRowList), quote);

                    zqu.ZQuoteUtil.updateChargeGroup(chargeGroup);

                    if(!editChargeGroupRow.isPercentProduct) {
                        updatePercentProduct(editChargeGroupRow, editChargeGroupRowList);
                    }

                    break;
                }
            }
        }

        //updateQuoteAmendmentTotal(quote.Id, selectedChargeGroup);

        // Need to refresh the page because of "uncommitted work pending"
        PageReference pageRef = Page.Z_EditCharges;
        pageRef.getParameters().put('id', quote.Id);
        pageRef.getParameters().put('selected', selectedChargeGroup);
        pageRef.setRedirect(true);

        return pageRef;
    }


    /**
     *  Update charge group on discount change
     */
    public void onDiscountChange() {

        // Retrieve the charge group
       for (EditChargeGroupRow editChargeGroupRow : editChargeGroupRowList) {
            zqu.ZChargeGroup chargeGroup = editChargeGroupRow.chargeGroup;

            if (chargeGroup.groupId == selectedChargeGroup) {
                List<zqu.zCharge> charges = zqu.zQuoteUtil.calculateChargesOnDiscountChange(
                    chargeGroup.zCharges
                );
                chargeGroup.zCharges = charges;
            }
        }

    }


    /**
     *  Update charge group on quantity change
     */
    public void onQuantityChange() {

        // Retrieve the charge group
        for (EditChargeGroupRow editChargeGroupRow : editChargeGroupRowList) {
            zqu.ZChargeGroup chargeGroup = editChargeGroupRow.chargeGroup;

            if (chargeGroup.groupId == selectedChargeGroup) {
                List<zqu.zCharge> charges = zqu.zQuoteUtil.calculateChargesOnQuantityChange(
                    chargeGroup.zCharges
                );
                chargeGroup.zCharges = charges;
            }
        }

    }


    /**
     *  Update charge group on effective price change
     */
    public void onEffectivePriceChange() {

        // Retrieve the charge group
        for (EditChargeGroupRow editChargeGroupRow : editChargeGroupRowList) {
            zqu.ZChargeGroup chargeGroup = editChargeGroupRow.chargeGroup;

            if (chargeGroup.groupId == selectedChargeGroup) {
                List<zqu.zCharge> charges = zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(
                    chargeGroup.zCharges
                );
                chargeGroup.zCharges = charges;
            }
        }

    }


    /**
     *  Update charge group on total change
     */
    public void onTotalChange() {

        // Retrieve the charge group
        for (EditChargeGroupRow editChargeGroupRow : editChargeGroupRowList) {
            zqu.ZChargeGroup chargeGroup = editChargeGroupRow.chargeGroup;

            if (chargeGroup.groupId == selectedChargeGroup) {
                List<zqu.zCharge> charges = zqu.zQuoteUtil.calculateChargesOnTotalChange(
                    chargeGroup.zCharges
                );
                chargeGroup.zCharges = charges;
            }
        }

    }

    /**
     *  Update charge group on upsell price change
     */
    public void onUpsellPriceChange() {
        // Retrieve the charge group
        for (EditChargeGroupRow editChargeGroupRow : editChargeGroupRowList) {
            zqu.ZChargeGroup chargeGroup = editChargeGroupRow.chargeGroup;
            if (chargeGroup.groupId == selectedChargeGroup) {
                List<EditChargeRow> chargeRows = editChargeGroupRow.editChargeRows;
                for (EditChargeRow currentChargeRow : chargeRows) {
                    zqu.ZCharge charge = currentChargeRow.charge;
                     System.debug('3>>>>>>>charge.EFFECTIVE_PRICE='+charge.EFFECTIVE_PRICE);
                    charge.TOTAL = String.valueOf(calculateTotalCost(charge, currentChargeRow));
                }
                List<zqu.zCharge> charges = zqu.zQuoteUtil.calculateChargesOnTotalChange(chargeGroup.zCharges);
                chargeGroup.zCharges = charges;
            }
        }
    }

    /**
     * Update charge group on quantity change
     */
    public void onUpsellQuantityChange() {
        // For each editChargeGroupRow on this controller
        for (EditChargeGroupRow editChargeGroupRow : editChargeGroupRowList) {
            zqu.ZChargeGroup chargeGroup = editChargeGroupRow.chargeGroup;
            // Just find the selected charge group
            if (chargeGroup.groupId == selectedChargeGroup) {
                List<EditChargeRow> chargeRows = editChargeGroupRow.editChargeRows;
                for (EditChargeRow currentChargeRow : chargeRows) {
                    zqu.ZCharge charge = currentChargeRow.charge;
                    charge.QUANTITY = String.valueOf(currentChargeRow.getOriginalQuantity() + currentChargeRow.upsellQuantity - currentChargeRow.getOriginalUpsellQuantity());
                    System.debug('Quantity: ' + charge.QUANTITY);
                }
                List<zqu.zCharge> charges = zqu.zQuoteUtil.calculateChargesOnQuantityChange(chargeGroup.zCharges);
                for (EditChargeRow currentChargeRow : chargeRows) {
                    zqu.ZCharge charge = currentChargeRow.charge;
                    System.debug('4 >>>>>>>charge.EFFECTIVE_PRICE='+charge.EFFECTIVE_PRICE);
                    charge.TOTAL = String.valueOf(calculateTotalCost(charge, currentChargeRow));
                    System.debug('Total Price: ' + charge.TOTAL);
                }
                charges = zqu.zQuoteUtil.calculateChargesOnTotalChange(charges);
                
                
                chargeGroup.zCharges = charges;
            }
        }
    }

    public void customDiscountEdit() {
        for(EditChargeGroupRow editChargeGroupRow : editChargeGroupRowList) {
            if(editChargeGroupRow.chargeGroup.groupId == selectedChargeGroup) {
                PricingRules.updateTotalWithCustomDiscount(editChargeGroupRow.chargeGroup);
            }
        }
    }

    // ------------------------------------------------------------------------
    // --- Private Methods ---
    // ------------------------------------------------------------------------

    private static Decimal calculateBlendedPrice(zqu.ZCharge charge, EditChargeRow chargeRow) {
        // Calculate current cost
        Decimal currentQuantity = chargeRow.getOriginalQuantity();
        System.debug('Current Quantity: ' + currentQuantity);
        Decimal currentPrice = chargeRow.getOriginalPrice();
        System.debug('Current Price:' + currentPrice);
        Decimal currentCost = currentQuantity * currentPrice;
        System.debug('Current Cost w/ upsell: ' + currentCost);
        // Subtract previous upsell amount (from this same quote)
        Decimal oldUpsellQuantity = chargeRow.getOriginalUpsellQuantity();
        Decimal oldUpsellPrice = chargeRow.getOriginalUpsellPrice();
        Decimal oldUpsellCost = oldUpsellQuantity * oldUpsellPrice;
        System.debug('Old Upsell Cost: ' + oldUpsellCost);
        // Now recalculate current values
        currentCost = currentCost - oldUpsellCost;
        currentQuantity = currentQuantity - oldUpsellQuantity;
        currentPrice = currentCost / currentQuantity;
        System.debug('Current cost w/o upsell: ' + currentCost);
        // Now calculate blended price
        Decimal upsellQuantity = chargeRow.upsellQuantity;
        Decimal upsellPrice = chargeRow.upsellPrice;
        Decimal upsellCost = upsellQuantity * upsellPrice;
        Decimal totalCost = currentCost + upsellCost;
        System.debug('Total Cost: ' + totalCost);
        Decimal totalQuantity = currentQuantity + upsellQuantity;
        System.debug('Total Quantity: ' + totalQuantity);
        Decimal blendedPrice = totalCost / totalQuantity;
        blendedPrice.setScale(2);
        return blendedPrice;
    }

    private static Decimal calculateTotalCost(zqu.ZCharge charge, EditChargeRow chargeRow) {
        Decimal currentQuantity = chargeRow.getOriginalQuantity();
        System.debug('Current Quantity: ' + currentQuantity);
        Decimal currentCost = chargeRow.getOriginalTotal();
        System.debug('Current Total Cost: ' + currentCost);
        Decimal previousUpsellQuantity = chargeRow.getOriginalUpsellQuantity();
        System.debug('Previous Upsell Quantity: ' + previousUpsellQuantity);
        Decimal previousUpsellPrice = chargeRow.getOriginalUpsellPrice();
        System.debug('Previous Upsell Price: ' + previousUpsellPrice);
        Decimal previousUpsellTotalCost = previousUpsellPrice * previousUpsellQuantity;
        System.debug('Previous Upsell Total Cost: ' + previousUpsellTotalCost);
        Decimal nonUpsellQuantity = currentQuantity - previousUpsellQuantity;
        System.debug('Non-Upsell Quantity: ' + nonUpsellQuantity);
        Decimal nonUpsellCost = currentCost - previousUpsellTotalCost;
        System.debug('Non-Upsell Total Cost: ' + nonUpsellCost);
        Decimal newUpsellQuantity = chargeRow.upsellQuantity;
        System.debug('New Upsell Quantity: ' + newUpsellQuantity);
        Decimal newUpsellPrice = chargeRow.upsellPrice;
        System.debug('New Upsell Price: ' + newUpsellPrice);
        Decimal newUpsellTotalCost = newUpsellPrice * newUpsellQuantity;
        System.debug('New Upsell Total Cost: ' + newUpsellTotalCost);
        Decimal newTotalQuantity = nonUpsellQuantity + newUpsellQuantity;
        System.debug('New Total Quantity: ' + newTotalQuantity);
        Decimal newTotalCost = nonUpsellCost + newUpsellTotalCost;
        System.debug('New Total Cost: ' + newTotalCost);
        return newTotalCost;
        // Calculate current cost
        /*
        System.debug('Current Quantity: ' + currentQuantity);
        Decimal currentPrice = chargeRow.getOriginalPrice();
        System.debug('Current Price:' + currentPrice);
        Decimal currentCost = currentQuantity * currentPrice;
        System.debug('Current Cost w/ upsell: ' + currentCost);
        // Subtract previous upsell amount (from this same quote)
        Decimal oldUpsellQuantity = chargeRow.getOriginalUpsellQuantity();
        System.debug('Old Upsell Quantity: ' + oldUpsellQuantity);
        Decimal oldUpsellPrice = chargeRow.getOriginalUpsellPrice();
        Decimal oldUpsellCost = oldUpsellQuantity * oldUpsellPrice;
        System.debug('Old Upsell Cost: ' + oldUpsellCost);
        // Now recalculate current values
        currentCost = currentCost - oldUpsellCost;
        System.debug('currentQuantity: ' + currentQuantity);        
        currentQuantity = currentQuantity - oldUpsellQuantity;
        System.debug('currentQuantity: ' + currentQuantity);   
        currentPrice = currentCost / currentQuantity;
        System.debug('Current cost w/o upsell: ' + currentCost);
        // Now calculate blended price
        Decimal upsellQuantity = chargeRow.upsellQuantity;
        Decimal upsellPrice = chargeRow.upsellPrice;
        Decimal upsellCost = upsellQuantity * upsellPrice;
        Decimal totalCost = currentCost + upsellCost;
        return totalCost;
        */
    }

    /**
     *  Display an error message back to the VF page
     */
    private static void appendMessage(ApexPages.Severity severity, String message) {
        ApexPages.addMessage(new ApexPages.Message(severity, message));
    }


    /**
     *  Validate the quote context
     */
    private Boolean validate() {

        // Validate that we are passing an ID in parameter
        if (null == controller.getRecord() || null == controller.getRecord().Id) {
            appendMessage(ApexPages.Severity.ERROR,
                    'Need to specify the quote id to edit the subscription charges');
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
                processing__c 
            FROM
                zqu__Quote__c
            WHERE
                Id = :quoteId
        ];

        // Validate that we retrieved the quote
        if (1 != quoteList.size()) {
            appendMessage(ApexPages.Severity.ERROR,
                    'No quote found with the ID passed in parameter');
            return false;
        }

        this.quote = quoteList[0];


		if(this.quote.processing__c){
            appendMessage(ApexPages.Severity.WARNING, LABEL.Z_QUOTE_PROCESSING_WARNING);
            return false;
		}





        // Refresh amendment
        refreshAmendmentList();

        // Get the charge group
        editChargeGroupRowList = chargeGroupsToEditChargeGroupRows(Z_ProductSelector.getStaticChargeGroups(quote.Id));

        // Instantiate the map wich everything in not edit mode at first
        groupEditMap = new Map<String, String>();

        for (EditChargeGroupRow editChargeGroupRow : editChargeGroupRowList) {
            zqu.ZChargeGroup chargeGroup = editChargeGroupRow.chargeGroup;

            groupEditMap.put(chargeGroup.groupId, EditMode.NO_EDIT.name());
        }

        // Initialization successful
        return true;
    }


    /**
     *  Refresh the quote amendment list (for the changes vs. Original section)
     */
    private void refreshAmendmentList() {
        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = new Set<String>
            { 'Box_Discount__c'
            , 'List_Price__c'
            , 'Upsell_Price__c'
            , 'Upsell_Quantity__c'
            };

        // Retrieve the list of amendments associated with the quote
        quoteAmendmentList = [
            SELECT
                zqu__Description__c,
                zqu__TotalAmount__c,
                zqu__DeltaMRR__c,
                zqu__Type__c,
                zqu__DeltaTCV__c
            FROM
                zqu__QuoteAmendment__c
            WHERE
                zqu__Quote__c = :quote.Id
        ];

        // Set up the map
        quoteAmendmentMap = new Map<Id, zqu__QuoteAmendment__c>(quoteAmendmentList);

    }

    void updatePercentProduct(EditChargeGroupRow editChargeGroupRow, List<EditChargeGroupRow> editChargeGroupRowList) {
        List<zqu.ZChargeGroup> percentProductCharges = getPercentProductCharges(editChargeGroupRowList);
        if(!percentProductCharges.isEmpty()) {
            PricingRules.updatePercentProduct(percentProductCharges, pluckChargeGroups(editChargeGroupRowList));
        }
    }

    Boolean custPercentFieldsEmpty() {
        for(EditChargeGroupRow editChargeGroupRow : editChargeGroupRowList) {
            if(editChargeGroupRow.isPercentProduct) {
                   for(EditChargeRow editChargeRow : editChargeGroupRow.editChargeRows) {
                       if(editChargeRow.discount == null || editChargeRow.listPrice == null) {
                           return true;
                       }
                   }
            }
        }

        return false;
    }

    void populateCustomPercentProductFieldsOnPage() {
        for(EditChargeGroupRow editChargeGroupRow : editChargeGroupRowList) {
            if(editChargeGroupRow.isPercentProduct) {
                Map<zqu.zCharge, Zuora__SubscriptionProductCharge__c> chargeToSubscriptionCharge = PricingRules.getRelatedSubscriptionCharge(editChargeGroupRow.chargeGroup);
                for(EditChargeRow editChargeRow : editChargeGroupRow.editChargeRows) {
                    Zuora__SubscriptionProductCharge__c subscriptionCharge = chargeToSubscriptionCharge.get(editChargeRow.charge);
                    if(subscriptionCharge != null) {
                        if (subscriptionCharge.Box_Discount__c != null) {
                            editChargeRow.discount = Decimal.valueOf(subscriptionCharge.Box_Discount__c);
                        }
                        else {
                            editChargeRow.discount = 0.00;
                        }
                        if (subscriptionCharge.List_Price__c != null) {
                            editChargeRow.listPrice = Decimal.valueOf(subscriptionCharge.List_Price__c);
                        }
                        else {
                            editChargeRow.listPrice = 0.00;
                        }
                        
                    }
                }
            }
        }
    }

    void getSubscriptionMap() {
        subscriptionMap = new Map<String, Boolean>();
        for(EditChargeGroupRow editChargeGroupRow : editChargeGroupRowList) {
            Map<zqu.zCharge, Zuora__SubscriptionProductCharge__c> chargeToSubscriptionCharge = PricingRules.getRelatedSubscriptionCharge(editChargeGroupRow.chargeGroup);
            subscriptionMap.put(editChargeGroupRow.chargeGroup.groupId, chargeToSubscriptionCharge.isEmpty());
        }
    }
    
    public PageReference returnToQuote() {

		Id quoteId = quote.Id;
		
		zqu__Quote__c q = new zqu__Quote__c (Id=quoteId);
		
		try{
			// update quote so it has current info.
			update q;
		
		}catch(Exception e){
            appendMessage(ApexPages.Severity.ERROR,  'Unable to return to quote');
            return null;
		}	
		return new PageReference('/' + quoteId);    	
    }    
}