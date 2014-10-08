@isTest
private class scheduledTokenRefreshTest{

    static testMethod void test(){
        String CRON_EXP='0 10 * * * ?';
        
        //create Access and Refresh tokens
        Token__c aT = new Token__c();
        aT.Name = 'Access';
        aT.Value__c = '1234';
        insert aT;
        
        Token__c rT = new Token__c();
        rT.Name = 'Refresh';
        rT.Value__c = '1234';
        insert rT;
        
        
        Test.startTest();
        String jobID = System.schedule('ScheduledApexClassTest', CRON_EXP, new scheduledTokenRefresh());
        
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id=:jobID];
        
        System.assertEquals(CRON_EXP, ct.CronExpression);
        
        System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();
        
        //assert new data was committed;
    }
}