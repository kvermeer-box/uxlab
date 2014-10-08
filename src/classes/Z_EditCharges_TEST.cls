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

@isTest
public class Z_EditCharges_TEST {
    static zqu__Quote__c quote;
    static zqu__ZProduct__c parentProduct;
    static List<zqu__ProductRatePlan__c> parentProductRatePlan;
    static zqu__ZProduct__c percentProduct;
    static List<zqu__ProductRatePlan__c> percentProductRatePlan;
    static zqu.zChargeGroup percentCharge;
    static zqu.zChargeGroup parentCharge;

    static Pricing_Rule__c pricingRule;
    static Zuora__SubscriptionProductCharge__c subscriptionCharge;
    static zqu__QuoteAmendment__c quoteAmendment;

    static final String percentName = 'Percent Product';
    static final String oldValue = '10.00';
    static final String newValue = '50.00';

    public static void setup() { 
        Amount_Threshold__c threshold = Z_TestUtils.createAmountThreshold(true);

        parentProduct = TestFactory.prepareProductCatalog(TestFactory.rateplannames);
        percentProduct = TestFactory.prepareProductCatalog(TestFactory.rateplanKHnames);

        percentProduct.Name = percentName;
        update percentProduct;

        Account account = TestFactory.makeAccount();
        Opportunity opportunity = TestFactory.makeOpportunity(account);
        quote = TestFactory.makeQuote(opportunity);

        parentProductRatePlan = [
            SELECT Name, zqu__ZuoraId__c
            FROM zqu__ProductRatePlan__c
            WHERE zqu__ZProduct__c = :parentProduct.Id
        ];

        percentProductRatePlan = [
            SELECT Id
            FROM zqu__ProductRatePlan__c
            WHERE zqu__ZProduct__c = :percentProduct.Id
        ];

        pricingRule = Z_TestUtils.createPricingRule(parentProduct.Id, percentProduct.Id, 15, true);
        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = new Set<String>
            { 'Box_Discount__c'
            , 'List_Price__c'
            , 'Upsell_Price__c'
            , 'Upsell_Quantity__c'
            };

        percentCharge = zqu.zQuoteUtil.getChargeGroups(quote.Id, new List<Id>{percentProductRatePlan[0].Id})[0];
        for(zqu.zCharge zcharge : percentCharge.zCharges) {
            zcharge.TOTAL = oldValue;
        }
        percentCharge.zCharges = zqu.zQuoteUtil.calculateChargesOnTotalChange(percentCharge.zCharges);
        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = new Set<String>
            { 'Box_Discount__c'
            , 'List_Price__c'
            , 'Upsell_Price__c'
            , 'Upsell_Quantity__c'
            };
        parentCharge = zqu.zQuoteUtil.getChargeGroups(quote.Id, new List<Id>{parentProductRatePlan[0].Id})[0];
        for(zqu.zCharge zcharge : parentCharge.zCharges) {
            zcharge.TOTAL = oldValue;
        }
        parentCharge.zCharges = zqu.zQuoteUtil.calculateChargesOnTotalChange(parentCharge.zCharges);
        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = new Set<String>
            { 'Box_Discount__c'
            , 'List_Price__c'
            , 'Upsell_Price__c'
            , 'Upsell_Quantity__c'
            };
        List<zqu.zChargeGroup> cgList = zqu.zQuoteUtil.addChargeGroups(new List<zqu.zChargeGroup>{parentCharge, percentCharge});
        Zuora__Subscription__c subscription = Z_TestUtils.createZSubscription(account.Id, true);
        subscriptionCharge = Z_TestUtils.createZSubscriptionProductCharge(subscription.Id, percentProduct.zqu__SKU__c, account.Id, false);
        subscriptionCharge.Zuora__External_Id__c = 'HK-47';
        subscriptionCharge.Box_Discount__c = '0.00';
        subscriptionCharge.List_Price__c = '100.00';
        insert subscriptionCharge;

        
        List<zqu__QuoteAmendment__c> qaList = [SELECT Id FROM zqu__QuoteAmendment__c where zqu__Quote__c = : quote.Id LIMIT 1];
        if(qaList.size() > 0){
            quoteAmendment = qaList[0];
        }
    }

    static testMethod void testDisplayNoQuoteFound() {

        Test.startTest();

        ApexPages.StandardController stdController = new ApexPages.StandardController(new zqu__Quote__c());
        Z_EditCharges ctl = new Z_EditCharges(stdController);

        Test.stopTest();
    }

    static testMethod void testDisplayWrongQuoteId() {

        // Create a non-quote object (to get a correct ID but wrong object)
        Account acc = TestFactory.makeAccount();

        Test.startTest();

        ApexPages.Standardcontroller stdController = new ApexPages.StandardController(acc);
        Z_EditCharges ctl = new Z_EditCharges(stdController);

        Test.stopTest();
    }


    static testMethod void testDisplayNoProduct() {

        // Create the quote object
        Account acc = TestFactory.makeAccount();
        Opportunity opp = TestFactory.makeOpportunity(acc);
        quote = TestFactory.makeQuote(opp);

        Test.startTest();

        ApexPages.Standardcontroller stdController = new ApexPages.StandardController(quote);
        Z_EditCharges ctl = new Z_EditCharges(stdController);

        Test.stopTest();
    }


    static testMethod void testDisplayProduct() {

        // Setup the product catalog
        zqu__ZProduct__c product = TestFactory.prepareProductCatalog(TestFactory.rateplannames);

        // Create the quote object
        Account acc = TestFactory.makeAccount();
        Opportunity opp = TestFactory.makeOpportunity(acc);
        quote = TestFactory.makeQuote(opp);

        // Update quote information
        quote.zqu__Currency__c = 'USD';
        quote.zqu__StartDate__c = Date.today().addDays(1);
        update quote;

        Amount_Threshold__c threshold = Z_TestUtils.createAmountThreshold(true);

        // Make a quote amendment
        quoteAmendment = new zqu__QuoteAmendment__c();
        quoteAmendment.zqu__Description__c = 'test amendment';
        quoteAmendment.zqu__TotalAmount__c = 150;
        quoteAmendment.zqu__Type__c = 'AddProduct';
        quoteAmendment.zqu__Quote__c = quote.Id;

        insert quoteAmendment;

        Test.startTest();

        ApexPages.Standardcontroller stdController = new ApexPages.StandardController(quote);
        Z_EditCharges ctl = new Z_EditCharges(stdController);

        // Display/Cancel catalog
        ctl.doDisplayProductCatalog();
        ctl.cancelDisplayProductCatalog();

        // Add a charge to the quote
        List<zqu__ProductRatePlan__c> prpList = [
            SELECT
                Name
            FROM
                zqu__ProductRatePlan__c
            WHERE
                zqu__ZProduct__c = :product.Id
        ];

        ctl.toBeAddedChargeGroup = zqu.ZQuoteUtil.getChargeGroup(quote.Id, prpList[0].Id);

        // Charge group added to the quote
        zqu.ZChargeGroup addedChargeGroup = zqu.ZQuoteUtil.addChargeGroup(ctl.toBeAddedChargeGroup);

        ctl.selectedChargeGroup = addedChargeGroup.groupId;

        // On load
        ctl.onLoad();

        // Cancel an amendment
        ctl.quoteAmendmentToUndo = quoteAmendment.Id;
        ctl.undoAmendment();

        ctl.deleteGroup();
        ctl.unDeleteGroup();
        ctl.editGroup();
        ctl.cancelEditGroup();
        ctl.saveGroup();

        // Changes in the charge group
        ctl.onDiscountChange();
        ctl.onQuantityChange();
        ctl.onEffectivePriceChange();
        ctl.onTotalChange();

        Test.stopTest();
    }

    //Bluewolf Tests
    static testMethod void productSelectorTest() {
        setup();

        Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(quote);
            Z_EditCharges ctl = new Z_EditCharges(stdController);
            PageReference actual = ctl.productSelector();
        Test.stopTest();

        system.assert(ApexPages.getMessages().isEmpty(), 'there should be no errors '+ApexPages.getMessages());
        system.assertNotEquals(null, actual, 'a page reference should have been returned');
    }

    static testMethod void undoAmendmentTest_New() {
        setup();

        Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(quote);
            Z_EditCharges ctl = new Z_EditCharges(stdController);
            quoteAmendment = Z_TestUtils.createQuoteAmendment(quote.Id, true);
            zqu__QuoteRatePlan__c quoteRatePlan = Z_TestUtils.createQuoteRatePlan(quote.Id, quoteAmendment.Id, parentProductRatePlan[0].zqu__ZuoraId__c, subscriptionCharge.Zuora__External_Id__c, true);
            ctl.quoteAmendmentMap.put(quoteAmendment.Id, quoteAmendment);

            ctl.quoteAmendmentToUndo = quoteAmendment.Id;
            PageReference actual = ctl.undoAmendment();
        Test.stopTest();

        system.assert(!ApexPages.hasMessages(ApexPages.Severity.ERROR), 'there should be no errors '+ApexPages.getMessages());
        system.assert(ApexPages.hasMessages(ApexPages.Severity.CONFIRM), 'a success message should have been given to the page');

    }

    static testMethod void undoAmendmentTest_Update() {
        setup();


        Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(quote);
            Z_EditCharges ctl = new Z_EditCharges(stdController);
            quoteAmendment = Z_TestUtils.createQuoteAmendment(quote.Id, false);
            quoteAmendment.zqu__Type__c = 'UpdateProduct';
            insert quoteAmendment;

            ctl.quoteAmendmentMap.put(quoteAmendment.Id, quoteAmendment);
            zqu__QuoteRatePlan__c quoteRatePlan = Z_TestUtils.createQuoteRatePlan(quote.Id, quoteAmendment.Id, parentProductRatePlan[0].zqu__ZuoraId__c, subscriptionCharge.Zuora__External_Id__c, true);

            ctl.quoteAmendmentToUndo = quoteAmendment.Id;
            PageReference actual = ctl.undoAmendment();
        Test.stopTest();

        system.assert(!ApexPages.hasMessages(ApexPages.Severity.ERROR), 'there should be no errors '+ApexPages.getMessages());
        system.assert(ApexPages.hasMessages(ApexPages.Severity.CONFIRM), 'a success message should have been given to the page');

    }


    static testMethod void deleteGroupTest() {
        setup();

        Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(quote);
            Z_EditCharges ctl = new Z_EditCharges(stdController);
            ctl.selectedChargeGroup = percentCharge.groupId;
            PageReference actual = ctl.deleteGroup();
        Test.stopTest();

        system.assert(ApexPages.getMessages().isEmpty(), 'there should be no errors '+ApexPages.getMessages());
        system.assertNotEquals(null, actual, 'a page reference should have been returned');

        List<zqu.zChargeGroup> chargeGroups = zqu.zQuoteUtil.getChargeGroups(quote.Id);
        system.assertEquals(1, chargeGroups.size(), 'there should only be one charge group');
        system.assertEquals(parentCharge.groupId, chargeGroups[0].groupId, 'the remaining charge group should be the non-deleted group');
    }

    static testMethod void editGroupTest_DISCOUNT() {
        setup();

        Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(quote);
            Z_EditCharges ctl = new Z_EditCharges(stdController);
            for(zqu.zCharge zcharge : percentCharge.zCharges) {
                zcharge.TOTAL = newValue;
            }
            ctl.selectedChargeGroup = percentCharge.groupId;
            ctl.editGroup();
        Test.stopTest();

        system.assertEquals('DISCOUNT', ctl.groupEditMap.get(percentCharge.groupId), 'the edit mode should be set to discount mode');
    }

    static testMethod void editGroupTest_PARTIAL() {
        setup();

        Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(quote);
            Z_EditCharges ctl = new Z_EditCharges(stdController);
            for(zqu.zCharge zcharge : parentCharge.zCharges) {
                zcharge.TOTAL = newValue;
            }
            ctl.selectedChargeGroup = parentCharge.groupId;
            ctl.editGroup();
        Test.stopTest();

        system.assertEquals('FULL', ctl.groupEditMap.get(parentCharge.groupId), 'the edit mode should be set to discount mode');
    }

    static testMethod void saveGroupTest() {
        setup();

        Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(quote);
            Z_EditCharges ctl = new Z_EditCharges(stdController);
            for(zqu.zCharge zcharge : parentCharge.zCharges) {
                zcharge.TOTAL = newValue;
            }
            parentCharge.zCharges = zqu.zQuoteUtil.calculateChargesOnTotalChange(parentCharge.zCharges);
            ctl.selectedChargeGroup = parentCharge.groupId;
            PageReference actual = ctl.saveGroup();
        Test.stopTest();

 

        system.assert(ApexPages.getMessages().isEmpty(), 'there should be no errors '+ApexPages.getMessages());
        system.assertNotEquals(null, actual, 'a page reference should have been returned');

        Boolean found = false;
        List<zqu.zChargeGroup> chargeGroups = zqu.zQuoteUtil.getChargeGroups(quote.Id);
        for(zqu.zChargeGroup chargeGroup : chargeGroups) {
            if(chargeGroup.groupId == parentCharge.groupId) {
                found = true;
                for(zqu.zCharge zcharge : parentCharge.zCharges) {
                    system.assertEquals(newValue, zcharge.TOTAL, 'the charge total should have been updated');
                }
            }
        }

        system.assert(found, 'charge group was not found and assert was not run');
    }

    static testMethod void customDiscountEditTest() {
        setup();

        Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(quote);
            Z_EditCharges ctl = new Z_EditCharges(stdController);
            for(zqu.zCharge zcharge : percentCharge.zCharges) {
                zcharge.TOTAL = newValue;
            }
            ctl.selectedChargeGroup = percentCharge.groupId;
            ctl.customDiscountEdit();
        Test.stopTest();

        Boolean found = false;
        List<zqu.zChargeGroup> chargeGroups = zqu.zQuoteUtil.getChargeGroups(quote.Id);
        for(zqu.zChargeGroup chargeGroup : chargeGroups) {
            if(chargeGroup.groupId == percentCharge.groupId) {
                found = true;
                for(zqu.zCharge zcharge : percentCharge.zCharges) {
                    system.assertEquals(newValue, zcharge.TOTAL, 'the charge total should have been updated');
                }
            }
        }

        system.assert(found, 'charge group was not found and assert was not run');
    }

   

    static testMethod void customUpsellEditTest() {
        setup();

        Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(quote);
            Z_EditCharges ctl = new Z_EditCharges(stdController);
 

            PageReference returnToQuotePageRef = ctl.returnToQuote();
            
            ctl.onUpsellQuantityChange();
            ctl.onUpsellPriceChange();
            List<Z_EditCharges.EditChargeGroupRow> editChargeGroupRowList = Z_EditCharges.chargeGroupsToEditChargeGroupRows(zqu.ZQuoteUtil.getChargeGroups(quote.Id));
            if (editChargeGroupRowList.size() > 0) { 
                Z_EditCharges.EditChargeGroupRow grpRow = editChargeGroupRowList.get(0);
                List<Z_EditCharges.EditChargeRow> cRow = grpRow.editChargeRows;
                if (cRow.size() > 0) {
                    Z_EditCharges.EditChargeRow row = cRow.get(0);
                    row.getOriginalPrice();
                    row.getOriginalQuantity();
                    row.getOriginalUpsellPrice();
                }
            } 
            
        Test.stopTest();

 
    }
        
}