public with sharing class Z_SubscriptionUtility {
  
    @future(callout=true)
    public static void clearSubscription(Id quoteId) {
        List<zqu.ZChargeGroup> chargeGroups = zqu.zQuoteUtil.getChargeGroups(quoteId);
        if(chargeGroups.isEmpty()) { return; }
        zqu.zQuoteUtil.deleteChargeGroups(chargeGroups);
        
        zqu__Quote__c quote = new zqu__Quote__c(id = quoteId);
        quote.Processing__c = false;
        update quote;
    }
}