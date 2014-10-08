// Support class for SLA project



public class SLA_Support {

    private static Date ReferenceSaturday = Date.newInstance(1970,1,3); // This was a Saturday

    // Processes new responses.
    // Note, this function can be called at any time (before/after trigger, future)
    // The assumption is that the caller is responsible for subsequent DML if necessary
    // This function should be called after final assignment on response create
    // Returns the list of responses that were modified
    // The following fields must be present
    // CampaignMember
    //      SLA_Cycles__c
    //      SLA_Expires__c
    // Lead
    //      OwnerID 
    //      SLA_Cycles__c
    //      SLA_Expires__c
    //      
    public List<CampaignMember> ProcessNewResponses(List<CampaignMember> newresponses, Map<ID,Lead> relatedleads)
    {
        Set<ID> campaignids = new Set<ID>();    // We need a set of the campaign IDs
        Set<ID> leadowners = new Set<ID>();     // We need a set of the lead owners
        List<CampaignMember> cmstoprocess = new List<CampaignMember>(); // Responses to process

        for(CampaignMember cm: newresponses)
        {
            if(cm.ContactID==null)	// Modified 6/13/13 to ignore converted leads
            {
                cmstoprocess.add(cm);
                campaignids.add(cm.CampaignID);
                leadowners.add(relatedleads.get(cm.LeadID).OwnerID);
            }
            
        }
        if(cmstoprocess.size()==0) return null; // Nothing to process
        
        // Get profiles
        Map<ID,User> relatedusers = new Map<ID, User>([Select ID, ProfileID, Profile.Name, UserRole.DeveloperName from User where ID in :leadowners]);
        // Get SLA time
        Map<ID, Campaign> relatedcampaigns = new Map<ID, Campaign>([Select ID, Campaign_SLA__c from Campaign where ID in :campaignids]);    

		List<CampaignMember> modifiedcms = new List<CampaignMember>();

        for(CampaignMember cm: cmstoprocess)
        {
        	SLA_Configuration config = new SLA_Configuration(relatedusers.get(relatedleads.get(cm.LeadID).OwnerID),relatedleads.get(cm.LeadID));
        	if(!SLA_Configuration.IsResponseStatusActive(cm)) continue;	// Only process active responses
            if( config.onLead())
            {
                cm.SLA_Cycles__c = 1;
                cm.SLA_Expires__c = DateTime.Now().addHours( SLAHours(cm));
                cm.SLA_Expires_Original__c = cm.SLA_Expires__c;
                cm.First_SLA_Owner__c = relatedleads.get(cm.LeadID).OwnerID;
                relatedleads.get(cm.LeadID).SLA_Cycles__c = 1;
                relatedleads.get(cm.LeadID).SLA_Expires__c = cm.SLA_Expires__c;
                modifiedcms.add(cm);
            }
            
        }
        return(modifiedcms);

    }
    
    
    // SLA attainment (lead status change while SLA is set to a non SLA status)
    // Sections A, E in spec
    // Called on status change
    // The assumption is that the caller is responsible for subsequent DML if necessary
    // This function should be called on lead status change
    // relatedresponses are a list of active responses on the leads. Only one allowed per lead
    // Returns a list of modified leads
    // The following fields must be present
    // CampaignMember
    //      SLA_Cycles__c
    //      SLA_Expires__c
    //      SLA_Achieved__c
    //      First_SLA_Owner__c
    // Lead
    //      OwnerID 
    //      SLA_Cycles__c
    //      SLA_Expires__c
    //      
    public List<Lead> SLAAttainmentCheck(List<Lead> leadstotest, List<CampaignMember> relatedresponses)
    {
        Set<ID> leadowners = new Set<ID>();     // We need a set of the lead owners
        Map<ID, CampaignMember> leadsToResponses = new Map<ID,CampaignMember>();    // Map from lead ID to active response

        for(CampaignMember cm: relatedresponses) leadsToResponses.put(cm.LeadID, cm);

        List<Lead> modifiedleads = new List<Lead>();

        List<Lead> leadstoprocess = new List<Lead>();   // Leads to process
        
        for(Lead ld: leadstotest)
        {
            if(ld.SLA_Expires__c == null || ld.SLA_Cycles__c== null ) continue;
            leadowners.add(ld.OwnerID);
            leadstoprocess.add(ld);             
        }

        if(leadstoprocess.size()==0) return modifiedleads;  // Nothing to process
        
        // Get profiles
        Map<ID,User> relatedusers = new Map<ID, User>([Select ID, ProfileID, Profile.Name, UserRole.DeveloperName from User where ID in :leadowners]);


        for(Lead ld: leadstoprocess)
        {
	       	SLA_Configuration config = new SLA_Configuration(relatedusers.get(ld.OwnerID), ld);
	       	if(config.IsSLAStage(ld.status)) continue;	// If it's an SLA status, it wasn't changed, so this doesn't apply

            if(config.onLead())
            {
                CampaignMember cm = leadsToResponses.get(ld.id);

                if(ld.SLA_Cycles__c==1)
                {   // SLA attainment by first rep
                    if(cm!=null)
                    {
                        cm.First_SLA_Owner__c = ld.OwnerID;
                        cm.SLA_Achieved__c = DateTime.Now();
                    }
                    ld.SLA_Cycles__c = null;
                    ld.SLA_Expires__c = null;
                    modifiedleads.add(ld);
                }
                else if(ld.SLA_Cycles__c == 2)
                {
                    // SLA attainment by second rep
                    if(cm!=null)
                    {
                        cm.SLA_Achieved__c = DateTime.Now();
                    }
                    ld.SLA_Cycles__c = null;
                    ld.SLA_Expires__c = null;
                    modifiedleads.add(ld);
                }
            }
            
        }
        return modifiedleads;

    }   

    // Leads claimed by rep (lead owner change while SLA is set)
    // Sections D in spec
    // Called on lead owner changed
    // The assumption is that the caller is responsible for subsequent DML if necessary
    // This function should be called on lead owner change
    // oldmap contains a map to old lead values (specifically - old OwnerID)
    // relatedresponses are a list of active responses on the leads. Only one allowed per lead
    // Returns a list of modified leads
    // The following fields must be present
    // CampaignMember
    //      SLA_Cycles__c
    //      SLA_Expires__c
    //      Second_SLA_Owner__c
    // Lead
    //      OwnerID 
    //      SLA_Cycles__c
    //      SLA_Expires__c
    //      
    public List<Lead> LeadsClaimed(List<Lead> leadstotest, Map<ID, Lead> oldmap, List<CampaignMember> relatedresponses)
    {
        Set<ID> leadowners = new Set<ID>();     // We need a set of the lead owners
        
        Map<ID, CampaignMember> leadsToResponses = new Map<ID,CampaignMember>();    // Map from lead ID to active response

        for(CampaignMember cm: relatedresponses) leadsToResponses.put(cm.LeadID, cm);

        List<Lead> leadstoprocess = new List<Lead>();   // Leads to process
        
        for(Lead ld: leadstotest)
        {
            // If not SLA, or new owner isn't user, or prior owner isn't sharktank
            if(ld.SLA_Expires__c == null || ld.SLA_Cycles__c!= 1 ||
                ld.OwnerID.getSObjectType() != User.getSObjectType()) continue;
            leadstoprocess.add(ld);
            leadowners.add(ld.OwnerID);             
        }

        // Get profiles
        Map<ID,User> relatedusers = new Map<ID, User>([Select ID, ProfileID, Profile.Name, UserRole.DeveloperName from User where ID in :leadowners]);

        List<Lead> modifiedleads = new List<Lead>();

        if(leadstoprocess.size()==0) return modifiedleads;  // Nothing to process
        
        for(Lead ld: leadstoprocess)
        {
        	SLA_Configuration config = new SLA_Configuration(relatedusers.get(ld.OwnerID), ld);
			if(config.SLALeadMovementQueueID()==null) continue;
			
            if(config.onLead())
            {
            	// Fixed - we don't know who the old user is, but this applies to transition out of any sharktank queue
            	if(!SLA_Configuration.getAllSLALeadMovementQueueIDs().contains(oldmap.get(ld.id).OwnerID)) continue;
                //if(oldmap.get(ld.id).OwnerID!= config.SLALeadMovementQueueID()) continue;
                ld.SLA_Expires__c = dateTime.Now().addHours(SLAHours(24));
                ld.SLA_Cycles__c = 2;
    
                CampaignMember cm = leadsToResponses.get(ld.id);
                if(cm!=null)
                {
                    cm.SLA_Expires__c = ld.SLA_Expires__c;
                    cm.SLA_Cycles__c = 2;
                    cm.Second_SLA_Owner__c = ld.OwnerID;
                }   
                modifiedleads.add(ld);
            }
        }
        return modifiedleads;
    }   


    // Lead owners changed (vacation, etc)
    // Sections K, L, M, P in spec
    // The assumption is that the caller is responsible for subsequent DML if necessary
    // This function should be called on lead owner change
    // oldmap contains a map to old lead values (specifically - old OwnerID)
    // relatedresponses are a list of active responses on the leads. Only one allowed per lead
    // Returns a list of modified leads
    // The following fields must be present
    // CampaignMember
    //      SLA_Cycles__c
    //      SLA_Expires__c
    // Lead
    //      OwnerID 
    //      SLA_Cycles__c
    //      SLA_Expires__c
    //      
    public List<Lead> LeadsOwnersChanged(List<Lead> leadstotest, Map<ID, Lead> oldmap, List<CampaignMember> relatedresponses)
    {
        Set<ID> leadowners = new Set<ID>();     // We need a set of the lead owners
        for(Lead ld: leadstotest) leadowners.add(ld.ownerid);
        for(Lead ld: oldmap.values()) leadowners.add(ld.ownerid);
        // Get profiles
        Map<ID,User> relatedusers = new Map<ID, User>([Select ID, Name, ProfileID, Profile.Name, UserRole.DeveloperName from User where ID in :leadowners]);
        
        Map<ID, CampaignMember> leadsToResponses = new Map<ID,CampaignMember>();    // Map from lead ID to active response

        for(CampaignMember cm: relatedresponses) leadsToResponses.put(cm.LeadID, cm);

        Map<ID,Lead> modifiedleads = new Map<ID,Lead>();
        Boolean leadadded = false;

        List<Lead> LeadsTransferredFromNonSLA;
        
        for(Lead ld: leadstotest)
        {
	       	SLA_Configuration config = new SLA_Configuration(relatedusers.get(ld.OwnerID), ld);
	       	SLA_Configuration oldconfig = new SLA_Configuration(relatedusers.get(oldmap.get(ld.id).OwnerID), oldmap.get(ld.id));
        	// Step P here
        	if(config.onLead() && 
        		(! oldconfig.onLead() ||	// Prior owner is non SLA user
        			// Or prior owner is a queue that isn't the sharktank
        			(oldmap.get(ld.id).OwnerID.getSObjectType()!= User.getSObjectType() && oldmap.get(ld.id).OwnerID!= config.SLALeadMovementQueueID())
        		) && ld.SLA_Cycles__c == null
        	)
        	{
        		CampaignMember cm = leadsToResponses.get(ld.id);
        		if(cm!=null)
        		{
        			if(!config.IsSLAStage(cm.FCRM__FCR_Response_Status__c)) continue;	// Ignore if cm is not SLA stage
        			// In test mode we aren't querying our fields, so for tests assume cycles is null
        			if(Test.IsRunningTest() || cm.SLA_Cycles__c == null)
        			{
		                ld.SLA_Expires__c = DateTime.Now().addHours( SLAHours(cm));
		                ld.SLA_Cycles__c = 1;
		                cm.SLA_Cycles__c = 1;
		                cm.SLA_Expires__c = ld.SLA_Expires__c;
		                cm.SLA_Expires_Original__c = cm.SLA_Expires__c;
		                cm.First_SLA_Owner__c = ld.OwnerID;
        			}
        			else
        			{
                        ld.SLA_Expires__c = DateTime.Now().addHours(SLAHours(24));
                        ld.SLA_Cycles__c = 2;
                        cm.SLA_Cycles__c = 2;
                        cm.Second_SLA_Owner__c = ld.OwnerID;
	                    cm.SLA_Expires__c = ld.SLA_Expires__c;
	                    cm.SLA_Achieved__c = null;
	                    cm.Transferred_to_Non_SLA_Owner__c = false;
	                    
        				
        			}
	        		modifiedleads.put(ld.id, ld);
        		}
        		
        		continue;	// Done processing step P
        	}
        	
        	

            /* Moved to SLALeadTrigger
            if(ld.Current_Owner__c!= ld.OwnerID)
            {
                ld.Current_Owner__c = (ld.OwnerID.getSObjectType() != User.getSObjectType())? null: ld.OwnerID;
                modifiedleads.put(ld.id, ld);
            } 
            */          

            if(ld.SLA_Expires__c == null || ld.SLA_Cycles__c== null) continue;

            CampaignMember cm = leadsToResponses.get(ld.id);
			if(cm==null) continue;	// Ignore if no CM and cm is not SLA stage
           	if(!SLA_Configuration.IsResponseStatusActive(cm)) continue;
			
            if (config.onLead())
            {   
	            // If new owner isn't user, or prior owner isn't a user
	            if( ld.OwnerID.getSObjectType() != User.getSObjectType() ||
	                oldmap.get(ld.id).OwnerID.getSObjectType()!= User.getSObjectType()) continue;
 
            	// K and L here
                if(oldmap.get(ld.id).OwnerID== config.SLALeadMovementQueueID()) continue;    // Doesn't apply for K&L

                // Can't process if there's no active response
                // Can use the SLA_Hours__c formula here because unlike initial creation, this is an
                // update and the formula is guaranteed valid
                if(ld.SLA_Cycles__c==1)
                {
                    // K
                    ld.SLA_Expires__c = DateTime.now().addHours(SLAHours(cm.SLA_Hours__c.intValue()));
                    cm.First_SLA_Owner__c = ld.OwnerID;
                }
                else
                {
                    //L
                    ld.SLA_Expires__c = DateTime.Now().addHours(SLAHours(24));
                    cm.Second_SLA_Owner__c = ld.OwnerID;
                }
                cm.SLA_Expires__c = ld.SLA_Expires__c;
                modifiedleads.put(ld.id, ld);
            }
            else
            {
	            // If new owner isn't user and isn't a sharttank queue, continue
	            if( ld.OwnerID.getSObjectType() != User.getSObjectType() && SLA_Configuration.getAllSLALeadMovementQueueIDs().contains(ld.OwnerID)) continue;
	            // If old one isn't either sla user or sharktank continue
	            if(!oldconfig.onLead() && ! SLA_Configuration.getAllSLALeadMovementQueueIDs().contains(oldmap.get(ld.id).OwnerID)) continue;

                // M here - transferred to non SLA
                ld.SLA_Expires__c = null;
                ld.SLA_Cycles__c = null;
                modifiedleads.put(ld.id, ld);
                cm.SLA_Achieved__c = DateTime.Now();
                cm.Transferred_to_Non_SLA_Owner__c = true;
                
            }



        }

        return modifiedleads.values();
    }   

   
    
    // Get SLA hours
    // It turns out, there is no easy way to get the day of week in Apex
    // So the "cheat" here is to pick a reference saturday in 1970, count the days
    // from them, and take the modulus of 7. The remainder will be 0 for Saturday,
    // 1 for Sunday.
    // The problem gets a lot trickier if you have different "weekends" by locale, but
    // that's beyond the scope of the requirements here.
    /*private static Integer SLAHours(Campaign camp)
    {
        double hours = (camp.Campaign_SLA__c == null)? 2: camp.Campaign_SLA__c;
        return SLAHours(hours.intValue());
    }
    */

    private static Integer SLAHours(CampaignMember cm)
    {
        if(Test.isRunningTest()) return 2;  // In test mode, we aren't querying our fields
        double hours = cm.SLA_Hours__c;
        return SLAHours(hours.intValue());
    }
    
    // Returns the weekeday hours for the specified duration
    public static Integer SLAHours(Integer hoursfromnow)
    {
    	Integer weekdayhours = hoursfromnow;
    	Integer TodaysWeekDay = Weekday(Date.Today());
    	Integer HoursToEndDay = 24 - DateTime.Now().hour();

		// This is a somewhat brute force approach - dealing with the edge conditions
		// mathematically turned out to be complex.

    	while (TodaysWeekDay >=5) 
    	{	// Today is already a weekend
    		weekdayhours+=24;
    		TodaysWeekday= Math.Mod(TodaysWeekday+1,7);
    	}
    	    	
    	while(hoursfromnow >= HoursToEndDay)
    	{
    		TodaysWeekday= Math.Mod(TodaysWeekday+1,7);
    		if(TodaysWeekDay <= 4) hoursfromnow -=24; else weekdayhours+=24;
    	}
    	
        //if(math.mod(ReferenceSaturday.daysBetween(target.Date()),7)<2) hoursfromnow+= (24 * (2- math.mod(ReferenceSaturday.daysBetween(target.Date()),7) ));
        return weekdayhours;        
    }
    
    // Returns the day of week, where Monday is day 0
    public static Integer Weekday(Date thisdate)
    {
        return math.mod(ReferenceSaturday.AddDays(2).daysBetween(thisdate),7);
    }

	public static string GetLeadQueryString(String fieldlist, String restofquery)
	{
		List<String> excludefields = new List<String>(SLA_Configuration.getAllExcludeRecordFieldNames());
		String querystring = fieldlist;
		if(excludefields.size()>0) querystring += ', ' + string.join(excludefields,',');
		querystring+= ' ' + restofquery;
		return querystring;
	}

}