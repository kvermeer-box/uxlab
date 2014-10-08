public class Z_RatePlanGroup {

	public Map<String,Set<Id>> ratePlanGroupMap = new Map<String,Set<Id>>();
	public Map<String, Id> zuoraIdToSalesforceIdMap = new Map<String,Id>(); //Key=Zuora Rate Plan Id, Value=SFDC Rate Plan Id
	public Map<Id,id> ratePlanChargeMap = new Map<Id,Id>(); // Key= Rate Plan Charge Id, Value=SFDC Rate Plan Id
	
	
	
	public Z_RatePlanGroup (List<String> groupNames) {
 
		System.debug('>>>>>>>>>Z_RatePlanGroup<<<<<<<<<<<<');
				 
		if(groupNames==null || groupNames.size()==0){
			return;
		}
		
		Set<Id> ratePlanIds;
		Set<Id> allRatePlanIds = new Set<Id>();
		 
		
		for(Rate_Plan_Group_Member__c member : [Select r.Rate_Plan_Group__r.Name, r.Product_Rate_Plan_Zuora_ID__c, 
														r.Rate_Plan_Group__c, r.Product_Rate_Plan__c, r.Id 
													From Rate_Plan_Group_Member__c r
														Where r.Rate_Plan_Group__r.Name in: groupNames]){
			
			zuoraIdToSalesforceIdMap.put(member.Product_Rate_Plan_Zuora_ID__c, member.Product_Rate_Plan__c);
			allRatePlanIds.add(member.Product_Rate_Plan__c);
			
			ratePlanIds = ratePlanGroupMap.get(member.Rate_Plan_Group__r.Name);
			
			if(ratePlanIds==null){
				ratePlanIds = new Set<Id>();	
			}
			
			ratePlanIds.add(member.Product_Rate_Plan__c);
															
			ratePlanGroupMap.put(member.Rate_Plan_Group__r.Name, ratePlanIds);

											
		}//end-for 

		for(zqu__ProductRatePlanCharge__c prpc : [Select z.zqu__ZuoraId__c, z.zqu__ProductRatePlan__c, z.Id 
												From zqu__ProductRatePlanCharge__c z 
													where zqu__ProductRatePlan__c in:allRatePlanIds ]){
						
		
			ratePlanChargeMap.put(prpc.Id, prpc.zqu__ProductRatePlan__c);	
		}
			 
	}

	public boolean containsRatePlan(String groupName, Id ratePlanId){
	
		System.debug('>>>>>>>>>containsRatePlan<<<<<<<<<<<<');
	
		boolean containsRatePlan = false;

		System.debug('>>>>>groupName='+groupName);
		System.debug('>>>>>ratePlanId='+ratePlanId);
		
		if(groupName==null || ratePlanId==null){
			return containsRatePlan;
		}
		
		Set<Id> ratePlanGroupMembers = ratePlanGroupMap.get(groupName);

		System.debug('>>>>>ratePlanGroupMembers='+ratePlanGroupMembers);
		
		if(ratePlanGroupMembers!=null && ratePlanGroupMembers.contains(ratePlanId)){
			containsRatePlan=true; 
		}
		
		
		return containsRatePlan;
	}
	
	public boolean containsRatePlanZuoraId(String groupName, String ratePlanZuoraId){
	
		System.debug('>>>>>>>>>containsRatePlanZuoraId<<<<<<<<<<<<');
	
		boolean containsRatePlan = false;
		Id sfdcId;

		System.debug('>>>>>groupName='+groupName);
		System.debug('>>>>>ratePlanZuoraId='+ratePlanZuoraId);
		
		if(groupName==null || ratePlanZuoraId==null){
			return containsRatePlan;
		}
		
		Set<Id> ratePlanGroupMembers = ratePlanGroupMap.get(groupName);

		System.debug('>>>>>ratePlanGroupMembers='+ratePlanGroupMembers);
		
		sfdcId=zuoraIdToSalesforceIdMap.get(ratePlanZuoraId);
		
		if(ratePlanGroupMembers!=null && sfdcId!=null && ratePlanGroupMembers.contains(sfdcId)){
			containsRatePlan=true; 
		}
		
		
		return containsRatePlan;
	}
	
	public boolean containsRatePlanCharge(String groupName, String ratePlanChargeId){
	
		System.debug('>>>>>>>>>ratePlanChargeId<<<<<<<<<<<<');
	
		boolean containsRatePlanCharge = false;
		Id ratePlanId;
	 

		System.debug('>>>>>groupName='+groupName);
		System.debug('>>>>>ratePlanChargeId='+ratePlanChargeId);
		
		if(groupName==null || ratePlanChargeId==null){
			return containsRatePlanCharge;
		}
		
		Set<Id> ratePlanGroupMembers = ratePlanGroupMap.get(groupName);

		System.debug('>>>>>ratePlanGroupMembers='+ratePlanGroupMembers);
		
		ratePlanId=ratePlanChargeMap.get(ratePlanChargeId);
		
		return containsRatePlan(groupName, ratePlanId);
 
	}	

	/* provide a list of ids.  return a list of ids that are in the group */
	public List<Id> includeRatePlans(String groupName, Set<Id> ratePlanIds){
 
		
		List<Id> includedRatePlans = new List<Id>();
		
		if(groupName==null || ratePlanIds==null){
			return includedRatePlans;
		}
		
		Set<Id> ratePlanGroupMembers = ratePlanGroupMap.get(groupName);

		System.debug('>>>>>ratePlanGroupMembers='+ratePlanGroupMembers);
		
		for(Id ratePlanId : ratePlanIds){
		
			if(ratePlanGroupMembers!=null && ratePlanGroupMembers.contains(ratePlanId)){
				includedRatePlans.add(ratePlanId);
			}
		}
		
		
		return includedRatePlans;
	}

}