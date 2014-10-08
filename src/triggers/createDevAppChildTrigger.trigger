trigger createDevAppChildTrigger on Developer_Account__c (after insert) {
	
	List<Developer_Account__c> dAccts = [SELECT Id, Name FROM Developer_Account__c WHERE Id IN :trigger.new];	
	
	List<Developer_Application__c> insertApps = new List<Developer_Application__c>();	
	for (Developer_Account__c a : dAccts) {
		Developer_Application__c childApp = new Developer_Application__c();
		childApp.Developer_Account__c = a.Id;
		childApp.Name = a.Name;
		insertApps.add(childApp);
	}
	
	insert insertApps;
}