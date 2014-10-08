public class Z_DisplayQuoteLinesExtension {

  	public zqu__Quote__c quote {get;set;}
  
	public List<QuoteLineItemWrapper> quoteLineItemList {get;set;}
   
  	public Integer countLines {
  		get{
  	
			if(quoteLineItemList != null){
	        	return quoteLineItemList.size();
	      	}else{
	        	return 0;
	      	}
  		}
  		set;
  	}
 
   
  
  	public Z_DisplayQuoteLinesExtension(ApexPages.StandardController controller) {
  	
		countLines = 0;
    	quoteLineItemList = new List<QuoteLineItemWrapper>();
    
    	quote = (zqu__Quote__c)controller.getRecord();
    
	    if(quote.Id != null){
	     
			for(zqu__Quote__c q : [select id, Name, Deal_Type__c from zqu__Quote__c where id  = :quote.Id Limit 1]){
	        	quote = q;
	      	}      
	      
	      	loadQuoteLineItems();
	    }
       
	}   
   
   	public void loadQuoteLineItems() {

		quoteLineItemList  = new List<QuoteLineItemWrapper>();
    
    	List<zqu__QuoteChargeSummary__c> quoteChargeSummaryList = queryQuoteLines();
    
	    for(zqu__QuoteChargeSummary__c qcs : quoteChargeSummaryList){
	    	
	            QuoteLineItemWrapper wrapper = new QuoteLineItemWrapper(qcs, qcs.Name);
	            quoteLineItemList.add(wrapper);
	            
	    }
  	}
   
	public List<zqu__QuoteChargeSummary__c> queryQuoteLines() {
    
    
		List<zqu__QuoteChargeSummary__c > lineItems = [Select z.zqu__UOM__c, z.zqu__Type__c, z.zqu__TotalPrice__c, 
																z.zqu__TCV__c, z.zqu__Quote_Charge__c, z.zqu__QuoteRatePlan__c, 
																z.zqu__QuoteRatePlanCharge__c, z.zqu__Quantity__c, 
																z.zqu__Product_Rate_Plan_Name__c, z.zqu__Product_Name__c, 
																z.zqu__Opportunity__c, z.zqu__Model__c, z.zqu__MRR__c, 
																z.zqu__ListTotal__c, z.zqu__ListPrice__c, z.zqu__EffectivePrice__c, 
																z.zqu__Discount__c, z.zqu__Description__c, z.Quote__c, 
																z.Quote_Unit_Price__c, z.Order_Amount__c, z.Name, 
																z.NRR__c, z.NRR_New__c, z.MRR_New__c, z.Id, 
																z.CurrencyIsoCode, z.Discount__c, z.Quote_Display_Name__c,
																z.MRR_Clean__c, z.Quote_Total_Price__c, z.Quote_Discount__c 
																    
															From zqu__QuoteChargeSummary__c z
                                    							where z.zqu__QuoteRatePlan__r.zqu__Quote__c = :quote.Id
                                    								and z.zqu__Quantity__c > 0
                                    									order by zqu__Type__c desc];
                                     
    
		  return lineItems;
  	}
  
    
    public class QuoteLineItemWrapper{ 
  	   
    	public String Name {get;set;}    
    	public zqu__QuoteChargeSummary__c quoteLineItem {get;set;}
    
    	public QuoteLineItemWrapper(zqu__QuoteChargeSummary__c quoteChargeSummary, string quoteChargeName){
    	
      	this.quoteLineItem = quoteChargeSummary;
      	this.Name = quoteChargeName; 
        
		}
    
  	}
  


}