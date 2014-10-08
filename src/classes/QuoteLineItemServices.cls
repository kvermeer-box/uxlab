public with sharing class QuoteLineItemServices
{
    @TestVisible final static String LEGACY_PREFIX = 'Legacy - ';
    public static Date LEGACY_DATE = QuoteMachine_AddProductsController.LEGACY_DATE;
    public static final String COMPETING_ITEM_ERROR = 'This quote already has a higher ranked professional service product';
    public static Boolean quoteTriggerIsRunning = false;
    public static Id renewalRecordTypeId
    {
        get
        {
            if( renewalRecordTypeId == NULL )
            {
                renewalRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Opportunity' AND DeveloperName = 'Renewal'][0].Id;
            }
            return renewalRecordTypeId;
        }
        private set;
    }
    
    private static Bonus_Products__c bonusProductCustomSetting
    {
        get
        {
            if( bonusProductCustomSetting == NULL )
            {
                bonusProductCustomSetting = Bonus_Products__c.getInstance();
            }
            return bonusProductCustomSetting;
        }
        private set;
    }
        
    public static List<QuoteLineItem> filterQuoteLineItemsWithPairs( List<QuoteLineItem> quoteLineItems )
    {
        Set<Id> productsWithPairsIds = new Set<Id>();
        for( String productWithPairId : Product_Pairings__c.getAll().keySet() )
        {
            if( productWithPairId instanceOf Id )
                productsWithPairsIds.add( Id.valueOf(productWithPairId) );
        }

        List<QuoteLineItem> filteredQuoteLineItemsWithPairs = new List<QuoteLineItem>();
        for( QuoteLineItem quoteLineItem : quoteLineItems )
        {
            if( quoteLineItem.Parent_Quote_Created_Date__c > LEGACY_DATE && productsWithPairsIds.contains(quoteLineItem.Product_Id__c) )
            {
                filteredQuoteLineItemsWithPairs.add( quoteLineItem );
            }
        }

        return filteredQuoteLineItemsWithPairs;
    }

    public static List<Quote> setQuoteProductTier( List<QuoteLineItem> quoteLineItems )
    {
        List<Quote> quotesToUpdate = new List<Quote>();
        for( QuoteLineItem quoteLineItem : quoteLineItems )
        {
            Product_Tier__c productTierSetting = Product_Tier__c.getInstance( quoteLineItem.Product_ID__c );
            if( productTierSetting == NULL ) continue;
            
            String productTier = productTierSetting.Product_Tier__c;
            if( quoteLineItem.Parent_Quote_Pricebook__c == Pricebook_Setting__c.getInstance('Legacy').Id__c )
                productTier = LEGACY_PREFIX + productTier;
            quotesToUpdate.add( new Quote( Id = quoteLineItem.QuoteId, Product_Tier__c = productTier ) );
        }
        return quotesToUpdate;
    }
    /**
    *
    *   @param QuoteLineItem    line item to set the default price on
    *   @param Id       The related product Id
    *   @param Integer      The number of seats on the Quote
    */
    public static QuoteLineItem setDefaultPrice(QuoteLineItem qli, Id relatedProductId, Integer seats)
    {
        List<Product_Pricing__c> matchingProductPricing = [
            SELECT Price__c, Min_Seat_Threshold__c
            FROM Product_Pricing__c
            WHERE Product_Id__c = :relatedProductId
            AND Min_Seat_Threshold__c <= :seats
            ORDER BY Min_Seat_Threshold__c DESC
            LIMIT 1
        ];

        if(!matchingProductPricing.isEmpty())
        {
            qli.UnitPrice = matchingProductPricing[0].Price__c;
        }

        return qli;
    }

    public static List<QuoteLineItem> getPairedProducts( List<QuoteLineItem> quoteLineItems )
    {
        List<QuoteLineItem> allPairedLineItems = new List<QuoteLineItem>();
        Map<Id, Quote> idToParentQuotes = new Map<Id, Quote> ([SELECT (SELECT PricebookEntryId, Product_ID__c FROM QuoteLineItems ) FROM Quote WHERE Id IN :Pluck.ids('QuoteId', quoteLineItems) ]);
        Map<Id,Set<Id>> quoteItemIdToPairedProductIds = getQuoteItemIdToPairedProductIds( quoteLineItems, idToParentQuotes );

        Set<Id> pairedProductIds = getAllPairedProductIds( quoteItemIdToPairedProductIds );

        Map<Id,Map<String,Map<Id,PricebookEntry>>> pricebookIdToCurrencyCodeToPricebookEntryMap = mapPricebookIdToCurrencyCodeToPricebookEntryMap( pairedProductIds );
        
        for( QuoteLineItem quoteLineItem : quoteLineItems )
        {
            List<PricebookEntry> pairedPricebookEntries = new List<PricebookEntry>();
            Set<Id> pairedEntryIds = quoteItemIdToPairedProductIds.get( quoteLineItem.Id );
            if( pricebookIdToCurrencyCodeToPricebookEntryMap.containsKey( quoteLineItem.Parent_Quote_Pricebook__c ) )
            {
                Map<Id,PricebookEntry> relatedPricebookEntries = pricebookIdToCurrencyCodeToPricebookEntryMap.get( quoteLineItem.Parent_Quote_Pricebook__c ).get( quoteLineItem.CurrencyIsoCode );
                for( Id pairedEntryId : pairedEntryIds )
                {
                    pairedPricebookEntries.add( relatedPricebookEntries.get( pairedEntryId ) );
                }
                List<QuoteLineItem> deDupeLineItems = deDupePairedLineItems( buildPairedLineItems( quoteLineItem, pairedPricebookEntries), idToParentQuotes.get( quoteLineItem.QuoteId) );
                allPairedLineItems.addAll( deDupeLineItems );
            }
        }
        return allPairedLineItems;
    }

    public static List<QuoteLineItem> getExistingPairedLineItems( List<QuoteLineItem> quoteLineItems )
    {
        Map<Id, Quote> idToParentQuotes = new Map<Id, Quote> ([SELECT (SELECT PricebookEntryId, Product_ID__c, QuoteId FROM QuoteLineItems ) FROM Quote WHERE Id IN :Pluck.ids('QuoteId', quoteLineItems) ]);
        Map<Id,Set<Id>> quoteItemIdToPairedProductIds = getQuoteItemIdToPairedProductIds( quoteLineItems, idToParentQuotes );
        Set<Id> pairedProductIds = getAllPairedProductIds( quoteItemIdToPairedProductIds );
        Map<Id, QuoteLineItem> idToExistingPairedLineItem = new Map<Id, QuoteLineItem>();
        for( Quote parentQuote : idToParentQuotes.values() )
        {
            for( QuoteLineItem quoteLineItem : parentQuote.quoteLineItems )
            {
                if( pairedProductIds.contains( quoteLineItem.Product_ID__c ) )
                {
                    idToExistingPairedLineItem.put( quoteLineItem.Id, quoteLineItem );
                }
            }
        }
        return idToExistingPairedLineItem.values();
    }

    public static void handleDmlException( List<QuoteLineItem> triggerRecords, List<QuoteLineItem> dmlRecords, DmlException dmlEx )
    {
        Map<Id, List<QuoteLineItem> > quoteIdToQuoteLineItems = GroupBy.ids( 'QuoteId', triggerRecords );
        for( Integer i = 0; i < dmlEx.getNumDml(); i++ )
        {
            Id errorId = dmlRecords[ dmlEx.getDmlIndex(i) ].QuoteId;
            for( QuoteLineItem quoteLineItem : quoteIdToQuoteLineItems.get( errorId ) )
            {
                quoteLineItem.addError( dmlEx.getMessage() );
            }
        }
    }

    public static void preventInsertOfCompetingQuoteLineItems( List<QuoteLineItem> quoteLineItems )
    {
        List<QuoteLineItem> quoteLineItemsWithCompetingProducts = new List<QuoteLineItem>();
        Map<Id,List<QuoteLineItem>> pricebookEntryIdToLineItems = GroupBy.ids( 'PricebookEntryId', quoteLineItems );
        Map<Id,PricebookEntry> idToRelatedPricebookEntries = new Map<Id,PricebookEntry> ( [SELECT Product2Id FROM PricebookEntry WHERE Id IN :pricebookEntryIdToLineItems.keySet() ] );
        for( PricebookEntry entry : idToRelatedPricebookEntries.values() )
        {
            String pricebookEntry15DigitId = String.valueOf(entry.Product2Id).left(15);
            if( Competing_Product__c.getInstance( pricebookEntry15DigitId ) != NULL )
                quoteLineItemsWithCompetingProducts.addAll( pricebookEntryIdToLineItems.get(entry.Id) );
        }
        Map<Id,Quote> idToParentQuote = new Map<Id,Quote>([SELECT (SELECT Product_ID__c FROM QuoteLineItems ) FROM Quote WHERE Id IN :Pluck.ids('QuoteId', quoteLineItemsWithCompetingProducts) ]);
        for( QuoteLineItem quoteLineItem : quoteLineItemsWithCompetingProducts )
        {
            if( hasHigherRankedCompetingProduct( idToRelatedPricebookEntries.get( quoteLineItem.PricebookEntryId ).Product2Id, idToParentQuote.get( quoteLineItem.QuoteId ).QuoteLineItems ) )
            {
                quoteLineItem.addError( COMPETING_ITEM_ERROR );
            }
        }
    }
    
    @TestVisible private static Boolean hasHigherRankedCompetingProduct( Id newProductId, List<QuoteLineItem> siblingQuoteLineItems )
    {
        String product15DigitId = String.valueOf(newProductId).left(15);
        System.debug('Product we\'re adding: ' + product15DigitId);
        Competing_Product__c newCompetingProductSetting = Competing_Product__c.getInstance( product15DigitId );
        if( newCompetingProductSetting == NULL ) return false;
        
        for( String productId : Pluck.strings( 'Product_Id__c', siblingQuoteLineItems ) )
        {
            Competing_Product__c competingProductSetting = Competing_Product__c.getInstance( productId );
            if( competingProductSetting != NULL && newCompetingProductSetting.Seniority_Rank__c <= competingProductSetting.Seniority_Rank__c )
            {
                return true;
            }
        }
        return false;
    }
    
    public static List<QuoteLineItem> getLowerRankedCompetingProductsToDelete( List<QuoteLineItem> quoteLineItems )
    {
        List<QuoteLineItem> quoteLineItemsWithCompetingProducts = new List<QuoteLineItem>();
        for( QuoteLineItem quoteLineItem : quoteLineItems )
        {
            if( Competing_Product__c.getInstance( quoteLineItem.Product_ID__c ) != NULL )
                quoteLineItemsWithCompetingProducts.add( quoteLineItem );
        }
        Set<String> competingProductIds = new Set<String>();
        for( String competingProductId : Competing_Product__c.getAll().keySet() )
        {
            competingProductIds.add( competingProductId );
        }
        List<QuoteLineItem> productsToDelete = [SELECT Id, QuoteId FROM QuoteLineItem WHERE QuoteId IN :Pluck.Ids('QuoteId', quoteLineItemsWithCompetingProducts)
                                                AND Id NOT IN :quoteLineItems AND Product_ID__c IN :competingProductIds];
        return productsToDelete;
    }

    private static Set<Id> getAllPairedProductIds( Map<Id,Set<Id>> quoteItemIdToPairedProductIds )
    {
        Set<Id> allPairedProductIds = new Set<Id>();
        for( Id quoteLineItemId : quoteItemIdToPairedProductIds.keySet() )
        {
            allPairedProductIds.addAll( quoteItemIdToPairedProductIds.get( quoteLineItemId ) );
        }

        return allPairedProductIds;
    }

    @TestVisible private static Map<Id,Set<Id>> getQuoteItemIdToPairedProductIds( List<QuoteLineItem> quoteLineItems, Map<Id, Quote> idToParentQuote )
    {
        Map<Id,Set<Id>> quoteItemIdToPairedProductIds = new Map<Id,Set<Id>>();
        for( QuoteLineItem quoteLineItem : quoteLineItems )
        {
            Set<Id> pairedProductIdsForLineItem = getPairedProductIdsForLineItem( quoteLineItem, idToParentQuote.get( quoteLineItem.QuoteId) );
            quoteItemIdToPairedProductIds.put( quoteLineItem.Id, pairedProductIdsForLineItem);
        }

        return quoteItemIdToPairedProductIds;
    }

    private static Set<Id> getPairedProductIdsForLineItem( QuoteLineItem quoteLineItem, Quote parentQuote )
    {
        Set<Id> pairedProductIdsForLineItem = new Set<Id>();

        if( quoteLineItem.Product_Id__c == NULL ) return pairedProductIdsForLineItem;

        Product_Pairings__c productPairings = Product_Pairings__c.getInstance( quoteLineItem.Product_Id__c );

        if( productPairings == NULL ) return pairedProductIdsForLineItem;

        Id professionalProductId = getProfessionalProductId( quoteLineItem, parentQuote, productPairings );

        if( professionalProductId != NULL )
        {
            pairedProductIdsForLineItem.add( professionalProductId );
        }

        List<String> pairedProducts = String.isBlank( productPairings.Paired_Products__c ) ? new List<String>() : productPairings.Paired_Products__c.split(',');

        for( String pairedProductId : pairedProducts )
        {
            if( pairedProductId instanceOf Id ) pairedProductIdsForLineItem.add( pairedProductId );
        }

        return pairedProductIdsForLineItem;
    }

    private static Id getProfessionalProductId ( QuoteLineItem quoteLineItem, Quote parentQuote, Product_Pairings__c productPairings )
    {
        Id professionalProductId = quoteLineItem.Quantity >= productPairings.Seat_Threshold__c ?  productPairings.Above_Threshold_PS__c : productPairings.Below_Threshold_PS__c;
        if( professionalProductId == NULL )
            return NULL;

        if( productPairings.Prerequisite_Products__c == NULL )
            return professionalProductId;

        Set<Id> prerequisiteProductIds = new Set<Id>();
        for( String prerequisiteProductId : productPairings.Prerequisite_Products__c.split(',') )
        {
            prerequisiteProductIds.add( prerequisiteProductId );
        }

        Boolean hasPrerequisite = false;
        for( QuoteLineItem siblingQuoteLineItem : parentQuote.QuoteLineItems )
        {
            if( prerequisiteProductIds.contains( siblingQuoteLineItem.Product_ID__c ) )
            {
                hasPrerequisite = true;
                break;
            }
        }
        return hasPrerequisite ? professionalProductId : NULL;
    }

    private static Map<Id,Map<String,Map<Id,PricebookEntry>>> mapPricebookIdToCurrencyCodeToPricebookEntryMap( Set<Id> productIds )
    {
        Map<Id,Map<String,Map<Id,PricebookEntry>>> pricebookIdToCurrencyCodeToPricebookEntryMap = new Map<Id,Map<String,Map<Id,PricebookEntry>>>();
        for( PricebookEntry entry: [ SELECT Id, Product2Id, Pricebook2Id, UnitPrice, CurrencyIsoCode FROM PricebookEntry WHERE Product2Id IN :productIds ] )
        {
            if( !pricebookIdToCurrencyCodeToPricebookEntryMap.containsKey( entry.Pricebook2Id) )
            {
                pricebookIdToCurrencyCodeToPricebookEntryMap.put( entry.Pricebook2Id, new Map<String,Map<Id,PricebookEntry>>() );
            }
            
            if( !pricebookIdToCurrencyCodeToPricebookEntryMap.get( entry.Pricebook2Id ).containsKey( entry.CurrencyIsoCode ) )
            {
                pricebookIdToCurrencyCodeToPricebookEntryMap.get( entry.Pricebook2Id ).put( entry.CurrencyIsoCode, new Map<Id,PricebookEntry>() );
            }
            pricebookIdToCurrencyCodeToPricebookEntryMap.get( entry.Pricebook2Id ).get( entry.CurrencyIsoCode ).put( entry.Product2Id, entry );
        }

        return pricebookIdToCurrencyCodeToPricebookEntryMap;
    }

    @TestVisible private static List<QuoteLineItem> buildPairedLineItems( QuoteLineItem quoteLineItem, List<PricebookEntry> pairedPricebookEntries )
    {
        List<QuoteLineItem> pairedLineItems = new List<QuoteLineItem>();
        for( PricebookEntry entry : pairedPricebookEntries )
        {
            pairedLineItems.add( buildQuoteLineItem( quoteLineItem.QuoteId, entry, 1 ) );
        }

        return pairedLineItems;
    }

    @TestVisible private static List<QuoteLineItem> deDupePairedLineItems( List<QuoteLineItem> quoteLineItems, Quote parentQuote )
    {
        List<QuoteLineItem> deDupePairedLineItems = new List<QuoteLineItem>();
        Set<Id> existingLineItems = Pluck.ids( 'PricebookEntryId', parentQuote.QuoteLineItems );
        for( QuoteLineItem quoteLineItem : quoteLineItems )
        {
            if( !existingLineItems.contains( quoteLineItem.PricebookEntryId ) )
            {
                deDupePairedLineItems.add( quoteLineItem );
            }
        }

        return deDupePairedLineItems;
    }
    
    public static List<QuoteLineItem> getBoxWorksTickets(List<Quote> quotes) {
        Map<Id,Quote> quoteMap = new Map<Id,Quote>(quotes);
        List<QuoteLineItem> boxWorksTickets = new List<QuoteLineItem>();
        // Get Ids of BoxWorks Products from Custom Setting
        Id boxWorksTicketId = bonusProductCustomSetting.Box_Works_2014_Id__c;
        Id boxWorksUnlimitedTicketId = bonusProductCustomSetting.BoxWorks_2014_Unlimited_Id__c;
        Integer numberOfTickets = (Integer) bonusProductCustomSetting.BoxWorks_Number_of_Tickets__c;
        if (boxWorksTicketId == null || boxWorksUnlimitedTicketId == null || numberOfTickets == null) {
            return boxWorksTickets;
        }
        // Requery Quote for info we need
        List<Quote> requeriedQuotes = [SELECT Id, Total_Price__c, Pricebook2Id, CurrencyIsoCode, (SELECT Product_Id__c, Id FROM QuoteLineItems) FROM Quote WHERE Id IN:quotes];
        // Get Map for prices for different currencies
        Map<Id,Map<String,Map<Id,PricebookEntry>>> pricebookIdToCurrencyCodeToPricebookEntryMap = mapPricebookIdToCurrencyCodeToPricebookEntryMap( new Set<Id>{ boxWorksTicketId } );
        System.debug('Checking each quote for adding BoxWorks tickets!');
        for (Quote currentQuote : requeriedQuotes) {
            System.debug('Quote: ' + currentQuote);
            Set<Id> existingProductIds = Pluck.ids( 'Product_Id__c', currentQuote.QuoteLineItems );
            // Convert amount tso USD
            Decimal quoteTotalPriceUSD = CurrencyUtils.convertAmountToUSD(currentQuote.Total_Price__c , currentQuote.CurrencyIsoCode);
            System.debug('Total Price USD: ' + quoteTotalPriceUSD);
            // Should we add boxworks tickets?
            
            if ( quoteTotalPriceUSD >= bonusProductCustomSetting.BoxWorks_Ticket_Threshold__c && !existingProductIds.contains( boxWorksTicketId ) && !existingProductIds.contains( boxWorksUnlimitedTicketId ) ) {
                // Add boxworks
                PriceBookEntry boxWorksEntry = pricebookIdToCurrencyCodeToPricebookEntryMap.get( currentQuote.Pricebook2Id ).get( currentQuote.CurrencyIsoCode).get( boxWorksTicketId );
                boxWorksTickets.add(buildQuoteLineItem( currentQuote.Id, boxWorksEntry, numberOfTickets ));
            }
        }
        return boxWorksTickets;
    }

    public static List<QuoteLineItem> getNewBonusProducts( List<Quote> quotes )
    {
        List<QuoteLineItem> bonusQuoteLineItems = new List<QuoteLineItem>();
        
        Set<Id> quoteIdsAboveThreshold = new Set<Id>();
        for( Quote quote : quotes )
        {
            quoteIdsAboveThreshold.add( quote.Id );
        }
        if( quoteIdsAboveThreshold.isEmpty() ) return bonusQuoteLineItems;
        
        List<Quote> requeriedQuotes = [SELECT Id, Total_Price__c, Pricebook2Id, CurrencyIsoCode, (SELECT Product_Id__c, IsPlatformProduct__c, Id FROM QuoteLineItems) FROM Quote WHERE Id IN: quoteIdsAboveThreshold];
        
        Id highBonusProductId = bonusProductCustomSetting.High_Bonus_Product_Id__c;
        Id lowBonusProductId = bonusProductCustomSetting.Low_Bonus_Product_Id__c;
        
        Map<Id,Map<String,Map<Id,PricebookEntry>>> pricebookIdToCurrencyCodeToPricebookEntryMap = mapPricebookIdToCurrencyCodeToPricebookEntryMap( new Set<Id>{ highBonusProductId, lowBonusProductId } );
        
        System.debug('Checking each quote for adding bonus products!');
        for (Quote aQuote : requeriedQuotes)
        {
            Boolean hasViewAPI = false;
            System.debug('Number of qlis: ' + aQuote.QuoteLineItems.size());
            for (QuoteLineItem lineItem : aQuote.QuoteLineItems) {
                System.debug('Line item: ' + lineItem);
                if (lineItem.IsPlatformProduct__c) {
                    hasViewAPI = true;
                }
            }
            if (hasViewAPI) continue;
            System.debug('Quote: ' + aQuote);
            Set<Id> existingProductIds = Pluck.ids( 'Product_Id__c', aQuote.QuoteLineItems );
            // Professional Services
            PricebookEntry entry;
            if( aQuote.Total_Price__c > bonusProductCustomSetting.Low_Bonus_Product_Threshold__c && aQuote.Total_Price__c < bonusProductCustomSetting.High_Bonus_Product_Threshold__c  )
            {
                System.debug('Adding low tier product.');
                entry = pricebookIdToCurrencyCodeToPricebookEntryMap.get( aQuote.Pricebook2Id ).get( aQuote.CurrencyIsoCode).get( lowBonusProductId );
            }
            else if( aQuote.Total_Price__c > bonusProductCustomSetting.High_Bonus_Product_Threshold__c )
            {
                System.debug('Adding high tier product.');
                entry = pricebookIdToCurrencyCodeToPricebookEntryMap.get( aQuote.Pricebook2Id ).get( aQuote.CurrencyIsoCode).get( highBonusProductId );
            }
            if( entry != NULL && !existingProductIds.contains( entry.Product2Id ) && !hasHigherRankedCompetingProduct( entry.Product2Id, aQuote.QuoteLineItems ))
            {
                bonusQuoteLineItems.add( buildQuoteLineItem( aQuote.Id, entry, 1 ) );
            }
            
        }
        return bonusQuoteLineItems;
    }
    
    private static Boolean shouldAddLowBonusProduct( Quote aQuote )
    {
        return aQuote.Total_Price__c > bonusProductCustomSetting.Low_Bonus_Product_Threshold__c
                && aQuote.Total_Price__c < bonusProductCustomSetting.High_Bonus_Product_Threshold__c
                && bonusProductCustomSetting.Low_Bonus_Product_Id__c != NULL;
    }

    private static Boolean shouldAddHighBonusProduct( Quote aQuote )
    {
        return aQuote.Total_Price__c > bonusProductCustomSetting.High_Bonus_Product_Threshold__c
                && bonusProductCustomSetting.High_Bonus_Product_Id__c != NULL;
    }
    
    private static QuoteLineItem buildQuoteLineItem( Id quoteId, PricebookEntry entry, Integer quantity)
    {
        return new QuoteLineItem( Quantity = quantity,
                            QuoteId = quoteId,
                            PricebookEntryId = entry.Id,
                            UnitPrice = entry.UnitPrice,
                            List_Price__c = entry.UnitPrice );
    }
    
    public static List<QuoteLineItem> filterBonusProducts( List<QuoteLineItem> quoteLineItems )
    {
        List<QuoteLineItem> filteredBonusProducts = new List<QuoteLineItem>();
        Bonus_Products__c bonusProductSetting = Bonus_Products__c.getInstance();
        Set<Id> bonusProductIds = new Set<Id>{ bonusProductSetting.High_Bonus_Product_Id__c, bonusProductSetting.Low_Bonus_Product_Id__c };
        Set<Id> pricebookEntryIds = Pluck.ids( [SELECT Id FROM PricebookEntry WHERE Product2Id IN :bonusProductIds] );
        for( QuoteLineItem quoteLineItem : quoteLineItems )
        {
            if( pricebookEntryIds.contains( quoteLineItem.PricebookEntryId ) )
            {
                filteredBonusProducts.add( quoteLineItem );
            }
        }
        return filteredBonusProducts;
    }
}