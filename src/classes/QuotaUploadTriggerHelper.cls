public class QuotaUploadTriggerHelper {



    public static void beforeInsert(List<Quota_Upload__c> newQuotaUploadList) {

        updateQuota(newQuotaUploadList);
        
    }

 

    public static void beforeUpdate(List<Quota_Upload__c> newQuotaUploadList, Map<Id,Quota_Upload__c> oldQuotaUploadMap) {

        updateQuota(newQuotaUploadList);                                              
 
    }



    public static void updateQuota(List<Quota_Upload__c> newQuotaUploadList) {
    	
    
    	/* Use Employee ID to get SFDC User ID */
    	
    	/* Use Employee Name to get SFDC User ID */	
    	
    	/* Use User ID and Start Date to get Revenue Forecast records */
    	
    	/* Upload Revenue Forecast or Create Revenue Forecast records */
    	
    	
    	Set<String> employeeIds = new Set<String>();
    	Set<Date> startDates = new Set<Date>();
    	Set<String> employeeNames = new Set<String>();
    	Map<String,User> employeeNameMap = new Map<String,User>();
    	Map<String,User> employeeIdMap = new Map<String,User>(); 
    	Set<Id> userIds = new Set<Id>();
    	Map<Id, Map<Date,RevenueForecast>> userRevenueForcastMap = new Map<Id, Map<Date,RevenueForecast>>();
    	
    	
    	for(Quota_Upload__c qu : newQuotaUploadList ){
    	
    		if(qu.employee_id__c!=null){
    			employeeIds.add(qu.employee_id__c);
    		}	
    		if(qu.Start_Date__c!=null){
    			startDates.add(qu.Start_Date__c);	
    		}	
    		if(qu.employee_name__c!=null){
    			employeeNames.add(qu.employee_name__c);
    		}	
    		
    	}//end-for

		// get list of users using employee id
		if(employeeIds.size()>0){
		
			for(User u : [Select u.Name, u.LastName, u.IsActive, u.Id, u.FirstName, u.Employee_ID__c 
								From User u
									Where IsActive = true and Employee_ID__c in : employeeIds]){
										
				if(u.Employee_ID__c!=null){
					employeeIdMap.put(u.Employee_ID__c, u);	
				}
			
			
			}//end-for
			
		}
		
		// get list of users using employee name
		if(employeeNames.size()>0){
			
			for(User u : [Select u.Name, u.LastName, u.IsActive, u.Id, u.FirstName, u.Employee_ID__c 
								From User u
									Where IsActive = true and Name in : employeeNames]){

				if(u.Name!=null){
					employeeNameMap.put(u.Name, u);	
				}
					
			}//end-for
		}
		
		// populate Employee field
		

    	for(Quota_Upload__c qu : newQuotaUploadList ){
    		
    		// employee field is populated, continue to next record
    		if(qu.Employee__c!=null){
    			continue;
    		}
    		
    		
    		if(qu.employee_id__c!=null && employeeIdMap.containsKey(qu.employee_id__c)){
    			
    			qu.Employee__c=employeeIdMap.get(qu.employee_id__c).Id;
    			continue;
    		}	
    		
 
    		if(qu.employee_name__c!=null  && employeeNameMap.containsKey(qu.employee_name__c)){
    			qu.Employee__c=employeeNameMap.get(qu.employee_name__c).Id;
    			continue;
    		}	
    	}//end-for
		    	
    	
    	for(Quota_Upload__c qu : newQuotaUploadList ){
    		
    		if(qu.Employee__c!=null){
    			userIds.add(qu.Employee__c);
    		}
    	}//end-for
    	
    	System.debug('>>>>>>>>>>userIds='+userIds);
    	Map<Date,RevenueForecast> revenueForecastMap;
    	
    	for(Id userId : userIds){
    		
    		revenueForecastMap=new Map<Date,RevenueForecast>();
    		userRevenueForcastMap.put(userId, revenueForecastMap);
    		
    	}
    	System.debug('>>>>>>>>>>revenueForecastMap='+revenueForecastMap);
    	if(userIds.size()>0){
    		
    		for(RevenueForecast rf : [Select r.StartDate, r.Quota, r.PeriodId, r.OwnerId, r.Id, r.CurrencyIsoCode 
    										From RevenueForecast r
    											Where OwnerId in : userIds and StartDate in : startDates ]){
    		
    		
    			System.debug('>>>>>>>>>rf='+rf);
    			revenueForecastMap = userRevenueForcastMap.get(rf.OwnerId);
    			
    			if(revenueForecastMap!=null){
    				revenueForecastMap.put(rf.StartDate,rf);	
    			}
    			
    		}//end-for 
    	}
    	System.debug('>>>>>>>>>>revenueForecastMap='+revenueForecastMap);
    	List<RevenueForecast> upsertRevenueForecastList = new List<RevenueForecast>();
    	
    	RevenueForecast selectedRevenueForecast;
    	
    	for(Quota_Upload__c qu : newQuotaUploadList){
    	
    		if(qu.Employee__c==null || qu.Start_Date__c==null){
    			continue;
    		}
    			
    			revenueForecastMap = userRevenueForcastMap.get(qu.Employee__c);	
    			
    			if(revenueForecastMap!=null && revenueForecastMap.containsKey(qu.Start_Date__c) ){

    				// a record is found, update it
    			
					System.debug('>>>>>> Record Found');
    			
    				selectedRevenueForecast	= revenueForecastMap.get(qu.Start_Date__c);

	    			System.debug('>>>>>>>>>selectedRevenueForecast='+selectedRevenueForecast);
	    			System.debug('>>>>>>>>>qu='+qu);
	    			System.debug('>>>>>>>>>selectedRevenueForecast.quota='+selectedRevenueForecast.quota);
    				
					// Update if quota and currency are different
    				if(selectedRevenueForecast.quota==qu.quota__c 
    					&&  selectedRevenueForecast.CurrencyIsoCode!=qu.CurrencyIsoCode){
    				
    						qu.Revenue_Forecast_ID__c=selectedRevenueForecast.Id;
					}else{
    					selectedRevenueForecast.quota = qu.quota__c;
    					selectedRevenueForecast.CurrencyIsoCode = qu.CurrencyIsoCode;
    					upsertRevenueForecastList.add(selectedRevenueForecast);
    				
    				}
    				
    			}else{ // no record is found, create a new one
    					
					System.debug('>>>>>> Create New Record');
				
					selectedRevenueForecast = new RevenueForecast();
					
					selectedRevenueForecast.OwnerId = qu.Employee__c;
					selectedRevenueForecast.quota = qu.Quota__c;
					selectedRevenueForecast.CurrencyIsoCode = qu.CurrencyIsoCode;
					selectedRevenueForecast.StartDate = qu.Start_Date__c;
					upsertRevenueForecastList.add(selectedRevenueForecast);
    			}

    	}//end-for
    	
    	
    	if(upsertRevenueForecastList.size()>0){

			System.debug('>>>>>> upsertRevenueForecastList='+upsertRevenueForecastList);
				
    		upsert upsertRevenueForecastList;	
    	}
    	
    	

    	
    	for(Quota_Upload__c qu : newQuotaUploadList){

			System.debug('>>>>>> qu='+qu);

    		for(RevenueForecast rf: upsertRevenueForecastList){	

				System.debug('>>>>>> rf='+rf);

				if(qu.Employee__c == rf.OwnerId && qu.Start_Date__c == rf.StartDate){
					
					qu.Revenue_Forecast_ID__c = rf.Id;
				}
			
			}
    		
    	} 
    	 
    	//update record 
    }

}