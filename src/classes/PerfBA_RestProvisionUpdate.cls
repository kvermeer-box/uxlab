/****************************************************************
Class: PerfBA_RestProvisionUpdate
Description: Box API will invoke this REST web service to update Enterprise ID in tenant.
The partner API will provision the enterprise once the SFDC flow exits
and make a callback to update the enterprise ID on the SFDC tenant record.
Post Method will update opportunity and tenant.
Author: Nikhil (Perficient) 11/21/2013
*****************************************************************/
@RestResource(urlMapping='/partnerapi/v1.0/provision/update')
global with sharing class PerfBA_RestProvisionUpdate {
@HttpPost
global static Void doPost() {
RestRequest req = RestContext.request;
RestResponse res = RestContext.response;
String Resbody ;
String jsonInput = req.requestBody.toString();
Map<String,Object> MainMap = (Map<String,Object>)JSON.deserializeUntyped(jsonInput);

list<Partner_Key_Account__c> lpartnerkey = [Select id,Account__c from Partner_Key_Account__c where
                                                        Key__c = :  String.valueOf(MainMap.get('partnerkey')) limit 1 ];
if(!lpartnerkey.isEmpty()){
list<Tenant__c> ltenant = [Select id,Account__c,Enterprise_ID_Tenant__c from Tenant__c where
                                                        Account__c = : lpartnerkey[0].Account__c limit 1 ];

list<Opportunity> lopp = [Select id,StageName,Tenant__c,Accountid,Box_Enterprise_ID__c from Opportunity where
                                                        Accountid = : lpartnerkey[0].Account__c and Tenant__c= : ltenant[0].id ORDER BY SystemModstamp DESC limit 1  ];

ltenant[0].Enterprise_ID_Tenant__c=String.valueOf(MainMap.get('enterpriseid'));
lopp[0].Box_Enterprise_ID__c = String.valueOf(MainMap.get('enterpriseid'));
try {
update ltenant;
update lopp;
} catch (Exception e) {
    res.statusCode = 400 ;
    resbody = '{"responseCode":"420_System_Validation/Error","responseMessage":"'+e.getDmlMessage(0)+'"}';
        res.responseBody = Blob.valueOf(Resbody);
            return;
                }
//res.responseBody = Blob.valueOf(JSON.serialize(lopp)) ;


resbody = '{"responseCode":"203_OK","responseMessage":"'+System.Label.X203_OK+'"}';

res.responseBody = Blob.valueOf(Resbody);

} else {
res.statusCode = 400 ;
resbody = '{"responseCode":"406_Invalid_Partner_Key_Failure","responseMessage":"'+System.Label.X406_Invalid_Partner_Key_Failure+'"}';
res.responseBody = Blob.valueOf(Resbody);

}
}
}