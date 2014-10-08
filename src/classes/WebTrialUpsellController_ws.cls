global without sharing class WebTrialUpsellController_ws {

  // Static Variables
  private static List<String> fields_to_sync = null;
  private static String error_string = null;
  private static Boolean error_occured = false;
  private static WebTrialSettings__c web_trial_settings = null;

  // Constants
  private static final String CLONED_OPP_SUFFIX = ' - Web Trial Upsell';
  private static final String WEB_TRIAL_SETTINGS_INSTANCE_NAME = 'default';

  // Error Messages
  private static String NO_FIELD_SET = 'Field Set could not be found';
  private static String NO_FIELDS = 'No Fields in Field Set';
  private static String QUERY_ERROR = 'Trouble querying for an opp';
  private static String ACTIVITY_QUERY_ERROR = 'Trouble Querying for Activities';
  private static String ACTIVITY_DML_ERROR = 'Trouble Inserting/Updating Activities';
  private static String QUERY_CAMPAIGN_MEMBER_ERROR = 'Trouble querying for the campaign member';
  private static String NO_CUSTOM_SETTING = 'No WebTrialSettings custom setting could be found';
  private static String CAMPAIGN_ASSOCIATION_ERROR = 'Issue trying to associate campaign';
  private static String WEB_TRIAL_ALREADY_CLOSED = 'This web trial is over, cannot create a upsell after web trial end date';
  private static String WEB_TRIAL_UPSELL_ALREADY_EXISTS = 'A web trial upsell already exists for this opp, cannot create another!';
  
  public class TrialUpsellReponse {
    public Boolean tur_success;
    public String tur_error_string;
    public String tur_upsell_opp_id;

    public TrialUpsellReponse(String upsell_response_json)
    {
      JSONParser parser = JSON.createParser(upsell_response_json);
      this.tur_success = false;
      this.tur_error_string = null;
      this.tur_upsell_opp_id = null;
      while (parser.nextToken()!=null) 
      {
        if (parser.getCurrentToken() == JSONToken.FIELD_NAME)
        {
          String field_name = parser.getText();
          parser.nextToken();
          if (field_name == 'success')
            this.tur_success = parser.getBooleanValue();
          else if (field_name == 'error_string')
            this.tur_error_string = parser.getText();
          else if (field_name == 'new_opp_id')
            this.tur_upsell_opp_id = parser.getText();
        }
      }
    }

    public String get_error_string()
    {
      return this.tur_error_string;
    }

    public Boolean get_success()
    {
      return this.tur_success;
    }

    public String get_upsell_opp_id()
    {
      return this.tur_upsell_opp_id;
    }
  }

  webservice static String createTrialUpsellOpp(String opp_to_clone_id)
  {
    Opportunity new_upsell_op = null;
    web_trial_settings = WebTrialSettings_cs.getInstance(WEB_TRIAL_SETTINGS_INSTANCE_NAME);
    if (web_trial_settings == null)
    {
      error_string = NO_CUSTOM_SETTING;
      System.debug(NO_CUSTOM_SETTING);
      error_occured = true;
    } else
    {
      Opportunity opp_to_clone = getOpp((Id)opp_to_clone_id);
      if (isUpsellValid(opp_to_clone))
      {
        new_upsell_op = createClonedOppFromBaseOpp(opp_to_clone);
        associateNewOpportunityWithCampaign(opp_to_clone,new_upsell_op);
      }
    }
    return createJSONResponse(new_upsell_op);
  }



  @TestVisible private static List<String> getFieldsToSync()
  {
    // If we have already cached the fields, just return them
    if (fields_to_sync != null) return fields_to_sync;
    Schema.FieldSet field_set = SObjectType.Opportunity.FieldSets.Web_Trial_Upsell;
    // If field_set can't be found, return an error
    if (field_set == null)
    {
      error_string = NO_FIELD_SET;
      System.debug(error_string);
      error_occured = true;
      return null;
    }
    List<Schema.FieldSetMember> field_set_members = field_set.getFields();
    // If the fields on the field set are null or there aren't any fields in the field set, return an error
    if (field_set_members == null || field_set_members.size() == 0)
    {
      error_string = NO_FIELDS;
      System.debug(error_string);
      error_occured = true;
      return null;
    }
    // Otherwise populate the fields_to_sync list
    fields_to_sync = new List<String>();
    for (Schema.FieldSetMember field : field_set_members)
      fields_to_sync.add(field.getFieldPath());
    return fields_to_sync;
  }

  @TestVisible private static Opportunity getOpp(Id opp_id)
  {
    List<String> fields_to_query = getFieldsToSync();
    if (fields_to_query == null) return null;
    // Construct the query, need to grab fields from field set
    String query = 'SELECT ';
    for (String field_to_query : fields_to_query)
      query += field_to_query + ', ';
    query += 'Id, OwnerId, Name, StageName, CloseDate, Originating_Opportunity__c, Upsell_Opportunity__c, ';
    query += 'FCRM__FCR_Response_ID__c, SDR__c, AccountId, RecordTypeId, Account.OwnerId';
    query += ', (Select ContactId, IsPrimary, Role FROM OpportunityContactRoles)';
    query += ' FROM Opportunity WHERE Id = \'' + opp_id + '\' LIMIT 1';
    Opportunity opp_to_clone = null;
    // Execute query
    try
    {
      opp_to_clone= Database.query(query);
    } catch (QueryException e)
    {
      error_string = QUERY_ERROR;
      System.debug(error_string);
      error_occured = true;
      return null;
    }
    return opp_to_clone;
  }

  private static Opportunity createClonedOppFromBaseOpp(Opportunity base_opp)
  {
    if (base_opp == null) return null;
    // STEP 1: Create the new opp with a modified name
    Opportunity new_opp = new Opportunity(Name=base_opp.Name + web_trial_settings.Web_Trial_Upsell_Opp_Name_Suffix__c,
                                          StageName= web_trial_settings.Web_Trial_Upsell_Opp_Stage__c,
                                          CloseDate=Date.today().addDays((Integer)web_trial_settings.Web_trial_upsell_days_to_close__c),
                                          Originating_Opportunity__c=base_opp.Id,
                                          OwnerId=UserInfo.getUserId(),
                                          RecordTypeId=web_trial_settings.Web_Trial_Upsell_Record_Type_Id__c);
    // STEP 2: Sync specified fields
    List<String> sync_fields = getFieldsToSync();
    if (sync_fields == null) return null;
    // Fill in all fields from field set
    for (String field_name : sync_fields)
      new_opp.put(field_name,base_opp.get(field_name));
    // STEP 3: Set Account ID
    new_opp.AccountId = base_opp.AccountId;
    try
    {
      // Insert new opp into database
      insert new_opp;
      // STEP 4: Copy OCRS, Tasks, and Activities
      Boolean copying_ocr_worked = copyOpportunityContactRoles(base_opp,new_opp);
      Boolean moving_activities_worked = moveActivitiesToNewOpp(base_opp,new_opp);
      Boolean moving_qual_notes_worked = moveQualNotesToNewOpp(base_opp, new_opp);
      if (!copying_ocr_worked || !moving_activities_worked) return null;
      // Update fields on base opp
      base_opp.upsell_opportunity__c = new_opp.Id;
      base_opp.SDR_Lookup__c = null;
      base_opp.OBR_Lookup__c = null;
      base_opp.BDR__c = null;
      update base_opp;
    } catch (DMLException e)
    {
      error_string = e.getMessage();
      System.debug(error_string);
      error_occured = true;
      return null;
    }
    return getOpp(new_opp.Id);
  }

  private static Boolean moveActivitiesToNewOpp(Opportunity base_opp, Opportunity new_opp)
  {
    if (base_opp == null || new_opp == null) return false;
    try
    {
      List<Task> tasks = [SELECT Id, whatId 
                          FROM Task
                          WHERE whatId = :base_opp.Id];
      for (Task cur_task : tasks) cur_task.whatId = new_opp.Id;
      if (tasks.size() > 0) update tasks;
      List<Event> events = [SELECT Id, whatId
                            FROM Event
                            WHERE whatId =:base_opp.Id];
      for (Event cur_event : events) cur_event.whatId = new_opp.Id;
      if (tasks.size() > 0) update events;
      return true;
    } catch (QueryException e)
    {
      error_string = ACTIVITY_QUERY_ERROR;
      System.debug(error_string);
      error_occured = true;
      return false;
    } catch (DMLException e)
    {
      error_string = ACTIVITY_DML_ERROR;
      System.debug(error_string);
      error_occured = true;
      return false;
    }
  }

    private static Boolean moveQualNotesToNewOpp(Opportunity base_opp, Opportunity new_opp) {
        if (base_opp == null || new_opp == null) return false;
        try {
            List<Qualification_Note__c> qualNotes = [SELECT Id, Opportunity__c
                                                       FROM Qualification_Note__c
                                                      WHERE Opportunity__c = :base_opp.Id];
            for (Qualification_Note__c currentQualNote : qualNotes) {
                currentQualNote.Opportunity__c = new_opp.Id;
            }
            if (!qualNotes.isEmpty()) {
                update qualNotes;
                
            }
            return true;
        }
        catch (Exception e) {
            error_string = e.getMessage();
            System.debug(error_string);
            error_occured = true;
            return false;
        }
    }

  private static Boolean copyOpportunityContactRoles(Opportunity base_opp, Opportunity new_opp)
  {
    List<OpportunityContactRole> new_ocr_list = new List<OpportunityContactRole>();
    // Create a new, appropriate ocr for the new_opp for each ocr on the base_opp
    for (OpportunityContactRole ocr : base_opp.OpportunityContactRoles)
    {
      OpportunityContactRole new_ocr = new OpportunityContactRole(ContactId=ocr.ContactId,
                                                                  OpportunityId=new_opp.Id,
                                                                  IsPrimary=ocr.IsPrimary,
                                                                  Role=ocr.Role);
      new_ocr_list.add(new_ocr);
    }
    // If empty, just report as a success
    if (new_ocr_list == null || new_ocr_list.size() <= 0)
    {
      return true;
    } else {
      // Otherwise, try to insert the OpportunityContactRoles to the database
      try
      {
        insert new_ocr_list;
      } catch (DMLException e)
      {
        error_string = e.getMessage();
        System.debug(error_string);
        error_occured = true;
        return false;
      }
      return true;
    }
  }

  private static void associateNewOpportunityWithCampaign(Opportunity base_opp, Opportunity new_opp)
  {
    if (base_opp==null|| new_opp==null)
    {
      System.debug('Null arguments provided to associateNewOpportunityWithCampaign!');
      return;
    }
    String response_id = base_opp.FCRM__FCR_Response_ID__c;
    if (response_id!=null)
    {
      // Use current response
      try {
        CampaignMember current_response = [SELECT ContactId, CampaignId, Id 
                                          FROM CampaignMember
                                          WHERE Id = :response_id LIMIT 1];
        Id contact_id = current_response.ContactId;
        Id campaign_id = current_response.CampaignId;
        Boolean association_worked = createCampaignMemberForOpp(new_opp,contact_id,campaign_id);
        // If the association doesn't work, use the default campaign
        if (!association_worked)
        {
          Boolean default_association = createCampaignMemberForOpp(new_opp,getPrimaryContactId(new_opp),web_trial_settings.Web_Trial_Upsell_Default_Campaign_Id__c);
          // If default campaign doesn't work, indicate an error occured
          if (!default_association)
          {
            error_string = CAMPAIGN_ASSOCIATION_ERROR;
            System.debug(error_string);
            error_occured = true;
            return;
          }
        }
      } catch (QueryException e)
      {
        error_string = QUERY_CAMPAIGN_MEMBER_ERROR;
        System.debug(error_string);
        error_occured = true;
        return;
      }
    } else
    {
      // Use default campaign
      Boolean default_association = createCampaignMemberForOpp(new_opp,getPrimaryContactId(new_opp),web_trial_settings.Web_Trial_Upsell_Default_Campaign_Id__c);
          if (!default_association)
          {
            error_string = CAMPAIGN_ASSOCIATION_ERROR;
            System.debug(error_string);
            error_occured = true;
            return;
          }
    }
    
  }

  private static Boolean createCampaignMemberForOpp(Opportunity opp, Id contact_id, Id campaign_id)
  {
    if (opp == null || contact_id == null || campaign_id == null)
    {
      System.debug('Opp: ' + opp);
      System.debug('ContactId: ' + contact_id);
      System.debug('CampaignId: ' + campaign_id);
      System.debug('Null arguments to createCampaignMemberForOpp!');
      return false;
    }
    System.debug('Admin Response Control Code: ' + web_trial_settings.Web_Trial_Upsell_FC_Admin_Code__c);
    CampaignMember new_association = new CampaignMember(FCRM__FCR_Opportunity__c=opp.Id,
                                                        FCRM__FCR_Admin_Response_Control__c=web_trial_settings.Web_Trial_Upsell_FC_Admin_Code__c,
                                                        CampaignId=campaign_id,
                                                        ContactId=contact_id, Status='Responded');
    try
    {
      insert new_association;
    } catch (DMLException e)
    {
      error_string = e.getMessage();
      System.debug(error_string);
      error_occured = true;
      return false;
    }
    return true;
  }

  private static Id getPrimaryContactId(Opportunity opp)
  {
    if (opp == null)
    {
      System.debug('Null opp passed to getPrimaryContactId.');
      return null;
    }
    // Find primary ocr
    for (OpportunityContactRole ocr : opp.OpportunityContactRoles)
    {
      if (ocr.isPrimary)
        return ocr.ContactId;
    }
    // If no primary ocr could be found, return null
    return null;
  }

  private static String createJSONResponse(Opportunity newUpsell)
  {
    String response = '{\n';
    response+= '"success" : ';
    if (error_occured)
      response+= 'false';
    else response += 'true';
    response+=',\n"error_string": ';
    if (error_string==null) response+= '""';
    else response+= '"' + error_string + '"';
    response+=',\n"new_opp_id": ';
    if (newUpsell==null) response+='null';
    else response+='"' + newUpsell.Id + '"';
    response+='\n}';
    return response;
  }

  private static Boolean isUpsellValid(Opportunity opp)
  {
    if (opp == null) return false;
    // Can't create a upsell after trial is over
    if (opp.Trial_End_Date__c < Date.today())
    {
      error_string = WEB_TRIAL_ALREADY_CLOSED;
      System.debug(error_string);
      error_occured = true;
      return false;
    }  // Can't create an upsell if one already exists
    else if (opp.Upsell_Opportunity__c != null)
    {
      error_string = WEB_TRIAL_UPSELL_ALREADY_EXISTS;
      System.debug(error_string);
      error_occured = true;
      return false;
    } else // Finally return true if valid 
        return true;
  }
}