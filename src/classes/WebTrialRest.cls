/**
 * Endpoint for web trials
 *
 * @author DLO
 * @revision Kyle Vermeer 8/13/14
 */
@RestResource(urlMapping='/processWebTrial/*')
global class WebTrialRest {
    private static final String OPP_STAGE_RECEIVED_PROSPECTING = 'Received / Prospecting';

    // Custom Setting stuffs
    @TestVisible static final String LEAD_STATUS_DISQUALIFIED;
    private static final InAppRestSettings__c settings        = InAppRestSettings__c.getInstance('default'); 
    public static final String CONVERTED_CONTACT_OPP_STAGE;
    private static final String DEFAULT_LEAD_CONVERTED_STATUS;
    private static final String WEB_TRIAL_CAMPAIGN_ID;

    static {
        CONVERTED_CONTACT_OPP_STAGE   = (settings == null) ? OPP_STAGE_RECEIVED_PROSPECTING : settings.Converted_Contact_Opp_Stage__c;
        DEFAULT_LEAD_CONVERTED_STATUS = (settings == null) ? 'Qualified - New Opportunity' : settings.Default_Lead_Converted_Status__c;
        WEB_TRIAL_CAMPAIGN_ID         = (settings == null) ? null : settings.Web_Trial_Campaign_ID__c;
        LEAD_STATUS_DISQUALIFIED      = (settings == null) ? 'Disqualified' : settings.Lead_Disqualified_Status__c;
    }

    // Important variables
    @TestVisible static WebTrial wt;
    @TestVisible static Opportunity opp;
    @TestVisible static WebTrialLogModel webTrialLogModel;
    private static boolean existingOpp = false;

    // FCRM Constants
    @TestVisible static final Integer ADMIN_RESPONSE_CONTROL = 8;
    @TestVisible static final Integer ADMIN_RESPONSE_CONTROL_CONTACT = 10;

    // Zuora constants
    @TestVisible static final String ZUORA_BILLING_ANNUAL           = 'Annual';
    @TestVisible static final String ZUORA_BILLING_MONTHLY          = 'Month';
    private static final String ZUORA_SUBSCRIPTION_STATUS_ACTIVE    = 'Active';
    private static final String ZUORA_PAYMENT_METHOD_CREDIT_CARD    = 'CreditCard';
    private static final String ZUORA_LAST_TRANSACTION_APPROVED     = 'Approved';
    private static final String ZUORA_LAST_PAYMENT_PROCESSED        = 'Processed';
    private static final String ZUORA_LAST_PAYMENT_VOIDED           = 'Voided';
    private static final String ZUORA_SUBSCRIPTION_STATUS_CANCELLED = 'Cancelled';
    private static final String ZUORA_SUBSCRIPTION_STATUS_EXPIRED   = 'Expired';

    // Other constants
    @TestVisible static final String OPP_STAGE_CLOSED_LOST    = 'Closed Lost';
    @TestVisible static final String OPP_STAGE_CLOSED_WON     = 'Closed Won';
    @TestVisible static final String CONTACT_STATUS_DISQUALIFIED = 'Disqualified';
    @TestVisible static final String CONTACT_DISQUALIFIED_REASON = 'Lost Web Trial';
    @TestVisible static final String CAMPAIGN_MEMBER_RESPONSE_STATUS_DISQUALIFIED = 'Disqualified';
    @TestVisible static final String CAMPAIGN_MEMBER_DISQUALIFIED_REASON = 'Lost Web Trial';
    @TestVisible static final String LEAD_DISQUALIFIED_REASON = 'Lost Web Trial';
    @TestVisible static final String OPP_NAME_APPEND          = '-Web Trial Conversion';
    @TestVisible static final String OPP_NAME_CANCEL_APPEND   = '-Web Trial Conversion(cancelled)';
    @TestVisible static final String OPP_NAME_DECLINE_APPEND  = '-Web Trial Conversion(cc decline)';
    @TestVisible static final String OPP_NAME_INACTIVE_APPEND = '-Web Trial Conversion(inactive)';
    @TestVisible static final String OPP_LOST_BIZ_REASON      = 'Lack of Adoption';
    @TestVisible static final String ENTERPRISE_BLOCK         = 'block';
    @TestVisible static final String CONTACT_STATUS_PENDING   = 'Pending';
    private static final String OWNER_QUEUE_PREFIX       = '00G';
    private static final String LEAD_STATUS_DEFAULT      = 'Pending';

    // Script status codes
    @TestVisible static final String STATUS_CC_DECLINED              = 'cc_declined';
    @TestVisible static final String STATUS_CLOSED_WON               = 'close_won';
    @TestVisible static final String STATUS_CLOSED_LOST              = 'close_lost';
    @TestVisible static final String STATUS_INACTIVE_WEBTRIAL        = 'inactive_webtrials';
    @TestVisible static final String STATUS_EXTENSION_PAYMENT_UNPROCESSED = 'trial_extension_no_payment_processed'; // CLOSED_WON
    private static final String STATUS_SCRIPT_ERROR                  = 'script_error';
    private static final String STATUS_INVALID_DATA                  = 'invalid_data';
    private static final String STATUS_DUPE_RECORDS_FOUND            = 'duplicate_records_found';
    private static final String STATUS_INACTIVE_ACCOUNT              = 'inactive_account';
    private static final String STATUS_EXTENSION_WITH_NON_CC         = 'rep_trial_extension_with_non_credit_card_payment_method';
    private static final String STATUS_ALREADY_CLOSED                = 'already_closed';
    private static final String STATUS_CLOSED_LOST_DOWNGRADED        = 'close_lost_downgraded';
    private static final String STATUS_UNDETERMINED                  = 'undetermined';
    @TestVisible static final String STATUS_INACTIVE_JUNK                 = 'inactive_webtrials_sal_junk';
    private static final String STATUS_ACTIVE_WITHOUT_BILLING        = 'active_rep_trial_without_active_billing_subscription';
    private static final String STATUS_NO_OPP_TRAILS                 = 'no_opportunity_trails';

    // Web Trial Field Names
    private static final String READ_ONLY = 'readOnly';
    private static final String EMAIL_FIELD = 'email';
    private static final String IS_DEACTIVATED = 'isDeactivated';
    private static final String IS_BLOCKED = 'isBlocked';
    private static final String TRIAL_END = 'trialEnd';
    private static final String ENTERPRISE_ID = 'enterpriseId';
    private static final String SEATS_SOLD = 'seatsSold';
    private static final String GB_SOLD = 'gbSold';
    private static final String LAST_PAYMENT_DATE = 'lastPaymentDate';
    private static final String SUBSCRIPTION_STATUS = 'subscriptionStatus';
    private static final String ARR_FIELD = 'arr';
    private static final String PAYMENT_METHOD_TYPE = 'paymentMethodType';
    private static final String BILLING_PERIOD = 'billingPeriod';
    private static final String LAST_TRANSACTION_STATUS = 'lastTransactionStatus';
    private static final String LAST_PAYMENT_STATUS = 'lastPaymentStatus';
    private static final String CURRENCY_ISO_CODE = 'currencyIsoCode';
    private static final String STATUS_CODE = 'statusCode';
    private static final String ERROR_MSG = 'errorMsg';
    private static final String SEND_NOTIFICATION_TO_ELOQUA = 'sendNotificationToEloqua';
    private static final String SET_ENTERPRISE_BLOCKED = 'setEnterpriseBlocked';
    private static final String OPPORTUNITY_ID = 'opportunityId';
    private static final String ACCOUNT_ID = 'accountId';
    private static final String ACCOUNT_NAME = 'accountName';
    private static final String OWNER_NAME = 'ownerName';
    static final Date TRIAL_START_DATE = Date.today().addDays(-15);

    @HttpPost
    global static WebTrial processWebTrial() {
        WebTrial webTrialRecord = new WebTrial(RestContext.request.requestBody.toString());
        return processSingleWebTrial(webTrialRecord);
    }

    @TestVisible private static WebTrial processSingleWebTrial(WebTrial webTrial) {
        System.debug('Beginning the web trial process...');
        webTrialLogModel = new WebTrialLogModel( WebTrialLogServices.buildWebTrialLog() );
        try {
            if (webTrial != null) {
                wt = webTrial;
                if ( String.isNotEmpty( wt.enterpriseId ) ) {
                    if ( String.isNotEmpty( wt.email ) ) {
                        determineCloseOutStatus();
                        if( wt.isClosedWon() )
                        {
                            opp = findOrCreateOpp();
                            confirmOpportunityData();
                            processResults();
                        }
                        else
                        {
                            processClosedLostWebTrialRequest();
                        }
                    } else {
                        wt.statusCode = STATUS_INVALID_DATA;
                        throw new CustomException('Error: Invalid email.');
                    }
                } else {
                    wt.statusCode = STATUS_INVALID_DATA;
                    throw new CustomException('Error: Invalid Enterprise ID.');
                }
            } else {
                wt = new WebTrial();
                wt.statusCode = STATUS_INVALID_DATA;
                throw new CustomException('Error: Invalid Web Trial object.');
            }
            webTrialLogModel.setSuccess();
        } catch (Exception e) {
            if ( String.isEmpty( wt.statusCode ) ) {
                wt.statusCode = STATUS_SCRIPT_ERROR;
            }
            wt.errorMsg = e.getStackTraceString() + ': ' + e.getMessage();
            webTrialLogModel.setErrorFields( e.getMessage(), wt );
        }
        setReturnVariables();
        webTrialLogModel.setIdFields( wt );
        webTrialLogModel.setStatusCode( wt );
        try
        {
            insert webTrialLogModel.currentLog;
        }
        catch ( DmlException dmlEx )
        {
            WebTrialLogServices.sendLogExceptionEmail( dmlEx.getMessage(), wt );
        }

        return wt;
    }

    @TestVisible static void processClosedLostWebTrialRequest()
    {
        opp = findExistingOpp();
        if( opp != null )
        {
            if( !opp.isClosed )
            {
                opp.StageName = OPP_STAGE_CLOSED_LOST;
                update opp;
                return;
            }
            else if(opp.isClosed && opp.StageName == OPP_STAGE_CLOSED_LOST)
            {
                wt.statusCode = STATUS_ALREADY_CLOSED;
                throw new CustomException('Error: Matching opportunity is already closed :' + opp.Id);
            }
        }

        Contact contact = findExistingContact();
        if ( contact != null )
        {
            disqualifyContact( contact );
            return;
        }

        Lead lead = findExistingLead();
        if ( lead != null )
        {
            disqualifyLead( lead );
            return;
        }

        lead = createNewLead( wt );
        FCRM.FCR_SupportAPI.TreatNextCampaignAssociationsAsResponsePrompts();
        associateWebTrialCampaign( lead.Id, null );
        disqualifyLead( lead );
    }

    @TestVisible static void disqualifyContact(Contact contact)
    {
        webTrialLogModel.setContactId( contact.Id );
        contact.FCRM__FCR_Status__c = CONTACT_STATUS_DISQUALIFIED;
        contact.Disqualified_Reason__c = CONTACT_DISQUALIFIED_REASON;
        contact.Trial_End_Date__c = Date.today();
        if(String.isBlank(contact.Box_Enterprise_ID__c)) contact.Box_Enterprise_ID__c = wt.enterpriseId;
        update contact;
    }

    @TestVisible static void disqualifyLead(Lead lead)
    {
        webTrialLogModel.setLeadId( lead.Id );
        lead.Status = LEAD_STATUS_DISQUALIFIED;
        lead.Disqualified_Reason__c = LEAD_DISQUALIFIED_REASON;
        lead.Trial_End_Date_Copy1__c = lead.Trial_End_Date_Copy2__c = lead.Trial_End_Date__c = Date.today();
        
        if(String.isBlank(lead.Box_Enterprise_ID__c)) lead.Box_Enterprise_ID_Copy__c = lead.Box_Enterprise_ID__c = wt.enterpriseId;
        update lead;
    }

    private static Sobject findSobjectByField(List<Sobject> sobjs, String field, Object value) {
        for(Sobject sobj : sobjs) {
            if(sobj.get(field) == value) {
                return sobj;
            }
        }

        return null;
    }

    private static List<Sobject> findSobjectsByField(List<Sobject> sobjs, String field, Object value) {
        List<Sobject> matches = new List<Sobject>();

        for(Sobject sobj : sobjs) {
            if(sobj.get(field) == value) {
                matches.add(sobj);
            }
        }

        return matches;
    }

    private static Lead findExistingLead() {
        System.debug('Searching for existing lead by enterprise id ' + wt.enterpriseId + ' and email ' + wt.email + '...');

        if (wt.enterpriseId == null || wt.email == null) {
            return null;
        }

        List<Lead> leads = [
            SELECT Id, Box_Enterprise_ID__c, OwnerId, Owner.UserRole.Name,
                Status, Email, Trial_End_Date__c, CreatedDate
            FROM Lead
            WHERE (Box_Enterprise_ID__c = :wt.enterpriseId OR Email = :wt.email)
            AND IsConverted = false
        ];

        if (leads.isEmpty()) {
            return null;
        } else {
            List<Lead> leadsWithEID = (List<Lead>)findSobjectsByField(leads, 'Box_Enterprise_ID__c', wt.enterpriseId);

            if(leadsWithEID.isEmpty()) {
                Lead leadWithoutEnterpriseId = findLeadWithoutEnterpriseId(leads);
                if(leadWithoutEnterpriseId == null) {
                    return null;
                } else {
                    return ensureLeadConvertability(leadWithoutEnterpriseId);
                }
            } else if(leadsWithEID.size() == 1) {
                return ensureLeadConvertability(leadsWithEID[0]);
            } else { // leadsWithEID.size() > 1
                List<Lead> leadsWithEIDAndEmail = (List<Lead>)findSobjectsByField(leadsWithEID, 'Email', wt.email);
                if(leadsWithEIDAndEmail.isEmpty()) {
                    Lead leadWithoutEnterpriseId = findLeadWithoutEnterpriseId(leads);
                    if(leadWithoutEnterpriseId == null) {
                        return null;
                    } else {
                        return ensureLeadConvertability(leadWithoutEnterpriseId);
                    }
                } else if(leadsWithEIDAndEmail.size() == 1) {
                    return ensureLeadConvertability(leadsWithEIDAndEmail[0]);
                } else { // leadsWithEIDAndEmail.size() > 1
                    List<Lead> leadsWithEIDAndEmailAndTrialEnd = (List<Lead>)findSobjectsByField(leadsWithEIDAndEmail, 'Trial_End_Date__c', wt.trialEnd);
                    if(leadsWithEIDAndEmailAndTrialEnd.isEmpty()) {
                        return ensureLeadConvertability((Lead)findOldestCreatedDate(leadsWithEIDAndEmail));
                    } else if(leadsWithEIDAndEmailAndTrialEnd.size() == 1) {
                        return ensureLeadConvertability(leadsWithEIDAndEmailAndTrialEnd[0]);
                    } else { // leadsWithEIDAndEmailAndTrialEnd.size() > 1
                        List<CampaignMember> activeResponses = FCRM.FCR_SupportAPI.GetActiveResponses(new List<Id>(Pluck.ids(leadsWithEIDAndEmailAndTrialEnd)));
                        activeResponses = requeryCampaignMembers(activeResponses);
                        List<Id> leadIdsWithActiveResponses = new List<Id>(Pluck.ids('LeadId', activeResponses));
                        List<Lead> leadsWithActiveResponses = mapIdsToLeads(leadIdsWithActiveResponses, new Map<Id, Lead>(leadsWithEIDAndEmailAndTrialEnd));
                        if(leadsWithActiveResponses.isEmpty()) {
                            return ensureLeadConvertability((Lead)findOldestCreatedDate(leadsWithEIDAndEmailAndTrialEnd));
                        } else if(leadsWithActiveResponses.size() == 1) {
                            Map<Id, Lead> leadMap = new Map<Id, Lead>(leadsWithEIDAndEmailAndTrialEnd);
                            return ensureLeadConvertability(leadsWithActiveResponses[0]);
                        } else { // leadsWithActiveResponses.size() > 1
                            CampaignMember oldestActiveResponseAfterTrialStart = (CampaignMember)findOldestCreatedDate(filterActiveResponsesCreatedAfterDate(activeResponses, TRIAL_START_DATE));
                            Map<Id, Lead> leadMap = new Map<Id, Lead>(leadsWithEIDAndEmailAndTrialEnd);
                            Lead leadWithOldestActiveResponseAfterTrialStart = leadMap.get(oldestActiveResponseAfterTrialStart.LeadId);
                            if(oldestActiveResponseAfterTrialStart == null) {
                                return ensureLeadConvertability((Lead)findOldestCreatedDate(leadsWithEIDAndEmailAndTrialEnd));
                            } else {
                                return ensureLeadConvertability((Lead)findOldestCreatedDate(leadsWithActiveResponses));
                            }
                        }
                    }
                }
            }
        }
    }

    static List<CampaignMember> requeryCampaignMembers(List<CampaignMember> campaignMembers) {
        return [
            SELECT LeadId, CreatedDate
            FROM CampaignMember
            WHERE Id IN :campaignMembers
        ];
    }

    static List<Lead> mapIdsToLeads(List<Id> leadIds, Map<Id, Lead> leads) {
        List<Lead> orderedLeads = new List<Lead>();

        for(Id leadId : leadIds) {
            orderedLeads.add(leads.get(leadId));
        }

        return orderedLeads;
    }

    static List<CampaignMember> filterActiveResponsesCreatedAfterDate(List<CampaignMember> activeResponses, Date trialStart) {
        List<CampaignMember> activeResponsesCreatedAfterDate = new List<CampaignMember>();

        for(CampaignMember activeResponse : activeResponses) {
            if(trialStart < activeResponse.CreatedDate) {
                activeResponsesCreatedAfterDate.add(activeResponse);
            }
        }

        return activeResponsesCreatedAfterDate;
    }

    static Sobject findOldestCreatedDate(List<Sobject> records) {
        Sobject oldest = null;

        for(Sobject record : records) {
            if(oldest == null) {
                oldest = record;
            } else if((Datetime)record.get('CreatedDate') < (Datetime)oldest.get('CreatedDate')) {
                oldest = record;
            }
        }

        return oldest;
    }

    static List<Lead> findLeadsWithLatestTrialEndDate(List<Lead> leads) {
        List<Lead> latest = new List<Lead>();
        Date latestDate = null;

        for(Lead lead : leads) {
            if(lead.Trial_End_Date__c == null) {
                continue;
            }

            if(latestDate == null) {
                latest.add(lead);
                latestDate = lead.Trial_End_Date__c;
            } else if(latestDate == lead.Trial_End_Date__c) {
                latest.add(lead);
            } else if(latestDate < lead.Trial_End_Date__c) {
                latest = new List<Lead>{lead};
                latestDate = lead.Trial_End_Date__c;
            }
        }

        return latest;
    }

    static Lead findLeadWithoutEnterpriseId(List<Lead> leads) {
        if(leads.isEmpty()) {
            return null;
        }

        List<Lead> leadsWithEmail = (List<Lead>)findSobjectsByField(leads, 'Email', wt.email);
        if(leadsWithEmail.isEmpty()) {
            return (Lead)findOldestCreatedDate(leadsWithEmail);
        } else if(leadsWithEmail.size() == 1) {
            return leadsWithEmail[0];
        } else { // leadsWithEmail.size() > 1
            List<Lead> leadsWithLatestTrialEndDate = findLeadsWithLatestTrialEndDate(leadsWithEmail);
            if(leadsWithLatestTrialEndDate.isEmpty()) {
                return (Lead)findOldestCreatedDate(leadsWithEmail);
            } else if(leadsWithLatestTrialEndDate.size() == 1) {
                return leadsWithLatestTrialEndDate[0];
            } else { // leadsWithLatestTrialEndDate.size() > 1
                List<CampaignMember> activeResponses = FCRM.FCR_SupportAPI.GetActiveResponses(new List<Id>(Pluck.ids(leadsWithLatestTrialEndDate)));
                activeResponses = requeryCampaignMembers(activeResponses);
                List<Id> leadIdsWithActiveResponses = new List<Id>(Pluck.ids('LeadId', activeResponses));
                List<Lead> leadsWithActiveResponses = mapIdsToLeads(leadIdsWithActiveResponses, new Map<Id, Lead>(leadsWithLatestTrialEndDate));
                if(leadsWithActiveResponses.isEmpty()) {
                    return ensureLeadConvertability((Lead)findOldestCreatedDate(leadsWithLatestTrialEndDate));
                } else if(leadsWithActiveResponses.size() == 1) {
                    Map<Id, Lead> leadMap = new Map<Id, Lead>(leadsWithLatestTrialEndDate);
                    return ensureLeadConvertability(leadsWithActiveResponses[0]);
                } else { // leadsWithActiveResponses.size() > 1
                    CampaignMember oldestActiveResponseAfterTrialStart = (CampaignMember)findOldestCreatedDate(filterActiveResponsesCreatedAfterDate(activeResponses, TRIAL_START_DATE));
                    Map<Id, Lead> leadMap = new Map<Id, Lead>(leadsWithLatestTrialEndDate);
                    Lead leadWithOldestActiveResponseAfterTrialStart = leadMap.get(oldestActiveResponseAfterTrialStart.LeadId);
                    if(oldestActiveResponseAfterTrialStart == null) {
                        return ensureLeadConvertability((Lead)findOldestCreatedDate(leadsWithLatestTrialEndDate));
                    } else {
                        return ensureLeadConvertability((Lead)findOldestCreatedDate(leadsWithActiveResponses));
                    }
                }
            }
        }
    }

    private static Lead ensureLeadConvertability(Lead l) {
        System.debug('Ensuring lead fields are ready for conversion...');

        Lead lead = l;
        if (reassignLeadOwnedByQueue(lead) || undoDisqualifiedStatus(lead) || reassignForbiddenLeadOwners(lead)) {
            update lead;
            System.debug('Lead has been updated and is now conversion ready!');
        } else {
            System.debug('Lead does not need updating to be ready for conversion.');
        }
        return lead;
    }

    private static boolean reassignLeadOwnedByQueue(Lead lead) {
        System.debug('Checking if lead is owned by a queue...');

        boolean needsUpdating = false;
        if (lead != null && String.valueOf(lead.OwnerId).startsWith(OWNER_QUEUE_PREFIX)) {
            lead.OwnerId = UserInfo.getUserId();
            needsUpdating = true;
            System.debug('This lead is owned by a queue. New owner: ' + UserInfo.getUserId());
        }
        return needsUpdating;
    }

    private static boolean undoDisqualifiedStatus(Lead lead) {
        System.debug('Checking if lead status is disqualified...');

        boolean needsUpdating = false;
        if (lead.Status != null && lead.Status.equals(LEAD_STATUS_DISQUALIFIED)) {
            lead.Status = LEAD_STATUS_DEFAULT;
            needsUpdating = true;
            System.debug('Lead status was disqualified and now is ' + LEAD_STATUS_DISQUALIFIED);
        }
        return needsUpdating;
    }

    @TestVisible static Boolean reassignForbiddenLeadOwners(Lead lead)
    {
        if( !wt.isClosedWon() ) return false;
        if( lead.Owner.UserRole.Name == NULL ) return false;
        
        List<Web_Trial_Owner_Reassignment__c> ownerReassignmentSetting = 
            [SELECT User_to_Reassign_To__c FROM Web_Trial_Owner_Reassignment__c WHERE Role_Name__c = :lead.Owner.UserRole.Name ];
        
        if( ownerReassignmentSetting.isEmpty() || lead.OwnerId == (Id)ownerReassignmentSetting[0].User_to_Reassign_To__c ) return false;
        
        lead.OwnerId = (Id)ownerReassignmentSetting[0].User_to_Reassign_To__c;
        return true;
    }

    @TestVisible
    static Opportunity findExistingOpp() {
        System.debug('Searching for existing opp by enterprise id ' + wt.enterpriseId + '...');

        if(String.isBlank(wt.enterpriseId)) {
            return opp;
        }

        List<Opportunity> opps = [
            SELECT Id, Name, Box_Enterprise_ID__c, Rep_Quota_Relief__c, IsClosed, StageName, Account.Id, Account.Name, Account.Owner.Name, CloseDate,
                (
                    SELECT Id, ContactId
                    FROM OpportunityContactRoles
                    WHERE IsPrimary = true
                )
            FROM Opportunity
            WHERE Box_Enterprise_ID__c = :wt.enterpriseId
            AND Web_Trial__c = TRUE
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        if (opps.isEmpty()) {
            return opp;
        }

        if (opps[0].StageName != null && opps[0].StageName.equals(OPP_STAGE_CLOSED_LOST)) {
            if( opps[0].CloseDate.daysBetween( Date.Today() ) >=0 && opps[0].CloseDate.daysBetween( Date.Today() ) <= 30 ) {
                opp = opps[0];
                return opp;
            }
        } else if (opps[0].IsClosed) {
            opp = opps[0];
            wt.statusCode = STATUS_ALREADY_CLOSED;
            throw new CustomException('Error: Matching opportunity is already closed [but not closed lost]: ' + opps[0].Id);
        } else {
            opp = opps[0];
            existingOpp = true;
            System.debug('Existing opp found!');
            if (opps[0].OpportunityContactRoles != null && opps[0].OpportunityContactRoles.size() == 1) {
                associateWebTrialCampaign(null, opps[0].OpportunityContactRoles[0].ContactId);
            }
        }

        return opp;
    }

    static Contact findWithActiveTrial(List<Contact> contacts) {
        Contact earliestTrialContact = null;

        for(Contact contact : contacts) {
            if(contact.Trial_Start_Date__c != null) {
                if(earliestTrialContact == null) {
                    earliestTrialContact = contact;
                } else {
                    if(contact.Trial_Start_Date__c < earliestTrialContact.Trial_Start_Date__c) {
                        earliestTrialContact = contact;
                    }
                }
            }
        }

        return earliestTrialContact;
    }

    static Contact findWithEarliestCreatedDate(List<Contact> records) {
        Contact earliestCreatedDate = null;

        for(Contact record : records) {
            if(earliestCreatedDate == null) {
                earliestCreatedDate = record;
                continue;
            }

            if(record.CreatedDate < earliestCreatedDate.CreatedDate) {
                earliestCreatedDate = record;
            }
        }

        return earliestCreatedDate;
    }

    @TestVisible
    static Contact matchMultipleContacts(List<Contact> contacts, String enterpriseId) {
        Contact matched = (Contact)findSobjectByField(contacts, 'Box_Enterprise_ID__c', enterpriseId);

        if(matched != null) {
            return matched;
        } else { // no contacts with a matching box enterprise id
            Contact earliestTrialContact = findWithActiveTrial(contacts);
            if(earliestTrialContact != null) {
                return earliestTrialContact;
            } else { // no contacts with active trials
                return findWithEarliestCreatedDate(contacts);
            }
        }
    }

    @TestVisible
    static Contact findExistingContact() {
        System.debug('Searching for existing contact by email ' + wt.email + '...');

        if (wt.email == null) {
                return null;
        }

        List<Contact> contacts = [
            SELECT Id, Email, AccountId, Account.Name, 
                   Trial_Start_Date__c, Trial_End_Date__c,
                   Trial_Type__c, Initial_Trial_Signup__c, CreatedDate, Box_Enterprise_ID__c
            FROM Contact
            WHERE email = :wt.email
        ];

        if (contacts == null || contacts.size() == 0) {
            // return nothing
            return null;
        } else if (contacts.size() == 1) {
            System.debug('Existing contact found!');
            Contact contact;
            contact = contacts[0];
            return contact;
        } else {
            return matchMultipleContacts(contacts, wt.enterpriseId);
        }
    }

    @TestVisible static Opportunity findOrCreateOpp() {
        System.debug('Finding or creating opp...');

        // First search for existing opp...
        opp = findExistingOpp();
        if (opp == null) {
            // Search for existing contact...
            Contact contact = findExistingContact();
            if (contact != null) {
                contact.Trial_End_Date__c = WebTrialRest.wt.trialEnd;
                opp = createOpportunityFromContact(wt, contact);
                if( !processResponseIfFound( contact.Id ) ){
                    associateWebTrialCampaign(null, contact.Id);
                }
            } else {
                // Search for existing lead...
                Lead lead = findExistingLead();
                
                Database.LeadConvertResult leadConvertResult;
                if( lead != null )
                {
                    updateLeadTrialEndDate( lead );
                    List<CampaignMember> responses = FCRM.FCR_SupportAPI.GetActiveResponses( new List<Id>{ lead.id } );
                    leadConvertResult = convertLead(lead);
                    if( leadConvertResult != null )
                    {
                       opp = new Opportunity(Id = leadConvertResult.getOpportunityId(), StageName = OPP_STAGE_CLOSED_WON );
                    }
                    if( responses.isEmpty() )
                    {
                        if( !processDisqualifiedTrialIfFound( lead.Id ) ){
                            associateWebTrialCampaign( null, leadConvertResult.getContactId() );
                        }
                    }
                }
                else {
                    lead = createNewLead(wt);
                    leadConvertResult = convertLead(lead);
                    if( leadConvertResult != null )
                    {
                        opp = new Opportunity(Id = leadConvertResult.getOpportunityId(), StageName = OPP_STAGE_CLOSED_WON );
                    }
                    associateWebTrialCampaign( null, leadConvertResult.getContactId() );
                }
                contact = new Contact( Id = leadConvertResult.getContactId() );
            }
            contact.FCRM__FCR_Status__c = CONTACT_STATUS_PENDING;
            update contact;

            // We do this step just in case assignment rules run and the owner changes
            queryOppData();
        }

        return opp;
    }

    @TestVisible static Boolean processResponseIfFound( Id contactId )
    {
        List<CampaignMember> responses = FCRM.FCR_SupportAPI.GetActiveResponses( new List<Id>{ contactId } );
        if( !responses.isEmpty() )
        {
            FCRM.FCR_SupportAPI.AssociateOpportunitiesToResponses( new List<Opportunity>{ opp } );
            return true;
        }
        return processDisqualifiedTrialIfFound( contactId );
    }

    static Boolean processDisqualifiedTrialIfFound( Id leadOrContactId )
    {
        List<CampaignMember> responses = FCCRM_ResponseUtilities.FindDQdTrialResponse( new List<Id>{ leadOrContactId } );
        if( responses.isEmpty() ) return false;
        
        responses[0].Reanimation_Audit_Field__c = DateTime.now();
        responses[0].FCRM__FCR_Admin_Response_Control__c = ADMIN_RESPONSE_CONTROL;
        responses[0].FCRM__FCR_Opportunity__c = opp.Id;
        update responses[0];
        
        return true;
    }

    @TestVisible static void updateLeadTrialEndDate( Lead lead )
    {
        lead.Trial_End_Date__c = wt.trialEnd;
        lead.Trial_End_Date_Copy1__c = lead.Trial_End_Date__c;
        lead.Trial_End_Date_Copy2__c = lead.Trial_End_Date__c;
        update lead;
    }

    // Make sure to duplicate the queried fields here in findExistingOpp()
    private static void queryOppData() {
        System.debug('Querying for opp data...');

        if (opp != null) {
            opp = [SELECT Id, Name, Account.Id, Account.Name, Account.Owner.Name FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
            System.debug('Opportunity data found  ^_^ Owner is ' + Account.Owner.Name);
        }
    }

    public static void associateWebTrialCampaign(Id leadId, Id contactId) {
        System.debug('Associating web trial campaign to record...');

        if (WEB_TRIAL_CAMPAIGN_ID != null) {
            CampaignMember cm = new CampaignMember();
            cm.CampaignId = WEB_TRIAL_CAMPAIGN_ID;
            cm.FCRM__FCR_Admin_Response_Control__c = ADMIN_RESPONSE_CONTROL;
            if (leadId != null) {
                cm.LeadId = leadId;
            } else {
                cm.FCRM__FCR_Admin_Response_Control__c = ADMIN_RESPONSE_CONTROL_CONTACT;
                cm.ContactId = contactId;
            }

            cm.FCRM__FCR_Opportunity__c = (opp == null) ? null : opp.Id;

            try {
                insert cm;
                System.debug('Campaign is now associated.');
            } catch (Exception e) {
                System.debug('Error associating to campaign: '+ e.getStackTraceString() + ': ' + e.getMessage() + '\nMoving on...');
            }
        }
    }

    public static Opportunity createOpportunityFromContact(WebTrial webTrial, Contact contact)
    {
        if (contact == null) return opp;
        
        if (webTrial.trialEnd == null)
        {
            webTrial.statusCode = STATUS_INVALID_DATA;
            throw new CustomException('Error: Cannot create Opportunity without a Trial End Date.');
        }
        opp = new Opportunity( Name = contact.Account.Name,
                               AccountId = contact.AccountId,
                               CloseDate = webTrial.trialEnd,
                               Initial_Trial_Signup__c = contact.Initial_Trial_Signup__c,
                               StageName = OPP_STAGE_CLOSED_WON,
                               Trial_Type__c = contact.Trial_Type__c,
                               Trial_Start_Date__c = contact.Trial_Start_Date__c,
                               Trial_End_Date__c = contact.Trial_End_Date__c,
                               Web_Trial__c = true );
        insert opp;

        OpportunityContactRole ocr = new OpportunityContactRole( ContactId = contact.Id,
                                                                 IsPrimary = true,
                                                                 OpportunityId = opp.Id );
        insert ocr;
        
        return opp;
    }

    public static String INDUSTRY_OTHER = 'Other';
    public static String PRIOR_ACCOUNT_TYPE_NONE = 'None';
    public static String ERRORMSG_READONLY_WEBTRIAL = 'Script is running in read only mode!';
    public static Lead createNewLead(WebTrial webTrial) {
        Lead lead;
        if (webTrial != null) {
            lead = new Lead();
            lead.LastName = webTrial.email;
            lead.Email = webTrial.email;
            lead.Company = webTrial.email;
            lead.Industry = INDUSTRY_OTHER;
            lead.Prior_Account_Type__c = PRIOR_ACCOUNT_TYPE_NONE;
            lead.Box_Enterprise_ID__c = webTrial.enterpriseId;
            lead.Trial_End_Date_Copy1__c = lead.Trial_End_Date_Copy2__c = lead.Trial_End_Date__c = webtrial.trialEnd;
            lead.Initial_Trial_Signup_Copy__c = lead.Initial_Trial_Signup__c = String.valueOf(webtrial.seatsSold);
            lead.Trial_Start_Date_Copy__c = lead.Trial_Start_Date__c = Date.today().addDays(-15);

            if (webTrial.readOnly == null || !webTrial.readOnly) {
                insert lead;
            } else {
                webTrial.errorMsg = ERRORMSG_READONLY_WEBTRIAL;
            }
        }
        return lead;
    }

    private static Database.LeadConvertResult convertLead(Lead lead) {
        Database.LeadConvertResult lcr;
        if (lead != null) {
            lead.Box_Enterprise_ID__c = wt.enterpriseId;
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lead.Id);
            lc.setConvertedStatus(DEFAULT_LEAD_CONVERTED_STATUS);
            if (wt.readOnly == null || !wt.readOnly) {
                lcr = Database.convertLead(lc);
                if (!lcr.isSuccess()) {
                    throw new CustomException('Error: Lead conversion error ' + lcr.getErrors());
                }
            } else {
                wt.errorMsg = 'Script is running in read only mode!';
            }
        }
        return lcr;
    }

    private static void confirmOpportunityData() {
        System.debug('Opp validation time, w00t w00t!');

        if ((wt.readOnly != null && wt.readOnly)) {
            // Skip
        } else if (opp != null) {
            updateField('Seats_Sold__c', wt.seatsSold);
            updateField('GB_Sold__c', wt.gbSold);
            updateField('Contact_Method_Most_Recent__c', 'Business Web Trial');
            updateField('CloseDate', wt.trialEnd);
            updateField('Account_Type_Sold__c', 'Business');
            //updateField('Amount', wt.arr);
            updatePaymentAmount();
            updateField('Quota_Relief__c', wt.arr);
            updateField('Payment_Method__c', wt.paymentMethodType);
            updateField('CurrencyIsoCode', wt.currencyIsoCode);
            updateField('Box_Enterprise_ID__c', wt.enterpriseId);
            updateField('Fee_Frequency__c', mapZuoraBillingPeriodToOppFeeFrequency(wt.billingPeriod));
            if (!existingOpp || (existingOpp && opp.Rep_Quota_Relief__c == null)) {
                updateField('Rep_Quota_Relief__c', false);
            }
        } else {
            throw new CustomException('Unknown error - opp could not be found or created. D. Lo needs a spanking!');
        }
    }

    /**
     * This method serves to allow from MRR tracking, but also allows ARR to be sent over in any non-monthly cases
     *
     * Updates either the MRR_Annualized__c or Amount field, depending on the billing period
     */
    private static void updatePaymentAmount() {
        Decimal amount = wt.arr;
        if (wt.billingPeriod == 'Month') { // If monthly, pay annualized
            updateField('MRR_Annualized__c', wt.arr);
            opp.Amount = null;
        }
        else { // If not annualized, still update Amount
            updateField('Amount', wt.arr);
        }
    }

    public static String mapZuoraBillingPeriodToOppFeeFrequency(String s) {
        System.debug('Mapping Zuora billing period...');

        if(String.isBlank(s)) {
            return null;
        } else if (s.equals('Annual')) {
            return 'Annual';
        } else if (s.equals('Month')) {
            return 'Monthly';
        } else if (s.equals('Quarter')) {
            return 'Quarterly';
        } else if (s.equals('Semi-Annual')) {
            return 'Semi-Annual';
        } else if (s.equals('Two Years')) {
            return 'Two Year Deal';
        } else if (s.equals('Three Years')) {
            return 'Three Year Deal';
        } else {
            return null;
        }
    }

    private static void updateField(String fieldName, Object fieldValue) {
        System.debug('Data confirmation for field ' + fieldName);

        if (fieldName != null && fieldValue != null) {
            opp.put(fieldName, fieldValue);
            System.debug('Data confirmed: ' + fieldName + ', ' + fieldValue);
        }
    }

    private static void determineCloseOutStatus() {
        System.debug('Determining opp close out status...');

        // If opp exists and subscription is active
        if (wt.subscriptionStatus != null && wt.subscriptionStatus.equals(ZUORA_SUBSCRIPTION_STATUS_ACTIVE) && (wt.isDeactivated == null || !wt.isDeactivated) && wt.enterpriseId != null) {
            // Payment is not CC
            if (wt.paymentMethodType != null && !wt.paymentMethodType.equals(ZUORA_PAYMENT_METHOD_CREDIT_CARD)) {
                wt.statusCode = STATUS_EXTENSION_WITH_NON_CC;
            // Transaction is not approved OR last payment is not processed or voided
            } else if ((wt.lastTransactionStatus != null && !wt.lastTransactionStatus.equals(ZUORA_LAST_TRANSACTION_APPROVED)) || (wt.lastPaymentDate != null && wt.lastPaymentStatus != null && !wt.lastPaymentStatus.equals(ZUORA_LAST_PAYMENT_PROCESSED) && !wt.lastPaymentStatus.equals(ZUORA_LAST_PAYMENT_VOIDED))) {
                 wt.statusCode = STATUS_CC_DECLINED;
             // Last payment processed
            } else if (wt.lastPaymentStatus != null && wt.lastPaymentStatus.equals(ZUORA_LAST_PAYMENT_PROCESSED)) {
                wt.statusCode = STATUS_CLOSED_WON;
            // No last payment date
            } else if (wt.lastPaymentDate == null) {
                // User blocked
                if (wt.isBlocked != null && wt.isBlocked) {
                    wt.statusCode = STATUS_INACTIVE_WEBTRIAL;
                // User not blocked (payment not processed)
                } else {
                    wt.statusCode = STATUS_EXTENSION_PAYMENT_UNPROCESSED;
                }
            } else {
                wt.statusCode = STATUS_UNDETERMINED;
            }
        // no last payment, user is blocked, and subscription is active.  In this version of the script, this case should never happen
        } else if (wt.lastPaymentDate == null && wt.isBlocked != null && wt.isBlocked && wt.subscriptionStatus != null && wt.subscriptionStatus.equals(ZUORA_SUBSCRIPTION_STATUS_ACTIVE) && (wt.isDeactivated == null || !wt.isDeactivated) && wt.enterpriseId != null) {
            wt.statusCode = STATUS_INACTIVE_JUNK;
        // no enterprise or user deactivated and subscription status is cancelled or expired
        } else if (wt.enterpriseId == null || (wt.enterpriseId != null && wt.isDeactivated != null && wt.isDeactivated && opp != null && wt.subscriptionStatus != null && (wt.subscriptionStatus.equals(ZUORA_SUBSCRIPTION_STATUS_CANCELLED) || wt.subscriptionStatus.equals(ZUORA_SUBSCRIPTION_STATUS_EXPIRED)))) {
            if (wt.enterpriseId != null) {
                wt.statusCode = STATUS_CLOSED_LOST;
            } else {
                wt.statusCode = STATUS_CLOSED_LOST_DOWNGRADED;
                wt.errorMsg = 'Can\'t find opportunities since we can\'t determine the enterprise ID  =(';
            }
        // we have an active enterprise and the subscription is empty or not active
        } else if (wt.enterpriseId != null && (wt.isDeactivated == null || wt.isDeactivated == false) && (wt.subscriptionStatus == null || !wt.subscriptionStatus.equals(ZUORA_SUBSCRIPTION_STATUS_ACTIVE))) {
            wt.statusCode = STATUS_ACTIVE_WITHOUT_BILLING;
        } else if (opp == null && (wt.readOnly == null || !wt.readOnly)) {
            wt.statusCode = STATUS_NO_OPP_TRAILS;
            throw new CustomException('Unknown error - opp could not be found or created. D. Lo needs a whipping!');
        } else {
            wt.statusCode = STATUS_UNDETERMINED;
        }
        System.debug('Close out status: ' + wt.statusCode);
    }

    @TestVisible static void processResults()
    {
        if (opp != null) {
            // Closed Won
            if (wt.statusCode != null && ( wt.statusCode.equals(STATUS_CLOSED_WON) || wt.statusCode.equals(STATUS_EXTENSION_PAYMENT_UNPROCESSED) )) {
                opp.Name      = opp.Account.Name + OPP_NAME_APPEND;
                opp.StageName = OPP_STAGE_CLOSED_WON;
                opp.CloseDate = wt.trialEnd;
                opp.Web_Trial__c = true;
                wt.sendNotificationToEloqua = true;
            // Closed Lost
            } else if (wt.statusCode != null && wt.statusCode.equals(STATUS_CLOSED_LOST)) {
                opp.Name      = opp.Account.Name + OPP_NAME_CANCEL_APPEND;
                opp.StageName = OPP_STAGE_CLOSED_LOST;
                opp.CloseDate = wt.trialEnd;
                opp.Lost_Biz_Reason__c = OPP_LOST_BIZ_REASON;
            // CC Declined
            } else if (wt.statusCode != null && wt.statusCode.equals(STATUS_CC_DECLINED)) {
                wt.setEnterpriseBlocked = ENTERPRISE_BLOCK;
                opp.Name = opp.Account.Name + OPP_NAME_DECLINE_APPEND;
                opp.CloseDate = wt.trialEnd;
                // Annual billing
                if (wt.billingPeriod != null && wt.billingPeriod.equals(ZUORA_BILLING_ANNUAL)) {
                    opp.StageName = OPP_STAGE_CLOSED_LOST;
                    opp.Lost_Biz_Reason__c = OPP_LOST_BIZ_REASON;
                // Monthly billing
                } else if (wt.billingPeriod != null && wt.billingPeriod.equals(ZUORA_BILLING_MONTHLY)) {
                    opp.StageName = OPP_STAGE_CLOSED_WON;
                    opp.Web_Trial__c = true;
                }
                wt.sendNotificationToEloqua = true;
            // Inactive web trial
            } else if (wt.statusCode != null && wt.statusCode.equals(STATUS_INACTIVE_WEBTRIAL)) {
                opp.Name = opp.Account.Name + OPP_NAME_INACTIVE_APPEND;
                opp.StageName = OPP_STAGE_CLOSED_LOST;
                opp.Lost_Biz_Reason__c = OPP_LOST_BIZ_REASON;
                opp.CloseDate = wt.trialEnd;
                wt.sendNotificationToEloqua = true;
            } else if (wt.statusCode != null && wt.statusCode.equals(STATUS_INACTIVE_JUNK)) {
                wt.sendNotificationToEloqua = true;
            // This is new - everything leftover is closed lost.
            } else {
                opp.Name      = opp.Account.Name + OPP_NAME_APPEND;
                opp.StageName = OPP_STAGE_CLOSED_LOST;
                opp.CloseDate = wt.trialEnd;
                opp.Lost_Biz_Reason__c = OPP_LOST_BIZ_REASON;
            }

            saveToSalesforce();
        }
    }

    private static void saveToSalesforce() {
        if (wt.readOnly == null || !wt.readOnly) {
            System.debug('ooooooooo man this is the real deal. saving to db in 3.. 2.. 1...');
            update opp;
            System.debug('Record saved.');
        } else {
            System.debug('This is just a test.');
            wt.errorMsg = 'Script is running in read only mode!';
        }
    }

    private static void setReturnVariables() {
        System.debug('Setting return variables...');

        if (opp != null) {
            wt.opportunityId = opp.Id;
            if (opp.Account.Id != null) {
                wt.accountId = opp.Account.Id;
            }
            if (opp.Account.Name != null) {
                wt.accountName = opp.Account.Name;
            }
            if (opp.Account.Owner.Name != null) {
                wt.ownerName = opp.Account.Owner.Name;
            }
        }
    }

    public static void resetWebTrialApi() {
        System.debug('Resetting web trial api...');

        opp = null;
        existingOpp = false;
    }

    global class WebTrial {

        public WebTrial(){}

        public WebTrial(String json_request)
        {
            if (json_request == null) return;
            JSONParser parser = JSON.createParser(json_request);
            while (parser.nextToken() != null)
            {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME)
                {
                    String field_name = parser.getText();
                    parser.nextToken();
                    System.debug('Current Token: ' + parser.getCurrentToken());
                    if (parser.getCurrentToken() == JSONToken.VALUE_NULL) continue;
                    System.debug('Text: ' + parser.getText());
                    if (field_name == READ_ONLY)
                        this.readOnly = parser.getBooleanValue();
                    else if (field_name == EMAIL_FIELD)
                        this.email = parser.getText();
                    else if (field_name == IS_DEACTIVATED)
                        this.isDeactivated = parser.getBooleanValue();
                    else if (field_name == IS_BLOCKED)
                        this.isBlocked = parser.getBooleanValue();
                    else if (field_name == TRIAL_END)
                        this.trialEnd = parser.getDateValue();
                    else if (field_name == ENTERPRISE_ID)
                        this.enterpriseId = parser.getText();
                    else if (field_name == SEATS_SOLD)
                        this.seatsSold = Integer.valueOf(parser.getText());
                    else if (field_name == GB_SOLD)
                        this.gbSold = Decimal.valueOf(parser.getText());
                    else if (field_name == LAST_PAYMENT_DATE)
                        this.lastPaymentDate = parser.getDateValue();
                    else if (field_name == SUBSCRIPTION_STATUS)
                        this.subscriptionStatus = parser.getText();
                    else if (field_name == ARR_FIELD)
                        this.arr = Decimal.valueOf(parser.getText());
                    else if (field_name == PAYMENT_METHOD_TYPE)
                        this.paymentMethodType = parser.getText();
                    else if (field_name == BILLING_PERIOD)
                        this.billingPeriod = parser.getText();
                    else if (field_name == LAST_TRANSACTION_STATUS)
                        this.lastTransactionStatus = parser.getText();
                    else if (field_name == LAST_PAYMENT_STATUS)
                        this.lastPaymentStatus = parser.getText();
                    else if (field_name == CURRENCY_ISO_CODE)
                        this.currencyIsoCode = parser.getText();
                    else if (field_name == STATUS_CODE)
                        this.statusCode = parser.getText();
                    else if (field_name == ERROR_MSG)
                        this.errorMsg = parser.getText();
                    else if (field_name == SEND_NOTIFICATION_TO_ELOQUA)
                        this.sendNotificationToEloqua = parser.getBooleanValue();
                    else if (field_name == SET_ENTERPRISE_BLOCKED)
                        this.setEnterpriseBlocked = parser.getText();
                    else if (field_name == OPPORTUNITY_ID)
                        this.opportunityId = parser.getText();
                    else if (field_name == ACCOUNT_ID)
                        this.accountId = parser.getText();
                    else if (field_name == ACCOUNT_NAME)
                        this.accountName = parser.getText();
                    else if (field_name == OWNER_NAME)
                        this.ownerName = parser.getText();
                    else
                        System.debug('Unknown Field Provided: ' +field_name);
                }
            }
        }

        public Boolean isClosedWon()
        {
            Boolean hasClosedWonStatusCode = ( statusCode == WebTrialRest.STATUS_CLOSED_WON );
            Boolean hasCCDeclinedAndMonthlyBilling = ( statusCode == WebTrialRest.STATUS_CC_DECLINED
                                                       && billingPeriod == WebTrialRest.ZUORA_BILLING_MONTHLY );
            Boolean hasExtensionPaymentUnprocessedStatusCode = ( statusCode == WebTrialRest.STATUS_EXTENSION_PAYMENT_UNPROCESSED );
            return hasClosedWonStatusCode || hasCCDeclinedAndMonthlyBilling || hasExtensionPaymentUnprocessedStatusCode;
        }

        // Debuggers
        public Boolean readOnly;

        // User fields
        public String email;
        public Boolean isDeactivated;
        public Boolean isBlocked;
        public Date trialEnd;

        // Enterprise fields
        public String enterpriseId;
        public Integer seatsSold;
        public Decimal gbSold;

        // Zuora fields
        public Date lastPaymentDate;
        public String subscriptionStatus;
        public Decimal arr;
        public String paymentMethodType;
        public String billingPeriod;
        public String lastTransactionStatus;
        public String lastPaymentStatus;
        public String currencyIsoCode;

        // Return
        public String statusCode;
        public String errorMsg;
        public Boolean sendNotificationToEloqua;
        public String setEnterpriseBlocked;

        // Object properties
        public String opportunityId;
        public String accountId;
        public String accountName;
        public String ownerName;
    }
}