public with sharing class PerfBA_TestData {

	public static Account createAccount(String rid) {
	Account acc = new Account();
		acc.Name = 'TestAcc';
		acc.Reseller_ID__c=decimal.valueOf(rid);
		insert acc;
		return acc;
	}
	public static Account createcustomerAccount() {
	Account accc = new Account();
		accc.Name = 'TestcusAcc';
		insert accc;
		return accc;
	}
	public static Contact createcustomerContact(string cemail, String aid) {
	Contact con =  new Contact();
		con.FirstName = 'test';
		con.LastName = 'one';
		con.Email = cemail;
		con.accountid=aid;
		insert con;
	return con;
	}

	public static Partner_Plan__c createPartnerPlan( String plancode) {
	Partner_Plan__c pp = new Partner_Plan__c();
		pp.Plan_Code__c = plancode ;
		pp.Account_Type_Sold__c='Starter';
		pp.Partner_Price__c=4;
		pp.Retail_Price__c=3;
		insert pp;
		return pp;
	}
	public static Partner_Plan_Customization__c createPartnerPlanCustomization(String plancode,String accid) {
	Partner_Plan_Customization__c ppc = new Partner_Plan_Customization__c();
		ppc.space_Amount__c = 100 ;
		ppc.Account__c=accid;
		ppc.Partner_Plan__c=plancode;
		insert ppc;
		return ppc;
	}
	public static Tenant__c createtenant(String temail,string accc) {
		Tenant__c lt = new Tenant__c();
		lt.Admin_Email__c = temail;
		lt.account__c = accc;
		insert lt;
		return lt;
	}

	public static Campaign_Map_Definition__c createsetting(String campid) {
	Campaign_Map_Definition__c lcs = new Campaign_Map_Definition__c();
		lcs.Default_Campaign__c = campid;
		lcs.Object_Field__c = 'Campaign__c';
		lcs.Object_Type__c='Account';
		lcs.name='Primary';
		insert lcs;
		return lcs;
	}
	
	public static PRM_Settings__c createPRMsetting() {
	PRM_Settings__c lcs = new PRM_Settings__c();
		 
		lcs.Ownerid__c='00560000001FyKa';
		lcs.Amount__c='Partner_Price__c';
		lcs.ChannelAmount__c='Retail_Price__c';
		lcs.name='default';
		lcs.Primary_Churn_Reason__c='Other';
		insert lcs;
		return lcs;
	}

	public static Campaign createcampaign() {
	Campaign lc = new Campaign();
		lc.Name = 'Universal';
		lc.Type = 'Blog';
		lc.StartDate = Date.today();
		lc.EndDate = Date.today().adddays(25);
		lc.Status = 'New';
		insert lc;
		return lc;
	}

	public static Partner_Key_Account__c createpka(string pka,string accc,string acc) {
	Partner_Key_Account__c lpka= New Partner_Key_Account__c();
	lpka.Key__c=pka;
	lpka.Account__c=accc;
	lpka.Partner__c=acc;
	insert lpka;
	return lpka;
	}

	public static Opportunity createopp(string tid,string accc,string acc,string Sn,String eid) {
	Opportunity opp= New Opportunity();
	opp.Accountid=accc;
	opp.StageName=Sn;
	opp.Name='Test opp';
	opp.CloseDate=date.today().addDays(2);
	opp.Tenant__c=tid;
	opp.Box_Partner_Account__c=acc;
	opp.Box_Enterprise_ID__c=eid;
	insert opp;
	return opp;
	}

	public static Partner_Plan__c createpplan(Decimal tlevel,String pcode) {
	Partner_Plan__c lpplan= New Partner_Plan__c();
	lpplan.name='Test';
	lpplan.Tier_Level__c=tlevel;
	lpplan.Plan_Code__c=pcode;
	insert lpplan;
	return lpplan;
	}
		public static Partner_Discount__c createdisc(String rid) {
	Partner_Discount__c acc = new Partner_Discount__c();
		acc.Partner_Plan_Customization__c = rid;
		acc.Discount__c=10;
		insert acc;
		return acc;
	}

}