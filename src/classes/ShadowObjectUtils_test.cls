@isTest
private class ShadowObjectUtils_test {
    
    @isTest static void testAllTriggers() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Sales_Request__c sr = new Sales_Request__c();
        insert sr;
        update sr;
        delete sr;

        Box_Consulting__c bc = new Box_Consulting__c(Account__c = acc.Id);
        insert bc;
        update bc;
        delete bc;

        Executive_Engagement__c ee = new Executive_Engagement__c();
        insert ee;
        update ee;
        delete ee;

        BoxOut_Request__c bo = new BoxOut_Request__c();
        insert bo;
        update bo;
        delete bo;

        Enterprise_Key_Management__c ekm = new Enterprise_Key_Management__c();
        insert ekm;
        update ekm;
        delete ekm;
    }

    @isTest static void testSalesforceTechnicalIssues() {
        Salesforce_Technical_Issue__c sfti = new Salesforce_Technical_Issue__c(Request_Type__c = 'Cats', Summary_40_character_max__c = 'I won!', How_can_we_help__c = 'Do it for me', Severity__c = 'AMAZING', Status__c = 'Assigned', Completed_Date__c = NULL, Ticket_Duration__c = NULL);
        insert sfti;
        //avoids the case where the number of hours is < 0 which results in NULL previously
        sfti.Status__c = 'Completed';
        update sfti;
        Salesforce_Technical_Issue__c query_sfti = [SELECT Ticket_Duration__c, Completed_Date__c FROM Salesforce_Technical_Issue__c WHERE ID = :sfti.ID];
        System.assertNotEquals(query_sfti.Ticket_Duration__c, NULL);
        System.assertNotEquals(query_sfti.Completed_Date__c, NULL);
        System.assertNotEquals(SalesforceTechnicalIssueTriggerHelper.sfdcBusinessHours, NULL);
        query_sfti.Status__c = 'Assigned';
        update query_sfti;
        System.assertEquals(sfti.Ticket_Duration__c, NULL);
        System.assertEquals(sfti.Completed_Date__c, NULL);
        delete query_sfti;
    }

    @isTest static void testSalesOpsRevenueOpsRequest() {
        RecordType[] rts = [SELECT Id FROM RecordType WHERE SObjectType = 'Sales_Ops_Revenue_Ops_Request__c'];
        Sales_Ops_Revenue_Ops_Request__c request = new Sales_Ops_Revenue_Ops_Request__c(Request_Type__c = 'test', RecordTypeId = rts[0].Id);
        insert request;
        update request;
        delete request;
    }
    
}