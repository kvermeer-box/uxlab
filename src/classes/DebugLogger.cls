public class DebugLogger {

	public static void write(String component, String detail){

		if(component==null || component.length()==0){
			return;
		}

		if(detail==null || detail.length()==0){
			return;
		}

		try{

			Debug_Log_Settings__c logSettings;
						
			logSettings = Debug_Log_Settings__c.getInstance(component);

			if(logSettings!=null && logSettings.Enabled__c){
				
				Debug_Log__c debugLog = new Debug_Log__c();
				debugLog.Component__c = component;
				debugLog.Detail__c = detail;
				
				insert debugLog;
			}

	 
		}
		catch(Exception ex){ }
	}

}