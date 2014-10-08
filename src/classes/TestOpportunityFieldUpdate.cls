@isTest
public class TestOpportunityFieldUpdate {
    static testMethod void OpportunityUpdateTest() {
    String RegId;
    Account Accnt = new Account(Name = 'Accnt1');
    insert Accnt;
    Account BoxResellerAccnt = new Account(Name = 'AccntBoxReseller');
    insert BoxResellerAccnt;
    Contact con1 = new Contact(FirstName = 'test00_FstName', LastName = 'test00_LstName',Email = 'test00a1@test.com', AccountId = Accnt.Id);
    insert con1;
    Opportunity opps = new Opportunity(Name = 'NewOppty1,', StageName = 'Prospecting',  CloseDate=Date.Today()+30,ATTUID__c = '123456',Opportunity_Type__c = 'New',
                                              Registration_ID__c = 'BOX0214192391', AccountId = Accnt.Id, Box_Partner_Account__c = BoxResellerAccnt.Id);
    insert opps;
    RegId = opps.Registration_ID__c;

    OpportunityContactRole insertOpptyConRole = new OpportunityContactRole (
                                                   IsPrimary = true,
                                                   OpportunityId = opps.id,
                                                   Contactid = con1.Id);
    insert  insertOpptyConRole;                                              
    Partner_Key_Account__c upsertPartnerKey = new Partner_Key_Account__c(
                                              Account__c = Accnt.Id, 
                                              Partner__c = BoxResellerAccnt.Id, 
                                              Key__c = '9898989898');
    insert upsertPartnerKey;
    test.startTest();
    PageReference pageRef = Page.DealRegDataUpdate;
    Test.setCurrentPage(pageRef);
    
    OpportunityFieldUpdate controller = new OpportunityFieldUpdate();
    
    controller.searchText =RegId;
    controller.searchText2 = '123456';
    controller.search();
    controller.CTNValue = '510709687';
    controller.save();
                                                                                                 
    test.stopTest(); 
    system.assertEquals(con1.Id, insertOpptyConRole.Contactid);
    system.assertEquals(upsertPartnerKey.Account__c, opps.AccountId);
    system.assertEquals(upsertPartnerKey.Partner__c, opps.Box_Partner_Account__c);    
                                                     
  }
 
    static testMethod void OpportunityUpdateTest2() {
    String RegId;
    Account Accnt = new Account(Name = 'Accnt1');
    insert Accnt;
    Account BoxResellerAccnt = new Account(Name = 'AccntBoxReseller');
    insert BoxResellerAccnt;
    Contact con1 = new Contact(FirstName = 'test00_FstName', LastName = 'test00_LstName',Email = 'test00a1@test.com', AccountId = Accnt.Id);
    insert con1;
    Opportunity opps = new Opportunity(Name = 'NewOppty1,', StageName = 'Prospecting',  CloseDate=Date.Today()+30,ATTUID__c = '123456',Opportunity_Type__c = 'New',
                                              Registration_ID__c = 'BOX0214192391', AccountId = Accnt.Id, Box_Partner_Account__c = BoxResellerAccnt.Id);
    insert opps;
 
    OpportunityContactRole insertOpptyConRole = new OpportunityContactRole (
                                                   IsPrimary = true,
                                                   OpportunityId = opps.id,
                                                   Contactid = con1.Id);
    insert  insertOpptyConRole;
    RegId = opps.Registration_ID__c;
                                                    
    Partner_Key_Account__c upsertPartnerKey = new Partner_Key_Account__c(
                                              Account__c = Accnt.Id, 
                                              Partner__c = BoxResellerAccnt.Id, 
                                              Key__c = '9898989898');
    insert upsertPartnerKey;
    test.startTest();
    PageReference pageRef = Page.DealRegDataUpdate;
    Test.setCurrentPage(pageRef);
    
    OpportunityFieldUpdate controller = new OpportunityFieldUpdate();
    
    controller.searchText =RegId;

    controller.searchText2 = '123456';
    controller.search();
    controller.CTNValue = '0510709687';
    controller.save();
                                                                                                 
    test.stopTest(); 
    system.assertEquals(con1.Id, insertOpptyConRole.Contactid);
    system.assertEquals(upsertPartnerKey.Account__c, opps.AccountId);
    system.assertEquals(upsertPartnerKey.Partner__c, opps.Box_Partner_Account__c);    
                                                     
  }  
    static testMethod void OpportunityUpdateTest3() {
    String RegId;
    Account Accnt = new Account(Name = 'Accnt1');
    insert Accnt;
    Account BoxResellerAccnt = new Account(Name = 'AccntBoxReseller');
    insert BoxResellerAccnt;
    Contact con1 = new Contact(FirstName = 'test00_FstName', LastName = 'test00_LstName',Email = 'test00a1@test.com', AccountId = Accnt.Id);
    insert con1;
    Opportunity opps = new Opportunity(Name = 'NewOppty1,', StageName = 'Closed Won',  CloseDate=Date.Today()+30,ATTUID__c = '123456',Opportunity_Type__c = 'New',
                                              Registration_ID__c = 'BOX0214192391', AccountId = Accnt.Id, Box_Partner_Account__c = BoxResellerAccnt.Id);
    insert opps;
    RegId = opps.Registration_ID__c;

    
    OpportunityContactRole insertOpptyConRole = new OpportunityContactRole (
                                                   IsPrimary = true,
                                                   OpportunityId = opps.id,
                                                   Contactid = con1.Id);
    insert  insertOpptyConRole;
                                                   
    Partner_Key_Account__c upsertPartnerKey = new Partner_Key_Account__c(
                                              Account__c = Accnt.Id, 
                                              Partner__c = BoxResellerAccnt.Id, 
                                              Key__c = '9898989898');
    insert upsertPartnerKey;
    test.startTest();
    system.debug('***Oppty:' +opps);
    PageReference pageRef = Page.DealRegDataUpdate;
    Test.setCurrentPage(pageRef);
    
    OpportunityFieldUpdate controller = new OpportunityFieldUpdate();
    
    controller.searchText =RegId;
    controller.searchText2 = '123456';
    controller.search();
    controller.CTNValue = '0510709687';
    controller.save();
                                                                                                 
    test.stopTest(); 
    system.assertEquals(con1.Id, insertOpptyConRole.Contactid);
    system.assertEquals(upsertPartnerKey.Account__c, opps.AccountId);
    system.assertEquals(upsertPartnerKey.Partner__c, opps.Box_Partner_Account__c);    
                                                     
  }  
/*
   static testMethod void OpportunityUpdateTest4() {
    String RegId;
    Account Accnt = new Account(Name = 'Accnt1');
    insert Accnt;
    Account BoxResellerAccnt = new Account(Name = 'AccntBoxReseller');
    insert BoxResellerAccnt;
    Contact con1 = new Contact(FirstName = 'test00_FstName', LastName = 'test00_LstName',Email = 'test00a1@test.com', AccountId = Accnt.Id);
    insert con1;
    Opportunity opps = new Opportunity(Name = 'NewOppty1,', StageName = 'Prospecting',  CloseDate=Date.Today()+30,ATTUID__c = '123456',Sales_Rep_Channel_only__c = UserInfo.getUserId(),
                                              Registration_ID__c = 'BOX0214192391', AccountId = Accnt.Id, Box_Partner_Account__c = BoxResellerAccnt.Id, Opportunity_Type__c = 'New');
    insert opps;
    RegId = opps.Registration_ID__c;

    
    OpportunityContactRole insertOpptyConRole = new OpportunityContactRole (
                                                   IsPrimary = true,
                                                   OpportunityId = opps.id,
                                                   Contactid = con1.Id);
    insert  insertOpptyConRole;
                                                   
    Partner_Key_Account__c upsertPartnerKey = new Partner_Key_Account__c(
                                              Account__c = Accnt.Id, 
                                              Partner__c = BoxResellerAccnt.Id, 
                                              Key__c = '9898989898');
    insert upsertPartnerKey;
    test.startTest();
    system.debug('***Oppty:' +opps);
    PageReference pageRef = Page.DealRegDataUpdate;
    Test.setCurrentPage(pageRef);
    
    OpportunityFieldUpdate controller = new OpportunityFieldUpdate();
    
    controller.searchText ='123';
    controller.searchText2 = '87676767';
    controller.search();
    controller.CTNValue = '0520709687';
    controller.save();
                                                                                                 
    test.stopTest(); 
    system.assertEquals(con1.Id, insertOpptyConRole.Contactid);
    system.assertEquals(upsertPartnerKey.Account__c, opps.AccountId);
    system.assertEquals(upsertPartnerKey.Partner__c, opps.Box_Partner_Account__c);    
                                                     
  }  */
    static testMethod void OpportunityUpdateTest5() {
    String RegId;
    Account Accnt = new Account(Name = 'Accnt1');
    insert Accnt;
    Account BoxResellerAccnt = new Account(Name = 'AccntBoxReseller');
    insert BoxResellerAccnt;
    Contact con1 = new Contact(FirstName = 'test00_FstName', LastName = 'test00_LstName',Email = 'test00a1@test.com', AccountId = Accnt.Id);
    insert con1;
    Opportunity opps = new Opportunity(Name = 'NewOppty1,', StageName = 'Closed Won',  CloseDate=Date.Today()+30,ATTUID__c = '123456',Opportunity_Type__c = 'New',
                                              Registration_ID__c = 'BOX0214192391', AccountId = Accnt.Id, Box_Partner_Account__c = BoxResellerAccnt.Id);
    insert opps;
    RegId = opps.Registration_ID__c;

    
    OpportunityContactRole insertOpptyConRole = new OpportunityContactRole (
                                                   IsPrimary = true,
                                                   OpportunityId = opps.id,
                                                   Contactid = con1.Id);
    insert  insertOpptyConRole;
                                                   
    Partner_Key_Account__c upsertPartnerKey = new Partner_Key_Account__c(
                                              Account__c = Accnt.Id, 
                                              Partner__c = BoxResellerAccnt.Id, 
                                              Key__c = '9898989898');
    insert upsertPartnerKey;
    test.startTest();
    system.debug('***Oppty:' +opps);
    PageReference pageRef = Page.DealRegDataUpdate;
    Test.setCurrentPage(pageRef);
    
    OpportunityFieldUpdate controller = new OpportunityFieldUpdate();
    
    controller.searchText =RegId;
    controller.searchText2 = '123456';
    controller.search();
    controller.CTNValue = '3530709687';
    controller.save();
                                                                                                 
    test.stopTest(); 
    system.assertEquals(con1.Id, insertOpptyConRole.Contactid);
    system.assertEquals(upsertPartnerKey.Account__c, opps.AccountId);
    system.assertEquals(upsertPartnerKey.Partner__c, opps.Box_Partner_Account__c);    
                                                     
  }  
    static testMethod void OpportunityUpdateTest6() {
    String RegId;
    Account Accnt = new Account(Name = 'Accnt1');
    insert Accnt;
    Account BoxResellerAccnt = new Account(Name = 'AccntBoxReseller');
    insert BoxResellerAccnt;
    Contact con1 = new Contact(FirstName = 'test00_FstName', LastName = 'test00_LstName',Email = 'test00a1@test.com', AccountId = Accnt.Id);
    insert con1;
    Opportunity opps = new Opportunity(Name = 'NewOppty1,', StageName = 'Prospecting',  CloseDate=Date.Today()+30,ATTUID__c = '123456',Opportunity_Type__c = 'New',
                                              Registration_ID__c = 'BOX0214192391', AccountId = Accnt.Id, Box_Partner_Account__c = BoxResellerAccnt.Id);
    insert opps;
    RegId = opps.Registration_ID__c;

    
    OpportunityContactRole insertOpptyConRole = new OpportunityContactRole (
                                                   IsPrimary = true,
                                                   OpportunityId = opps.id,
                                                   Contactid = con1.Id);
                                                   
    insert  insertOpptyConRole;

    test.startTest();
    system.debug('***Oppty:' +opps);
    PageReference pageRef = Page.DealRegDataUpdate;
    Test.setCurrentPage(pageRef);
    
    OpportunityFieldUpdate controller = new OpportunityFieldUpdate();
    
    controller.searchText =RegId;
    controller.searchText2 = '123456';
    controller.search();
    controller.CTNValue = '2540709687';
    controller.save();
                                                                                                 
    test.stopTest(); 
    system.assertEquals(con1.Id, insertOpptyConRole.Contactid);
                                                     
  } 
    static testMethod void OpportunityUpdateTest7() {
    String RegId;
    Account Accnt = new Account(Name = 'Accnt1');
    insert Accnt;
    Account BoxResellerAccnt = new Account(Name = 'AccntBoxReseller');
    insert BoxResellerAccnt;
    Contact con1 = new Contact(FirstName = 'test00_FstName', LastName = 'test00_LstName',Email = 'test00a1@test.com', AccountId = Accnt.Id);
    insert con1;
    Opportunity opps = new Opportunity(Name = 'NewOppty1,', StageName = 'Prospecting',  CloseDate=Date.Today()+30,ATTUID__c = '123456',Opportunity_Type__c = 'New',
                                              Partner_External_ID__c = '2540709687', Registration_ID__c = 'BOX0214192391', AccountId = Accnt.Id, Box_Partner_Account__c = BoxResellerAccnt.Id);
    insert opps;
    RegId = opps.Registration_ID__c;

    
    OpportunityContactRole insertOpptyConRole = new OpportunityContactRole (
                                                   IsPrimary = true,
                                                   OpportunityId = opps.id,
                                                   Contactid = con1.Id);
                                                   
    insert  insertOpptyConRole;

    test.startTest();
    system.debug('***Oppty:' +opps);
    PageReference pageRef = Page.DealRegDataUpdate;
    Test.setCurrentPage(pageRef);
    
    OpportunityFieldUpdate controller = new OpportunityFieldUpdate();
    
    controller.searchText =RegId;
    controller.searchText2 = '123456';
    controller.search();
    controller.InputCTNValue = '2540709687';
    controller.CTNValue = '9550709687';
    controller.save();
    
                                                                                                 
    test.stopTest(); 
    system.assertEquals(con1.Id, insertOpptyConRole.Contactid);
                                                     
  } 

    static testMethod void OpportunityUpdateTest8() {
    String RegId;
    Account Accnt = new Account(Name = 'Accnt1');
    insert Accnt;
    Account BoxResellerAccnt = new Account(Name = 'AccntBoxReseller');
    insert BoxResellerAccnt;
    Contact con1 = new Contact(FirstName = 'test00_FstName', LastName = 'test00_LstName',Email = 'test00a1@test.com', AccountId = Accnt.Id);
    insert con1;
    Opportunity opps = new Opportunity(Name = 'NewOppty1,', StageName = 'Prospecting',  CloseDate=Date.Today()+30,ATTUID__c = '123456',Opportunity_Type__c = 'New',
                                              Partner_External_ID__c = '2540709687', Registration_ID__c = 'BOX0214192391', AccountId = Accnt.Id, Box_Partner_Account__c = BoxResellerAccnt.Id);
    insert opps;
    RegId = opps.Registration_ID__c;

    
    OpportunityContactRole insertOpptyConRole = new OpportunityContactRole (
                                                   IsPrimary = true,
                                                   OpportunityId = opps.id,
                                                   Contactid = con1.Id);
                                                   
    insert  insertOpptyConRole;
    
    Partner_Key_Account__c upsertPartnerKey = new Partner_Key_Account__c(
                                          Account__c = Accnt.Id, 
                                          Partner__c = BoxResellerAccnt.Id, 
                                          Key__c = '9898989898');
    insert upsertPartnerKey;

    test.startTest();
    system.debug('***Oppty:' +opps);
    PageReference pageRef = Page.DealRegDataUpdate;
    Test.setCurrentPage(pageRef);
    
    OpportunityFieldUpdate controller = new OpportunityFieldUpdate();
    
    controller.searchText =RegId;
    controller.searchText2 = '123456';
    controller.search();
    controller.InputCTNValue = '2540709687';
    controller.CTNValue = '9550709687';
    controller.save();
    
                                                                                                 
    test.stopTest(); 
    system.assertEquals(con1.Id, insertOpptyConRole.Contactid);
                                                     
  } 
    static testMethod void OpportunityUpdateTest9() {
    String RegId;
    Account Accnt = new Account(Name = 'Accnt1');
    insert Accnt;
    Account BoxResellerAccnt = new Account(Name = 'AccntBoxReseller');
    insert BoxResellerAccnt;
    Contact con1 = new Contact(FirstName = 'test00_FstName', LastName = 'test00_LstName',Email = 'test00a1@test.com', AccountId = Accnt.Id);
    insert con1;
    Opportunity opps = new Opportunity(Name = 'NewOppty1,', StageName = 'Prospecting',  CloseDate=Date.Today()+30,ATTUID__c = '123456',Opportunity_Type__c = 'New',
                                              Partner_External_ID__c = '2540709687', Registration_ID__c = 'BOX0214192391', AccountId = Accnt.Id, Box_Partner_Account__c = BoxResellerAccnt.Id);
    insert opps;
    RegId = opps.Registration_ID__c;

    OpportunityContactRole insertOpptyConRole = new OpportunityContactRole (
                                                   IsPrimary = true,
                                                   OpportunityId = opps.id,
                                                   Contactid = con1.Id);
                                                   
    insert  insertOpptyConRole;
    
    Partner_Key_Account__c upsertPartnerKey = new Partner_Key_Account__c(
                                          Account__c = Accnt.Id, 
                                          Partner__c = BoxResellerAccnt.Id, 
                                          Key__c = '9898989898');
    insert upsertPartnerKey;

    test.startTest();
    system.debug('***Oppty:' +opps);
    PageReference pageRef = Page.DealRegDataUpdate;
    Test.setCurrentPage(pageRef);
    
    OpportunityFieldUpdate controller = new OpportunityFieldUpdate();
    
    controller.searchText =RegId;
    controller.searchText2 = '123456';
    controller.search();
    controller.InputCTNValue = '2540709687';
    controller.CTNValue = '9550709687';
    controller.save();
    
                                                                                                 
    test.stopTest(); 
    system.assertEquals(Accnt.Id, opps.AccountId);
    system.assertEquals(BoxResellerAccnt.Id, opps.Box_Partner_Account__c);    
                                                     
  } 
    static testMethod void OpportunityUpdateTest10() {
    String RegId;
    Account Accnt = new Account(Name = 'Accnt1');
    insert Accnt;
    Account BoxResellerAccnt = new Account(Name = 'AccntBoxReseller');
    insert BoxResellerAccnt;
    Contact con1 = new Contact(FirstName = 'test00_FstName', LastName = 'test00_LstName',Email = 'test00a1@test.com', AccountId = Accnt.Id);
    insert con1;
    Opportunity opps = new Opportunity(Name = 'NewOppty1,', StageName = 'Prospecting',  CloseDate=Date.Today()+30,ATTUID__c = '123456',Opportunity_Type__c = 'New',
                                              Partner_External_ID__c = '2540709687', Registration_ID__c = 'BOX0214192391', AccountId = Accnt.Id, Box_Partner_Account__c = BoxResellerAccnt.Id);
    insert opps;
    RegId = opps.Registration_ID__c;

    
    OpportunityContactRole insertOpptyConRole = new OpportunityContactRole (
                                                   IsPrimary = true,
                                                   OpportunityId = opps.id,
                                                   Contactid = con1.Id);
                                                   
    insert  insertOpptyConRole;
    
    Partner_Key_Account__c upsertPartnerKey = new Partner_Key_Account__c(
                                          Account__c = Accnt.Id, 
                                          Partner__c = BoxResellerAccnt.Id, 
                                          Key__c = '9898989898');
    insert upsertPartnerKey;

    test.startTest();
    system.debug('***Oppty:' +opps);
    PageReference pageRef = Page.DealRegDataUpdate;
    Test.setCurrentPage(pageRef);
    
    OpportunityFieldUpdate controller = new OpportunityFieldUpdate();
    
    controller.searchText =RegId;
    controller.searchText2 = '123456';
    controller.search();
    controller.InputCTNValue = '1540709687';
    controller.CTNValue = '0550709687';
    controller.save();
    
                                                                                                 
    test.stopTest(); 
    system.assertEquals(con1.Id, insertOpptyConRole.Contactid);
                                                    
  }    
    //----duplicate Account Primary key 
    static testMethod void OpportunityUpdateTest11() {
    String RegId;
    Account Accnt = new Account(Name = 'Accnt1');
    insert Accnt;
    Account Accnt2 = new Account(Name = 'Accnt2');
    insert Accnt2;    
    Account BoxResellerAccnt = new Account(Name = 'AccntBoxReseller');
    insert BoxResellerAccnt;
    Account BoxResellerAccnt2 = new Account(Name = 'AccntBoxReseller2');
    insert BoxResellerAccnt2;    
    Contact con1 = new Contact(FirstName = 'test00_FstName', LastName = 'test00_LstName',Email = 'test00a1@test.com', AccountId = Accnt.Id);
    insert con1;
    Opportunity opps = new Opportunity(Name = 'NewOppty1,', StageName = 'Prospecting',  CloseDate=Date.Today()+30,ATTUID__c = '123456',Opportunity_Type__c = 'New',
                                              Registration_ID__c = 'BOX0214192391', AccountId = Accnt.Id, Box_Partner_Account__c = BoxResellerAccnt.Id);
    insert opps;
    RegId = opps.Registration_ID__c;

    OpportunityContactRole insertOpptyConRole = new OpportunityContactRole (
                                                   IsPrimary = true,
                                                   OpportunityId = opps.id,
                                                   Contactid = con1.Id);
    insert  insertOpptyConRole;                                              
   
    test.startTest();
    PageReference pageRef = Page.DealRegDataUpdate;
    Test.setCurrentPage(pageRef);
    
    OpportunityFieldUpdate controller = new OpportunityFieldUpdate();
    
    controller.searchText =RegId;
    controller.searchText2 = '123456';
    controller.search();
    controller.CTNValue = '510709687';
    controller.save();
                                                                                                 
    test.stopTest(); 
    system.assertEquals(con1.Id, insertOpptyConRole.Contactid);
   
  }
   	//--Insert new contact
    static testMethod void OpportunityUpdateTest13() {
    String RegId;
    Account Accnt = new Account(Name = 'Accnt1');
    insert Accnt;
    Account Accnt2 = new Account(Name = 'Accnt2');
    insert Accnt2;    
    Account BoxResellerAccnt = new Account(Name = 'AccntBoxReseller');
    insert BoxResellerAccnt;
    Account BoxResellerAccnt2 = new Account(Name = 'AccntBoxReseller');
    insert BoxResellerAccnt2;    
/*    Contact con1 = new Contact(FirstName = 'test00_FstName', LastName = 'test00_LstName',Email = 'test00a1@test.com', AccountId = Accnt.Id);
    insert con1; */
    Opportunity opps = new Opportunity(Name = 'NewOppty1,', StageName = 'Prospecting',  CloseDate=Date.Today()+30,ATTUID__c = '123456',Opportunity_Type__c = 'New',
                                              Registration_ID__c = 'BOX0214192391', AccountId = Accnt.Id, Box_Partner_Account__c = BoxResellerAccnt.Id);
    insert opps;
 //   RegId = opps.Registration_ID__c;

/*
    OpportunityContactRole insertOpptyConRole = new OpportunityContactRole (
                                                   IsPrimary = true,
                                                   OpportunityId = opps.id,
                                                   Contactid = con1.Id);
    insert  insertOpptyConRole;    */                                          
    Partner_Key_Account__c upsertPartnerKey1 = new Partner_Key_Account__c(
                                              Account__c = Accnt.Id, 
                                              Partner__c = BoxResellerAccnt.Id, 
                                              Key__c = '9898989898');
    insert upsertPartnerKey1;

    test.startTest();
    PageReference pageRef = Page.DealRegDataUpdate;
    Test.setCurrentPage(pageRef);
    
    OpportunityFieldUpdate controller = new OpportunityFieldUpdate();
    
    controller.searchText ='BOX0214192391';
    controller.searchText2 = '123456';
    controller.search();
    controller.CTNValue = '510709687';
    controller.save();
                                                                                                 
    test.stopTest(); 
    system.assertEquals(Accnt.Id, opps.AccountId);
   
  }
   static testMethod void OpportunityUpdateTestBRSI() {
    String RegId;
    Account Accnt = new Account(Name = 'Accnt1');
    insert Accnt;
    Account Accnt2 = new Account(Name = 'Accnt2');
    insert Accnt2;    
    Account BoxResellerAccnt = new Account(Name = 'AccntBoxReseller');
    insert BoxResellerAccnt;
    Account BoxResellerAccnt2 = new Account(Name = 'AccntBoxReseller2',SI_Partner_Account__c=true);
    insert BoxResellerAccnt2;    
    Contact con1 = new Contact(FirstName = 'test00_FstName', LastName = 'test00_LstName',Email = 'test00a1@test.com', AccountId = Accnt.Id);
    insert con1;
    Opportunity opps = new Opportunity(Name = 'NewOppty1,', StageName = 'Prospecting',  CloseDate=Date.Today()+30,ATTUID__c = '123456',Opportunity_Type__c = 'New',
                                              Registration_ID__c = 'BOX0214192391', AccountId = Accnt.Id, Box_Partner_Account__c = BoxResellerAccnt.Id);
    insert opps;
    opps.Service_Partner_Account__c=BoxResellerAccnt2.id;
    opps.StageName='Closed Won';
    
    update opps;
                                        
    
  }
  
  static testMethod void OpportunityUpdateTestBRSI2() {
    String RegId;
    Account Accnt = new Account(Name = 'Accnt1');
    insert Accnt;
    Account Accnt2 = new Account(Name = 'Accnt2');
    insert Accnt2;    
    Account BoxResellerAccnt = new Account(Name = 'AccntBoxReseller');
    insert BoxResellerAccnt;
    Account BoxResellerAccnt2 = new Account(Name = 'AccntBoxReseller2',SI_Partner_Account__c=true);
    insert BoxResellerAccnt2;    
    Contact con1 = new Contact(FirstName = 'test00_FstName', LastName = 'test00_LstName',Email = 'test00a1@test.com', AccountId = Accnt.Id);
    insert con1;
    Opportunity opps = new Opportunity(Name = 'NewOppty1,', StageName = 'Prospecting',  CloseDate=Date.Today()+30,ATTUID__c = '123456',Opportunity_Type__c = 'New',
                                              Registration_ID__c = 'BOX0214192391', AccountId = Accnt.Id);
    insert opps;
    opps.Service_Partner_Account__c=BoxResellerAccnt2.id;
     opps.Box_Partner_Account__c = BoxResellerAccnt.Id;
    update opps;
                                        
    
  }
}