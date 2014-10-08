global class NAICSUpdater_batch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {

  private static final Integer MAX_BATCH_SIZE = (CustomSettings.getExternalServicesSettings('default') != null) ? (Integer) CustomSettings.getExternalServicesSettings('default').Max_Records_Per_NAICS_Batch__c : 5;
  
  // BATCHABLE

  public String query;
  
  global NAICSUpdater_batch() {
    query = 'SELECT Id, updateNAICSFields__c FROM Account WHERE updateNAICSFields__c = true';
  }
  
  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<sObject> scope) {
    Set<Id> accountIds = new Set<Id>();
    for (sObject curAccount : scope) {
      accountIds.add(curAccount.Id);
    }
    NAICSUpdater.updateNAICSFields(accountIds);
  }
  
  global void finish(Database.BatchableContext BC) {
    // Nothing to do right now
  }

  // SCHEDULABLE

  global void execute(SchedulableContext sc) {
    NAICSUpdater_batch batchClass = new NAICSUpdater_batch();
    Database.executeBatch(batchClass, 5);
  }
  
}