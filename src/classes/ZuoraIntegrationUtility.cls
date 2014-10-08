/**
 * Utility methods for syncing zuora and SFDC.
 *
 * @author Richard Wu
 * @revision Kyle Vermeer 6/26/2014 Determine EId to Account Mapping using EID on 'Closed Won' Opps instead of EID on Account
 */
public class ZuoraIntegrationUtility {
    @TestVisible static final String SYNC_ERROR_MESSAGE = 'There was an error trying to sync Salesforce accounts with Zuora accounts';
 
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
            Integer batchSize = Integer.valueOf(Zuora_Settings__c.getOrgDefaults().Account_Sync_Batch_Size__c);

            Zuora.zApi.QueryOptions queryOptions = new Zuora.zApi.QueryOptions();
            queryOptions.batchSize = batchSize;
            queryOptions.caseSensitive = true;

            Zuora.zApi.QueryRequest queryRequest = new Zuora.zApi.QueryRequest();
            queryRequest.zoql = zoql;
            queryRequest.queryOptions = queryOptions;

            Zuora.zApi.QueryResult queryResult = zApiInstance.zquery(queryRequest);
            
            return queryResult.records;
        }
                                                                   
        public override List<Zuora.zApi.SaveResult> zupdate(List<Zuora.zObject> zobjects) { return zApiInstance.zupdate(zobjects); }
    }

    public static ZApi zApi = new ZApiReal();

    @future(callout=true)
    public static void linkZuoraAccounts() {
        try {
            zApi.zlogin();

            // get zuora accounts that do not have a crm id but do have an enterprise id
            String zoql = ''
                + ' SELECT Id, CrmId, EnterpriseID__c'
                + ' FROM Account'
                + ' WHERE CrmId =\'\''
                + ' AND Status = \'Active\' AND EnterpriseID__c != \'\'';
            
            List<Zuora.zObject> zobjects = zApi.zquery(zoql);
            
            System.Debug('QueryResult: ' + zobjects.size());
            
            List<Zuora.zObject> changedZobjects = getChangedZobjects(zobjects);
            
            System.Debug('changedZobjects: ' + changedZobjects.size());
            
            if(changedZobjects.isEmpty()) { return; }
            
            List<Zuora.zObject> updateZobjects = new List<Zuora.zObject>();
            List<Zuora.zApi.SaveResult> saveResults;
 
            
            for(Zuora.zObject zObject : changedZobjects){
            	
            	updateZobjects.add(zObject);
            	
            	if(updateZobjects.size()==50){
            	
            		saveResults = zApi.zupdate(updateZobjects);
            		handleZuoraErrors(saveResults);
            	
            		updateZobjects.clear();
            			
            	}
            	
            }

        	if(updateZobjects.size()>0){
        	
        		saveResults = zApi.zupdate(updateZobjects);
        		handleZuoraErrors(saveResults);
        	
        		updateZobjects.clear();
        			
        	}
                    

        
        
        } catch(Exception e) {
            System.Debug('linkZuoraAccounts exception: ' + e);
            throw new LoggedException(e, SYNC_ERROR_MESSAGE, 'ZuoraIntegrationUtility');
        }
    }

    @TestVisible
    static Set<String> zPluckStrings(String field, List<Zuora.zObject> zobjects) {
        Set<String> strings = new Set<String>();

        for(Zuora.zObject zobject : zobjects) {
            String value = (String)zobject.getValue(field);

            if(String.isNotEmpty(value)) { strings.add(value); }
        }

        return strings;
    }

    @TestVisible
    static Map<String, Id> getEntepriseIdToAccountId(Set<String> enterpriseIds) {

        List<Opportunity> opps = [SELECT Box_Enterprise_ID__c, AccountId
                                    FROM Opportunity
                                   WHERE Box_Enterprise_ID__c IN :enterpriseIds];
 
        Map<String, Id> eIdToAccountId = new Map<String, Id>();
 
        for (Opportunity currentOpp : opps) {
            eIdToAccountId.put(currentOpp.Box_Enterprise_ID__c, currentOpp.AccountId);
        }

         
        return eIdToAccountId;
    }

    @TestVisible
    static Map<String, Id> getStringToId(List<Sobject> records, String keyField, String valueField) {
        Map<String, Id> stringToId = new Map<String, Id>();

        for(Sobject record : records) {
            stringToId.put((String)record.get(keyField), (Id)record.get(valueField));
        }

        return stringToId;
    }

    @TestVisible
    static List<Zuora.zObject> getChangedZobjects(List<Zuora.zObject> zobjects) {
    	
        Set<String> enterpriseIds = zPluckStrings('EnterpriseID__c', zobjects);

        Map<String, Id> enterpriseIdToAccountId = getEntepriseIdToAccountId(enterpriseIds);

        List<Zuora.zObject> changedZobjects = new List<Zuora.zObject>();

        for(Zuora.zObject zobject : zobjects) {
            String enterpiseId = (String)zobject.getValue('EnterpriseID__c');
            Id accountId = enterpriseIdToAccountId.get(enterpiseId);

            if(accountId != null) {
                String zuoraId = (String)zobject.getValue('Id');

                Zuora.zObject changedZobject = new Zuora.zObject('Account');
                changedZobject.setValue('Id', zuoraId);
                changedZobject.setValue('CrmId', accountId);

                changedZobjects.add(changedZobject);
            }
        }

        return changedZobjects;
    }

    public class ZuoraUpdateErrorException extends Exception {}

    @TestVisible
    static void handleZuoraErrors(List<Zuora.zApi.SaveResult> saveResults) {
        List<String> errorMessages = new List<String>();
        final String messageFormat = 'Updating a zuora account with the id {0} failed with the code {1} and message {2}';

        for(Zuora.zApi.SaveResult saveResult : saveResults) {
            if(!saveResult.Success) {
                String zuoraId = saveResult.Id;

                for(Zuora.zObject error : saveResult.errors) {
                    String errorCode = (String)error.getValue('Code');
                    String message = (String)error.getValue('Message');

                    String errorMessage = String.format(messageFormat, new List<String>{zuoraId, errorCode, message});
                    errorMessages.add(errorMessage);
                    System.Debug('Error occured, message: ' + message);
                }
            }
        }

        if(!errorMessages.isEmpty()) {
            String exceptionMessage = String.join(errorMessages, '\n');

            throw new ZuoraUpdateErrorException(exceptionMessage);
        }
    }

}