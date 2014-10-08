/**
 * Contains logic for Opportunity cloning
 *
 * @author David Liu
 * @revision Kyle Vermeer 5/13/14   Added opportunityCloneCustomization and validatePrimaryContactOnClose
 */
public class OpportunityCustomization {

    /**
     * Validates that a opportunity has a primary contact before it closes.
     *
     * @param {Map<Id,Opportunity>} oldMap - Trigger.oldMap
     * @param {Map<Id,Opportunity>} newMap - Trigger.newMap
     */
    public static void validatePrimaryContactOnClose(Map<Id,Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        // Don't bother validating if this user/profile is exempt
        if(Opportunity_Management__c.getInstance().Exempt_From_Validation__c) return;
        
        // List of opportunities to process
        List<Opportunity> opstoprocess = new List<Opportunity>();
        
        for(Opportunity op: newMap.values())
        {
            if(op.StageName != oldMap.get(op.id).StageName)
            {
                opstoprocess.add(op);
            }
        }
        if(opstoprocess.size()==0) return;  // Nothing to process
        
        // Get primary contacts
        Map<ID, OpportunityContactRole> primarycontacts = OpportunityCustomization.GetPrimaryContacts(opstoprocess);
        
        // Now do the validation
        OpportunityCustomization.ValidateClosedWon(opstoprocess, primarycontacts, null);
        
        // That's it - any opportunities without a primary contact will be flagged with errors
    }


    /**
     * Trigger method for opportunity cloning.  Copies non-standard aspects of the opp
     *
     * @param {Map<Id,Opportunity>} newMap - Trigger.newMap
     */
    public static void opportunityCloneCustomization(Map<Id,Opportunity> newMap) {
        // Though this will likely only be called from the UI, one record at a time,
        // we'll build for bulk processing in case later APEX or API wants to do
        // bulk clone and is smart enough to set the Admin_Opportunity_Cloned_From__c field
        List<Opportunity> opstoprocess = new List<Opportunity>();
        if(trigger.isAfter)
        {   // On after trigger, only handle
            for(Opportunity op: newMap.values())
            {
                if(op.Admin_Opportunity_Cloned_From__c != null) opstoprocess.add(op);
            }
        }
        if(opstoprocess.size()==0) return; // It's not a clone
        
        // Mapped by opportunity ID
        Map<ID,OpportunityContactRole> primarycontacts = OpportunityCustomization.GetPrimaryContacts(opstoprocess);
        
        // Which ones don't yet have primary contacts?
        List<Opportunity> opneedsprimarycontact = new List<Opportunity>();
        for(Opportunity op: opstoprocess)
        {
            if(!primarycontacts.containskey(op.id)) opneedsprimarycontact.add(op);
        }
        
        Map<ID, OpportunityContactRole> Newprimarycontacts;
        if(opneedsprimarycontact.size()>0)
        {
            Newprimarycontacts = OpportunityCustomization.GetNewPrimaryContactsForOps(opneedsprimarycontact);
            if(NewPrimarycontacts.size()>0)
            {
                insert NewPrimaryContacts.values(); // Ok to insert new opportunitycontactroles
                // and merge the two lists. 
                primarycontacts.putall(NewPrimaryContacts);
            }
        }

        // Now let's finish up
        
        // Get the map to campaign sources
        Map<ID, ID> MostRecentCampaigns = OpportunityCustomization.GetMostRecentCampaign(new Map<ID, Opportunity>(opstoprocess), primarycontacts);
        
        // Build list of changes to current opportunities
        // We have to do it this way because this is an after trigger - we can't just modify the original list
        Map<ID, ID> NewOpportunityCampaignIds = new Map<ID, ID>();
        for(Opportunity op: opstoprocess)
        {
            if(op.CampaignID != MostRecentCampaigns.get(op.id))
            {
                NewOpportunityCampaignIDs.put(op.id, MostRecentCampaigns.get(op.id));
            }
        }

        // If we're exempt from validation, we're now done, so exit.
        if(Opportunity_Management__c.getInstance().Exempt_From_Validation__c) 
        {
            OpportunityCustomization.UpdatePrimaryCampaigns(NewOpportunityCampaignIDs);
            return;
        }
        
        // Validate that any closed opportunities have primary contacts
        OpportunityCustomization.ValidateClosedWon(opstoprocess, primarycontacts, NewOpportunityCampaignIDs );
        
        OpportunityCustomization.UpdatePrimaryCampaigns(NewOpportunityCampaignIDs);
    }
    
    // Return map of primary opportunity contact role by opportunity ID
    public static Map<ID,OpportunityContactRole> GetPrimaryContacts(List<Opportunity> ops)
    {
        List<OpportunityContactRole> ocrs = [SELECT ID, IsPrimary, ContactID, OpportunityID FROM OpportunityContactRole where IsPrimary=true and OpportunityID in :ops];
        Map<ID, OpportunityContactRole> primaryocrs = new Map<ID, OpportunityContactRole>();
        // This is safe because there is only one possible primary opportunitycontactrole per opportunity
        for(OpportunityContactRole ocr: ocrs)
        {
            primaryocrs.put(ocr.OpportunityID, ocr);
        }
        return primaryocrs;      
    }

    // Create new primary contact roles for source of cloned opportunities
    public static Map<ID, OpportunityContactRole> GetNewPrimaryContactsForOps(List<Opportunity> ops)
    {
        System.Debug('GetNewPrimaryContactsForOps: ' + ops.size());
        // Map from original op id to new one
        Map<ID, ID> sourceopidmap = new Map<ID, ID>();
        
        for(Opportunity op:ops)
        {
            sourceopidmap.put(op.Admin_Opportunity_Cloned_From__c,  op.id); 
        }
        // Now grab the source info
        List<OpportunityContactRole> sourceocrs = [SELECT ID, OpportunityID, ContactID, IsPrimary, Role From OpportunityContactRole where IsPrimary=true and  OpportunityID in :sourceopidmap.keyset()];
        
        // Now create the duplicates
        Map<ID, OpportunityContactRole> newocrs = new Map<ID, OpportunityContactRole>();
        for(OpportunityContactRole ocr: sourceocrs)
        {
            newocrs.put(sourceopidmap.get(ocr.OpportunityID), new OpportunityContactRole(OpportunityID=sourceopidmap.get(ocr.OpportunityID), ContactID = ocr.ContactID, IsPrimary = true, Role = ocr.Role));
        }
        return newocrs;
    }
    
    // Return map of most recent CampaignID for each Opportunity
    public static Map<ID, ID> GetMostRecentCampaign(Map<ID, Opportunity> ops, Map<ID, OpportunityContactRole> primaryocrs)
    {
        
        // Map of primary ContactIDs to OpportunityIDS 
        Map<ID, Opportunity> contactopmap = new Map<ID,Opportunity>();
        for(OpportunityContactRole ocr:primaryocrs.values())
        {
            contactopmap.put(ocr.ContactID, ops.get(ocr.OpportunityID ));
        }
        
        // Get most campaign members for all contacts
        List<Contact> cts = [SELECT ID, (SELECT ID, CampaignID, ContactID, FirstRespondedDate from CampaignMembers where HasResponded=true Order By FirstRespondedDate DESC LIMIT 1 ) from Contact where ID in :contactopmap.keyset()];

        Map<ID,ID> results = new Map<ID, ID>();
        
        // Now find the most recent one on each contact that is before the opportunity create date
        for(Contact ct: cts)
        {
            if(ct.campaignmembers.size()>0)
            {
                results.put(contactopmap.get(ct.id).id, ct.campaignmembers[0].CampaignID);
            }
        }
        return results;     
        
    }
    
    
    // Validate list of opps to make sure each one has a primary contact when closed/won
    // Sets object error message if not
    // If opstoupdate is not null and it contains a key that matches an invalid opportunity, that entry is
    // removed from the opstoupdate list.
    public static void ValidateClosedWon(List<Opportunity> ops, Map<ID, OpportunityContactRole> primarycontacts, Map<ID, ID>opstoupdate)
    {
        Map<String, OppValidationStages__c> oppstages = OppValidationStages__c.getAll();
        if(oppstages==null || oppstages.size()==0) return;  // No validation if no stages defined
        for(Opportunity op: ops)
        {
            if(!primarycontacts.containskey(op.id))
            {
                Boolean foundstage = false;
                for(OppValidationStages__c opstage: oppstages.values())
                {
                    if(opstage.stagename__c == op.StageName)
                    {
                        foundstage = true;
                        break;
                    }
                }
                if(foundstage)
                {
                    op.addError('You cannot save an opportunity with a ' + op.StageName + ' stage without a Primary Contact. Please adjust the Opportunity stage to an open value (such as ‘Negotiation/Review’) and save the record. Then add a primary contact role to this opportunity. After this is done you can edit and close out this Opportunity.');
                    if(opstoupdate!=null) opstoupdate.remove(op.id);
                }
            }
        }
    }
    
    // Receives map of opportunity ID along with new CampaignID for each. Updates
    public static void UpdatePrimaryCampaigns(Map<ID, ID>opstoupdate)
    {
        if(opstoupdate==null || opstoupdate.size()==0) return;
        List<Opportunity> ops = [SELECT ID, CampaignID from Opportunity where ID in :opstoupdate.keyset()];
        for(Opportunity op: ops)
        {
            op.CampaignID = opstoupdate.get(op.id);
        }
        update ops;
    }
    
}