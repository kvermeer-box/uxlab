public without sharing class OpportunityClosedWonRSIUpdate {
 // Start By Nikhil @ Perficient
  /**
  * Author:Nikhil @ 4/14/14
  * function: UpdateResellerSIAcct (public, static)
  * Description:
  *   This function updates the Contacts under Box Reseller Account or SI Partner Account
  *   Will check for Stage as  'Closed Won'.
  * Inputs:
  *   Map<Id,Opportunity> new_opps_map - Trigger.new
  *   Map<Id,Opportunity> old_opps_map - Trigger.old
  * Return:
  *   None
  */
  
  public static void AfterUpdateUpdateResellerSIAcct(Map<ID,Opportunity> new_opps_map,Map<ID,Opportunity> old_opps_map)
  {
  	set<ID> account_ids = new set<ID>();
  	set<ID> BPSIaccount_ids = new set<ID>();
  
  	List<Contact> ContactUpdateList =new List<Contact>();
  	
  	map<ID,Opportunity> Opps = new map<ID,Opportunity>();
    // Grabs all opps that are 'Closed Won'
    if (!InfiniteControl.inInfiniteContext) {
    for (Opportunity cur_opp : new_opps_map.values())
    {
    Opportunity old_opp = old_opps_map.get(cur_opp.id);

      if (cur_opp.IsWon) {
      	Opps.put(cur_opp.id,cur_opp);
      	if(cur_opp.AccountId != null ){
        account_ids.add(cur_opp.AccountId);
      	}
      	if(cur_opp.Box_Partner_Account__c != null && old_opp.Box_Partner_Account__c == cur_opp.Box_Partner_Account__c && !old_opp.IsWon && cur_opp.IsWon ){
        BPSIaccount_ids.add(cur_opp.Box_Partner_Account__c);
        }else if(cur_opp.Box_Partner_Account__c != null && old_opp.Box_Partner_Account__c != cur_opp.Box_Partner_Account__c){
        BPSIaccount_ids.add(cur_opp.Box_Partner_Account__c);
        }
      	if(cur_opp.Service_Partner_Account__c != null && old_opp.Service_Partner_Account__c == cur_opp.Service_Partner_Account__c && !old_opp.IsWon && cur_opp.IsWon ){
        BPSIaccount_ids.add(cur_opp.Service_Partner_Account__c);
       	}else if(cur_opp.Service_Partner_Account__c != null && old_opp.Service_Partner_Account__c != cur_opp.Service_Partner_Account__c){
        BPSIaccount_ids.add(cur_opp.Service_Partner_Account__c);
       	}
      } else if (!cur_opp.Iswon && !cur_opp.IsClosed) {
      	Opps.put(cur_opp.id,cur_opp);
      	if(cur_opp.AccountId != null ){
        account_ids.add(cur_opp.AccountId);
      	}
      	if(cur_opp.Box_Partner_Account__c != null && old_opp.Box_Partner_Account__c != cur_opp.Box_Partner_Account__c){
        BPSIaccount_ids.add(cur_opp.Box_Partner_Account__c);
        }
      	if(cur_opp.Service_Partner_Account__c != null && old_opp.Service_Partner_Account__c != cur_opp.Service_Partner_Account__c){
        BPSIaccount_ids.add(cur_opp.Service_Partner_Account__c);
      	}
      }
    }
   
   
    if(!Opps.isEmpty() && !BPSIaccount_ids.isEmpty() && !account_ids.isEmpty()){
    	   UpdateBPSIContact(Opps,account_ids,BPSIaccount_ids,false);         
      }
       
    } 
  
  }
  
 public static void AfterInsertUpdateResellerSIAcct(Map<ID,Opportunity> new_opps_map)
  {
  	set<ID> account_ids = new set<ID>();
  	set<ID> BPSIaccount_ids = new set<ID>();
  	map<ID,Opportunity> OpenOpps = new map<ID,Opportunity>();
  	if (!InfiniteControl.inInfiniteContext) {
    	for (Opportunity cur_opp : new_opps_map.values())
    	{
    		if (!cur_opp.Iswon && !cur_opp.IsClosed) {
    			OpenOpps.put(cur_opp.id,cur_opp);
		      	if(cur_opp.AccountId != null){
		        account_ids.add(cur_opp.AccountId);
		      	}
		      	if(cur_opp.Box_Partner_Account__c != null){
		        BPSIaccount_ids.add(cur_opp.Box_Partner_Account__c);
		      	}
		      	if(cur_opp.Service_Partner_Account__c != null){
		        BPSIaccount_ids.add(cur_opp.Service_Partner_Account__c);
		      	}
    		}
    	
    	}
    	if(!OpenOpps.isEmpty() && !BPSIaccount_ids.isEmpty() && !account_ids.isEmpty()){//Fresh opp not closed but check if have any open or Closed opportunity
      	          	
      		CheckOldandOpenOpp(OpenOpps,account_ids,BPSIaccount_ids); 
      	}
    	
   	}
  }
  
  private static void CheckOldandOpenOpp(Map<Id,Opportunity> OpenOpps, Set<Id> account_ids,Set<id> BPSIaccount_ids){
  	Map<id,Opportunity> AccOppMap = new Map<id,Opportunity>();
  	map<ID,Opportunity> OppsI = new map<ID,Opportunity>();
  	for(opportunity opp:[select Id,StageName,AccountId,Box_Partner_Account__c,Service_Partner_Account__c from Opportunity where AccountId in:account_ids and IsWon =: true ORDER BY CloseDate ASC]){
  	AccOppMap.put(opp.AccountId,opp);	
  	}
  	
  	For(id oppid: OpenOpps.keyset()){
  		if(AccOppMap.containskey(OpenOpps.get(oppid).Accountid)){
  			
  		}else 
  		{
  			OppsI.put(oppid,OpenOpps.get(oppid));
  		}
  	  		
  	}
  	
  	if(!OppsI.isEmpty()){
  		UpdateBPSIContact(OppsI,account_ids,BPSIaccount_ids,false);
  	}
  	
  }
  
  private static void UpdateBPSIContact(Map<Id,Opportunity> Opps, Set<Id> account_ids,Set<id> BPSIaccount_ids,Boolean Uncheck){
  	Map<id,list<Contact>> AccConMap = new Map<id,list<Contact>>();
  	Map<id,Opportunity> AccOppMap = new Map<id,Opportunity>();
  	Map<id,Opportunity> AccOppOpenMap = new Map<id,Opportunity>();
  	List<Account> AccountUpdateList = new List<Account>();
  	List<Contact> ContactUpdateList =new List<Contact>();
  	List<Opportunity> OpportunityUpdateList = new List<Opportunity>();

  	Boolean StopChecking = false;
  	Boolean AddToList = false;
  	Boolean AddAccountToList = false;
  	set<ID> SIaccount_ids = new set<ID>();
  	set<ID> BPaccount_ids = new set<ID>();
  	set<ID> BPSIOldaccount_ids = new set<ID>();
  	set<ID> OtherOppSIaccount_ids = new set<ID>();
  	set<ID> OtherOppBPaccount_ids = new set<ID>();
  	set<ID> OtherOppBPSIOldaccount_ids = new set<ID>();
  	/*****
  	for(Account Acc: [SELECT Id,Name, (SELECT id,Reseller_Customer_Contact__c,Service_Partner_Customer_Contact__C FROM Contacts) FROM Account where id in:BPSIaccount_ids]){
  	AccConMap.put(Acc.id,Acc.Contacts);	
  	}*****/
  	for(opportunity opp:[select Id,StageName,AccountId,Box_Partner_Account__c,Service_Partner_Account__c from Opportunity where AccountId in:account_ids and IsWon =: true and Id NOT IN:Opps.keyset() ORDER BY CloseDate ASC]){
  	AccOppMap.put(opp.AccountId,opp);
  	/*****
  	if(opp.Box_Partner_Account__c != null){
  		OtherOppBPSIOldaccount_ids.add(opp.Box_Partner_Account__c);
  		OtherOppBPaccount_ids.add(opp.Box_Partner_Account__c);
  	} else if(opp.Service_Partner_Account__c != null){
  		OtherOppBPSIOldaccount_ids.add(opp.Service_Partner_Account__c);
  		OtherOppSIaccount_ids.add(opp.Service_Partner_Account__c);
  	}	*****/
  	}
  	
  	for(opportunity opp:[select Id,StageName,AccountId,Box_Partner_Account__c,Service_Partner_Account__c from Opportunity where AccountId in:account_ids and IsWon=:false and Id NOT IN:Opps.keyset() ORDER BY CreatedDate ASC]){
  	AccOppOpenMap.put(opp.AccountId,opp);
  	/*****
  	if(opp.Box_Partner_Account__c != null){
  		OtherOppBPSIOldaccount_ids.add(opp.Box_Partner_Account__c);
  		OtherOppBPaccount_ids.add(opp.Box_Partner_Account__c);
  	} else if(opp.Service_Partner_Account__c != null){
  		OtherOppBPSIOldaccount_ids.add(opp.Service_Partner_Account__c);
  		OtherOppSIaccount_ids.add(opp.Service_Partner_Account__c);
  	}	*****/
  	}
  	
  	For(id oppid: opps.keyset()){
  		if(!opps.get(oppid).IsWon && AccOppMap.containskey(opps.get(oppid).Accountid)){
  			//to Stop If already a closed
  		} else	if(opps.get(oppid).Accountid != null){
  			Account acc= new account();
  			acc.id=opps.get(oppid).Accountid;
  			if(opps.get(oppid).Box_Partner_Account__c != null){
  				acc.Box_Reseller_Account__c=opps.get(oppid).Box_Partner_Account__c;
  				AddAccountToList=true;
  			}
  			if(opps.get(oppid).Service_Partner_Account__c != null){
  				acc.SI_Partner_Accounts__c=opps.get(oppid).Service_Partner_Account__c;
  				AddAccountToList=true;
  			}
  			if(AddAccountToList)AccountUpdateList.add(acc);
  		}
  		/*****
  		if(!opps.get(oppid).IsWon && AccOppMap.containskey(opps.get(oppid).Accountid)){
  			//to Stop If already a closed
  		} else if((!opps.get(oppid).IsWon && !AccOppMap.containskey(opps.get(oppid).Accountid)) ||
  		(opps.get(oppid).IsWon && opps.get(oppid).IsClosed)){//to only update if no Close opprtunity
  			
  		if(opps.get(oppid).Box_Partner_Account__c != null && opps.get(oppid).Box_Partner_Account__c != opps.get(oppid).Service_Partner_Account__c){
  			if(AccConMap.containskey(opps.get(oppid).Box_Partner_Account__c)){
  				if(!AccConMap.get(opps.get(oppid).Box_Partner_Account__c).isEmpty()){
  					   for(Contact cid : AccConMap.get(opps.get(oppid).Box_Partner_Account__c)){
  					   	   ContactUpdateList.add(new Contact(id=cid.id,Reseller_Customer_Contact__c=true));
  					 }
  				}
  			}
  			  			
  		}
  		if(opps.get(oppid).Service_Partner_Account__c != null && opps.get(oppid).Box_Partner_Account__c != opps.get(oppid).Service_Partner_Account__c){
  			if(AccConMap.containskey(opps.get(oppid).Service_Partner_Account__c)){
  				if(!AccConMap.get(opps.get(oppid).Service_Partner_Account__c).isEmpty()){
  					   for(Contact cid : AccConMap.get(opps.get(oppid).Service_Partner_Account__c)){
  					   	   ContactUpdateList.add(new Contact(id=cid.id,Service_Partner_Customer_Contact__C=true));
  					 }
  				}
  			}
  		  			
  		}
  		if(opps.get(oppid).Service_Partner_Account__c != null && opps.get(oppid).Box_Partner_Account__c != null &&
  			 opps.get(oppid).Box_Partner_Account__c == opps.get(oppid).Service_Partner_Account__c){
  			if(AccConMap.containskey(opps.get(oppid).Service_Partner_Account__c)){
  				if(!AccConMap.get(opps.get(oppid).Service_Partner_Account__c).isEmpty()){
  					   for(Contact cid : AccConMap.get(opps.get(oppid).Service_Partner_Account__c)){
  					   	   ContactUpdateList.add(new Contact(id=cid.id,Service_Partner_Customer_Contact__C=true,Reseller_Customer_Contact__c=true));
  					 }
  				}
  			}
  		  			
  		}
  		}
  		
  		
  		if(opps.get(oppid).Accountid != null){
  			if(AccOppMap.containskey(opps.get(oppid).Accountid)){
  				if(AccOppMap.get(opps.get(oppid).Accountid).Box_Partner_Account__c != opps.get(oppid).Box_Partner_Account__c){
  					BPaccount_ids.add(AccOppMap.get(opps.get(oppid).Accountid).Box_Partner_Account__c);
  					BPSIOldaccount_ids.add(AccOppMap.get(opps.get(oppid).Accountid).Box_Partner_Account__c);
  					AccOppMap.get(opps.get(oppid).Accountid).Box_Partner_Account__c=opps.get(oppid).Box_Partner_Account__c;
  					AddToList=true;
  				}
  				if(AccOppMap.get(opps.get(oppid).Accountid).Service_Partner_Account__c != opps.get(oppid).Service_Partner_Account__c){
  					SIaccount_ids.add(AccOppMap.get(opps.get(oppid).Accountid).Service_Partner_Account__c);
  					BPSIOldaccount_ids.add(AccOppMap.get(opps.get(oppid).Accountid).Service_Partner_Account__c);
  					AccOppMap.get(opps.get(oppid).Accountid).Service_Partner_Account__c=opps.get(oppid).Service_Partner_Account__c;
  					AddToList=true;
  				}
  				if(AddToList)OpportunityUpdateList.add(AccOppMap.get(opps.get(oppid).Accountid));
  			}else if(AccOppOpenMap.containskey(opps.get(oppid).Accountid)){
  				
  				if(AccOppOpenMap.get(opps.get(oppid).Accountid).Box_Partner_Account__c != opps.get(oppid).Box_Partner_Account__c){
  					BPaccount_ids.add(AccOppOpenMap.get(opps.get(oppid).Accountid).Box_Partner_Account__c);
  					BPSIOldaccount_ids.add(AccOppOpenMap.get(opps.get(oppid).Accountid).Box_Partner_Account__c);
  					AccOppOpenMap.get(opps.get(oppid).Accountid).Box_Partner_Account__c=opps.get(oppid).Box_Partner_Account__c;
  					AddToList=true;
  				}
  				if(AccOppOpenMap.get(opps.get(oppid).Accountid).Service_Partner_Account__c != opps.get(oppid).Service_Partner_Account__c){
  					SIaccount_ids.add(AccOppOpenMap.get(opps.get(oppid).Accountid).Service_Partner_Account__c);
  					BPSIOldaccount_ids.add(AccOppOpenMap.get(opps.get(oppid).Accountid).Service_Partner_Account__c);
  					AccOppOpenMap.get(opps.get(oppid).Accountid).Service_Partner_Account__c=opps.get(oppid).Service_Partner_Account__c;
  					AddToList=true;
  				}
  				if(AddToList)OpportunityUpdateList.add(AccOppOpenMap.get(opps.get(oppid).Accountid));
  			}
  		}
  	***/
  	}//for loop End
  	System.debug('AccountUpdateList'+AccountUpdateList);
  	//System.debug('ContactUpdateList'+ContactUpdateList);
 	//System.debug('BPSIOldaccount_ids'+BPSIOldaccount_ids);
 	//System.debug('OtherOppBPSIOldaccount_ids'+OtherOppBPSIOldaccount_ids);
 	//System.debug('Uncheck'+Uncheck);
  	InfiniteControl.inInfiniteContext=true;	
  	//if(!OpportunityUpdateList.isEmpty()){try {update OpportunityUpdateList;} catch (DmlException e) {}}
  	if(!AccountUpdateList.isEmpty()){try {update AccountUpdateList;} catch (DmlException e) {system.debug(e);}}
  	//if(!ContactUpdateList.isEmpty()){try {update ContactUpdateList;} catch (DmlException e) {system.debug(e);}}
  	//ContactUpdateList.clear();
  	//if(!BPSIOldaccount_ids.isEmpty() && Uncheck){try {UncheckContacts(ContactUpdateList,BPSIOldaccount_ids,BPaccount_ids,SIaccount_ids,account_ids);} catch (DmlException e) {}}
  	//ContactUpdateList.clear();
  	//if(!OtherOppBPSIOldaccount_ids.isEmpty() && Uncheck){try {UncheckContacts(ContactUpdateList,OtherOppBPSIOldaccount_ids ,OtherOppBPaccount_ids,OtherOppSIaccount_ids,account_ids);} catch (DmlException e) {}}
  }
  /*****
  //Separate method to uncheck Contacts
  private static void UncheckContacts(List<Contact> ContactUpdateList,Set<Id> BPSIOldaccount_ids,Set<id> BPaccount_ids,Set<id> SIaccount_ids, Set<Id> account_ids){
  	if(ContactUpdateList.isEmpty()){
  		ContactUpdateList=new List<Contact>();
  	}
	
  	Map<id,list<Contact>> BPOldAccConMap = new Map<id,list<Contact>>();
  	Map<id,list<Contact>> SIOldAccConMap = new Map<id,list<Contact>>();
  	Map<id,Opportunity> BPOldAccOppMap = new Map<id,Opportunity>();
  	Map<id,Opportunity> SIOldAccOppMap = new Map<id,Opportunity>();
  	
  	for(Account Acc: [SELECT Id,Name, (SELECT id,Reseller_Customer_Contact__c,Service_Partner_Customer_Contact__C FROM Contacts) FROM Account where id in:BPaccount_ids]){
  	BPOldAccConMap.put(Acc.id,Acc.Contacts);	
  	}
  	for(Account Acc: [SELECT Id,Name, (SELECT id,Reseller_Customer_Contact__c,Service_Partner_Customer_Contact__C FROM Contacts) FROM Account where id in:SIaccount_ids]){
  	SIOldAccConMap.put(Acc.id,Acc.Contacts);
  	//Need to add conditon to check if already in map	
  	}
  	
  	for(opportunity opp:[select Id,Box_Partner_Account__c,Accountid from Opportunity where Box_Partner_Account__c in:BPaccount_ids and Accountid Not in: account_ids]){
  	BPOldAccOppMap.put(opp.Box_Partner_Account__c,opp);	
  	}
  	for(opportunity opp:[select Id,Service_Partner_Account__c,Accountid from Opportunity where Service_Partner_Account__c in:SIaccount_ids and Accountid Not in: account_ids]){
  	SIOldAccOppMap.put(opp.Service_Partner_Account__c,opp);	
  	}
  	
  	
  	for(id oid :BPSIOldaccount_ids){
  		
  		if(SIOldAccConMap.containskey(oid) && !BPOldAccConMap.containskey(oid) && !SIOldAccOppMap.containskey(oid)){
  			if(!SIOldAccConMap.get(oid).isEmpty()){
  				for(Contact cid : SIOldAccConMap.get(oid)){
  					ContactUpdateList.add(new Contact(id=cid.id,Service_Partner_Customer_Contact__C=false));
  				 }
  			}  			
  		} else if(!SIOldAccConMap.containskey(oid) && BPOldAccConMap.containskey(oid) && !BPOldAccOppMap.containskey(oid)){
  			if(!BPOldAccConMap.get(oid).isEmpty()){
  				for(Contact cid : BPOldAccConMap.get(oid)){
  					ContactUpdateList.add(new Contact(id=cid.id,Reseller_Customer_Contact__c=false));
  				 }
  			}  			
  		} else if(SIOldAccConMap.containskey(oid) && BPOldAccConMap.containskey(oid) && !BPOldAccOppMap.containskey(oid) && !SIOldAccOppMap.containskey(oid) ){
  			if(!SIOldAccConMap.get(oid).isEmpty()){
  				for(Contact cid : SIOldAccConMap.get(oid)){
  					ContactUpdateList.add(new Contact(id=cid.id,Reseller_Customer_Contact__c=false,Service_Partner_Customer_Contact__C=false));
  				 }
  			}  			
  		}
  		
  	}
  	
  	  	if(!ContactUpdateList.isEmpty()){try {update ContactUpdateList;} catch (DmlException e) {}}
  	
  }
  
  // End By Nikhil @ Perficient ***/
}