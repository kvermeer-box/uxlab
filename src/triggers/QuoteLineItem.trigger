trigger QuoteLineItem on QuoteLineItem (after delete, after undelete, after insert, before insert)
{
	if( Trigger.isBefore )
	{
		if( Trigger.isInsert)
		{
			QuoteLineItemServices.preventInsertOfCompetingQuoteLineItems( trigger.new );
		}
	}
	if( Trigger.isAfter )
	{
		Savepoint sp = Database.setSavepoint();
		if( Trigger.isInsert )
		{
			List<Quote> quotesWithProductTierUpdates = QuoteLineItemServices.setQuoteProductTier( trigger.new );
			try
			{
				update quotesWithProductTierUpdates;
			}
			catch( DmlException dmlEx )
			{
				System.assert( false, dmlEx );
				Map<Id,List<QuoteLineItem>> quoteIdToQuoteLineItems = GroupBy.ids( 'QuoteId', trigger.new );
				for( Integer i = 0; i < dmlEx.getNumDml(); i++ )
				{
					Id errorId = quotesWithProductTierUpdates[ dmlEx.getDmlIndex(i) ].Id;
					for( QuoteLineItem quoteLineItem : quoteIdToQuoteLineItems.get( errorId ) )
					{
						quoteLineItem.addError( dmlEx.getMessage() );
					}
				}
			}
			
			List<QuoteLineItem> lowerRankedCompetingProductsToDelete = QuoteLineItemServices.getLowerRankedCompetingProductsToDelete( trigger.new );
			try
			{
				delete lowerRankedCompetingProductsToDelete;
			}
			catch( DmlException dmlEx )
			{
				QuoteLineItemServices.handleDmlException( Trigger.new, lowerRankedCompetingProductsToDelete, dmlEx );
				Database.rollback(sp);
			}
		}
		List<QuoteLineItem> itemsWithPairedProducts = QuoteLineItemServices.filterQuoteLineItemsWithPairs( Trigger.isDelete ? Trigger.old : Trigger.new );
		if( itemsWithPairedProducts.isEmpty() )
		{
			return;
		}
		
		if( Trigger.isInsert || Trigger.isUndelete )
		{
			List<QuoteLineItem> pairedProductsToInsert = QuoteLineItemServices.getPairedProducts( itemsWithPairedProducts );
			
			List<QuoteLineItem> bonusProducts = QuoteLineItemServices.filterBonusProducts( pairedProductsToInsert );
			List<Quote> quotesToUpdate = QuoteServices.setAddedBonusProducts(Pluck.ids('QuoteId', bonusProducts), new List<QuoteLineItem>());
			bonusProducts.addAll(QuoteLineItemServices.getNewBonusProducts(quotesToUpdate));
			QuoteServices.genericSafeUpdate(quotesToUpdate, Trigger.new, QuoteServices.SOBJECT_FIELD_ID);

			if( !pairedProductsToInsert.isEmpty() )
			{
				try
				{
					insert pairedProductsToInsert;
				}
				catch( DmlException dmlEx )
				{
					QuoteLineItemServices.handleDmlException( Trigger.new, pairedProductsToInsert, dmlEx );
					Database.rollback(sp);
				}
			}
			
		}
		if( Trigger.isDelete )
		{
			List<QuoteLineItem> pairedProductsToDelete = new List<QuoteLineItem>();
			pairedProductsToDelete = QuoteLineItemServices.getExistingPairedLineItems( itemsWithPairedProducts );
			if( !pairedProductsToDelete.isEmpty() )
			{
				try
				{
					delete pairedProductsToDelete;
				}
				catch( DmlException dmlEx )
				{
					QuoteLineItemServices.handleDmlException( Trigger.old, pairedProductsToDelete, dmlEx );
					Database.rollback(sp);
				}
			}
		}
	}
}