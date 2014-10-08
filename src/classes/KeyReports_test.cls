@isTest
private class KeyReports_test {
    
    @isTest static void basic_test() {
        // Implement test code
        Key_Reports_Tab__c tab = new Key_Reports_Tab__c(Name = 'Account Executives', Display_Name__c = 'Account Executives');
        insert tab;

        KeyReports keyReportsController = new KeyReports();
        Key_Reports_Tab__c[] tabs = keyReportsController.tabs;
        System.assertEquals(tabs.size(), 1, 'There should be exactly 1 tab');
        String initialTab = keyReportsController.initialTab;
        System.assertNotEquals(initialTab, null, 'Initial tab should not be null');
    }
    
    
}