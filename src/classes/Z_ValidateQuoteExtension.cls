public class Z_ValidateQuoteExtension {
	

	private final zqu__Quote__c quote;
	

	public Z_ValidateQuoteExtension(ApexPages.StandardController controller){
		quote = (zqu__Quote__c) controller.getRecord();	
 
	}
 

	public PageReference processQuote(){
		
		List <ApexPages.Message> messages;
		
		processMessages(Z_QuoteValidationUtility.validateQuote(quote.Id));

		if(ApexPages.hasMessages()){
		
			
		}else{

			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This quote has passed all validations.'));
		}
		
		return null;

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