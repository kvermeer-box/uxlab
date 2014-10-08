@RestResource(urlMapping='/RestTest/*')
global class RestTest {

	@HttpGet
	global static Opportunity getOpportunity(RestRequest req, RestResponse res) {		
		String opportunityId = req.params.get('oppId');
		List<Opportunity> oppList = [SELECT Id, Name, StageName, Amount, CloseDate, OwnerId, Use_Case_Primary__c FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
		Opportunity opp = oppList[0];
		return opp;				
	}	
	
	@HttpPost
	global static InAppClass testSerialization(InAppClass ia) {
		return ia;	
	}
	
	global class InAppClass {
		global String a;
		global String b;
		global Decimal c;
		global Decimal d;
	}

}