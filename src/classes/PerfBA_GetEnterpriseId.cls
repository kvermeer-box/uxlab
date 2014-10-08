/****************************************************************
Class: PerfBA_GetEnterpriseId
Description: Box API will invoke this REST web service to get Enterprise Id for a tenant associated with the
				customer account. The customer account is obtained from object "Partner_Key_Account__c" using the "partner key"
				sent in the input. This is the second call Box API makes in the update transaction
Author: Rucha (Perficient) 11/18/2013
*****************************************************************/
@RestResource(urlMapping='/partnerapi/v1.0/getenterpriseid')
global with sharing class PerfBA_GetEnterpriseId {

	@HttpGet
	global static void getEnterpriseId(){
		//Get the partner key
		RestRequest req = RestContext.request;
		RestREsponse resp = RestContext.response;
		String response='';
		String partnerKey = req.params.get('partnerkey');

		List<Partner_Key_Account__c> partnerAccount = [SELECT Account__c FROM Partner_Key_Account__c WHERE Key__c = :partnerKey];

		JSONGenerator respStr = JSON.createGenerator(FALSE);
		respStr.writeStartObject();

		if(partnerAccount.isEmpty()){
			//return error, partner key not found
			resp.statusCode = 400 ;
			respStr.writeStringField('responseCode', '406_Invalid_Partner_Key_Failure');
			respStr.writeStringField('responseMessage', Label.X406_Invalid_Partner_Key_Failure);
			respStr.writeEndObject();
		}
		else{
			List<Tenant__c> tenant = [SELECT Enterprise_ID_Tenant__c FROM Tenant__c WHERE Account__c = :partnerAccount.get(0).Account__c];

			if(tenant.isEmpty()){
				//Send error
				resp.statusCode = 400 ;
				respStr.writeStringField('responseCode', '409_No_Tenant_For_Customer');
				respStr.writeStringField('responseMessage', Label.X409_No_Tenant_For_Customer);
				respStr.writeEndObject();
			}
			else{
				//Send success
				respStr.writeStringField('responseCode', '205_EnterpriseId_Found');
				respStr.writeStringField('responseMessage', Label.X205_EnterpriseId_Found);
				respStr.writeStringField('Enterprise_Id', tenant.get(0).Enterprise_ID_Tenant__c);
				respStr.writeEndObject();
			}
		}

		//return response;
		respStr.close();
		resp.responseBody = Blob.valueOf(respStr.getAsString());
	}
}