public class Z_QuoteValidationUtility {

	public static final String COUNTRY_UNITED_STATES		= 'United States';
	public static final String PAYMENT_METHOD_CHECK 		= 'Check';
	public static final String PAYMENT_METHOD_ACH 			= 'ACH';
	public static final String PAYMENT_METHOD_WIRE_TRANSFER = 'Wire Transfer';

 	public static String SUBSCRIPTION_TYPE_NEW_SUBSCRIPTION 	= 'New Subscription';
 	public static String SUBSCRIPTION_TYPE_RENEW_SUBSCRIPTION 	= 'Renew Subscription';
 	public static String SUBSCRIPTION_TYPE_AMEND_SUBSCRIPTION 	= 'Amend Subscription';

 	public static String DEAL_TYPE_ELA 							= 'ELA';	

 	public static integer ELA_SEATS_THRESHOLD 					= 250;

 	public static final String CUSTOM_SETTING_CHECK_WIRE_MINIMUM = 'Check Wire Minimum ';
 
 	public static final String CURRENCY_CODE_USD 				= 'USD';

	 
		
	public static List <ApexPages.Message> validateQuote(Id quoteId){
	
		List <ApexPages.Message> messageList = new List <ApexPages.Message>();
		
		zqu__Quote__c quote = getQuote(quoteId);
		
		if(quote==null){
			return messageList;
		}

		// allow sales ops and sys admins to manually approve a quote
		if(quote.approved__c){
			return messageList;
		}
 
		decimal	nonRecurringAmount=quote.NRR__c;
		decimal	recurringAmount=quote.Recurring_Payment__c;	

		if(nonRecurringAmount==null){
			nonRecurringAmount=0;
		}
		if(recurringAmount==null){
			recurringAmount=0;
		}
		
		//addInfoMessage(messageList, 'nonRecurringAmount='+ nonRecurringAmount); 
		//addInfoMessage(messageList, 'recurringAmount='+ recurringAmount); 


		// Get check/wire minimum thresholds
 
		System.debug('>>>>>>>>currencyCode='+quote.zqu__Currency__c);
		//addInfoMessage(messageList, 'currencyCode='+ quote.zqu__Currency__c); 
				
		Amount_Threshold__c customSettingThreshold = Amount_Threshold__c.getInstance(CUSTOM_SETTING_CHECK_WIRE_MINIMUM + quote.zqu__Currency__c);

		Decimal checkWireMinimumThreshold = 1000;

		if(customSettingThreshold != null && customSettingThreshold.Threshold_Amount__c > 0){
			checkWireMinimumThreshold = customSettingThreshold.Threshold_Amount__c;
		}	

		//addInfoMessage(messageList, 'checkWireMinimumThreshold='+ checkWireMinimumThreshold); 
		System.debug('>>>>>>>>checkWireMinimumThreshold='+checkWireMinimumThreshold);
		
		if(quote.zqu__SubscriptionType__c.equals(SUBSCRIPTION_TYPE_NEW_SUBSCRIPTION)){
		
			/* No checks under 1000.  */
			/* Payment must be over 1000 if paying by check */

			if(PAYMENT_METHOD_CHECK.equals(quote.zqu__PaymentMethod__c)
					|| PAYMENT_METHOD_ACH.equals(quote.zqu__PaymentMethod__c)
					|| PAYMENT_METHOD_WIRE_TRANSFER.equals(quote.zqu__PaymentMethod__c)){

				
				if(nonRecurringAmount < checkWireMinimumThreshold && recurringAmount == 0){
				
					messageList.add(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Z_CHECK_WIRE_PAYMENT_TOTAL_ERROR + ' Total amount must be more than ' + integer.valueOf(checkWireMinimumThreshold) + '.'));	
					
				}else if(recurringAmount < checkWireMinimumThreshold && recurringAmount > 0){   
					
					messageList.add(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Z_CHECK_WIRE_PAYMENT_RECURRING_ERROR + ' Recurring amount must be more than ' + integer.valueOf(checkWireMinimumThreshold) + '.'));		
					
				}//end-if		
				
			}
			
			/* verify ELA */
 
			if(quote.deal_type__c == DEAL_TYPE_ELA){
				
				if(quote.Enterprise_wide_Deployment__c == false 
					|| quote.Seats_Sold__c < ELA_SEATS_THRESHOLD
					|| quote.zqu__InitialTerm__c < 24){
				
					messageList.add(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Z_ELA_ERROR));	
				}	
			}
			
		
		}else if (quote.zqu__SubscriptionType__c == SUBSCRIPTION_TYPE_AMEND_SUBSCRIPTION) {
			
			// 2 scenarios

			/* No checks under 1000.  */
			/* Payment must be over 1000 if paying by check */

			if(PAYMENT_METHOD_CHECK.equals(quote.zqu__PaymentMethod__c)
					|| PAYMENT_METHOD_ACH.equals(quote.zqu__PaymentMethod__c)
					|| PAYMENT_METHOD_WIRE_TRANSFER.equals(quote.zqu__PaymentMethod__c)){

	 			if(quote.New_Box_Subscription__c){
				// new subscription - amounts are full amounts

					if(recurringAmount < checkWireMinimumThreshold && recurringAmount > 0){   
						
						messageList.add(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Z_CHECK_WIRE_PAYMENT_RECURRING_ERROR + ' Recurring amount must be more than ' + integer.valueOf(checkWireMinimumThreshold) + '.'));		
						
					}//end-if	
						
 
	 			}else{
	 			// upsell - amounts are net new amounts
 
 					double subscriptionExtendedAmount=0;
 					if( quote.Subscription_Extended_Amount__c!=null){
 						subscriptionExtendedAmount = quote.Subscription_Extended_Amount__c;	
 					}
 
					recurringAmount = recurringAmount + subscriptionExtendedAmount;	

					//addInfoMessage(messageList, 'Amend with same product: recurringAmount='+ recurringAmount);
	 				
					if(recurringAmount < checkWireMinimumThreshold && recurringAmount > 0){   
						
						messageList.add(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Z_CHECK_WIRE_PAYMENT_RECURRING_ERROR + ' Recurring amount must be more than ' + integer.valueOf(checkWireMinimumThreshold) + '.'));		
						
					}//end-if	
	 			}
			}
			
		}else if (quote.zqu__SubscriptionType__c == SUBSCRIPTION_TYPE_RENEW_SUBSCRIPTION) {
			
			/* No checks under 1000.  */
			/* Payment must be over 1000 if paying by check */

			if(PAYMENT_METHOD_CHECK.equals(quote.zqu__PaymentMethod__c)
					|| PAYMENT_METHOD_ACH.equals(quote.zqu__PaymentMethod__c)
					|| PAYMENT_METHOD_WIRE_TRANSFER.equals(quote.zqu__PaymentMethod__c)){

				
				if(recurringAmount < checkWireMinimumThreshold && recurringAmount > 0){  
					
					messageList.add(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Z_CHECK_WIRE_PAYMENT_RECURRING_ERROR + ' Recurring amount must be more than ' + integer.valueOf(checkWireMinimumThreshold) + '.'));		
					
				}//end-if		
				
			}
		}
		 
		// Verify quote currency matches opportunity currency
		if (quote.zqu__Opportunity__r.CurrencyIsoCode != quote.zqu__Currency__c) {
				messageList.add(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Z_QUOTE_OPPORTUNITY_CURRENCY_MISMATCH));
		}

		// Verify quote name length
		if (quote.name.length()>76) {
				messageList.add(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Z_QUOTE_NAME_LENGTH_ERROR));
		}

		// Payment Frequency Required
		if(quote.Payment_Frequency__c==null){
			messageList.add(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Z_PAYMENT_FREQUENCY_REQUIRED));	
		}

		// Payment Method Required
		if(quote.zqu__PaymentMethod__c==null){
			messageList.add(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Z_PAYMENT_METHOD_REQUIRED));	
		}
		
		// Payment Term Required
		if(quote.zqu__PaymentTerm__c==null){
			messageList.add(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Z_PAYMENT_TERM_REQUIRED));	
		}		


		// Bill To Email Required
		if(quote.zqu__BillToContact__r.Email==null){
			messageList.add(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Z_BILL_TO_CONTACT_EMAIL_REQUIRED));	
		}
		
		// Sold To Email Required
		if(quote.zqu__SoldToContact__r.Email==null){
			messageList.add(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Z_SOLD_TO_CONTACT_EMAIL_REQUIRED));	
		}		

		// Bill To Address Required
		
		if(quote.zqu__BillToContact__r.MailingStreet==null 
			&& quote.zqu__BillToContact__r.MailingCity==null
			&& quote.zqu__BillToContact__r.MailingCountry==null){
			messageList.add(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Z_BILL_TO_ADDRESS_REQUIRED));	
		}else{
		
			if(quote.zqu__BillToContact__r.MailingStreet==null){
				messageList.add(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Z_BILL_TO_STREET_REQUIRED));	
			}
			if(quote.zqu__BillToContact__r.MailingCity==null){
				messageList.add(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Z_BILL_TO_CITY_REQUIRED));	
			}
			if(quote.zqu__BillToContact__r.MailingCountry==null){
				messageList.add(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Z_BILL_TO_COUNTRY_REQUIRED));	
			}	
		}	
		
		// Sold To Address Required
		if(quote.zqu__SoldToContact__r.MailingStreet==null 
			&& quote.zqu__SoldToContact__r.MailingCity==null
			&& quote.zqu__SoldToContact__r.MailingCountry==null){
			messageList.add(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Z_SOLD_TO_ADDRESS_REQUIRED));	
		}else{
		
			if(quote.zqu__SoldToContact__r.MailingStreet==null){
				messageList.add(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Z_SOLD_TO_STREET_REQUIRED));	
			}
			if(quote.zqu__SoldToContact__r.MailingCity==null){
				messageList.add(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Z_SOLD_TO_CITY_REQUIRED));	
			}
			if(quote.zqu__SoldToContact__r.MailingCountry==null){
				messageList.add(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Z_SOLD_TO_COUNTRY_REQUIRED));	
			}
		}

		// US Bill To Address requires zip code and state
		if(quote.zqu__BillToContact__r.MailingCountry==COUNTRY_UNITED_STATES 
			&& (quote.zqu__BillToContact__r.MailingPostalCode==null || quote.zqu__BillToContact__r.MailingState==null)){
			messageList.add(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Z_BILL_TO_ZIP_CODE_STATE_REQUIRED));	
		}

		// US Sold To Address requires zip code and state
		if(quote.zqu__SoldToContact__r.MailingCountry==COUNTRY_UNITED_STATES 
			&& (quote.zqu__SoldToContact__r.MailingPostalCode==null || quote.zqu__SoldToContact__r.MailingState==null)){
			messageList.add(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Z_BILL_TO_ZIP_CODE_STATE_REQUIRED));	
		}
		
		// PO Box is not allowed for Sold To US Addresses
		if (quote.zqu__SoldToContact__r.MailingCountry == COUNTRY_UNITED_STATES) {
			if (LocationUtils_hlpr.isPOBox(quote.zqu__SoldToContact__r.MailingStreet)) {
				messageList.add(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Z_NO_PO_BOX));
			}
		}   
		
		// application name and overage fee rqeuired for View API
		if(quote.Box_View_API__c ){
			
			if(quote.Application_Name__c==null){
				messageList.add(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Z_APPLICATION_NAME_REQUIRED));	
			}
			if(quote.Overage_Fee__c==null){
				messageList.add(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Z_OVERAGE_FEE_REQUIRED));	
			}
		}
		
		 
		
		return messageList;
	
	}

	/* use quote id to return a quote */
	//public static void addInfoMessage(List <ApexPages.Message> messageList, String message){
	//	messageList.add(new ApexPages.Message(ApexPages.Severity.INFO, message));   	
	//}
	
	
	/* use quote id to return a quote */
	public static zqu__Quote__c getQuote(Id quoteId){
	
		if(quoteId==null){		
			return null;	
		}
		
		for(zqu__Quote__c q : [Select z.Payment_Frequency__c, z.Id, ARR__c,
										z.Name, 
										zqu__PaymentMethod__c, 
										zqu__SubscriptionType__c, Recurring_Payment__c,
										z.zqu__SoldToContact__r.Email, z.zqu__SoldToContact__c, 
										z.zqu__BillToContact__r.Email, z.zqu__BillToContact__c,
										z.Billing_Street__c, z.Billing_Country__c, 
										z.zqu__BillToContact__r.MailingCountry, 
										z.zqu__BillToContact__r.MailingPostalCode, 
										z.zqu__BillToContact__r.MailingState, 
										z.zqu__BillToContact__r.MailingCity, 
										z.zqu__BillToContact__r.MailingStreet, 
										z.zqu__SoldToContact__r.MailingCountry, 
										z.zqu__SoldToContact__r.MailingPostalCode, 
										z.zqu__SoldToContact__r.MailingState, 
										z.zqu__SoldToContact__r.MailingCity, 
										z.zqu__SoldToContact__r.MailingStreet,
										z.zqu__Currency__c, z.zqu__PaymentTerm__c,
										z.zqu__Opportunity__r.CurrencyIsoCode, 
										z.zqu__Opportunity__c, z.Approved__c,
										z.Box_View_API__c, z.Box_Content_API__c,  
										z.Application_Name__c, z.Overage_Fee__c,
										z.deal_type__c, z.Enterprise_wide_Deployment__c,
										z.Seats_Sold__c, zqu__InitialTerm__c, 
										z.NRR__c, z.New_Box_Subscription__c,
										z.Subscription_Extended_Amount__c  
									From zqu__Quote__c z 
										Where z.Id =: quoteId]){
			
			return q;		
			
		}//end-for
		 
		return null;
			
	}
}