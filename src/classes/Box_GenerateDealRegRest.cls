@RestResource(urlMapping='/1.0/generateDealReg/*')
global with sharing class Box_GenerateDealRegRest {
	
	@HttpPost
	global static void doPost() {
		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;
		Map<String, String> reqParams = req.params;
		
		String accountId = reqParams.get('externalaccountid');
		Box_TestDealRegGenerator generator = new Box_TestDealRegGenerator(accountId);
		res.responseBody = Blob.valueOf(generator.generateDealRegRest());
	}
	
}