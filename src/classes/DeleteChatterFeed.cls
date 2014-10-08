global class DeleteChatterFeed implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {
 
	public static final String FEED_ITEM_TYPE_CREATE_RECORD_EVENT = 'CreateRecordEvent';
	
  	public String query;
           
  	global DeleteChatterFeed() { 
 
  		// get a list of influence detail records created in 2013
  		
		if (Test.isRunningTest()) {
	    	query = 'Select f.Id From FCRM__FCR_Influence_Detail__c f limit 10';
		}else{
			query = 'Select f.Id From FCRM__FCR_Influence_Detail__c f where CALENDAR_YEAR(CreatedDate) = 2013';
		}
	
  	}
  
  	global Database.QueryLocator start(Database.BatchableContext BC) {
    	return Database.getQueryLocator(query);
  	}

  	global void execute(Database.BatchableContext BC, List<sObject> scope) {
  	
    	List<Id> influenceDetailIds = new List<Id>();

    	FCRM__FCR_Influence_Detail__c processInfluenceDetail; 
    	
    	for (sObject currentInfluenceDetail : scope) {
    	
    		processInfluenceDetail = (FCRM__FCR_Influence_Detail__c)currentInfluenceDetail;
    		
    		influenceDetailIds.add(processInfluenceDetail.Id);
 
    	}//end-for
      
    	if(influenceDetailIds.size()>0){
			deleteChatterFeed(influenceDetailIds);
    	}
    	
  	}
  
  	global void finish(Database.BatchableContext BC) {
    	// Nothing to do right now
  	}

  	// SCHEDULABLE

  	global void execute(SchedulableContext sc) {
    	DeleteChatterFeed batchClass = new DeleteChatterFeed();
    	Database.executeBatch(batchClass);
  	}

  	
  	public static void deleteChatterFeed(List<Id> influenceDetailIds){
  	
  		if(influenceDetailIds==null || influenceDetailIds.size()==0){
  			return;
  		}
  		
  		List<FeedItem> deleteFeedItems = new List<FeedItem>();
  		
  		for(FeedItem fi : [SELECT Id,ParentId,Title,Type 
  								FROM FeedItem 
  									WHERE ParentId in: influenceDetailIds 
  											AND Type =: FEED_ITEM_TYPE_CREATE_RECORD_EVENT]){
  			deleteFeedItems.add(fi);	
  		}//end-for
  		
  		if(deleteFeedItems.size()>0){
  			delete deleteFeedItems;
  		}
  	
  	}  	
 
}