/**
 * Utility methods for sycning quote values to zuora customer account
 *
 * @author Richard Wu 5/30/14
 *  
 */
  
public with sharing class Z_IntegrationUtility {

	public static final String COUNTRY_UNITED_STATES		= 'United States';
	 
	public abstract class ZApi {
		
		Zuora.zApi zApiInstance;

		public ZApi() { this.zApiInstance = new Zuora.zApi(); }

		public abstract void zlogin();

		public abstract List<Zuora.zObject> zquery(String zoql);

		public abstract List<Zuora.zApi.SaveResult> zupdate(List<Zuora.zObject> zobjects);
	}

	public class ZApiReal extends ZApi {
		
		public ZApiReal() { super(); }

		public override void zlogin() { zApiInstance.zlogin(); }

		public override List<Zuora.zObject> zquery(String zoql) {
			 
			return zApiInstance.zquery(zoql);

		}
                                                                   
		public override List<Zuora.zApi.SaveResult> zupdate(List<Zuora.zObject> zobjects) { return zApiInstance.zupdate(zobjects); }
	}

	public static ZApi zApi = new ZApiReal();
 
	@future(callout=true)
	public static void updateZuoraAccount(Id accountId, String soldToCountry, String zAccountId, String enterpriseId) {
		/* this is called for new subscriptions */
		
		try {
 		
			System.debug('>>>>>>>soldToCountry='+soldToCountry);
			System.debug('>>>>>>>zAccountId='+zAccountId);
			System.debug('>>>>>>>enterpriseId='+enterpriseId);
			
			if(zAccountId==null || (soldToCountry==null && enterpriseId==null)){
				return;
			}

			if(Test.isRunningTest()){

				// do nothing
				
			}else{ 

				zApi.zlogin();

			}
			
			Account acct;
			
			for(Account a : [Select a.Id, a.VAT_ID_Number__c From Account a Where Id =: accountId]){
			
				acct = a;	
				
			} 
			
			
			List<Zuora.zObject> updateZAccounts = new List<Zuora.zObject>();
 
			Zuora.zObject updateZAccount = new Zuora.zObject('Account');
				
			updateZAccount.setValue('Id', zAccountId);
 
 			if(enterpriseId!=null){
				updateZAccount.setValue('EnterpriseID__c', enterpriseId);
 			}
 
 			if(acct!=null && acct.VAT_ID_Number__c!=null){
				updateZAccount.setValue('VATNo__c', acct.VAT_ID_Number__c);
 			}
 
 			if(soldToCountry==null || soldToCountry == COUNTRY_UNITED_STATES){
 				updateZAccount.setValue('Subsidiary__NS', Label.Z_NETSUITE_SUBSIDIARY_US);	
 			}else{
 				updateZAccount.setValue('Subsidiary__NS', Label.Z_NETSUITE_SUBSIDIARY_NON_US);
 			}
 
						
			updateZAccounts.add(updateZAccount);
 
 			List<Zuora.zApi.SaveResult> saveResults;
 
			if(Test.isRunningTest()){

				// do nothing
				
			}else{ 

				saveResults = zApi.zupdate(updateZAccounts);

	 		}
				
			handleZuoraErrors(saveResults);
 	
		} catch(Exception e) {
			throw new LoggedException(e, 'Unable to update Zuora account', 'Z_IntegrationUtility');
		}
	}
 
 

	public class ZuoraUpdateErrorException extends Exception {}

	@TestVisible
	static void handleZuoraErrors(List<Zuora.zApi.SaveResult> saveResults) {
		
		List<String> errorMessages = new List<String>();
		
		final String messageFormat = 'Updating a zuora account with the id {0} failed with the code {1} and message {2}';

		if(saveResults!=null){
			
			for(Zuora.zApi.SaveResult saveResult : saveResults) {
			
				if(!saveResult.Success) {
					String zuoraId = saveResult.Id;
	
					for(Zuora.zObject error : saveResult.errors) {
						String errorCode = (String)error.getValue('Code');
						String message = (String)error.getValue('Message');
	
						String errorMessage = String.format(messageFormat, new List<String>{zuoraId, errorCode, message});
						
						errorMessages.add(errorMessage);
					}
				}
			}
		}

		if(!errorMessages.isEmpty()) {
			
			String exceptionMessage = String.join(errorMessages, '\n');

			throw new ZuoraUpdateErrorException(exceptionMessage);
		}
	}
	
}