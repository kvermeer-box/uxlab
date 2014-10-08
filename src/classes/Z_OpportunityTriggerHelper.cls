public class Z_OpportunityTriggerHelper {

	public static string OPPORTUNITY_STAGE_SUBMIT_FOR_APPROVAL = 'Submit for Approval';

    public static void beforeUpdate(List<Opportunity> opportunityList,
                                    Map<Id,Opportunity> oldOpportunityMap) {

        updateFields(opportunityList, oldOpportunityMap);
        // get live quote and populate opportunity

        updateQuoteFields(opportunityList, oldOpportunityMap);
 

    }

    public static void afterUpdate(List<Opportunity> opportunityList,
                                    Map<Id,Opportunity> oldOpportunityMap) {
                                    	
    
		updateQuotes(opportunityList);
        updateContacts(opportunityList, oldOpportunityMap);
                 
    }


	public static void updateQuotes(List<Opportunity> opportunityList ){
    
    	Set<Id> quoteIds = new Set<Id>();
    	Map<Id, zqu__Quote__c> quoteMap = new Map<Id, zqu__Quote__c>();
    	List<zqu__Quote__c> updateQuoteList = new List<zqu__Quote__c>();
    
    	for(Opportunity opp : opportunityList){
    		
    		if(opp.Live_ZQuote__c!=null){
    			quoteIds.add(opp.Live_ZQuote__c);
    		}	
    	} 
    	
    	System.debug('>>>>>>>updateQuotes.quoteIds='+quoteIds);
    	
    	for(zqu__Quote__c q : [Select Id, Signed_by_Customer__c, live_quote__c from zqu__Quote__c where Id in: quoteIds]){
    	
    		quoteMap.put(q.Id, q);
    		 
    	}

    	System.debug('>>>>>>>updateQuotes.quoteMap='+quoteMap);

		zqu__Quote__c liveQuote;
		
    	for(Opportunity opp : opportunityList){
    		
    		 
    		if(opp.Live_ZQuote__c!=null && quoteMap.containsKey(opp.Live_ZQuote__c)){
    		
    			liveQuote=quoteMap.get(opp.Live_ZQuote__c);
    			
    			if(liveQuote.Signed_by_Customer__c == false){
    				
    				liveQuote.live_quote__c=true;
    				liveQuote.Signed_by_Customer__c=true;
    				
    				updateQuoteList.add(liveQuote);
    			}
    		
    			 
    		}	
    	}//end-for
    	
    	if(updateQuoteList.size()>0){
    		update updateQuoteList;
    	}     	
    	                               	
                                    	
	}
	

    public static void updateQuoteFields(List<Opportunity> opportunityList,
                                    Map<Id,Opportunity> oldOpportunityMap){
    
        List<Opportunity> updateOpportunities = new List<Opportunity>();

        
        Opportunity oldOpp;
        
        for(Opportunity opp : opportunityList){
        
            oldOpp = oldOpportunityMap.get(opp.Id);
            
            if(opp.StageName == OPPORTUNITY_STAGE_SUBMIT_FOR_APPROVAL 
                && opp.stageName != oldOpp.stageName){
                    
                updateOpportunities.add(opp); 
                
            }//end-if
        }


        if(updateOpportunities.size()>0){ 
            Z_QuoteUtility.updateQuoteFields(updateOpportunities);
        }

    }           
	
	public static void updateFields(List<Opportunity> opportunityList,
                                    Map<Id,Opportunity> oldOpportunityMap){
    
    	Set<Id> oppIds = new Set<Id>();
    	Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
    	
    	Opportunity oldOpp;
    	
    	for(Opportunity opp : opportunityList){
    	
    		oldOpp = oldOpportunityMap.get(opp.Id);
    		
    		if(opp.StageName == OPPORTUNITY_STAGE_SUBMIT_FOR_APPROVAL 
    			&& opp.stageName != oldOpp.stageName){
    				
    			oppIds.add(opp.Id);	
    			
    		}//end-if
    		
    		
    	}//end-for                                	
  	
		if(oppIds.size()>0){
	
			for(Opportunity opp : [SELECT Id,    
										(SELECT Id, Live_Quote__c, signed_by_customer__c, zqu__SubscriptionType__c FROM zqu__Quotes__r) 
		                     				FROM Opportunity 
		                    				WHERE Id in :oppIds]){
		        
		        oppMap.put(opp.Id,opp);

				           	
			}//end-for	
		
		}
		
		List<zqu__Quote__c> quoteList;
 
		List<zqu__Quote__c> updateQuoteList = new List<zqu__Quote__c>();
		
		for(Opportunity opp : opportunityList){

		        
	        if(opp.StageName == OPPORTUNITY_STAGE_SUBMIT_FOR_APPROVAL
	        	&& opp.stageName != oldOpp.stageName){  

				quoteList = oppMap.get(opp.Id).zqu__Quotes__r;
         
	        	 	
				if (quoteList != null){
					
					if(quoteList.size() == 1) {

						opp.live_zquote__c = quoteList.get(0).Id;						

					}else{
						
						
						for(zqu__Quote__c q : quoteList){
							
							if(q.Signed_by_Customer__c){
								
								opp.live_zquote__c = q.Id;
							}		
							 
						}
					
					}
					
					
					
				} 
				
	        }//end-if

			
		}//end-for
	
	} 
	
	
	/* populate contact mailing address with quote sold to address */
    public static void updateContacts(List<Opportunity> opportunityList,
                                    Map<Id,Opportunity> oldOpportunityMap){
        
        Set<Id> quoteIds = new Set<Id>();
		Map<Id, zqu__Quote__c> quoteMap = new Map<Id, zqu__Quote__c>();
        Set<Id> contactIds = new Set<Id>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        List<Contact> updateContactList = new List<Contact>();
        
        Opportunity oldOpp;
        
        // get new live z uoqtes;
        for(Opportunity opp : opportunityList){
        
            oldOpp = oldOpportunityMap.get(opp.Id);
            
            if(opp.StageName == OPPORTUNITY_STAGE_SUBMIT_FOR_APPROVAL
            	&& opp.live_zquote__c != null  
                && opp.live_zquote__c != oldOpp.live_zquote__c){
                    
            	quoteIds.add(opp.live_zquote__c);     
                
            }//end-if
        }


 		if(quoteIds.size()>0){
 			for(zqu__Quote__c q : [Select z.zqu__SoldToContact__c, z.Sold_To_Zip_Code__c, 
 											z.Sold_To_Street__c, z.Sold_To_State__c, 
 											z.Sold_To_Country__c, z.Sold_To_City__c, z.Id 
 										From zqu__Quote__c z
 											where Id in: quoteIds]){
 			
 				quoteMap.put(q.Id, q);		
 				if(q.zqu__SoldToContact__c!=null){
 					contactIds.add(q.zqu__SoldToContact__c);
 				}						
 			}//end-for
 		}
 		
 		if(contactIds.size()>0){
 		
 			for(Contact c : [Select c.MailingStreet, c.MailingState, c.MailingPostalCode, 
 										c.MailingCountry, c.MailingCity, c.Id, c.System_Update_Counter__c 
 									From Contact c
 										Where Id in: contactIds]){
 						
 				contactMap.put(c.Id,c);			
 											
 			}//end-for		
 			
 		}
 		
 		Contact selectedSoldToContact;
 		Id soldToContactId;
 		zqu__Quote__c selectedQuote;
 		
 		for(Id quoteId : quoteIds){
 			
 			selectedQuote = quoteMap.get(quoteId);
 			soldToContactId = selectedQuote.zqu__SoldToContact__c;
 			selectedSoldToContact = contactMap.get(soldToContactId);
 			
 			// no sold to contact, no record to update
 			// continue to next quote
 			if(selectedSoldToContact==null){
 				continue;
 			}
 			
 			// quote address is blank, no contac record to udpate
 			// continue to next quote
 			if(isQuoteAddressBlank(selectedQuote)){
 				continue;
 			}
 			
 			if(isAddressDifferent(selectedQuote, selectedSoldToContact)){
 				
 				updateAddress(selectedQuote, selectedSoldToContact);
 				updateContactList.add(selectedSoldToContact);	
 			}
 			
 		}//end-for
 		
		if(updateContactList.size()>0){
			update updateContactList;
		}
    }  	 

  	public static void updateAddress(zqu__Quote__c selectedQuote, Contact selectedContact){
 
 
		selectedContact.MailingStreet		= selectedQuote.Sold_To_Street__c;
  		selectedContact.MailingState 		= selectedQuote.Sold_To_State__c; 
  		selectedContact.MailingPostalCode	= selectedQuote.Sold_To_Zip_Code__c;
  		selectedContact.MailingCountry 		= selectedQuote.Sold_To_Country__c;
  		selectedContact.MailingCity 		= selectedQuote.Sold_To_City__c;
  		
  		if(selectedContact.System_Update_Counter__c==null){
  			selectedContact.System_Update_Counter__c=1;
  		}else{
  			selectedContact.System_Update_Counter__c=selectedContact.System_Update_Counter__c+1;	
  		} 
  	}


  	public static boolean isQuoteAddressBlank(zqu__Quote__c selectedQuote){
  	
  		boolean isBlank=false;
  		
  		
  		if(selectedQuote.Sold_To_Street__c == null 
  			&& selectedQuote.Sold_To_State__c == null
  			&& selectedQuote.Sold_To_Zip_Code__c == null
  			&& selectedQuote.Sold_To_Country__c == null
  			&& selectedQuote.Sold_To_City__c == null){
  		
  			isBlank=true;		
  		}
  		
  		
  		return isBlank;
  			
  	} 

  	public static boolean isAddressDifferent(zqu__Quote__c selectedQuote, Contact selectedContact){
  	
  		boolean addressDifferent=false;
  		
  		
  		if(selectedContact.MailingStreet != selectedQuote.Sold_To_Street__c
  			|| selectedContact.MailingState != selectedQuote.Sold_To_State__c 
  			|| selectedContact.MailingPostalCode != selectedQuote.Sold_To_Zip_Code__c
  			|| selectedContact.MailingCountry != selectedQuote.Sold_To_Country__c
  			|| selectedContact.MailingCity != selectedQuote.Sold_To_City__c){
  		
  			addressDifferent=true;		
  		}
  		
  		
  		return addressDifferent;
  			
  	}                              
}