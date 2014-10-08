public class ContactTriggerHelper {

	public static final string QUOTE_APPROVAL_STATUS_IN_REVIEW 	= 'In Review';
	public static final string QUOTE_APPROVAL_STATUS_APPROVED 	= 'Approved';
	
	public static final string QUOTE_STATUS_NEW 				= 'New';
	public static final string QUOTE_STATUS_SENT_TO_Z_BILLING 	= 'Sent to Z-Billing';
	
    public static void beforeInsert(List<Contact> contactList) {

         Contact_UniqueEmailCheck.checkForDuplicateEmails(contactList);
    }

    public static void afterInsert(Map<Id,Contact> contactMap) {

    }

    public static void beforeUpdate(Map<Id,Contact> newContactMap,
                                    Map<Id,Contact> oldContactMap) {

		    validate(newContactMap.values(), oldContactMap);     
        Contact_UniqueEmailCheck.checkForDuplicateEmails(oldcontactMap, newContactMap);
    }

    public static void afterUpdate(Map<Id,Contact> newContactMap,
                                   Map<Id,Contact> oldContactMap) {


    }

    public static void beforeDelete(Map<Id,Contact> oldcontactMap) {

		    validateDeletion(oldcontactMap.values());    

    }

    public static void afterDelete(Map<Id,Contact> oldContactMap) {

    }

 
   	public static void validate(List<Contact> contactList,
                                    Map<Id,Contact> oldContactMap) {

 		Set<Id> contactIds = new Set<Id>();
		Map<Id, Contact> contactMap = new Map<Id, Contact>();

        for(Contact c : contactList){

			contactIds.add(c.Id);

        }//end-for

		// verify whether address can be changed if it's used on a quote 

		for(Contact c : [Select c.Id, 
								(Select id From zqu__Quotes2__r Where Lock_Contact_Address__c = True limit 1) 
							From Contact c
								Where id in: contactIds]){
			
			contactMap.put(c.Id, c);
				
		}//end-for
				
		Contact updatedContact;
		Contact oldContact;
		
        for(Contact c : contactList){
        	
        	updatedContact=contactMap.get(c.Id);
        	oldContact=oldContactMap.get(c.Id); 
        	System.debug('>>>>>>>>c.System_Update_Counter__c='+c.System_Update_Counter__c);
        	System.debug('>>>>>>>>oldContact.System_Update_Counter__c='+oldContact.System_Update_Counter__c);
        	// this update is exempted from validation
        	if(c.System_Update_Counter__c != oldContact.System_Update_Counter__c){
        		continue;
        	}
        	
        	if(isAddressChanged(c, oldContact)
        		&& updatedContact.zqu__Quotes2__r!=null 
        		&& updatedContact.zqu__Quotes2__r.size()>0){
        			
        		c.addError(Label.Z_CONTACT_ADDRESS_UPDATE_ERROR);	
        	
        	}	
        	
        }		
		
		

	}

  	public static boolean isAddressChanged(Contact newContact, Contact oldContact){
  	
  		boolean addressChanged=false;
  		
  		if(newContact.MailingStreet != oldContact.MailingStreet
  			|| newContact.MailingState != oldContact.MailingState
  			|| newContact.MailingPostalCode != oldContact.MailingPostalCode
  			|| newContact.MailingCountry != oldContact.MailingCountry
  			|| newContact.MailingCity != oldContact.MailingCity){
  		
  			addressChanged=true;		
  		}
  		
  		
  		return addressChanged;
  			
  	}
 	
   	public static void validateDeletion(List<Contact> contactList){
   	
   		// contact can't be deleted if it is on a quote

 		Set<Id> contactIds = new Set<Id>();
 		Map<Id, Contact> contactMap = new Map<Id, Contact>();

      for(Contact c : contactList){

			 contactIds.add(c.Id);

      }//end-for
   			
		for(Contact c : [Select c.Id, 
								(Select id From zqu__Quotes2__r limit 1), 
								(Select id From zqu__Quotes__r limit 1) 
							From Contact c
								Where id in: contactIds]){
			
			contactMap.put(c.Id, c);
				
		}//end-for
		
		
		Contact deletedContact;
		
        for(Contact c : contactList){
        
        	deletedContact = contactMap.get(c.Id);
        	
        	if(deletedContact!=null){
        	
        		if(deletedContact.zqu__Quotes2__r != null && deletedContact.zqu__Quotes2__r.size()>0){
    				  c.addError(Label.Z_CONTACT_DELETION_ERROR);	
        		}else if(deletedContact.zqu__Quotes__r != null && deletedContact.zqu__Quotes__r.size()>0){
        			c.addError(Label.Z_CONTACT_DELETION_ERROR);	
        		}
        		
        		
        	}//end-if	
        	
        }
		
   	}	

}