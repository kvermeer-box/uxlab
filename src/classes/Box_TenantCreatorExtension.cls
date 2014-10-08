public without sharing class Box_TenantCreatorExtension {

    public Tenant__c tenant {get; set;} 
    public Boolean showSuccess {get; set;}   
    public Boolean isAuthenticated {get; set;} 
    public Boolean isATTPartner {get; set;} 
    public Boolean isStandardLicenseUser {get; set;}
    public string adminId {get;set;}
    
    public String adminEmail {get; set;}
    
    private String errorMsg {get; set;}
 
    //  Params
    private String accountId {get; set;}
    public String contactId {get; set;}
    private String opportunityId {get; set;}
    private String registrationId {get; set;}
    public String name {get; set;}
    private Boolean redirect {get; set;}
    public Boolean showHeader {get; set;} 
    private Decimal resellerID;

    public Box_TenantCreatorExtension(ApexPages.StandardController controller) {
        System.debug('(Controller) Tenant creator initialized.');        
        this.tenant = (Tenant__c)controller.getRecord();
               
        // Stores the accountId for Save and New use case
        this.accountId      = ApexPages.CurrentPage().getParameters().get('CF00N60000002Jm96_lkid');
        this.contactId      = ApexPages.CurrentPage().getParameters().get('contactid');
        this.opportunityId  = ApexPages.CurrentPage().getParameters().get('oppid');
        this.registrationId = ApexPages.CurrentPage().getParameters().get('regid');
        this.name           = ApexPages.CurrentPage().getParameters().get('name');        
        this.showHeader     = ApexPages.CurrentPage().getParameters().get('showheader') == null ? true : Boolean.valueOf(ApexPages.CurrentPage().getParameters().get('showheader'));                
        this.isATTPartner = false;
        // Redirect
        String redirectParam = ApexPages.CurrentPage().getParameters().get('redirect');
        if (redirectParam != null) {
            this.redirect = Boolean.valueOf(redirectParam);                       
        }
        
        // Set authentication and admin
        setIsAuthenticated();
        setIsStandardLicenseUser();
        Opportunity opp = [SELECT Id, Box_Partner_Account__r.Reseller_ID__c, Deal_Reg_Approval_Status__c FROM Opportunity WHERE Id =: this.opportunityId ];
        if( opp.Deal_Reg_Approval_Status__c != 'Approved' ){
            Apexpages.addMessage( new Apexpages.Message( Apexpages.Severity.ERROR, 'Deal Reg Approval Status needs to be approved to create Box Trial/Instance.' ) );
        }
        else {
            if (opp.Box_Partner_Account__r.Reseller_ID__c != null) {
                this.resellerId = opp.Box_Partner_Account__r.Reseller_ID__c;
            }
        }
        
        // Prepopulate fields
        prepopulateFields();
        
        showSuccess = false;
    }
    
    private void setIsAuthenticated() {
        System.debug('(Controller) Checking if user is authenticated...');
        isAuthenticated = !UserInfo.getUserType().equals('Guest');
        System.debug('(Controller) User is authenticated: ' + isAuthenticated);
        
        /*
        final String GUEST_USER_LICENSE_KEY = 'PID_Guest_User';
        Profile p = [SELECT Id, UserLicense.LicenseDefinitionKey FROM Profile WHERE Id = :UserInfo.getProfileId()];
        if (p.UserLicense.LicenseDefinitionKey != null && p.UserLicense.LicenseDefinitionKey.equals(GUEST_USER_LICENSE_KEY)) {
            isAuthenticated = false;
        } else {
            isAuthenticated = true;
        }
        */
    }
    
    private void setIsStandardLicenseUser() {
        System.debug('(Controller) Checking if user is a standard license user...');
        isStandardLicenseUser = UserInfo.getUserType().equals('Standard');
        System.debug('(Controller) User is a standard license user: ' + isStandardLicenseUser);
    }

    private void prepopulateFields() {
        tenant.Name               = name;
        tenant.Admin__c           = contactId;
        tenant.Registration_ID__c = registrationId;
        tenant.Account__c         = accountId;
        tenant.Reseller_Id__c     = this.resellerId;
        
        setAdminEmail();
        //if (!isAuthenticated) {
            // One day this will not be hardcoded  =)
            tenant.Deal_Status__c = 'trial';
        //}
        
        if (redirect == null) { redirect = true; }
    }

    public void syncSave() {
        System.debug('(Controller) Beginning sync and save...');        
        try {
            errorMsg = null;
            setTrialDates();
            insert tenant;
        } catch (Exception e) {
            errorMsg = e.getDmlMessage(0);
            return;
        }
        System.debug('(Controller) Tenant saved!');
    }
    
    public PageReference createSingle() {
        return createEnterprise(false);
    }
    
    public PageReference createMultiple() {
        return createEnterprise(true);
    }
        
    public void setAdminEmail() {
        if (adminId != null && adminId.startsWith('003')) {
            try {
                Contact c = [SELECT Email FROM Contact WHERE Id = :adminId];    
                adminEmail = c.Email;
                tenant.Admin__c = adminId;
            } catch (Exception e) {
                adminEmail = null;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));                
            }
        } else {
            adminEmail = null;
        }
    }
    
    private void setTrialDates() {
    	
        if (opportunityId != null && !opportunityId.equals('')) {

			try {
            	
            	Opportunity o = [SELECT Id, Box_Partner_Account__r.Reseller_ID__c, Box_Partner_Account__r.Partner_Trial_Length__c FROM Opportunity WHERE Id = :opportunityId];
                
                if( String.valueOf( o.Box_Partner_Account__r.Reseller_ID__c ) == '3980955827' ){
                	isATTPartner = true;
                }else {
                	isATTPartner = false;
                }
                    
		        if (tenant.Deal_Status__c.toLowerCase().equals(Box_EnterpriseDealStatusEnum.TRIAL.name().toLowerCase())) {
		            	
		        System.debug('(Controller) Setting trial end dates...');
	                    
	            	if (o.Box_Partner_Account__r.Partner_Trial_Length__c != null) {
	                	tenant.Trial_Start_Date__c = Date.today();    
	                    tenant.Trial_End_Date__c = tenant.Trial_Start_Date__c.addDays(Integer.valueOf(o.Box_Partner_Account__r.Partner_Trial_Length__c));
	                    System.debug('(Controller) Start date = ' + tenant.Trial_Start_Date__c + '; End date = ' + tenant.Trial_End_Date__c);
	                }
				}
			} catch (Exception e) { }                
             
        }
    }
        
    private PageReference createEnterprise(Boolean createAnother) {                    
        PageReference ref;       
        
        if (errorMsg != null) {
            if (errorMsg.contains('seats')) {
                tenant.Seats_Allocated__c.addError(errorMsg);
            } else {
                tenant.addError(errorMsg);
            }
            return null;
        }
        
        // We'll use this if we have any errors
        Tenant__c tenantCopy = tenant.clone();        
        try {
            if (tenant != null && tenant.Id != null) {
                // First get tenant data
                String q = Box_TenantDAO.getQuery();
                q += ' WHERE Id = \'' + tenant.Id + '\'';            
                tenant = (Tenant__c)Database.query(q);
                
                // Now sync the data
                Box_SyncingEnterprise b = new Box_SyncingEnterprise(tenant); 
                
                /* 03/03/14 - Call the appropriate create method based on isATTPartner value */
                // b.create( isATTPartner );  
                
                if(isATTPartner){
                	b.create(isATTPartner);	
                }else{
                	b.create();
                }          
                
                // Associate tenant to opportunity
                if (opportunityId != null && !opportunityId.equals('')) {
                    Opportunity o = new Opportunity(Id = opportunityId);
                    o.Tenant__c   = tenant.Id;
                    update o;
                }
    
                // Go to newly created Tenant page
                if (createAnother == null || !createAnother && (redirect == null || redirect)) {
                    ref = new PageReference('/' + tenant.Id);
                // Go to new Tenant creator
                } else {
                    // Generate new Tenant
                    tenant = new Tenant__c();
                    prepopulateFields();
                    showSuccess = true;
                    ref = page.Box_TenantCreator;
                }
            } else {
                // throw new CustomException('Yo');
            }
        } catch (Box_CalloutException bce) {
            // We had to insert the tenant first to properly query the admin data. We delete the tenant if there are errors
            if (tenant != null && tenant.Id != null) {
                System.debug('(Controller) Box_CalloutException thrown. Deleting tenant...');            
                delete tenant;
            }
            tenant = tenantCopy;
            showSuccess = false;            
            // This displays the error on the page
            tenant.addError(bce.getHttpResponseError().context_info.errors[0].message);        
        } catch (Exception e) {
            // We had to insert the tenant first to properly query the admin data. We delete the tenant if there are errors
            if (tenant != null && tenant.Id != null) {
                System.debug('(Controller) Exception thrown. Deleting tenant...');            
                delete tenant;
            }
            tenant = tenantCopy;
            showSuccess = false;            
            // This displays the error on the page
            tenant.addError(e.getMessage());
        }
        return ref;
    }
    
    public PageReference previous() {
        return Page.TrialsAndProvisioning;
    }

}