public class Territory_S1RulesDAO {
    
    private static Map<Id, Territory_Stage_1_Assignment_Rule__c> allRulesMap;
    
    public static String getSoqlFields() {
        System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDAO: Getting fields to query...');
        
        // Prepare important fields to query
        List<String> fieldsToQuery = new List<String>(); 
        fieldsToQuery.add('Id');
        fieldsToQuery.add('Name');
        fieldsToQuery.add('Active__c');
        fieldsToQuery.add('Assigned_Queue__c');
        fieldsToQuery.add('Assigned_Team__c');
        fieldsToQuery.add('Assigned_Team__r.Name');
        fieldsToQuery.add('Assigned_User__c');
        fieldsToQuery.add('Assign_To__c');
        fieldsToQuery.add('Child_Rules__c');
        fieldsToQuery.add('Entry_Method__c');
        fieldsToQuery.add('Entry_Value__c');
        fieldsToQuery.add('Key__c');
        fieldsToQuery.add('Parent_Assignment_Rule__c'); 
        
        // Format fields in dynamic soql readable fashion
        String soqlFields = String.join(fieldsToQuery, ', ');       
        System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDAO: Query fields: ' + soqlFields);
        
        return soqlFields;
    }
    
    public static String getBaseSoqlQuery() {
        System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDAO: Getting base soql query for s1 assignment rules...');
        
        String soql = 'SELECT ' + getSoqlFields() + ', '
                    + '         (SELECT ' + getSoqlFields() + ' FROM Child_Assignment_Rules__r WHERE Active__c = true) '
                    + '     FROM Territory_Stage_1_Assignment_Rule__c '
                    + '     WHERE Active__c = true ';           
        System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDAO: Base soql query: ' + soql);
        return soql;
    }
    
    public static Map<Id, Territory_Stage_1_Assignment_Rule__c> getRefreshedAllRulesMap() {
        System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDAO: Getting refreshed map of all s1 assignment rules...');
        
        allRulesMap = new Map<Id, Territory_Stage_1_Assignment_Rule__c>();
        String soql = getBaseSoqlQuery();
        allRulesMap.putAll((List<Territory_Stage_1_Assignment_Rule__c>)Database.query(soql));
        System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDAO: ' + allRulesMap.size() + ' rules mapped.');
        
        return allRulesMap; 
    }
    
    public static Map<Id, Territory_Stage_1_Assignment_Rule__c> getAllRulesMap() {
        System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDAO: Getting map of all s1 assignment rules...');
        
        if (allRulesMap != null && allRulesMap.size() > 0) {
            return allRulesMap;
        } else {
            return getRefreshedAllRulesMap();
        }
    }
    
    public static Map<String, Territory_Stage_1_Assignment_Rule__c> getAllParentRulesMapByKey() {
    	System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDAO: Getting map of all s1 parent assignment rules...');
    	Map<String, Territory_Stage_1_Assignment_Rule__c> allParentRulesMap = new Map<String, Territory_Stage_1_Assignment_Rule__c>();
    	allRulesMap = getAllRulesMap();
    	for (Id id : allRulesMap.keySet()) {
    		Territory_Stage_1_Assignment_Rule__c rule = allRulesMap.get(id);
    		if (rule.Parent_Assignment_Rule__c == null) {
    			allParentRulesMap.put(rule.Key__c, rule);
    		}
    	}
    	System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDAO: ' + allParentRulesMap.size() + ' parent rules mapped.');
    	return allParentRulesMap;
    }
    
    public static List<Territory_Stage_1_Assignment_Rule__c> getQueriedRulesFromTriggerMap(Map<Id, Territory_Stage_1_Assignment_Rule__c> triggerMap) {
        System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDAO: Querying relevant fields from a trigger map...');
        
        List<Territory_Stage_1_Assignment_Rule__c> queriedRules = new List<Territory_Stage_1_Assignment_Rule__c>();
        
        // Query
        if (triggerMap != null) {
            List<Id> rulesList = new List<Id>();
            rulesList.addAll(triggerMap.keySet());
            String soql = getBaseSoqlQuery() 
                        + '     AND Id IN (\'' + String.join(rulesList, '\', \'') + '\') ';
                        
            // Update list with results         
            queriedRules = (List<Territory_Stage_1_Assignment_Rule__c>)Database.query(soql);        
            System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDAO: ' + queriedRules.size() + ' rules queried.');
        }
        
        return queriedRules;
    }

}