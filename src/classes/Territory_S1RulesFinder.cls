public class Territory_S1RulesFinder {

    // All data collection variables
    private Map<String, Territory_Stage_1_Assignment_Rule__c> allRulesMapWithCapitalKey;
        
    // Default entry methods
    private final String ENTRY_METHOD_COUNTRY = 'Country';
    private final String ENTRY_METHOD_CONTACT_METHOD_GROUPING = 'Contact Method Grouping';
    private final String ENTRY_METHOD_MAX_EMPLOYEE_SIZE = 'Max Employee Size';
    private final String ENTRY_METHOD_TRIAL_TYPE = 'Trial Type';
    private final String ENTRY_METHOD_INDUSTRY = 'Industry';
    
    // Default rules 
    private final String ENTRY_VALUE_DEFAULT = '<< DEFAULT ASSIGNMENT RULE >>';
    private final String ENTRY_VALUE_BLACK_HOLE = '<< BLACK HOLE >>';
    private final String ENTRY_VALUE_UNLIMITED = 'UNLIMITED';
    private final Territory_Stage_1_Assignment_Rule__c QA_DEFAULT_RULE;
    private final Territory_Stage_1_Assignment_Rule__c BD_DEFAULT_RULE; 

    public Territory_S1RulesFinder () {
        // Set mass data variables      
        setAllRulesMapWithCapitalKey();
        
        // Set default rules
        Territory_CustomSettings.setS1BlackHoleRule(allRulesMapWithCapitalKey.get(ENTRY_VALUE_BLACK_HOLE));
        QA_DEFAULT_RULE = allRulesMapWithCapitalKey.get('<< QA LEAD >>');
        BD_DEFAULT_RULE = allRulesMapWithCapitalKey.get('<< BUSINESS DEVELOPMENT >>');  
    }

    public Territory_Stage_1_Assignment_Rule__c findAssignmentRule(Lead lead) {
        System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesFinder: Finding assignment rule for lead ' + lead.Id);
        System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesFinder: Script limit (before) ' + Limits.getScriptStatements());
        
        // Setup
        Territory_Stage_1_Assignment_Rule__c rule;

        // Filter special exceptions
        rule = findSpecialAssignmentRuleForLead(lead);

        // Find the assignment rule
        if (rule == null) { 
            rule = findAssignmentRule(lead, null);
        }
        
        // Just in case
        if (rule == null) {
            rule = Territory_CustomSettings.getS1BlackHoleRule();
        }
        
        System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesFinder: Script limit (after) ' + Limits.getScriptStatements());
        return rule;
    }
    
    private void setAllRulesMapWithCapitalKey() {
        System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesFinder: Setting all rules map with key__c...');
        System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesFinder: Script limit (before) ' + Limits.getScriptStatements());
    
        // Go through each rule and add using key__c as the map key
        allRulesMapWithCapitalKey = new Map<String, Territory_Stage_1_Assignment_Rule__c>();
        Map<Id, Territory_Stage_1_Assignment_Rule__c> allRulesMap = Territory_S1RulesDAO.getAllRulesMap();
        for (Id id : allRulesMap.keySet()) {
            Territory_Stage_1_Assignment_Rule__c rule = allRulesMap.get(id);
            allRulesMapWithCapitalKey.put(rule.Key__c.toUpperCase(), rule);
        }
        System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesFinder: ' + allRulesMapWithCapitalKey.size() + ' total rules added.');
        System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesFinder: Script limit (after) ' + Limits.getScriptStatements());
    }
    
    private Territory_Stage_1_Assignment_Rule__c findSpecialAssignmentRuleForLead(Lead lead) {
        System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesFinder: Checking if lead qualifies for special assignment rules...');
        
        Territory_Stage_1_Assignment_Rule__c specialRule;
        specialRule = findQaAssignmentRuleForLead(lead);
        if (specialRule == null) { specialRule = findBdAssignmentRuleForLead(lead); }
        
        return specialRule;
    }
    
    private Territory_Stage_1_Assignment_Rule__c findQaAssignmentRuleForLead(Lead lead) {
        System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesFinder: Checking if lead is a QA lead...');
                
        // Generate list of QA email values
        List<String> qaLeadEmailStrings = generateQaLeadEmailStrings();     
        
        // Iterate through QA values to find a match
        if (lead.Email != null) {
            for (String s : qaLeadEmailStrings) {
                if (lead.Email.toLowerCase().contains(s.toLowerCase())) {
                    System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesFinder: This is a QA lead: ' + lead.Email);
                    return QA_DEFAULT_RULE;
                }
            }           
        }
        System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesFinder: This is not a QA lead');
        return null;
    }
    
    private List<String> generateQaLeadEmailStrings() {
        List<String> qaLeadEmailStrings = new List<String>();
        qaLeadEmailStrings.add('test@');
        qaLeadEmailStrings.add('@box.com');
        qaLeadEmailStrings.add('@box.net');
        qaLeadEmailStrings.add('boxinternalqa');
        qaLeadEmailStrings.add('boxstresslive');
        qaLeadEmailStrings.add('boxautomatedqa');
        return qaLeadEmailStrings;
    }
    
    private Territory_Stage_1_Assignment_Rule__c findBdAssignmentRuleForLead(Lead lead) {
        System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesFinder: Checking if lead is a BD lead...');
        
        Territory_Stage_1_Assignment_Rule__c bdRule;        
        bdRule = findBdSourceDetailRuleForLead(lead);
        if (bdRule == null) { 
            bdRule = findBdPartnerProgramRuleForLead(lead); 
        }       
        return bdRule;
    }
    
    private Territory_Stage_1_Assignment_Rule__c findBdSourceDetailRuleForLead(Lead lead) {
        List<String> bdSourceDetailValues = generateBdSourceDetailValues();
    
        // Iterate through Source Detail values to find a match
        if (lead.Source_Detail__c != null) {
            for (String s : bdSourceDetailValues) {
                if (lead.Source_Detail__c.toLowerCase().contains(s.toLowerCase())) {
                    System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesFinder: This is a BD source detail lead: ' + lead.Source_Detail__c);
                    return BD_DEFAULT_RULE;
                }
            }           
        }
        System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesFinder: This is not a BD source detail lead');
        return null;
    }
    
    private Territory_Stage_1_Assignment_Rule__c findBdPartnerProgramRuleForLead(Lead lead) {
        List<String> bdPartnerProgramValues = generateBdPartnerProgramValues();
        
        // Iterate through Partner Program values to find a match
        if (lead.Partner_program_type__c != null) {
            for (String s : bdPartnerProgramValues) {
                if (lead.Partner_program_type__c.toLowerCase().contains(s.toLowerCase())) {
                    System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesFinder: This is a BD partner program lead: ' + lead.Partner_program_type__c);
                    return BD_DEFAULT_RULE;
                }
            }           
        }
        System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesFinder: This is not a BD partner program lead');
        return null;
    }
    
    private List<String> generateBdSourceDetailValues() {
        List<String> bdSourceDetailValues = new List<String>();
        bdSourceDetailValues.add('Referral Partner');
        bdSourceDetailValues.add('Reseller Program');
        bdSourceDetailValues.add('Partner Application Form');
        return bdSourceDetailValues;
    }
        
    private List<String> generateBdPartnerProgramValues() {
        List<String> bdPartnerProgramValues = new List<String>();
        bdPartnerProgramValues.add('Consulting');
        bdPartnerProgramValues.add('General Inquiry');
        bdPartnerProgramValues.add('Alliance');     
        return bdPartnerProgramValues;
    }   
    
    private Territory_Stage_1_Assignment_Rule__c findAssignmentRule(Lead lead, Territory_Stage_1_Assignment_Rule__c currentRule) {
        System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesFinder: Finding the assignment rule for lead ' + lead.Id);
        
        // Setting up variables we will use
        Territory_Stage_1_Assignment_Rule__c nextRule;
        Territory_Stage_1_Assignment_Rule__c finalRule;
        Map<String, Territory_Stage_1_Assignment_Rule__c> rules;
        
        // Recursively find the final node (leaf). Starting at the root 
        if (currentRule == null) {
            System.debug(System.LoggingLevel.ERROR, 'Beginning at root node.');
            rules = Territory_S1RulesDAO.getAllParentRulesMapByKey();
            nextRule = findNextAssignmentRuleByEntryValue(lead, rules);
            finalRule = findAssignmentRule(lead, nextRule);
        // Branch node
        } else if (currentRule.Child_Assignment_Rules__r != null && currentRule.Child_Assignment_Rules__r.size() > 0) {
            System.debug(System.LoggingLevel.ERROR, 'Beginning at branch node: ' + currentRule.Id);
            rules = getChildMapByKey(currentRule);
            nextRule = findNextAssignmentRuleByEntryValue(lead, rules);
            finalRule = findAssignmentRule(lead, nextRule);
        // Leaf node     
        } else {
            System.debug(System.LoggingLevel.ERROR, 'Leaf node reached: ' + currentRule.Id);
            finalRule = currentRule;
        }       
        return finalRule;
    }
    
    private Map<String, Territory_Stage_1_Assignment_Rule__c> getChildMapByKey(Territory_Stage_1_Assignment_Rule__c rule) {
        Map<String, Territory_Stage_1_Assignment_Rule__c> rules = new Map<String, Territory_Stage_1_Assignment_Rule__c>();
        for (Territory_Stage_1_Assignment_Rule__c r : rule.Child_Assignment_Rules__r) {
            // We get a new version of each rule with queried child values
            rules.put(r.Entry_Value__c.toUpperCase(), allRulesMapWithCapitalKey.get(r.Key__c));
        }
        return rules;
    }
    
    private Territory_Stage_1_Assignment_Rule__c findNextAssignmentRuleByEntryValue(Lead lead, Map<String, Territory_Stage_1_Assignment_Rule__c> rules) {
        System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesFinder: Finding most relevant assignment rule for ' + lead.Id + ' from ' + rules.size() + ' rules.');
        
        Territory_Stage_1_Assignment_Rule__c rule;      
        String entryMethod = findEntryMethod(rules);
        
        // First check for Country matches
        if (entryMethod == null)
            rule = Territory_CustomSettings.getS1BlackHoleRule();
        else if (entryMethod.equals(ENTRY_METHOD_COUNTRY))
            rule = findOrDefaultAssignmentRule('Territory_Routing_Country__c', lead, rules);
         // Next check for Contact Method Grouping matches
        else if (rule == null && entryMethod.equals(ENTRY_METHOD_CONTACT_METHOD_GROUPING))
            rule = findOrDefaultAssignmentRule('CleanCM__c', lead, rules);
         // Try finding a matching employee segment
        else if (rule == null && entryMethod.equals(ENTRY_METHOD_MAX_EMPLOYEE_SIZE))
            rule = findRuleByLeadEmployees(lead, rules);
        // Trial Type
        else if (rule == null && entryMethod.equals(ENTRY_METHOD_TRIAL_TYPE))
            rule = findOrDefaultAssignmentRule('Trial_Type__c', lead, rules);
        // Industry
        else if (rule == null && entryMethod.equals(ENTRY_METHOD_INDUSTRY))
            rule = findOrDefaultAssignmentRule('Industry', lead, rules);
        // Default, just in case
        else if (rule == null) {
            rule = Territory_CustomSettings.getS1BlackHoleRule();
        }
        
        System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesFinder: Next assignment rule: ' + rule.Id + ' - ' + rule.Entry_Method__c + ' : ' + rule.Entry_Value__c.toUpperCase());
        return rule;
    }
    
    private Territory_Stage_1_Assignment_Rule__c findOrDefaultAssignmentRule(String field, Lead lead, Map<String, Territory_Stage_1_Assignment_Rule__c> rules) {
        Territory_Stage_1_Assignment_Rule__c rule;
        System.debug('Lead: ' + lead);
        System.debug('Field: ' + field);
        // Parse the entry value
        String entryValue = String.valueOf(lead.get(field));
        System.debug('Entry Value: ' + entryValue);
        if (entryValue != null) {
            entryValue = entryValue.toUpperCase();
        }
        System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesFinder: Entry value: ' + entryValue);
        
        // Do the get  
        if (entryValue != null && !entryValue.equals('')) {
            rule = rules.get(entryValue);
        }
        if (rule == null) {
            rule = getDefaultRule(rules);
        }
        return rule;
    }
    
    private String findEntryMethod(Map<String, Territory_Stage_1_Assignment_Rule__c> rules) {
        System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesFinder: Finding entry method...');
        String entryMethod;
        for (String key : rules.keySet()) {
            Territory_Stage_1_Assignment_Rule__c r = rules.get(key);
            if (r.Entry_Method__c != null && !r.Entry_Method__c.contains('<<')) {
                System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesFinder: Entry method: ' + r.Entry_Method__c);
                return r.Entry_Method__c;
            }
        }
        return null;
    }
    
    private Territory_Stage_1_Assignment_Rule__c getDefaultRule(Map<String, Territory_Stage_1_Assignment_Rule__c> rules) {
        Territory_Stage_1_Assignment_Rule__c rule = rules.get(ENTRY_VALUE_DEFAULT);
        if (rule == null) {
            rule = Territory_CustomSettings.getS1BlackHoleRule();
        }
        return rule;
    }
    
    private Territory_Stage_1_Assignment_Rule__c findRuleByLeadEmployees(Lead lead, Map<String, Territory_Stage_1_Assignment_Rule__c> rules) {
        
        // Prep the data
        Territory_Stage_1_Assignment_Rule__c rule;
        Integer employeeSize = Territory_LeadEmployeeSizeCalculator.calculateLeadEmployeeSize(lead);
        
        // Match employee size, if it is available
        if (employeeSize != null) {
            // Sort and find the matching employee bracket
            List<Territory_Stage_1_Assignment_Rule__c> sortedRulesList = convertRulesMapToSortedList(rules);
            for (Integer i = 0; i < sortedRulesList.size(); i++) {
                Territory_Stage_1_Assignment_Rule__c r = sortedRulesList[i];                
                // Find the first rule with a max employee size greater than the lead's employee size   
                if (r.Entry_Value__c.isNumeric() && employeeSize <= Integer.valueOf(r.Entry_Value__c)) {
                    rule = r;   
                    break;
                // Unlimited sorts to the end, so if we see it, we're done
                } else if (r.Entry_Value__c.toUpperCase().equals(ENTRY_VALUE_UNLIMITED)) {
                    rule = r;
                    break;
                }
            }       
        }
        
        // Get defaults if there are no matches
        if (rule == null) {
            rule = getDefaultRule(rules);
        }
        return rule;
    }
    
    private List<Territory_Stage_1_Assignment_Rule__c> convertRulesMapToSortedList(Map<String, Territory_Stage_1_Assignment_Rule__c> rules) {
        System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesFinder: converting ' + rules.size() + ' object rules map to sorted list...');
        
        // Pop these into the sortable list
        List<Territory_S1RulesComparable> sortedComparableRulesList = new List<Territory_S1RulesComparable>();
        for (String key : rules.keySet()) {
            Territory_Stage_1_Assignment_Rule__c rule = rules.get(key);
            Territory_S1RulesComparable comparableRule = new Territory_S1RulesComparable(rule);
            sortedComparableRulesList.add(comparableRule);
        }
         
        // Sort
        sortedComparableRulesList.sort();       
        List<Territory_Stage_1_Assignment_Rule__c> sortedRulesList = new List<Territory_Stage_1_Assignment_Rule__c>();
        for (Territory_S1RulesComparable c : sortedComparableRulesList) {
            sortedRulesList.add(c.rule);
            System.debug(System.LoggingLevel.ERROR, '    Entry_Value__c: ' + c.rule.Entry_Value__c.toUpperCase());
        }       
        return sortedRulesList;
    }

}