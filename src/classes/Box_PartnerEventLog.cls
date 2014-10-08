global class Box_PartnerEventLog {
		
		//Object values
		public String customer_account_name;
		public String[] customer_emails;
		public Operation[] operations;
		public PartnerCustomerField[] partner_customer_fields;
		public String partner_customer_id;
		public String partner_transaction_id;
		public String partner_transaction_timestamp;
		public String event_code;
		public String event_status; //event_type
		public String event_message;
		public String event_description;
		public String partner_name;
		public PartnerRepField[] partner_reps;

		private Map<String, String> partnerCustomerFieldMap = new Map<String, String>();
   		
        public Box_PartnerEventLog() {
        	/*
            if (json_request == null) return;
            JSONParser parser = JSON.createParser(json_request);
        
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String field_name = parser.getText();
                    parser.nextToken();
                    System.debug('Current Token: ' + parser.getCurrentToken());
                    if (parser.getCurrentToken() == JSONToken.VALUE_NULL) continue;
                    System.debug('Text: ' + parser.getText());
                    if (field_name == CUSTOMER_ACCOUNT_NAME)
                        this.customerAccountName = parser.getText();
                    else if (field_name == CUSTOMER_EMAILS)
                        //this.customerEmails = parser.getText(); //list of emails from JSON
                    else
                        System.debug('Unknown Field Provided: ' +field_name);
                }
            }
            */
        }
        
        public class Operation {
        	public String action;
        	public String seat_count;
        	public String account_type;
        	
        	public Operation(String act, String seat, String acct) {
        		this.action = act;
        		this.seat_count = seat;
        		this.account_type = acct;
        	}
        }
        
        public class PartnerCustomerField {
        	public String name;
        	public String value;
        	
        	public PartnerCustomerField(String t, String v) {
        		this.name = t;
        		this.value = v;
        	}
        }
        
        public class PartnerRepField {
        	public String id;
        	public String email;
        	
        	public PartnerRepField(String i, String e) {
        		this.id = i;
        		this.email = e;
        	}
        }
        
        // Returns string of all customer emails, delimited by ';'
        public String getCustomerEmailsList() {
        	String returnList = '';
        	if (customer_emails == null) {
        		return returnList;
        	}
        	for (Integer i = 0; i < customer_emails.size(); i++) {
        		returnList = returnList + customer_emails.get(i);
        		if (i != customer_emails.size() - 1) {
        			returnList = returnList + '; ';
        		}
        	}
        	return returnList;
        }
        
        // construct map of key-value pairs for partner_customer_key_1, etc.
        // eg. for AT&T: partner_customer_key_1__c -> "BAN" -> "823956930"
        public void constructPartnerCustomerFieldMap() {
        	partnerCustomerFieldMap = new Map<String, String>();
        	for (Integer i = 0; i < partner_customer_fields.size(); i++) {
        		PartnerCustomerField field = partner_customer_fields.get(i);
        		if (field == null) {
        			continue;
        		}
        		partnerCustomerFieldMap.put(field.name, field.value);
        	}
        }
        
        public String getPartnerKey1() {
        	//TODO: add partner name, ie. 'AT&T' to key to map
        	return partnerCustomerFieldMap.get('BAN');
        }
        
        public String getPartnerKey2() {
        	return partnerCustomerFieldMap.get('CTN');
        }
        
        public String getPartnerKey3() {
        	return partnerCustomerFieldMap.get('FAN');
        }
        
        // todo: change getResellerID() and getPartnerName() to base off partner token
        // reseller ID for AT&T is 553 in production, 1525 in ATT sandbox
        public String getResellerID() {
        	return Label.ATT_Reseller_ID;
        }
        
        public String getPartnerName() {
        	if (partner_name != null) {
        		return partner_name;
        	}
        	return 'AT&T'; 
        }
        
        // Returns string of all operations
        public String getOperationsList() {
        	String returnList = '';
        	if (operations == null) {
        		return returnList;
        	}
        	for (Integer i = 0; i < operations.size(); i++) {
        		Operation oper = operations.get(i);
        		if (oper == null) {
        			continue;
        		}
        		returnList = returnList + oper.action + ' ' + oper.seat_count + ' ' + oper.account_type + '\r\n';
        	}
        	return returnList;
        }
        
        // Return string of partner rep info
        public String getPartnerRepsInfo() {
        	String returnList = '';
        	if (partner_reps == null) {
        		return returnList;
        	}
			for (Integer i = 0; i < partner_reps.size(); i++) {
				PartnerRepField partnerRep = partner_reps.get(i);
				if (partnerRep == null) {
					continue;
				}
				returnList = returnList + partnerRep.id + ' ' + partnerRep.email + '\r\n';
			}        	
			return returnList;
        }
        
        //ATT returns date in format: 04/15/2014 10:36:09-05:00
        //First, parse this to create ISO8601 formatted timestamp
        //Second, deserialize the ISO8601 string into apex datetime   
        //TODO: breakout condition for later partners that may have different formats
        public Datetime getPartnerTransactionDatetime() {
        	String t = partner_transaction_timestamp;
        	if (t == null) {
        		return null;
        	} 
        	//split into 2 strings: index0 is date, index1 is time
        	String[] strs = t.split(' ');
        	if (strs.size() < 2) {
        		return null;
        	}
        	Date d;
        	try {
				d = Date.parse(strs[0]);
			} catch (Exception e) {
				return null;
			} 	
        	Integer month = d.month();
        	Integer day = d.day();
        	String timeStr = strs[1];
        	
			String iso8601Formatted = String.valueOf(d.year()) + '-' +
									  ((month >= 10) ? String.valueOf(month) : '0' + String.valueOf(month)) + '-' +
									  ((day >= 10) ? String.valueOf(day) : '0' + String.valueOf(day)) + 'T' +
									  timeStr;
			
			Datetime dt;
			try {
				dt = (Datetime)JSON.deserialize('"' + iso8601Formatted + '"', Datetime.class);
			} catch (Exception e) {
				dt = null;
			} 	
        	return dt;
        }
        
        /*
		Convert "06/09/2014 10:13:17-07:00" to
	     	    "1999-01-01T23:01:01-08:00"
		List<String> strings = s.split(' ');
		if (strings.length > 1) {
			String s1 = strings[0];
			String s2 = strings[1];
			Date d = Date.parse(s1);
			return d.format() + 'T' + s2;
		} else {
			return s;
		}
		*/
		
}