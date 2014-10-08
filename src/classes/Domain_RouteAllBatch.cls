/**
 * Batch class to attempt to populate an Account on all leads without an account using Domain Mapping
 *
 * @author Kyle Vermeer 7/24/14
 */
public class Domain_RouteAllBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    //////////////////////
    // BATCHABLE
    //////////////////////

    Integer leadsUpdated;

    String query;

    public Domain_RouteAllBatch() {
        this.leadsUpdated = 0;
        query = 'SELECT Id, Email, Account__c FROM Lead WHERE Account__c = null';
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

   public void execute(Database.BatchableContext BC, List<sObject> scope) {

        Lead[] leadsWithNewAccount = Domain_LeadRouting.attachLeadsToAccounts((List<Lead>) scope);
        update leadsWithNewAccount;
        this.leadsUpdated += leadsWithNewAccount.size();
    }

    public void finish(Database.BatchableContext BC) {
        // Send a summary email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {UserInfo.getUserEmail()};
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Salesforce Batch Job Summary');
        mail.setPlainTextBody('You ran the Domain_RouteAllBatch batch job.  ' + this.leadsUpdated + ' leads had their account updated.');
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

    
}