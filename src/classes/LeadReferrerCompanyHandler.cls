public with sharing class LeadReferrerCompanyHandler {
	public static void popReferrerCompany(Lead[] leads) {
		List<Id> accntIds = new List<Id>();
		for(Lead l :leads){
			accntIds.add(l.Referrer_Partner_ID__c);
		}
		Map<Id, String> accntMap = new Map<Id, String>();
		for(Account a :[SELECT Id, Name FROM Account WHERE Id IN :accntIds]){
			accntMap.put(a.Id, a.Id);
		}
		for(Lead l :leads){
			if(accntMap.get(l.Referrer_Partner_ID__c) != null){
				l.Referrer_Partner_Company_2__c = accntMap.get(l.Referrer_Partner_ID__c);
			}
		}
	}
}