public class Territory_MaxRoutedLeadSelector {

	public static Id selectDeservingUser(Set<User> users, Map<Id, Territory_MaxLeadSummary> usersAndLeadSummaries, Id defaultId) {
		// Debug
		if (users != null) {
			System.debug(System.LoggingLevel.ERROR, 'Territory_MaxRoutedLeadSelector: Selecting the most deserving user out of ' + users.size() + ' users.');
		} else {
			return defaultId;
		}
		if (usersAndLeadSummaries != null) {
			System.debug(System.LoggingLevel.ERROR, 'Territory_MaxRoutedLeadSelector: ' + usersAndLeadSummaries.size() + ' users with existing routed leads in this pool.');
		} else {
			System.debug(System.LoggingLevel.ERROR, 'Territory_MaxRoutedLeadSelector: No existing routed leads in this pool.');
		}
		System.debug(System.LoggingLevel.ERROR, 'Territory_MaxRoutedLeadSelector: Script limit (before): ' + Limits.getScriptStatements());
		
		// Set up default user id		
		Id deservingUserId;	
		List<User> userList = new List<User>();
		userList.addAll(users);
		deservingUserId = userList[0].Id;		
		
		// Iterate across users to see if there's a better match
		if (usersAndLeadSummaries != null) {			
			for (User user : users) {
				Territory_MaxLeadSummary userSummary = usersAndLeadSummaries.get(user.Id);
				// Users not represented automatically win
				if (userSummary == null) {
					deservingUserId = user.Id;
					System.debug(System.LoggingLevel.ERROR, 'Territory_MaxRoutedLeadSelector: ' + user.Name + ' does not have any routed leads. Winner!');
					break;
				// User with the oldest lead summary wins
				} else {									
					// Compare dates
					Territory_MaxLeadSummary deservingSummary = usersAndLeadSummaries.get(deservingUserId);
					if (userSummary.createdDateGmt < deservingSummary.createdDateGmt) {
						deservingUserId = user.Id;
						System.debug(System.LoggingLevel.ERROR, 'Territory_MaxRoutedLeadSelector: ' + user.Name + ' has an older lead summary. Winner!');
					// Compare sort order if dates are equal
					} else if (userSummary.createdDateGmt == deservingSummary.createdDateGmt && userSummary.sortOrder != null && deservingSummary.sortOrder != null) {
						if (userSummary.sortOrder == null && deservingSummary.sortOrder != null) {
							deservingUserId = user.Id;
							System.debug(System.LoggingLevel.ERROR, 'Territory_MaxRoutedLeadSelector: ' + user.Name + ' has a lead summary on the same date, but without a sort order. Winner!');
						} else if (userSummary.sortOrder < deservingSummary.sortOrder) {
							deservingUserId = user.Id;	
							System.debug(System.LoggingLevel.ERROR, 'Territory_MaxRoutedLeadSelector: ' + user.Name + ' has a smaller sort order. Winner!');
						}							
					}
				}
			}
		}		
		System.debug(System.LoggingLevel.ERROR, 'Territory_MaxRoutedLeadSelector: Most deserving user ' + deservingUserId);
		System.debug(System.LoggingLevel.ERROR, 'Territory_MaxRoutedLeadSelector: Script limit (after): ' + Limits.getScriptStatements());
		return deservingUserId;
	}
	
}