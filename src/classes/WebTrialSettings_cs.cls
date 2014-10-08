public class WebTrialSettings_cs {

  // Testing Constants
  private static final String WEB_TRIAL_UPSELL_STAGE = 'Recieved/Prospecting';
  private static final Integer WEB_TRIAL_UPSELL_DAYS_UNTIL_CLOSE = 60;
  private static final String WEB_TRIAL_UPSELL_OPP_NAME_SUFFIX = '- Web Trial Upsell';
  private static final Integer WEB_TRIAL_UPSELL_FCCRM_ADMIN_RESPONSE_CODE = 138;
  private static final String WEB_TRIAL_UPSELL_RECORD_TYPE_ID = '012600000009Uqy';
  
  public static WebTrialSettings__c getInstance(String instance_name)
  {
    if (!Test.isRunningTest() || WebTrialSettings__c.getInstance(instance_name)!=null)
    {
      return WebTrialSettings__c.getInstance(instance_name);
    } else
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
      insert web_trial_campaign;
      WebTrialSettings__c web_trial_settings = new WebTrialSettings__c(Name=instance_name, 
                                                                       Web_Trial_Upsell_Opp_Stage__c= WEB_TRIAL_UPSELL_STAGE,
                                                                       Web_Trial_Upsell_Days_To_Close__c=WEB_TRIAL_UPSELL_DAYS_UNTIL_CLOSE,
                                                                       Web_Trial_Upsell_Opp_Name_Suffix__c=WEB_TRIAL_UPSELL_OPP_NAME_SUFFIX,
                                                                       Web_Trial_Upsell_FC_Admin_Code__c=WEB_TRIAL_UPSELL_FCCRM_ADMIN_RESPONSE_CODE,
                                                                       Web_Trial_Upsell_Default_Campaign_Id__c=web_trial_campaign.Id,
                                                                       Web_Trial_Upsell_Record_Type_Id__c=WEB_TRIAL_UPSELL_RECORD_TYPE_ID);
      upsert web_trial_settings;
      return web_trial_settings;
    }
  }
}