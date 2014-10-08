@isTest
public with sharing class TestUtils
{
    static Integer dummyIdCounter = 0;
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

    public static Id NEW_AGREEMENT_QUOTE_RECORD_TYPE
    {
        get
        {
            if( NEW_AGREEMENT_QUOTE_RECORD_TYPE == NULL )
            {
                NEW_AGREEMENT_QUOTE_RECORD_TYPE = [ SELECT Id FROM RecordType WHERE sObjectType = 'Quote' AND DeveloperName = 'New_Agreement'][0].id;
            }
            return NEW_AGREEMENT_QUOTE_RECORD_TYPE;
        }
        private set;
    }

    public static Id RENEWAL_OPPORTUNITY_RECORD_TYPE
    {
        get
        {
            if( RENEWAL_OPPORTUNITY_RECORD_TYPE == NULL )
            {
                RENEWAL_OPPORTUNITY_RECORD_TYPE = [SELECT Id FROM RecordType WHERE sObjectType = 'Opportunity' AND DeveloperName = 'Renewal'][0].id;
            }
            return RENEWAL_OPPORTUNITY_RECORD_TYPE;
        }
        private set;
    }

    public static Pricebook2 STANDARD_PRICEBOOK
    {
        get
        {
            if( STANDARD_PRICEBOOK == NULL )
            {
                STANDARD_PRICEBOOK = [SELECT Id FROM Pricebook2 WHERE isStandard=true ];
            }

            return STANDARD_PRICEBOOK;
        }
        private set;
    }

    public static Id generateSObjectDummyId( SObject record )
    {
        String idPrefix = record.getSObjectType().getDescribe().getKeyPrefix();
        String idSuffix = String.valueOf( dummyIdCounter ).leftPad(12);
        idSuffix = idSuffix.replace(' ', '0');
        dummyIdCounter++;
        record.id = idPrefix + idSuffix;
        return record.id;
    }

    public static Competing_Product__c buildCompetingProductSetting( Product2 product )
    {
        return new Competing_Product__c( Name = String.valueOf( product.id ).left(15),
                                         Product_Name__c = product.Name,
                                         Seniority_Rank__c = 1 );
    }

    public static List<Product_Tier__c> buildProductTierSettings( List<Product2> products )
    {
        List<Product_Tier__c> productTierSettings = new List<Product_Tier__c>();
        for( Product2 product : products )
        {
            productTierSettings.add( new Product_Tier__c( Name = String.valueOf( product.id ).left(15), Product_Tier__c = product.Name ) );
        }
        return productTierSettings;
    }

    public static List<Product_Tier__c> createProductTierSettings( List<Product2> products )
    {
        List<Product_Tier__c> productTierSettings = buildProductTierSettings( products );
        System.runAs( ADMIN_USER )
        {
            insert productTierSettings;
        }
        return productTierSettings;
    }
    public static Product_Pricing__c buildProductPricingSetting(Id product2Id, Integer minThreshold, String name, Integer price)
    {
        Product_Pricing__c productPricing = new Product_Pricing__c();
        productPricing.Min_Seat_Threshold__c = minThreshold;
        productPricing.Price__c = price;
        productPricing.Product_Id__c = product2Id;
        productPricing.Name = name;

        return productPricing;
    }

    public static Campaign createCampaign(Boolean doInsert) {
        Campaign campaign = new Campaign();
        campaign.Name = 'Beatles Medley';

        if(doInsert) {
            insert campaign;
        }

        return campaign;
    }

    public static Lead createLead(Boolean doInsert) {
        Lead lead = new Lead();
        lead.LastName = 'Emmanuel';
        lead.Company = 'Maton';

        if(doInsert) {
            insert lead;
        }

        return lead;
    }

    public static InAppRestSettings__c createInAppRestSettings(String name, Id webtrialCampaignId, Boolean doInsert) {
        InAppRestSettings__c existingSetting = InAppRestSettings__c.getInstance( name );
        if( existingSetting != NULL ) return existingSetting;
        InAppRestSettings__c inAppRestSettings = new InAppRestSettings__c();
        inAppRestSettings.Name = name;
        inAppRestSettings.Web_Trial_Campaign_ID__c = webtrialCampaignId;
        inAppRestSettings.Disqualified_Response_Status_Values__c = 'Mailman;Pending';
        inAppRestSettings.Last_X_Days_Responded__c = 10;
        inAppRestSettings.Default_Lead_Converted_Status__c = 'Qualified - New Opportunity';
        inAppRestSettings.Lead_Disqualified_Status__c = 'Disqualified';

        if(doInsert) {
            System.runAs(ADMIN_USER) {
                insert inAppRestSettings;
            }
        }

        return inAppRestSettings;
    }

    public static Bonus_Products__c createBonusProductsSetting( Id pricebookId )
    {
        Bonus_Products__c bonusProductsSetting = Bonus_Products__c.getInstance();

        Product2 highProduct = ProductTestFactory.buildProduct();
        Product2 lowProduct = ProductTestFactory.buildProduct();
        insert new List<Product2>{ highProduct, lowProduct };

        PricebookEntry highPricebookEntry = ProductTestFactory.buildPricebookEntry( highProduct, pricebookId );
        PricebookEntry lowPricebookEntry = ProductTestFactory.buildPricebookEntry( lowProduct, pricebookId );

        insert new List<PricebookEntry>{ highPricebookEntry, lowPricebookEntry };

        bonusProductsSetting.High_Bonus_Product_Id__c = String.valueOf(highProduct.Id).left(15);
        bonusProductsSetting.High_Bonus_Product_Threshold__c = 20000.00;
        bonusProductsSetting.Low_Bonus_Product_Id__c = String.valueOf(lowProduct.Id).left(15);
        bonusProductsSetting.Low_Bonus_Product_Threshold__c = 5000.00;

        System.runAs( ADMIN_USER )
        {
            if( bonusProductsSetting.Id != NULL )
            {
                update bonusProductsSetting;
            }
            else
            {
                insert bonusProductsSetting;
            }
        }

        return bonusProductsSetting;
    }

    public static void setSObjectFields( List<sObject> records, String fieldName, Object value )
    {
        for( sObject record : records )
        {
            record.put( fieldName, value );
        }
    }

    public static QuoteMachineSettings__c buildQuoteMachineSettings()
    {
        QuoteMachineSettings__c quoteMachineSettings = new QuoteMachineSettings__c();
        quoteMachineSettings.Name = 'default';
        quoteMachineSettings.Premier_Support_Minimum_Price__c = 1;
        return quoteMachineSettings;
    }

    public static QuoteMachineSettings__c createQuoteMachineSettings()
    {
        QuoteMachineSettings__c quoteMachineSettings = buildQuoteMachineSettings();

        System.runAs(ADMIN_USER)
        {
            insert quoteMachineSettings;
        }

        return quoteMachineSettings;
    }

    public static void createPricebookSettings()
    {
        Pricebook_Setting__c currentPricebookSetting = Pricebook_Setting__c.getInstance('Current');
        Pricebook_Setting__c defaultPricebookSetting = Pricebook_Setting__c.getInstance('Legacy');
        if( currentPricebookSetting == NULL )
        {
            currentPricebookSetting = new Pricebook_Setting__c( Name = 'Current' );
        }
        if( defaultPricebookSetting == NULL )
        {
            defaultPricebookSetting = new Pricebook_Setting__c( Name = 'Default' );
        }
        Pricebook2 currentPricebook = ProductTestFactory.buildPricebook( 'Test Current' );
        Pricebook2 defaultPricebook = ProductTestFactory.buildPricebook( 'Test Default' );

        insert new List<Pricebook2> { currentPricebook, defaultPricebook };
        currentPricebookSetting.Id__c = String.valueOf(currentPricebook.Id).left(15);
        defaultPricebookSetting.Id__c = String.valueOf(defaultPricebook.Id).left(15);

        System.runAs( TestUtils.ADMIN_USER )
        {
            upsert new List<Pricebook_Setting__c>{ currentPricebookSetting, defaultPricebookSetting };
        }
    }


    public static Pricebook_Setting__c buildPricebookSetting(String name, String id) {
        return new Pricebook_Setting__c(
              Name = name
            , Id__c = id
        );
    }

    static Sobject adminIffyInsert(Sobject record, Boolean doInsert) {
        if(doInsert) {
            System.runAs(ADMIN_USER) {
                insert record;
            }
        }

        return record;
    }

    public static Actions_Package__c createActionsPackage(String name, Integer startRange, Integer endRange, Integer quantity, Boolean doInsert) {
        Actions_Package__c actionsPackage = new Actions_Package__c
            ( Name = name
            , Start_Range__c = startRange
            , End_Range__c = endRange
            , Quantity__c = quantity
            );

        return (Actions_Package__c)adminIffyInsert(actionsPackage, doInsert);
    }

    public static Web_Trial_Owner_Reassignment__c createWebTrialOwnerReassignmentSetting( String roleNameToReassign, Id userIdToReassignTo )
    {
        Web_Trial_Owner_Reassignment__c setting = buildWebTrialOwnerReassignmentSetting( roleNameToReassign, userIdToReassignTo );
        System.runAs( ADMIN_USER )
        {
            insert setting;
        }
        return setting;
    }

    public static Web_Trial_Owner_Reassignment__c buildWebTrialOwnerReassignmentSetting( String roleNameToReassign, Id userIdToReassignTo )
    {
        return new Web_Trial_Owner_Reassignment__c( Name = 'Reassignment Setting 1',
                                                    Role_Name__c = roleNameToReassign,
                                                    User_to_Reassign_To__c = userIdToReassignTo );
    }

    public static List<Opportunity> createOpportunities(Integer size, String stageName, Boolean doInsert) {
        List<Opportunity> oppties = new List<Opportunity>();
        for(Integer i=0;i<size;i++) {
            Opportunity oppty = new Opportunity();
            oppty.Name = 'name'+i;
            oppty.StageName = stageName;
            oppty.CloseDate = Date.today().addDays(i);
            oppties.add(oppty);
        }
        if(doInsert) {
            insert oppties;
        }
        return oppties;
    }
}