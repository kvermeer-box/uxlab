public class Z_SetPrimaryQuote {
 
	private zqu__Quote__c quote;
	private Id quoteId;
	
	public Z_SetPrimaryQuote(ApexPages.StandardController controller){ 
		
		quote = (zqu__Quote__c) controller.getRecord();	

        quote = [SELECT Id, Name, zqu__Opportunity__c FROM zqu__Quote__c 
                   WHERE Id = :quote.id]; 
                   		
	}


    public Z_SetPrimaryQuote() { 
    	
    	quoteId=ApexPages.currentPage().getParameters().get('id');

        quote = [SELECT Id, Name, zqu__Opportunity__c FROM zqu__Quote__c 
                   WHERE Id = :quoteId]; 
    }
 
 
	public PageReference cancel(){
 
		PageReference pageRef = new PageReference('/' + quote.zqu__Opportunity__c);
		return pageRef;

    }


	public PageReference processQuote(){
 
		
		List <ApexPages.Message> messages=Z_QuoteUtility.makeSignedQuote(quote.Id); 

		PageReference pageRef = null;

		if(messages.size()>0){

			processMessages(messages);	

		}else{ 
 
	        pageRef = new PageReference('/' + quote.zqu__Opportunity__c);


    	}

		return pageRef;

	}//method ends

	public void processMessages(List <ApexPages.Message> messages){

		if(messages==null || messages.size()==0){
			return;
		}
		
	 	for(ApexPages.Message msg : messages){
		 
			ApexPages.addMessage(msg);	
		 		
		}
	 }

 
}