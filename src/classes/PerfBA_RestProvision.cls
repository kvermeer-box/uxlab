/******************************************************************************************
Class: PerfBA_RestProvision
Description: Box API will invoke this REST web service to make Provision Request.
SFDC validates the admin email provided is not associated with an existing tenant,
the partner key is unique, and the partner ID is valid.
If any validations fail, an error response is provided back to the partner API,
which will then provide an error response back to the requestor.
Author: Nikhil (Perficient) 11/14/2013
doGet() Method: Method will use two Parameters provided by box API to return the
                                Plan details and also going to check for the Valid Plan code and Customization.
doPost() Method: Method will accept a Json file and after doing all validations and if pass then
                                        insert tenant,Partner Key and opportunity.
********************************************************************************************/
@RestResource(urlMapping='/partnerapi/v1.0/provision')
global without sharing class PerfBA_RestProvision {
private static Map<String,Object> MainMap;

@HttpGet
global static Void doGet() {
RestRequest req = RestContext.request;
RestResponse res = RestContext.response;
String Resbody ;
String Pid = req.params.get('partnerid');
String Pcode = req.params.get('plancode');
res.addHeader('Content-Type', 'application/json');

list<Partner_Plan__c> pp = [SELECT Id,Name, Description__c,Plan_Code__c,Account_Type_Sold__c,
                                                                                                                Tier_Level__c FROM Partner_Plan__c
                                                                                                                WHERE Plan_Code__c = : pcode LIMIT 1];
list<Account> lpartnerid = [Select id,Deal_Reg__c,Trial_End_Date__c from Account where
                                                                                                                Reseller_ID__c = : decimal.valueOf(pid) limit 1 ];

if (pp.isEmpty()){
res.statusCode = 400 ;
resbody = '{"responseCode":"401_Partner_Plan_Failure","responseMessage":"'+System.Label.X401_Partner_Plan_Failure +'"}';
res.responseBody = Blob.valueOf(Resbody);

} else if(lpartnerid.isEmpty()){
res.statusCode = 400 ;
resbody = '{"responseCode":"405_Invalid_Partner_Failure","responseMessage":"'+System.Label.X405_Invalid_Partner_Failure+'"}';
res.responseBody = Blob.valueOf(Resbody);

} else {
list<Partner_Plan_Customization__c> ppc =[SELECT space_Amount__c FROM Partner_Plan_Customization__c
                                                WHERE Account__c = : lpartnerid[0].id and Partner_Plan__c = : pp[0].id LIMIT 1];

if(ppc.isEmpty()){
res.statusCode = 400 ;
resbody = '{"responseCode":"402_Partner_Plan_Customization_Failure","responseMessage":"'+System.Label.X402_Partner_Plan_Customization_Failure +'"}';
res.responseBody = Blob.valueOf(Resbody);

} else {
resbody = '{"responseCode":"201_Get_Plan_Info_Success","responseMessage":"'+System.Label.X201_Get_Plan_Info_Success;
resbody += '","Enterprise Type":"'+pp[0].Account_Type_Sold__c+'","Space Amount":"'+ppc[0].space_Amount__c +'"}';
res.responseBody = Blob.valueOf(Resbody);
//res.responseBody = Blob.valueOf(JSON.serialize((Partner_Plan_Customization__c)ppc[0])) ;
//res.responseBody = Blob.valueOf(JSON.serialize(ppc[0])) ;
}
}
}

@HttpPost
global static Void doPost() {

RestRequest req = RestContext.request;
RestResponse res = RestContext.response;
list<Contact> lcon;
Account Acc = new account();
Opportunity opp = new Opportunity();
CampaignMember cmn= New CampaignMember();
Contact cont = new Contact();
Campaign_Map_Definition__c CMD = Campaign_Map_Definition__c.getInstance('Primary');
PRM_Settings__c PRMS= PRM_Settings__c.getInstance('default');
String assigncampaign;
String Resbody ;
String jsonInput = req.requestBody.toString();
System.savepoint sp;
Decimal Amount = 0;
Decimal ChannelAmount = 0;



MainMap = (Map<String,Object>)JSON.deserializeUntyped(jsonInput);
Map<String,Object> subDetails = (Map<String,Object>)MainMap.get('account');
System.debug('Email*********'+String.valueOf(subDetails.get('email')));
list<Partner_Plan__c> pp = [SELECT Id,Name, Description__c,Plan_Code__c,Account_Type_Sold__c,Partner_Price__c,Retail_Price__c,
                                                                                                            Tier_Level__c FROM Partner_Plan__c
                                                                                                                WHERE Plan_Code__c = : String.valueOf(MainMap.get('plancode')) LIMIT 1];
list<Tenant__c> ltenant = [Select id,Admin_Email__c from Tenant__c where Admin_Email__c = : String.valueOf(subDetails.get('email')) limit 1 ];

System.debug('ltenant*********'+ltenant);
if(!ltenant.isEmpty()){ // Tenant Validation
res.statusCode = 400 ;
resbody = '{"responseCode":"403_Tenant_Exists_Failure","responseMessage":"'+System.Label.X403_Tenant_Exists_Failure+'"}';
res.responseBody = Blob.valueOf(Resbody);

} else if (pp.isEmpty()){
res.statusCode = 400 ;
resbody = '{"responseCode":"401_Partner_Plan_Failure","responseMessage":"'+System.Label.X401_Partner_Plan_Failure +'"}';
res.responseBody = Blob.valueOf(Resbody);

} else {// Partner Key Validation

list<Partner_Key_Account__c> lpartnerkey = [Select id from Partner_Key_Account__c where
                                                                                                                Key__c = :  String.valueOf(MainMap.get('partnerkey')) limit 1 ];
if(!lpartnerkey.isEmpty()){
res.statusCode = 400 ;
resbody = '{"responseCode":"404_Duplicate_Key_Failure","responseMessage":"'+System.Label.X404_Duplicate_Key_Failure+'"}';
res.responseBody = Blob.valueOf(Resbody);

} else { // Partner Id Validation

list<Account> lpartnerid = [Select name,id,Deal_Reg__c,API_Box_Entity__c,Trial_End_Date__c,Max_Trial_Days__c,Partner_Trial_Length__c,API_Contact_Method__c,API_Fee_Frequency__c
                                                                ,API_Payment_Method__c,API_Rep_Deal__c  from Account where  Reseller_ID__c = : decimal.valueOf(String.valueOf(MainMap.get('partnerid'))) limit 1 ];

if(lpartnerid.isEmpty()){
res.statusCode = 400 ;
resbody = '{"responseCode":"405_Invalid_Partner_Failure","responseMessage":"'+System.Label.X405_Invalid_Partner_Failure+'"}';
res.responseBody = Blob.valueOf(Resbody);

} else {
list<Partner_Plan_Customization__c> ppc =[SELECT id,space_Amount__c,CurrencyIsoCode,Contract_Term__c FROM Partner_Plan_Customization__c
                                                WHERE Account__c = : lpartnerid[0].id and Partner_Plan__c = : pp[0].id LIMIT 1];
if(ppc.isEmpty()){//Invalid Partner plan Customization
res.statusCode = 400 ;
resbody = '{"responseCode":"402_Partner_Plan_Customization_Failure","responseMessage":"'+System.Label.X402_Partner_Plan_Customization_Failure +'"}';
res.responseBody = Blob.valueOf(Resbody);

} else if (String.valueOf(MainMap.get('dealstatus')).equalsIgnoreCase('trial') &&  MainMap.containsKey('trialenddate') && isTrialEndDateInValid(String.valueof(lpartnerid[0].Max_Trial_Days__c != null?lpartnerid[0].Max_Trial_Days__c:0))){
res.statusCode = 400 ;
resbody = '{"responseCode":"416_Invalid_TrialEndDate","responseMessage":"'+System.Label.X416_Invalid_TrialEndDate+'"}';
res.responseBody = Blob.valueOf(Resbody);
} else if(lpartnerid[0].Deal_Reg__c){

//Place Holder if Deal Reg is true
} else {
sp = Database.setSavepoint();
lcon = [Select id,Accountid,Account.name,Email,Phone,FirstName,lastname from Contact where
                                                                                                                Email = : String.valueOf(subDetails.get('email')) limit 1 ];
if(lcon.isEmpty()){

Acc.name=String.valueOf(MainMap.get('companyname'));
if(MainMap.containsKey('street')){
acc.BillingStreet=String.valueOf(MainMap.get('street'));
}
if(MainMap.containsKey('city')){
Acc.BillingCity=String.valueOf(MainMap.get('city'));
}
if(MainMap.containsKey('country')){
Acc.BillingCountry=String.valueOf(MainMap.get('country'));
}
if(MainMap.containsKey('zip')){
Acc.BillingPostalCode=String.valueOf(MainMap.get('zip'));
}
if(MainMap.containsKey('employees')){
Acc.NumberOfEmployees=Integer.valueOf(String.valueOf(MainMap.get('employees')));
}
Acc.RecordTypeId=[SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Customer' ].Id;
Acc.Ownerid=PRMS.Ownerid__c;
//Acc.name='test';
try {
Insert Acc;
} catch (Exception e) {
Database.rollback(sp);
res.statusCode = 400 ;
resbody = '{"responseCode":"420_System_Validation/Error","responseMessage":"'+e.getDmlMessage(0)+'"}';
    res.responseBody = Blob.valueOf(Resbody);
            return;
                }
cont.Accountid=acc.id;
if(subDetails.containsKey('firstname')){
cont.FirstName=String.valueOf(subDetails.get('firstname'));
}
cont.LastName=String.valueOf(subDetails.get('lastname'));
if(subDetails.containsKey('phone')){
cont.Phone=String.valueOf(subDetails.get('phone'));
}
cont.email=String.valueOf(subDetails.get('email'));
cont.OwnerId=PRMS.Ownerid__c;
lcon.add(cont);
try {
Insert lcon;
} catch (Exception e) {
    Database.rollback(sp);
    res.statusCode = 400 ;
    resbody = '{"responseCode":"420_System_Validation/Error","responseMessage":"'+e.getDmlMessage(0)+'"}';
        res.responseBody = Blob.valueOf(Resbody);
            return;
                }
} else {
if(subDetails.containsKey('firstname')){
lcon[0].FirstName=String.valueOf(subDetails.get('firstname'));
}
lcon[0].LastName=String.valueOf(subDetails.get('lastname'));
lcon[0].OwnerId=PRMS.Ownerid__c;
if(subDetails.containsKey('phone')){
lcon[0].Phone=String.valueOf(subDetails.get('phone'));
}
try {
Update lcon[0];
} catch (Exception e) {
    Database.rollback(sp);
    res.statusCode = 400 ;
    resbody = '{"responseCode":"420_System_Validation/Error","responseMessage":"'+e.getDmlMessage(0)+'"}';
        res.responseBody = Blob.valueOf(Resbody);
            return;
                }
}
String querystr = 'select '+CMD.Object_Field__c+' from '+CMD.Object_Type__c+' where id = \''+lpartnerid[0].id+'\'';
sObject so;
so =  database.query(querystr);
if(so.get(CMD.object_Field__c) == null || so.get(CMD.object_Field__c) == ''){
assigncampaign = cmd.Default_Campaign__c;
} else {
assigncampaign = (String)so.get(CMD.object_Field__c);
}
CampaignMember cm= New CampaignMember(CampaignId=assigncampaign, ContactId= lcon[0].Id,Status='Responded',FCRM__FCR_Admin_Response_Control__c=130 );

try {
insert cm;
} catch (Exception e) {
    Database.rollback(sp);
    res.statusCode = 400 ;
    resbody = '{"responseCode":"420_System_Validation/Error","responseMessage":"'+e.getDmlMessage(0)+'"}';
        res.responseBody = Blob.valueOf(Resbody);
            return;
                }
List<id> cid = new List<id>();
cid.add(lcon[0].id);

Partner_Key_Account__c lpka= New Partner_Key_Account__c(Key__c=String.valueOf(MainMap.get('partnerkey')),Account__c=lcon[0].Accountid,
                                                                                                Partner__c=lpartnerid[0].id);
try {
insert lpka;
} catch (Exception e) {
    Database.rollback(sp);
    res.statusCode = 400 ;
    resbody = '{"responseCode":"420_System_Validation/Error","responseMessage":"'+e.getDmlMessage(0)+'"}';
        res.responseBody = Blob.valueOf(Resbody);
            return;
                }


System.debug('lcon*********'+lcon);
Tenant__c lTe = New Tenant__c();
if(String.valueOf(MainMap.get('dealstatus')).equalsIgnoreCase('trial') &&  MainMap.containsKey('trialenddate') ){
lTe = New Tenant__c(Admin__c=lcon[0].Id,Account__c=lcon[0].Accountid,
            Admin_Email__c= String.valueOf(subDetails.get('email'))
            ,Admin_Name__c= subDetails.containsKey('firstname')? String.valueOf(subDetails.get('firstname')):''+String.valueOf(subDetails.get('lastname'))
            ,Admin_Phone__c=subDetails.containsKey('phone')? String.valueOf(subDetails.get('phone')):''
            ,Trial_End_Date__c = Date.parse((String)MainMap.get('trialenddate'))
            ,Billing_Cycle__c=MainMap.containsKey('billingcycle')? String.valueOf(MainMap.get('billingcycle')):''
            ,Trial_Start_Date__c=date.today()
            ,Seats_Allocated__c = Decimal.valueOf((String)MainMap.get('seats'))
            ,Deal_Status__c=String.valueOf(MainMap.get('dealstatus'))
            ,Account_Type__c=pp[0].Account_Type_Sold__c
            ,Active_Status__c='active'
            ,Original_Active_Date__c=date.today()
            ,Most_Recent_Active_Date__c=date.today()
            ,Seats_Used__c=1
            ,Disable_Box_Sync__c=true
            ,Last_Activity_Date__c=date.today()
            ,Plan_Code__c=String.valueOf(MainMap.get('plancode'))
            ,Reseller_ID__c=decimal.valueOf(String.valueOf(MainMap.get('partnerid')))
                                                                            );


try {
insert lte;
} catch (Exception e) {
Database.rollback(sp);
if(e.getDmlMessage(0).containsIgnoreCase('Minimum seats allocated is three')){
res.statusCode = 400 ;
resbody = '{"responseCode":"418_Invalid_Seats","responseMessage":"'+e.getDmlMessage(0)+'"}';
} else if (e.getDmlMessage(0).containsIgnoreCase('Trial Date cannot be a day in the past')){
res.statusCode = 400 ;
resbody = '{"responseCode":"419_Trial_End_In_The_Past","responseMessage":"'+e.getDmlMessage(0)+'"}';
} else {
res.statusCode = 400 ;
resbody = '{"responseCode":"420_System_Validation/Error","responseMessage":"'+e.getDmlMessage(0)+'"}';
}
        res.responseBody = Blob.valueOf(Resbody);
            return;
                }

} else if (String.valueOf(MainMap.get('dealstatus')).equalsIgnoreCase('trial') &&  !MainMap.containsKey('trialenddate') )   {
lTe = New Tenant__c(Admin__c=lcon[0].Id,Account__c=lcon[0].Accountid,
            Admin_Email__c= String.valueOf(subDetails.get('email'))
            ,Admin_Name__c= subDetails.containsKey('firstname')? String.valueOf(subDetails.get('firstname')):''+String.valueOf(subDetails.get('lastname'))
            ,Admin_Phone__c=subDetails.containsKey('phone')? String.valueOf(subDetails.get('phone')):''
            ,Trial_End_Date__c = date.today().addDays(Integer.valueOf(lpartnerid[0].Partner_Trial_Length__c != null?lpartnerid[0].Partner_Trial_Length__c:0))
            ,Billing_Cycle__c=MainMap.containsKey('billingcycle')? String.valueOf(MainMap.get('billingcycle')):''
            ,Trial_Start_Date__c=date.today()
            ,Seats_Allocated__c =Decimal.valueOf((String)MainMap.get('seats'))
            ,Deal_Status__c=String.valueOf(MainMap.get('dealstatus'))
            ,Account_Type__c=pp[0].Account_Type_Sold__c
            ,Active_Status__c='active'
            ,Original_Active_Date__c=date.today()
            ,Most_Recent_Active_Date__c=date.today()
            ,Seats_Used__c=1
            ,Disable_Box_Sync__c=true
            ,Last_Activity_Date__c=date.today()
            ,Plan_Code__c=String.valueOf(MainMap.get('plancode'))
            ,Reseller_ID__c=decimal.valueOf(String.valueOf(MainMap.get('partnerid')))
            );
try {
insert lte;
} catch (Exception e) {
Database.rollback(sp);
if(e.getDmlMessage(0).containsIgnoreCase('Minimum seats allocated is three')){
res.statusCode = 400 ;
resbody = '{"responseCode":"418_Invalid_Seats","responseMessage":"'+e.getDmlMessage(0)+'"}';
} else {
res.statusCode = 400 ;
resbody = '{"responseCode":"420_System_Validation/Error","responseMessage":"'+e.getDmlMessage(0)+'"}';
}
        res.responseBody = Blob.valueOf(Resbody);
            return;
                }
} else if (String.valueOf(MainMap.get('dealstatus')).equalsIgnoreCase('live_deal')){
lTe = New Tenant__c(Admin__c=lcon[0].Id,Account__c=lcon[0].Accountid,Admin_Email__c= String.valueOf(subDetails.get('email'))
        ,Admin_Name__c= subDetails.containsKey('firstname')? String.valueOf(subDetails.get('firstname')):''+String.valueOf(subDetails.get('lastname'))
        ,Admin_Phone__c=subDetails.containsKey('phone')? String.valueOf(subDetails.get('phone')):''
        ,Billing_Cycle__c=MainMap.containsKey('billingcycle')? String.valueOf(MainMap.get('billingcycle')):''
        ,Seats_Allocated__c =Decimal.valueOf((String)MainMap.get('seats'))
        ,Deal_Status__c=String.valueOf(MainMap.get('dealstatus'))
        ,Space_Allocated__c=ppc[0].space_Amount__c
        ,Account_Type__c=pp[0].Account_Type_Sold__c
        ,Active_Status__c='active'
        ,Original_Active_Date__c=date.today()
        ,Most_Recent_Active_Date__c=date.today()
        ,Original_Live_Date__c=date.today()
        ,Seats_Used__c=1
        ,Disable_Box_Sync__c=true
        ,Last_Activity_Date__c=date.today()
        ,Plan_Code__c=String.valueOf(MainMap.get('plancode'))
        ,Reseller_ID__c=decimal.valueOf(String.valueOf(MainMap.get('partnerid')))
        );
try {
insert lte;
} catch (Exception e) {
Database.rollback(sp);
if(e.getDmlMessage(0).containsIgnoreCase('Minimum seats allocated is three')){
res.statusCode = 400 ;
resbody = '{"responseCode":"418_Invalid_Seats","responseMessage":"'+e.getDmlMessage(0)+'"}';
}  else {
res.statusCode = 400 ;
resbody = '{"responseCode":"420_System_Validation/Error","responseMessage":"'+e.getDmlMessage(0)+'"}';
}
        res.responseBody = Blob.valueOf(Resbody);
            return;
                }
}
Decimal Discount = 0;
List<Partner_Discount__c> pd = getdiscount(ppc[0].Id);
if(!pd.isEmpty()) {
Discount = pd[0].Discount__c == null ? 0 : pd[0].Discount__c/100;
}
Amount = (decimal)pp.get(0).get(PRMS.Amount__c);
ChannelAmount = (decimal)pp.get(0).get(PRMS.ChannelAmount__c);
opp.OwnerId=PRMS.Ownerid__c;
opp.Account_Type_Sold__c=pp[0].Account_Type_Sold__c;
opp.Plan_Code__c=String.valueOf(MainMap.get('plancode'));
opp.Accountid=lcon[0].Accountid;
opp.Reseller_ID__c=String.valueOf(MainMap.get('partnerid'));
opp.CurrencyIsoCode=ppc[0].CurrencyIsoCode;
opp.Payment_Term__c=ppc[0].Contract_Term__c;
opp.Tenant__c=lte.id;
opp.Box_Partner_Account__c=lpartnerid[0].id;
opp.Box_Entity__c=lpartnerid[0].API_Box_Entity__c;
opp.Primary_Contact__c=lte.Admin__c;
opp.Contact_Method_Most_Recent__c=PRMS.API_Contact_Method__c;
opp.Fee_Frequency__c=lpartnerid[0].API_Fee_Frequency__c;
opp.Payment_Method__c=lpartnerid[0].API_Payment_Method__c;
opp.Rep_Quota_Relief__c=lpartnerid[0].API_Rep_Deal__c;
if(MainMap.containsKey('seats')){
opp.Seats_Sold__c=Decimal.valueOf((String)MainMap.get('seats'));
opp.Amount=Decimal.valueOf((String)MainMap.get('seats'))*(Amount-discount*Amount);
//opp.Best_Case__c=Decimal.valueOf((String)MainMap.get('seats'))*(Amount-discount*Amount);
opp.Channel_Amount__c=Decimal.valueOf((String)MainMap.get('seats'))*ChannelAmount;
}
if(String.valueOf(MainMap.get('dealstatus')).equalsIgnoreCase('live_deal')){
opp.Provisioning_Date__c=date.today();
opp.Approval_Stage__c='Provisioned';    
opp.StageName='Closed Won';
opp.CloseDate=date.today();
opp.Name=lpartnerid[0].name+' NEW '+opp.Seats_Sold__c+' '+pp[0].Account_Type_Sold__c+' '+
        (getAccName(lcon[0].Accountid)[0].name == null ? '' : getAccName(lcon[0].Accountid)[0].name);

opp.RecordTypeId=PRMS.BoxAPIClosedWonRecordtype__c;
} else {
opp.Name=lpartnerid[0].name+' TRIAL '+opp.Seats_Sold__c+' '+pp[0].Account_Type_Sold__c+' '+
        (getAccName(lcon[0].Accountid)[0].name == null ? '' : getAccName(lcon[0].Accountid)[0].name);

opp.RecordTypeId=PRMS.BoxAPITrialRecordtype__c;
opp.Trial_Start_Date__c=date.today();
if( !MainMap.containsKey('trialenddate')){
opp.CloseDate=date.today().addDays(Integer.valueOf(lpartnerid[0].Partner_Trial_Length__c != null?lpartnerid[0].Partner_Trial_Length__c:0));
opp.Trial_End_Date__c=date.today().addDays(Integer.valueOf(lpartnerid[0].Partner_Trial_Length__c != null?lpartnerid[0].Partner_Trial_Length__c:0));
} else {
opp.CloseDate=Date.parse((String)MainMap.get('trialenddate'));
opp.Trial_End_Date__c=Date.parse((String)MainMap.get('trialenddate'));
}
opp.StageName='Discovery / Trial';
}
try {
insert opp;
} catch (Exception e) {
    Database.rollback(sp);
    res.statusCode = 400 ;
    resbody = '{"responseCode":"420_System_Validation/Error","responseMessage":"'+e.getDmlMessage(0)+'"}';
        res.responseBody = Blob.valueOf(Resbody);
            return;
                }
// part to addd campaign menmer to opportunity
List<CampaignMember> GetActRes=FCRM.FCR_SupportAPI.GetActiveResponses(cid);
if(GetActRes.isEmpty()){
cmn.Id=cm.id;
} else {
cmn.Id=GetActRes[0].id;
}
cmn.FCRM__FCR_Admin_Response_Control__c=8;
cmn.FCRM__FCR_Opportunity__c=opp.id;
try {
Update cmn;
} catch (Exception e) {
    Database.rollback(sp);
    res.statusCode = 400 ;
    resbody = '{"responseCode":"420_System_Validation/Error","responseMessage":"'+e.getDmlMessage(0)+'"}';
        res.responseBody = Blob.valueOf(Resbody);
            return;
                }
//END


OpportunityContactRole oppContactRole = new OpportunityContactRole(ContactId=lte.Admin__c, OpportunityId=opp.Id, IsPrimary=True, Role='Business  User');
try {
insert oppContactRole;
} catch (Exception e) {
    Database.rollback(sp);
    res.statusCode = 400 ;
    resbody = '{"responseCode":"420_System_Validation/Error","responseMessage":"'+e.getDmlMessage(0)+'"}';
        res.responseBody = Blob.valueOf(Resbody);
            return;
                }

resbody = '{"responseCode":"202_OK","responseMessage":"'+System.Label.X202_SFDC_Updated;
resbody += '","Trial End Date":"'+lte.Trial_End_Date__c+'","PartnerKey":"'+String.valueOf(MainMap.get('partnerkey'))+'"}';
res.responseBody = Blob.valueOf(Resbody);
}
}
}
}
}

private static Boolean isTrialEndDateInValid(String Maxtd){
                if(MainMap.containsKey('trialenddate')){
                                Date requestedTrialEndDate = Date.parse((String)MainMap.get('trialenddate'));
                                if(requestedTrialEndDate != null){
                                        Date latestTrialEndDate = date.today().addDays(Integer.valueOf(Maxtd));

                                        if(requestedTrialEndDate > latestTrialEndDate){
                                                return true;
                                        }
                                        else{
                                                return false;
                                        }
                                }
                }

                return false;
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
        * Retrieves name from Account.
        *
        * @param Id
        *
        * @author Nikhil
        */
        private static List<Account> getAccName(Id Aid) {
            return [SELECT Name FROM Account WHERE id = : Aid limit 1  ];
        }



}