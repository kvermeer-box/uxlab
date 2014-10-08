/**
 * Class for one-off lead trigger functionalities.
 *
 * @author Kyle Vermeer 5/6/14
 */
public class LeadTriggerHandler {

    /**
     * Links the Marketing Activities on the converted leads to their new contacts.
     *
     * @param {Map<Id,Lead>} oldMap - Trigger.oldMap
     * @param {Map<Id,Lead>} newMap - Trigger.newMap
     */
    public static void attachMarketingActivityFromConvertedLeads(Map<Id, Lead> oldMap, Map<Id, Lead> newMap) {
        Map<Id, Id> leadIdToContactId = new Map<Id, Id>();
        Map<Id, Id> leadIdToAccountId = new Map<Id, Id>();
        // Populate map from converted leads to their contacts
        for (Lead currentLead : newMap.values()) {
            Lead oldLead = oldMap.get(currentLead.Id);
            if (currentLead.isConverted && !oldLead.isConverted) { // Lead was just converted
                if (currentLead.ConvertedContactId != null) { // If it was converted into a contact, add it to the map
                    leadIdToContactId.put(currentLead.Id, currentLead.ConvertedContactId);
                }
                if (currentLead.ConvertedAccountId != null) { // check for account id
                    leadIdToAccountId.put(currentLead.Id, currentLead.ConvertedAccountId);
                }
            }
        }
        // Gather set of all converted lead ids
        Set<Id> convertedLeadIds = leadIdToContactId.keySet();
        if (convertedLeadIds.isEmpty()) { // If no leads were converted, just return
            return;
        }
        // Now query for all related marketing activities
        try {
            List<Marketing_Activity__c> marketingActivities = [SELECT Id, Lead__c, Contact__c
                                                                 FROM Marketing_Activity__c
                                                                WHERE Lead__c IN :convertedLeadIds];
            // Adjust the Contact__c field of each marketing activity
            for (Marketing_Activity__c currentMActivity : marketingActivities) {
                Id contactId = leadIdToContactId.get(currentMActivity.Lead__c);
                Id accountId = leadIdToAccountId.get(currentMActivity.Lead__c);
                if (contactId == null || accountId == null) { // If either id is null, just shoot error message
                    System.debug('Contact id could not be found for lead on marketing activity.');
                }
                else { // Attach contact to marketing activity
                    currentMActivity.Contact__c = contactId;
                    currentMActivity.Account__c = accountId;
                }
            }
            // Update the activities
            update marketingActivities;
        }
        catch (Exception e) {
            new LoggedException(e,'Trouble update marketing activities!','LeadTriggerHandler', new List<Id>(convertedLeadIds));
        }
    }

}