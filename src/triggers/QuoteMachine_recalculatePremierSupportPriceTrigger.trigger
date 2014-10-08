trigger QuoteMachine_recalculatePremierSupportPriceTrigger on Quote (after insert, after update) {

    private final String PREMIER_SUPPORT_PRODUCT_ID = '01t60000001xrec';
    public static Integer iteration = 0;

    if( trigger.isAfter )
    {
        if( trigger.isUpdate )
        {
            // Foreplay time!  Set up a quotes w/premier support line items map
            List<Quote> allQuotesList = [SELECT Id, Business_Ent_Unlimited_Total__c, Annualized_Bus_Ent_Unlimited_Total__c,
                                                    (SELECT Id, PricebookEntry.Product2.Percentage_of_Contract_Price__c, Discount__c
                                                        FROM QuoteLineItems
                                                        WHERE PricebookEntry.Product2.Id = :PREMIER_SUPPORT_PRODUCT_ID)
                                                FROM Quote
                                                WHERE Id IN :Trigger.new];
            System.debug('Number of quotes we will evaluate: ' + allQuotesList.size());

            // Foreplay is over.  Time for the good stuff.
            List<QuoteLineItem> updateList = new List<QuoteLineItem>();
            List<QuoteLineItem> deleteList = new List<QuoteLineItem>();
            for (Quote q : allQuotesList) {
                System.debug('Evaluating changes to quote ' + q.Id);
                Double oldTotal = 0;
                Double newTotal = 0;
                if (Trigger.oldMap.get(q.Id).Business_Ent_Unlimited_Total__c != null) {
                    oldTotal = Trigger.oldMap.get(q.Id).Business_Ent_Unlimited_Total__c;
                }
                if (Trigger.newMap.get(q.Id).Business_Ent_Unlimited_Total__c != null) {
                    newTotal = Trigger.newMap.get(q.Id).Business_Ent_Unlimited_Total__c;
                }
                if (oldTotal != newTotal) {
                    System.debug('Business/Enterprise/Unlimited total has been changed to ' + q.Business_Ent_Unlimited_Total__c + '. Update all associated premier support line items.');
                    if (q.QuoteLineItems != null && q.QuoteLineItems.size() > 0) {
                        for (QuoteLineItem psLineItem : q.QuoteLineItems) {
                            System.debug('Associated premier support product exists! ' + psLineItem.Id);
                            if (psLineItem.PricebookEntry != null && psLineItem.PricebookEntry.Product2 != null && psLineItem.PricebookEntry.Product2.Percentage_of_Contract_Price__c != null) {
                                psLineItem.List_Price__c = q.Business_Ent_Unlimited_Total__c * (psLineItem.PricebookEntry.Product2.Percentage_of_Contract_Price__c / 100);
                                Double annualPsSubtotal = q.Annualized_Bus_Ent_Unlimited_Total__c * (psLineItem.PricebookEntry.Product2.Percentage_of_Contract_Price__c / 100);
                                // If the new annual total price is less than the threshold, delete.  Otherwise, update.
                                Double minimumPrice = QuoteMachineSettings__c.getInstance('default').Premier_Support_Minimum_Price__c;
                                if (psLineItem.Discount__c != null && ((annualPsSubtotal * (1 - (psLineItem.Discount__c / 100))) < minimumPrice)) {
                                    deleteList.add(psLineItem);
                                    System.debug('New total price less than' + minimumPrice + '. This record will be deleted.');
                                } else {
                                    updateList.add(psLineItem);
                                    System.debug('New list price for Premier Support: ' + psLineItem.List_Price__c);
                                }
                            }
                        }
                    }
                }
            }
            if (updateList != null && updateList.size() > 0) {
                update updateList;
                System.debug(updateList.size() + ' premier support products updated.');
            }
            if (deleteList != null && deleteList.size() > 0) {
                delete deleteList;
                System.debug(deleteList.size() + ' premier support products deleted.');
            }
            //List<Quote> filteredQuotes = trigger.new;
            List<Quote> filteredQuotes = (List<Quote>)Select.Field.isEqual( Quote.Added_Bonus_Products__c, false ).filter( trigger.new );
            List<QuoteLineItem> bonusProducts = QuoteLineItemServices.getNewBonusProducts( filteredQuotes );
            for (Quote currentQuote : trigger.new) {
                System.debug('Are boxworks tickets added?' + currentQuote.Added_BoxWorks_Tickets_Already__c);
            }
            List<QuoteLineItem> tickets = QuoteLineItemServices.getBoxWorksTickets(Select.Field.isEqual( Quote.Added_BoxWorks_Tickets_Already__c, false ).filter( trigger.new ));
            bonusProducts.addAll(tickets);
            if( !bonusProducts.isEmpty() )
            {
                try
                {
                    insert bonusProducts;
                }
                catch( DmlException dmlEx )
                {
                    for( Integer i = 0; i < dmlEx.getNumDml(); i++ )
                    {
                        Id quoteErrorId = bonusProducts[ dmlEx.getDmlIndex(i)].QuoteId;
                        trigger.newMap.get( quoteErrorId ).addError( dmlEx );
                    }
                }
            }
            List<Quote> quotesToUpdate = QuoteServices.setAddedBonusProducts(Pluck.ids('QuoteId', bonusProducts), tickets);
            QuoteServices.genericSafeUpdate(quotesToUpdate, Trigger.new, QuoteServices.SOBJECT_FIELD_ID);
        }

        if( trigger.isInsert || trigger.isUpdate )
        {
            Select.Filter productTierChangedFilter = Select.Field.hasChanged( Quote.Product_Tier__c );
            List<Quote> filteredQuotes = (List<Quote>)( trigger.isInsert ? productTierChangedFilter.filter( trigger.new ) : productTierChangedFilter.filter( trigger.new, trigger.oldMap ) );

            List<Opportunity> opportunitiesToUpdate = QuoteServices.setParentOpportunityProductTier( filteredQuotes );

            QuoteServices.genericSafeUpdate(opportunitiesToUpdate, Trigger.new, QuoteServices.QUOTE_FIELD_OPPORTUNITY_ID);
        }
    }
}