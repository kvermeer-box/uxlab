trigger DiscOrgOwnerFix on Contact (before insert, before update) {
    Set<ID> accountstoquery = new Set<ID>();
    List<Contact> contactstoprocess = new List<Contact>();

	DiscOrgOwnerSetting__c config = DiscOrgOwnerSetting__c.getInstance('default');
	if(config==null || config.OwnerIDs__c == null) return;
	
	Set<String> ownerids = new Set<String>(config.OwnerIDs__c.split(','));

    for(Contact c: Trigger.New){
        if(ownerids.contains(c.OwnerID) && c.AccountID!=null )
        {
            accountstoquery.add(c.AccountID);
            contactstoprocess.add(c);
        }
    }
    if(contactstoprocess.size()==0 || accountstoquery.size()==0) return;
    Map<ID, Account> accounts = new Map<ID, Account>([SELECT ID, OwnerID from Account where ID in :accountstoquery]);
   
    if (accounts != null && accounts.size() != 0) {
	    for(Contact c: contactstoprocess) {
	    	if (accounts.get(c.AccountID) != null && accounts.get(c.AccountID).OwnerID != null) {
	    		c.OwnerID = accounts.get(c.AccountID).OwnerID;
	    	}
	    }
    }
}