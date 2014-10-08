/**
 * Trigger functionality to check that contacts contains unique email addresses
 *
 * @author Kyle Vermeer 9/24/14
 */
public class Contact_UniqueEmailCheck {

    private static final String DUPLICATE_EMAIL_ERROR_MESSAGE = 'A contact already contains this email! Cannot commit this contact to database.';

    public static void checkForDuplicateEmails(Contact[] newContacts) {
        Contact[] contactsToProcess = new Contact[] {};
        for( Contact currentContact : newContacts ) {
            if( currentContact.FCRM__FCR_Admin_Update_Counter__c == null || currentContact.FCRM__FCR_Admin_Update_Counter__c == 0 ) {
                contactsToProcess.add(currentContact);
            }
        }
        processPotenialDuplicates(contactsToProcess);
    }

    public static void checkForDuplicateEmails(Map<Id, Contact> oldMap, Map<Id, Contact> newMap) {
        Contact[] contactsToProcess = new Contact[] {};
        for( Contact currentContact : newMap.values() ) {
            Contact oldContact = oldMap.get(currentContact.Id);
            if( currentContact.FCRM__FCR_Admin_Update_Counter__c == oldContact.FCRM__FCR_Admin_Update_Counter__c ) {
                System.debug('Old Contact: ' + oldContact.FCRM__FCR_Admin_Update_Counter__c);
                System.debug('CurrentContact: ' + currentContact.FCRM__FCR_Admin_Update_Counter__c);
                System.debug('Added to process!');
                contactsToProcess.add(currentContact);
            }
        }
        processPotenialDuplicates(contactsToProcess);
    }

    private static void processPotenialDuplicates(Contact[] contactsToCheckForDuplicateEmails) {

        Map<String, Contact> emailToContact = new Map<String, Contact>();
        Set<Id> idsOfContactsInList = new Set<Id>(); // Use this list to make sure contacts don't conflict with themselves

        // 1. Check that email in memory doesn't conflict
        // Initial loop will check for email duplicates in the list of contacts being inserted/updated
        for( Contact currentContact : contactsToCheckForDuplicateEmails ) {
            if( currentContact.Id != null ) { // Populate set of ids, presuming the contact has an id
                idsOfContactsInList.add(currentContact.Id);
            }
            String email = currentContact.Email;
            if( email != null ) { // Make sure email isn't null
                String normalizedEmail = email.toLowerCase();
                if( emailToContact.containsKey(normalizedEmail) ) { // If a contact that is about to be commited already has this email, add error
                    currentContact.addError(DUPLICATE_EMAIL_ERROR_MESSAGE);
                }
                else { // No issue, add email to set of emails that have been checked
                    emailToContact.put(normalizedEmail, currentContact);
                }
            }
        }

        // 2. Check that email in database doesn't conflict
        Contact[] matchingContacts = [SELECT Id, Email 
                                        FROM Contact 
                                       WHERE Id NOT IN :idsOfContactsInList
                                         AND Email IN :emailToContact.keySet()];
        
        if( !matchingContacts.isEmpty() ) { // If there is some conflict already in the database
            for( Contact currentContact : matchingContacts ) {
                Contact violatingContact = emailToContact.get(currentContact.email.toLowerCase());
                violatingContact.addError(DUPLICATE_EMAIL_ERROR_MESSAGE);
            }
        }
    }

}