/**
 * This class contains utility methods and values for one-off methods to support Qualification Note object.
 *
 * @author Richard Wu <rwu@box.com>
 * @version 1.0
 *
 */

public class QualificationNoteUtility {
	
	public static final String LEAD_STATUS_QUALIFIED_NEW_OPPORTUNITY = 'Qualified - New Opportunity';

 	/* create note after lead has been converted */
    public static void createNote(List<Lead> leadList) {

		System.debug('>>>>>>>>>createNote<<<<<<<' );
		System.debug('>>>>>>>>>leadList='+leadList);
	    	  
    	Qualification_Note__c newNote;
    	
    	List<Qualification_Note__c> newNoteList = new List<Qualification_Note__c> ();
    	
    	LeadTriggerHelper.preventLooping = true;
    	
    	for(Lead l : leadList){
    	
    		// create note by copying values from lead 
			
			if(l.Status == LEAD_STATUS_QUALIFIED_NEW_OPPORTUNITY){
				
				if(containsNote(l)){
					
					newNote = copyNote(l);	
					newNoteList.add(newNote);
				}
				
			}
 
    	}//end-for
    	
    	if(newNoteList.size()>0){
    		insert newNoteList;
    	}	    	
 
    }	

    
    /* create note after an opportunity is created */
    public static void createNote(List<Opportunity> opportunityList) {

		System.debug('>>>>>>>>>createNote<<<<<<<' );

    	Set<Id> oppIds = new Set<Id>();
    	Set<Id> contactIds = new Set<Id>();
    	
 
    	Map<Id, Contact> contactMap = new Map<Id, Contact>();   // key=contact id
    	Map<Id, Id> oppContactMap = new Map<Id, Id>(); // key=opp id, value=contact id
    	    	
    	for(Opportunity opp : opportunityList){

    		oppIds.add(opp.Id);
 
    	}	

    	for(OpportunityContactRole ocr : [Select ContactId, IsPrimary, OpportunityId From OpportunityContactRole 
    											where isPrimary=true 
    												and OpportunityId in: oppIds]) {
    		
			oppContactMap.put(ocr.opportunityId, ocr.contactId);
			contactIds.add(ocr.contactId);
    		
    	}//end-for

		System.debug('>>>>>>>>>oppIds='+oppIds);
		System.debug('>>>>>>>>>contactIds='+contactIds);
    	
    	if(contactIds.size()>0){
	    	for(Contact c: [Select of_Users__c, Budget_Buying_Process__c, Business_Use_Case_Objective_Need__c,
									Compelling_Event_Urgency__c, Competition__c, Current_IT_Environment__c, 
									Decision_Maker_Authority__c, Next_Steps_Follow_Up_Question__c, 
									Opp_Details__c, Opp_Source__c, Pain__c, Timeframe_in_months__c,
									account.name
								from Contact 
									Where Id in:contactIds]){
	    	
				contactMap.put(c.Id, c);
	    	
			}
    	}

    	Qualification_Note__c newNote;
    	Contact fromContact;
    	Id fromContactId;
    	 
    	List<Qualification_Note__c> newNoteList = new List<Qualification_Note__c> ();
    	
    	for(Opportunity opp : opportunityList){
    	
    		// create note by copying values from contact 
    		
			fromContactId=oppContactMap.get(opp.Id);					
			
			if(fromContactId!=null){
 				fromContact=contactMap.get(fromContactId);
			}
			 
			if(fromContact!=null){

				if(containsNote(fromContact)){
				
					newNote = copyNote(opp.id, fromContact);
					newNoteList.add(newNote);
					
				}
    		} 
    	}//end-for
    	
    	if(newNoteList.size()>0){
    		insert newNoteList;
    	}	    	
 
    }	
	
	/* check if contact has note info */
	public static boolean containsNote(Contact fromContact) {	
	
		boolean containsNote=false;	
			
		System.debug('>>>>fromContact='+fromContact);
		
		if(fromContact.of_Users__c != null
			|| fromContact.Budget_Buying_Process__c != null
			|| fromContact.Business_Use_Case_Objective_Need__c != null
			|| fromContact.Compelling_Event_Urgency__c != null
			|| fromContact.Competition__c != null
			|| fromContact.Current_IT_Environment__c != null   
			|| fromContact.Decision_Maker_Authority__c != null
			|| fromContact.Next_Steps_Follow_Up_Question__c != null
			|| fromContact.Opp_Details__c != null
			|| fromContact.Opp_Source__c != null
			|| fromContact.Pain__c != null
			|| fromContact.Timeframe_in_months__c != null){
		
			
			containsNote=true;		
		}
		
		System.debug('>>>>containsNote='+containsNote);
		
		return containsNote;
	}
		
	/* check if lead has note info */	
	public static boolean containsNote(Lead fromLead) {	
	
		boolean containsNote=false;		
	
		System.debug('>>>>fromLead='+fromLead);
		
		if(fromLead.of_Users__c != null
			|| fromLead.Budget_Buying_Process__c != null
			|| fromLead.Business_Use_Case_Objective_Need__c != null
			|| fromLead.Compelling_Event_Urgency__c != null
			|| fromLead.Competition__c != null
			|| fromLead.Current_IT_Environment__c != null   
			|| fromLead.Decision_Maker_Authority__c != null
			|| fromLead.Next_Steps_Follow_Up_Question__c != null
			|| fromLead.Opp_Details__c != null
			|| fromLead.Opp_Source__c != null
			|| fromLead.Pain__c != null
			|| fromLead.Timeframe_in_months__c != null){
		
			containsNote=true;		
		}
		
		System.debug('>>>>containsNote='+containsNote);
		
		return containsNote;
	}
	
	
	/* copy note info from contact */
	public static Qualification_Note__c copyNote(Id oppId, Contact fromContact) {	
	
		Qualification_Note__c newNote = new Qualification_Note__c(Opportunity__c=oppId);		
		
		newNote.Name								= fromContact.Account.name;
		newNote.of_Users__c 						= fromContact.of_Users__c;
		newNote.Budget_Buying_Process__c 			= fromContact.Budget_Buying_Process__c;
		newNote.Business_Use_Case_Objective_Need__c = fromContact.Business_Use_Case_Objective_Need__c;
		newNote.Compelling_Event_Urgency__c 		= fromContact.Compelling_Event_Urgency__c;
		newNote.Competition__c 						= fromContact.Competition__c;
		newNote.Current_IT_Environment__c 			= fromContact.Current_IT_Environment__c;
		newNote.Decision_Maker_Authority__c 		= fromContact.Decision_Maker_Authority__c; 
		newNote.Next_Steps_Follow_Up_Question__c 	= fromContact.Next_Steps_Follow_Up_Question__c;
		newNote.Opp_Details__c 						= fromContact.Opp_Details__c;
		newNote.Opp_Source__c 						= fromContact.Opp_Source__c;
		newNote.Pain__c 							= fromContact.Pain__c;
		newNote.Timeframe_in_months__c 				= fromContact.Timeframe_in_months__c;
		
		return newNote;
	}
	
	/* copy note info from lead */
	public static Qualification_Note__c copyNote(Lead fromLead) {	
		
		Qualification_Note__c newNote = new Qualification_Note__c(Opportunity__c=fromLead.ConvertedOpportunityId);		
		
		newNote.Name								= fromLead.Company;
		newNote.OwnerId								= fromLead.OwnerId;
		newNote.of_Users__c 						= fromLead.of_Users__c;
		newNote.Budget_Buying_Process__c 			= fromLead.Budget_Buying_Process__c;
		newNote.Business_Use_Case_Objective_Need__c	= fromLead.Business_Use_Case_Objective_Need__c;
		newNote.Compelling_Event_Urgency__c 		= fromLead.Compelling_Event_Urgency__c;
		newNote.Competition__c 						= fromLead.Competition_qual__c;
		newNote.Current_IT_Environment__c		 	= fromLead.Current_IT_Environment__c;
		newNote.Decision_Maker_Authority__c 		= fromLead.Decision_Maker_Authority__c; 
		newNote.Next_Steps_Follow_Up_Question__c 	= fromLead.Next_Steps_Follow_Up_Question__c;
		newNote.Opp_Details__c 						= fromLead.Opp_Details__c;
		newNote.Opp_Source__c 						= fromLead.Opp_Source__c;
		newNote.Pain__c 							= fromLead.Pain_qual__c;
		newNote.Timeframe_in_months__c 				= fromLead.Timeframe_in_months__c;
		
		return newNote;
	}
}