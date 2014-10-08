public class Z_QuoteTriggerHelper {

	public static final string QUOTE_APPROVAL_STATUS_IN_REVIEW 	= 'In Review';
	public static final string QUOTE_APPROVAL_STATUS_APPROVED 	= 'Approved';
	
	public static final string QUOTE_STATUS_NEW 				= 'New';
 	public static final String QUOTE_STATUS_SEND_TO_Z_BILLING   = 'Sent to Z-Billing';

 	public static String RATE_PLAN_GROUP_BOX_ORG 				= 'Box.org';
 	public static String RATE_PLAN_GROUP_BOX_CONSULTING 		= 'Box Consulting';

 	public static String SUBSCRIPTION_TYPE_NEW_SUBSCRIPTION 	= 'New Subscription';
 	public static String SUBSCRIPTION_TYPE_RENEW_SUBSCRIPTION 	= 'Renew Subscription';
 	public static String SUBSCRIPTION_TYPE_AMEND_SUBSCRIPTION 	= 'Amend Subscription';


 	public static String PRODUCT_GROUP_BOX_VIEW_API 			= 'Box View API';
 	public static String PRODUCT_GROUP_BOX_CONTENT_API 			= 'Box Content API'; 	
 	
 	public static String PAYMENT_FREQUENCY_PREPAY 				= 'Prepay';
 	
 	public static integer ELA_SEATS_THRESHOLD 					= 250;

 	public static String DEAL_TYPE_ELA 							= 'ELA';
 	 	
    public static void beforeInsert(List<zqu__Quote__c> quoteList) {
 
		initFields(quoteList);
		updateFields(quoteList);
		validate(quoteList);
		
    }
 
    public static void beforeUpdate(List<zqu__Quote__c> quoteList,
                                    Map<Id,zqu__Quote__c> oldQuoteMap) {
		
		updateFields(quoteList);
		updateAddressFields(quoteList,oldQuoteMap);		
		validate(quoteList);
		updateRollupFields(quoteList);
		 
    }
    
    public static void beforeDelete(List<zqu__Quote__c> quoteList) {
                                    	
    	validateDeletion(quoteList);                                	
    }
    
    
    public static void afterUpdate(List<zqu__Quote__c> quoteList,
                                   Map<Id,zqu__Quote__c> oldQuoteMap) {
 
 		updateZuoraCustomerAccount(quoteList, oldQuoteMap);
		updateRelatedQuotes(quoteList);
 		 
    }

 	public static void updateRelatedQuotes(List<zqu__Quote__c> quoteList){
 		/* Only 1 quote on an opportunity can set as live or signed quote */
 		/* a signed quote must the be live quote */
 		
 		
 		Set<Id> liveQuoteIds = new Set<Id>();
 		Set<Id> signedQuoteIds = new Set<Id>();
 		Set<Id> oppIds = new Set<Id>();
 		List<zqu__Quote__c> updateQuoteList = new List<zqu__Quote__c> ();
 		
 		for(zqu__Quote__c quote : quoteList){

 			if(quote.Signed_by_Customer__c){
 				signedQuoteIds.add(quote.Id);
 				oppIds.add(quote.zqu__Opportunity__c);	
 			}else if(quote.Live_Quote__c){
 				liveQuoteIds.add(quote.Id);
 				oppIds.add(quote.zqu__Opportunity__c);	
 			}	
 			
 		}
 		
 		if(oppIds.size()>0){
 			
 			for(zqu__Quote__c q : [Select z.zqu__Opportunity__c, z.Live_Quote__c, z.Id,		
 											z.signed_by_customer__c  
 											From zqu__Quote__c z
 												Where zqu__Opportunity__c in: oppIds]){
 			
 				
 				if(signedQuoteIds.contains(q.Id) || liveQuoteIds.contains(q.Id)){
 					// do nothing, this is a signed or live quote	
 					continue;
 				
 				}else{

 					if(q.Signed_by_Customer__c){
 						
 						// this was a signed quote but is no longer a signed quote
 						q.Signed_by_Customer__c=false;
 						q.Live_Quote__c=false;

 						updateQuoteList.add(q);
 						
 					}else if(q.Live_Quote__c){
 						// this was a live quote but is no longer a live quote
 						q.Live_Quote__c=false;
 						updateQuoteList.add(q);
 					}	
 					
 				}		
 				
 			}//end-for		
 		}
 		
 		if(updateQuoteList.size()>0){
 			update updateQuoteList;
 		}
 			
 		
 	}

 	public static void validateDeletion(List<zqu__Quote__c> quoteList){
 		
        /* Prevent user from deleting a quote if Delete_Quote__c = False */
        for(zqu__Quote__c q : quoteList){

            if(!q.Delete_Quote__c){
                q.addError(LABEL.Z_DELETE_QUOTE_ERROR);
            }

        }//end-for
	}

    public static void updateZuoraCustomerAccount(List<zqu__Quote__c> quoteList,
                                   Map<Id,zqu__Quote__c> oldQuoteMap){
   
   		zqu__Quote__c oldQuote;
   		
   		for(zqu__Quote__c quote : quoteList){
   		
   			oldQuote=oldQuoteMap.get(quote.Id);  
   			 
   			
   			if(quote.zqu__SubscriptionType__c == SUBSCRIPTION_TYPE_NEW_SUBSCRIPTION
   				&& quote.zqu__Status__c == QUOTE_STATUS_SEND_TO_Z_BILLING){
   				
   				if(quote.zqu__ZuoraAccountID__c!=null
   					&& quote.zqu__ZuoraAccountID__c!=oldQuote.zqu__ZuoraAccountID__c){
   					
   					Z_IntegrationUtility.updateZuoraAccount(quote.Account__c, quote.Sold_To_Contact_Country__c, quote.zqu__ZuoraAccountID__c, quote.Enterprise_ID__c); 	
   				
   				}	
   			}
   			
   		}//end-for                              	
   	}
                                   
    
    /* Bill To Contact and Sold To Contact must be associated with the account */
    /* Bill To and Sold To are required */
    public static void validate(List<zqu__Quote__c> quoteList) {
    	
		Set<Id> contactIds = new Set<Id>();
		Set<Id> opportunityIds = new Set<Id>();
		
		Map<Id, Contact> contactMap = new Map<Id, Contact>();
		Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
		
		for(zqu__Quote__c q : quoteList){
		
			if(q.zqu__BillToContact__c != null){
				contactIds.add(q.zqu__BillToContact__c);	
			}
			if(q.zqu__SoldToContact__c != null){
				contactIds.add(q.zqu__SoldToContact__c);	
			}
			
			if(q.zqu__Opportunity__c != null){
				opportunityIds.add(q.zqu__Opportunity__c);
			}
			
		}//end-for
		
		if(contactIds.size()>0){
			
			for(Contact c : [select id, AccountId from Contact Where Id in: contactIds]){
				contactMap.put(c.Id,c);	
			}//end-for
		
		}
		
		if(opportunityIds.size()>0){
			for(Opportunity opp : [select id, AccountId from Opportunity Where Id in: opportunityIds]){
				opportunityMap.put(opp.Id,opp);	
			}//end-for	
		}
		
		Contact selectedContact;
		Id selectedAccountId;
		for(zqu__Quote__c q : quoteList){
			
			if(q.zqu__Opportunity__c!=null){
				selectedAccountId = opportunityMap.get(q.zqu__Opportunity__c).AccountId;	
			}
		
			if(selectedAccountId!=null && q.zqu__BillToContact__c != null && contactMap.containsKey(q.zqu__BillToContact__c)){
				
				selectedContact=contactMap.get(q.zqu__BillToContact__c);
				
				if(selectedContact.AccountId!=selectedAccountId){
					q.addError(Label.Z_INVALID_BILL_TO_CONTACT_ACCOUNT);	
				}	
			
			}
			
			if(selectedAccountId!=null && q.zqu__SoldToContact__c != null && contactMap.containsKey(q.zqu__SoldToContact__c)){
			
				selectedContact=contactMap.get(q.zqu__SoldToContact__c);

				if(selectedContact.AccountId!=selectedAccountId){
					q.addError(Label.Z_INVALID_SOLD_TO_CONTACT_ACCOUNT);	
				}		
			
			}


			if(q.zqu__BillToContact__c==null){
				q.addError(Label.Z_BILL_TO_CONTACT_REQUIRED);	
			}
			
			if(q.zqu__SoldToContact__c==null){
				q.addError(Label.Z_SOLD_TO_CONTACT_REQUIRED);	
			}
			
		}//end-for
		
		
    	
    }

	/* Default fields on quote */
    public static void initFields(List<zqu__Quote__c> quoteList) {

		Set<Id> oppIds = new Set<Id>();
		
		Map<Id, Opportunity> oppMap = new Map<Id, Opportunity> ();
		

    	for(zqu__Quote__c q : quoteList){

    		// get all opp ids
    		if (q.zqu__Opportunity__c != null){
    			oppIds.add(q.zqu__Opportunity__c);
    		}		
    		
    	}//end-for   
    	
    	
    	if(oppIds.size()>0){
    		
    		// get opp records
    		for(Opportunity opp : [Select o.Id, o.AccountId 
											From Opportunity o 
    											Where Id in: oppIds]){
    		
    			oppMap.put(opp.Id,opp);
    			
    		}//end-for	
    		
    	}//end-if



    	Opportunity currentOpp;
  
    	for(zqu__Quote__c q : quoteList){
    		
    		currentOpp=oppMap.get(q.zqu__Opportunity__c);
     
    		 
    		if(currentOpp!=null){
    		
    			q.Account__c = currentOpp.AccountId;	
			
    		}
 
    		
    	}//end-for   

    }

	/* Update Address fields on quote */
    public static void updateAddressFields(List<zqu__Quote__c> quoteList,
                                    Map<Id,zqu__Quote__c> oldQuoteMap) {
                                    	
		Set<Id> contactIds = new Set<Id> ();
		Map<Id, Contact> contactMap = new Map<Id, Contact>();
		
    	for(zqu__Quote__c q : quoteList){
 
 			if(q.zqu__SoldToContact__c!=null){
 				contactIds.add(q.zqu__SoldToContact__c);	
 			}
 			if(q.zqu__BillToContact__c!=null){
 				contactIds.add(q.zqu__BillToContact__c);	
 			} 
 			
    	}
 
    	if(contactIds.size()>0){
    		
    		for(Contact c: [Select c.Id, c.MailingStreet, c.MailingState, c.MailingPostalCode, c.MailingCountry, c.MailingCity 
    							From Contact c
    								Where Id in: contactIds]){
    									
    			contactMap.put(c.Id, c);
    				
    		}
    		
    	}					

		zqu__Quote__c oldQuote;
		Contact soldToContact;
		
    	for(zqu__Quote__c q : quoteList){
    		
    		oldQuote = oldQuoteMap.get(q.Id);
    		soldToContact = contactMap.get(q.zqu__SoldToContact__c);
    		
			if(soldToContact==null){
				continue;
			}
    			
    		// quote has been submitted for approval
    		if(q.Approval_Status__c == QUOTE_APPROVAL_STATUS_IN_REVIEW && q.Approval_Status__c != oldQuote.Approval_Status__c)	{
 
    				q.Sold_To_Street__c 	= soldToContact.MailingStreet;
    				q.Sold_To_City__c		= soldToContact.MailingCity;
    				q.Sold_To_State__c 		= soldToContact.MailingState;
    				q.Sold_To_Zip_Code__c	= soldToContact.MailingPostalCode;
    				q.Sold_To_Country__c	= soldToContact.MailingCountry;
 			}     		
    	}
		    	
    }
    
	/* Update fields on quote */
    public static void updateFields(List<zqu__Quote__c> quoteList) {
		
    	for(zqu__Quote__c q : quoteList){


	        if(q.zqu__SubscriptionType__c == SUBSCRIPTION_TYPE_NEW_SUBSCRIPTION){

	        	// calculate Renewal Date = Start Date + initial term
		        if(q.zqu__StartDate__c != null && q.zqu__InitialTerm__c != null){
		            q.Renewal_Date__c = q.zqu__StartDate__c.addMonths(Integer.valueOf(q.zqu__InitialTerm__c));
		        }
		        
	        } else if(q.zqu__SubscriptionType__c == SUBSCRIPTION_TYPE_AMEND_SUBSCRIPTION){
	        
	        	// calculate Renewal Date 
	        	q.Renewal_Date__c = q.zqu__SubscriptionTermEndDate__c;
	        	
	        	if(q.Change_Payment_Frequency__c
	        		|| q.Change_Contract_Term__c
	        		|| q.Change_License_Product__c
	        		|| q.Add_Premier_Support_Cloud_Connect__c){
	        			
			        if(q.zqu__StartDate__c != null && q.zqu__InitialTerm__c != null){
		            	q.Renewal_Date__c = q.zqu__StartDate__c.addMonths(Integer.valueOf(q.zqu__InitialTerm__c));
		        	}	
        		}	
	        
	        } else if(q.zqu__SubscriptionType__c == SUBSCRIPTION_TYPE_RENEW_SUBSCRIPTION){
	        
	        	// calculate Renewal Date 
	        	q.Renewal_Date__c = q.zqu__StartDate__c.addMonths(Integer.valueOf(q.zqu__InitialTerm__c));
	        	
	        }	
 
	        if(q.zqu__PaymentMethod__c == 'Check'
	            || q.zqu__PaymentMethod__c == 'ACH'
	            || q.zqu__PaymentMethod__c == 'Wire Transfer'){
	
	            q.zqu__BillingMethod__c='Email';
	        }

			if(q.zqu__StartDate__c!=null && q.zqu__InitialTerm__c!=null){
				q.End_Date__c = q.zqu__StartDate__c.addMonths(Integer.valueOf(q.zqu__InitialTerm__c));
			}else{
				q.End_Date__c = null;	
			}
			         
			if(q.deal_type__c == DEAL_TYPE_ELA){
				q.ELA__c = true;
			}else{
				q.ELA__c = false;
			}
	 
	 
	 
	 		// calculate # of months in the existing subscription term
	 		// moved code to NewQuoteController
	 		/*
	 		if(q.zqu__SubscriptionTermStartDate__c != null && q.zqu__SubscriptionTermEndDate__c != null){
	 			
	 			q.Subscription_Term__c = q.zqu__SubscriptionTermStartDate__c.monthsBetween( q.zqu__SubscriptionTermEndDate__c);
	 			
	 		}
	 		*/
	 		
	 
			// calculate contract term for use in Total Amount calculation
			
			// default initial term, which is used for New Subscription and Amend-New Subscription, and Renew-New Subscription
	        //q.Contract_Term_Calculation__c = q.zqu__InitialTerm__c;
	 		// moved code to NewQuoteController
	 		/*
	        if(!q.New_Box_Subscription__c){
	        	
				if(q.zqu__SubscriptionType__c == SUBSCRIPTION_TYPE_AMEND_SUBSCRIPTION){
				
					q.Contract_Term_Calculation__c = q.Subscription_Term__c;	
						
				}else if(q.zqu__SubscriptionType__c == SUBSCRIPTION_TYPE_RENEW_SUBSCRIPTION){
					
					q.Contract_Term_Calculation__c = q.zqu__RenewalTerm__c;
				
				}
	        }
	        */
 

    	}//end-for   
    	

    } 
           

    public static void updateRollupFields(List<zqu__Quote__c> quoteList) {
    	
    	Set<Id> quoteIds = new Set<Id>(); 
    	Map<Id, List<zqu__QuoteChargeSummary__c>> quoteChargeSummaryMap = new Map<Id, List<zqu__QuoteChargeSummary__c>> ();
 
    	// get quote Ids
    	
    	for(zqu__Quote__c q : quoteList){
    	
    		if(q.Id != null){  
    			quoteIds.add(q.Id);	
    		}	

    	}//end-for  
   
		if(quoteIds.size()>0){

			for(zqu__Quote__c q : [Select Id, zqu__SubscriptionType__c,  
											(Select Id, zqu__EffectivePrice__c, zqu__ListPrice__c, 
														zqu__ListTotal__c, zqu__MRR__c, NRR__c,
														MRR_New__c, NRR_New__c, Account_Type__c,
														zqu__Discount__c, zqu__Quantity__c,
														Product_Rate_Plan__c, zqu__TotalPrice__c, 
														Box_MRR__c, Product_ID__c, NRR_Short_Term__c,
														NRR_One_Time__c, Upsell_Quantity__c,
														Upsell_Discount__c, Upsell_Price__c, 
														Subscription_Price__c, Subscription_Quantity__c,  
														Subscription_MRR__c, NRR_Net__c, Box_MRR_Net__c, 
														Short_Term__c, Quote_Total_Price__c, Order_Amount__c             
													From Quote_Charge_Summarys__r) 
										From zqu__Quote__c z  where id in: quoteIds]){
											
				quoteChargeSummaryMap.put(q.Id, q.Quote_Charge_Summarys__r);	
											
			}
		}

    	
    	List<String> ratePlanGroupNames = new List<String>();
    	ratePlanGroupNames.add(RATE_PLAN_GROUP_BOX_CONSULTING); 
    	ratePlanGroupNames.add(RATE_PLAN_GROUP_BOX_ORG); 
    	Z_RatePlanGroup ratePlanGroups = new Z_RatePlanGroup(ratePlanGroupNames);


		List<String> productGroupNames = new List<String>();
		productGroupNames.add(PRODUCT_GROUP_BOX_VIEW_API);
		productGroupNames.add(PRODUCT_GROUP_BOX_CONTENT_API);  
		Z_ProductGroup productGroups = new Z_ProductGroup(productGroupNames);
		
		

    	Double nrr;
    	Double mrr;
    	
    	Double mrrNew;
    	Double nrrNew;
    	
    	Double mrrNet;
    	Double nrrNet;
    	 
    	Double quoteTotalPrice;
    	Double quoteTotalOrderAmount;
 
    	String accountType;
    	Integer seatsSold;
    	Double licenseDiscount;
    	Double effectivePrice;
    	Double boxConsulting;
    	
    	boolean containsBoxViewAPI;
    	boolean containsBoxContentAPI;
    	boolean containsBoxOrg;
    	
    	String quoteTerms;
    	
 
	    
 		List<zqu__QuoteChargeSummary__c> quoteChargeSummaryList;

			for(zqu__Quote__c q : quoteList){
				
				mrr=0;
				nrr=0;   
				
				mrrNew=0;
				nrrNew=0;
				
				mrrNet=0;
				nrrNet=0;
				
				quoteTotalPrice=0;
				quoteTotalOrderAmount=0;
				
				accountType=null;
				seatsSold=0;
				licenseDiscount=0;
				effectivePrice=0;
				boxConsulting=0;
      			containsBoxViewAPI=false;
    			containsBoxContentAPI=false;
    			containsBoxOrg=false;
    			quoteTerms='';
    			
				quoteChargeSummaryList = quoteChargeSummaryMap.get(q.Id);
 
				
				if(quoteChargeSummaryList != null && quoteChargeSummaryList.size()>0){
				
					for(zqu__QuoteChargeSummary__c qcs : quoteChargeSummaryList){
					
						System.debug('>>>>>>>>qcs='+qcs);
						
						if(qcs.Account_Type__c!=null){ 

							if(q.zqu__SubscriptionType__c==SUBSCRIPTION_TYPE_RENEW_SUBSCRIPTION){	

									accountType		= qcs.account_Type__c;
									licenseDiscount	= qcs.Upsell_Discount__c;
									effectivePrice	= qcs.Upsell_Price__c;

							}else{
								
								// get new license product info (not removed products)
								if(qcs.MRR_New__c > 0){
									
									accountType		= qcs.account_Type__c;
									licenseDiscount	= qcs.zqu__Discount__c;
									effectivePrice	= qcs.zqu__EffectivePrice__c;
								
								}else if(qcs.Short_Term__c && qcs.NRR_Short_Term__c > 0){
								
									// this is short term (not removed products)
									accountType		= qcs.account_Type__c;
									licenseDiscount	= qcs.zqu__Discount__c;
									effectivePrice	= qcs.zqu__EffectivePrice__c;
								}
							}	 
 
							
							if(q.zqu__SubscriptionType__c==SUBSCRIPTION_TYPE_RENEW_SUBSCRIPTION){	
															
								seatsSold = seatsSold + Integer.valueOf(qcs.Upsell_Quantity__c);	
							
							}else{	
															 
								seatsSold = seatsSold + Integer.valueOf(qcs.zqu__Quantity__c);
							
							}
							
						}//end-if account type != null						
						

						if(ratePlanGroups.containsRatePlan(RATE_PLAN_GROUP_BOX_CONSULTING,qcs.Product_Rate_Plan__c)){
							boxConsulting = boxConsulting + qcs.zqu__TotalPrice__c;
						}


						if(qcs.Box_MRR__c!=null){
							mrr = mrr + qcs.Box_MRR__c;
						}
						
						if(qcs.MRR_New__c!=null){
							mrrNew = mrrNew + qcs.MRR_New__c;
						}

						if(qcs.Box_MRR_Net__c!=null){
							mrrNet = mrrNet + qcs.Box_MRR_Net__c;
						}
				
						if(qcs.NRR__c!=null){
							nrr = nrr + qcs.NRR__c;
						}

						
						if(qcs.NRR_New__c!=null){
							nrrNew = nrrNew + qcs.NRR_New__c;	
						}	

						if(qcs.NRR_Net__c!=null){
							nrrNet = nrrNet + qcs.NRR_Net__c;	
						}	


						if(qcs.Quote_Total_Price__c!=null && qcs.Quote_Total_Price__c >0){
							// Sum only Positive Numbers
							quoteTotalPrice = quoteTotalPrice + qcs.Quote_Total_Price__c;	
						}	
			
						if(qcs.Order_Amount__c!=null){
							quoteTotalOrderAmount = quoteTotalOrderAmount + qcs.Order_Amount__c;	
						}	
		
						// is there Box View API
						if(productGroups.containsProduct(PRODUCT_GROUP_BOX_VIEW_API, qcs.Product_ID__c)){
							containsBoxViewAPI=true;		
						}
						
						
						// is there Box Content API
						if(productGroups.containsProduct(PRODUCT_GROUP_BOX_CONTENT_API, qcs.Product_ID__c)){
							containsBoxContentAPI=true;		
						}
						
						// is there Box.org
						if(ratePlanGroups.containsRatePlan(RATE_PLAN_GROUP_BOX_ORG, qcs.Product_Rate_Plan__c)){
							containsBoxOrg=true;
						}
									
					}//end-for qcs
					
				}	
				
				/* populate quote fields */

				if (q.Box_MRR__c != mrr){
					q.Box_MRR__c=mrr;
 
				}				
				
				if (q.NRR__c != nrr){
					q.NRR__c=nrr;
 
				}
				   
				if (q.MRR_New__c != mrrNew){
					q.MRR_New__c=mrrNew;
 
				}
	
 				if (q.Box_MRR_Net__c != mrrNet){
					q.Box_MRR_Net__c=mrrNet;
 
				}
				   
				if (q.Box_NRR_Net__c != nrrNet){
					q.Box_NRR_Net__c=nrrNet;
				}
				
				if (q.NRR_New__c != nrrNew){
					q.NRR_New__c=nrrNew;
				}
				
				if (q.Quote_Total_Price__c != quoteTotalPrice){
					q.Quote_Total_Price__c=quoteTotalPrice;
				}				
				
				if (q.Quote_Total_Order_Amount__c != quoteTotalOrderAmount){
					q.Quote_Total_Order_Amount__c=quoteTotalOrderAmount;
				}		
				
				
				if (q.account_type_sold__c != accountType){
					q.account_type_sold__c=accountType;
 
				}
				if (q.license_discount__c != licenseDiscount){
					q.license_discount__c=licenseDiscount;
 
				}
				if (q.Seats_Sold__c != seatsSold){
					q.Seats_Sold__c=seatsSold;
		 
				}				
				if (q.Effective_Price__c != effectivePrice){
					q.Effective_Price__c=effectivePrice;
 
				}
				if (q.Box_Consulting__c != boxConsulting){
					q.Box_Consulting__c=boxConsulting;
 
				}

				if (q.Box_View_API__c != containsBoxViewAPI){
					q.Box_View_API__c=containsBoxViewAPI;
				}

				if (q.Box_Content_API__c != containsBoxContentAPI){
					q.Box_Content_API__c=containsBoxContentAPI;
				}

				if (q.Box_org__c != containsBoxOrg){
					q.Box_org__c=containsBoxOrg;
				}
				
 
				if(q.Box_Org__c){
					quoteTerms = quoteTerms + Label.Z_TERMS_BOX_ORG;
				}
 

				//update quote terms
				if(q.quote_terms__c != quoteTerms){
					q.quote_terms__c = quoteTerms;
				}
				
 				q.Discount__c  = q.License_Discount__c;


			}//end-for
 
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
}