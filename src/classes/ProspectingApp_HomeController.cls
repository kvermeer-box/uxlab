public class ProspectingApp_HomeController {

    // Custom Setting Constants
    transient private ProspectingApp_Settings__c SETTINGS = ProspectingApp_Settings__c.getInstance('default');
    private final String SOBJECT_STEP_ORDER = SETTINGS.SObject_Step_Order__c;
    
    // Important variables
    public List<String> sObjectStepOrder {get; set;}
    public Map<String, FilterSelection> sObjectMasterKey {get; set;}
    public Boolean releaseTheQuestions {get; set;}
    
    // Current variables
    public String currentPageSObject {get; set;}
    transient public List<String> currentSelectedCheckboxes {get; set;}    
    public List<String> currentAvailableCheckboxes {get; set;}
    public List<ProspectingApp_Question__c> currentRelevantQuestions {get; set;}
    public List<ProspectingApp_Question__c> currentAvailableQuestions {get; set;}
    transient public String currentCheckbox {get; set;}
            
    // Non Custom Setting Constants
    private final String QUESTION_OBJECT_NAME = 'ProspectingApp_Question__c';
    private final String QUESTION_OBJECT_JUNCTION_FIELD_REL_NAME = 'Question__r';
    private final Integer QUESTION_PAGE_SIZE = 10;

    public ProspectingApp_HomeController() {        
        initializeProspectingApp();
    }

    public ApexPages.StandardSetController setCon {    
        get {
            if (setCon == null) {
                setCon = new ApexPages.StandardSetController(currentRelevantQuestions);
                setCon.setPageSize(QUESTION_PAGE_SIZE);
            }
            return setCon;
        }
        set;
    }
    
    public List<ProspectingApp_Question__c> getPaginatedQuestions() {
        return (List<ProspectingApp_Question__c>)setCon.getRecords();
    }
    
    public String getCurrentPageName() {
        return Schema.getGlobalDescribe().get(currentPageSObject).getDescribe().getLabel();
    }
    
    public String getCurrentPageNamePlural() {
        return Schema.getGlobalDescribe().get(currentPageSObject).getDescribe().getLabelPlural();
    }
    
    public String getNextPage() {
        String nextPage;
        Boolean currentPageFound = false;
        for (Integer i = 0; i < sObjectStepOrder.size(); i++) {
            if (currentPageFound) {
                nextPage = Schema.getGlobalDescribe().get(sObjectStepOrder.get(i)).getDescribe().getName();
                break;
            }
            if (currentPageSObject.equals(sObjectStepOrder.get(i)) && i != sObjectStepOrder.size()) {
                currentPageFound = true;
            }
        }
        return nextPage;
    }
    
    public String getPrevPage() {
        String prevPage;
        for (Integer i = 0; i < sObjectStepOrder.size(); i++) {
            System.debug(i + ': ' + currentPageSObject + ', ' + sObjectStepOrder.get(i));
            if (i != 0 && currentPageSObject.equals(sObjectStepOrder.get(i))) {
                prevPage = Schema.getGlobalDescribe().get(sObjectStepOrder.get(i-1)).getDescribe().getName();
                break;
            }
        }
        return prevPage;
    }
    
    public String getNextPageName() {
        String nextPage;
        Boolean currentPageFound = false;
        for (Integer i = 0; i < sObjectStepOrder.size(); i++) {
            if (currentPageFound) {
                nextPage = Schema.getGlobalDescribe().get(sObjectStepOrder.get(i)).getDescribe().getLabel();
                break;
            }
            if (currentPageSObject.equals(sObjectStepOrder.get(i)) && i != sObjectStepOrder.size()) {
                currentPageFound = true;
            }
        }
        return nextPage;
    }        
    
    public String getPrevPageName() {
        String prevPage;
        for (Integer i = 0; i < sObjectStepOrder.size(); i++) {
            if (i != 0 && currentPageSObject.equals(sObjectStepOrder.get(i))) {
                prevPage = Schema.getGlobalDescribe().get(sObjectStepOrder.get(i-1)).getDescribe().getLabel();
                break;
            }
        }
        return prevPage;
    }

    public void initializeProspectingApp() { 
        System.debug('Initializing prospecting app...');
        
        // Set up step order
        if (SOBJECT_STEP_ORDER != null) {
                sObjectStepOrder = SOBJECT_STEP_ORDER.split(';');
                currentPageSObject = sObjectStepOrder[0]; 
                System.debug('Step order: ' + SOBJECT_STEP_ORDER);
        }
         
        // Initialize collections
        sObjectMasterKey = new Map<String, FilterSelection>();
        currentSelectedCheckboxes = new List<String>();
        currentAvailableCheckboxes = new List<String>();
        currentRelevantQuestions = new List<ProspectingApp_Question__c>();
        currentAvailableQuestions = new List<ProspectingApp_Question__c>();
        
        // Standard variables
        releaseTheQuestions = false;
        
        // Set current variables        
        setCurrentVariables();
    }
    
    public void setCurrentVariables() {
        // Set current variables        
        currentAvailableQuestions = sObjectMasterKey.get(getPrevPage()) == null ? null : sObjectMasterKey.get(getPrevPage()).questions.clone();        
        List<ProspectingApp_Question__c> questions = sObjectMasterKey.get(getPrevPage()) == null ? null : sObjectMasterKey.get(getPrevPage()).questions.clone();
        currentAvailableCheckboxes = grabPotentialCheckboxOptionsFromSObject(Schema.getGlobalDescribe().get(currentPageSObject).getDescribe(), questions);
        currentRelevantQuestions = grabRelevantQuestions(Schema.getGlobalDescribe().get(currentPageSObject).getDescribe(), null);             
    }
    
    private List<String> grabPotentialCheckboxOptionsFromSObject(Schema.DescribeSObjectResult dsr, List<ProspectingApp_Question__c> questions) {
        System.debug('Grabbing potential checkbox values from SObject ' + dsr.getName());
        
        String queryString;
        List<String> options = new List<String>();
        
        // Get strings that we will use in our query
        String junctionObjName = grabQuestionJunctionObjectNameAndRelationshipNameFromSObject(dsr.getName())[0];    
        String junctionObjRelationshipFieldName = grabParentFieldNameFromJunctionObj(Schema.getGlobalDescribe().get(junctionObjName).getDescribe(), dsr);
         
        // Build the query
        if (junctionObjName != null && junctionObjRelationshipFieldName != null) {
                queryString = ' SELECT ' 
                                        + '     COUNT(' + flipObjNameToRelationship(junctionObjRelationshipFieldName) + '.Id) number, '
                                        + '     MAX(' + flipObjNameToRelationship(junctionObjRelationshipFieldName) + '.Id) iden, '
                                        + '     ' + flipObjNameToRelationship(junctionObjRelationshipFieldName) + '.Name label '
                                        + ' FROM ' + junctionObjName + ' ';
                                        if (questions != null && questions.size() > 0) {
                                            queryString += ' WHERE ' + QUESTION_OBJECT_JUNCTION_FIELD_REL_NAME + '.Id IN :questions ';
                                        } 
                                        queryString += ' GROUP BY ' + flipObjNameToRelationship(junctionObjRelationshipFieldName) + '.Name ';
                        System.debug('Aggregate soql query string: ' + queryString);
                        List<AggregateResult> aggList = (List<AggregateResult>)Database.query(queryString);
                        
                        // Finally get the checkbox values!
                        if (aggList != null && aggList.size() > 0) {
                                for (AggregateResult r : aggList) {
                                        if (r.get('number') != null && r.get('number') != 0) {                  
                                                // SelectOption op = new SelectOption(String.valueOf(r.get('iden')), String.valueOf(r.get('label')));                      
                                                // options.add(op);
                                                // System.debug('Checkbox added: ' + op.getValue() + ', ' + op.getLabel());
                                                options.add(String.valueOf(r.get('label')));
                                                System.debug('String (checkbox) added: ' + r.get('label'));
                                        }
                                }
                        }  
        }               
        return options;
    }
    
    public void addCurrentSelectedCheckboxes() {
        System.debug('Current checkbox: ' + currentCheckbox);
        
        currentSelectedCheckboxes = new List<String>();
        String value = currentCheckbox;
        currentSelectedCheckboxes.add(value);
        
        // Refresh value
        currentCheckbox = null;
    }
    
    public void grabCurrentRelevantQuestions() {        
        // First get the checkbox
        addCurrentSelectedCheckboxes();
    
        List<ProspectingApp_Question__c> questions = grabRelevantQuestions(Schema.getGlobalDescribe().get(currentPageSObject).getDescribe(), currentSelectedCheckboxes); 
        setCon = new ApexPages.StandardSetController(questions);
        setCon.setPageSize(QUESTION_PAGE_SIZE);   
        
        // Automatically go to next page or release the Kraken!
        if (getNextPage() != null) {
            goToNextPage();
        } else {
            releaseTheQuestions = true;
        }
    }
    
    private List<ProspectingApp_Question__c> grabRelevantQuestions(Schema.DescribeSObjectResult dsr, List<String> checkboxes) {
        System.debug('Grabbing all relevant questions...');     
               
        // Get junction obj relationship name
        String junctionObjName = grabQuestionJunctionObjectNameAndRelationshipNameFromSObject(dsr.getName())[0]; 
        String junctionObjRelationshipName = grabQuestionJunctionObjectNameAndRelationshipNameFromSObject(dsr.getName())[1];
        String junctionObjRelationshipFieldName = flipObjNameToRelationship(grabParentFieldNameFromJunctionObj(Schema.getGlobalDescribe().get(junctionObjName).getDescribe(), dsr));  
        
        List<ProspectingApp_Question__c> newQuestionsList = new List<ProspectingApp_Question__c>();
        if (junctionObjName != null && junctionObjRelationshipName != null && junctionObjRelationshipFieldName != null) {                
            // Get a set of currently selected checkboxes and questions
            Set<String> filterCheckboxes = createCheckboxFilterSet(checkboxes); 
            Set<String> filterQuestions = createQuestionsFilterSet();
                                            
            String queryString;     
            queryString  = ' SELECT Id, Question__c, URL__c, CreatedDate, '
                                     + '    (SELECT Id, Name FROM ' + junctionObjRelationshipName;
                                    if (filterCheckboxes != null && filterCheckboxes.size() > 0) {
                                            queryString += ' WHERE ' + junctionObjRelationshipFieldName + '.Name IN :filterCheckboxes ';               
                                    }                               
            queryString += ' ) '                            
                                     + ' FROM ProspectingApp_Question__c ';
                                    if (filterQuestions != null && filterQuestions.size() > 0) {
                                         queryString += ' WHERE Id IN :filterQuestions ';
                                    } 
            queryString += '        ORDER BY Sort_Order__c DESC NULLS LAST, CreatedDate DESC ';                      
                                     
            System.debug('Soql query string: ' + queryString);    
            System.debug('filterQuestions: ' + String.valueOf(filterQuestions));                   
            List<ProspectingApp_Question__c> unfilteredQuestions = new List<ProspectingApp_Question__c>();
            unfilteredQuestions = (List<ProspectingApp_Question__c>)Database.query(queryString);
                                    
            if (unfilteredQuestions != null && unfilteredQuestions.size() > 0) {                                                         
                for (ProspectingApp_Question__c q : unfilteredQuestions) {
                        if (q.getSObjects(junctionObjRelationshipName) !=  null && q.getSObjects(junctionObjRelationshipName).size() > 0) {
                            newQuestionsList.add(q);
                            // currentRelevantQuestions.add(q);
                        }
                }
                System.debug(newQuestionsList.size() + ' questions added.');
            }                       
        }       
        
        currentRelevantQuestions = newQuestionsList;
        return currentRelevantQuestions;                                
    }    
    
    private Set<String> createCheckboxFilterSet(List<String> checkboxes) {
        // Get a set of currently selected checkboxes
        Set<String> filterCheckboxes = new Set<String>();
        if (checkboxes != null) {
            for (String s : checkboxes) {
                filterCheckboxes.add(s);
            }                               
        }
        System.debug('Current selected checkboxes: ' + String.valueOf(filterCheckboxes));
        return filterCheckboxes;
    }
    
    private Set<String> createQuestionsFilterSet() {
        // Get a set of currently selected checkboxes 
        Set<String> filterQuestions = new Set<String>();
        if (currentAvailableQuestions != null && currentAvailableQuestions.size() > 0) {
            for (ProspectingApp_Question__c q : currentAvailableQuestions) {
                filterQuestions.add(q.Id);
            }
        }        
        System.debug('Current questions set: ' + String.valueOf(filterQuestions));
        return filterQuestions;
    }
    
    private String flipObjNameToRelationship(String objName) {
        String flippedString;
        if (objName != null) {
            flippedString = objName.substring(0, objName.length() - 1) + 'r';
        }    
        return flippedString;
    }    
    
    private String flipObjRelationshipNameToObj(String objName) {
        String flippedString;
        if (objName != null) {
            flippedString = objName.substring(0, objName.length() - 1) + 'c';
        }    
        return flippedString;
    }        
    
    private List<String> grabQuestionJunctionObjectNameAndRelationshipNameFromSObject(String sObjectName) {
        System.debug('Grabbing the name of the junction object between ProspectingApp_Question__c and ' + sObjectName);
        
        List<String> junctionObjNameAndRelationshipName = new List<String>();
        Boolean finalBreak = false;
        
        // Get main obj and children
        Schema.DescribeSObjectResult dsr = Schema.getGlobalDescribe().get(sObjectName).getDescribe();                
        List<Schema.ChildRelationship> children = dsr.getChildRelationships();
        for (Schema.ChildRelationship c : children) {
            if (finalBreak) {
                break;
            }
            // Get fields of children if it is a custom object            
            if (c.getChildSObject().getDescribe().isCustom()) {
                Map<String, Schema.SObjectField> fields = c.getChildSObject().getDescribe().fields.getMap();
                for (String f : fields.keySet()) {                
                    if (finalBreak) {
                        break;
                    }
                    // If a field is a reference to Questions, return the name of the obj
                    Schema.DescribeFieldResult dfr = fields.get(f).getDescribe();
                    if (dfr.getType() == Schema.DisplayType.Reference) {
                        for (Schema.SObjectType t : dfr.getReferenceTo()) {                        
                            if (t.getDescribe().isCustom() && t.getDescribe().getName().equals(QUESTION_OBJECT_NAME)) {
                                junctionObjNameAndRelationshipName.add(c.getChildSObject().getDescribe().getName());
                                junctionObjNameAndRelationshipName.add(c.getRelationshipName());                                
                                finalBreak = true;
                                System.debug('Junction object name found: ' + junctionObjNameAndRelationshipName[0]);
                                System.debug('Junction object relationship name found: ' + junctionObjNameAndRelationshipName[1]);
                                break;
                            }
                        }
                    }
                }            
            }
        }
        return junctionObjNameAndRelationshipName;
    }
    
    private String grabParentFieldNameFromJunctionObj(Schema.DescribeSObjectResult junctionObj, Schema.DescribeSObjectResult parentObj) {
        System.debug('Grabbing the field name for the master-detail relationship between ' + parentObj.getName() + ' and ' + junctionObj.getName() + '...');
        
        String fieldName;
        if (junctionObj != null && parentObj != null) {
        
            // Get all fields from the junction obj
            Map<String, Schema.SObjectField> fields = junctionObj.fields.getMap();            

            // For each field, check if it is a reference to parentObj
            for (String f : fields.keySet()) {
                Schema.DescribeFieldResult dfr = fields.get(f).getDescribe();
                if (dfr.getType() == Schema.DisplayType.Reference) {
                    if (dfr.getReferenceTo().size() == 1) {
                        if (dfr.getReferenceTo()[0].getDescribe().getName().equals(parentObj.getName())) {
                            fieldName = dfr.getName();
                            System.debug('Master-detail relationship field name: ' + fieldName);
                            break;
                        }
                    }
                }
            }
        }
        return fieldName;
    }
    
    public void goToPrevPage() {
        System.debug('Navigating to previous page...');
        
        // Get next page
        currentPageSObject = getPrevPage(); 
        
        // Set new page vars
        setNewPageVariables();
        
        // Check saved checkboxes
        grabPageHistory(); 
    }
    
    private void grabPageHistory() {
        currentSelectedCheckboxes = sObjectMasterKey.get(currentPageSObject).selectedCheckboxes;
        currentRelevantQuestions = sObjectMasterKey.get(currentPageSObject).questions.clone();
        setCon = new ApexPages.StandardSetController(currentRelevantQuestions);
        setCon.setPageSize(QUESTION_PAGE_SIZE); 
    }
    
    public void goToNextPage() {
        System.debug('Navigating to next page...');
                
        // Stamp current available questions
        currentAvailableQuestions = currentRelevantQuestions.clone();
        
        // First store the data of the current page so you can navigate back
        updateMasterKey();        

        // Get next page
        currentPageSObject = getNextPage();        

        // Set new page vars
        setNewPageVariables();

        System.debug('Navigation complete!');        
    }    
    
    private void updateMasterKey() {
        System.debug('Updating the master key...');
        
        FilterSelection fs = new FilterSelection();
        fs.selectedCheckboxes = currentSelectedCheckboxes.clone();
        fs.questions = currentRelevantQuestions.clone();
        sObjectMasterKey.put(currentPageSObject, fs);
        System.debug('New master key stored for ' + currentPageSObject + ': ' + String.valueOf(fs));
    }
    
    public void setNewPageVariables() {
        System.debug('Setting new page variables...');                
        
        // Clear variables
        currentSelectedCheckboxes.clear();
        currentAvailableCheckboxes.clear();
        currentRelevantQuestions.clear();        
    
        // Set current variables
        setCurrentVariables();
    
        System.debug('New page variables are ready.');
    }
    
    public Class FilterSelection {
        public List<String> selectedCheckboxes;
        public List<ProspectingApp_Question__c> questions;
    }        
}