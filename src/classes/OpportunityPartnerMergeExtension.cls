/***************************************************************************************************************************************
    Class:          OpportunityPartnerMergeExtension
    
    Description:    Extension for OpportunityPartnerMerge VF pags - retrieves opportunity list and executes merge
    
    Author:         Lior Gotesman                  
     
    Revision Hist:  Lior Gotesman, 04/29/2013,       Initial Version
                                                                                
****************************************************************************************************************************************/

public with sharing class OpportunityPartnerMergeExtension {
    
    public List<Opportunity> oppList {get;set;} 
    public Id oppSelectedId {get;set;} // Id of selected opp, set when user clicks radio button
    private Opportunity inFocusOpp {get;set;}
    private List<OpportunityContactRole> inFocusContact {get; set;}
    private List<CampaignMember> cmsToDelete {get; set;} 
    private List<OpportunityContactRole> oppListContact {get; set;}
    public OpportunityMergeSettings__c oppMergeSetting {get; set;}
    private Map<String, String> mergeMapping {get; set;}
    private String stdId {get; set;}
    
    public OpportunityPartnerMergeExtension(ApexPages.StandardController std) {
        stdId = stdId = String.valueOf(std.getRecord().Id);
        List<OpportunityMergeSettings__c> mappingList = [Select Id, Merge_Rule_Mapping__c, Source_Flag__c, Destination_Flag__c, Concat_Flag__c, Default_Rule__c 
                            From OpportunityMergeSettings__c LIMIT 1];
        system.debug('--------------'+mappingList);
        if(mappingList.size()>0) oppMergeSetting = mappingList[0];
        //comment out hard code merge fields rule
        inFocusOpp = [Select Id, AccountId, Amount, Box_Products__c, CloseDate, Customer_Contact_city__c, Customer_Contact_Email__c,
                        Customer_Contact_First_name__c, Customer_Contact_Last_Name__c, Customer_Contact_Phone__c,
                        Customer_Contact_State__c, Customer_Contact_Street_Address__c, Customer_Contact_Title__c, Customer_Contact_Zip_Code__c,
                        Date_of_first_meeting__c, Deal_reg_expiration_date__c, deal_reg_rejection_reason__c, Partner_submitter_name__c, Sales_rep_channel_only__c,
                        seats_sold__c, tenant_Account_type__c, tenant_enterprise_id__c, trial_end_date__c, Partner_Submitter_Email__c,
                        Partner_Submitter_Phone__c, Why_Box__c, Registration_ID__c, Box_Partner_User__c, Box_Partner_Account__c, FCRM__FCR_Response_ID__c  
                        From Opportunity Where Id = :std.getRecord().Id];
        oppList = [Select Id, Name, Deal_ID__c, Box_Partner_User__c, Box_Partner_Account__c, Not_Subject_to_Merge__c From Opportunity 
            Where AccountId = :inFocusOpp.AccountId and Id != :inFocusOpp.Id
            and Not_Subject_to_Merge__c != 1];
        inFocusContact = [Select Id, ContactId, Role from OpportunityContactRole where OpportunityId = :inFocusOpp.Id and isPrimary = true];
        /*if( oppList != null && !oppList.isEmpty() ) {
            oppListContact = [Select Id, ContactId, Role from OpportunityContactRole where OpportunityId = :oppList.get(0).Id and isPrimary = true];
        }*/
        cmsToDelete = [Select Id from CampaignMember where FCRM__FCR_Opportunity__c =: inFocusOpp.Id];
    }
    
//  Merge selected Opp    
    public PageReference doMerge() {
        //Grab fields to merge from rule map
        String mergeRule = oppMergeSetting.Merge_Rule_Mapping__c;
        List<String> strRules = mergeRule.split('\\|');
        mergeMapping = new Map<String, String>();
        for(String r :strRules){
            List<String> str = r.split(',');
            if(str.size() == 2){
                if(str[1] == oppMergeSetting.Source_Flag__c || str[1] == oppMergeSetting.Concat_Flag__c){
                    mergeMapping.put(str[0],str[1]);    
                }
            }
            else if(str.size() == 1){
                mergeMapping.put(str[0],oppMergeSetting.Default_Rule__c);
            }
        }
        String sqlStr = 'Select Id, AccountId, Box_Partner_User__c';
        if(!mergeMapping.isEmpty()){
            for(String api :mergeMapping.keySet()){
                sqlStr = sqlStr + ', ' + api;
            }
        }
        String accountId = String.valueOf(inFocusOpp.AccountId);
        String sqlList = sqlStr + ' From Opportunity Where IsClosed = false and Registration_ID__c = null and AccountId = :accountId and Id != :stdId and Not_Subject_to_Merge__c != 1';
        sqlStr = sqlStr + ' From Opportunity Where Id = :stdId';
        try{
            inFocusOpp =  Database.query(sqlStr);
            oppList = Database.query(sqlList);
            }
        catch (Exception e) {
            ApexPages.addMessages(e);
        }
        
        System.savepoint sp = Database.setSavepoint();
        for (Opportunity opp : oppList) {
            if (opp.Id == oppSelectedId) {
                try {
                    //opp.Registration_ID__c = inFocusOpp.Registration_ID__c;
                    if(inFocusOpp.Box_Partner_User__c != null){
                        opp.Box_Partner_User__c = inFocusOpp.Box_Partner_User__c;} 
                        else 
                        {opp.Box_Partner_User__c = null;}
                    /*opp.Box_Partner_Account__c = inFocusOpp.Box_Partner_Account__c;
                    opp.Amount = inFocusOpp.Amount;
                    opp.Box_Products__c = inFocusOpp.Box_Products__c;
                    opp.CloseDate = inFocusOpp.CloseDate;
                    opp.Customer_Contact_City__c = inFocusOpp.Customer_Contact_City__c;
                    opp.Customer_Contact_First_Name__c = inFocusOpp.Customer_Contact_First_Name__c;
                    opp.Customer_Contact_Last_Name__c = inFocusOpp.Customer_Contact_Last_Name__c;
                    opp.Customer_Contact_Phone__c = inFocusOpp.Customer_Contact_Phone__c;
                    opp.Customer_Contact_State__c = inFocusOpp.Customer_Contact_State__c;
                    opp.Customer_Contact_Street_Address__c = inFocusOpp.Customer_Contact_Street_Address__c;
                    opp.Customer_Contact_Title__c = inFocusOpp.Customer_Contact_Title__c;
                    opp.Customer_Contact_Zip_Code__c = inFocusOpp.Customer_Contact_Zip_Code__c;
                    opp.Date_of_First_Meeting__c = inFocusOpp.Date_of_First_Meeting__c;
                    opp.Deal_Reg_Expiration_Date__c = inFocusOpp.Deal_Reg_Expiration_Date__c;
                    opp.Deal_Reg_Rejection_Reason__c = inFocusOpp.Deal_Reg_Rejection_Reason__c;
                    opp.Sales_Rep_Channel_only__c = inFocusOpp.Sales_Rep_Channel_only__c;
                    opp.Seats_Sold__c = inFocusOpp.Seats_Sold__c;
                    opp.Trial_End_Date__c = inFocusOpp.Trial_End_Date__c;
                    opp.Partner_Submitter_Email__c = inFocusOpp.Partner_Submitter_Email__c;
                    opp.Partner_Submitter_Name__c = inFocusOpp.Partner_Submitter_Name__c;
                    opp.Partner_Submitter_Phone__c = inFocusOpp.Partner_Submitter_Phone__c;*/
                    for(String api :mergeMapping.keySet()){
                        if(mergeMapping.get(api) == oppMergeSetting.Source_Flag__c){
                            opp.put(api, inFocusOpp.get(api));
                        }
                        else if(mergeMapping.get(api) == oppMergeSetting.Concat_Flag__c){
                            //Code used for field type
                            Map<String, Schema.SObjectField> M;
                            M = Schema.SObjectType.Opportunity.fields.getMap();
                            Schema.SObjectField field = M.get(api);
                            String typeStr = String.valueOf(field.getDescribe().getType());
                            if(typeStr == 'CURRENCY' || typeStr == 'NUMBER' || typeStr == 'DOUBLE'){
                                decimal dS = 0;
                                if(null!=inFocusOpp.get(api))
                                    ds = decimal.valueOf(String.valueOf(inFocusOpp.get(api)));
                                decimal dD = 0;
                                if(null!=opp.get(api))
                                    dD = decimal.valueOf(String.valueOf(opp.get(api)));
                                opp.put(api, dS + dD);
                            }
                            else{
                                String strS = '';
                                String strD = '';
                                if(opp.get(api)!=null)
                                {
                                    strS = String.valueOf(opp.get(api));
                                }
                                if(inFocusOpp.get(api)!=null)
                                {
                                    strD = String.valueOf(inFocusOpp.get(api));
                                }
                                String conStr = '';
                                if(strD!=''&&strS!=''){
                                    conStr = strD + ' ' + strS;
                                }
                                else conStr = strD+strS;
                                opp.put(api, conStr);
                            }
                        }
                    }
                //  Insert Box partner user to opportunity team of new opportunity 
                    if(inFocusOpp.Box_Partner_User__c != null){
                    OpportunityTeamMember otm = new OpportunityTeamMember(
                        OpportunityId  = opp.Id, 
                        TeamMemberRole = 'Partner', 
                        UserId         = inFocusOpp.Box_Partner_User__c);
                        insert otm;} 
                    if(inFocusContact != null && inFocusContact.size() > 0){
                        List<OpportunityContactRole> oppContactRoles = [SELECT Id, ContactId, Role 
                                                                  FROM OpportunityContactRole 
                                                                  WHERE OpportunityId = :opp.Id AND
                                                                  ContactId =: inFocusContact[0].ContactId];

                    OpportunityContactRole ocr = new OpportunityContactRole(
                        OpportunityId = opp.Id,
                        Role          = inFocusContact.get(0).Role,
                        ContactId     = inFocusContact.get(0).ContactId),
                        IsPrimary;
                        if( oppContactRoles == null || oppContactRoles.isEmpty() ){                         
                            insert ocr;
                        }
                    infocusopp.FCRM__FCR_Response_ID__c = null;
                    update infocusopp;
                    //oppListContact.get(0).isPrimary = false;
                    //update oppListContact;
                    }
                    if( cmsToDelete != null && !cmsToDelete.isEmpty() ){
                        for( CampaignMember killCM : cmsToDelete ){
                            killCM.FCRM__FCR_Admin_Response_Control__c = 1;
                            killCM.FCRM__FCR_Opportunity__c = null;
                            killCM.FCRM__FCR_Opportunity_Created_by__c = null;
                            killCM.FCRM__FCR_Response_Status__c = 'Resolved - Already Engaged';
                            killCM.FCRM__FCR_Status_Last_Set__c = system.now();
                            killCM.FCRM__FCR_Dated_Opportunity_Amount__c = null;
                            killCM.Active_Opportunity_Status_Date__c = null;
                            killCM.Attempting_Contact_Status_Date__c = null;
                            killCM.FCRM__FCR_ClosedOpRevenueModel1__c = null;
                            killCM.FCRM__FCR_ClosedOpRevenueModel2__c = null;
                            killCM.FCRM__FCR_ClosedOpRevenueModel3__c = null;
                            killCM.FCRM__FCR_Dated_Opportunity_Amount__c = null;
                            killCM.FCRM__FCR_First_Owner_Assigned__c = null;
                            killCM.FCRM__FCR_First_Owner_Type__c = null;
                            killCM.FCRM__FCR_First_Owner_Worked__c = null;
                            killCM.FCRM__FCR_First_Queue_Assigned__c = null;
                            killCM.First_SLA_Owner__c = null;
                            killCM.FCRM__FCR_QR__c = false;
                            killCM.FCRM__FCR_QR_Date__c = null;
                            killCM.FCRM__FCR_OpenOpRevenueModel1__c = null;
                            killCM.FCRM__FCR_OpenOpRevenueModel2__c = null;
                            killCM.FCRM__FCR_OpenOpRevenueModel3__c = null;
                            killCM.Open_Status_Date__c = null;
                            killCM.FCRM__FCR_Revenue_Timestamp__c = null;
                            killCM.FCRM__FCR_SAR__c = false;
                            killCM.FCRM__FCR_SAR_Date__c = null;
                            killCM.Working_Status_Date__c = null;
                            killCM.Opportunity_Merged__c = true;
                            killCM.FCRM__FCR_SAR_Owner__c = null;
                            killCM.FCRM__FCR_SQR__c = false;
                            killCM.FCRM__FCR_SQR_Date__c = null;
                            killCM.FCRM__FCR_LostOpRevenueModel1__c = null;
                            killCM.FCRM__FCR_LostOpRevenueModel2__c = null;
                            killCM.FCRM__FCR_LostOpRevenueModel3__c = null;
                        }
                    }
                    
                    update cmsToDelete;
                    //insert otm;
                    //Set up new relationship for Sales Requests
                    Sales_Request__c[] srs  = [SELECT Id, Opportunity__c FROM Sales_Request__c WHERE Opportunity__c = :inFocusOpp.Id];
                    if( srs != null && !srs.isEmpty() ){
                        for(Sales_Request__c sr : srs){
                            sr.Opportunity__c = oppSelectedId;
                        }
                    }
                    update srs;
                    
                    //Set up new relationship for Deal Dynamic
                    SE_Notes__c[] dds  = [SELECT Id, Opportunity__c FROM SE_Notes__c WHERE Opportunity__c = :inFocusOpp.Id];
                    if( dds != null && !dds.isEmpty() ){
                        for(SE_Notes__c dd : dds){
                            dd.Opportunity__c = oppSelectedId;
                        }
                    }
                    update dds;
                    
                    //Merge relationship for Activities
                    Task[] tasks = [SELECT Id, Whatid FROM Task WHERE WhatId = :inFocusOpp.Id];
                    if( tasks != null && !tasks.isEmpty() ){
                        for(Task t : tasks){
                            t.Whatid = oppSelectedId;
                        }
                    }
                    Event[] events = [SELECT Id, Whatid FROM Event WHERE WhatId = :inFocusOpp.Id];
                    if( events != null && !events.isEmpty() ){
                        for(Event e : events){
                            e.Whatid = oppSelectedId;
                        }
                    }
                    
                    update tasks;
                    update events;
                    
                    /*Schema.DescribeSObjectResult R = Opportunity.SObjectType.getDescribe();
                    List<Schema.ChildRelationship> cRs = R.getChildRelationships(); 
                    for(Schema.ChildRelationship c :cRs)
                    {
                        String strSQL = 'SELECT Id, '+ c.getField() +' FROM '+ c.getChildSObject() +' WHERE '+ c.getField() +' = :inFocusOpp.Id';
                        sObject[] os = Database.query(strSQL);
                        if( os != null && !os.isEmpty() ){
                            for(sObject o : os){
                                o.put(c.getField(), oppSelectedId);
                            }
                        }
                    }*/
                    
                    
                    delete inFocusOpp;
                    update opp;
                    update oppMergeSetting;
                    
                    return new PageReference('/' + opp.Id); 
                } catch (Exception e) {
                    //undelete inFocusOpp;
                    ApexPages.addMessages(e);  
                    Database.rollBack( sp );            
                }
            } 
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Select Opportunity before merging.'));
        return null;
    }

    public PageReference selectOpp() {
        return null;
    } 
    
    @isTest
    public static void testOpportunityPartnerMergeExtension() {
        Account act = new Account(Name='TestAccount');
        insert act;
        
        OpportunityMergeSettings__c oms = new OpportunityMergeSettings__c(Name = 'testtest', Merge_Rule_Mapping__c = 'Super_Secret_Manager_Notes__c,CONCAT,|Contact_Method_Most_Recent__c,|Theater__c,DESTINATION,|Next_Steps__c,Destination,|Amount,CONCAT,|CloseDate,SOURCE,|Seats_Sold__c,SOURCE,|SI_Partner_Account__c,SOURCE,|Churn_Specifics__c,CONCAT,|Box_Enterprise_ID__c,SOURCE,', Source_Flag__c = 'SOURCE', Destination_Flag__c = 'DESTINATION', Concat_Flag__c = 'CONCAT', Default_Rule__c = 'SOURCE');
        insert oms;

        Opportunity mergeTarget = new Opportunity(CloseDate=Date.Today(), Name = 'op1', StageName='New', AccountId=act.Id, Amount = 1, Super_Secret_Manager_Notes__c = 'testT');
        insert mergeTarget;
        mergeTarget.Deal_Reg_Approval_Status__c = null;
        update mergeTarget;
        
        Opportunity inFocusOpp = new Opportunity(CloseDate=Date.Today(), Name = 'op2', StageName='New', AccountId=act.Id, Amount = 2, Super_Secret_Manager_Notes__c = 'testS');
        insert inFocusOpp;
        
        Campaign c = new Campaign(name = 'TestCTest');
        insert c;
        
        Contact con = new Contact(LastName = 'TestConTest');
        insert con;
        
        CampaignMember cm = new CampaignMember(CampaignId = c.Id, ContactId = con.Id, FCRM__FCR_Opportunity__c = inFocusOpp.Id);
        insert cm;
        
        ApexPages.StandardController std = new ApexPages.StandardController(inFocusOpp);       
        OpportunityPartnerMergeExtension opm = new OpportunityPartnerMergeExtension(std);
        
        system.assertEquals(opm.oppList.size() > 0, true);
        
        opm.selectOpp();
        opm.oppSelectedId = mergeTarget.Id;
        opm.doMerge();  
    }
    
}