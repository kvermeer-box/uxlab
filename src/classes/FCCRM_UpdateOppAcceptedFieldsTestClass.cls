/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class FCCRM_UpdateOppAcceptedFieldsTestClass {

	// Initialize settings
	public static FccrmInternalSettings__c SETTINGS;
	public static String IGNORED_OPP_STAGES;	

    static testMethod void myUnitTest() {
    	
    	// Setting up variables...
    	try {
			SETTINGS = FccrmInternalSettings__c.getInstance('default');
			IGNORED_OPP_STAGES = SETTINGS.AE_Accepted_Fields_Ignored_Stages__c; 
		} catch (Exception e) {
			System.debug('FccrmInternalSettings__c custom settings have not yet been initialized. Killing...');
			return;
		}		
		List<String> unacceptableStages = new List<String>();
		if (IGNORED_OPP_STAGES != null && !IGNORED_OPP_STAGES.equals('')) {
			unacceptableStages = IGNORED_OPP_STAGES.split(';');
		} 
        
        // Test batch inserts
        List<Opportunity> insertList = new List<Opportunity>();
        for (Integer i = 0; i < 5; i++) {
        	Opportunity o = new Opportunity();
        	o.Name = 'Test!';
        	o.CloseDate = Date.today();
        	o.StageName = 'Submit for Approval'; 
        	insertList.add(o);
        }        
        insert insertList;
        
        Set<Id> insertIds = new Set<Id>();
        for (Opportunity insertOpp : insertList) {
        	insertIds.add(insertOpp.Id);
        }
        List<Opportunity> insertedOppsList = [SELECT Id, AE_Accepted_By__c, AE_Accepted_Date__c FROM Opportunity WHERE Id IN :insertIds];
        System.assert(insertedOppsList[(Math.random() * 5).intValue()].AE_Accepted_By__c != null);
        System.assert(insertedOppsList[(Math.random() * 5).intValue()].AE_Accepted_Date__c.isSameDay(Date.today()));
                
        // Test batch updates
        if (unacceptableStages != null && unacceptableStages.size() > 0) {
        	List<Opportunity> insertBadOpps = new List<Opportunity>();
        	for (Integer i = 0; i < 5; i++) {
        		Opportunity o = new Opportunity();
	        	o.Name = 'Test!';
	        	o.CloseDate = Date.today();
	        	o.StageName = unacceptableStages[0]; 
	        	insertBadOpps.add(o);
        	}        
        	insert insertBadOpps;
        	        	
        	List<Opportunity> updateOpps = new List<Opportunity>();        	
            for (Opportunity opp : insertBadOpps) {
            	opp.StageName = 'Submit for Approval';
            	updateOpps.add(opp);
            }    
            update updateOpps;
            
            Set<Id> updateIds = new Set<Id>();
            for (Opportunity updateOpp : updateOpps) {
            	updateIds.add(updateOpp.Id);
            }
            List<Opportunity> updatedOppsList = [SELECT Id, AE_Accepted_By__c, AE_Accepted_Date__c FROM Opportunity WHERE Id IN :updateIds];
            System.assert(updatedOppsList[(Math.random() * 5).intValue()].AE_Accepted_By__c != null);
            System.assert(updatedOppsList[(Math.random() * 5).intValue()].AE_Accepted_Date__c.isSameDay(Date.today()));
        }
    }
}