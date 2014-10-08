@isTest
public with sharing class TestReferralleadExtension {
	
	static testmethod void saveLeadTest1(){
         
         // populate a lead
         Lead l = new Lead(company='testcompany',lastname='testln');
         test.starttest();
 
 	// instantiate a controller extension
         ReferralleadExtension  ext = new ReferralleadExtension(new ApexPages.StandardController(l));
		// call the saveLead method 
		PageReference p = ext.saveLead();
         test.stoptest();
        
     }
     
		static testmethod void saveLeadTest2(){
         
         // populate a lead
         Lead l = new Lead(company='testcompany',lastname='testln',Previously_Worked_With__c='No');
         test.starttest();
 
 	// instantiate a controller extension
         ReferralleadExtension  ext = new ReferralleadExtension(new ApexPages.StandardController(l));
		// call the saveLead method 
		PageReference p = ext.saveLead();
         test.stoptest();
        
     }
     static testmethod void saveLeadTest3(){
         
         // populate a lead
         Lead l = new Lead(company='testcompany',Previously_Worked_With__c='No');
         test.starttest();
 
 	// instantiate a controller extension
         ReferralleadExtension  ext = new ReferralleadExtension(new ApexPages.StandardController(l));
		// call the saveLead method 
		PageReference p = ext.saveLead();
         test.stoptest();
        
     }
     

}