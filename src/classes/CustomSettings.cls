/**
 * CustomSettings
 *
 * Description:
 *   This class abstracts away some of the pain of using custom settings, specifically
 *   giving the developer piece of mind when worrying about custom settings in unit tests.
 *
 * Public API:
 *   
 *   static LocationSettings__c getLocationSettings(String instance_name)
 *   static BoxOut_Settings__c getBoxOutSettings(String instance_name)
 *   static External_Services_Settings__c getExternalServicesSettings(String instance_name)
 *   static SalesDivision__c getSalesDivisionSettings(String instance_name)
 *   static Theater__c getTheaterSettings(String instance_name)
 *   static User_Role_Settings__c getUserRoleSettings()
 *   static Quote_Approval_settings__c getQuoteApprovalSettings()
 *   static Country__c getCountrySettings(String instanceName)
 *
 * Revision History:
 *
 *   Kyle Vermeer     1/7/2014      Inital Documentation / Added getUserRoleSettings()
 *   Kyle Vermeer     1/15/2014     Added getQuoteApprovalSettings()
 *   Richard Wu       1/15/2014     Added getCountrySettings(String instanceName) 
 *   Kyle Vermeer     2/25/2014     Updated values for UserRoleSettings
 * @revision Kyle Vermeer 3/21/2014 Added ViewAPICustomSettings
 * @revision Kyle Vermeer 4/3/2014 Added CloneToChurnCustomSettings
 */

public class CustomSettings {
    
    public static LocationSettings__c getLocationSettings(String instance_name)
    {
        if (Test.isRunningTest()) {
            // Specific Constants
            String US_COUNTRY_NAMES = 'USA;US;United States;The United States;Guam;Northern Mariana Islands;Puerto Rico;United States Virgin Islands;The United States of America';
            // Create Setting
            LocationSettings__c sample_setting = new LocationSettings__c(Name=instance_name);
            sample_setting.US_Country_Names__c = US_COUNTRY_NAMES;
            return sample_setting;
        }
        else {
            return LocationSettings__c.getInstance(instance_name);
        }
    }

    public static BoxOut_Settings__c getBoxOutSettings(String instance_name)
    {
        if (Test.isRunningTest()) {
            BoxOut_Settings__c sample_setting = new BoxOut_Settings__c(Name = instance_name);
            sample_setting.BoxOut_Competitors__c = 'Dropbox (consumer);Dropbox For Business;GDrive;Office 365 / Skydrive Pro;Sharepoint on Prem;';
            sample_setting.Button_Text_Invalid_Opp__c = 'Invalid Opp';
            sample_setting.Button_Text_No_Opp__c = 'No Opp';
            sample_setting.Button_Text_Valid_Opp__c = ' Submit!';
            sample_setting.High_Threshold_Amount__c = 25000;
            sample_setting.High_Threshold_Sales_Divisions__c = 'Major;Enterprise;';
            sample_setting.Invalid_Cursor__c = 'not-allowed';
            sample_setting.Low_Threshold_Sales_Divisions__c = 'ESB;Coporate;';
            sample_setting.Low_Threshold_Amount__c = 10000;
            sample_setting.NOT_Accepted_Opp_Stages__c = 'Unresolved;Sales Qualified Opportunity (by SDR);Received / Prospecting;SDR Re-Engagement;Prospecting;Id. Decision Makers;Discovery / Trial;In Trial;';
            sample_setting.Valid_Cursor__c = 'pointer';
            return sample_setting;
        }
        else {
            return BoxOut_Settings__c.getInstance(instance_name);
        }
    }

    public static External_Services_Settings__c getExternalServicesSettings(String instanceName) {
        if (Test.isRunningTest()) {
            External_Services_Settings__c sampleSetting = new External_Services_Settings__c(Name = instanceName);
            sampleSetting.Max_Records_Per_NAICS_Batch__c = 5;
            sampleSetting.NAICS_API_URL__c = 'http://naics.us/v0/q';
            sampleSetting.NAICS_Year__c = '2012';
            return sampleSetting;
        } 
        else {
            return External_Services_Settings__c.getInstance(instanceName);
        }
    }

    public static SalesDivision__c getSalesDivisionSettings(String instanceName) {
        if (Test.isRunningTest()) {
            SalesDivision__c sampleSetting = new SalesDivision__c(Name = instanceName);
            sampleSetting.Grouping__c='ESB;Corporate;Major;Enterprise';
            return sampleSetting;
        }
        else {
            return SalesDivision__c.getInstance(instanceName);
        }
  }

    public static Theater__c getTheaterSettings(String instanceName) {
        if (Test.isRunningTest()) {
            Theater__c sampleSetting = new Theater__c(Name = instanceName);
            sampleSetting.Grouping__c = 'NATAM;EMEA';
            return sampleSetting;
        }
        else {
            return Theater__c.getInstance(instanceName);
        }
    }

    public static User_Role_Settings__c getUserRoleSettings() {
        if (Test.isRunningTest()) {
            User_Role_Settings__c sampleSetting = new User_Role_Settings__c();
            sampleSetting.Segments__c = 'Corporate;Major;Enterprise;ESB;';
            sampleSetting.Theaters__c = 'NATAM;EMEA';
            sampleSetting.Teams__c = 'Central;East;Northeast;Southeast;South;West;Verticals;Federal';
            sampleSetting.SDR_Identifier__c = 'SDR';
            sampleSetting.OBR_Identifier__c = 'OBR';
            sampleSetting.NIR_Identifier__c = 'NIR';
            return sampleSetting;
        }
        else { // Not a test, return custom setting
            return User_Role_Settings__c.getInstance();
        }
    }

    public static Quote_Approval_Settings__c getQuoteApprovalSettings() {
        if (Test.isRunningTest()) {
            Quote_Approval_Settings__c sampleSetting = new Quote_Approval_Settings__c();
            sampleSetting.Payment_Terms_For_Auto_Approve__c = 'Net 30;Due Upon Receipt;';
            sampleSetting.Query_Wildcard_Character__c = '*';
            sampleSetting.Teams_For_Auto_Approve__c = 'Renewals;';
            sampleSetting.Professional_Services_Product_Names__c = 'API Consultation;Content Migration;QuickStart;SmartStart;FullStart - Standard;End User Live Training;Administrator User Live Training;Implementation Live Training;Private Standard End User Training;';
            sampleSetting.Premier_Support_Product_Names__c = 'Service Level Commitment/Premier Support';
            return sampleSetting;
        }
        else {  // Not a test, return custom setting
            return Quote_Approval_Settings__c.getInstance();
        }
    }
    

    public static BoxOutV2_Settings__c getBoxOutV2Settings() {
        if (Test.isRunningTest()) {
            BoxOutV2_Settings__c sampleSetting = new BoxOutV2_Settings__c();
            sampleSetting.Minimum_Opp_Probability__c = 25;
            sampleSetting.BoxOut_Competitors__c = 'Dropbox (consumer);Dropbox for Business;GDrive;Office 365 / Skydrive Pro;Sharepoint on Prem;';
            return sampleSetting;
        }
        else {
            return BoxOutV2_Settings__c.getInstance();
        }
    }
     
    public static View_API_Settings__c getViewAPISettings() {
        if (Test.isRunningTest()) {
            View_API_Settings__c sampleSetting = new View_API_Settings__c();
            sampleSetting.Bulk_Conversion_Price_Factor__c = 0.5;
            return sampleSetting;
        }
        else {
            return View_API_Settings__c.getInstance();
        }
    }

    public static CloneToChurnSettings__c getCloneToChurnSettings() {
        if (Test.isRunningTest()) {
            CloneToChurnSettings__c sampleSetting = new CloneToChurnSettings__c();
            sampleSetting.Inactive_User_Replacement_Id__c = '00560000001FyKaAAK'; // Non-rep user
            sampleSetting.Churn_Opp_Name_Appendage__c = ' Renewal Opp';
            return sampleSetting;
        }
        else {
            return CloneToChurnSettings__c.getInstance();
        }
    }
}