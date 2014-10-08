public class InAppRestSettings_cs {

  // Constant Values Used for Tests
  public static final String BUSINESS_PRICE_BOOK_ENTRY_ID = '01u6000000574Dr';
  public static final String CLOSED_WON_ALREADY_STATUS_CODE = 'closed_won_already';
  public static final String CLOSED_WON_LAST_PAYMENT_STATUSES = 'Processed;Voided';
  public static final String CLOSED_WON_LAST_TRANSACTION_STATUS = 'Approved';
  public static final String CLOSED_WON_OPPORTUNITY_RECORD_TYPE_ID = '012600000009Ur3';
  public static final String CLOSED_WON_PAYMENT_METHOD_TYPE = 'CreditCard';
  public static final String CLOSED_WON_PICKLIST_VALUE = 'Closed Won';
  public static final String CLOSED_WON_STATUS_CODE = 'closed_won';
  public static final String CLOSED_WON_SUBSCRIPTION_STATUS = 'Active';
  public static final String CONTACT_METHOD_MOST_RECENT = 'Business Upgrade';
  public static final String DEFAULT_LEAD_CONVERTED_STATUS = 'Qualified - New Opportunity';
  public static final String DEFAULT_OBJECT_OWNER_ID = '00560000001HN53';
  public static final String EXCLUDED_OPP_STAGES = 'Closed Won';
  public static final String FEE_FREQUENCY_MAPPING = 'Monthly,Monthly;Quarter,Quarterly;Annual,Annual;Semi-Annual,Semi-Annual;Two Years,Two Year Deal;Three Years,Three Year Deal;';
  public static final String INVALID_ZUORA_STATUS_CODE = 'invalid_zuora_status';
  public static final Integer LAST_PAYMENT_AND_EVENT_DATE_DELTA = -1;
  public static final String NO_EMAIL_ADDRESS_STATUS_CODE = 'no_email_address_found';
  public static final String NO_ENTERPRISE_ID_STATUS_CODE = 'no_enterprise_id_found';
  public static final String NO_OPPORTUNITY_STATUS_CODE = 'no_opportunity_found';
  public static final String OPP_NAME_APPEND_TEXT = '-In App Conversion';
  public static final String PRIOR_ACCOUNT_TYPE_MAPPING = 'lite,Lite (Free);individual,Individual ($8);professional,Professional ($20);business,Business;enterprise,Enterprise;dell_lite,Lite (Free);dell_individual,Individual ($8);dell_business,Professional ($20);';
  public static final String SCRIPT_ERROR_STATUS_CODE = 'script_error';
  public static final String CONVERTED_CONTACT_OPP_STAGE = 'Received / Prospecting';
  public static final String LEAD_DISQUALIFIED_STATUS = 'Disqualified';
  public static final String WT_OWNER_ROLES_TO_REASSIGN = 'Sales Development Rep;SDR;';
  public static final String WT_REASSIGN_TO_USER_ID = '00560000001v0ty';
  public static final String DISQUALIFIED_RESPONSE_STATUS_VALUES = 'Disqualified';
  public static final Integer LAST_X_DAYS_RESPONDED = 30;

  public static InAppRestSettings__c getInstance(String instance_name)
  {
    if (!Test.isRunningTest())
    {
      return InAppRestSettings__c.getInstance(instance_name);
    }
    else
    {
      Campaign web_trial_campaign = new Campaign(Name='Web Trial Test Campaign',
                                           Campaign_Type__c='Strategic Initiative',
                                           Time_Period__c='Ongoing',
                                           Audience__c='Paid',
                                           Status='In Progress',
                                           IsActive=true,
                                           FCRM__FCR_Bypass_Nurture_Timeout__c=true,
                                           FCRM__FCR_Repeat_Responses_Allowed__c=true,
                                           FCRM__FCR_Repeat_Response_Timeout_Segments__c='2 Minutes');
      Campaign in_app_campaign = new Campaign(Name='In App Test Campaign',
                                           Campaign_Type__c='Strategic Initiative',
                                           Time_Period__c='Ongoing',
                                           Audience__c='Paid',
                                           Status='In Progress',
                                           IsActive=true,
                                           FCRM__FCR_Bypass_Nurture_Timeout__c=true,
                                           FCRM__FCR_Repeat_Responses_Allowed__c=true,
                                           FCRM__FCR_Repeat_Response_Timeout_Segments__c='2 Minutes');
      List<Campaign> campaign_list = new List<Campaign> {web_trial_campaign,in_app_campaign};
      insert campaign_list;
      InAppRestSettings__c setting = new InAppRestSettings__c(Name=instance_name);
      setting.Business_Price_Book_Entry_Id__c = BUSINESS_PRICE_BOOK_ENTRY_ID;
      setting.Closed_Won_Already_Status_Code__c = CLOSED_WON_ALREADY_STATUS_CODE;
      setting.Closed_Won_Last_Payment_Statuses__c = CLOSED_WON_LAST_PAYMENT_STATUSES;
      setting.Closed_Won_Last_Transaction_Status__c = CLOSED_WON_LAST_TRANSACTION_STATUS;
      setting.Closed_Won_Opportunity_Record_Type_Id__c = CLOSED_WON_OPPORTUNITY_RECORD_TYPE_ID;
      setting.Closed_Won_Payment_Method_Type__c = CLOSED_WON_PAYMENT_METHOD_TYPE;
      setting.Closed_Won_Picklist_Value__c = CLOSED_WON_PICKLIST_VALUE;
      setting.Closed_Won_Status_Code__c = CLOSED_WON_STATUS_CODE;
      setting.Closed_Won_Subscription_Status__c = CLOSED_WON_SUBSCRIPTION_STATUS;
      setting.Contact_Method_Most_Recent__c = CONTACT_METHOD_MOST_RECENT;
      setting.Converted_Contact_Opp_Stage__c = CONVERTED_CONTACT_OPP_STAGE;
      setting.Default_Lead_Converted_Status__c = DEFAULT_LEAD_CONVERTED_STATUS;
      setting.Default_Objects_Owner_Id__c = DEFAULT_OBJECT_OWNER_ID;
      setting.Disqualified_Response_Status_Values__c = DISQUALIFIED_RESPONSE_STATUS_VALUES;
      setting.Excluded_Opp_Stages__c = EXCLUDED_OPP_STAGES;
      setting.Fee_Frequency_Mapping__c = FEE_FREQUENCY_MAPPING;
      setting.Associated_Campaign_ID__c = in_app_campaign.Id;
      setting.Invalid_Zuora_Status_Code__c = INVALID_ZUORA_STATUS_CODE;
      setting.Last_Payment_and_Event_Date_Delta__c = LAST_PAYMENT_AND_EVENT_DATE_DELTA;
      setting.Last_X_Days_Responded__c = LAST_X_DAYS_RESPONDED;
      setting.Lead_Disqualified_Status__c = LEAD_DISQUALIFIED_STATUS;
      setting.No_Email_Address_Status_Code__c = NO_EMAIL_ADDRESS_STATUS_CODE;
      setting.No_Enterprise_Id_Status_Code__c = NO_ENTERPRISE_ID_STATUS_CODE;
      setting.No_Opportunity_Status_Code__c = NO_OPPORTUNITY_STATUS_CODE;
      setting.Opp_Name_Append_Text__c = OPP_NAME_APPEND_TEXT;
      setting.Prior_Account_Type_Mapping__c = PRIOR_ACCOUNT_TYPE_MAPPING;
      setting.Script_Error_Status_Code__c = SCRIPT_ERROR_STATUS_CODE;
      setting.Web_Trial_Campaign_ID__c = web_trial_campaign.Id;
      setting.Web_Trial_Owner_Roles_To_Reassign__c = WT_OWNER_ROLES_TO_REASSIGN;
      setting.Web_Trial_Reassign_To_User_ID__c = WT_REASSIGN_TO_USER_ID;
      upsert setting;
      return setting;
    }
  }
}