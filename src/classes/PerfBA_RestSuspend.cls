/****************************************************************
Class: PerfBA_RestSuspend
Description: Box API will invoke this REST web service to Suspend the tenant and
Create opportunity.
The partner API layer submits a status change request to SFDC.
SFDC finds the tenant record associated using the enterprise ID.
The requested status is validated against the current status value of the tenant record.
If it is already set to the requested status, an error response is provided
The tenant status is updated.
An opportunity is created with stage = “Cancelled/Churn”.
The details of the tenant record are populated on the opportunity.
An opportunity contact role is created for the contact associated with the tenant.
Author: Nikhil (Perficient) 11/19/2013
*****************************************************************/
@RestResource(urlMapping='/partnerapi/v1.0/suspend')
global with sharing class PerfBA_RestSuspend {
@HttpPost
global static Void doPost() {
RestRequest req = RestContext.request;
RestResponse res = RestContext.response;
Opportunity opp ;
String Resbody ;
Decimal Discount = 0;
 System.savepoint sp;
list<Partner_Plan__c> pp;
list<Account> lpartnerid ;
PRM_Settings__c PRMS= PRM_Settings__c.getInstance('default');
String jsonInput = req.requestBody.toString();
Map<String,Object> MainMap = (Map<String,Object>)JSON.deserializeUntyped(jsonInput);
List<Tenant__c> ltenant = [SELECT Enterprise_ID_Tenant__c,Account__c,id,Active_Status__c,Account__r.Original_Close_Date__c,Original_Live_Date__c,
														Account__r.name,Deal_Status__c,Seats_Allocated__c,Reseller_ID__c,Plan_Code__c,Admin__c,Admin_Email__c,Admin_Name__c,Admin_Phone__c  FROM Tenant__c
														WHERE Enterprise_ID_Tenant__c = :String.valueOf(MainMap.get('enterpriseid'))];
if(ltenant.isEmpty()){
res.statusCode = 400 ;
resbody = '{"responseCode":"411_No_Tenant_For_EnterpriseId","responseMessage":"'+System.Label.X411_No_Tenant_For_EnterpriseId+'"}';
res.responseBody = Blob.valueOf(Resbody);
} else if(ltenant[0].Active_Status__c != null && ltenant[0].Active_Status__c != '' && ltenant[0].Active_Status__c.equalsIgnoreCase('deactivated')) {
res.statusCode = 400 ;
resbody = '{"responseCode":"408_Same_Status_Failure","responseMessage":"'+System.Label.X408_Same_Status_Failure+'"}';
res.responseBody = Blob.valueOf(Resbody);
}  else {
if(ltenant[0].Plan_Code__c != null){
pp = [SELECT Id,Name, Description__c,Plan_Code__c,Tier_Level__c,Account_Type_Sold__c
							,Partner_Price__c,Retail_Price__c FROM Partner_Plan__c
							WHERE Plan_Code__c = : ltenant[0].Plan_Code__c LIMIT 1];
}
if(ltenant[0].Reseller_ID__c != null){
lpartnerid = [Select name,id,Deal_Reg__c,Trial_End_Date__c,Max_Trial_Days__c,Partner_Trial_Length__c,API_Box_Entity__c
				,API_Contact_Method__c,API_Fee_Frequency__c,API_Payment_Method__c,API_Rep_Deal__c,Reseller_ID__c from Account where
				Reseller_ID__c = : ltenant[0].Reseller_ID__c limit 1 ];
}
ltenant[0].Active_Status__c ='deactivated';
if(!ltenant[0].Deal_Status__c.equalsIgnoreCase('trial')){
	
/****************************************************************
if ( Date.Today().Month() == (ltenant[0].Original_Live_Date__c == null ? 0 : ltenant[0].Original_Live_Date__c.Month()) &&
	 Date.Today().Year() == (ltenant[0].Original_Live_Date__c == null ? 0 : ltenant[0].Original_Live_Date__c.Year())){
List<Opportunity> oppl = getwonOppotunity(ltenant[0].Id);
if(!pp.isEmpty())
{
Partner_Plan_Customization__c ppc = getPartnerPlanCustomize(lpartnerid[0].Id, pp[0].Id);
if(ppc != null){
List<Partner_Discount__c> pd = getdiscount(ppc.Id);
if(!pd.isEmpty()) {
Discount = pd[0].Discount__c == null ? 0 : pd[0].Discount__c/100;
}
}
}
                        if(!oppl.isEmpty()) {
                        	for(opportunity ol : oppl){
                        		ol.StageName ='Closed Lost';
                        		ol.Name=ol.Box_Partner_Account__r.name+' CANCEL '+ol.Seats_Sold__c+' '+ol.Account_Type_Sold__c+' '+ol.Account.Name;
                        		ol.OwnerId=PRMS.Ownerid__c;
                        		ol.Amount=ltenant[0].Seats_Allocated__c*((decimal)pp.get(0).get(PRMS.Amount__c)-discount*(decimal)pp.get(0).get(PRMS.Amount__c));
								ol.Channel_Amount__c=ltenant[0].Seats_Allocated__c*(decimal)pp.get(0).get(PRMS.ChannelAmount__c);
                        		ol.Seats_Sold__c=ltenant[0].Seats_Allocated__c;
                        	}
                        	
           try {
update oppl;
} catch (Exception e) {
	res.statusCode = 400 ;
	resbody = '{"responseCode":"420_System_Validation/Error","responseMessage":"'+e.getDmlMessage(0)+'"}';
		res.responseBody = Blob.valueOf(Resbody);
			return;
				}            	
                     }	
                    
} else {
****************************************************************/	
opp = new Opportunity();
if(!pp.isEmpty())
{
Partner_Plan_Customization__c ppc = getPartnerPlanCustomize(lpartnerid[0].Id, pp[0].Id);
if(ppc != null){
opp.CurrencyIsoCode=ppc.CurrencyIsoCode;
opp.Payment_Term__c=ppc.Contract_Term__c;
List<Partner_Discount__c> pd = getdiscount(ppc.Id);
if(!pd.isEmpty()) {
Discount = pd[0].Discount__c == null ? 0 : pd[0].Discount__c/100;
}
}
opp.Account_Type_Sold__c=pp[0].Account_Type_Sold__c;
opp.Amount=ltenant[0].Seats_Allocated__c*((decimal)pp.get(0).get(PRMS.Amount__c)-discount*(decimal)pp.get(0).get(PRMS.Amount__c));
//opp.Best_Case__c=ltenant[0].Seats_Allocated__c*((decimal)pp.get(0).get(PRMS.Amount__c)-discount*(decimal)pp.get(0).get(PRMS.Amount__c));
opp.Channel_Amount__c=ltenant[0].Seats_Allocated__c*(decimal)pp.get(0).get(PRMS.ChannelAmount__c);
}
if(!lpartnerid.isEmpty())
{
opp.Box_Partner_Account__c=lpartnerid[0].id;
opp.Box_Entity__c=lpartnerid[0].API_Box_Entity__c;
opp.Contact_Method_Most_Recent__c=PRMS.API_Contact_Method__c;
opp.Primary_Churn_Reason__c=PRMS.Primary_Churn_Reason__c;
opp.Fee_Frequency__c=lpartnerid[0].API_Fee_Frequency__c;
opp.Payment_Method__c=lpartnerid[0].API_Payment_Method__c;
opp.Reseller_ID__c=String.valueOf(lpartnerid[0].Reseller_ID__c);

}
opp.Primary_Contact__c=ltenant[0].Admin__c;
opp.Accountid=ltenant[0].Account__c;
opp.OwnerId=PRMS.Ownerid__c;
opp.StageName='Cancellation - Churn';
opp.CloseDate=date.today();
opp.Original_Close_Date__c=date.today();
opp.Tenant__c=ltenant[0].id;
opp.Seats_Sold__c=ltenant[0].Seats_Allocated__c;
opp.Box_Enterprise_ID__c=ltenant[0].Enterprise_ID_Tenant__c;
opp.RecordTypeId=PRMS.BoxAPIClosedWonRecordtype__c;
opp.Name = (lpartnerid[0].Name == null ? '' : lpartnerid[0].Name) + ' CANCEL ' +(String.valueOf(ltenant[0].Seats_Allocated__c) == null ? '' :
				String.valueOf(ltenant[0].Seats_Allocated__c))+ ' '+pp[0].Account_Type_Sold__c+' '+ltenant[0].Account__r.name ;
try {
insert opp;
} catch (Exception e) {
	res.statusCode = 400 ;
	resbody = '{"responseCode":"420_System_Validation/Error","responseMessage":"'+e.getDmlMessage(0)+'"}';
		res.responseBody = Blob.valueOf(Resbody);
			return;
				}
	//}	Commented For Current Month Scenario		
} else {
opp = [SELECT Tenant__c, StageName, Seats_Sold__c, Name,
				Id, CloseDate, Channel_Amount__c, Amount,Account.name,
				Account_Type_Sold__c,Box_Partner_Account__r.name
				FROM Opportunity
				WHERE tenant__c = : ltenant[0].id
				AND tenant__c  != null  And StageName = 'Discovery / Trial' ORDER BY SystemModstamp DESC limit 1  ];
opp.StageName = 'Closed Lost';
opp.OwnerId=PRMS.Ownerid__c;
opp.Name=opp.Box_Partner_Account__r.name+' CANCEL '+opp.Seats_Sold__c+' '+opp.Account_Type_Sold__c+' '+opp.Account.Name;

try {
update opp;

} catch (Exception e) {
	res.statusCode = 400 ;
	resbody = '{"responseCode":"420_System_Validation/Error","responseMessage":"'+e.getDmlMessage(0)+'"}';
		res.responseBody = Blob.valueOf(Resbody);
			return;
				}
}

try {
update ltenant;
} catch (Exception e) {
	Database.rollback(sp);
	res.statusCode = 400 ;
	resbody = '{"responseCode":"420_System_Validation/Error","responseMessage":"'+e.getDmlMessage(0)+'"}';
		res.responseBody = Blob.valueOf(Resbody);
			return;
				}
resbody = '{"responseCode":"204_SFDC_tenant_Updated","responseMessage":"'+System.Label.X204_SFDC_tenant_Updated+'"}';
res.responseBody = Blob.valueOf(Resbody);
}
}

/**
				* Retrieves Discount related to specific partner plan customization.
				*
				* @param Id
				*
				* @author Nikhil
				*/
				private static List<Partner_Discount__c> getdiscount(Id PpcId) {
						return [SELECT Partner_Plan_Customization__c,Discount__c
								FROM Partner_Discount__c o
								WHERE o.Partner_Plan_Customization__c = : PpcId
								AND o.Partner_Plan_Customization__c  != null ORDER BY SystemModstamp DESC limit 1  ];
				}

				

	/**
				* Returns partner plan customization record.
				*
				* @return Partner_Plan_Customization__c
				*
				* @author Santoshi(Perficient)
				*/
				private Static Partner_Plan_Customization__c getPartnerPlanCustomize(Id accId ,
								Id partnerPlanId) {
						List<Partner_Plan_Customization__c> ppc = [SELECT space_Amount__c,CurrencyIsoCode,Contract_Term__c 
										FROM Partner_Plan_Customization__c
										WHERE Account__c = : accId AND
										Partner_Plan__c = : partnerPlanId
										AND Partner_Plan__c!= null LIMIT 1];
						if(!ppc.isEmpty()) {
								return ppc[0];
						}
						return null;
				}
				
				
				 /**
                * Retrieves Lost opportunity related to specific tenant.
                *
                * @param Id
                *
                * @author Santoshi(Perficient)
                */
                private static List<Opportunity> getwonOppotunity (Id TenantId) {
                        return [SELECT o.Tenant__c, o.StageName, o.Seats_Sold__c, o.Name,o.Account.name,
                                o.Id, o.CloseDate, o.Channel_Amount__c, o.Amount,
                                o.Account_Type_Sold__c,o.Box_Partner_Account__r.name
                                FROM Opportunity o
                                WHERE o.tenant__c = : TenantId
                                AND o.tenant__c  != null And ( o.StageName In ('Closed Won','Cancellation - Churn'))];
                }
				
				
				
				
				

}