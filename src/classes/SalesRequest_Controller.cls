/**
 * Controller for the Sales Request VF page
 *
 * @author Kyle Vermeer 5/30/14
 */
public class SalesRequest_Controller {
	
    @TestVisible
    private static String OPPORTUNITY_ID_PARAMETER = 'opportunityId';
    @TestVisible
    private static String ACCOUNT_ID_PARAMETER = 'accountId';
    @TestVisible
    private static String LEAD_ID_PARAMETER = 'leadId';
    @TestVisible
    private static String CONTACT_ID_PARAMETER = 'contactId';
    @TestVisible
    private static String RISK_ID_PARAMETER = 'riskId';
    @TestVisible
    private static String CATEGORY_PARAMETER = 'category';

    private static final String CATEGORY_DEFAULT = 'General';
    private static final String CATEGORY_SALES_OPS = 'SalesOps';
    private static final String CATEGORY_PERSONNEL = 'Personnel';
    private static final String TITLE_DEFAULT = 'Sales Requests';
    private static final String TITLE_SALES_OPS = 'Sales Ops & Revenue Ops';
    private static final String TITLE_PERSONNEL = 'Personnel Change';

    ///////////////////////////
    // Public Properties
    ///////////////////////////

    public String opportunityId { get; set; }
    public String accountId { get; set; }
    public String leadId { get; set; }
    public String contactId { get; set; }
    public String riskId { get; set; }
    public String category { get; set; }

    public String oppName { 
        get {
            if (oppName == null) {
                oppName = '';
            }
            return oppName;
        }
        set;
    }
    public String accountName {
        get {
            if (accountName == null) {
                accountName = '';
            }
            return accountName;
        }
        set;
    }
    public String leadName {
        get {
            if (leadName == null) {
                leadName = '';
            }
            return leadName;
        }
        set;
    }
    public String contactName {
        get {
            if (contactName == null) {
                contactName = '';
            }
            return contactName;
        }
        set;
    }
    public String riskName {
        get {
            if (riskName == null) {
                riskName = '';
            }
            return riskName;
        }
        set;
    }

    public String title {
        get {
            if( category == CATEGORY_SALES_OPS ) {
                return TITLE_SALES_OPS;
            }
            else if( category == CATEGORY_PERSONNEL ) {
                return TITLE_PERSONNEL;
            }
            else {
                return TITLE_DEFAULT;
            }
        }
        set;
    }

    public String subtitle {
        get {
            if( category == CATEGORY_SALES_OPS ) {
                return 'Before submitting your sales request, for FAQs and policy documentation, ';
            }
            else {
                return null;
            }
        }
        set;
    }

    public String subtitleLinkAnchor {
        get {
            if( category == CATEGORY_SALES_OPS ) {
                return 'please visit the Sales Operations Help Desk.';
            }
            else {
                return null;
            }
        }
    }

    public String subtitleLink {
        get {
            if( category == CATEGORY_SALES_OPS ) {
                return '/apex/sopshd_index';
            }
            else {
                return null;
            }
        }
    }

    public List<SalesRequestView> requestViews { get; set; }

    /**
     * Constructor
     */
    public SalesRequest_Controller() {
        getInfoFromURL();
		initializeViews();
	}

    /**
     * Initializes the requestViews property
     */
    private void initializeViews() {
        List<Sales_Request_Entry__c> srEntries = [SELECT Id, Name, Info_Text__c, Link_to_Request_Page__c, 
                                                         Account_Parameter_Name__c, Opportunity_Parameter_Name__c,
                                                         Lead_Parameter_Name__c, Contact_Parameter_Name__c, 
                                                         Risk_Parameter_Name__c, Is_VisualForce_Page__c,
                                                         Only_Allow_Profiles__c, Restrict_From_Profiles__c,
                                                         Listed_Profiles__c
                                                    FROM Sales_Request_Entry__c
                                                   WHERE Category__c = :this.category];
        String profileId = UserInfo.getProfileId();
        Profile userProfile = [SELECT Name From Profile WHERE Id = :profileId LIMIT 1];
        String profileName = userProfile.Name;
        srEntries = SalesRequest_SortingAlgorithm.sort(srEntries);
        requestViews = new List<SalesRequestView>();
        for (Sales_Request_Entry__c currentSREntry : srEntries) {
            // If we should still display the entry, add it to the view list
            if (shouldDisplayEntry(currentSREntry, profileName)) {
                requestViews.add(new SalesRequestView(currentSREntry, this));
            }
        }
    }

    private Boolean shouldDisplayEntry(Sales_Request_Entry__c entry, String profileName) {
        // default display entry to true
        Boolean displayEntry = true;

        // Check if the entry only allows certain profiles
        if (entry.Only_Allow_Profiles__c) {
            displayEntry = false; // remove display from default
            if (entry.Listed_Profiles__c != null) {
                String[] profileNames = entry.Listed_Profiles__c.split(';');
                for (String currentProfileName : profileNames) {
                    if (currentProfileName.trim() == profileName) {
                        displayEntry = true;
                    }
                }
            }
        }
        // Check if the entry doesn't allow certain profiles
        if (entry.Restrict_From_Profiles__c) {
            if (entry.Listed_Profiles__c != null) {
                String[] profileNames = entry.Listed_Profiles__c.split(';');
                for (String currentProfileName : profileNames) {
                    if (currentProfileName.trim() == profileName) {
                        displayEntry = false;
                    }
                }
            }
        }
        return displayEntry;
    }

    /**
     * Get opp and account info from URL
     */
    private void getInfoFromURL() {
        this.opportunityId = ApexPages.currentPage().getParameters().get(OPPORTUNITY_ID_PARAMETER);
        this.accountId = ApexPages.currentPage().getParameters().get(ACCOUNT_ID_PARAMETER);
        this.leadId = ApexPages.currentPage().getParameters().get(LEAD_ID_PARAMETER);
        this.contactID = ApexPages.currentPage().getParameters().get(CONTACT_ID_PARAMETER);
        this.riskId = ApexPages.currentPage().getParameters().get(RISK_ID_PARAMETER);
        this.category = ApexPages.currentPage().getParameters().get(CATEGORY_PARAMETER);
        if ( this.category == null ) {
            this.category = CATEGORY_DEFAULT;
        }

        try {
            if (this.opportunityId != null) {
                Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Id = :this.opportunityId];
                this.oppName = opp.Name;
            }
        }
        catch (Exception e) {
            // Ignore it
        }
        try {
            if (this.accountId != null) {
                Account acc = [SELECT Id, Name FROM Account WHERE Id = :this.accountId];
                this.accountName = acc.Name;
            }
        }
        catch (Exception e) {
            // Ignore it
        }
        try {
            if (this.leadId != null) {
                Lead l = [SELECT Id, Name FROM Lead WHERE Id = :this.leadId];
                this.leadName = l.Name;
            }
        }
        catch (Exception e) {
            // Ignore it
        }
        try {
            if (this.contactId != null) {
                Contact c = [SELECT Id, Name FROM Contact WHERE Id = :this.contactId];
                this.contactName = c.Name;
            }
        }
        catch (Exception e) {
            // Ignore it
        }
        try {
            Risk__c r = [SELECT Id, Name FROM Risk__c WHERE Id = :this.riskId];
            this.riskName = r.Name;
        }
        catch (Exception e) {
            // Ignore it
        }
    }

    /**
     * Class used to pass information about sales requests to the VF page
     */
    public class SalesRequestView {

        //////////////////////////////
        // Public Member Variables
        //////////////////////////////
        public SalesRequest_Controller controller;
        public String requestName { get; set; }
        public String infoText { get; set; }
        public String link { get; set; }
        // Just to hold the info
        private String accountParameterName { get; set; }
        private String opportunityParameterName { get; set; }
        private String leadParameterName { get; set; }
        private String contactParameterName { get; set; }
        private String riskParameterName { get; set; }

        /**
         * Constructor
         */
        public SalesRequestView(Sales_Request_Entry__c srEntry, SalesRequest_Controller control) {
            this.requestName = srEntry.Name;
            this.infoText = srEntry.Info_Text__c;
            this.accountParameterName = srEntry.Account_Parameter_Name__c;
            this.opportunityParameterName = srEntry.Opportunity_Parameter_Name__c;
            this.leadParameterName = srEntry.Lead_Parameter_Name__c;
            this.contactParameterName = srEntry.Contact_Parameter_Name__c;
            this.riskParameterName = srEntry.Risk_Parameter_Name__c;
            this.link = addParametersToLink(srEntry.Link_to_Request_Page__c, control, srEntry.Is_VisualForce_Page__c);
        }

        /**
         * Transforms a base url into a url with appropriate parameters
         *
         * Note: This method requeries that accountParameterName and opporunityParameterName be populated
         *       to function properly.  Otherwise, it won't add any paramters.
         *
         * @param {String} baseLink - baseLink for request (we will be added parameters to this)
         * @param {SalesRequest_Controller} control - controller these views exist in
         * @param {Boolean} isVFPage - does this request lead to a VF page?
         * @return {String} - baseLink + new parameters
         */
        private String addParametersToLink(String baseLink, SalesRequest_Controller control, Boolean isVFPage) {
            if (baseLink == null) {
                System.debug('baseLink was null, what the hell guys');
                return '#';
            }
            String newLink = baseLink;

            // Add ? for parameters if the link does not include parameters
            if (!baseLink.contains('?')) { 
                newLink += '?';
            }

            // Add oppId if the request accepts oppIds and oppId is not null
            if (control.opportunityId != null && this.opportunityParameterName != null) {
                if (isVFPage) { // for VF page, just send unaltered parameter
                    newLink += '&' + this.opportunityParameterName + '=' + control.opportunityId;
                }
                else { // For non-VF page, we need to add some additional things
                    newLink += '&CF' + this.opportunityParameterName + '=' + EncodingUtil.urlEncode(control.oppName, 'UTF-8');
                    newLink += '&CF' + this.opportunityParameterName + '_lkid' + '=' + control.opportunityId;
                }
                
            }

            // Add accountId if the request accepts accountIds and accountId is not null
            if (control.accountId != null && this.accountParameterName != null) {
                if (isVFPage) { // For VF page, just send unaltered parameter
                    newLink += '&' + this.accountParameterName + '=' + control.accountId;
                }
                else { // For non-VF page, we need to do some additional things
                    newLink += '&CF' + this.accountParameterName + '=' + EncodingUtil.urlEncode(control.accountName, 'UTF-8');
                    newLink += '&CF' + this.accountParameterName + '_lkid' + '=' + control.accountId;
                }
            }

            // Add leadId if the request accepts leadIds and leadId is not null
            if (control.leadId != null && this.leadParameterName != null) {
                if (isVFPage) { // For VF page, jsut send unaltered parameter
                    newLink += '&' + this.leadParameterName + '=' + control.leadId;
                }
                else { // For non-VF page, we need to do some additional things
                    newLink += '&CF' + this.leadParameterName + '=' + EncodingUtil.urlEncode(control.leadName, 'UTF-8');
                    newLink += '&CF' + this.leadParameterName + '_lkid' + '=' + control.leadId;
                }
            }

            // Add contactId if the request accepts contactIds and contactId is not null
            if (control.contactId != null && this.contactParameterName != null) {
                if (isVFPage) { // For VF page, jsut send unaltered parameter
                    newLink += '&' + this.contactParameterName + '=' + control.contactId;
                }
                else { // For non-VF page, we need to do some additional things
                    newLink += '&CF' + this.contactParameterName + '=' + EncodingUtil.urlEncode(control.contactName, 'UTF-8');
                    newLink += '&CF' + this.contactParameterName + '_lkid' + '=' + control.contactId;
                }
            }

            // Add riskId if the request accepts riskIds and riskId is not null
            if (control.riskId != null && this.riskParameterName != null) {
                if (isVFPage) { // For VF page, jsut send unaltered parameter
                    newLink += '&' + this.riskParameterName + '=' + control.riskId;
                }
                else { // For non-VF page, we need to do some additional things
                    newLink += '&CF' + this.riskParameterName + '=' + EncodingUtil.urlEncode(control.riskName, 'UTF-8');
                    newLink += '&CF' + this.riskParameterName + '_lkid' + '=' + control.riskId;
                }
            }

            return newLink;
        }
    }
}