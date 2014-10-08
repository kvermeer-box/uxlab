public class Territory_UserDAO {

	public static String getSoqlFields() {
        System.debug(System.LoggingLevel.ERROR, 'Territory_UserDAO: Getting fields to query...');
        
        // Prepare important fields to query
        List<String> fieldsToQuery = new List<String>(); 
        fieldsToQuery.add('Id');
        fieldsToQuery.add('Name');
        fieldsToQuery.add('Email');
        fieldsToQuery.add('UserRole.Name');
        fieldsToQuery.add('Remove_From_All_Lead_Assignment_Queues__c');
        fieldsToQuery.add('IsActive');
        
        // Format fields in dynamic soql readable fashion
        String soqlFields = String.join(fieldsToQuery, ', ');       
        System.debug(System.LoggingLevel.ERROR, 'Territory_UserDAO: Query fields: ' + soqlFields);
        
        return soqlFields;
    }

	public static String getBaseSoqlQuery() {
        System.debug(System.LoggingLevel.ERROR, 'Territory_UserDAO: Getting base soql query for users...');
        
        String soql = 'SELECT ' + getSoqlFields() 
                    + '     FROM User '
                    + '     WHERE IsActive = true '
                    + '     	AND Remove_From_All_Lead_Assignment_Queues__c = false ';
        System.debug(System.LoggingLevel.ERROR, 'Territory_UserDAO: Base soql query: ' + soql);
        return soql;
    }

	public static List<User> getAllUsersList(String queryAppend) {
        System.debug(System.LoggingLevel.ERROR, 'Territory_UserDAO: Getting  map of all users...');
        
        List<User> allUsersList = new List<User>();
        String soql = getBaseSoqlQuery();
        if (queryAppend != null) { soql += ' ' + queryAppend + ' '; }
        System.debug(System.LoggingLevel.ERROR, 'Territory_UserDAO: SOQL Query: ' + soql);
        allUsersList = (List<User>)Database.query(soql);
        System.debug(System.LoggingLevel.ERROR, 'Territory_UserDAO: ' + allUsersList.size() + ' users mapped.');
        
        return allUsersList; 
    }

}