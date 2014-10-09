/**
 * Utility methods for campaign association related to Online Sales
 *
 * @author Kyle Vermeer 9/17/14
 */
public class OnlineSales_CampaignAssociation {
    
    public ErrorTracker et {
        get {
            if (et == null) {
                et = new ErrorTracker();
            }
            return et;
        }
        set;
    }

    public OnlineSales_CampaignAssociation(ErrorTracker et) {
        this.et = et;
    }

    /**
     * Associates campaign with a contact / opp when there is no active response
     *
     * @param Id cId - id of contact to associate campaign
     * @param Id oppId - id of opp to attribute to campaign
     * @param Id defaultCampaignId - id of default campaign for transaction
     */
    public void associateCampaignNoActiveResponse(Id cId, Id oppId, Id defaultCampaignId) {
        if( defaultCampaignId == null ) { // check for null input
            System.debug('Null campaign Id provided. Cannot associate campaign.');
            return;
        }
        try { // Try to associate campaign
            CampaignMember defaultResponse = new CampaignMember(Status = 'Responded', 
                                                            FCRM__FCR_Admin_Response_Control__c = 10, 
                                                            CampaignId = defaultCampaignId,
                                                            FCRM__FCR_Opportunity__c = oppId,
                                                            ContactId = cId);
            insert defaultResponse;
        }
        catch( Exception e ) {
            et.addWarning('Campaign Attribution failed! Error: ' + e.getMessage());
        }
    }

    /**
     * Returns a CampaignMember is the lead has an active response, otherwise returns null
     *
     * @param Lead l - lead to check for active response
     * @return CampaignMember - active response, or null if none exists
     */
    public CampaignMember getActiveResponseLead(Lead l) {
        List<CampaignMember> activeResponses = FCRM.FCR_SupportAPI.GetActiveResponses(new List<Id> { l.Id });
        if( activeResponses.isEmpty() ) {
            return null;
        }
        else {
            return activeResponses[0];
        }
    }

    /**
     * Associates the default campaign with a contact where there is an active response.
     *
     * THIS SHOULD BE USED BEFORE OPP IS CREATED
     *
     * @param Id cId - id of contact to associate with campaign
     * @param Id defaultCampaignId - id of the default campaign for the transaction
     */
    public void associateDefaultCampaignContactWithActiveResponse(Id cId, Id defaultCampaignId) {
        if( defaultCampaignId == null ) {
            System.debug('Null campaign Id provided. Cannot associate campaign.');
            return;
        }
        try { // Try to associate campaign
            CampaignMember defaultResponse = new CampaignMember(Status = 'Responded', 
                                                                FCRM__FCR_Admin_Response_Control__c = 10, 
                                                                CampaignId = defaultCampaignId,
                                                                ContactId = cId);
            insert defaultResponse;
        }
        catch( Exception e ) {
            et.addWarning('Campaign Attribution failed! Error: ' + e.getMessage());
        }
        
    }

    /**
     * Associate an active response with an opp
     *
     * @param Id oppId - id of opportunity to associate activeResponse to
     * @param CampaignMember activeResponse - the active response
     */
    public void associateActiveResponse(Id oppId, CampaignMember activeResponse) {
        if( activeResponse == null ) {
            System.debug('Null active response provided.  Cannot associate response.');
            return;
        }
        try { // Try to associate campaign
            activeResponse.FCRM__FCR_Opportunity__c = oppId;
            activeResponse.FCRM__FCR_Admin_Response_Control__c = 8;
            update activeResponse;
        }
        catch( Exception e ) {
            et.addWarning('Campaign Attribution failed! Error: ' + e.getMessage());
        }
    }

    public void associateDefaultCampaignWithLead(Id leadId, Id defaultCampaignId) {
        if( defaultCampaignId == null ) {
            System.debug('Null campaign Id provided.  Cannot associate campaign.');
            return;
        }
        try {
            CampaignMember defaultResponse = new CampaignMember(CampaignId = defaultCampaignId,
                                                                LeadId = leadId);
            insert defaultResponse;
        }
        catch( Exception e ) {
            et.addWarning('Campaign Attribution Failed! Error: ' + e.getMessage());
        }
    }
}