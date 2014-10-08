@isTest
private class WebTrialUpsellController_test {
  
  @isTest(SeeAllData=true) 
  static void testCreateTrialUpsellOpp() {
    FCRM.FCR_SupportAPI.SetRepeatResponseUserForContext();
    String opp_id = createOpportunity();
    Task test_task = new Task(Subject='Test_Task',OwnerId=UserInfo.getUserId(),Status='Completed',WhatId=opp_id);
    insert test_task;

    //START TEST//
    Test.startTest();
    String response = WebTrialUpsellController_ws.createTrialUpsellOpp(opp_id);
    Test.stopTest();
    //END TEST//

    JSONParser parser = JSON.createParser(response);
    Boolean success = false;
    String error_string = null;
    Id upsell_opp_id = null;
    while (parser.nextToken()!=null) 
    {
      if (parser.getCurrentToken() == JSONToken.FIELD_NAME)
      {
        String field_name = parser.getText();
        parser.nextToken();
        if (field_name == 'success')
          success = parser.getBooleanValue();
        else if (field_name == 'error_string')
          error_string = parser.getText();
        else if (field_name == 'new_opp_id')
          upsell_opp_id = parser.getText();
      }
    }
    System.debug(response);
    System.debug('Success: ' + success);
    System.debug('Error String: ' + error_string);
    System.debug('New Opp Id: ' + upsell_opp_id);
    List<String> sync_fields = WebTrialUpsellController_ws.getFieldsToSync();
    Opportunity original_opp = WebTrialUpsellController_ws.getOpp(opp_id);
    System.assertEquals(original_opp.OpportunityContactRoles.size(),1);
    Opportunity upsell_opp = WebTrialUpsellController_ws.getOpp(upsell_opp_id);
    // Business Rule: All Copied fields must match
    for (String field_name : sync_fields)
    {
      if (field_name != 'SDR_Lookup__c' && field_name != 'OBR_Lookup__c' && field_name != 'BDR__c' && field_name != 'FCRM__FCR_Last_Campaign_Touch__c' && field_name != 'FCRM__FCR_First_Campaign_Touch__c')
        System.assertEquals(original_opp.get(field_name),upsell_opp.get(field_name));
    }
    // Business Rule: Close Date --> Today + WebTrialSettings__c.web_trial_upsell_days_to_close__c
    WebTrialSettings__c web_trial_settings = WebTrialSettings_cs.getInstance('default');
    System.assertEquals(upsell_opp.CloseDate,
                        Date.today().addDays((Integer)web_trial_settings.Web_trial_upsell_days_to_close__c));
    // Business Rule: Opp stage --> WebTrialSettings__c.web_trial_upsell_opp_stage__c
    System.assertEquals(upsell_opp.StageName,web_trial_settings.Web_trial_upsell_opp_stage__c);
    // Business Rule: Original_opp.upsell_opportunity__c = upsell_opp.id
    System.assertEquals(original_opp.upsell_opportunity__c,upsell_opp_id);
    // Business Rule: Upsell_opp.originating_opportunity__c = original_opp.id
    System.assertEquals(upsell_opp.originating_opportunity__c,original_opp.id);
    // Business Rule: Delete old SDR, convert
    System.assertEquals(original_opp.SDR_Lookup__c,null);
    //System.assertNotEquals(upsell_opp.SDR_Lookup__c,null);
    // Business Rule: Delete old OBR, convert
    System.assertEquals(original_opp.OBR_Lookup__c,null);
    //System.assertNotEquals(upsell_opp.OBR_Lookup__c,null);
    // Business Rule: Delete old BDR, convert
    System.assertEquals(original_opp.BDR__c,null);
    //System.assertNotEquals(original_opp.BDR__c,null);
    // Business Rule: Set to Record Type from custom setting
    System.assertEquals(web_trial_settings.Web_Trial_Upsell_Record_Type_Id__c,upsell_opp.RecordTypeId);
    // Business Rule: Copy over Tasks and Events
    List<Task> tasks_for_upsell = [SELECT Id,Subject
                                    FROM Task
                                    WHERE whatId=:upsell_opp.Id];
    System.assertEquals(1,tasks_for_upsell.size());
  }
  
  private static Id createOpportunity() {
    Id user= TestDataFactory_hlpr.createUserSimple();
    WebTrialSettings__c web_trial_settings = WebTrialSettings_cs.getInstance('default');
    Opportunity opp = new Opportunity(Name='Test Opp',
                                      StageName='Discovery / Trial',
                                      CloseDate=Date.today().addDays(30),
                                      Trial_Type__c='Testing Trial',
                                      Web_Trial_Upsell__c=false,
                                      Trial_Start_Date__c=Date.today(),
                                      Web_Trial__c=true,
                                      Initial_Trial_Signup__c='uhh',
                                      Trial_End_Date__c=Date.today().addDays(30),
                                      SDR_Lookup__c=user,
                                      OBR_Lookup__c=user,
                                      BDR__c=user
                                      );
    insert opp;
    Contact con = new Contact(LastName='Test Contact');
    insert con;
    OpportunityContactRole ocr = new OpportunityContactRole(ContactId=con.Id,
                                                            OpportunityId=opp.Id,
                                                            IsPrimary=true,
                                                            Role='Business User');
    insert ocr;
    CampaignMember response = new CampaignMember(FCRM__FCR_Opportunity__c=opp.Id,
                                                 FCRM__FCR_Admin_Response_Control__c=web_trial_settings.Web_Trial_Upsell_FC_Admin_Code__c,
                                                 CampaignId=web_trial_settings.Web_Trial_Upsell_Default_Campaign_Id__c,
                                                 ContactId=con.Id, Status='Responded');
    insert response;
    //opp.FCRM__FCR_Response_ID__c = response.Id;
    //update opp;
    return opp.Id;
  }
}