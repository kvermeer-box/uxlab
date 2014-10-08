global with sharing class Box_UserPartnerKeyDAO {

	public static Map<String, String> getParamKeys() {
        Map<String, String> paramKeyMap = new Map<String, String>();
        paramKeyMap = new Map<String, String>();
        paramKeyMap.put('externalcontactid', 'Key__c');
        paramKeyMap.put('external_contact_id', 'Key__c');
        paramKeyMap.put('contact_id', 'Contact__r.Id');
        paramKeyMap.put('partner_id', 'Partner__r.Id');
        return paramKeyMap; 
    } 
    
    public static String getQuery() {
        System.debug('Box_UserPartnerKeyDAO: Getting the base SOQL query for partner keys...');
        
        String q = ' SELECT Id,' 
                 + '        Contact__r.Id, '
                 + '        Partner__r.Id, '    
                 + '        Key__c '
                 + '    FROM Partner_Key_Contact__c ';               

        System.debug('Box_UserPartnerKeyDAO: Query: ' + q);
        return q;
    } 
    
    public static Partner_Key_Contact__c getPartnerKeyFromKey(String key, String value) {
        System.debug('Box_UserPartnerKeyDAO: Querying partner key by key...');      
        
        Partner_Key_Contact__c pk;
        if (key != null && value != null && !key.equals('') && !value.equals('')) {
            // Build query
            System.debug('Box_UserPartnerKeyDAO: Looking for ' + value + ' on the partner key ' + key + ' field...');
            String q = getQuery() + ' '
                     + ' WHERE ' + key + ' = \'' + value + '\' ';
            System.debug('Box_UserPartnerKeyDAO: Final query: ' + q);           
                     
            // Execute query         
            List<Partner_Key_Contact__c> pks = (List<Partner_Key_Contact__c>)Database.query(q);
            pk = parseSinglePartnerKey(pks, true); 
        } else {            
            throw new CustomException('Error: invalid parameters.');
        }       
        return pk;
    }

	private static Partner_Key_Contact__c parseSinglePartnerKey(List<Partner_Key_Contact__c> pks, boolean rejectMultiple) {
		Partner_Key_Contact__c pk;
		if (pks == null || pks.size() == 0) {
            throw new CustomException('Error: no partner key found.');
        } else if (pks.size() > 1 && rejectMultiple) {
            throw new Box_DuplicateRecordException(pks, 'Error: multiple partner keys found.');
        } else {                
            pk = pks[0];
            System.debug('Box_UserPartnerKeyDAO: Partner key found: ' + pk);
        }       
        return pk;
	}

    public static Partner_Key_Contact__c findPartnerKeyFromSalesTransaction(Box_SalesTransaction salesTransaction) {
        System.debug('Box_UserPartnerKeyDAO: Finding partner key from sales transaction...');           
        
        // Make sure we have all inputs
        if (salesTransaction == null) {
            throw new CustomException('Error: Cannot partner key from null sales transaction.');
        } 
        
        // Get variables ready
        Partner_Key_Contact__c pk;      
        
        // Validate inputs
        if (salesTransaction == null || salesTransaction.external_contact_id == null || salesTransaction.external_contact_id.equals('')) {
            throw new CustomException('Error: Cannot find a partner key. External contact id is null.');
        } 
        
        // Attempt to find partner key
        try {
            pk = getPartnerKeyFromKey(getParamKeys().get('externalcontactid'), salesTransaction.external_contact_id);   
        } catch (Box_DuplicateRecordException d) {
            throw new CustomException('Error: Mulitple partner keys found with id ' + salesTransaction.external_contact_id);
        } catch (Exception e) {
            throw new CustomException('Error: No partner key found with id ' + salesTransaction.external_contact_id);
        }
        
        return pk;  
    }
    
    public static String getContactIdFromPartnerKey(String key) {
        System.debug('Box_UserPartnerKeyDAO: Getting the contact id from a partner key...');
        
        String contactId;
        Partner_Key_Contact__c pk = getPartnerKeyFromKey(getParamKeys().get('externalcontactid'), key);
        if (pk != null && pk.Contact__r.Id != null) {
            contactId = pk.Contact__r.Id;
            System.debug('Box_UserPartnerKeyDAO: Contact id found: ' + contactId);
        }
        
        return contactId;
    }
    
    public static String getPartnerKeyFromContactIdAndRunningUser(String contactId) {
    	System.debug('Box_UserPartnerKeyDAO: Getting the partner key from the contact id...');
    	
    	System.debug('Box_UserPartnerKeyDAO: Building special query...');
    	String q = getQuery() + ' '
                 + ' WHERE ' + getParamKeys().get('contact_id') + ' = \'' + contactId + '\' ' 
                 + ' 	AND ' + getParamKeys().get('partner_id') + ' = \'' + Box_AccountDAO.findPartnerFromRunningUser().Id + '\' ';
        System.debug('Box_UserPartnerKeyDAO: Final query: ' + q);           
                 
        // Execute query         
        List<Partner_Key_Contact__c> pks = (List<Partner_Key_Contact__c>)Database.query(q);
        Partner_Key_Contact__c pk = parseSinglePartnerKey(pks, false);
        System.debug('Box_UserPartnerKeyDAO: Partner key found: ' + pk.Key__c);        
        
    	return pk.Key__c;
    }
    
    public static void findAndUpdatePartnerKey(String oldKey, String newKey) {    	
    	System.debug('Box_UserPartnerKeyDAO: Finding and updating partner key...');
    	 
    	if (oldKey != null && newKey != null) {    		
    		// First, try to find the key
    		Partner_Key_Contact__c key;	    				    			    	
	    	try {
	    		key = getPartnerKeyFromKey(getParamKeys().get('external_contact_id'), oldKey);		    		
	    	} catch (Box_DuplicateRecordException d) {
	    		throw d;
	    	} catch (Exception e) {
	    		throw new NoDataFoundException();
	    	}
	    	
	    	// Now try updating the key
			key.Key__c = newKey;
			update key;
			System.debug('Box_UserPartnerKeyDAO: Partner key successfully updated to ' + newKey);
    	}    	
    }
    	
}