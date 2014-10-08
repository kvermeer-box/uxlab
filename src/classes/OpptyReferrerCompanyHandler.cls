/**
 * Populates Referrer Partner Company based on the text matching text field
 *
 * @author Perficient
 * @revision Kyle Vermeer 5/13/14 Prevent query on every update
 */
public class OpptyReferrerCompanyHandler {
    
    public static void popReferrerCompany(Opportunity[] opptys) {
        // Gets all account ids
        Set<Id> accntIds = new Set<Id>();
        // Either add account to accounts to check for, or set Referrer Partner Company to null
        for(Opportunity o :opptys){
            if (o.Referral_Partner_Id__c != null) { // There is a referral partner id, add it to ids set
                accntIds.add(o.Referral_Partner_ID__c);
            }
            else { // partner id null, set partner company to null
                o.Referrer_Partner_Company_2__c = null;
            }
        }
        // Here (what I think is happening) is we are checking that the ids are valid account ids
        Map<Id, String> accntMap = new Map<Id, String>();
        for(Account a :[SELECT Id, Name FROM Account WHERE Id IN :accntIds]){
            accntMap.put(a.Id, a.Id);
        }
        // Now populate the referrer partner company on the opps
        for(Opportunity o :opptys){
            if(accntMap.get(o.Referral_Partner_ID__c) != null){
                o.Referrer_Partner_Company_2__c = accntMap.get(o.Referral_Partner_ID__c);
            }
        }
    }

    public static void populateReferrerCompany(Map<Id,Opportunity> oldMap, Map<Id,Opportunity> newMap) {
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for (Opportunity currentOpp : newMap.values()) {
            Opportunity oldOpp = oldMap.get(currentOpp.Id);
            if (oldOpp.Referral_Partner_Id__c != currentOpp.Referral_Partner_Id__c) {
                oppsToUpdate.add(currentOpp);
            }
        }
        if (oppsToUpdate != null && !oppsToUpdate.isEmpty()) {
            popReferrerCompany(oppsToUpdate);
        }
    }
}