public class Territory_TeamDAO {
	
	private static Map<Id, Territory_Team__c> allTeams;

	public static String getSoqlFields() {
        System.debug(System.LoggingLevel.ERROR, 'Territory_TeamDAO: Getting fields to query...');
        
        // Prepare important fields to query
        List<String> fieldsToQuery = new List<String>(); 
        fieldsToQuery.add('Id');
        fieldsToQuery.add('Name');
        fieldsToQuery.add('Team_Member_Roles__c');
        
        // Format fields in dynamic soql readable fashion
        String soqlFields = String.join(fieldsToQuery, ', ');       
        System.debug(System.LoggingLevel.ERROR, 'Territory_TeamDAO: Query fields: ' + soqlFields);
        
        return soqlFields;
    }
    
    public static String getChildSoqlFields() {
        System.debug(System.LoggingLevel.ERROR, 'Territory_TeamDAO: Getting child (Team Member Role) fields to query...');
        
        // Prepare important fields to query
        List<String> fieldsToQuery = new List<String>(); 
        fieldsToQuery.add('Id');
        fieldsToQuery.add('Role_Name__c');
        
        // Format fields in dynamic soql readable fashion
        String soqlFields = String.join(fieldsToQuery, ', ');       
        System.debug(System.LoggingLevel.ERROR, 'Territory_TeamDAO: Query fields: ' + soqlFields);
        
        return soqlFields;
    }
    
    public static String getBaseSoqlQuery() {
        System.debug(System.LoggingLevel.ERROR, 'Territory_TeamDAO: Getting base soql query for teams...');
        
        String soql = 'SELECT ' + getSoqlFields() + ', '
        			+ '		(SELECT ' + getChildSoqlFields() + ' FROM Team_Member_Roles__r) '
                    + '     FROM Territory_Team__c '
                    + '     WHERE Team_Member_Roles__c > 0 ';
        System.debug(System.LoggingLevel.ERROR, 'Territory_TeamDAO: Base soql query: ' + soql);
        return soql;
    }
    
    public static Map<Id, Territory_Team__c> getAllTeamsMap() {
        System.debug(System.LoggingLevel.ERROR, 'Territory_TeamDAO: Getting map of all teams...');
        
        allTeams = new Map<Id, Territory_Team__c>();
        String soql = getBaseSoqlQuery();
        allTeams.putAll((List<Territory_Team__c>)Database.query(soql));
        
        System.debug(System.LoggingLevel.ERROR, 'Territory_TeamDAO: ' + allTeams.size() + ' teams mapped.');
        return allTeams; 
    }
    
    public static Map<Id, Set<User>> getTeamAndUserMap(Set<Territory_Team__c> allRelevantTeams) {
    	System.debug(System.LoggingLevel.ERROR, 'Territory_TeamDAO: Preparing a map of all relevant teams and their users...');
		System.debug(System.LoggingLevel.ERROR, 'Territory_TeamDAO: Script limit (before) ' + Limits.getScriptStatements());		
		
		Map<Id, Set<User>> teamAndUserMap = new Map<Id, Set<User>>();
		
		// Get list of all possible users		
		List<User> allRelevantUsers = Territory_UserDAO.getAllUsersList(buildTeamSubsetQueryAppend(allRelevantTeams));
		
		// Iterate through all possible users and add to relevant team
		for (User user : allRelevantUsers) {
			// Iterate through all teams			
			for (Territory_Team__c team : allRelevantTeams) {
				// ...and all team member roles
				for (Territory_Team_Member_Role__c role : team.Team_Member_Roles__r) {
					System.debug(System.LoggingLevel.ERROR, 'Territory_TeamDAO: Comparing ' + user.Name + '\'s role (' + user.UserRole.Name + ') to ' + role.Role_Name__c + '...');
					// If the user's role contains the role name in the team member role, add
					if (user.UserRole.Name != null && user.UserRole.Name.contains(role.Role_Name__c)) {
						Set<User> userSet = teamAndUserMap.get(team.Id);
						if (userSet == null) {
							userSet = new Set<User>();							
						}
						userSet.add(user);
						teamAndUserMap.put(team.Id, userSet);
						System.debug(System.LoggingLevel.ERROR, 'Territory_TeamDAO: Adding ' + user.Name + ' to ' + team.Name + ' set.');
					}
				}
			}
		}
		
		// Debug
		System.debug(System.LoggingLevel.ERROR, 'Territory_TeamDAO: Total teams: ' + teamAndUserMap.size());
		for (Id id : teamAndUserMap.keySet()) {
			System.debug(System.LoggingLevel.ERROR, 'Territory_TeamDAO:     Team: ' + id + '\'s user list size: ' + teamAndUserMap.get(id).size());
			for (User u : teamAndUserMap.get(id)) {
				System.debug(System.LoggingLevel.ERROR, 'Territory_TeamDAO:     ' + id + ': ' + u.Name);
			}
		}		
		System.debug(System.LoggingLevel.ERROR, 'Territory_TeamDAO: Script limit (after) ' + Limits.getScriptStatements());
		return teamAndUserMap;
    }
    
    private static String buildTeamSubsetQueryAppend(Set<Territory_Team__c> teamSubset) {
    	// Iterate across all team member roles and query for those associated users
    	String queryAppend;
    	if (teamSubset != null && teamSubset.size() > 0) {
	    	queryAppend = ' AND ( ';
			Integer teamIterator = 0; 		
			for (Territory_Team__c team : teamSubset) {
				for (Integer j = 0; j < team.Team_Member_Roles__r.size(); j++) {
					Territory_Team_Member_Role__c role = team.Team_Member_Roles__r[j];
					String teamRoleWildcard = '%' + role.Role_Name__c + '%';
					queryAppend += ' UserRole.Name LIKE \'' + String.escapeSingleQuotes(teamRoleWildcard) + '\'';				
					if (!(teamIterator == teamSubset.size() - 1 && j == team.Team_Member_Roles__r.size() - 1)) {
						queryAppend += ' OR ';
					}	
				}						
				teamIterator++;
			}
			queryAppend += ' ) ';
    	}
		return queryAppend;
    }

}