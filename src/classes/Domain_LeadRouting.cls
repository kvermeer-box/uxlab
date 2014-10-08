/**
 * Methods for controlled lead attachment to accounts
 *
 * @author Kyle Vermeer 7/2/14
 */
public class Domain_LeadRouting {

    /**
     * Given a list leads, attempts to attach those leads to an account.
     *
     * If the lead already has an account, this method will not consider it
     *
     * @param {List<Lead>} leads - leads to get attached to accounts
     * @return {Lead[]} - leads that go an account attached to them
     */
    public static Lead[] attachLeadsToAccounts(List<Lead> leads) {

        // If Domain Mapping is turned off, don't run this!
        if (!Domain_Mapping_Settings__c.getInstance().Domain_Mapping_Turned_On__c) {
            System.debug('Domain Mapping is turned off!');
            return new Lead[]{};
        }

        List<Lead> leadsToConsider = new List<Lead>();
        Set<String> leadDomains = new Set<String>();
        Set<String> blackListedDomains = Domain_Utilities.getBlackListedDomains();

        for (Lead currentLead : leads) {
            // Only check if email is not null and it doesn't already have an account and it isn't a black listed account
            if (currentLead.Email != null && currentLead.Account__c == null) {
                leadsToConsider.add(currentLead);
                // Add full domain to set
                String fullDomain = Domain_Utilities.getFullDomain(currentLead.Email);
                if (fullDomain != null && !blackListedDomains.contains(fullDomain.toLowerCase())) {
                    leadDomains.add(fullDomain);
                }
                // Add base domain to set
                String baseDomain = Domain_Utilities.getBaseDomain(currentLead.Email);
                if (baseDomain != null && !blackListedDomains.contains(baseDomain.toLowerCase())) {
                    leadDomains.add(baseDomain);
                }
            }
        }
        // If there are no domains, no need to waste a query
        if (leadDomains.isEmpty()) {
            System.debug('No domains, not going to query for any Account_Domains__c\'s!');
            return new Lead[]{};
        }
        Map<String,Account_Domain__c> accountDomainMap = getAccountDomainMap(leadDomains);
        // If we were unable to find account domains, just return
        if (accountDomainMap == null) {
            return new Lead[]{};
        }

        Lead[] leadsUpdated = new Lead[]{};
        // If there are domains, lets query for the account domains associated with them
        for (Lead currentLead : leadsToConsider) {
            Account_Domain__c accountDomainForLead = null;
            // First attempt to find account domain for full domain
            String fullDomain = Domain_Utilities.getFullDomain(currentLead.Email);
            if (fullDomain != null) {
                accountDomainForLead = accountDomainMap.get(fullDomain);
            }
            // If no account domain was found for the full domain, search for an account domain for the base domain
            if (accountDomainForLead == null) {
                String baseDomain = Domain_Utilities.getBaseDomain(currentLead.Email);
                if (baseDomain != null) {
                    accountDomainForLead = accountDomainMap.get(baseDomain);
                }
            }
            // If we found an account domain for either the full or base domain, update the lead's account
            if (accountDomainForLead != null) {
                currentLead.Account__c = accountDomainForLead.Account__c;
                leadsUpdated.add(currentLead);
            }
        }
        return leadsUpdated;
    }

    /**
     * Given a set of email domains, returns all a map of Account_Domain__c's that represent that domain
     *
     * The selected Account_Domain__c for each domain is selected first on highest Reference_Count__c, then
     * on most recent account creation date
     *
     * @param {Set<String>} emailDomains - email domains to search for
     * @return {Map<String,Account_Domain__c>} - map from domain to Account_Domain__c that best represents that domain
     */
    @TestVisible
    public static Map<String, Account_Domain__c> getAccountDomainMap(Set<String> emailDomains) {
        try { // Attempt to query for domains
            List<Account_Domain__c> accountDomains = [SELECT Id, Domain__c, Reference_Count__c, Account__c, Account__r.CreatedDate,
                                                             Account__r.Exclude_From_Domain_Mapping__c
                                                        FROM Account_Domain__c
                                                       WHERE Domain__c IN :emailDomains];
            System.debug('Found ' + accountDomains.size() + ' Account_Domain__c for provided domains!');
            Map<String, Account_Domain__c> domainMap = new Map<String, Account_Domain__c>();
            // For each Account_Domain__c, compare it to the current Account_Domain__c for that domain for the spot in the map
            for (Account_Domain__c currentAccountDomain : accountDomains) {
                // If the account is excluded from domain mapping, don't consider it
                if (currentAccountDomain.Account__r.Exclude_From_Domain_Mapping__c) {
                    continue;
                }
                String currentDomain = currentAccountDomain.Domain__c;
                // Get the exisiting entry for that domain in the map
                Account_Domain__c existingEntryFromDomain = domainMap.get(currentDomain);
                if (existingEntryFromDomain == null) { // If there is no existing entry, add the new one to the map
                    domainMap.put(currentDomain, currentAccountDomain);
                }
                else { // If there is an existing entry
                    // First: Compare Reference Count
                    System.debug('Current Account Domain: ' + currentAccountDomain);
                    System.debug('Existing Entry: ' + existingEntryFromDomain);
                    if (currentAccountDomain.Reference_Count__c > existingEntryFromDomain.Reference_Count__c) {
                        domainMap.put(currentDomain, currentAccountDomain);
                    }
                    else if (currentAccountDomain.Reference_Count__c == existingEntryFromDomain.Reference_Count__c) {
                        // If the Reference Counts are equal, compare by Account createdDate
                        if (currentAccountDomain.Account__r.CreatedDate < existingEntryFromDomain.Account__r.CreatedDate) {
                            domainMap.put(currentDomain, currentAccountDomain);
                        }
                    }
                }
            }
            return domainMap;
        }
        catch (Exception e) { // If something fails, log an exception and return null
            new LoggedException(e,'There was an issue querying for Account_Domain__c\'s','Domain_LeadRouting');
            return null;
        }
    }
}