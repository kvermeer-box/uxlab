/**
 * Controls syncing of tenants with Box.
 *
 * @author David Liu
 * @revision 1.1 Kyle Vermeer 4/8/14 Use Oauth2
 */

global class Box_SyncingEnterprise extends Box_SyncingObject {

    // V2 API Modifications
    private static final PRM_Settings__c settings = PRM_Settings__c.getInstance('default');
    private static final Boolean useOAuth = (settings != null) ? settings.Use_OAuth__c : false;

    private static final String ATT_RESELLER_ID = '553';

    private final String API_NAME = '/internal_enterprises';

    // Objects in sync
    public Box_Enterprise enterprise;
    public Tenant__c tenant;
    
    // Original object copies, for rollback purposes
    private Tenant__c originalTenant;
     
    // Optional
    public Box_SalesTransaction salesTransaction;     
         
    public Box_SyncingEnterprise(sObject o) {
        super(o); 
    } 
    
    public Box_SyncingEnterprise(Object o) {
        super(o);
    }
     
    public void setSObject(sObject o) {
        this.tenant = (Tenant__c)o;
        this.originalTenant = (Tenant__c)o;
    }
    
    public void setObject(Object o) {
        this.salesTransaction = (Box_SalesTransaction)o;
        this.enterprise = salesTransaction.enterprise;
    }
    
    @future (callout = true)
    public static void futureCreate(String id) {
        System.debug('Creating an enterprise via future method...');
        ContextControl.isFuture = true;
        Box_SyncingEnterprise.createFromId(id);
    } 
    
    @future (callout = true)
    public static void futureEdit(String id) {
        System.debug('Updating an enterprise via future method...');
        ContextControl.isFuture = true;
        Box_SyncingEnterprise.editFromId(id);
    } 
 
    
    /* 12/27/13 Call another create method if AT&T Reseller */
    webservice static String createFromId(String id) {
        System.debug('Creating an enterprise from tenant id...');       
        ContextControl.preventLooping = true;
        String returnMessage;
        try {   
            Tenant__c t = Box_TenantDAO.getTenantFromKey('id', id);
            Box_SyncingEnterprise b = new Box_SyncingEnterprise(t);
            if( isATT(t) ){
                b.tenant = (Tenant__c)b.create( true );
            }else{  
                b.tenant = (Tenant__c)b.create();
            }   
            returnMessage = 'Enterprise successfully created in Box. Page will now refresh...';
        } catch (Exception e) {
            returnMessage = e.getMessage();
        }
        return returnMessage;
    }
     
    webservice static String readFromId(String id) {
        System.debug('Reading an enterprise from tenant id...');
        ContextControl.preventLooping = true;
        
        String returnMessage;
        try {
            Tenant__c t = Box_TenantDAO.getTenantFromKey('id', id);         
            Box_SyncingEnterprise b = new Box_SyncingEnterprise(t);
            if( isATT(t) ){
                b.tenant = (Tenant__c)b.read( true );
            }else{      
                b.tenant = (Tenant__c)b.read();
            }           
            returnMessage = 'Enterprise data successfully saved to Box. Page will now refresh...';
        } catch (Exception e) {
            returnMessage = e.getMessage();
        }
        return returnMessage;
    }   

    /**
     * Written by KV to stop the nightly sync errors
     *
     * Advised by Richard Wu
     *
     * @param {Tenant} t - tenant to update
     * @return {String} - message?
     */
    webservice static String readFromTenant(Tenant__c t) {
        System.debug('Syncing tenant from Box...');
        ContextControl.preventLooping = true;

        String returnMessage;
        try {      
            Box_SyncingEnterprise b = new Box_SyncingEnterprise(t);
            if( isATT(t) ){
                b.tenant = (Tenant__c)b.read( true );
            }else{      
                b.tenant = (Tenant__c)b.read();
            }           
            returnMessage = 'Enterprise data successfully saved to Box. Page will now refresh...';
        } catch (Exception e) {
            returnMessage = e.getMessage();
        }
        return returnMessage;
    }

    /* 12/27/13 Call another edit method if AT&T Reseller */
    webservice static String editFromId(String id) {
        System.debug('Editing an enterprise from tenant id...');
        ContextControl.preventLooping = true;
        String returnMessage;
        try {
            Tenant__c t = Box_TenantDAO.getTenantFromKey('id', id);
            Box_SyncingEnterprise b = new Box_SyncingEnterprise(t); 
            if( isATT(t) ){
                b.tenant = (Tenant__c)b.edit( true );
            }else{      
                b.tenant = (Tenant__c)b.edit();
            }   
            returnMessage = 'Enterprise data successfully saved to Box. Page will now refresh...';
        } catch (Exception e) {
            returnMessage = e.getMessage();
        }
        return returnMessage;
    }   
 
 
    static boolean isATT(Tenant__c t) {
    
        boolean isATT = false;
    
        try{
            
            isATT = String.valueOf( t.Opportunities__r[0].Box_Partner_Account__r.Reseller_ID__c ) == '3980955827';

        }catch (Exception e){
            isATT=false;
            DebugLogger.write('Box_SyncingEnterprise', 'isATT.e = ' + e);  
        }
        
        return isATT;
    } 
 
    /**
     * Creates enterprise in Box.
     *
     * @return {sObject} - tenant provisioned
     * @author David Liu
     */
    public sObject create() {
        System.debug('Creating the enterprise...');
        sendAndReceive(API_NAME, 'POST');   
        return tenant; 
    }
    
    /**
     * Create enterprise in Box, for ATT.
     *
     * @param {Boolean} isATTPartner - true if ATT, false otherwise
     * @return {sObject} - tenant provisioned
     * @author David Liu
     */
    public sObject create( Boolean isATTPartner) {
        System.debug('Creating the enterprise...');
        sendAndReceive(API_NAME, 'POST', isATTPartner );   
        return tenant;
    }
    
    /**
     * Read a tenant from Box
     *
     * @return {sObject} - tenant grabbed from Box
     * @author David Liu
     */
    public sObject read() {
        System.debug('Reading the enterprise...');
        sendAndReceive(API_NAME + '/' + getEnterpriseId(tenant, enterprise), 'GET');    
        return tenant;
    }
    
    /**
     * Read a tenant from Box, provisioned by ATT
     *
     * @param {Boolean} isATTPartner - True if ATT, False otherwise
     * @return {sObject} - tenant grabbed from Box
     * @author David Liu
     */
    public sObject read( Boolean isATTPartner ) {
        System.debug('Reading the enterprise...');
        sendAndReceive(API_NAME + '/' + getEnterpriseId(tenant, enterprise), 'GET', isATTPartner ); 
        return tenant;
    }
    
    /**
     * Edit a tenant from Box
     *
     * @return {sObject} - tenant grabbed from Box
     * @author David Liu
     */
    public sObject edit() {
        System.debug('Editing the enterprise...');
        sendAndReceive(API_NAME + '/' + getEnterpriseId(tenant, enterprise), 'PUT');    
        return tenant;
    }

    /**
     * Edit a tenant from Box, provisioned by ATT
     *
     * @param {Boolean} isATTPartner - True if ATT, False otherwise
     * @return {sObject} - tenant grabbed from Box
     * @author ???
     */
    public sObject edit( Boolean isATTPartner ) {
        System.debug('Editing the enterprise...');
        sendAndReceive(API_NAME + '/' + getEnterpriseId(tenant, enterprise), 'PUT', isATTPartner ); 
        return tenant;
    }
    

    
    private sObject sendAndReceive(String endpoint, String method) {
        System.debug('Sending and receiving...');
        HttpResponse response;
        try {       
            // Create JSON
            String enterpriseJson = JSON.serialize(enterprise);
            
            // Sync JSON
            Box_ObjectSyncUtil u = new Box_ObjectSyncUtil();
            if (useOauth) {
                response = u.syncToBox(enterpriseJson, endpoint, method, getResellerId(tenant));
            }
            else {
                response = u.syncToBox(enterpriseJson, endpoint, method);
            }
            
            
            // Deserialize. If error, deserialize into an error object
            Box_Enterprise b;
            try {
                b = (Box_Enterprise)JSON.deserialize(response.getBody(), Box_Enterprise.class);
            } catch (JSONException j) {
                System.debug('Error: Could not deserialize into enterprise. Deserializing into error object...');
                throw new Box_CalloutException(response);
            }
            
            // Unpack JSON
            tenant = (Tenant__c)unpack(b, method); 
                        
            // Update status
            tenant = (Tenant__c)updateSObjectSyncing((sObject)tenant, response);
        } catch (Box_CalloutException c) {
            System.debug('Error: Box has rejected the request.');
            // Rollback the tenant
            tenant = originalTenant;
            tenant = (Tenant__c)updateSObjectError((sObject)tenant, c, response);
            throw c;
        } catch (Exception e) {
            System.debug('Send and receive error. ' + e.getMessage());
            tenant = (Tenant__c)updateSObjectError((sObject)tenant, e, response);
            throw e;
        }       
        return tenant;
    } 
    
    
    private sObject sendAndReceive(String endpoint, String method, Boolean isATTPartner) {
        System.debug('Sending and receiving...');
        HttpResponse response;
        try {       
            // Create JSON
            String enterpriseJson = JSON.serialize(enterprise);
            
            // Sync JSON
            Box_ObjectSyncUtil u = new Box_ObjectSyncUtil( isATTpartner);
            if (useOauth) {
                response = u.syncToBox(enterpriseJson, endpoint, method, ATT_RESELLER_ID);
            }
            else {
                response = u.syncToBox(enterpriseJson, endpoint, method);
            }
            
            // Deserialize. If error, deserialize into an error object
            Box_Enterprise b;
            try {
                b = (Box_Enterprise)JSON.deserialize(response.getBody(), Box_Enterprise.class);
            } catch (JSONException j) {
                System.debug('Error: Could not deserialize into enterprise. Deserializing into error object...');
                throw new Box_CalloutException(response);
            }
            
            // Unpack JSON
            tenant = (Tenant__c)unpack(b, method); 
                        
            // Update status
            tenant = (Tenant__c)updateSObjectSyncing((sObject)tenant, response);
        } catch (Box_CalloutException c) {
            System.debug('Error: Box has rejected the request.');
            // Rollback the tenant
            tenant = originalTenant;
            tenant = (Tenant__c)updateSObjectError((sObject)tenant, c, response);
            throw c;
        } catch (Exception e) {
            System.debug('Send and receive error. ' + e.getMessage());
            tenant = (Tenant__c)updateSObjectError((sObject)tenant, e, response);
            throw e;
        }       
        return tenant;
    }  
    
    public sObject destroy() {
        return new Tenant__c();
    }  
    
    private sObject unpack(Object o, String method) {
        System.debug('Unpacking Box_Enterprise to tenant...'); 
         
        try {
            // Cast objects first
            enterprise = (Box_Enterprise)o;

            // Update salesTransaction
            if (salesTransaction != null) {
                salesTransaction.enterprise = enterprise;
                // Create new tenant if necessary
                if (tenant == null) { 
                    tenant = Box_TenantFactory.createTenantFromSalesTransaction(salesTransaction);
                } else {
                    // Otherwise, update related objects
                    Contact admin = tenant.Admin__r;
                    Account account = tenant.Account__r;                    
                    Box_UserFactory.translateSalesTransactionToContact(salesTransaction, admin);
                    Box_AccountFactory.translateSalesTransactionToAccount(salesTransaction, account);
                    update admin;
                    update account;
                }
            }
             
            // Update w/enterprise values
            tenant = Box_TenantFactory.translateEnterpriseToTenant(enterprise, tenant);
            
            // Update w/salesTransaction values
            if (salesTransaction != null) {
                if (salesTransaction.last_transaction_id != null) { tenant.Last_Transaction_ID__c = salesTransaction.last_transaction_id; }
            }                       
        } catch (Exception e) {         
            throw new CustomException(e.getMessage(), Box_ObjectSyncUtil.generateRecipientsList());
        }
        return tenant;
    }

    // We have to do this the hard way without reflection   
    public Object translate(sObject s) {
        System.debug('Translating tenant to Box_Enterprise...');
        
        Tenant__c t = (Tenant__c)s;
        originalTenant = t.clone(true);
        
        try {
            // Enterprise Info
            enterprise                  = new Box_Enterprise(); 
            enterprise.account_type     = String.valueOf(tenant.Account_Type__c);
            enterprise.active_status    = String.valueOf(tenant.Active_Status__c);
            enterprise.billing_cycle    = String.valueOf(tenant.Billing_Cycle__c); 
            enterprise.blocked_status   = String.valueOf(tenant.Blocked_Status__c);             
            enterprise.deal_status      = tenant.Deal_Status__c;    
            enterprise.id               = String.valueOf(tenant.Enterprise_ID_Tenant__c); 
            enterprise.hide_add_user_ui = Boolean.valueOf(tenant.Hide_Add_User_UI__c);                                                                  
            enterprise.name             = String.valueOf(tenant.Name);
            enterprise.price_per_user   = String.valueOf(tenant.Price_Per_User__c);          
            enterprise.seats            = String.valueOf(tenant.Seats_Allocated__c);
            enterprise.seats_used       = String.valueOf(tenant.Seats_Used__c);
            enterprise.is_silent_mode   = Boolean.valueOf(tenant.Silent_Mode__c);       
            enterprise.space_amount     = String.valueOf(tenant.Space_Allocated__c);
            enterprise.space_used       = String.valueOf(tenant.Space_Used__c);
            enterprise.subdomain        = String.valueOf(tenant.Subdomain__c);          
             
            // Trial end
            enterprise.trial_end_at     = String.valueOf(Box_TenantFactory.calculateTrialDate(tenant));
             
            // Admin info
            Box_User u                 = new Box_User();
            u.login                    = String.valueOf(tenant.Admin_Email_Lookup__c);
            u.name                     = String.valueOf(tenant.Admin_Name_Lookup__c);            
            u.phone_number             = String.valueOf(tenant.Admin_Phone_Number_Lookup__c);
            enterprise.administered_by = u;         
                        
        } catch (Exception e) {
            throw new CustomException('Error translating Salesforce object to Box object', Box_ObjectSyncUtil.generateRecipientsList());
        } 
        return enterprise;
    }               
    
    private String getEnterpriseId(Tenant__c t, Box_Enterprise e) {
        System.debug('Getting the enterprise id...');
        String enterpriseId;
        if (tenant != null && tenant.Enterprise_ID_Tenant__c != null && !tenant.Enterprise_ID_Tenant__c.equals('')) {
            enterpriseId = tenant.Enterprise_ID_Tenant__c;
        } else if (enterprise != null && enterprise.id != null && !enterprise.id.equals('')) {
            enterpriseId = enterprise.id;
        } else {
            throw new CustomException('Error: Enterprise ID not specified.');
        }
        System.debug('Enterprise ID: ' + enterpriseId);
        return enterpriseId;
    }

    /**
     * Gets the resellerId associated with the tenant.
     *
     * @param {Tenant__c} t - tenant for which we are grabbing the reseller
     * @return {String} - reseller id
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    private static String getResellerId(Tenant__c t) {
        if (t == null) { // check for null input
            return null;
        }
        if (t.Reseller_ID__c != null) { // If we've put the reseller id on the tenant, use that!
            return String.valueOf(t.Reseller_ID__c);
        }
        try {
            List<Opportunity> opportunitiesForTenant = [SELECT Id, Box_Partner_Account__r.Reseller_ID__c
                                                          FROM Opportunity
                                                         WHERE Tenant__c = :t.Id
                                                      ORDER BY CreatedDate DESC];
            if (opportunitiesForTenant.isEmpty()) {
                System.debug('No opportunities for this tenant.');
                return null;
            }
            else {
                Opportunity mostRecentOpp = opportunitiesForTenant[0];
                if (mostRecentOpp.Box_Partner_Account__r.Reseller_ID__c == null) {
                    System.debug('No Reseller Id on Box Partner Account for Opp: ' + mostRecentOpp);
                    return null;
                }
                else {
                    return String.valueOf(mostRecentOpp.Box_Partner_Account__r.Reseller_ID__c);
                }
            }
        }
        catch (Exception e) {
            System.debug('Issue finding resellerId for tenant. Exception: ' + e);
            return null;
        }
    }

}