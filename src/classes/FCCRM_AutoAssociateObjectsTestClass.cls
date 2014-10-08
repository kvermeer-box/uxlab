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
private class FCCRM_AutoAssociateObjectsTestClass {

	// Generic settings
	public static FccrmInternalSettings__c settings;	
	
	// Data.com settings
	public static String DATACOM_CAMPAIGN_ID;
	public static String DATACOM_LEAD_SOURCE;
	
	// DiscoverOrg settings
	public static String DISCOVERORG_CAMPAIGN_ID;
	public static String DISCOVERORG_API_USER_ID;	

    static testMethod void myUnitTest() {
        try {
		settings                = FccrmInternalSettings__c.getInstance('default');
		DATACOM_CAMPAIGN_ID     = settings.Data_com_Campaign_Id__c;
		DATACOM_LEAD_SOURCE     = settings.Data_com_Lead_Source__c;
		DISCOVERORG_CAMPAIGN_ID = settings.DiscoverOrg_Campaign_Id__c;
		DISCOVERORG_API_USER_ID = settings.DiscoverOrg_API_User_Id__c;
		} catch (Exception e) {
			System.debug('FccrmInternalSettings__c not yet initialized. Killing...');
			return;
		}
		
		// Setting the user to run the test as
		User u;
		if (DISCOVERORG_API_USER_ID != null) {
			u = new User(Id = DISCOVERORG_API_USER_ID);
		} else {
			u = new User(Id = UserInfo.getUserId());
		}
		
		System.runAs(u) {
			
			List<Lead> insertLeads = new List<Lead>();
			List<Contact> insertContacts = new List<Contact>();
			
			// Data.com lead test
			for (Integer i = 0; i < 100; i++) {
				Lead l = new Lead();
				l.LastName = 'Joe';
				l.Company = 'Blow';
				l.Country = 'United States';
				if (DATACOM_LEAD_SOURCE != null) {
					l.LeadSource = DATACOM_LEAD_SOURCE;
				}
				insertLeads.add(l);
			}
			
			// DiscoverOrg lead test
			for (Integer i = 0; i < 100; i++) {
				Lead l = new Lead();
				l.LastName = 'Joe';
				l.Company = 'Blow';
				l.LeadSource = null;
				l.Country = 'United States';
				insertLeads.add(l);
			}
			
			Account a = new Account();
			a.BillingCountry = 'United States';
			a.Name = 'Hi';
			insert a;
			
			// Data.com contact test
			for (Integer i = 0; i < 100; i++) {
				Contact c = new Contact();
				c.AccountId = a.Id;
				c.LastName = 'Pirate';
				if (DATACOM_LEAD_SOURCE != null) {
					c.LeadSource = DATACOM_LEAD_SOURCE;
					insertContacts.add(c);
				}
			}
			
			// DiscoverOrg contact test
			for (Integer i = 0; i < 100; i++) {
				Contact c = new Contact();
				c.AccountId = a.Id;
				c.LastName = 'Pirate';
				insertContacts.add(c);
			}			
			
			insert insertLeads;
			insert insertContacts;			
		}
		
    }
}