/**
 * This class contains the logic for Opportunity Trigger functionality.
 *   
 * @author Richard Wu
 * @revision Kyle Vermeer 5/12/14 Standardize format and merge all opportunity triggers
 */
public class OpportunityTriggerHelper {

    //////////////
    // Constants
    //////////////

    public static final Id NON_REP_USER_ID = '00560000001FyKa';
    
    ////////////////
    // Public API
    ////////////////

    /**
     * Before insert trigger functionality
     *
     * @param {List<Opportunity>} newList - Trigger.new
     */
    public static void beforeInsert(List<Opportunity> newList) {
        OpportunityClosedWonUpdate_trgr.insertBillingCountryClassification(newList);
        OpportunityUpdateSalesDivision_trgr.updateSalesDivisionAndTheater(true,null,newList);
        CSMEmailHelper.updateCSMEmail(newList, false);
        initFields(newList);
        updateTerritory(newList);
        OpptyReferrerCompanyHandler.popReferrerCompany(newList);
        checkOppCreatorForSDR_OBR_NIR(newList);
        CongaUtils.massKeySynthesis();
        FCCRM_UpdateOppAcceptedFields(null, newList);
    }
    
    /**
     * After insert trigger functionality
     *
     * @param {Map<Id,Opportunity>} newMap - Trigger.newMap
     */
    public static void afterInsert(Map<Id,Opportunity> newMap) {
        OpportunityCustomization.opportunityCloneCustomization(newMap);
        createOpportunitySharesForPartners(newMap.values());
    }
    
    /**
     * Before update trigger functionality
     *
     * @param {Map<Id,Opportunity>} oldMap - Trigger.oldMap
     * @param {Map<Id,Opportunity>} newMap - Trigger.newMap
     */
    public static void beforeUpdate(Map<Id,Opportunity> oldMap, Map<Id,Opportunity> newMap) {
        OpportunityClosedWonUpdate_trgr.updateBillingCountryClassification(newMap,oldMap);
        OpportunityUpdateSalesDivision_trgr.updateSalesDivisionAndTheater(false,oldMap,newMap.values());
        webTrialUpsellSync(oldMap, newMap);
        updateTerritory(newMap.values());
        OpportunityCustomization.validatePrimaryContactOnClose(oldMap,newMap);
        OpptyReferrerCompanyHandler.populateReferrerCompany(oldMap,newMap);
        CongaUtils.massKeySynthesis();
        FCCRM_UpdateOppAcceptedFields(oldMap,newMap.values());
    }

    /**
     * After update trigger functionality
     *
     * @param {Map<Id,Opportunity>} oldMap - Trigger.oldMap
     * @param {Map<Id,Opportunity>} newMap - Trigger.newMap
     */
    public static void afterUpdate(Map<Id,Opportunity> oldMap, Map<Id,Opportunity> newMap) {
        createOpportunitySharesForPartners(oldMap,newMap);
    }
   
    /**
     * Before delete trigger functionality
     *
     * @param {Map<Id,Opportunity>} oldMap - Trigger.oldMap
     */
    public static void beforeDelete(Map<Id,Opportunity> oldMap) {
                                            
        /* Prevent user from deleting an opportunity if Allow_Delete__c = False */
        for(Opportunity oldOpp : oldMap.values()){
            
            if(!oldOpp.Allow_Delete__c){  
                oldOpp.addError(Label.Opportunity_Delete_Error);
            }   
            
        }//end-for 
    }

    /**
     * After delete trigger functionality
     *
     * @param {Map<Id,Opportunity>} oldMap - Trigger.oldMap
     */
    public static void afterDelete(Map<Id,Opportunity> oldMap) {}

    /**
     * After Undelete trigger functionality
     *
     * @param {Map<Id,Opportunity>} newMap - Trigger.newMap
     */
    public static void afterUndelete(Map<Id,Opportunity> newMap) {}


    ////////////////////
    // Private Methods
    ////////////////////


    /* replace opp owner if it's not a user or an inactive user */
    public static void initFields(List<Opportunity> opportunityList) {
        
        Set<Id> userIds = new Set<Id>();
        Map<Id, User> userMap = new Map<Id, User>();
        
        Set<String> userNames = new Set<String>();
        Map<String, User> userNameMap = new Map<String, User>();
        
        for(Opportunity opp : opportunityList){
            
            if(opp.OwnerId!=null){
                userIds.add(opp.OwnerId);
            }
 
        }//end-for
        
        if(userIds.size()>0){
            
            for(User u : [Select u.IsActive, u.Id, u.Name From User u Where Id in: userIds]){
            
                userMap.put(u.Id, u);
                
                if(!u.IsActive){
                    userNames.add(u.Name);  
                }   
                
            }//end-for
            
        }
        
        System.debug('>>>>>userNames='+userNames);
        
        if(userNames.size()>0){

            for(User u : [Select u.IsActive, u.Id, u.Name From User u Where Name in: userNames and isActive=True]){
            
                userNameMap.put(u.Name, u);
                
            }//end-for
    
        }//end-if
        
        System.debug('>>>>>userNameMap='+userNameMap);
        
        User oppOwner;
        
        for(Opportunity opp : opportunityList){
            
            if(opp.OwnerId!=null && userMap.containsKey(opp.OwnerId)){
                
                oppOwner=userMap.get(opp.OwnerId);
                
                if(!oppOwner.isActive){
                        
                    System.debug('>>>>>INACTIVE OWNER<<<<<');
                    
                    // find if there is an active user with the same name
                    if(userNameMap.containsKey(oppOwner.Name)){
                        
                        System.debug('>>>>>set owner='+userNameMap.get(oppOwner.Name).Id);
                        
                        opp.OwnerId = userNameMap.get(oppOwner.Name).Id;
                        
                    }else{
                        
                        System.debug('>>>>>set owner=non-rep user');
                        
                        // owner owner is an inactive user
                        opp.OwnerId = NON_REP_USER_ID;  
                        
                    }
                        
                }//end-if owner is inactive
                    
            }//end-if there's an owner id 
         
 
        }//end-for
                
    }

    // update opp owner and territory fields 
    // new and existing records
 
    public static void updateTerritory(List<Opportunity> opportunityList) {
		
        if(!TerritoryAssignment.isEnabled()){
            return;
        }
		
        Set<Id> accountIds = new Set<Id>();
                 
        Map<Id,Account> accountMap = new Map<Id,Account>();
    
        for(Opportunity opp : opportunityList){
            accountIds.add(opp.AccountId);
        }

        if(accountIds.size()>0){
  
            for(Account acct : [Select Id, OwnerId, Owner.Name, Owner.IsActive, Territory__c
            							from Account 
            								where Id in : accountIds]){
            								
                accountMap.put(acct.Id,acct);
            }           
            
        }
          
        System.debug('>>>>>>>>accountMap='+accountMap); 
        
        Account currentAccount;
        
        for(Opportunity opp : opportunityList){
        
            currentAccount=accountMap.get(opp.AccountId);
            
            // if there's no account, then we can't default
            if(currentAccount==null){
                continue;
            }
   
            // if opp owner or current user is non-rep user, do not change owner
            if(opp.OwnerId == NON_REP_USER_ID || userinfo.getUserId()==NON_REP_USER_ID){
                opp.Exclude_from_Territory_Assignment__c = true;
                continue;    
            }

            // update owner if it's allowed
            if(opp.Exclude_from_Territory_Assignment__c==false
                && opp.IsClosed==false
                && (opp.Holdout_Opp_Expiration__c==null || opp.Holdout_Opp_Expiration__c <= system.today()) ){      

                System.debug('>>>>>>>>currentAccount.OwnerId='+currentAccount.OwnerId); 

                if(currentAccount.Owner.isActive){
                    opp.ownerId = currentAccount.OwnerId; 
                }
                opp.Territory_at_Close__c = currentAccount.Territory__c; 
            }
            
   
        
        }//end-for

    }

    /**
     * Creates OpportunityShare objects for Partner users so they can see Opportunities they are working.
     *
     * @param {Map<Id,Opportunity>} oldMap - Trigger.oldMap
     * @param {Map<Id,Opportunity>} newMap - Trigger.newMap
     */
    public static void createOpportunitySharesForPartners(Map<Id,Opportunity> oldMap, Map<Id,Opportunity> newMap) {
        List<Opportunity> oppsToCreateShares = new List<Opportunity>();
        // Check each opp to see if the Box Partner User changed, if so, create an opportunity share for it
        for (Opportunity currentOpp : newMap.values()) {
           // Opportunity oldOpp = oldMap.get(currentOpp.Id);
            //if (oldOpp.Box_Partner_User__c != currentOpp.Box_Partner_User__c) {
                oppsToCreateShares.add(currentOpp);
            //}
        }
        DealRegController.createOpptyShares(oppsToCreateShares);
    }

    /**
     * Creates OpportunityShare objects for Partner users so they can see Opportunities they are working.
     *
     * @param {Map<Id,Opportunity>} newValues - Trigger.new
     */
    public static void createOpportunitySharesForPartners(List<Opportunity> newValues) {
        DealRegController.createOpptyShares(newValues);
    }

    /**
     * If the opp's creator is an sdr, obr, or nir, show that on opp
     *
     * @param {List<Opportunity>} opps - Trigger.new
     */
    public static void checkOppCreatorForSDR_OBR_NIR(List<Opportunity> opps) {
        User u = [select id, userRole.Name from user where id=:UserInfo.getUserId()];
        if (u.userRole.Name == null) { // don't continue if null user role name
            return;
        }
        String sdr_id = null;
        if (u.userRole.Name.contains(UserRoleUtils.getSDRRoleIdentifier())) {
            sdr_id = u.id;
        }
        String obr_id = null;
        if (u.userRole.Name.contains(UserRoleUtils.getOBRRoleIdentifier())) {
            obr_id = u.id;
        }
        String nir_id = null;
        if (u.userRole.Name.contains(UserRoleUtils.getNIRRoleIdentifier())) {
            nir_id = null;
        }
        for (Opportunity currentOpp : opps) {
            System.debug('SDR Lookup Before: ' + currentOpp.SDR_Lookup__c);
            if (sdr_id != null) {
                currentOpp.SDR_Lookup__c = sdr_id;
            }
            if (obr_id != null) {
                currentOpp.OBR_Lookup__c = obr_id;
            }
            if (nir_id != null) {
                currentOpp.EIR_Lookup__c = nir_id;
            }
            System.debug('SDR Lookup After: ' + currentOpp.SDR_Lookup__c);
        }
        
    }

    /**
     * Update fields when opp was accepted by AE
     *
     * @param {Map<Id,Opportunity>} oldMap - Trigger.oldMap
     * @param {Map<Id,Opportunity>} newMap - Trigger.newMap
     */
    public static void FCCRM_UpdateOppAcceptedFields(Map<Id,Opportunity> oldMap, List<Opportunity> newValues) {
        System.debug('Entering FCCRM trigger to update Opp AE_Accepted_By__c and AE_Accepted_Date__c fields...');
    
        // Initialize settings
        FccrmInternalSettings__c SETTINGS;
        String IGNORED_OPP_STAGES;    
        try {
            SETTINGS = FccrmInternalSettings__c.getInstance('default');
            IGNORED_OPP_STAGES = SETTINGS.AE_Accepted_Fields_Ignored_Stages__c; 
        } catch (Exception e) {
            System.debug('FccrmInternalSettings__c custom settings have not yet been initialized. Killing...');
            return;
        }
        
        // Set up variables
        Set<String> ignoredStages = new Set<String>();
        if (IGNORED_OPP_STAGES != null && !IGNORED_OPP_STAGES.equals('')) {
            List<String> ignoredStagesList = IGNORED_OPP_STAGES.split(';');
            ignoredStages.addAll(ignoredStagesList);
        }
        
        // Now to iterate across opps and update    
        for (Opportunity o : newValues) {
            System.debug('Evaluating old and new stage values for opp ' + o.Name);
            String oldStage;
            String newStage;
            
            // Set the old/new stage fields 
            if (oldMap!= null) {
                oldStage = oldMap.get(o.Id).StageName;
            }
            newStage = o.StageName;
            System.debug('oldStage: ' + oldStage + ', newStage: ' + newStage);
            
            // Make sure opp stage is changing from a non-accepted stage to an accepted stage
            if (oldStage == null || oldStage.equals('') || ignoredStages.contains(oldStage)) {
                if (newStage != null && !newStage.equals('') && !ignoredStages.contains(newStage)) {
                    System.debug('Opp has changed from an unacceptable stage to an acceptable stage. Time to update!');
                    o.AE_Accepted_By__c = o.OwnerId;
                    o.AE_Accepted_Date__c = Date.today();
                    System.debug('AE_Accepted_By__c is now ' + o.AE_Accepted_By__c + '. AE_Accepted_Date__c is now ' + o.AE_Accepted_Date__c);
                }
            }       
        }
    }

    /**
     * Sync fields back from web trial upsell to original trial opp upon closing
     *
     * @param {Map<Id,Opportunity>} oldMap - Trigger.oldMap
     * @param {Map<Id,Opportunity>} newMap - Trigger.newMap
     */
    public static void webTrialUpsellSync(Map<Id,Opportunity> oldMap, Map<Id,Opportunity> newMap) {
        List<Opportunity> filteredOpps = OpportunityServices.filterOpportunities(newMap.values(), oldMap);
        if( !filteredOpps.isEmpty() )
        {
            List<Opportunity> originatingOpportunities = OpportunityServices.getOriginatingOpportunities(Pluck.ids('Originating_Opportunity__c', filteredOpps));
            OpportunityServices.copyOpptyFieldsOntoOriginatingOppty( new Map<Id,Opportunity>(originatingOpportunities), filteredOpps );
            Map<Id, List<Opportunity>> originatingOpptyIdToOppties = GroupBy.ids('Originating_Opportunity__c', filteredOpps);
            OpportunityServices.setOriginatingOpportunitiesStatus(originatingOpportunities, originatingOpptyIdToOppties);
        }
    }
}