trigger SLALeadTrigger on Lead (before insert, before update) {
	for(Lead ld: trigger.new)
	{
        if (ld.ownerId == null) {
            continue;
        }
		ID newowner = (ld.OwnerID.getSObjectType() != User.getSObjectType())? null: ld.OwnerID;
		if(ld.Current_Owner__c != newowner) ld.Current_Owner__c = newowner;
	}
}