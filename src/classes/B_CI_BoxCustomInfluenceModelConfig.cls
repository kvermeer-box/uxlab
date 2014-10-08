public class B_CI_BoxCustomInfluenceModelConfig {
    
    private B_CI_AccountModelSettings__c currentconfig;

        private Integer CurrentInstanceNumber = 0;
        
        private Map<String,String> m_AvailableRoles;      // Indexed by the role
        
        private List<String> m_AvailableRoleList;           // In order provided by Describe
        
        private Map<String, B_CI_ContactRoleWeight__c> m_WeightInfo;
        
        private Set<String> m_AvailableSalesDivisions = new Set<String>();
        
        private List<String> m_AvailableSalesDivisionsList = new List<String>();

        private List<String> m_OpenSlotSalesDivisions = new List<String>();
        
        private Map<String, B_CI_TimeFrameWeights__c> m_TimeframeSettingByOpenSlotName = new Map<String, B_CI_TimeFrameWeights__c>();
        
        private Set<String> m_AvailableCampaignTypes = new Set<String>{'First Touch', 'Last Touch', 'Tipping Point'};
        
        public B_CI_TimeFrameWeights__c timeframeDefaultConfig {get;set;}
        
        public B_CI_ContactRoleWeight__c noRoleWeightConfig {get;set;}
        
        private Map<String, B_CI_CampaignSpecificWeight__c> m_WeightInfoCampaign;
        
        private Map<String, B_CI_TimeFrameWeights__c> m_TimeframeInfo;
        
        public Map<String, B_CI_CampaignTypeExcluded__c> m_CampaignTypeExcludeInfo {get;set;}
        
        private List<String> m_AvailableCampaignTypesList;
        
        private Map<String,String> m_AvailableCampaignTypes2;
        
        private Integer instNum;

    public void Init()
    {
        if(currentconfig!=null) return;
        String InstanceInfo = Apexpages.currentPage().getParameters().get('instance');
        if(InstanceInfo!=null)
        {
            try
            {
                CurrentInstanceNumber = Integer.valueOf(InstanceInfo);
            } catch(Exception ex) {}
        }
        
        Schema.DescribeFieldResult ocrroleinfo = OpportunityContactRole.Role.getDescribe();
        List <Schema.PicklistEntry> plelist = ocrroleinfo.getPicklistValues();
        m_AvailableRoles = new Map<String,String>();
        m_AvailableRoleList = new List<String>();   
        
        for(Schema.PicklistEntry ple: plelist)
        {
            m_AvailableRoles.put(ple.getValue(),ple.getLabel());
            m_AvailableRoleList.add(ple.getValue());
        }      
        
        Schema.DescribeFieldResult typefields = Schema.sObjectType.Campaign.fields.Campaign_Type__c;
        List<Schema.PickListEntry> pickvalues = typefields.getPicklistValues();                
        m_AvailableCampaignTypesList = new List<String>();
        m_AvailableCampaignTypes2 = new Map<String,String>();         

        for(Schema.Picklistentry ple: pickvalues)
        {
            m_AvailableCampaignTypes2.put(ple.getLabel(),ple.getLabel());
            m_AvailableCampaignTypesList.add(ple.getLabel());           
        }
        
        instNum = CurrentInstanceNumber;
        LoadInstance(CurrentInstanceNumber);
    }         
        
    public void LoadInstance(Integer InstanceNumber)
    {
        String InstanceName = (InstanceNumber==0) ? 'default' : 'default-'+ String.ValueOf(InstanceNumber);
        B_CI_AccountModelSettings__c cfg = B_CI_AccountModelSettings__c.getInstance( InstanceName);
        if(cfg==null)
        {
            currentconfig = new B_CI_AccountModelSettings__c();
            currentconfig.name = InstanceName;
            currentconfig.DateFilter__c = 'open';
            currentconfig.CloseDateCutoff__c = false;
        }
        else 
        {
            currentconfig = cfg;
            if(currentconfig.DateFilter__c == 'none') currentconfig.DateFilter__c = 'open';
            if(currentconfig.DateFilter__c == null) currentconfig.DateFilter__c = 'open';
        }         
        
        Map<String,B_CI_ContactRoleWeight__c> crwentries = B_CI_ContactRoleWeight__c.getAll();
        m_WeightInfo = new Map<String, B_CI_ContactRoleWeight__c>();
        Map<String,B_CI_CampaignSpecificWeight__c> cswentries = B_CI_CampaignSpecificWeight__c.getAll();
        m_WeightInfoCampaign = new Map<String, B_CI_CampaignSpecificWeight__c>();
         Map<String,B_CI_TimeFrameWeights__c> tfwentries = B_CI_TimeFrameWeights__c.getAll();
        m_TimeframeInfo = new Map<String, B_CI_TimeFrameWeights__c>();
         Map<String,B_CI_CampaignTypeExcluded__c> ctentries = B_CI_CampaignTypeExcluded__c.getAll();
        m_CampaignTypeExcludeInfo = new Map<String, B_CI_CampaignTypeExcluded__c>();        
        
        // Load existing entries into the map
        Boolean roleConfigFound = false;
        for(String crwName: crwentries.keySet()) 
        {
            if (!crwName.contains('No Role'))
            {
                m_WeightInfo.put(crwentries.get(crwName).Role__c, crwentries.get(crwName));
            }
            else
            {
                roleConfigFound = true;
                noRoleWeightConfig = crwentries.get(crwName);
            }
        }
        for(B_CI_CampaignSpecificWeight__c csw: cswentries.values()) m_WeightInfoCampaign.put(csw.Type__c, csw);
        for(B_CI_TimeFrameWeights__c tfw: tfwentries.values()) m_TimeframeInfo.put(tfw.Sales_Division__c, tfw);
        for(B_CI_CampaignTypeExcluded__c cte: ctentries.values()) m_CampaignTypeExcludeInfo.put(cte.Campaign_Type__c, cte);
                
        // Now create new objects for those that are missing
        for(String cType: m_AvailableCampaignTypes2.keyset())
        {
            if(!m_CampaignTypeExcludeInfo.containskey(cType))
            {
                String ctName = 'w' + string.ValueOf(InstanceNumber) + cType;
                m_CampaignTypeExcludeInfo.put(cType, new B_CI_CampaignTypeExcluded__c(Name = ctName, Exclude__c = false, Campaign_Type__c = cType, Instance__c = InstanceNumber));
            }
        }              
        
        // Now create new objects for those that are missing
        for(String role: m_AvailableRoles.keyset())
        {
            if(! m_WeightInfo.containskey(role))
            {
                String rolename = 'w' + string.ValueOf(InstanceNumber) + role;
                m_WeightInfo.put(role, new B_CI_ContactRoleWeight__c(Role__c = role, Name = rolename, weight__c = 0, Instance__c = InstanceNumber ));
            }
        }
        
        // Add default setting used for when Opportunity Contact Role Label is null
        if (!roleConfigFound)
        {
            noRoleWeightConfig = new B_CI_ContactRoleWeight__c(Role__c = 'No Role', Name = 'w' + string.ValueOf(InstanceNumber) + 'No Role', weight__c = 0, Instance__c = InstanceNumber );
        }
         
        // Create list of available campaign types       
        for(String ctype: m_AvailableCampaignTypes)
        {
            if(! m_WeightInfoCampaign.containskey(ctype))
            {
                String typename = 'w' + string.ValueOf(InstanceNumber) + ctype;
                m_WeightInfoCampaign.put(ctype, new B_CI_CampaignSpecificWeight__c(Type__c = ctype, Name = typename, weight__c = 0, Instance__c = InstanceNumber ));
            }
        }  
        
        // Add sales divisions that user added previously   
        if (m_TimeframeInfo.size() > 0)
        {
            Set<String> availableSalesDivisions = new Set<String>();
            for (String newSalesDiv : m_TimeframeInfo.keySet())
            {
                if (newSalesDiv != 'Default') 
                {
                    m_AvailableSalesDivisions.add(newSalesDiv);
                    m_AvailableSalesDivisionsList.add(newSalesDiv);
                }
            }
        }
        for(String salesDiv: m_AvailableSalesDivisions)
        {
            if(! m_TimeframeInfo.containskey(salesDiv))
            {
                String sdname = 'w' + string.ValueOf(InstanceNumber) + salesDiv;
                m_TimeframeInfo.put(salesDiv, new B_CI_TimeFrameWeights__c(Sales_Division__c = salesDiv, Name = sdname, Number_of_Days__c = 0, Instance__c = InstanceNumber ));
            }
        }
        // Add default setting used for when opp's Sales Division doesn't have a timeframe setting
        if (!m_TimeframeInfo.containsKey('Default'))
        {
            String sdname = 'w' + string.ValueOf(InstanceNumber) + 'Default';
            timeframeDefaultConfig = new B_CI_TimeFrameWeights__c(Sales_Division__c = 'Default', Name = sdname, Number_of_Days__c = 1, Instance__c = InstanceNumber);
            m_TimeframeInfo.put('Default', timeframeDefaultConfig);
        }
        else
        {
            timeframeDefaultConfig = m_TimeframeInfo.get('Default');
        }         
        for (Integer i = m_TimeframeInfo.size(); i <= 20; i++) {
            String slotName = 'Sales Division ' + i;
            m_OpenSlotSalesDivisions.add(slotName); // Use a list to maintain order of slots
            m_TimeframeSettingByOpenSlotName.put(slotName, new B_CI_TimeFrameWeights__c(Sales_Division__c = null, Number_of_Days__c = 0, Name = slotName, Instance__c = InstanceNumber ));
        }
                            
    }
    
    private List<B_CI_TimeFrameWeights__c> timeframesDeleted = new List<B_CI_TimeFrameWeights__c>();
    
    // Removes timeframe entry that was selected to be deleted 
    public void deleteTimeframeEntry()
    {
        timeframesDeleted.add(m_TimeframeInfo.get(timeframeEntryToDelete));        
        m_TimeframeInfo.remove(timeframeEntryToDelete);
        m_AvailableSalesDivisions.remove(timeframeEntryToDelete);
        m_OpenSlotSalesDivisions = new List<String>(); 
        for (Integer i = m_TimeframeInfo.size(); i <= 20; i++)
        {
            String slotName = 'Sales Division ' + i;
            m_OpenSlotSalesDivisions.add(slotName);
            if (!m_TimeframeSettingByOpenSlotName.containsKey(slotName)) m_TimeframeSettingByOpenSlotName.put(slotName, new B_CI_TimeFrameWeights__c(Sales_Division__c = null, Number_of_Days__c = 0, Name = slotName, Instance__c = instNum ));
        }
    }

    public String timeframeEntryToDelete {get;set;}

    public Set<String> getCampaignTypes()
    {
        Init();
        return m_CampaignTypeExcludeInfo.keySet();
    }

    public Set<String> getAvailableCampaignTypes()
    {
        Init();
        return m_AvailableCampaignTypes;
    }
    
    public Integer getAvailableSalesDivisionsSize()
    {
        Init();
        return m_AvailableSalesDivisions.size();
    }    
    
    public List<String> getOpenSlotSalesDivisions()
    {
        Init();
        return m_OpenSlotSalesDivisions;
    }
    
    public Map<String, B_CI_TimeFrameWeights__c> getTimeframeSettingByOpenSlotName() 
    {
        Init();
        return m_TimeframeSettingByOpenSlotName;
    }
    
    public Map<String, B_CI_CampaignSpecificWeight__c> getWeightInfoCampaign()
    {
        Init();
        return m_WeightInfoCampaign;
    }
    
    public Map<String, B_CI_TimeFrameWeights__c> getTimeframeInfo()
    {
        Init();
        return m_TimeframeInfo;
    }

    
    public List<String> getAvailableSalesDivisions()
    {
        Init();
        List<String> sdList = new List<String>();
        for (String sd : m_AvailableSalesDivisionsList)
        {
            if (m_AvailableSalesDivisions.contains(sd)) sdList.add(sd);
        }
        return sdList;
    }    

    public List<String> getAvailableRoles()
    {
        Init();
        return m_AvailableRoleList; 
    }
    
    public List<String> getAvailableCampaignTypes2()
    {
        Init();
        return m_AvailableCampaignTypesList; 
    }
    
    public List<B_CI_ContactRoleWeight__c> weightInfoList {
        get {
            if (weightInfoList != null) return weightInfoList;
            return m_WeightInfo.values();
        }
        set;
    }
    
    public Map<String, String> getRoleLabels()
    {
        Init();
        return m_AvailableRoles;
    }
    
    public Map<String, String> getCampaignTypeLabels()
    {
        Init();
        return m_AvailableCampaignTypes2;
    }    
    
    public Map<String, B_CI_ContactRoleWeight__c> getWeightInfo()
    {
        Init();
        return m_WeightInfo;
    }

    public Map<String, B_CI_CampaignTypeExcluded__c> getCampaignTypeExclude()
    {
        Init();
        return m_CampaignTypeExcludeInfo;
    }

    public B_CI_AccountModelSettings__c configobject { get { init(); return currentconfig; } }


    public PageReference Save()
    {
        Init();
        Database.Upsert(currentconfig);
        
        // Save/Update Contact Role Weight Settings
        // ----------------------------------------------------------------------------------------------------------------
        List<B_CI_ContactRoleWeight__c> weightstoupdate = new List<B_CI_ContactRoleWeight__c>();
        List<B_CI_ContactRoleWeight__c> weightstodelete = new List<B_CI_ContactRoleWeight__c>();
        Map<String,B_CI_ContactRoleWeight__c> currententries = B_CI_ContactRoleWeight__c.getAll();
        
        for(B_CI_ContactRoleWeight__c crw : weightInfoList)
        {
            // If this entry doesn't have a current match, delete it
            if(!m_AvailableRoles.ContainsKey(crw.Role__c) && crw.id!=null && crw.Role__c != 'No Role') weightstodelete.add(crw);
            
            // If it's a new entry, or existing entry and value has changed, add it to the list to update
            if(crw.id==null || currententries.containskey(crw.name) && (crw.Weight__c != currententries.get(crw.Name).Weight__c || crw.Exclude_From_Influence__c != currententries.get(crw.Name).Exclude_From_Influence__c)) 
                weightstoupdate.add(crw);
        }
        if(weightstodelete.size()>0) delete weightstodelete;
        if(weightstoupdate.size()>0) upsert weightstoupdate;    // Upsert new or revised values
        upsert noRoleWeightConfig;

        // Save/Update Campaign Specific Weight Settings
        // ----------------------------------------------------------------------------------------------------------------
        List<B_CI_CampaignSpecificWeight__c> c_weightstoupdate = new List<B_CI_CampaignSpecificWeight__c>();
        List<B_CI_CampaignSpecificWeight__c> c_weightstodelete = new List<B_CI_CampaignSpecificWeight__c>();
        Map<String,B_CI_CampaignSpecificWeight__c> campaigncurrententries = B_CI_CampaignSpecificWeight__c.getAll();
        
        for(B_CI_CampaignSpecificWeight__c csw: m_WeightInfoCampaign.Values())
        {
            // If this entry doesn't have a current match, delete it
            if(!m_AvailableCampaignTypes.contains(csw.Type__c) && csw.id!=null) c_weightstodelete.add(csw);

            // If it's a new entry, or existing entry and value has changed, add it to the list to update
            if(csw.id==null || campaigncurrententries.containskey(csw.name) && csw.Weight__c != campaigncurrententries.get(csw.Name).Weight__c) c_weightstoupdate.add(csw);
        }
        if(c_weightstodelete.size()>0) delete c_weightstodelete;
        if(c_weightstoupdate.size()>0) upsert c_weightstoupdate;    // Upsert new or revised values

        // Save/Update Campaign Type Exclude Settings
        // ----------------------------------------------------------------------------------------------------------------        
        upsert m_CampaignTypeExcludeInfo.values();
                
        // Save/Update Timeframe By Sales Division Weight Settings
        // ----------------------------------------------------------------------------------------------------------------     
        List<B_CI_TimeFrameWeights__c> timeframestoupdate = new List<B_CI_TimeFrameWeights__c>();
        List<B_CI_TimeFrameWeights__c> timeframestodelete = new List<B_CI_TimeFrameWeights__c>();
        Map<String,B_CI_TimeFrameWeights__c> timeframecurrententries = B_CI_TimeFrameWeights__c.getAll();
        
        // Include open slots with values entered
        for(B_CI_TimeFrameWeights__c tfw: m_TimeframeSettingByOpenSlotName.Values())
        {
            // Make sure user hasn't entered a Sales Division that already exists.
            // Only add if number of days and sales division are valid values
            if (!m_AvailableSalesDivisions.contains(tfw.Sales_Division__c)
                && tfw.Number_Of_Days__c > 0 && tfw.Sales_Division__c != null)  
            {
                tfw.name = 'w' + string.ValueOf(tfw.Instance__c) + tfw.Sales_division__c;
                timeframestoupdate.add(tfw);
            }
        }       
                
        for(B_CI_TimeFrameWeights__c tfw: m_TimeframeInfo.Values())
        {
            // If this entry doesn't have a current match, delete it
            if(!m_AvailableSalesDivisions.contains(tfw.Sales_Division__c) && tfw.id!=null && tfw.Sales_Division__c != 'Default') timeframestodelete.add(tfw);
            
            // If it's a new entry, or existing entry and value has changed, add it to the list to update
            if(tfw.id==null || timeframecurrententries.containskey(tfw.name) && tfw.Number_Of_Days__c != timeframecurrententries.get(tfw.Name).Number_Of_Days__c) timeframestoupdate.add(tfw);
        }   
        timeframestodelete.addAll(timeframesDeleted);
        if(timeframestodelete.size()>0) delete timeframestodelete;
        if(timeframestoupdate.size()>0) upsert timeframestoupdate;  // Upsert new or revised values
        upsert timeframeDefaultConfig;  
        
        
        return Cancel();        // And return to main
    }
    
    public PageReference Cancel()
    {
            String returl = ApexPages.currentPage().getParameters().get('returl');
            if(returl!=null) return new PageReference(returl);
            return null;
    }
}