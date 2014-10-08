public without sharing abstract class Box_SyncingObject {
	
	public Box_SyncingObject(sObject s) {
		setSObject(s);
		translate(s);
	}
	
	public Box_SyncingObject(Object o) {
		setObject(o);
	}

	protected sObject updateSObjectSyncing(sObject s, HttpResponse res) {
		System.debug('Updating sync status (success)...');
		if (s != null) {		
			try {			
				s.put('Box_Sync_Status__c', 'Syncing');
				s.put('Box_Last_Synced__c', DateTime.now());
				s.put('Box_Sync_Response_Header__c', res.toString());
				s.put('Box_Sync_Response_Body__c', res.getBody());
				
				// Clear error logs
				s.put('Box_Error_Date_Time__c', null);
				s.put('Box_Sync_Error_Response_Header__c', null);
				s.put('Box_Sync_Error_Response_Body__c', null);
				s.put('Box_Sync_Error__c', null);
				
				ContextControl.preventLooping = true;
				upsert s;
				System.debug('Object updated!');
			} catch (Exception e) {
				throw new LoggedException(e, 'Error saving data to Salesforce. (success): ' + e.getMessage(), 'Box_SyncingObject', new List<Id> {s.Id});
			}
		}
		return s;
	}
	
	protected sObject updateSObjectError(sObject s, Exception e, HttpResponse res) {
		System.debug('Updating sync status (failure)...');		
		if (s != null) {
			try {
				s.put('Box_Sync_Status__c', 'Error');
				s.put('Box_Error_Date_Time__c', DateTime.now());		
				if (res != null) {
					s.put('Box_Sync_Error_Response_Header__c', res.toString());
					s.put('Box_Sync_Error_Response_Body__c', res.getBody());
				} else {
					s.put('Box_Sync_Error_Response_Header__c', null);
					s.put('Box_Sync_Error_Response_Body__c',  null);
				}
				s.put('Box_Sync_Error__c', e.getStackTraceString() + ': ' + e.getMessage());
				
				ContextControl.preventLooping = true;
				upsert s;
				System.debug('Object updated!');
			} catch (Exception ex) {
				throw new LoggedException(ex, 'Error saving data to Salesforce. (error) ' + ex.getMessage(), 'Box_SyncingObject', new List<Id> {s.Id});
			}
		} else {
			System.debug('Object does not exist. We will not update.');
		}
		return s; 
	}
	
	// Object setters
	abstract void setSObject(sObject s);
	abstract void setObject(Object o);	
		
	// Translates sObject to bObject
	abstract Object translate(sObject s);
	abstract sObject unpack(Object o, String s);
	
	// CRUD operations
	abstract sObject create();
	abstract sObject read();
	abstract sObject edit();
	abstract sObject destroy();

}