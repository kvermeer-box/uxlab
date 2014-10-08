public class Z_DeleteQuoteExtension {
	

	private final zqu__Quote__c zQuote;
	private boolean allowDeleteQuote  {get;set;}
	private Id oppId				  {get;set;}
		

	public Z_DeleteQuoteExtension(ApexPages.StandardController controller){
		zQuote = (zqu__Quote__c) controller.getRecord();	
		oppId=zQuote.zqu__Opportunity__c;
	}
 

	public PageReference deleteQuote(){
		
		try{
		
			delete zQuote;	
			
		}catch(Exception e){
			ApexPages.addMessages(e);
			return null;
		}

		Opportunity opp = new Opportunity(id=oppId);
		PageReference oppPage = new ApexPages.StandardController(opp).view();
        oppPage.setRedirect(true);
        
        return oppPage;	
	}
	

	public Boolean getAllowDelete(){
		
		return allowDeleteQuote;
	}
 
	public PageReference processQuote(){
		
		List <ApexPages.Message> messages;
		
		processMessages(validateQuote());

		if(ApexPages.hasMessages()){
			
			allowDeleteQuote=false;
			
			return null;
			
		}else{

			allowDeleteQuote=true;
			
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, LABEL.Z_QUOTE_DELETE_CONFIRMATION));
		}
		
		return null;

	}//method ends

	private List <ApexPages.Message> validateQuote(){
	
		List <ApexPages.Message> messageList = new List <ApexPages.Message>();
 
		if(zQuote.Delete_Quote__c == false){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, LABEL.Z_DELETE_QUOTE_ERROR));
		}		
	
		return messageList;
			
	}	
	
	
	private void processMessages(List <ApexPages.Message> messages){

		if(messages==null || messages.size()==0){
			return;
		}
		
		 for(ApexPages.Message msg : messages){
		 
		 	ApexPages.addMessage(msg);	
		 		
		 }
		
		
	} 
}