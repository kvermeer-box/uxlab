public class LeadTriggerHelper {

	public static boolean preventLooping = false;

    ///////////////////////////////
    // Trigger Handling Methods
    ///////////////////////////////

    /**
     * Before insert trigger functionality
     *
     * @param {List<Lead>} leadList - Trigger.new
     */
    public static void beforeInsert(List<Lead> leadList) {
        Domain_LeadRouting.attachLeadsToAccounts(leadList);
    }

    /**
     * After insert trigger functionality
     *
     * @param {List<Lead>} newMap - Trigger.newMap
     */
    public static void afterInsert(Map<Id,Lead> newMap) {}

    /**
     * Before update trigger funcionality
     *
     * @param {Map<Id,Lead>} oldMap - Trigger.oldMap
     * @param {Map<Id,Lead>} newMap - Trigger.newMap
     */
    public static void beforeUpdate(Map<Id,Lead> oldMap,
                                    Map<Id,Lead> newMap) {
        Domain_LeadRouting.attachLeadsToAccounts(newMap.values());
    }

    /**
     * After update trigger functionality
     *
     * @param {Map<Id,Lead>} oldMap - Trigger.oldMap
     * @param {Map<Id,Lead>} newMap - Trigger.newMap
     */
    public static void afterUpdate(Map<Id,Lead> oldMap,
                                   Map<Id,Lead> newMap) {                                  
        updateObjects(newMap.values(),oldMap);       
    }

    /**
     * Before delete trigger functionality
     *
     * @param {Map<Id,Lead>} oldMap - Trigger.oldMap
     */
    public static void beforeDelete(Map<Id,Lead> oldMap) {}

    /**
     * After delete trigger functionality
     *
     * @param {Map<Id,Lead>} oldMap - Trigger.oldMap
     */
    public static void afterDelete(Map<Id,Lead> oldMap) {}

    /**
     * After Undelete trigger functionality
     *
     * @param {Map<Id,Lead>} newMap - Trigger.newMap
     */
    public static void afterUndelete(Map<Id,Lead> newMap) {}


    ////////////////////////////
    // Implementation Methods
    ////////////////////////////
    
	public static void updateObjects(List<Lead> leadList,
	                                   Map<Id,Lead> oldLeadMap){
	
		if(preventLooping){
			return;
		}
	
		Lead oldLead;
		List<Lead> convertedLeadList = new List<Lead>();
		
		for(Lead l : leadList){
		
			oldLead = oldLeadMap.get(l.id);
			
			System.debug('>>>>>>l='+l.ConvertedOpportunityId);
			System.debug('>>>>>>oldLead='+oldLead.ConvertedOpportunityId);
			
			
			//conversion has occurred
			if(l.ConvertedOpportunityId != null 
				&& l.ConvertedOpportunityId!=oldLead.ConvertedOpportunityId){
				
				convertedLeadList.add(l);	
			}	
			
		}//end-for
	
		if(convertedLeadList.size()>0){
			QualificationNoteUtility.createNote(convertedLeadList);   
		}
	}
}