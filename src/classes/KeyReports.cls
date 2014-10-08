public class KeyReports {    
    
    public Key_Reports_Tab__c[] tabs {
        get {
            if (tabs == null) {
                tabs = [SELECT Id, Display_Name__c, (SELECT Id, Report_Name__c, Report_Description__c, Report_Link__c, Key_Reports_Tab__c
                                                       FROM Key_Reports_Reports__r
                                                   ORDER BY Sort_Order__c)
                          FROM Key_Reports_Tab__c
                      ORDER BY Sort_Order__c ASC];
            }
            return tabs;
        }
        set;
    }

    public String initialTab {
        get {
            // First get the profile name for the running user
            String profileId = UserInfo.getProfileId();
            Profile currentProfile = [SELECT Id, Name FROM Profile WHERE Id = :profileId LIMIT 1];
            String profileName = currentProfile.Name;
            // Use the profile name to query for the mapping
            Key_Reports_Initial_Tab_Mapping__c mapping = null;
            String tabId = null;
            try {
                mapping = [SELECT Id, Key_Reports_Tab__c FROM Key_Reports_Initial_Tab_Mapping__c WHERE Profile__c = :profileName];
                // If we successfully got the mapping, assign the tab to tabId
                if (mapping != null) {
                    tabId = mapping.Key_Reports_Tab__c;
                }
            }
            catch (Exception e) {
                System.debug('No mapping found for profile: ' + profileName);
            }
            // If we did not find a mapping, or the mapping has no tab, make first tab default
            if (mapping == null || tabId == null) {
                if (this.tabs.size() > 0) { // Make sure there is a first tab!
                    tabId = this.tabs[0].Id;
                }
            }
            return tabId;
        }
    }
         

    public KeyReports() {}
}