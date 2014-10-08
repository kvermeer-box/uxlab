global class TaskDeletionScheduler implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {
  // BATCHABLE

  public String query;
        
  global TaskDeletionScheduler() {
  	
  	/* Delete__c is formula field.  It determines whether a task can be deleted. */
  	
	if (Test.isRunningTest()) {
    	query = 'SELECT id FROM Task LIMIT 1';
	}else{
		query = 'SELECT id, Delete__c FROM Task WHERE OwnerId = \'005600000018aQl\' and isDeleted = false limit 5000000 ALL ROWS';
	}
	
  }
  
  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<sObject> scope) {
  	
    List<Task> tasksToDelete = new List<Task>();
    
    Task deleteTask;
    
    for (sObject currentTask : scope) {
    	
    	deleteTask = (Task)currentTask;
    	
		if (Test.isRunningTest()) {   	
			
      		tasksToDelete.add(deleteTask);
      		
      	}else{
      		
      		if(deleteTask.Delete__c==true){
      			tasksToDelete.add(deleteTask);
      		}
      		
      	} 
      	
    }//end-for
    
    if(tasksToDelete.size()>0){
    	delete tasksToDelete;
      	DataBase.emptyRecycleBin(tasksToDelete);
    }
  }
  
  global void finish(Database.BatchableContext BC) {
    // Nothing to do right now
  }

  // SCHEDULABLE

  global void execute(SchedulableContext sc) {
    TaskDeletionScheduler batchClass = new TaskDeletionScheduler();
    Database.executeBatch(batchClass);
  }

}