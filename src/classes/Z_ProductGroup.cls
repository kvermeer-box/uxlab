public class Z_ProductGroup {

	public Map<String,Set<Id>> productGroupMap = new Map<String,Set<Id>>(); 

	public Z_ProductGroup (List<String> groupNames) {
 
		System.debug('>>>>>>>>>Z_ProductGroup<<<<<<<<<<<<');
				 
		if(groupNames==null || groupNames.size()==0){
			return;
		}
		
		Set<Id> productIds;
		Set<Id> allProductIds = new Set<Id>();
		 
		
		for(Product_Group_Member__c member : [Select p.Product_Zuora_Id__c, p.Product_Group__c, 
														p.Name, p.Id, p.Product_Group__r.Name,
														p.Product__c   
													From Product_Group_Member__c p
														Where p.Product_Group__r.Name in: groupNames]){
			
						
			productIds = productGroupMap.get(member.Product_Group__r.Name);
			
			if(productIds==null){
				productIds = new Set<Id>();	
			}
			
			productIds.add(member.Product__c);
															
			productGroupMap.put(member.Product_Group__r.Name, productIds);

											
		}//end-for 

 
			 
	}


	/* returns true if group members include product id */
	public boolean containsProduct(String groupName, Id productId){
		
		List<Id> productIds	= new List<Id>();
		productIds.add(productId);
		return containsProduct(groupName, productIds);
		
	}

	/* returns true if group members include any of the product ids */
	public boolean containsProduct(String groupName, List<Id> productIds){

		System.debug('>>>>>>>>>containsProduct<<<<<<<<<<<<');
	
		boolean containsProduct = false;

		System.debug('>>>>>groupName='+groupName);
		System.debug('>>>>>productIds='+productIds);
		
		if(groupName==null || productIds==null){
			return containsProduct;
		}
		
		Set<Id> productGroupMembers = productGroupMap.get(groupName);

		System.debug('>>>>>productGroupMembers='+productGroupMembers);

		if(productGroupMembers==null || productGroupMembers.size()==0){
			return containsProduct;
		}
		
		for(Id memberId : productGroupMembers){
		
			for(Id checkProductId : productIds){
				
				if(memberId==checkProductId){
					System.debug('>>>>>>>YES<<<<<<<<');
					containsProduct=true;
					return containsProduct;	
				}
			}		
			
		}
 
		return containsProduct;	
	
	}

	/* returns count of the product ids that are group members*/
	public integer countProduct(String groupName, List<Id> productIds){

		System.debug('>>>>>>>>>countProduct<<<<<<<<<<<<');
	
		integer productCount = 0;

		System.debug('>>>>>groupName='+groupName);
		System.debug('>>>>>productIds='+productIds);
		
		if(groupName==null || productIds==null){
			return productCount;
		}
		
		Set<Id> productGroupMembers = productGroupMap.get(groupName);

		System.debug('>>>>>productGroupMembers='+productGroupMembers);

		if(productGroupMembers==null || productGroupMembers.size()==0){
			return productCount;
		}
		
		for(Id memberId : productGroupMembers){
		
			for(Id checkProductId : productIds){
				
				if(memberId==checkProductId){
					System.debug('>>>>>>>YES<<<<<<<<');
					productCount=productCount+1;

				}
			}		
			
		}
		
		System.debug('>>>>>>>productCount='+productCount);
 
		return productCount;	
	
	}

	public set<Id> getMemberIds(String groupName){
	
		set<Id> memberIds = new set<Id>();
		
		if (groupName!=null && productGroupMap.containsKey(groupName)){
			return productGroupMap.get(groupName);
		}
		
		
		return memberIds;
		
	} 
}