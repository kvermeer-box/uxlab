public with sharing class QuoteServices
{
    public static final String QUOTE_FIELD_OPPORTUNITY_ID = 'OpportunityId';
    public static final String SOBJECT_FIELD_ID = 'Id';

    public static List<Opportunity> setParentOpportunityProductTier( List<Quote> quotes )
    {
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        Set<Id> processedOpportunityIds = new Set<Id>();
        for( Quote quote : quotes )
        {
            if( !processedOpportunityIds.contains( quote.OpportunityId ) )
            {
                opportunitiesToUpdate.add( new Opportunity( Id = quote.OpportunityId, Account_Type_Sold__c = quote.Product_Tier__c ) );
                processedOpportunityIds.add( quote.OpportunityId );
            }
        }

        return opportunitiesToUpdate;
    }


    static Map<Id, List<sObject>> createRelationshipMap(List<sObject> children, String lookupField) {
        Map<Id, List<sObject>> parentIdToChildren = new Map<Id, List<sObject>>();

        for(sObject child : children) {
            Id parentId = (Id) child.get(lookupField);

            if(parentIdToChildren.get(parentId) == null) {
                parentIdToChildren.put(parentId, new List<sObject>());
            }

            parentIdToChildren.get(parentId).add(child);
        }

        return parentIdToChildren;
    }

    /* used for updating a parent object from a child object trigger */
    /* this can also be used to update an object from the same trigger by setting the lookupField to 'Id' */
    public static void genericSafeUpdate(List<sObject> recordsToUpdate, List<sObject> triggerRecords, String lookupField) {
        try {
            update recordsToUpdate;
        } catch(DMLException dmx) {
            Map<Id, List<sObject>> recordToUpdateIdToOwner = createRelationshipMap(triggerRecords, lookupField);

            for(Integer i = 0; i < dmx.getNumDml(); i++) {
                List<sObject> failedChildren = recordToUpdateIdToOwner.get(dmx.getDmlId(i));
                String failedMessage = dmx.getDmlMessage(i);

                for(sObject failedChild : failedChildren) {
                    failedChild.addError(failedMessage);
                }
            }
        }
    }

    public static List<Quote> setAddedBonusProducts(Set<Id> quoteIds, List<QuoteLineItem> ticketsAdded)
    {
        Set<Id> quotesWithTicketsAdded = Pluck.ids('QuoteId',ticketsAdded);
        List<Quote> quotes = new List<Quote>();

        for(Id quoteId : quoteIds)
        {
            Quote quoteToUpdate = new Quote(Id=quoteId, Added_Bonus_Products__c=true);
            if (quotesWithTicketsAdded.contains(quoteId)) {
                quoteToUpdate.Added_BoxWorks_Tickets_Already__c = true;
            }
            quotes.add(quoteToUpdate);
        }

        return quotes;
    }
}