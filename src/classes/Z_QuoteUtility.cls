/**
 * Utility methods for sycning quote values to opp
 *
 * @author Richard Wu 5/1/14
 * @revision Kyle Vermeer 5/8/14 Modified updateOpportunityFields to return a list of error messages
 * @revision Kyle Vermeer 6/25/14 Added setPDFCreated()
 */

global class Z_QuoteUtility {

 	public static String SUBSCRIPTION_TYPE_NEW_SUBSCRIPTION 	= 'New Subscription';
 	public static String SUBSCRIPTION_TYPE_RENEW_SUBSCRIPTION 	= 'Renew Subscription';
 	public static String SUBSCRIPTION_TYPE_AMEND_SUBSCRIPTION 	= 'Amend Subscription';

 	public static String PAYMENT_FREQUENCY_PREPAY 				= 'Prepay';
 
    public static List<ApexPages.Message> makeSignedQuote(Id quoteId) {
        
        List <ApexPages.Message> messagesList = new List <ApexPages.Message>();
        zqu__Quote__c quote;
        
        try{
        
        	quote = new zqu__Quote__c (Id=quoteId);
        	quote.Signed_by_Customer__c = true;
        	quote.Live_Quote__c=true;
        	update quote;		
        	
        } catch (Exception e) {
 
        	messagesList.add(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
           
        }

 		return messagesList;
    } 

    public static List<ApexPages.Message> makeLiveQuote(Id quoteId) {
        
        List <ApexPages.Message> messagesList = new List <ApexPages.Message>();
        zqu__Quote__c quote;
        
        try{
        
        	quote = new zqu__Quote__c (Id=quoteId);
        	quote.Live_Quote__c = true;
        	update quote;		
        	
        } catch (Exception e) {
 
        	messagesList.add(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
           
        }

 		return messagesList;
    }    

    public static void updateQuoteFields(List<Opportunity> opportunityList) {
    
    	List<Id> liveQuoteIds = new List<String>();
    	Map<String, zqu__Quote__c> quoteMap = new Map<String, zqu__Quote__c> ();
    
    	if(opportunityList==null || opportunityList.size()==0){
    		return;	
    	}	
    	
    	for(Opportunity opp : opportunityList){
    	
    		if(opp.Live_ZQuote__c != null){
    			liveQuoteIds.add(opp.Live_ZQuote__c);	
    		}
    		
    	}
 
		for(zqu__Quote__c q : [SELECT Id, ARR__c, NRR_Opportunity__c, Payment_Frequency__c, 
                            Zqu__Opportunity__c, Box_Consulting__c, 
                            Zqu__PaymentMethod__c, signed_by_customer__c, 
                            Zqu__InitialTerm__c, Live_Quote__c, account_type_sold__c,  
                            Seats_Sold__c, Delta_ARR__c, zqu__SubscriptionType__c,
                            Renewal_Amount_Opportunity__c   
                       FROM zqu__Quote__c 
                	      WHERE Id in :liveQuoteIds]){
                      	
        
            	quoteMap.put(q.Id, q);          	
		
		}//end-for
        
        
		zqu__Quote__c quote;
        	
		for(Opportunity opp : opportunityList){
        	
        		if(opp.Live_ZQuote__c==null){
        			return;
        		}
        		
        		quote=quoteMap.get(opp.Live_ZQuote__c);	

				/* START - update these fields for all quote types: new, amend, renew */
				
	            opp.System_Update_Counter__c = opp.System_Update_Counter__c != null ? opp.System_Update_Counter__c + 1 : 1;
	             
	            opp.Account_Type_Sold__c 	= quote.Account_Type_Sold__c;
	            opp.Payment_Method__c 		= quote.Zqu__PaymentMethod__c;
	            
	            if(quote.Zqu__InitialTerm__c < 12){
	            	// this is short term
	            	opp.Fee_Frequency__c 	= PAYMENT_FREQUENCY_PREPAY;
	            	
	            }else{
	            	
	            	opp.Fee_Frequency__c 	= quote.Payment_Frequency__c;
	        	}
	            
	            opp.Payment_Term__c = quote.Zqu__InitialTerm__c;
	            
		        // Null out old live quote
		        opp.Live_Quote__c = null;
		            
		        // Set live zQuote
	            opp.Live_ZQuote__c = quote.Id;
		            
		             
	            /* END */
	            
	            if (quote.zqu__SubscriptionType__c==SUBSCRIPTION_TYPE_NEW_SUBSCRIPTION
					|| quote.zqu__SubscriptionType__c==SUBSCRIPTION_TYPE_AMEND_SUBSCRIPTION){
		        
		        	opp.Seats_Sold__c 		= quote.Seats_Sold__c; 
		            opp.Box_Consulting__c 	= quote.Box_Consulting__c;
		            
            		opp.ARR__c 				= quote.ARR__c;
		            opp.Amount				= quote.ARR__c;
		            opp.NRR__c 				= quote.NRR_Opportunity__c;

	            }else if (quote.zqu__SubscriptionType__c==SUBSCRIPTION_TYPE_RENEW_SUBSCRIPTION){
	            
	            	opp.Renewal_Amount__c 	= quote.Renewal_Amount_Opportunity__c;	
	            	
	            }
 
		}//end-for              
 
    }

    webservice static String setPDFCreated(String quoteId) {
        if (quoteId == null) { // check for null input
            return createPDFCreatedJSON(false, quoteId, 'Quote Id provided was null!');
        }
        zqu__Quote__c quote = null;
        try {
            quote = [SELECT Id, PDF_Has_Been_Created__c
                                     FROM zqu__Quote__c
                                    WHERE Id = :quoteId];
            if (quote.PDF_Has_Been_Created__c) {
                return createPDFCreatedJSON(true, quoteId, null);
            }
            quote.PDF_Has_Been_Created__c = true;
        }
        catch (Exception e) {
            new LoggedException(e,'Trouble finding quote for setPDFCreated', 'Z_QuoteUtility');
            return createPDFCreatedJSON(false, quoteId, 'Trouble querying for quote to set PDF created! Talk to sales ops!');
        }
        try {
            update quote;
        }
        catch (Exception e) {
            new LoggedException(e, 'Trouble updating quote for setPDFCreated', 'Z_QuoteUtility');
            return createPDFCreatedJSON(false, quoteId, 'Trouble updating quote so that it knows a PDF has been created! Talk to sales ops!');
        }
        // If it has succeeded
        return createPDFCreatedJSON(true, quoteId, null);
    }

    private static String createPDFCreatedJSON(Boolean success, String quoteId, String errorMessage) {
        // Write json object
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        if (quoteId != null) { // write a json field for datasource
            gen.writeStringField('quoteId', quoteId);
        }
        else { // If datasource is null, just send it over as null
            gen.writeNullField('quoteId');
        }
        gen.writeBooleanField('success', success);
        if (errorMessage == null) { // If error message is null, set to empty string
            errorMessage = '';
        }
        gen.writeStringField('error: ', errorMessage);
        gen.writeEndObject();
        String jsonString = gen.getAsString();
        gen.close();
        return jsonString;
    }

 
}