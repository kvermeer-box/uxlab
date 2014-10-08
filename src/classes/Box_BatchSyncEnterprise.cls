global class Box_BatchSyncEnterprise implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts, Schedulable {

	global List<FailureResult> failedUpdates = new List<FailureResult>();	
	
	global void execute(SchedulableContext sc) { 
		Database.executeBatch(new Box_BatchSyncEnterprise(), 1);
	}
	
	private String getTenantQuery() {
		String q = Box_TenantDAO.getQuery();
		q += ' WHERE Enterprise_ID_Tenant__c != null ';
		q += '     AND Admin_Email_Lookup__c != null ';
		return q;
	}
	
	global Database.QueryLocator start(Database.BatchableContext ctx) {		
		String q = getTenantQuery();
		return Database.getQueryLocator(q);
	}
	
	global void execute(Database.BatchableContext ctx, List<sObject> scope) {
		ContextControl.isBatch = true;
		List<Tenant__c> tenants = (List<Tenant__c>)scope;
		for (Tenant__c t : tenants) {
			try {
				Box_SyncingEnterprise b = new Box_SyncingEnterprise(t);
				system.debug('Tenant = '+ t);
				system.debug( String.valueOf( t.Opportunities__r[0].Box_Partner_Account__r.Reseller_ID__c ));
				if( String.valueOf( t.Opportunities__r[0].Box_Partner_Account__r.Reseller_ID__c ) == '3980955827' ){
					//b.read(true);     KV EDIT OUT
					Box_SyncingEnterprise.readFromTenant(t);  // KV ADD IN
				}else{
					//b.read();    KV EDIT OUT
					Box_SyncingEnterprise.readFromTenant(t); // KV ADD IN
				}
			} catch (Exception e) {				
				/*
				FailureResult f = new FailureResult(t, e);
				failedUpdates.add(f);						
				System.debug('====================================='+failedUpdates.size());
				System.debug('====================================='+f.getTenant().Id);
				System.debug('====================================='+f.getTenant().Box_Sync_Error_Response_Body__c);
				// throw e;				
				*/
			}
		}
	} 
	
	global void finish(Database.BatchableContext ctx) {
		AsyncApexJob a = [SELECT Id, ApexClassId, JobItemsProcessed, TotalJobItems, NumberOfErrors, CreatedBy.Email 
							FROM AsyncApexJob
							WHERE Id = :ctx.getJobId()];
		
		// Get a list of errors				
		String errorMessages = '';
		List<Tenant__c> tenantsWithErrors = new List<Tenant__c>();					
		List<Tenant__c> tenants = (List<Tenant__c>)Database.query(getTenantQuery());
		for (Tenant__c t : tenants) {
			if (t.Box_Sync_Error_Response_Body__c != null) {
				// Create a table if needed
				if (tenantsWithErrors.size() == 0) {
					errorMessages += 'Error List: <br /><br />';
					errorMessages += '<table style="border-collapse: collapse;">';
					errorMessages += '	  <tr>';
					errorMessages += '		  <td style="padding: 5px; border: 1px solid black;">';
					errorMessages += '			  <b>Salesforce ID</b>';
					errorMessages += '  	  </td>';
					errorMessages += '	  	  <td style="padding: 5px; border: 1px solid black;">';
					errorMessages += '		  	  <b>Tenant ID</b>';
					errorMessages += '		  </td>';
					errorMessages += '		  <td style="padding: 5px; border: 1px solid black;">';
					errorMessages += '			  <b>Box Error Message</b>';
					errorMessages += '		  </td>';
					errorMessages += '	  </tr>';
				}
				errorMessages += '<tr>';
				errorMessages += '	  <td style="padding: 5px; border: 1px solid black;">';
				errorMessages += 		  t.Id;
				errorMessages += '	  </td>';
				errorMessages += '	  <td style="padding: 5px; border: 1px solid black;">';
				errorMessages += 		  t.Enterprise_ID_Tenant__c;
				errorMessages += '	  </td>';
				errorMessages += '	  <td style="padding: 5px; border: 1px solid black;">';
				errorMessages += 		  t.Box_Sync_Error_Response_Body__c;
				errorMessages += '	  </td>';
				errorMessages += '<tr>';				
				tenantsWithErrors.add(t);
			}
		}
		if (tenantsWithErrors.size() > 0) {
			errorMessages += '</table>';
		}						
							
		// Create email output					
		String emailMessage = 'Your batch job Box_BatchSyncEnterprise has finished. '
							+ 'It executed ' + a.totalJobItems + ' batches, '
							+ 'of which ' + tenantsWithErrors.size() + ' threw unhandled exceptions.<br /><br />';
		emailMessage += errorMessages;
				
		// Send.		
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses(Box_ObjectSyncUtil.generateRecipientsList()); 
		mail.setReplyTo('dliu+prm@box.com');
		mail.setSenderDisplayName('Batch Job Summary');
		mail.setSubject('Box_BatchSyncEnterprise batch summary');
		mail.setPlainTextBody(emailMessage);
		mail.setHtmlBody(emailMessage);
		if (!Test.isRunningTest()) { // Only send e-mail if not testing
			Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
		}
		
	}

	public static testmethod void testBatch() {
		Test.startTest();
		Database.executeBatch(new Box_BatchSyncEnterprise(), 1);
		Test.stopTest();
	}
	
	public class FailureResult {
		Tenant__c tenant;
		Exception error;
		
		public FailureResult(Tenant__c tenant, Exception error) {
			this.tenant = tenant;
			this.error = error;
		}
		
		public Tenant__c getTenant() {
			return tenant;
		}
		
		public String getErrorMessage() {
			return error.getMessage();
		}
	}	
}