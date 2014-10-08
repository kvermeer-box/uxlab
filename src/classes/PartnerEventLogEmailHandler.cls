global class PartnerEventLogEmailHandler  implements Messaging.InboundEmailHandler{




	 /**
	  * Entry Point for incoming email - this code is executed when e-mail is recieved.
	  **/
  	global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,
                                Messaging.InboundEnvelope env) {
                             
        // Grab email body
	    String email_text= email.plainTextBody;
	    System.Debug('email text' + email_text);
	   	Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
	   	
	   	// Deserialize
		Partner_Event_Log__c partnerEventLog = new Partner_Event_Log__c();
		Box_PartnerEventLog pLog;
		JSONParser parser = JSON.createParser(email_text);
		try {
			pLog = (Box_PartnerEventLog)parser.readValueAs(Box_PartnerEventLog.class);
		} catch (Exception e) {
			result.message = 'Failed to create partner event log from email body.\n';
		    result.success = false;
		    return result;
		}

		partnerEventLog = PartnerEventLog_REST.insertPartnerEventLog(pLog, partnerEventLog);   	
	    return result;
	}
                                
}