trigger rampStartDate on User (before insert, before update) {
    
    //Initialize the rep's start date and the boolean that determines whether the trigger should run
    Date startDate;
    Boolean runTrigger;
    
    //Initialize the instance's fiscal year start month
    private static final String ORG_ID = '';
    Long FYStartMonth = [Select FiscalYearStartMonth from Organization].FiscalYearStartMonth;
    
    //Declare the rep's start date by taking the user's start date and adding the fudge factor
    for(user u:trigger.new) {
        
        //Checks if a new user is being created
        if(trigger.isInsert) {
        
            //Sets boolean to run trigger and initializes the user's Created Date as now, to avoid a null pointer
            runTrigger = TRUE;
            startDate = date.newInstance(datetime.now().year(),datetime.now().month(),datetime.now().day());
            u.Start_Date__c = datetime.now();
        
        //If a new user is not being created (is being updated)
        } Else {
        
            //Get all of the information about the user prior to the update
            User uBefore = System.Trigger.oldMap.get(u.Id);
            
            //Checks whether the one input that would affect the rep's ramp start date changed
            if(uBefore.Additional_Tenure_Days__c != u.Additional_Tenure_Days__c) {
                
                //Sets boolean to run trigger and initializes the user's Created Date                
                runTrigger = TRUE;
                startDate = date.newInstance(u.CreatedDate.year(),u.CreatedDate.month(),u.CreatedDate.day());
            
            } Else {
            
                runTrigger = FALSE;
            
            }                      
        }
        
        //Determines if trigger should be run based on above conditional
        if(runTrigger == TRUE) {           
        
            //Checks for null pointer on the rep start fudge factor, otherwise does nothing with the field since we won't need it
            if(u.Additional_Tenure_Days__c != NULL) { 
            
                // startDate = startDate.addDays(u.Additional_Tenure_Days__c.intValue());         
            }
    
            //Calculate what month within the quarter the rep's start date is, used for calculation (if not the first month in the qtr, the rep's first full quarter is the subsequent)
            Integer monthInQtr = math.mod(startDate.month() - FYStartMonth.intValue(),3) + 1;

            //Initialize rep's official start quarter as the start date INITIALLY
            u.Ramp_Start_Month__c = date.newInstance(startDate.year(),startDate.month(),1);
            u.Created_Date__c = datetime.newInstance(startDate.year(),startDate.month(),1);
    
            //If the rep's start date is the second month in a quarter
            If(monthInQtr == 2) {
    
                //Add 2 months to get to the start of the next quarter, considered the first full selling quarter
                u.Ramp_Start_Month__c = u.Ramp_Start_Month__c.addMonths(2);
                
                //Subtracts 1 month to get the start of the current quarter, for lead routing normalization
                u.Created_Date__c = u.Created_Date__c.addMonths(-1);
        
            //If the rep's start date is the third month in a quarter
            } Else If(monthInQtr == 3) {
    
                //Add 1 month to get to the start of the next quarter
                u.Ramp_Start_Month__c = u.Ramp_Start_Month__c.addMonths(1);
                
                //Subtracts 2 months to get the start of the current quarter, for lead routing normalization
                u.Created_Date__c = u.Created_Date__c.addMonths(-2);
            }
            
        }
    }
}