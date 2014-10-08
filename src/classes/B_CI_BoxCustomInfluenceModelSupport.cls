public with sharing class B_CI_BoxCustomInfluenceModelSupport {
    // V1.3
    // Modified 2/28/13 to include responses created on the opportunity close date
    // Added CloseDataCutoff__c option

    private Map<ID, Decimal> OpenOpportunityRevenue;
    private Map<ID, Decimal> ClosedOpportunityRevenue;
    private Map<ID, Decimal> LostOpportunityRevenue;
    private Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> OpenOpportunityRevenue2;
    private Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> ClosedOpportunityRevenue2;
    private Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> LostOpportunityRevenue2;
    private Integer Instance;

    private B_CI_AccountModelSettings__c config;

    // AllRelatedContacts are all contacts related either via account or OpportunityContactRole
    public Map<ID, Contact> AllRelatedContacts;
    
    // CampaignById are all parent Campaigns by Campaign Member Id
    private Map<ID, Campaign> CampaignById;
    
    // PrimaryCampaignIdByOppId is a map of campaign Ids by opp Id
    private Map<ID, ID> PrimaryCampaignIdByOppId = new Map<Id, ID>();
    
    // AccountsToContacts contains a set of all contact IDs for each account
    public Map<ID, Set<ID>> AccountsToContactIDs;
    
    // RelatedOpDetails contains all related opportunities with OpportunityContactRoles queried
    public Map<ID, Opportunity> RelatedOpDetails;
    
    // Trackes the highest weight attributed to a contact or lead per account
    private Map<String, Decimal> highestWeightByPersonId = new Map<String, Decimal>();
    
    // Map of contact Ids to Boolean value, indicating whether contacts have roles that exclude them from influence
    private Map<ID, Boolean> roleExcludedBycontactId = new Map<ID, Boolean>();
    
    private Set<String> campaignTypesToExclude = new Set<String>();

    private Map<String, B_CI_ContactRoleWeight__c> WeightInfo;
    private Map<String, B_CI_CampaignSpecificWeight__c> WeightInfoCampaign;
    private Map<String, B_CI_TimeFrameWeights__c> TimeframeInfo;    

    public B_CI_BoxCustomInfluenceModelSupport(
        Map<ID, Decimal> OpenOpRevenue,
        Map<ID, Decimal> ClosedOpRevenue,
        Map<ID, Decimal> LostOpRevenue,
        Integer instanceNumber)
    {
        this(new Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>>(), 
            new Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>>(),
            new Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>>(),
            instanceNumber);
        OpenOpportunityRevenue = OpenOpRevenue;
        ClosedOpportunityRevenue = ClosedOpRevenue;
        LostOpportunityRevenue = LostOpRevenue;
                
    }

    public B_CI_BoxCustomInfluenceModelSupport(
        Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> OpenOpRevenue2,
        Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> ClosedOpRevenue2,
        Map<ID, List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>> LostOpRevenue2,
        Integer instanceNumber)
    {
        OpenOpportunityRevenue2 = OpenOpRevenue2;
        ClosedOpportunityRevenue2 = ClosedOpRevenue2;
        LostOpportunityRevenue2 = LostOpRevenue2;
        
        Instance = InstanceNumber;
        
        // Reset earliest based on config
        String InstanceName = (Instance==0) ? 'default' : 'default-'+ String.ValueOf(Instance);
        config = B_CI_AccountModelSettings__c.getInstance( InstanceName);
        if(config.Account_Weight__c==null) config.Account_Weight__c = 0;    // Just in case
        
        Map<String,B_CI_ContactRoleWeight__c> crwentries = B_CI_ContactRoleWeight__c.getAll();
        WeightInfo = new Map<String, B_CI_ContactRoleWeight__c>();
        // Key by role for fast lookup of weight
        for(B_CI_ContactRoleWeight__c crw: crwentries.values()) if (crw.Instance__c == Instance) WeightInfo.put(crw.Role__c, crw);
        
        Map<String,B_CI_CampaignSpecificWeight__c> cswentries = B_CI_CampaignSpecificWeight__c.getAll();
        WeightInfoCampaign = new Map<String, B_CI_CampaignSpecificWeight__c>();
        // Key by type for fast lookup of weight
        for(B_CI_CampaignSpecificWeight__c csw: cswentries.values()) if (csw.Instance__c == Instance) WeightInfoCampaign.put(csw.Type__c, csw);        

        Map<String,B_CI_TimeFrameWeights__c> tfwentries = B_CI_TimeFrameWeights__c.getAll();
        TimeframeInfo = new Map<String, B_CI_TimeFrameWeights__c>();
        for(B_CI_TimeFrameWeights__c tfw: tfwentries.values()) if (tfw.Instance__c == Instance) TimeframeInfo.put(tfw.Sales_Division__c, tfw);
                
    }

    public string AccountProcessAttribution (Map<ID, Account> accounts, 
        Map<ID, Map<ID, Opportunity>> opportunities, String State)
    {
        
        Map<String,B_CI_CampaignTypeExcluded__c> ctentries = B_CI_CampaignTypeExcluded__c.getAll();
        for (B_CI_CampaignTypeExcluded__c cte : ctentries.values())
        {
            if (cte.Instance__c == Instance && cte.Exclude__c) campaignTypesToExclude.add(cte.Campaign_Type__c);
        }       
        
        if(config==null) return null;   // Config should be set by now
        
        // Get the opportunities, along with OpportunityContactRole info for each opportunity
        RelatedOpDetails = getRelatedOpDetails(opportunities);        
        
        // Find earliest date on all opportunities. This helps make the query more selective
        // and build the set of contacts related to the opportunities
        Set<ID> contactswithroles = new Set<ID>();
        DateTime earliest = DateTime.Now();
        
        Decimal longestTimeframe = 0;
        for(Opportunity op: RelatedOpDetails.values())
        {
            
            // Get longest timeframe possible because Search_Days on setting will not be referenced
            Decimal timeframeForOpp = TimeframeInfo.get(op.Sales_Division__c) == null ? TimeframeInfo.get('Default').Number_Of_Days__c : TimeframeInfo.get(op.Sales_Division__c).Number_Of_Days__c;
            longestTimeframe = timeframeForOpp > longestTimeframe ? timeframeForOpp : longestTimeframe;
            
            PrimaryCampaignIdByOppId.put(op.Id, op.CampaignId);
            
            // Don't worry about 'none' case here - it will be handled subsequently
            if(config.DateFilter__c!='closed')
            {
                if (op.CreatedDate< earliest) earliest = op.CreatedDate;
            }
            else
            {
                if (op.CreatedDate< earliest) earliest = op.CloseDate;
            }
            for(OpportunityContactRole ocr : op.OpportunityContactRoles)
            {
                contactswithroles.add(ocr.ContactID);   
            }
        }
        
        
        if(longestTimeframe!=null && config.DateFilter__c!='none') earliest = earliest.addDays(- longestTimeframe.intValue());
        else earliest = DateTime.newInstance(0);

        // Get a list of accounts with oppportunities - those are all we're interested in
        Set<ID> AccountsWithOpportunities = new Set<ID>();  
        for(ID accountid: accounts.keyset())
            if(opportunities.containskey(accountid)) AccountsWithOpportunities.add(accountid);

        // Query now on all contacts. This incluces all contacts on the account, and 
        // any contacts on an OpportunityContactRole
        AllRelatedContacts = getRelatedContacts(AccountsWithOpportunities, contactswithroles, earliest);
        
        CampaignById = getAssociatedCampaigns(AllRelatedContacts);        
        
        // Create a map from accounts to contact IDs
        // This will improve efficiency of the final model processing. We could requery on
        // account here, but we're assuming that SOQL calls and record lines is more limited
        // than script lines here.
        AccountsToContactIDs = new Map<ID, Set<ID>>();
        
        for(ID accountid: AccountsWithOpportunities) AccountsToContactIDs.put(accountid, new Set<ID>());
        for(Contact ct: AllRelatedContacts.Values())
        {
            if(ct.AccountID!=null && AccountsToContactIDs.ContainsKey(ct.AccountID)) AccountsToContactIDs.get(ct.AccountID).add(ct.id);
        }
        
        // Now process the revenues - go through each account
        for(ID accountid: AccountsWithOpportunities)
        {   // Loop through each opportunity on each account
            for(Opportunity op: opportunities.get(accountid).values())
            {   // Add the revenue for that opportunity
                if(config.Include_Zero_Amount_Influence__c==true || (op.Amount!=null && op.Amount>0))  // Don't bother if there's no revenue unless we're capturing zero revenue
                    AddRevenueForOpportunity(AccountsToContactIds.get(accountid), RelatedOpDetails.get(op.id), (op.Amount==null)? 0: op.Amount);
            }
        }
                    
        return null;            
    }

    // Determines whether campaign member will be included in influence calculation
    private Boolean campaignMemberIncluded(CampaignMember cm, Opportunity relatedop, DateTime earliest) 
    {
        return (
               cm.FCRM__FCR_Response_Date__c >= earliest
            && (cm.FCRM__FCR_Response_Date__c.Date() <= relatedop.CloseDate || !relatedop.isClosed && !config.CloseDateCutoff__c  )
            && (
                   // Excludes certain campaign types based on a custom field on the campaign called Exclude_from_Influence__c, 
                   // from all influence unless they are the primary campaign
                   (!CampaignById.get(cm.CampaignId).Exclude_from_Influence__c) 
                || (CampaignById.get(cm.CampaignId).Exclude_from_Influence__c && PrimaryCampaignIdByOppId.get(relatedop.Id) == cm.CampaignId)
                )
            && (cm.ContactId == null || !AllRelatedContacts.get(cm.ContactId).Exclude_from_Influence__c)
            && (
                // Exclude certain roles unless primary campaign 
                (
                    (cm.ContactId != null && roleExcludedBycontactId.containsKey(cm.ContactId))
                    && (
                           (roleExcludedBycontactId.get(cm.ContactId) && PrimaryCampaignIdByOppId.get(relatedop.Id) == cm.CampaignId) 
                        || (!roleExcludedBycontactId.get(cm.ContactId))
                    )
                )
                || (cm.ContactId != null && !roleExcludedBycontactId.containsKey(cm.ContactId))
                || (cm.ContactId == null)
            )
            && (!campaignTypesToExclude.contains(CampaignById.get(cm.CampaignId).Campaign_Type__c))
        );      
    }
    
    // Returns largest weight between new weight and previous weight calculated for either contact or lead
    private Decimal getLargerWeight(CampaignMember cm, String accountId, Decimal newWeight)
    {
        Decimal currentWeight;
        String personId = cm.ContactId + accountId;
        if (highestWeightByPersonId.containsKey(personId))
        {
            currentWeight = highestWeightByPersonId.get(personId);  
        }
        else
        {
            currentWeight = newWeight;
            highestWeightByPersonId.put(personId, currentWeight);
        }       
        return math.max(currentWeight, newWeight);
    }
    
    private Decimal getLargestWeight(CampaignMember cm, String accountId)
    {
        String personId =  cm.ContactId + accountId;
        if (highestWeightByPersonId.containsKey(personId)) return highestWeightByPersonId.get(personId);    
        return 0.0;     
    }

    public void AddRevenueForOpportunity(Set<ID> accountcontactids, Opportunity relatedop, Decimal Amount) 
    {
        Map<ID, Decimal> OpenOpPoints = new Map<ID, Decimal>();
        Map<ID, Decimal> ClosedOpPoints = new Map<ID, Decimal>();
        Map<ID, Decimal> LostOpPoints = new Map<ID, Decimal>();
        
        DateTime earliest;
        Decimal totalweight = 0;
        
        Decimal timeframeForOpp = TimeframeInfo.get(relatedop.Sales_Division__c) == null ? TimeframeInfo.get('Default').Number_Of_Days__c : TimeframeInfo.get(relatedop.Sales_Division__c).Number_Of_Days__c;
        
        if(timeframeForOpp!=null && config.DateFilter__c!='none')
        {
            earliest = (config.DateFilter__c=='open' || config.DateFilter__c==null) ? relatedop.CreatedDate.addDays(- timeframeForOpp.intValue()) : relatedop.CloseDate.addDays(- timeframeForOpp.intValue());
        }
        else earliest = DateTime.newInstance(0);
        
        // We need to build a new list of roles that removes duplicate contacts on the opportunity
        // We do this by creating a map keyed on the contact ID. Note that we are only using
        // a map here to remove duplicate contacts
        Map<ID, OpportunityContactRole> rolelist = new Map<ID, OpportunityContactRole>();
        system.debug('relatedop.OpportunityContactRoles ' + relatedop.OpportunityContactRoles);
        for(OpportunityContactRole ocr: relatedop.OpportunityContactRoles)
        {
            String role = ocr.Role == null ? 'No Role' : ocr.Role;
            
            // If this contact was created after the opportunity close date, ignore it
            if(AllRelatedContacts.get(ocr.contactid).CreatedDate > relatedop.CloseDate) continue;       

            if(! rolelist.containskey(ocr.ContactID))
            {   // First role for a contact
                rolelist.put(ocr.ContactID, ocr);  
                roleExcludedBycontactId.put(ocr.ContactID, WeightInfo.containskey(role) ? WeightInfo.get(role).Exclude_From_Influence__c : false);
            }           
            else 
            {   
                // A contact is always assigned the weight of the highest weighted non-excluded contact role. 
                // If there are only excluded roles, take the highest weight of those roles.
                if (roleExcludedBycontactId.get(ocr.ContactID) && WeightInfo.get(role).Exclude_From_Influence__c)
                {
                    // Subsequent role for a contact - replace if the new one has a higher weight
                    Decimal existingweight = (WeightInfo.containskey(rolelist.get(ocr.ContactID).Role))? WeightInfo.get(rolelist.get(ocr.ContactID).Role).Weight__c : 0;
                    Decimal newweight = (WeightInfo.containskey(role))? WeightInfo.get(role).Weight__c : 0;
                    if(newweight>existingweight) rolelist.put(ocr.ContactID, ocr);                      
                }
                // If subsequent role is not excluded, but previous one is, replace with non-excluded role
                else if (roleExcludedBycontactId.get(ocr.ContactID))
                {
                    rolelist.put(ocr.ContactID, ocr);
                    roleExcludedBycontactId.put(ocr.ContactID, false);                  
                }
                else
                {
                    Decimal existingweight = (WeightInfo.containskey(rolelist.get(ocr.ContactID).Role))? WeightInfo.get(rolelist.get(ocr.ContactID).Role).Weight__c : 0;
                    Decimal newweight = (WeightInfo.containskey(role))? WeightInfo.get(role).Weight__c : 0;
                    if(newweight>existingweight) rolelist.put(ocr.ContactID, ocr);                  
                }
            }                          
            
        }     
        system.debug('rolelist  ' + rolelist);           
        
        // Every response on contacts on an account gets one account based point
        // ----------------------------------------------------------------------------------------------------------------
        for(ID contactid: accountcontactids)
        {
            // If this contact was created after the opportunity close date, ignore it
            if(AllRelatedContacts.get(contactid).CreatedDate.Date() > relatedop.CloseDate) continue;
            for(CampaignMember cm: AllRelatedContacts.get(contactid).CampaignMembers)
            {
                if (campaignMemberIncluded(cm, relatedop, earliest))
                {
                    Decimal weight = getLargerWeight(cm, relatedop.AccountId, config.Account_Weight__c);
                    TotalWeight += weight;
                    if(relatedop.IsClosed)
                    {
                        if(relatedop.IsWon)
                        {
                            ClosedOpPoints.put(cm.id, (ClosedOpPoints.ContainsKey(cm.id))? ClosedOpPoints.get(cm.id)+weight: weight );
                        }
                        else
                        {
                            LostOpPoints.put(cm.id, (LostOpPoints.ContainsKey(cm.id))? LostOpPoints.get(cm.id)+weight: weight );
                        }
                    }
                    else
                    {
                        OpenOpPoints.put(cm.id, (OpenOpPoints.ContainsKey(cm.id))? OpenOpPoints.get(cm.id)+weight: weight );
                    }
                    
                }
            }
        }
        system.debug('account based points');
        system.debug('1 TotalWeight ' + TotalWeight);    
        system.debug('1 ClosedOpPoints ' + ClosedOpPoints);
        system.debug('1 LostOpPoints ' + LostOpPoints);
        system.debug('1 OpenOpPoints ' + OpenOpPoints);        
        
        // Now grant role based points to responses on contacts on OpportunityContactRoles
        // based on the role
        // ----------------------------------------------------------------------------------------------------------------
        for(OpportunityContactRole ocr: rolelist.values())
        {
            ID contactid = ocr.ContactID;
            Decimal weight;
            system.debug('contactid' + contactid);
            // Assign weight from contact role. If Role is null, grab weight value from "No Role" in WeightInfo. 
            if (WeightInfo.containskey(ocr.Role))
            {
                weight = WeightInfo.get(ocr.Role).Weight__c;
                system.debug('weight 1 ' + weight);
            }
            else if (ocr.Role == null) 
            {
                // Allows users to assign weight points to OpContactRoles with Role = null
                weight = WeightInfo.get('No Role').Weight__c;
                system.debug('weight 2 ' + weight);
            }
            else 
            {
                weight = 0;
                system.debug('weight 3 ' + weight); 
            }
            if(weight==0) continue;

            for(CampaignMember cm: AllRelatedContacts.get(contactid).CampaignMembers)
            {
                if (campaignMemberIncluded(cm, relatedop, earliest))
                {
                    system.debug('weight 4 ' + weight);
                    //weight = getLargerWeight(cm, relatedop.AccountId, weight);
                    system.debug('weight 5 ' + weight);
                    TotalWeight+= weight;
                    if(relatedop.IsClosed)
                    {
                        if(relatedop.IsWon)
                        {
                            ClosedOpPoints.put(cm.id, (ClosedOpPoints.ContainsKey(cm.id))? ClosedOpPoints.get(cm.id)+weight: weight );
                        }
                        else
                        {
                            LostOpPoints.put(cm.id, (LostOpPoints.ContainsKey(cm.id))? LostOpPoints.get(cm.id)+weight: weight );
                        }
                    }
                    else
                    {
                        OpenOpPoints.put(cm.id, (OpenOpPoints.ContainsKey(cm.id))? OpenOpPoints.get(cm.id)+weight: weight );
                    }
                    
                }
            }
        }        
        system.debug('Role weights');
        system.debug('2 TotalWeight ' + TotalWeight);    
        system.debug('2 ClosedOpPoints ' + ClosedOpPoints);
        system.debug('2 LostOpPoints ' + LostOpPoints);
        system.debug('2 OpenOpPoints ' + OpenOpPoints);        
        
        // Grant Campaign Specific points based off fields on related op
        // ----------------------------------------------------------------------------------------------------------------
        for(OpportunityContactRole ocr: rolelist.values())
        {
            ID contactid = ocr.ContactID;               
            for(CampaignMember cm: AllRelatedContacts.get(contactid).CampaignMembers)
            {                                
                if (cm.ContactId == relatedop.FCRM__FCR_Admin_Originating_Contact__c)
                {
                    Decimal weight = 0;
                    Boolean excludedCmWithPrimaryCampaign = CampaignById.get(cm.CampaignId).Exclude_from_Influence__c && PrimaryCampaignIdByOppId.get(relatedop.Id) == cm.CampaignId;
                    Boolean excludedRoleWithPrimaryCampaign = roleExcludedBycontactId.get(cm.ContactId) && PrimaryCampaignIdByOppId.get(relatedop.Id) == cm.CampaignId;
                    
                    if (relatedop.FCRM__FCR_First_Campaign_Touch__c == cm.CampaignId && !excludedCmWithPrimaryCampaign && !excludedRoleWithPrimaryCampaign) 
                    {
                        weight += WeightInfoCampaign.get('First Touch').Weight__c;
                    }
                    if (relatedop.FCRM__FCR_Last_Campaign_Touch__c == cm.CampaignId && !excludedCmWithPrimaryCampaign && !excludedRoleWithPrimaryCampaign) 
                    {
                        weight += WeightInfoCampaign.get('Last Touch').Weight__c;
                    }
                    if (PrimaryCampaignIdByOppId.get(relatedop.Id) == cm.CampaignId) 
                    {
                        weight += WeightInfoCampaign.get('Tipping Point').Weight__c;
                    }                   

                    if (weight > 0 && campaignMemberIncluded(cm, relatedop, earliest))
                    {
                        // Campaign Specific weighting is additive
                        TotalWeight+= weight;
                        if(relatedop.IsClosed)
                        {
                            if(relatedop.IsWon)
                            {
                                ClosedOpPoints.put(cm.id, (ClosedOpPoints.ContainsKey(cm.id))? ClosedOpPoints.get(cm.id)+weight: weight );
                            }
                            else
                            {
                                LostOpPoints.put(cm.id, (LostOpPoints.ContainsKey(cm.id))? LostOpPoints.get(cm.id)+weight: weight );
                            }
                        }
                        else
                        {
                            OpenOpPoints.put(cm.id, (OpenOpPoints.ContainsKey(cm.id))? OpenOpPoints.get(cm.id)+weight: weight );
                        }
                        
                    }                   
                }
            }
        }
        system.debug('Camapaign type weight');
        system.debug('3 TotalWeight ' + TotalWeight);    
        system.debug('3 ClosedOpPoints ' + ClosedOpPoints);
        system.debug('3 LostOpPoints ' + LostOpPoints);
        system.debug('3 OpenOpPoints ' + OpenOpPoints);                                
        
        for(ID cmid: OpenOpPoints.keyset())
        {
            if(OpenOpportunityRevenue2.get(cmid)==null) OpenOpportunityRevenue2.put(cmid, new List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>());
            if(OpenOpPoints.get(cmid) > 0)  // Revenue can be zero (if capturing zero amount influence, but weight must exist to capture info
            {
                Decimal therevenue = Amount * OpenOpPoints.get(cmid) / TotalWeight;
                OpenOpportunityRevenue2.get(cmid).add(new FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue(relatedop.id, therevenue)); 
                if(OpenOpportunityRevenue!=null) OpenOpportunityRevenue.put(cmid, (OpenOpportunityRevenue.containskey(cmid))? therevenue + OpenOpportunityRevenue.get(cmid): therevenue);
            }
        }       
        for(ID cmid: ClosedOpPoints.keyset())
        {
            if(ClosedOpportunityRevenue2.get(cmid)==null) ClosedOpportunityRevenue2.put(cmid, new List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>());
            if(ClosedOpPoints.get(cmid) > 0)
            {
                Decimal therevenue = Amount * ClosedOpPoints.get(cmid) / TotalWeight;
                ClosedOpportunityRevenue2.get(cmid).add(new FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue(relatedop.id, therevenue)); 
                if(ClosedOpportunityRevenue !=null) ClosedOpportunityRevenue.put(cmid, (ClosedOpportunityRevenue.containskey(cmid))? therevenue + ClosedOpportunityRevenue.get(cmid): therevenue);
            }
        }       
        for(ID cmid: LostOpPoints.keyset())
        {
            if(LostOpportunityRevenue2.get(cmid)==null) LostOpportunityRevenue2.put(cmid, new List<FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue>());
            if(LostOpPoints.get(cmid)>0)
            {
                Decimal therevenue = Amount * LostOpPoints.get(cmid) / TotalWeight;
                LostOpportunityRevenue2.get(cmid).add(new FCRM.FCR_CampaignInfluenceAPI.OpportunityRevenue(relatedop.id, therevenue)); 
                if(LostOpportunityRevenue!=null) LostOpportunityRevenue.put(cmid, (LostOpportunityRevenue.containskey(cmid))? therevenue + LostOpportunityRevenue.get(cmid): therevenue);
            }
        }       
        
    }
    
    // Get a list of all opportunties on all accounts
    // Subquery to get all OpportunityContactRole objects that have a role defined
    // Return map is keyed by opportunity ID
    // This also requeries for any extra fields we need on opportunity
    // Be sure to pull Amount off the original opportunity though, as it's been adjusted
    // by the caller to handle multi-currency correctly.
    public Map<ID, Opportunity> getRelatedOpDetails(Map<ID, Map<ID, Opportunity>> opportunities)
    {
        // Build set of opportunity keys
        Set<ID> opkeys = new Set<ID>();
        for(Map<ID, Opportunity> opmap: opportunities.values())
        {
            opkeys.addAll(opmap.keyset());
        }
        Map<ID, Opportunity> results = new Map<ID, Opportunity>(
            [Select ID, IsClosed, IsWon, CreatedDate, AccountId, CloseDate, CampaignId, Sales_Division__c, FCRM__FCR_Admin_Originating_Contact__c,
            FCRM__FCR_Last_Campaign_Touch__c, FCRM__FCR_First_Campaign_Touch__c, (Select ID, ContactID, Role from OpportunityContactRoles)
                From Opportunity where ID in :opkeys]
        );          
        return results;
    }    
        
    // Get a list of all contacts for the accounts and the OpportunityContactRoles
    // Subquery to get the responses
    // Only our responses are considered in the model
    public Map<ID, Contact> getRelatedContacts(Set<ID> accountids, Set<ID> contactids, DateTime earliest)
    {
        Map<ID, Contact> results = new Map<ID, Contact>(
            [Select ID, AccountID, CreatedDate, Exclude_from_Influence__c,
                    (Select ID, CampaignId, FCRM__FCR_Response_Date__c, LeadId, ContactId from CampaignMembers 
                    where FCRM__FCR_Response_Date__c!=null And HasResponded=true And FCRM__FCR_Response_Date__c >= :earliest)
                FROM Contact where (AccountID in :accountids or ID in :contactids)]
            );
        return results;
    }
     
    // Get a list of all parent campaigns for campaign members 
    // Used to determine which campaigns aren't included in influence attribution    
    private Map<ID, Campaign> getAssociatedCampaigns(Map<ID, Contact> relatedContacts) 
    {
        Map<ID, Campaign> parentCampaigns = new Map<ID, Campaign>();
        Set<Id> campaignIds = new Set<Id>();
        for(Contact ct: relatedContacts.Values())
        {
            for(CampaignMember cm: relatedContacts.get(ct.Id).CampaignMembers)
            {
                campaignIds.add(cm.CampaignId);
            }
        }
        if (campaignIds.size() > 0)
        {
            parentCampaigns = new Map<ID, Campaign>([Select Id, Exclude_from_Influence__c, Type, Campaign_Type__c From Campaign Where Id IN :campaignIds]);
        }
        return parentCampaigns;
    }   
  
}