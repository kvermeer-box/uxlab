global with sharing class Box_AccountPartnerKeyFactory {
	
	public static void upsertPartnerKey(String key, String accountId) {
		System.debug('Box_AccountPartnerKeyFactory: Upserting partner key to account..');
		
		if (key != null && accountId != null) {
			try {
				Partner_Key_Account__c pk = new Partner_Key_Account__c();
				pk.Account__c = accountId;
				pk.Key__c = key;
				pk.Partner__c = Box_AccountDAO.findPartnerFromRunningUser().Id;
				upsert pk Key__c;			
				System.debug('Box_AccountPartnerKeyFactory: Partner key upserted!');
			} catch (Exception e) {
				System.debug('Box_AccountPartnerKeyFactory: Partner key NOT upserted: ' + e.getMessage());
			}
		}
				
	}
	
	public static void upsertPartnerKey(String key, String accountId, String partnerId) {
		System.debug('Box_AccountPartnerKeyFactory: Upserting partner key to account..');
		
		if (key != null && accountId != null) {
			Partner_Key_Account__c pk = new Partner_Key_Account__c();
			pk.Account__c = accountId;
			pk.Key__c = key;
			pk.Partner__c = partnerId;
			upsert pk Key__c;		
			System.debug('Box_AccountPartnerKeyFactory: Partner key upserted!');
		}
		
	}
		
	/*
	public static void upsertPartnerKey(Box_SalesTransaction salesTransaction, String accountId) {
		System.debug('Box_AccountPartnerKeyFactory: Upserting partner key from sales transaction..');
		
		if (salesTransaction.external_account_id != null && accountId != null) {
			
			try {
				// Initialize normal vars
				Partner_Key_Account__c pk = new Partner_Key_Account__c();
				pk.Account__c = accountId;
				pk.Partner__c = Box_AccountDAO.findPartnerFromRunningUser().Id;
				
				// If there is no update key, things are simple
				if (salesTransaction.external_account_id_update == null) {
					pk.Key__c = salesTransaction.external_account_id;
					upsert pk Key__c;
					System.debug('Box_AccountPartnerKeyFactory: Partner key upserted!');
				// If there is an update key, find old one then update
				} else {
					pk = Box_AccountPartnerKeyDAO.getPartnerKeyFromKey(Box_AccountPartnerKeyDAO.getParamKeys().get('external_account_id'), salesTransaction.external_account_id);
					pk.Key__c = salesTransaction.external_account_id_update;
					update pk;
					System.debug('Box_AccountPartnerKeyFactory: Partner key successfully updated to ' + salesTransaction.external_account_id_update);
				}
			} catch (Exception e) {
				System.debug('Box_AccountPartnerKeyFactory: Partner key NOT upserted: ' + e.getMessage());
			}
		}
		
	}	
	*/
	
}