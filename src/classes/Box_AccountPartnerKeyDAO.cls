global with sharing class Box_AccountPartnerKeyDAO {
    
    public static Map<String, String> getParamKeys() {
        Map<String, String> paramKeyMap = new Map<String, String>();
        paramKeyMap = new Map<String, String>();
        paramKeyMap.put('externalaccountid', 'Key__c');
        paramKeyMap.put('external_account_id', 'Key__c');
        paramKeyMap.put('account_id', 'Account__r.Id');
        paramKeyMap.put('partner_id', 'Partner__r.Id');
        return paramKeyMap; 
    } 
    
    public static String getQuery() {
        System.debug('Box_AccountPartnerKeyDAO: Getting the base SOQL query for partner keys...');
        
        String q = ' SELECT Id,' 
                 + '        Account__r.Id, '
                 + '        Partner__r.Id, '    
                 + '        Key__c '
                 + '    FROM Partner_Key_Account__c ';               

        System.debug('Box_AccountPartnerKeyDAO: Query: ' + q);
        return q;
    } 
    
    public static Partner_Key_Account__c getPartnerKeyFromKey(String key, String value) {
        System.debug('Box_AccountPartnerKeyDAO: Querying partner key by key...');      
        
        Partner_Key_Account__c pk;
        if (key != null && value != null && !key.equals('') && !value.equals('')) {
            // Build query
            System.debug('Box_AccountPartnerKeyDAO: Looking for ' + value + ' on the partner key ' + key + ' field...');
            String q = getQuery() + ' '
                     + ' WHERE ' + key + ' = \'' + value + '\' ';
            System.debug('Box_AccountPartnerKeyDAO: Final query: ' + q);           
                     
            // Execute query         
            List<Partner_Key_Account__c> pks = (List<Partner_Key_Account__c>)Database.query(q);
            pk = parseSinglePartnerKey(pks, true); 
        } else {            
            throw new CustomException('Error: invalid parameters.');
        }       
        return pk;
    }

	private static Partner_Key_Account__c parseSinglePartnerKey(List<Partner_Key_Account__c> pks, boolean rejectMultiple) {
		Partner_Key_Account__c pk;
		if (pks == null || pks.size() == 0) {
            throw new CustomException('Error: no partner key found.');
        } else if (pks.size() > 1 && rejectMultiple) {
            throw new Box_DuplicateRecordException(pks, 'Error: multiple partner keys found.');
        } else {                
            pk = pks[0];
            System.debug('Box_AccountPartnerKeyDAO: Partner key found: ' + pk);
        }       
        return pk;
	}

    public static Partner_Key_Account__c findPartnerKeyFromSalesTransaction(Box_SalesTransaction salesTransaction) {
        System.debug('Box_AccountPartnerKeyDAO: Finding partner key from sales transaction...');           
        
        // Make sure we have all inputs
        if (salesTransaction == null) {
            throw new CustomException('Error: Cannot partner key from null sales transaction.');
        } 
        
        // Get variables ready
        Partner_Key_Account__c pk;      
        
        // Validate inputs
        if (salesTransaction == null || salesTransaction.external_account_id == null || salesTransaction.external_account_id.equals('')) {
            throw new CustomException('Error: Cannot find a partner key. External account id is null.');
        } 
        
        // Attempt to find partner key
        try {
            pk = getPartnerKeyFromKey(getParamKeys().get('externalaccountid'), salesTransaction.external_account_id);   
        } catch (Box_DuplicateRecordException d) {
            throw new CustomException('Error: Mulitple partner keys found with id ' + salesTransaction.external_account_id);
        } catch (Exception e) {
            throw new CustomException('Error: No partner key found with id ' + salesTransaction.external_account_id);
        }
        
        return pk;  
    }
    
    public static String getAccountIdFromPartnerKey(String key) {
        System.debug('Box_AccountPartnerKeyDAO: Getting the account id from a partner key...');
        
        String accountId;
        Partner_Key_Account__c pk;
        try {
        	pk = getPartnerKeyFromKey(getParamKeys().get('externalaccountid'), key);
        } catch (Exception e) {
        	System.debug('Box_AccountPartnerKeyDAO: Account could not be found.');
        	throw new CustomException('Error: Could not find account from external account id: ' + key);
        }	
        	
        if (pk != null && pk.Account__r.Id != null) {
            accountId = pk.Account__r.Id;
            System.debug('Box_AccountPartnerKeyDAO: Account id found: ' + accountId);
        }
        
        return accountId;
    }
    
    public static String getPartnerKeyFromAccountIdAndRunningUser(String accountId) {
    	System.debug('Box_AccountPartnerKeyDAO: Getting the partner key from the account id...');
    	
    	String key;
    	try {
    		System.debug('Box_AccountPartnerKeyDAO: Building special query...');
	    	String q = getQuery() + ' '
	                 + ' WHERE ' + getParamKeys().get('account_id') + ' = \'' + accountId + '\' '
	                 + ' 	AND ' + getParamKeys().get('partner_id') + ' = \'' + Box_AccountDAO.findPartnerFromRunningUser().Id + '\' ';
	        System.debug('Box_AccountPartnerKeyDAO: Final query: ' + q);           
	                 
	        // Execute query         
	        List<Partner_Key_Account__c> pks = (List<Partner_Key_Account__c>)Database.query(q);
	        Partner_Key_Account__c pk = parseSinglePartnerKey(pks, false);
	        key = pk.Key__c;
	        System.debug('Box_AccountPartnerKeyDAO: Partner key found: ' + pk.Key__c);        
    	} catch (Exception e) {
    		System.debug('Box_AccountPartnerKeyDAO: Partner key could not be found.');    		
    	}
        
    	return key;
    }
    
    public static void findAndUpdatePartnerKey(String oldKey, String newKey) {
    	System.debug('Box_AccountPartnerKeyDAO: Finding and updating partner key...');
    	
    	if (oldKey != null && newKey != null) {    		
    		// First, try to find the key
    		Partner_Key_Account__c key;	    				    			    	
	    	try {
	    		key = getPartnerKeyFromKey(getParamKeys().get('external_account_id'), oldKey);		    		
	    	} catch (Box_DuplicateRecordException d) {
	    		throw d;
	    	} catch (Exception e) {
	    		throw new NoDataFoundException();
	    	}
	    	
	    	// Now try updating the key
			key.Key__c = newKey;
			update key;
			System.debug('Box_AccountPartnerKeyDAO: Partner key successfully updated to ' + newKey);
    	}    	
    }

}