/**
 * Utilities for domain mapping
 *
 * @author Kyle Vermeer 6/19/14
 */
public class Domain_Utilities {

    private static final String AT_SIGN = '@';
    private static final String PERIOD = '.';

    /**
     * This method fetches the domain from an e-mail address.
     *
     * If the provide argument is not a valid e-mail address, returns null.
     * The base domain for kvermeer@box.com is box.com, 
     * the base domain for kvermeer@server1.mail.box.com is box.com.
     *
     * @param {String} email -  email from which to grab the domain
     * @return {String} - domain of the provided e-mail
     */
    public static String getFullDomain(String email) {
        if (email == null) {
            System.debug('Email provided was null!');
            return null;
        }
        Integer indexOfAtSign = email.indexOf(AT_SIGN);
        if (indexOfAtSign == -1) {
            System.debug('No @ sign could be found in e-mail!');
            return null;
        }

        String fullDomain = email.substring(indexOfAtSign + 1);
        if (fullDomain.indexOf(PERIOD) == -1) {
            System.debug('Domain must have a period at some point!');
            return null;
        }

        return fullDomain;
    }

    /**
     * This method fetches the base domain from an e-mail address. 
     *
     * If the provide argument is not a valid e-mail address, returns null.
     * The base domain for kvermeer@box.com is box.com, 
     * the base domain for kvermeer@server1.mail.box.com is box.com.
     *
     * @param {String} email -  email from which to grab the domain
     * @return {String} - domain of the provided e-mail
     */
    public static String getBaseDomain(String email) {
        String fullDomain = getFullDomain(email);
        if (fullDomain == null) {
            System.debug('Trouble gathering the full domain!');
            return null;
        }
        // If there are multiple instances of periods, there is a multi-level domain
        if (fullDomain.lastIndexOf(PERIOD) != fullDomain.indexOf(PERIOD)) {
            // Will find the period of the base domain ~~> (.com)
            Integer lastPeriodIndex = fullDomain.lastIndexOf(PERIOD);
            System.debug('lastPeriodIndex: ' + lastPeriodIndex);
            String stringWithoutLastPeriod = fullDomain.substring(0, lastPeriodIndex);
            // Will find the period before the base domain ~~> (.box.com)
            Integer secondToLastPeriodIndex = stringWithoutLastPeriod.lastIndexOf(PERIOD);
            System.debug('secondToLastPeriodIndex: '+ secondToLastPeriodIndex);
            String baseDomain = fullDomain.substring(secondToLastPeriodIndex + 1);
            return baseDomain;
        }
        else { // Only one period, is a single-level domain
            return fullDomain;
        }
    }

    /**
     * Gets a set of all the black listed domains
     *
     * @return {Set<String>} - set of all black listed domains ~~> forced to lower-case
     */
    public static Set<String> getBlackListedDomains() {
        Set<String> blackListedDomains = new Set<String>();
        List<Domain_Matching_BlackList_Domain__c> blacklistedDomainSettings = Domain_Matching_BlackList_Domain__c.getAll().values();
        System.debug('blacklistedDomainSettings: ' + blacklistedDomainSettings);
        for (Domain_Matching_BlackList_Domain__c currentBlackListedDomainSetting : blacklistedDomainSettings) {
            blackListedDomains.add(currentBlackListedDomainSetting.Domain__c.toLowerCase());
        }
        System.debug('blackListedDomains: ' + blackListedDomains);
        return blackListedDomains;
    }

    /**
     * Returns the account id for the provided domain.  Returns null if none could be found.
     *
     * @param String domain - email domain to find account for
     * @return Id - id of account associated with domain
     */
    public static Id getAccountForDomain(String domain) {
        if( domain == null ) { // First check for null inputs
            System.debug('Null domain provided, cannot find Account for that');
            return null;
        }
        Set<String> blackListedDomains = getBlackListedDomains();
        if( blackListedDomains.contains(domain) ) {
            System.debug('Black listed domain provided, returning null.');
            return null;
        }
        Map<String, Account_Domain__c> domainToAccountDomain = Domain_LeadRouting.getAccountDomainMap(new Set<String> { domain });
        //TODO: FINISH
        Account_Domain__c accountDomain = domainToAccountDomain.get(domain);
        if( accountDomain == null ) { // Domain was not found
            System.debug('Account could not be found for domain: ' + domain);
            return null;
        }
        else { // Domain was found
            return accountDomain.Account__c;
        }
    }

    /**
     * Returns the account id for the provided email.  Returns null if none could be found.
     *
     * First check full domain, then check base domain
     *
     * @param String email - email to find account for
     * @return Id - id of account associated with email domain
     */
    public static Id getAccountForEmail(String email) {
        if( email == null ) {
            System.debug('Null email provided, cannot find Account for that');
            return null;
        }
        // First check full domain
        String fullDomain = getFullDomain(email);
        Id accountId = getAccountForDomain(fullDomain);
        if( accountId == null ) {
            String baseDomain = getBaseDomain(email);
            if( baseDomain != fullDomain ) { // if the base and full domain are different, check base domain
                accountId = getAccountForDomain(baseDomain);
            }
        }
        return accountId;
    }

}