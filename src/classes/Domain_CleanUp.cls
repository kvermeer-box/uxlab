/**
 * Batch class to delete Account_Domain__c's without Accounts
 *
 * @author Kyle Vermeer 7/3/14
 */
public class Domain_CleanUp implements Database.Batchable<sObject>, Database.Stateful {
    
    public Integer deletionCount;

    //////////////////////
    // BATCHABLE
    //////////////////////

    String query;

    public Domain_CleanUp() {
        query = 'SELECT Id, Account__c From Account_Domain__c WHERE Account__c = null';
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        this.deletionCount = 0;
        return Database.getQueryLocator(query);
    }

   public void execute(Database.BatchableContext BC, List<sObject> scope) {
        this.deletionCount += scope.size();
        delete scope;
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('Deletion Count: ' + this.deletionCount);
        // Nothing to do right now
    }
}