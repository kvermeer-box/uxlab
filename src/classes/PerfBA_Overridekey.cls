/****************************************************************
Class: PerfBA_Overridekey
Description: Box API will invoke this REST web service to update Key.
In order to update the partner key, the existing partner key is provided.
If the new key is unique, the value of the old key is overridden with the new value and a
success message is returned
Author: Nikhil (Perficient) 11/21/2013
*****************************************************************/

@RestResource(urlMapping='/partnerapi/v1.0/overridekey')
global with sharing class PerfBA_Overridekey {
@HttpPost
global static Void doPost() {
RestRequest req = RestContext.request;
RestResponse res = RestContext.response;
String Resbody ;
String jsonInput = req.requestBody.toString();
Map<String,Object> MainMap = (Map<String,Object>)JSON.deserializeUntyped(jsonInput);

list<Partner_Key_Account__c> lopartnerkey = [Select id,Account__c from Partner_Key_Account__c where
														Key__c = :  String.valueOf(MainMap.get('oldpartnerkey')) limit 1 ];

list<Partner_Key_Account__c> lnpartnerkey = [Select id,Account__c from Partner_Key_Account__c where
														Key__c = :  String.valueOf(MainMap.get('newpartnerkey')) limit 1 ];

if(lopartnerkey.isEmpty()){
res.statusCode = 400 ;
resbody = '{"responseCode":"406_Invalid_Old_Partner_Key_Failure","responseMessage":"'+System.Label.X406_Invalid_Partner_Key_Failure+'"}';
res.responseBody = Blob.valueOf(Resbody);
} else if(!lnpartnerkey.isEmpty()){
res.statusCode = 400 ;
resbody = '{"responseCode":"410_New_Partner_Key_duplicate_failure","responseMessage":"'+System.Label.X410_New_PartnerKey_duplicate_failure+'"}';
res.responseBody = Blob.valueOf(Resbody);
} else {
lopartnerkey[0].Key__c=String.valueOf(MainMap.get('newpartnerkey'));
try {
update lopartnerkey;
} catch (Exception e) {
	res.statusCode = 400 ;

	resbody = '{"responseCode":"420_System_Validation/Error","responseMessage":"'+e.getDmlMessage(0)+'"}';
		res.responseBody = Blob.valueOf(Resbody);
			return;
				}
resbody = '{"responseCode":"206_Success","responseMessage":"'+System.Label.X206_Success+'"}';
res.responseBody = Blob.valueOf(Resbody);
}

}
}