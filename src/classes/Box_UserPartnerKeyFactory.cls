global with sharing class Box_UserPartnerKeyFactory {

	public static void upsertPartnerKey(String key, String contactId) {
		System.debug('Box_UserPartnerKeyFactory: Upserting partner key to contact..');
		
		if (key != null && contactId != null) {
			try {
				Partner_Key_Contact__c pk = new Partner_Key_Contact__c();
				pk.Contact__c = contactId;
				pk.Key__c = key;
				pk.Partner__c = Box_AccountDAO.findPartnerFromRunningUser().Id;
				upsert pk Key__c;		
				System.debug('Box_UserPartnerKeyFactory: Partner key upserted!');
			} catch (Exception e) {
				System.debug('Box_UserPartnerKeyFactory: Partner key NOT upserted: ' + e.getMessage());
			}
		}
		
	}

}