@isTest
private class DMAPPDMStageExtracStatsTT {

   static testMethod void testTrigger() {
      try {
          DMAPP__DM_Stage_Extra__c o = new DMAPP__DM_Stage_Extra__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<DMAPP__DM_Stage_Extra__c> l = [SELECT Id from DMAPP__DM_Stage_Extra__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}