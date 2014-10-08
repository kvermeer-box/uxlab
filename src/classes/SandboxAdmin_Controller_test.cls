@isTest
private class SandboxAdmin_Controller_test {
    
    @isTest static void testCoverage() {
        // Implement test code
        Sandbox__c newSandbox = new Sandbox__c(Name = 'Sandbox', Description__c = 'Just for Unit Test', Sandbox_Last_Refresh_Date__c = Date.today() );
        insert newSandbox;

        SandboxAdmin_Controller control = new SandboxAdmin_Controller();
        control.getSandboxes();
        SandboxAdmin_Controller.getUsers('k');
        SandboxAdmin_Controller.createSandboxMember('null;kvermeer@box.com;' + newSandbox.Id);
        SandboxAdmin_Controller.sendWarningEmail(newSandbox.Id);
        SandboxAdmin_Controller.refreshSandbox(newSandbox.Id);
    }
    
}