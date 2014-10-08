public class CampaignMemberSetFirstOwnerRole {

	public static void setFirstOwnerRoleRequestHandler(List<CampaignMember> cms, Map<Id, CampaignMember> oldMap, Boolean isInsert)
	{
		Map<Id, User> users = new Map<Id, User>([Select Id, UserRole.Name From User Where IsActive = true]);
		
		for (CampaignMember cm : cms)
		{
			// When First Owner worked is set or if it changes - 
			// set first owner role worked to the value of the role of the user in the first owner role worked field.
			if (!isInsert  
				&& cm.FCRM__FCR_First_Owner_Worked__c != null 
				&& cm.FCRM__FCR_First_Owner_Worked__c != oldMap.get(cm.Id).FCRM__FCR_First_Owner_Worked__c 
				&& users.get(cm.FCRM__FCR_First_Owner_Worked__c) != null
				&& users.get(cm.FCRM__FCR_First_Owner_Worked__c).UserRole != null)
			{
				cm.First_Owner_Role_Worked__c = users.get(cm.FCRM__FCR_First_Owner_Worked__c).UserRole.Name;
			}
			
			// When First Owner assigned is set or changed - set first owner role assigned based on the role of that user
			if ((isInsert && cm.FCRM__FCR_First_Owner_Assigned__c != null)
				|| (cm.FCRM__FCR_First_Owner_Assigned__c != null 
					&& cm.FCRM__FCR_First_Owner_Assigned__c != oldMap.get(cm.Id).FCRM__FCR_First_Owner_Assigned__c)
					&& users.get(cm.FCRM__FCR_First_Owner_Assigned__c) != null
					&& users.get(cm.FCRM__FCR_First_Owner_Assigned__c).UserRole != null)
			{
				cm.First_Owner_Role_Assigned__c = users.get(cm.FCRM__FCR_First_Owner_Assigned__c).UserRole.Name;
			}
		}
	}

}