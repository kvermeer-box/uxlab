/****************************************************************
Class: PerfBA_Update
Description: Box API will invoke this REST web service to make updates to the
                                to the tenant (customer box account) and create / update opportunities
Author: Rucha (Perficient) 11/19/2013
Revision History
12/9 - Santoshi Mishra - Modified class to support insert update scenario.
*****************************************************************/

@RestResource(urlMapping='/partnerapi/v1.0/update')
global with sharing class PerfBA_Update {
       // private class UpdateInput{
                //public String partnerId;
        //}
        private static Map<String,Object> deserializedInput;
        private static Map<String,Object> subDetails;
        private static List<Account> partnerAccount;
        private static List<Partner_Plan__c> newPlan;
        // Added by Santoshi on 12/11.
        public static Final String ACTIVE_STATUS = 'active';
        public static Final String DEACTIVATE = 'deactivated';
        public static Final String LIVE = 'live_deal';
        public static Final String TRIAL = 'trial';
        public static Final String CLOSED_WON = 'Closed Won';
        public static Final String Upsell = 'UPGRADE';
        public static Final String Cancellation ='Cancellation - Churn';
        public static Final String CHURN = 'DOWNGRADE';
        public static Final String PARAM_DEAL_STATUS = 'dealstatus';
        public static Final String PARAM_ACTIVE_STATUS = 'activestatus';
        public static Final String PARAM_SEATS = 'seats';
        public static Final String REACTIVATION = 'REACTIVATE';
        public static Final String PARAM_PLANCODE = 'plancode';
        public static Boolean ErrScenario = false;


// End Declaration - SM
        @HttpPost
        global static void boxAPIUpdates(){
                RestRequest req = RestContext.request;
                RestResponse resp = RestContext.response;
                String Resbody ;
                System.savepoint sp;

                system.debug('req: ' + req.requestBody.toString());
                String requestInput = req.requestBody.toString();
				PRM_Settings__c PRMS= PRM_Settings__c.getInstance('default');
				
                deserializedInput = (Map<String,Object>)JSON.deserializeUntyped(requestInput);
                system.debug('json: ' + deserializedInput);
        if(deserializedInput.containsKey('account')){
        subDetails = (Map<String,Object>)deserializedInput.get('account');
                }
                //Query Enterprise Id, If no tenant found for the enterprise id  send error
                List<Tenant__c> tenant = [SELECT Name,Active_Status__c,Admin__c, Deal_Status__c, Partner_Plan__r.Tier_Level__c, Trial_Start_Date__c,Account__c , plan_code__c,
                                                                        Enterprise_ID_Tenant__c,Seats_Allocated__c,Space_Allocated__c,Account_Type__c ,Last_Activity_Date__c
                                                                        ,Most_Recent_Active_Date__c,Original_Live_Date__c FROM Tenant__c
                                                                        WHERE Enterprise_ID_Tenant__c = :(String)deserializedInput.get('enterpriseid')
                                                                        AND Enterprise_ID_Tenant__c != null];
                list<Account> lpartnerid = [Select id,name,Deal_Reg__c,Trial_End_Date__c, API_Contact_Method__c ,API_Box_Entity__c,
                                API_Payment_Method__c, API_Fee_Frequency__c , API_Rep_Deal__c,Reseller_ID__c
                                FROM Account
                                WHERE Reseller_ID__c = : decimal.valueOf((String)deserializedInput.get('partnerid')) limit 1 ];

                if(lpartnerid.isEmpty()){
                        resp.statusCode = 400 ;
                        resbody = '{"responseCode":"405_Invalid_Partner_Failure","responseMessage":"'+System.Label.X405_Invalid_Partner_Failure+'"}';
                        resp.responseBody = Blob.valueOf(Resbody);
                }
                else if(tenant.isEmpty()){
                        resp.statusCode = 400 ;
                        resp.responseBody = Blob.valueOf(generateResponseMessage('411_No_Tenant_For_EnterpriseId',Label.X411_No_Tenant_For_EnterpriseId));
                } else if (deserializedInput.containsKey(PARAM_ACTIVE_STATUS) && deserializedInput.containsKey(PARAM_DEAL_STATUS) &&
                        (String.valueOf(deserializedInput.get(PARAM_ACTIVE_STATUS))).equalsIgnoreCase(ACTIVE_STATUS) &&
                        (String.valueOf(deserializedInput.get(PARAM_DEAL_STATUS))).equalsIgnoreCase(TRIAL) &&
                        tenant[0].Active_Status__c != null && tenant[0].Active_Status__c.equalsIgnoreCase(DEACTIVATE) &&
                        tenant[0].Deal_Status__c != null && tenant[0].Deal_Status__c.equalsIgnoreCase(TRIAL) ) {
                        resp.statusCode = 400 ;
                        resp.responseBody = Blob.valueOf(generateResponseMessage('417_Invalid_Update',Label.X417_Invalid_Update));

                        } else if( tenant.get(0).Trial_Start_Date__c != null && String.valueOf(deserializedInput.get('dealstatus')).equalsIgnoreCase('trial') && isTrialEndDateInValid(tenant.get(0).Trial_Start_Date__c)){
                        resp.statusCode = 400 ;
                        resp.responseBody = Blob.valueOf(generateResponseMessage('416_Invalid_TrialEndDate',Label.X416_Invalid_TrialEndDate));
                } else{
                        if(isDealRegReqd()){

                        }
                        else{
                        // Added by SM on 12/9
                        	
                        
                                Partner_Plan__c pp ;
                                if(deserializedInput.containsKey(PARAM_PLANCODE)){
                                pp = getPartnerPlan((String)deserializedInput.get(PARAM_PLANCODE));
                                } else {
                                pp = getPartnerPlan(tenant.get(0).plan_code__c);
                                }

                                Partner_Plan_Customization__c ppc;
                                if(pp != null)
                                ppc = getPartnerPlanCustomize(lpartnerid[0].Id, pp.Id);
                                else {
                                        resp.statusCode = 400 ;
                                        resp.responseBody = Blob.valueOf(generateResponseMessage('401_Partner_Plan_Failure',Label.X401_Partner_Plan_Failure));
                                }
                                if(ppc == null) {
                                        resp.statusCode = 400 ;
                                        resp.responseBody = Blob.valueOf(generateResponseMessage('402_Partner_Plan_Customization_Failure',Label.X402_Partner_Plan_Customization_Failure));
                                } else {
                                        sp = Database.setSavepoint();

                                        try {
                                        validateRequest(tenant,lpartnerid,pp,ppc,PRMS);
                                        } catch (Exception  e) {
                                                                Database.rollback(sp);
                                                        if(e.getDmlMessage(0).containsIgnoreCase('Minimum seats allocated is three')){
                                                        resp.statusCode = 400 ;
                                                        resp.responseBody = Blob.valueOf(generateResponseMessage('418_Invalid_Seats',e.getDmlMessage(0)));
                                                        } else if (e.getDmlMessage(0).containsIgnoreCase('Trial Date cannot be a day in the past')){
                                                        resp.statusCode = 400 ;
                                                        resp.responseBody = Blob.valueOf(generateResponseMessage('419_Trial_End_In_The_Past',e.getDmlMessage(0)));
                                                        } else {
                                                        resp.statusCode = 400 ;
                                                        resp.responseBody = Blob.valueOf(generateResponseMessage('420_System_Validation/Error',e.getDmlMessage(0)));
                                                        }
                                                        return;
                                        }
                                resp.responseBody = Blob.valueOf(generateResponseMessage('203_OK',Label.X203_OK));

                        }

                }



                }


        }

      
        private static Boolean isTrialEndDateInValid(Date currentTrialStartDate){
                if(deserializedInput.containsKey('trialenddate')){
                                Date requestedTrialEndDate = Date.parse((String)deserializedInput.get('trialenddate'));
                                if(requestedTrialEndDate != null){
                                        partnerAccount = [SELECT Max_Trial_Days__c
                                                                                FROM Account
                                                                                WHERE Reseller_ID__c = : decimal.valueOf((String)deserializedInput.get('partnerid'))];

                                        Date latestTrialEndDate = currentTrialStartDate.addDays(Integer.valueOf(partnerAccount.get(0).Max_Trial_Days__c != null?partnerAccount.get(0).Max_Trial_Days__c:0));
										
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

        private static Boolean isDealRegReqd(){
                return false;
        }

        //Create response message
        private static String generateResponseMessage(String responseCode, String responseMessage){
                JSONGenerator respStr = JSON.createGenerator(FALSE);
                respStr.writeStartObject();
                respStr.writeStringField('responseCode', responseCode);
                respStr.writeStringField('responseMessage', responseMessage);
                respStr.writeEndObject();
                respStr.close();
                return respStr.getAsString();
        }

        //Update Tenant
        private static void updateTenant(Tenant__c currTenant){

                
                if(deserializedInput.containsKey('billingcycle')){
                        currTenant.Billing_Cycle__c = (String)deserializedInput.get('billingcycle');
                }

                if(deserializedInput.containsKey('trialenddate') && String.valueOf(deserializedInput.get('dealstatus')).equalsIgnoreCase('trial')){
                        currTenant.Trial_End_Date__c = Date.parse((String)deserializedInput.get('trialenddate'));}
                        
                            update currTenant;

        }

        /**
         * Validates insert update scenario.
         *
         * @param List<Tenant__c>
         * @param List<Account>
         *
         * @author Santoshi(Perficient)
         */
        private static void validateRequest(List<Tenant__c> tenant,List<Account> lpartnerid ,
                        Partner_Plan__c pp ,Partner_Plan_Customization__c ppc,PRM_Settings__c PRMS) {
                Decimal Amount = 0;
                Decimal ChannelAmount = 0;
                Opportunity opp;
                Decimal seats = 0;
                String plancode ;
                 Decimal RDiscount = 0;
                 Decimal CDiscount = 0;

                if(deserializedInput.containsKey(PARAM_PLANCODE)) {
                        plancode = (String)deserializedInput.get(PARAM_PLANCODE);
                } else {
                        plancode = tenant.get(0).plan_code__c;
                }
                if(deserializedInput.containsKey(PARAM_SEATS)) {
                        seats = Decimal.valueOf((String)deserializedInput.get(PARAM_SEATS));
                }
                if(pp.get(PRMS.Amount__c) != null) {
                	List<Partner_Discount__c> rpd = getdiscount(ppc.Id);
                    if(!rpd.isEmpty()) {
                                RDiscount = rpd[0].Discount__c == null ? 0 : rpd[0].Discount__c/100;
                                }
                        Amount = seats * ((decimal)pp.get(PRMS.Amount__c)-RDiscount*(decimal)pp.get(PRMS.Amount__c));
                }
                if (pp.get(PRMS.ChannelAmount__c) != null) {
                        ChannelAmount = seats * (decimal)pp.get(PRMS.ChannelAmount__c);
                }
                System.debug('Checking 111 Amount----'+Amount+ChannelAmount);
                System.debug('Checking 111----'+String.valueOf(deserializedInput.get(PARAM_ACTIVE_STATUS)).equalsIgnoreCase(ACTIVE_STATUS));
                System.debug('Checking 111--77--'+String.valueOf(deserializedInput.get(PARAM_DEAL_STATUS)).equalsIgnoreCase(LIVE));
                System.debug('Checking 111--88--'+tenant[0].Active_Status__c.equalsIgnoreCase(ACTIVE_STATUS));
                System.debug('Checking 111--555--'+tenant[0].Deal_Status__c.equalsIgnoreCase(TRIAL));
                if(deserializedInput.containsKey(PARAM_ACTIVE_STATUS) &&
                                        deserializedInput.containsKey(PARAM_DEAL_STATUS) &&
                                        (String.valueOf(deserializedInput.get(PARAM_ACTIVE_STATUS))).equalsIgnoreCase(ACTIVE_STATUS) &&
                                        (String.valueOf(deserializedInput.get(PARAM_DEAL_STATUS))).equalsIgnoreCase(LIVE)) {
                                if((tenant[0].Active_Status__c != null && tenant[0].Deal_Status__c != null) &&
                                                (tenant[0].Active_Status__c.equalsIgnoreCase(ACTIVE_STATUS) && tenant[0].Deal_Status__c.equalsIgnoreCase(TRIAL))) {
                                        // Update Convert Scenario
                                        System.debug('Came here to convert');
                                        convertUpdateScenario(tenant,lpartnerId,pp,ppc,PRMS);

                        } else if ((tenant[0].Active_Status__c != null && tenant[0].Deal_Status__c != null) &&
                                                (tenant[0].Active_Status__c.equalsIgnoreCase(ACTIVE_STATUS)
                                                && tenant[0].Deal_Status__c.equalsIgnoreCase(LIVE)) &&
                        (tenant[0].Seats_Allocated__c != seats || tenant[0].Plan_Code__c != plancode )) {
                                        if(deserializedInput.containsKey(PARAM_SEATS)) {
                                                Partner_Plan__c currentPP = getPartnerPlan(tenant[0].plan_code__c);
                                                Partner_Plan_Customization__c currentPPC;
                                               

                                                if(currentPP != null) {
                                                        currentPPC = getPartnerPlanCustomize(lpartnerId[0].Id, currentPP.Id);
                                                        List<Partner_Discount__c> cpd = getdiscount(currentPPC.Id);
                                                        if(!cpd.isEmpty()) {
                                                        CDiscount = cpd[0].Discount__c == null ? 0 : cpd[0].Discount__c/100;
                                                        }
                                                        List<Partner_Discount__c> rpd = getdiscount(ppc.Id);
                                                        if(!rpd.isEmpty()) {
                                                        RDiscount = rpd[0].Discount__c == null ? 0 : rpd[0].Discount__c/100;
                                                        }
                                                        Decimal requestedPartnerPrice = seats
                                                                        * ((decimal)pp.get(PRMS.Amount__c) == null ? 0 : (decimal)pp.get(PRMS.Amount__c));
                                                        
                                                                requestedPartnerPrice=requestedPartnerPrice-RDiscount*requestedPartnerPrice;

                                                        Decimal currentPartnerPrice = (tenant[0].Seats_Allocated__c == null ? 0 : tenant[0].Seats_Allocated__c)
                                                                         * ((decimal)currentPP.get(PRMS.Amount__c) == null ? 0 : (decimal)currentPP.get(PRMS.Amount__c));
                                                                currentPartnerPrice=currentPartnerPrice-CDiscount*currentPartnerPrice;
                                                                
                                                        System.debug('checking requested price---'+requestedPartnerPrice+'---'+currentPartnerPrice);
                                                        /*****************************************Current Month Comment
                                                         if ( Date.Today().Month() == (tenant[0].Original_Live_Date__c == null ? 0 : tenant[0].Original_Live_Date__c.Month()) &&
                                                              Date.Today().Year() == (tenant[0].Original_Live_Date__c == null ? 0 : tenant[0].Original_Live_Date__c.Year())){
                                                         	
                                                         	Decimal ChannelAmountSp = (seats * ((decimal)pp.get(PRMS.ChannelAmount__c) == null ? 0 : (decimal)pp.get(PRMS.ChannelAmount__c)));
                                                         	
                                                         	List<Opportunity> oppl = getwonOppotunity(tenant[0].Id);
																			if(!oppl.isEmpty()) {
																			opp=oppl[0];
																			variousScenarios(tenant, lpartnerId, pp, ppc,
                                                                                        requestedPartnerPrice , seats , ChannelAmountSp ,
                                                                                        CLOSED_WON,'New', opp,seats,false,PRMS );
																			}  
                                                         	
                                                         } else ************************************************************/ 
                                                         if(requestedPartnerPrice - currentPartnerPrice > 0) {
                                                                        Decimal ChannelAmountSp = (seats * ((decimal)pp.get(PRMS.ChannelAmount__c) == null ? 0 : (decimal)pp.get(PRMS.ChannelAmount__c)))
                                                                        - (tenant[0].Seats_Allocated__c * ( (decimal)currentPP.get(PRMS.ChannelAmount__c) == null
                                                                        ? 0 :  (decimal)currentPP.get(PRMS.ChannelAmount__c)));
                                                                        opp = new Opportunity();
																			variousScenarios(tenant, lpartnerId, pp, ppc,
                                                                                        (requestedPartnerPrice-currentPartnerPrice),(seats-tenant[0].Seats_Allocated__c) , ChannelAmountSp ,
                                                                                        CLOSED_WON,Upsell, opp,seats,true,PRMS );
																			  
                                                                        System.debug('Came here to add upgrade');
                                                                        

                                                        } else {
                                                                System.debug('Came here to remove downgrade');
                                                                Decimal ChannelAmountSp = (seats * ((decimal)pp.get(PRMS.ChannelAmount__c) == null ? 0 : (decimal)pp.get(PRMS.ChannelAmount__c)))
                                                                        - (tenant[0].Seats_Allocated__c * ((decimal)currentPP.get(PRMS.ChannelAmount__c) == null
                                                                        ? 0 : (decimal)currentPP.get(PRMS.ChannelAmount__c)));
                                                                        
																			opp = new Opportunity();
																		 
                                                                        //remove downgrade scenario.
                                                                        opp.Original_Close_Date__c = System.today();
                                                                        variousScenarios(tenant, lpartnerid, pp, ppc,(requestedPartnerPrice-currentPartnerPrice), (seats-tenant[0].Seats_Allocated__c), ChannelAmountSp,
                                                                                        Cancellation, CHURN ,opp,seats,false,PRMS);
                                                        }
                                                }

                                        }
                        } else if((tenant[0].Active_Status__c != null && tenant[0].Deal_Status__c != null) &&
                                                (tenant[0].Active_Status__c.equalsIgnoreCase(DEACTIVATE)
                                                && tenant[0].Deal_Status__c.equalsIgnoreCase(LIVE))) {
                                                tenant[0].Active_Status__c = ACTIVE_STATUS;
                                                opp = new Opportunity();
                                                // update Resume scenario reactivation
                                                System.debug('Came here to update Resume');
                                                        variousScenarios(tenant, lpartnerid, pp, ppc,Amount,seats,ChannelAmount,
                                                        CLOSED_WON ,REACTIVATION, opp,seats,true,PRMS);
                        } else if((tenant[0].Active_Status__c != null && tenant[0].Deal_Status__c != null) &&
                                                (tenant[0].Active_Status__c.equalsIgnoreCase(DEACTIVATE)
                                                && tenant[0].Deal_Status__c.equalsIgnoreCase(TRIAL))) {
                                                tenant[0].Active_Status__c = ACTIVE_STATUS;
                                                tenant[0].Deal_Status__c = LIVE;
                                                tenant[0].Most_Recent_Active_Date__c=date.today();
                                                tenant[0].Original_Live_Date__c=date.today();
                                                List<Opportunity> oppl = getlostOppotunity(tenant[0].Id);
                        						if(!oppl.isEmpty()) {
                        						opp = oppl[0];
                        						} else {
                                                opp = new Opportunity();
                        						}
                                                // update Resume scenario Reactivation with new
                                                System.debug('Came here to update Resume');
                                                        variousScenarios(tenant, lpartnerid, pp, ppc,Amount,seats,ChannelAmount,
                                                        CLOSED_WON ,'NEW', opp,seats,false,PRMS);
                        } else if((tenant[0].Active_Status__c != null && tenant[0].Deal_Status__c != null) &&
                                                (tenant[0].Active_Status__c.equalsIgnoreCase(ACTIVE_STATUS) && tenant[0].Deal_Status__c.equalsIgnoreCase(Live)) &&
                        (tenant[0].Seats_Allocated__c == seats && tenant[0].Plan_Code__c == plancode )) {
                                        // Update Edit Live Scenario
                                        System.debug('Came here to update edit live');
                                        Updateeditlive(tenant,Live,lpartnerid,pp,ppc,seats,PRMS);

                        }

                }  else if (deserializedInput.containsKey(PARAM_ACTIVE_STATUS) &&
                                        deserializedInput.containsKey(PARAM_DEAL_STATUS) &&
                                        (String.valueOf(deserializedInput.get(PARAM_ACTIVE_STATUS))).equalsIgnoreCase(ACTIVE_STATUS) &&
                                        (String.valueOf(deserializedInput.get(PARAM_DEAL_STATUS))).equalsIgnoreCase(TRIAL)){ // Edit-Trial scenario
                                        if((tenant[0].Active_Status__c != null && tenant[0].Active_Status__c.equalsIgnoreCase(ACTIVE_STATUS)) &&
                                                (tenant[0].Deal_Status__c != null && tenant[0].Deal_Status__c.equalsIgnoreCase(TRIAL)) ) {
                                                        System.debug('Came here to update edit trial');
                                                Updateeditlive(tenant,TRIAL,lpartnerid,pp,ppc,seats,PRMS);

                                        }

                }
        }
        /**
         * Assigns values for Editlive Scenario
         *
         * @param List<Tenant__c>
         *
         * @author Nikhil(Perficient)
         */
        private static void Updateeditlive(List<Tenant__c> tenant,String Condition,list<Account> lpartnerid
        ,Partner_Plan__c pp ,Partner_Plan_Customization__c ppc,Decimal seats ,PRM_Settings__c PRMS) {
                        if(Condition.equalsIgnoreCase(TRIAL)){// only work for Edit-Trial scenario

                        List<Opportunity> opp = getOppotunity(tenant[0].Id);
                                if(!opp.isEmpty()) {
                                                Partner_Plan__c currentPP = getPartnerPlan(tenant[0].plan_code__c);
                                                Partner_Plan_Customization__c currentPPC;
                                                Decimal requestedPartnerPrice = 0 ;
                                                Decimal currentPartnerPrice;
                                                Decimal RDiscount = 0;
                                                Decimal CDiscount = 0;
                                                
                                                if(currentPP != null) {
                                                        currentPPC = getPartnerPlanCustomize(lpartnerId[0].Id, currentPP.Id);
                                                        List<Partner_Discount__c> cpd = getdiscount(currentPPC.Id);
                                                        if(!cpd.isEmpty()) {
                                                        CDiscount = cpd[0].Discount__c == null ? 0 : cpd[0].Discount__c/100;
                                                        }
                                                        List<Partner_Discount__c> rpd = getdiscount(ppc.Id);
                                                        if(!rpd.isEmpty()) {
                                                        RDiscount = rpd[0].Discount__c == null ? 0 : rpd[0].Discount__c/100;
                                                        }
                                                        requestedPartnerPrice = seats
                                                                        * ((decimal)pp.get(PRMS.Amount__c) == null ? 0 : (decimal)pp.get(PRMS.Amount__c));
                                                        requestedPartnerPrice=requestedPartnerPrice-RDiscount*requestedPartnerPrice;
                                                     /**   currentPartnerPrice = (tenant[0].Seats_Allocated__c == null ? 0 : tenant[0].Seats_Allocated__c)
                                                                         * (currentPP.Partner_Price__c == null ? 0 : currentPP.Partner_Price__c);
                                                        currentPartnerPrice=currentPartnerPrice-CDiscount*currentPartnerPrice;
                                                        
                                                        System.debug('checking requested price---'+requestedPartnerPrice+'---'+currentPartnerPrice);
                                                        //if(requestedPartnerPrice - currentPartnerPrice > 0 **/
                                                }
                                
                                //Decimal UpAmountSp=requestedPartnerPrice - currentPartnerPrice ;
                                opp[0].Account_Type_Sold__c = pp.Account_Type_Sold__c;
                                opp[0].Amount=requestedPartnerPrice;
                                //opp[0].Best_Case__c=requestedPartnerPrice;
                                opp[0].OwnerId=PRMS.Ownerid__c;
                                opp[0].Channel_Amount__c=seats * (decimal)pp.get(PRMS.ChannelAmount__c);
                                opp[0].CloseDate = Date.parse((String)deserializedInput.get('trialenddate'));
                                opp[0].Trial_End_Date__c = Date.parse((String)deserializedInput.get('trialenddate'));
                                opp[0].Seats_Sold__c = seats;
                                opp[0].Reseller_ID__c=String.valueOf(lpartnerid[0].Reseller_ID__c);
                                opp[0].Name =lpartnerid[0].Name + ' ' + 'New ' + (opp[0].Seats_Sold__c == null ? '' :
                                                String.valueOf(opp[0].Seats_Sold__c))+' '+opp[0].Account_Type_Sold__c+' '+
												(getAccName(tenant[0].Account__c)[0].name == null ? '' : getAccName(tenant[0].Account__c)[0].name);
														
                                  
                                opp[0].Contact_Method_Most_Recent__c = PRMS.API_Contact_Method__c;
                                opp[0].Plan_Code__c=pp.Plan_Code__c == null ? '' :
                                                        pp.Plan_Code__c;
                                if(opp[0].StageName == CLOSED_WON){
                        		opp[0].Approval_Stage__c='Provisioned';	
                        			}
                                }
                                update opp;
                                tenant[0] = formTenantRec(tenant[0], pp ,ppc, seats);

                        }

                        list<contact> lcon = [Select id,Email,Phone,FirstName,lastname from Contact where
                                                                                id = : tenant[0].Admin__c ];
                if(deserializedInput.containsKey('account')){
                if(!lcon.isEmpty() && !subDetails.isEmpty() ){
                if(subDetails.containsKey('firstname')){
                lcon[0].FirstName=String.valueOf(subDetails.get('firstname'));
                }
                lcon[0].LastName=String.valueOf(subDetails.get('lastname'));
                if(subDetails.containsKey('phone')){
                lcon[0].Phone=String.valueOf(subDetails.get('phone'));
                }
                lcon[0].email=String.valueOf(subDetails.get('email'));
                lcon[0].OwnerId=PRMS.Ownerid__c;
                Update lcon;
                }
                }
                list<Account> lact = [Select id,Name,BillingStreet,BillingCity,BillingCountry,
                                                                BillingPostalCode,NumberOfEmployees,Box_Enterprise_ID__c from Account where
                                                                                id = : tenant[0].Account__c ];
                if(!lact.isEmpty()){
                if(deserializedInput.containsKey('companyname')){
                lact[0].name=String.valueOf(deserializedInput.get('companyname'));
                }
                if(deserializedInput.containsKey('street')){
                lact[0].BillingStreet=String.valueOf(deserializedInput.get('street'));
                }
                if(deserializedInput.containsKey('city')){
                lact[0].BillingCity=String.valueOf(deserializedInput.get('city'));
                }
                if(deserializedInput.containsKey('country')){
                lact[0].BillingCountry=String.valueOf(deserializedInput.get('country'));
                }
                if(deserializedInput.containsKey('zip')){
                lact[0].BillingPostalCode=String.valueOf(deserializedInput.get('zip'));
                }
                if(deserializedInput.containsKey('employees')){
                lact[0].NumberOfEmployees=Integer.valueOf(String.valueOf(deserializedInput.get('employees')));
                }
                lact[0].OwnerId=PRMS.Ownerid__c;
                update lact;
                }
                if(deserializedInput.containsKey('account')){
                tenant[0].Admin_Name__c= subDetails.containsKey('firstname')? String.valueOf(subDetails.get('firstname')):''+String.valueOf(subDetails.get('lastname'));
                tenant[0].Admin_Phone__c=subDetails.containsKey('phone')? String.valueOf(subDetails.get('phone')):'';
                tenant[0].Admin_Email__c= String.valueOf(subDetails.get('email'));
                }
                tenant[0].Billing_Cycle__c=deserializedInput.containsKey('billingcycle')? String.valueOf(deserializedInput.get('billingcycle')):'';
                tenant[0].Last_Activity_Date__c=System.today();
                updateTenant(tenant[0]);
                }

        /**
         * Assigns values for add/upgrade, remove/downgrade Scenario
         *
         * @param List<Tenant__c>
         * @param List<Account>
         * @param Partner_Plan__c
         * @param Partner_Plan_Customization__c
         *
         * @author Santoshi(Perficient)
         */
        private static void variousScenarios(List<Tenant__c> tenant,List<Account> lpartnerid ,
                        Partner_Plan__c pp ,Partner_Plan_Customization__c ppc , Decimal partnerPrice , Decimal seats ,
                                        Decimal ChannelAmount , String stage , String oppName ,
                                        Opportunity opp,Decimal tseats,Boolean runfcrm,PRM_Settings__c PRMS) {
                        Campaign_Map_Definition__c CMD = Campaign_Map_Definition__c.getInstance('Primary');
                        CampaignMember cmn= New CampaignMember();
                        String assigncampaign;
                        
                        list<CampaignMember> lcam;
		
                        
                        opp = formOppRec(tenant, lpartnerid, opp, pp, ppc, Seats,oppName,PRMS);
                        opp.RecordTypeId=PRMS.BoxAPIClosedWonRecordtype__c;
                        opp.Amount = math.abs(partnerPrice);
                        //opp.Best_Case__c=math.abs(partnerPrice);
                        opp.Channel_Amount__c = math.abs(ChannelAmount);
                        opp.StageName = stage ;
                        if(opp.StageName == CLOSED_WON){
                        opp.Approval_Stage__c='Provisioned';	
                        }
                        if(opp.StageName == Cancellation){
                        opp.Primary_Churn_Reason__c=PRMS.Primary_Churn_Reason__c;	
                        }
                        addUpdateOpportunity(opp);
                        if(!tenant[0].Active_Status__c.equalsIgnoreCase(DEACTIVATE)) {
                                tenant[0] = formTenantRec(tenant[0], pp ,ppc, tseats);
                        } else {
                        tenant[0] = formTenantRec(tenant[0], pp ,ppc, tseats);
                        tenant[0].Active_Status__c=ACTIVE_STATUS;
                        }

                        updateTenant(tenant[0]);
                if(opp.StageName == CLOSED_WON && runfcrm){
                OpportunityContactRole oppContactRole = new OpportunityContactRole(ContactId=tenant[0].Admin__c, OpportunityId=opp.Id, IsPrimary=True, Role='Business  User');
                insert oppContactRole;
                }
        //Campign Member Association
                if(opp.StageName == CLOSED_WON && runfcrm){
                String querystr = 'select '+CMD.Object_Field__c+' from '+CMD.Object_Type__c+' where id = \''+lpartnerid[0].id+'\'';
                sObject so;
                so =  database.query(querystr);
                if(so.get(CMD.object_Field__c) == null || so.get(CMD.object_Field__c) == ''){
                assigncampaign = cmd.Default_Campaign__c;
                } else {
                assigncampaign = (String)so.get(CMD.object_Field__c);
                }
                CampaignMember cm= New CampaignMember(CampaignId=assigncampaign, ContactId= tenant[0].Admin__c,Status='Responded',FCRM__FCR_Admin_Response_Control__c=138,FCRM__FCR_Opportunity__c=opp.id );
                insert cm;
                // part to addd campaign menmer to opportunity
                List<id> cid = new List<id>();
                cid.add(tenant[0].Admin__c);
                List<CampaignMember> GetActRes=FCRM.FCR_SupportAPI.GetActiveResponses(cid);
                if(GetActRes.isEmpty()){
                cmn.Id=cm.id;
                } else {
                cmn.Id=GetActRes[0].id;
                }
                cmn.FCRM__FCR_Admin_Response_Control__c=8;
                cmn.FCRM__FCR_Opportunity__c=opp.id;
                Update cmn;
                }
        }

        /**
         * Assigns values for convert/update Scenario
         *
         * @param List<Tenant__c>
         * @param List<Account>
         * @param Partner_Plan__c
         * @param Partner_Plan_Customization__c
         *
         * @author Santoshi(Perficient)
         */
        private static void convertUpdateScenario(List<Tenant__c> tenant,List<Account> lpartnerid ,
                        Partner_Plan__c pp ,Partner_Plan_Customization__c ppc,PRM_Settings__c PRMS) {
                List<Opportunity> opp = getOppotunity(tenant[0].Id);
                
                        if(!opp.isEmpty()) {
                                if(pp != null && pp.Account_Type_Sold__c != null) {
                                        opp[0].Account_Type_Sold__c = pp.Account_Type_Sold__c;
                                }
                                        Decimal Discount = 0;
                                        List<Partner_Discount__c> pd = getdiscount(ppc.Id);
                                        if(!pd.isEmpty()) {
                                        Discount = pd[0].Discount__c == null ? 0 : pd[0].Discount__c/100;
                                        }
                                        Decimal seats;
                                        if(deserializedInput.get(PARAM_SEATS) != null) {
                                                seats = Decimal.valueOf((String)deserializedInput.get(PARAM_SEATS));
                                                opp[0].Seats_Sold__c = seats;
                                                if(pp.get(PRMS.Amount__c) != null) {
                                                        opp[0].Amount = seats * ((decimal)pp.get(PRMS.Amount__c)-discount*(decimal)pp.get(PRMS.Amount__c));
                                                		//opp[0].Best_Case__c=seats * ((decimal)pp.get(PRMS.Amount__c)-discount*(decimal)pp.get(PRMS.Amount__c));
                                                }
                                                if (pp.get(PRMS.ChannelAmount__c) != null) {
                                                        opp[0].Channel_Amount__c = seats * (decimal)pp.get(PRMS.ChannelAmount__c);
                                                }
                                        }
                                                opp[0].CloseDate = System.Today();
                                                opp[0].StageName = CLOSED_WON;
                                                opp[0].Reseller_ID__c=String.valueOf(lpartnerid[0].Reseller_ID__c);
                                                opp[0].RecordTypeId=PRMS.BoxAPIClosedWonRecordtype__c;
                                                opp[0].Contact_Method_Most_Recent__c = PRMS.API_Contact_Method__c;
                                                opp[0].OwnerId=PRMS.Ownerid__c;
                                                opp[0].Approval_Stage__c='Provisioned';
                                                opp[0].Name =lpartnerid[0].Name + ' ' + 'New ' + (opp[0].Seats_Sold__c == null ? '' :
                                                String.valueOf(opp[0].Seats_Sold__c))+' '+opp[0].Account_Type_Sold__c+' '+
                                                (getAccName(tenant[0].Account__c)[0].name == null ? '' : getAccName(tenant[0].Account__c)[0].name);
                                                
                                        System.debug('checking opty name---'+opp[0].Name );
                                        tenant[0] = formTenantRec(tenant[0], pp ,ppc, seats);
                                        tenant[0].Deal_Status__c = (String)deserializedInput.get('dealstatus');
                                        updateTenant(tenant[0]);
                                        addUpdateOpportunity(opp[0]);
                                }
        }

        /**
         * Update/inserts opportunity.
         *
         * @param Opportunity
         *
         * @author Santoshi(Perficient)
         */
        private static void addUpdateOpportunity(Opportunity opp) {
                upsert opp;
                System.debug('*****upsert'+opp);
        }

        /**
                * Returns partner plan record.
                *
                * @return Partner_Plan__c
                *
                * @author Santoshi(Perficient)
                */
                private Static Partner_Plan__c getPartnerPlan(String pcode) {
                        List<Partner_Plan__c> partnerPlan = [SELECT Id,Name, Description__c,Plan_Code__c,
                                        Tier_Level__c, Account_Type_Sold__c,
                                        Retail_Price__c, Partner_Price__c
                                        FROM Partner_Plan__c
                                        WHERE Plan_Code__c = :pcode  LIMIT 1];
                        if(!partnerPlan.isEmpty()) {
                                return partnerPlan[0];
                        }
                        return null;
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
                * Retrieves opportunity related to specific tenant.
                *
                * @param Id
                *
                * @author Santoshi(Perficient)
                */
                private static List<Opportunity> getOppotunity (Id TenantId) {
                        return [SELECT o.Tenant__c, o.StageName, o.Seats_Sold__c, o.Name,
                                o.Id, o.CloseDate, o.Channel_Amount__c, o.Amount,
                                o.Account_Type_Sold__c,o.Approval_Stage__c,o.ownerid
                                FROM Opportunity o
                                WHERE o.tenant__c = : TenantId
                                AND o.tenant__c  != null ORDER BY SystemModstamp DESC limit 1  ];
                }
                
                 /**
                * Retrieves Lost opportunity related to specific tenant.
                *
                * @param Id
                *
                * @author Santoshi(Perficient)
                */
                private static List<Opportunity> getlostOppotunity (Id TenantId) {
                        return [SELECT o.Tenant__c, o.StageName, o.Seats_Sold__c, o.Name,
                                o.Id, o.CloseDate, o.Channel_Amount__c, o.Amount,o.Approval_Stage__c,o.ownerid,
                                o.Account_Type_Sold__c
                                FROM Opportunity o
                                WHERE o.tenant__c = : TenantId
                                AND o.tenant__c  != null And StageName = 'Closed Lost' ORDER BY SystemModstamp DESC limit 1  ];
                }
                

                /**
                 * Assigns values to tenant record.
                 *
                 * @author Santoshi(Perficient)
                 */
                private static Tenant__c formTenantRec(Tenant__c tenant , Partner_Plan__c pp ,
                                Partner_Plan_Customization__c ppc , Decimal Seats) {
                                // tenant modification
                                        tenant.Seats_Allocated__c = seats == null ? 0 : seats;
                                        tenant.Space_Allocated__c = ppc.space_Amount__c == null ? 0 : ppc.space_Amount__c;
                                        tenant.Account_Type__c = pp.Account_Type_Sold__c;
                                        tenant.Last_Activity_Date__c = System.today();
                                        tenant.Plan_Code__c = pp.Plan_Code__c == null ? '' :
                                                        pp.Plan_Code__c;
                                        return tenant;
                }

                /**
                 * Assigns values to Opportunity record.
                 *
                 * @author Santoshi(Perficient)
                 */
                private static Opportunity formOppRec(List<Tenant__c> tenant,List<Account> lpartnerid ,
                                Opportunity opp , Partner_Plan__c pp ,Partner_Plan_Customization__c ppc , Decimal Seats ,
                                String oppName,PRM_Settings__c PRMS) {
						
						
                                                        // opportunity modification
                        opp.Account_Type_Sold__c = pp.Account_Type_Sold__c;
                        opp.Box_Enterprise_ID__c = tenant[0].Enterprise_ID_Tenant__c;
                        opp.Box_Partner_Account__c = lpartnerId[0].Id;
                        opp.CloseDate = System.today();
                        opp.Reseller_ID__c=String.valueOf(lpartnerid[0].Reseller_ID__c);
                        opp.Provisioning_Date__c=System.today();
                        opp.Payment_Term__c=ppc.Contract_Term__c;
                        opp.CurrencyIsoCode=ppc.CurrencyIsoCode;
                        opp.Contact_Method_Most_Recent__c = PRMS.API_Contact_Method__c;
                        opp.Fee_Frequency__c = lpartnerid[0].API_Fee_Frequency__c;
                        opp.Box_Entity__c=lpartnerid[0].API_Box_Entity__c;
                        opp.Payment_Method__c = lpartnerid[0].API_Payment_Method__c;
                        opp.Primary_Contact__c = tenant[0].Admin__c;
                        opp.Plan_Code__c=pp.Plan_Code__c == null ? '' :
                                                        pp.Plan_Code__c;
                        opp.Rep_Quota_Relief__c = lpartnerid[0].API_Rep_Deal__c;
                        opp.Seats_Sold__c = math.abs(seats);
                        opp.Tenant__c=tenant[0].id;
                        opp.Accountid=tenant[0].Account__c;
                        opp.OwnerId=PRMS.Ownerid__c;
                        opp.Name =lpartnerid[0].Name + ' ' + oppName + ' ' + (opp.Seats_Sold__c == null ? '' :
                                String.valueOf(opp.Seats_Sold__c))+' '+opp.Account_Type_Sold__c+' '+
                                (getAccName(tenant[0].Account__c)[0].name == null ? '' : getAccName(tenant[0].Account__c)[0].name);
                        return opp;
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
                                AND o.tenant__c  != null And ( o.StageName In ('Closed Won','Cancellation - Churn')) ORDER BY SystemModstamp ];
                }


}