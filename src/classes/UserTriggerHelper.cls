/**
 * This class contains utility methods and values for one-off methods needed in the User trigger.
 *
 * @author Richard Wu <rwu@box.com>
 * @version 1.0
 *
 *  
 */
public class UserTriggerHelper {
 
    public static void beforeInsert(List<User> userList) {
 

    }

    public static void afterInsert(List<User> userList) {
 

		updateObjects(userList, new Map<Id,User>());
    }

    public static void beforeUpdate(List<User> userList,
                                    Map<Id,User> oldUserMap) {
 
                               
    }

    public static void afterUpdate(List<User> userList,
                                   Map<Id,User> oldUserMap) {
 
		updateObjects(userList, oldUserMap);      
    }

	/* add partner users to public groups */
    public static void updateObjects(List<User> userList,
                                   Map<Id,User> oldUserMap) {
 
		boolean isInsert=false;
		Set<Id> partnerUserIds = new Set<Id>();
		
		Set<Id> profileIds = new Set<Id>();
		Map<Id, Profile> profileMap = new Map<Id, Profile>(); 
		Set<String> profileNames = new set<String>();
		Map<String, Group> groupMap = new Map<String, Group>(); 
		
		List<GroupMember>  newGroupMemberList = new List<GroupMember>();
 		 		
		if(oldUserMap==null || oldUserMap.size()==0){
			isInsert=true;
		}
		
		for(User u : userList){
		
			if(u.UserType=='PowerPartner'){
				partnerUserIds.add(u.Id);
				profileIds.add(u.ProfileId);
			}		
		}
		
		if(profileIds.size()>0){
			
			for(Profile p : [SELECT Id ,Name, UserLicenseId, UserType 
									FROM Profile 
										Where UserType ='PowerPartner'
											and id in: profileIds]){
			
				profileMap.put(p.id, p);
				profileNames.add(p.Name);	
				
			}
		}

		if(profileNames.size()>0){
 
			for(Group grp :[Select g.Type, g.Name, g.DeveloperName, 
										(Select Id, GroupId, UserOrGroupId From GroupMembers
											where UserOrGroupId in: partnerUserIds) 
								From Group g 
									where type = 'Regular' 
								 		and Name in: profileNames]){
			
					
				groupMap.put(grp.Name, grp);
					
			}//end-for
		}

		GroupMember gm;
		String profileName;
		Group partnerGroup;
		 
		
		 
		for(User u : userList){
		
			if(u.UserType=='PowerPartner'){
				
				profileName=profileMap.get(u.ProfileId).Name;
				partnerGroup=groupMap.get(profileName);
				
				// there's no group with this name
				if(partnerGroup==null){
					continue;
				}
				
				// check whether group member already exists before creating a new one
				if (!groupMemberExist(u, partnerGroup)){
				
 					gm = new GroupMember();
 					gm.GroupId = partnerGroup.Id;
 					gm.UserOrGroupId = u.Id;	
 					
 					newGroupMemberList.add(gm);
				
				}
 				
			}		
			
		}	

		if(newGroupMemberList.size()>0){
			
			try{
				
				insert newGroupMemberList;
				
			}catch (Exception e){
				LoggedException le = new LoggedException(e, 'Trouble adding partner users to public groups', 'UserTriggerHelper');
			}
		}		 

    
    }
    
	/* return true if group member already exists */
	public static boolean groupMemberExist(User u, Group grp){
		
		boolean exists = false;
		
		if(u==null || grp==null){
			return exists;
		}
		
		List<GroupMember> groupMemberList = grp.groupmembers;
		
		if(groupMemberList==null || groupMemberList.size()==0){
			return exists;		
		}
		
		for(GroupMember gm : groupMemberList){
		
			if(gm.UserOrGroupId==u.Id){
				exists=true;
				break;
			}	
		}
		
		return exists;
		
	}

}