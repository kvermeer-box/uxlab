public class SLA_Configuration {

	private SLA_Configuration_Settings__c m_Settings = null;
	private String m_Role;
	private static Map<String, ID> m_cachedLeadQueues = new Map<String,ID>();	// Cache the lead queue ID
	
	private static User m_TestSLAUser = null;
	private static User m_TestNonSLAUser = null;
	private static String m_TestSLAQueue = null;
	

	public SLA_Configuration(User u, Lead ld)
	{
		if(u==null || u.UserRoleId==null) return;
		Init(u.UserRole.DeveloperName);
		if(m_settings!=null && m_settings.Exclude_Record_Field_Name__c!=null)
		{	// Disable if exclude field is found and set
			if(ld.get(m_settings.Exclude_Record_Field_Name__c)==true) m_Settings.Enabled__c = false;
		}
	}

	public SLA_Configuration(String role)
	{
		Init(role);
	}

	private void Init(String role)
	{
		if(!Test.isRunningTest() && role!=null && role.length()>38) role = role.substring(0,38); 
		m_Role = role;
		if(Test.isRunningTest())
		{
			SetupForTests();
			if(role == m_TestSLAUser.UserRole.DeveloperName) m_Settings = GetTestSettings(role);
		}
		else m_Settings = (role==null)? null: SLA_Configuration_Settings__c.getInstance(role);
	}
	
	private static SLA_Configuration_Settings__c GetTestSettings(String role)
	{
		return new SLA_Configuration_Settings__c(Name = role, Active_For_Leads__c = true, Enabled__c = true,
			Lead_SLA_Movement_Queue__c = m_TestSLAQueue, SLA_Stage_Names__c = 'Open - Not Contacted',
			Working_Activity_Movement_Days__c=21, Working_Activity_Warning_Days__c = 14,
			Working_Stage_Names__c = 'Working,Attempting Contact'  );
	}
	
	public Boolean isEnabled()
	{
		return(m_Settings!=null && m_Settings.Enabled__c);
	}
	
	public Boolean onLead()
	{
		return isEnabled() && m_Settings.Active_for_Leads__c;
	}
	
	public String SLALeadMovementQueueName()
	{
		return (isEnabled() && onLead())? m_Settings.Lead_SLA_Movement_Queue__c: null;
	}

	public String SLALeadMovementQueueID()
	{
		if (isEnabled() && onLead() && m_Settings.Lead_SLA_Movement_Queue__c!=null)
		{
			if(!m_cachedleadqueues.containskey(m_role))
				m_cachedLeadQueues.put(m_role, GetQueueID(m_Settings.Lead_SLA_Movement_Queue__c));
			return m_cachedleadqueues.get(m_role);
		}
		return null;
	}

	
	public String ExcludeRecordFieldName()
	{
		return (isEnabled())? m_Settings.Exclude_Record_Field_Name__c: null;
	}
	
	public Set<String> SLAStageNames()
	{
		return (isEnabled() && m_Settings.SLA_Stage_Names__c!=null)? SplitAndTrim(m_Settings.SLA_Stage_Names__c): null; 
	}
	
	public Boolean IsSLAStage(String stage)
	{
		Set<String> stages = SLAStageNames();
		return(stages!=null && stages.contains(stage));
	}

	// Is active if it matches any active SLA stage
	public static Boolean IsResponseStatusActive(CampaignMember cm)
	{
		return getAllSLAStageNames().contains(cm.FCRM__FCR_Response_Status__c);
		//return IsSLAStage(cm.FCRM__FCR_Response_Status__c);
	}

	public Set<String> WorkingStageNames()
	{
		return (isEnabled() && m_Settings.Working_Stage_Names__c!=null)? SplitAndTrim(m_Settings.Working_Stage_Names__c): null; 
	}

	public Boolean IsWorkingStage(String stage)
	{
		Set<String> stages = WorkingStageNames();
		return(stages!=null && stages.contains(stage));
	}

	public Integer WorkingActivityMovementDays()
	{
		return(isEnabled() && m_Settings.Working_Activity_Movement_Days__c!=null)? m_Settings.Working_Activity_Movement_Days__c.intValue(): 21;
	}

	public Integer WorkingActivityWarningDays()
	{
		return(isEnabled() && m_Settings.Working_Activity_Warning_Days__c!=null)? m_Settings.Working_Activity_Warning_Days__c.intValue(): 14;
	}
	
	public static Set<String> SLARolesForLeads()
	{
		Map<String,SLA_Configuration_Settings__c> allsettings = SLA_Configuration_Settings__c.getAll();
		if(Test.isRunningTest()) 
		{
			SetupForTests(); 
			allsettings = new Map<String, SLA_Configuration_Settings__c>{m_TestSLAUser.UserRole.DeveloperName=> GetTestSettings(m_TestSLAUser.UserRole.DeveloperName)};
		}
		Set<String> results = new Set<String>();
		for(String role :allsettings.keyset())
		{
			SLA_Configuration_Settings__c slasetting = allsettings.get(role);
			if(slasetting.Enabled__c && slasetting.Active_for_Leads__c) results.add(role);
		}
		return results;
	}
	
	// Get a set of all lead movement queues
	private static Set<ID> m_CachedSLALeadMovementQueueIDs = null;
	
	public static Set<ID> getAllSLALeadMovementQueueIDs()
	{
		if(m_CachedSLALeadMovementQueueIDs!=null) return m_CachedSLALeadMovementQueueIDs;
		
		Map<String,SLA_Configuration_Settings__c> allsettings = SLA_Configuration_Settings__c.getAll();
		if(Test.isRunningTest()) 
		{
			SetupForTests(); 
			allsettings = new Map<String, SLA_Configuration_Settings__c>{m_TestSLAUser.UserRole.DeveloperName=> GetTestSettings(m_TestSLAUser.UserRole.DeveloperName)};
		}
		Set<ID> results = new Set<ID>();
		Set<String> queuenames = new Set<String>();
		if(allsettings.size()==0) return results;
		for(String role:allsettings.keyset())
		{
			SLA_Configuration_Settings__c slasetting = allsettings.get(role);
			if(slasetting.Enabled__c && slasetting.Active_for_Leads__c && slasetting.Lead_SLA_Movement_Queue__c!=null) 
				queuenames.add(slasetting.Lead_SLA_Movement_Queue__c);
		}
		// Now we have all the queue names
		if(queuenames.size()==0) return results;
		List<Group> groups = [Select ID, Type from Group where DeveloperName in :queuenames And Type ='Queue'];
		for(Group g:groups) results.add(g.id);
		m_CachedSLALeadMovementQueueIDs = results;
		return results;
	}

	public static Set<String> getAllSLAStageNames()
	{
		Map<String,SLA_Configuration_Settings__c> allsettings = SLA_Configuration_Settings__c.getAll();
		if(Test.isRunningTest()) 
		{
			SetupForTests(); 
			allsettings = new Map<String, SLA_Configuration_Settings__c>{m_TestSLAUser.UserRole.DeveloperName=> GetTestSettings(m_TestSLAUser.UserRole.DeveloperName)};
		}
		Set<String> results = new Set<String>();
		for(String role :allsettings.keyset())
		{
			SLA_Configuration_Settings__c slasetting = allsettings.get(role);
			if(slasetting.Enabled__c && slasetting.SLA_Stage_Names__c!=null) results.addall(SplitAndTrim(slasetting.SLA_Stage_Names__c));
		}
		return results;
	}

	public static Set<String> getAllWorkingStageNames()
	{
		Map<String,SLA_Configuration_Settings__c> allsettings = SLA_Configuration_Settings__c.getAll();
		if(Test.isRunningTest()) 
		{
			SetupForTests(); 
			allsettings = new Map<String, SLA_Configuration_Settings__c>{m_TestSLAUser.UserRole.DeveloperName=> GetTestSettings(m_TestSLAUser.UserRole.DeveloperName)};
		}
		Set<String> results = new Set<String>();
		for(String role :allsettings.keyset())
		{
			SLA_Configuration_Settings__c slasetting = allsettings.get(role);
			if(slasetting.Enabled__c && slasetting.Working_Stage_Names__c!=null) results.addall(SplitAndTrim(slasetting.Working_Stage_Names__c));
		}
		return results;
	}

	public static Set<String> getAllExcludeRecordFieldNames()
	{
		Map<String,SLA_Configuration_Settings__c> allsettings = SLA_Configuration_Settings__c.getAll();
		if(Test.isRunningTest()) 
		{
			SetupForTests(); 
			allsettings = new Map<String, SLA_Configuration_Settings__c>{m_TestSLAUser.UserRole.DeveloperName=> GetTestSettings(m_TestSLAUser.UserRole.DeveloperName)};
		}
		Set<String> results = new Set<String>();
		for(String role :allsettings.keyset())
		{
			SLA_Configuration_Settings__c slasetting = allsettings.get(role);
			if(slasetting.Enabled__c && slasetting.Exclude_Record_Field_Name__c!=null) results.add(slasetting.Exclude_Record_Field_Name__c.trim());
		}
		return results;
	}

	public static Integer getSmallestMovementDays()
	{
		return getSmallestDays(true);
	}

	public static Integer getSmallestWarningDays()
	{
		return getSmallestDays(false);
	}

	private static Integer getSmallestDays(Boolean Movement)
	{
		Map<String,SLA_Configuration_Settings__c> allsettings = SLA_Configuration_Settings__c.getAll();
		if(Test.isRunningTest()) 
		{
			SetupForTests(); 
			allsettings = new Map<String, SLA_Configuration_Settings__c>{m_TestSLAUser.UserRole.DeveloperName=> GetTestSettings(m_TestSLAUser.UserRole.DeveloperName)};
		}
		Integer result = 1000000;
		for(String role :allsettings.keyset())
		{
			SLA_Configuration_Settings__c slasetting = allsettings.get(role);
			if(Movement)
			{
				if(slasetting.Enabled__c && slasetting.Working_Activity_Movement_Days__c!=null && slasetting.Working_Activity_Movement_Days__c.intValue()< result) result = slasetting.Working_Activity_Movement_Days__c.intValue();
			}
			else
			{
				if(slasetting.Enabled__c && slasetting.Working_Activity_Warning_Days__c!=null && slasetting.Working_Activity_Warning_Days__c.intValue()< result) result = slasetting.Working_Activity_Warning_Days__c.intValue();
			}
		}
		return result;
	}

	private ID GetQueueID(String queuename)
	{
		if(queuename==null) return null;
		List<Group> groups = [Select ID, Type from Group where DeveloperName = :queuename And Type ='Queue'];
        if(groups.size()==0) return null;
        return groups[0].id;
	}
	
	// Pick an SLA user, non SLA user, and a queue for testing
	// Call this with role==null outside of system.runas at start of test to initialize statics for non-SLA user
	public static void SetupForTests()
	{
		// Find user that has a role we can use
		if(m_TestSLAUser==null) 
		{
			// Make sure user running tests (initialization) is not in SDR role
			List<User> slausers = [Select ID, Name, UserRole.DeveloperName from User where UserRole.DeveloperName<>null And UserRoleID<> :UserInfo.getUserRoleId() And IsActive=True limit 1];
			m_TestSLAUser = slausers[0];
			List<User> nonslausers = [Select ID, Name, UserRole.DeveloperName from User where UserRole.DeveloperName<>null And UserRole.DeveloperName<> :m_TestSLAUser.UserRole.DeveloperName And IsActive=True limit 1];
			m_TestNonSLAUser = nonslausers[0];
			List<QueueSObject> queues = [Select Queue.Type, QueueID, Queue.DeveloperName from QueueSObject where Queue.Type='queue' And SobjectType='Lead'];
			m_TestSLAQueue = queues[0].Queue.DeveloperName;
		}
	}
	
	public static USER GetSLAUser()
	{
		SetupForTests();
		return m_TestSLAUser;
	}

	public static USER GetNonSLAUser()
	{
		SetupForTests();
		return m_TestNonSLAUser;
	}

	public static Set<String> SplitAndTrim(String inputstring)
	{
		List<String> splitstring = inputstring.split(',');
		Set<String> results = new Set<String>();
		for(String s: splitstring) results.add(s.trim());
		return results;
	}
}