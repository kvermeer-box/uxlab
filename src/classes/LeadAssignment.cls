global class LeadAssignment { 
    
    // Generic settings
    public static LeadAssignmentSettings__c settings = LeadAssignmentSettings__c.getInstance('default');        
    public static final String ROUTING_AUTO_ASSIGN_OWNER_IDS = (settings == null) ? '005600000018aQl;00560000001HWN1;00560000001HN53;00560000001uPgI;00560000001IQCx;' : settings.Routing_Auto_Assign_Owner_Ids__c;
    public static final Boolean FCCRM_AUTO_ASSIGNMENT_RULES  = (settings == null) ? true : settings.FCCRM_Auto_assignment_Rules__c; 
    public static final Boolean EMERGENCY_SHUTOFF            = (settings == null) ? false : settings.Emergency_Shutoff_Button_for_Auto_Assign__c;
    public static final String DEFAULT_LEAD_CONVERTED_STATUS = (settings == null) ? 'Qualified - New Opportunity' : settings.Default_Lead_Converted_Status__c;  
     
    // Limiting settings
    public static final Decimal LIMITS_MAX_ROUTED_LEADS_AUDIT_DAYS = (settings == null) ? 30 : settings.Limits_Max_Routed_Leads_Audit_Days__c;
    
    // Type settings
    public static final String TYPE_WEB_TRIAL_CM_GROUPING_VALUES = (settings == null) ? 'Web Trial;' : settings.Type_Web_Trial_CMMR_Values__c;
    public static final String TYPE_FREEMIUM_CM_GROUPING_VALUES  = (settings == null) ? 'Freemium;' : settings.Type_Freemium_CMMR_Values__c;
    
    // Segment settings 
    public static final String  SEGMENT_BD_PARTER_PROGRAM_VALUES    = (settings == null) ? 'Consulting;General Inquiry;Alliance;' : settings.Segment_BD_Partner_Program_Values__c;
    public static final String  SEGMENT_BD_SOURCE_DETAIL_VALUES     = (settings == null) ? 'Referral Partner;' : settings.Segment_BD_Source_Detail_Values__c;
    public static final String  SEGMENT_OBR_MAJOR_CMMR_VALUES       = (settings == null) ? 'LeadGen for Major' : settings.Segment_OBR_Major_CMMR_Values__c;
    public static final String  SEGMENT_OBR_ENTERPRISE_CMMR_VALUES  = (settings == null) ? 'LeadGen for Enterprise' : settings.Segment_OBR_Enterprise_CMMR_Values__c;
    public static final String  SEGMENT_TEST_EMAIL_VALUES           = (settings == null) ? 'test@;@box.com;@box.net;boxinternalqa;boxstresslive;boxautomatedqa;' : settings.Segment_Test_Email_Values__c;   
    public static final String  SEGMENT_INTERNATIONAL_COUNTRY_CODES = (settings == null) ? 'GB;FR;DE;IT;ES;EU;' : settings.Segment_International_Country_Codes__c;
    public static final String  WEB_TRIAL                           = 'Web Trial';
    public static final String  FREEMIUM                            = 'Freemium';
    public static final String  INBOUND                             = 'Inbound';
    public static Decimal SEGMENT_CORPORATE_MAX_EMPLOYEES           = (settings == null) ? 500 : settings.Segment_Corporate_Max_Employees__c;
    public static Decimal SEGMENT_MAJORS_MAX_EMPLOYEES              = (settings == null) ? 5000 : settings.Segment_Majors_Max_Employees__c;
    
    // Tier settings
    public static final Decimal TIER_C1_MAX_USERS = (settings == null) ? 5 : settings.Tier_C1_Max_Users__c;
    public static final Decimal TIER_C2_MAX_USERS = (settings == null) ? 25 : settings.Tier_C2_Max_Users__c; 
    public static final Decimal TIER_C3_MAX_USERS = (settings == null) ? 75 : settings.Tier_C3_Max_Users__c; 
    public static final Decimal TIER_C4_MAX_USERS = (settings == null) ? 300 : settings.Tier_C4_Max_Users__c; 
    public static final Decimal TIER_M1_MAX_USERS = (settings == null) ? 25 : settings.Tier_M1_Max_Users__c;  
    public static final Decimal TIER_M2_MAX_USERS = (settings == null) ? 100 : settings.Tier_M2_Max_Users__c;
    public static final Decimal TIER_CORP_MIN_EMPLOYEES_BOOST = (settings == null) ? 100 : settings.Tier_Corp_Min_Employees_Boost__c;  
    public static final String  TIER_CORP_JOB_TITLE_WILDCARDS = (settings == null) ? 'CEO;CFO;CTO;CIO;COO;CMO;CSO;IT,Dir;Chief,Officer;' : settings.Tier_Corp_Job_Title_Boost_Wildcards__c;     
    
    // Routing settings
    public static final String ROUTING_INTERNAL_QA_USER_ID            = (settings == null) ? '005600000018aQl' : settings.Routing_Internal_QA_User_Id__c;
    public static final String ROUTING_BUSINESS_DEVELOPMENT_USER_ID   = (settings == null) ? '00560000001H6hF' : settings.Routing_Business_Development_User_Id__c;
    public static final String ROUTING_INTERNATIONAL_USER_ID          = (settings == null) ? '00560000001Huf4' : settings.Routing_International_User_Id__c;
    public static final String ROUTING_OBR_MAJOR_ROLE_IDENTIFIER      = (settings == null) ? 'Outbound Business Rep - Major' : settings.Routing_OBR_Major_Role_Identifier__c;
    public static final String ROUTING_OBR_ENTERPRISE_ROLE_IDENTIFIER = (settings == null) ? 'Outbound Business Rep - Enterprise' : settings.Routing_OBR_Ent_Role_Identifier__c;
    public static final String ROUTING_CORPORATE_ROLE_IDENTIFIER      = (settings == null) ? 'Account Executive - Corporate' : settings.Routing_Corporate_Role_Identifier__c;
    public static final String ROUTING_MAJOR_ROLE_IDENTIFIER          = (settings == null) ? 'Account Executive - Major' : settings.Routing_Major_Role_Identifier__c;
    public static final String ROUTING_ENTERPRISE_DEFAULT_USER_ID     = (settings == null) ? '00560000001HN53' : settings.Routing_Enterprise_Default_User_Id__c;
    public static final String ROUTING_SALES_OPS_DEFAULT_USER_ID      = (settings == null) ? '00560000001HN53' : settings.Routing_Sales_Ops_Default_User_Id__c;
    public static final String ROUTING_SDR_ROLE_IDENTIFIER            = (settings == null) ? 'Sales Development Rep' : settings.Routing_SDR_Role_Identifier__c;
    public static final String OBR_MAJOR_ROLE_WILDCARD                = '\'%' + ROUTING_OBR_MAJOR_ROLE_IDENTIFIER + '%\'';
    public static final String OBR_ENTERPRISE_ROLE_WILDCARD           = '\'%' + ROUTING_OBR_ENTERPRISE_ROLE_IDENTIFIER + '%\'';
    public static final String CORPORATE_ROLE_WILDCARD                = '\'%' + ROUTING_CORPORATE_ROLE_IDENTIFIER + '%\'';
    public static final String MAJOR_ROLE_WILDCARD                    = '\'%' + ROUTING_MAJOR_ROLE_IDENTIFIER + '%\'';
    public static final String SDR_ROLE_WILDCARD                      = '\'%' + ROUTING_SDR_ROLE_IDENTIFIER + '%\'';    

    // Ramping settings
    public static final String RAMPING_CORPORATE_WEB_TRIAL_BUCKETS = (settings == null) ? '0/24;182/64;274/12;' : settings.Ramping_Corporate_Web_Trial_Buckets__c;
    public static final String RAMPING_CORPORATE_FREEMIUM_BUCKETS  = (settings == null) ? '0/69;182/31;274/0;' : settings.Ramping_Corporate_Freemium_Buckets__c;
    public static final String RAMPING_CORPORATE_INBOUND_BUCKETS   = (settings == null) ? '0/3;182/25;274/72;' : settings.Ramping_Corporate_Inbound_Buckets__c;
    public static final String RAMPING_MAJOR_WEB_TRIAL_BUCKETS     = (settings == null) ? null : settings.Ramping_Major_Web_Trial_Buckets__c;
    public static final String RAMPING_MAJOR_FREEMIUM_BUCKETS      = (settings == null) ? null : settings.Ramping_Major_Freemium_Buckets__c;
    public static final String RAMPING_MAJOR_INBOUND_BUCKETS       = (settings == null) ? null : settings.Ramping_Major_Inbound_Buckets__c;
    
    // Email settings
    public static final String AUTO_ASSIGN_EMAIL_TEMPLATE_ID = (settings == null) ? '00X60000000wM3X' : settings.Email_Assignment_Rules_Template_Id__c;
    
    // Permissions settings
    public static final String ACCESS_PROFILE_IDS = (settings == null) ? '00e60000000in6T;00e60000000ilfb;00e60000000nlAt;00e60000000idKG;00e60000000imTb;00e60000000idJS;00e60000000inBY;00e60000000inKk;00e60000000inDy' : settings.Access_Profile_Ids__c;
    public static final String ACCESS_ROLE_IDS    = (settings == null) ? null : settings.Access_Role_Ids__c;
    public static final String ACCESS_USER_IDS    = (settings == null) ? null : settings.Access_User_Ids__c;
    
    // Permissions
    public static Boolean allowAccess;
    public static Boolean routedUsingApex;
    public static Boolean bucketRatiosCalculated = false;
    
    // General objects
    public static Lead lead;
    public static User routeByUser;
    public static User routeToUser; 
    public static String routeByUserId;
    public static String routeToUserId;
    
    // Entry criteria
    public static Boolean routeUsingAssignmentRules;
    
    // Employee information
    public static Decimal employees;
    public static String  employeesFieldOutput;
    
    // Matrix criteria
    public static String leadType;  
    public static String segment;
    public static Decimal tier; 
    public static Integer tenure;

    // User lists
    public static Map<Id, User> allUsersList;
    public static List<User> allCandidatesForObrMajor;
    public static List<User> allCandidatesForObrEnterprise;
    public static List<User> allCandidatesForCorporate;
    public static List<User> allCandidatesForMajor;
    public static List<User> allCandidatesForSdr;
    
    // Routed leads lists
    public static List<Routed_Lead__c> routedLeadsListForObrMajor;
    public static List<Routed_Lead__c> routedLeadsListForObrEnterprise;
    public static List<Routed_Lead__c> routedLeadsListForCorporateWebTrial;
    public static List<Routed_Lead__c> routedLeadsListForCorporateFreemium;
    public static List<Routed_Lead__c> routedLeadsListForCorporateInbound;
    public static List<Routed_Lead__c> routedLeadsListForMajorWebTrial;
    public static List<Routed_Lead__c> routedLeadsListForMajorFreemium;
    public static List<Routed_Lead__c> routedLeadsListForMajorInbound;
    public static List<Routed_Lead__c> routedLeadsListForSdrWebTrial;
    public static List<Routed_Lead__c> routedLeadsListForSdrFreemium;
    public static List<Routed_Lead__c> routedLeadsListForSdrInbound;    
    
    // Routed leads Maps
    public static Map<User, RoutedLeadSummary> maxRoutedLeadsMapForObrMajor;
    public static Map<User, RoutedLeadSummary> maxRoutedLeadsMapForObrEnterprise;
    public static Map<User, RoutedLeadSummary> maxRoutedLeadsMapForCorporateWebTrial;
    public static Map<User, RoutedLeadSummary> maxRoutedLeadsMapForCorporateFreemium;
    public static Map<User, RoutedLeadSummary> maxRoutedLeadsMapForCorporateInbound;
    public static Map<User, RoutedLeadSummary> maxRoutedLeadsMapForMajorWebTrial;
    public static Map<User, RoutedLeadSummary> maxRoutedLeadsMapForMajorFreemium;
    public static Map<User, RoutedLeadSummary> maxRoutedLeadsMapForMajorInbound;
    public static Map<User, RoutedLeadSummary> maxRoutedLeadsMapForSdrWebTrial;
    public static Map<User, RoutedLeadSummary> maxRoutedLeadsMapForSdrFreemium;
    public static Map<User, RoutedLeadSummary> maxRoutedLeadsMapForSdrInbound;  

    // Ramping buckets
    public static Integer minBoundTenure;
    public static Integer maxBoundTenure;
    public static Integer candidatesListSize;   
    public static Boolean allBucketsVerified;
    public static List<Bucket> rampingBuckets;
    public static List<Bucket> corporateWebTrialBuckets;
    public static List<Bucket> corporateFreemiumBuckets;
    public static List<Bucket> corporateInboundBuckets;
    public static List<Bucket> majorWebTrialBuckets;
    public static List<Bucket> majorFreemiumBuckets;
    public static List<Bucket> majorInboundBuckets; 

    // Routed Lead object references
    public static Id accountId;
    public static Id contactId;
    public static Opportunity opportunity;
    public static Opportunity upsellOpportunity;
    public static SDR_Qualification_Notes__c sdrQualNote;
    
    // Lead conversion variables
    public static Database.LeadConvertResult leadConvertResult;

    // Final variables
    public static Routed_Lead__c routedLead;
    public static String resultsUrl;
    public static Messaging.SingleEmailMessage email;
    public static Integer iteration;
    
    // Lead routing with only string inputs. Route Me! button uses this
    webservice static String routeLeadWebService(String l, String u) {
        routeUsingAssignmentRules = false;
        routedUsingApex = false;
        
        queryObjects(l, u);
            if (checkForErrors()) return resultsUrl;
            
        checkPermissions(); 
            if (checkForErrors()) return resultsUrl;    
            
        return routeLead();
    }
    
    webservice static String rerouteInQueue(String r) {
        
        // Step 0: Initialize variables
        routeUsingAssignmentRules = false;
        routedUsingApex = true;
        routeByUserId = UserInfo.getUserId();
        
        // Step 0: Initialize buckets
        initializeBuckets();
            if (checkForErrors()) return resultsUrl;        

        // Step 1: Get all the info we need to reroute
        Routed_Lead__c rl = queryRoutedLeadFields(r);
         
        // Step 2: Validate inputs
        if (rl == null) {
            return 'Error: Cannot find routed lead! Id: ' + r;
        } else if (rl.Reassign_To_Account__c != null) {
            return 'Error: You may not choose an account to reassign this routed lead to. This button will assign to the next person in line.';
        } else if (rl.Undo_Reason__c == null) {
            return 'Error: You must choose an Undo Reason!';
        } else if (rl.Undo_Reason__c.toUppercase().contains('DUP')) {
            return 'Error: Use the \'Reassign as Dupe\' button for duplicate leads';
        } else if (rl.Reassigned_Routed_Lead__c != null) {
            return 'Error: This routed lead has already been reassigned!';
        }
        
        // Step 3: Set the inputs
        segment = rl.Company_Segment__c;        
        leadType = rl.Type__c;
        tier = rl.Tier__c;  
        
        // Step 4: Choose the next person to route to. Try again if it's the same person (routedUsingApex = true)
        selectNextRoutingCandidate();
        while (routeToUser.Id == rl.Routed_To__r.Id) {
            System.debug('Same person!  Need to reroute again.');
            selectNextRoutingCandidate(); 
        }
        
        // Step 5: Set up routed lead and switch ownership of related objects
        if (rl.Lead__c != null) {
            lead = reassignRoutedLeadLead(rl, routeToUser.Id);
        }
        if (rl.Account__c != null) {
            accountId = reassignRoutedLeadAccount(rl, routeToUser.Id).Id;
        }
        if (rl.Contact__c != null) {
            contactId = reassignRoutedLeadContact(rl, routeToUser.Id, null).Id;
        }
        if (rl.Opportunity__c != null) {
            List<Opportunity> opps = reassignRoutedLeadOpps(rl, routeToUser.Id, null);
            for (Opportunity o : opps) {
                if (o.Name.toUppercase().contains('UPSELL')) {
                    upsellOpportunity = o;
                } else {
                    opportunity = o;
                }
            }
        }
        if (rl.SDR_Qualification_Notes__c != null) {
            sdrQualNote = getSdrQualNotesFromRoutedLead(rl);
        }
        
        // Step 6: Create routed lead
        createRoutedLeadObject();
        
        // Step 7: Populate reassign routed lead in original
        rl.Reassigned_Routed_Lead__c = routedLead.Id;
        update rl;
        
        return 'Success!\n\nAll related records have been rerouted to the next person in line: ' + routeToUser.Name + '.\n\nThis routed lead will not count against ' + rl.Routed_To__r.Name + '.||' + routedLead.Id;           
    }

    webservice static String reassignAsDupe(String r) {

        // Step 1: Get all the info we need to dedupe
        Routed_Lead__c rl = queryRoutedLeadFields(r);
        
        // Step 2: Validate inputs
        if (rl == null) {
            return 'Error: Cannot find routed lead! Id: ' + r;
        } else if (rl.Reassign_To_Account__c == null) {
            return 'Error: Please choose an account in the \"Reassign To Account\" field';          
        } else if (rl.Reassigned_Routed_Lead__c != null) {
            return 'Error: This routed lead was previously undone. See the \"Reassigned Routed Lead\" field for more details.';
        }
                                    
        // Step 3: Move contact to correct account
        reassignRoutedLeadContact(rl, rl.Reassign_To_Account__r.OwnerId, rl.Reassign_To_Account__r.Id);
                
        // Step 4: Move open opps to correct account
        reassignRoutedLeadOpps(rl, rl.Reassign_To_Account__r.OwnerId, rl.Reassign_To_Account__r.Id);
        
        // Step 5: Move SDR qual note
        reassignRoutedLeadSdrQualNotes(rl, rl.Reassign_To_Account__r.Id);               
                    
        // Step 6: Delete dupe account
        if (rl.Account__c != null && rl.Account__r.Id != null) {
            Account a = [SELECT Id FROM Account WHERE Id = :rl.Account__r.Id];
            delete a;
        }                   
        
        // Step 7: Update the routed lead
        rl.Undo_Reason__c = 'Duplicate Lead';
        rl.Account__c = rl.Reassign_To_Account__r.Id;
        update rl;
        
        return 'Success!\n\nAll related records have been reassigned to ' + rl.Reassign_To_Account__r.Owner.Name + '.\n\nThis routed lead will not count against ' + rl.Routed_To__r.Name + '.';                
    }
    
    public static Routed_Lead__c queryRoutedLeadFields(String r) {
        Routed_Lead__c rl = [SELECT Id, Undo_Reason__c, Reassign_To_Account__r.Id, Reassign_To_Account__r.Owner.Name, Routed_To__r.Name, Company_Segment__c, Type__c, Tier__c, Routed_To__r.Id,
                                        Contact__r.Id, Opportunity__r.Id, Upsell_Opportunity__r.Id, Account__r.Id, Account__r.OwnerId, SDR_Qualification_Notes__r.Id, Reassigned_Routed_Lead__c,
                                        Lead__c, Lead__r.Id, Account__c, Contact__c, Opportunity__c, Upsell_Opportunity__c
                                    FROM Routed_Lead__c
                                    WHERE Routed_Lead__c.Id = :r];
        return rl;
    }
    
    public static Lead reassignRoutedLeadLead(Routed_Lead__c r, String leadReassignId) {
        Lead l = getLeadFromRoutedLead(r);
        if (l != null && leadReassignId != null && !leadReassignId.equals('')) {
            l.OwnerId = leadReassignId;
            update l;
        }
        return l;
    }
    
    public static Lead getLeadFromRoutedLead(Routed_Lead__c r) {
        Lead l;
        if (r != null && r.Lead__c != null && r.Lead__r.Id != null) {
            l = [SELECT Id FROM Lead WHERE Id = :r.Lead__r.Id];
        }
        return l;
    }
    
    public static Account reassignRoutedLeadAccount(Routed_Lead__c r, String accountReassignId) {
        Account a = getAccountFromRoutedLead(r);
        if (a != null && accountReassignId != null && !accountReassignId.equals('')) {
            a.OwnerId = accountReassignId;
            update a;
        }
        return a;
    }
    
    public static Account getAccountFromRoutedLead(Routed_Lead__c r) {
        Account a;
        if (r != null && r.Account__c != null && r.Account__r.Id != null) {
            a = [SELECT Id FROM Account WHERE Id = :r.Account__r.Id];
        }
        return a;
    }
    
    
    public static Contact reassignRoutedLeadContact(Routed_Lead__c r, String contactReassignId, String accountReassignId) {
        Contact c = getContactFromRoutedLead(r);    
        if (c != null && contactReassignId != null && !contactReassignId.equals('')) {  
            c.OwnerId = contactReassignId;
            if (accountReassignId != null && !accountReassignId.equals('')) {
                c.AccountId = accountReassignId;
            }
            update c;
        }
        return c;
    }
    
    public static Contact getContactFromRoutedLead(Routed_Lead__c r) {
        Contact c;
        if (r != null && r.Contact__c != null && r.Contact__r.Id != null) {
            c = [SELECT Id FROM Contact WHERE Id = :r.Contact__r.Id];
        }
        return c;
    }

    public static List<Opportunity> reassignRoutedLeadOpps(Routed_Lead__c r, String oppReassignId, String accountReassignId)  {
        List<Opportunity> oppsToUpdate = getOppsFromRoutedLead(r);
        if (oppsToUpdate != null && oppsToUpdate.size() > 0) {
            for (Opportunity o : oppsToUpdate) {
                o.OwnerId = oppReassignId;              
                if (accountReassignId != null && !accountReassignId.equals('')) {
                    o.AccountId = accountReassignId;
                }
            }   
            update oppsToUpdate;            
        }
        return oppsToUpdate;
    }
    
    public static List<Opportunity> getOppsFromRoutedLead(Routed_Lead__c r) {
        Set<Id> oppsToQuery = new Set<Id>();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        if (r != null) {
            if (r.Opportunity__c != null && r.Opportunity__r.Id != null) {
                oppsToQuery.add(r.Opportunity__r.Id);
            }
            if (r.Upsell_Opportunity__c != null && r.Upsell_Opportunity__r.Id != null) {
                oppsToQuery.add(r.Upsell_Opportunity__r.Id);
            }
            if (oppsToQuery != null && oppsToQuery.size() > 0) {
                oppsToUpdate = [SELECT Id, Name FROM Opportunity WHERE Id IN :oppsToQuery];
            }
        }
        return oppsToUpdate;
    }   

    public static SDR_Qualification_Notes__c reassignRoutedLeadSdrQualNotes(Routed_Lead__c r, String accountReassignId) {
        SDR_Qualification_Notes__c s = new SDR_Qualification_Notes__c();
        if (r.SDR_Qualification_Notes__c != null && r.SDR_Qualification_Notes__r.Id != null) {
            s = getSdrQualNotesFromRoutedLead(r);
            s.Account__c = accountReassignId;
            update s;           
        }           
        return s;   
    }
    
    public static SDR_Qualification_Notes__c getSdrQualNotesFromRoutedLead(Routed_Lead__c r) {
        SDR_Qualification_Notes__c s = new SDR_Qualification_Notes__c();
        if (r.SDR_Qualification_Notes__r != null && r.SDR_Qualification_Notes__r.Id != null) {
            s = [SELECT Id, Name FROM SDR_Qualification_notes__c WHERE Id = :r.SDR_Qualification_Notes__r.Id];
        }
        return s;
    }

    // Lead routing with object inputs.  Auto-assignment.
    public static Lead routeLeadApex(Lead l, String u) {    
        if (iteration == null || iteration == 0) {          
            iteration = 1;          
        } else {
            iteration++;
        }
        System.debug('Iteration: ' + iteration);
        System.debug('Cumulative script statements: ' + Limits.getScriptStatements());
        System.debug('Cumulative query rows: ' + Limits.getQueryRows());
            
        clearVariables();
                
        lead = l;
        routeByUserId = u;
        routedUsingApex = true;

        determineHowToRouteLead();
            if (checkForErrors()) return null;          
            
        routeLead();
        
        return lead;
    }
        
    public static void clearVariables() {
        lead = null;
        routeByUser = null;
        routeToUser = null;
        routeByUserId = null;
        routeToUserId = null;
                        
        routeUsingAssignmentRules = null;
        routedUsingApex = false;
    
        employees = null;
        
        leadType = null;
        segment = null;
        tier = null;
        tenure = null;
    
        minBoundTenure = null;
        maxBoundTenure = null;
        candidatesListSize = null;
        rampingBuckets = null;

        routedLead = null;
        email = null;
    }
    
    // This is where all the magic happens  
    public static String routeLead() {      
        
        initializeBuckets();
            if (checkForErrors()) return resultsUrl;
                                
        assignEmployees();
            if (checkForErrors()) return resultsUrl;
                                
        assignLeadType();
            if (checkForErrors()) return resultsUrl;
                                        
        assignLeadSegment();
            if (checkForErrors()) return resultsUrl;
                                
        assignLeadTier();
            if (checkForErrors()) return resultsUrl;
                                
        selectNextRoutingCandidate();
            if (checkForErrors()) return resultsUrl;
                                
        passTheLead();
            if (checkForErrors()) return resultsUrl;
                    
        createRoutedLeadObject();
            if (checkForErrors()) return resultsUrl;    
                        
        generateReturnUrl();            
            if (checkForErrors()) return resultsUrl;
                    
        return resultsUrl;
    }
    
    public static void checkPermissions() {
        System.debug('Checking permissions for Route Me! v2 button...');
        allowAccess = false;
        
        // Always let assignment rules in
        if (routeUsingAssignmentRules) {
            System.debug('Access allowed - assignment rules.');
            allowAccess = true;     
            return; 
        }
        
        List<String> allowedProfileIds = new List<String>();
        List<String> allowedRoleIds = new List<String>();
        List<String> allowedUserIds = new List<String>();       
        // First check profile access       
        if (ACCESS_PROFILE_IDS != null && !ACCESS_PROFILE_IDS.equals('')) {
            allowedProfileIds = ACCESS_PROFILE_IDS.split(';');
            for (String s : allowedProfileIds) {
                if (routeByUser.ProfileId == s) {
                    System.debug('User allowed access through profile id.');
                    allowAccess = true;
                    return;
                }
            }           
        }
        
        // Check role access
        if (ACCESS_ROLE_IDS != null && !ACCESS_ROLE_IDS.equals('')) {
            allowedRoleIds = ACCESS_ROLE_IDS.split(';');
            for (String s : allowedRoleIds) {
                if (routeByUser.UserRoleId == s) {
                    System.debug('User allowed access through role id.');
                    allowAccess = true;
                    return;
                }
            }           
        }
        
        // Check user access
        if (ACCESS_USER_IDS != null && !ACCESS_USER_IDS.equals('')) {
            allowedUserIds = ACCESS_USER_IDS.split(';');
            for (String s : allowedUserIds) {
                if (routeByUser.Id == s) {
                    System.debug('User allowed access through user id.');
                    allowAccess = true;
                    return;
                }
            }                       
        }
                
        if (!allowAccess) {
            resultsUrl = 'Error: You do not have permission to use Route Me! button v2.';
        }
    }
    
    public static Boolean checkForErrors() {
        Boolean error = false;
        if (resultsUrl != null && resultsUrl.toUpperCase().startsWith('ERROR')) {
            error = true;
            System.debug('There is an error! ' + resultsUrl);
        }
        return error;
    }
    
    public static void queryObjects(String l, String u) {
        System.debug('Querying objects...'); 
        lead = [SELECT Id, NumberOfEmployees, Employees__c, Contact_Method__c, Email, Partner_program_type__c, Source_Detail__c,
                            Upsell_Opportunity__c, Purchase_Time_Frame__c, Title, Business_Web_Trial__c,
                            Do_Not_Assign__c, CreatedById, OwnerId, Contact_Method_Original__c, Company,
                            About_the_Company__c, Business_Objective__c, Competition__c, Decision_Makers__c,
                            How_They_Found_Box__c, Next_Steps__c, Pain__c, Number_of_Users__c, CleanCM__c,
                            Scope_of_Deployment__c, Number_of_Upsell_Users__c, Name, Eloqua_Country_Code__c,
                            Budget__c
                        FROM Lead WHERE Id = :l]; 
                         
        routeByUser = [SELECT Id, Name, Email, ProfileId, UserRoleId FROM User WHERE Id = :u];      
        
        if (lead == null || routeByUser == null) {
            resultsUrl = 'Error determining lead or routing user.';
        }
    }
    
    // Use assignment rules if lead is created by and owned by ROUTING_AUTO_ASSIGN_OWNER_IDS
    public static void determineHowToRouteLead() {
        System.debug('Determining how lead will be routed...');
        routeUsingAssignmentRules = false;          
        
        // Never assign with assignment rules if this box is checked!
        if (lead.Do_Not_Assign__c != null && lead.Do_Not_Assign__c && !FCCRM_AUTO_ASSIGNMENT_RULES) {
            routeUsingAssignmentRules = false;
            System.debug('Assign with assignment rules: ' + routeUsingAssignmentRules + '. \"Do Not Assign\" box is checked.');
            resultsUrl = 'Error: Do Not Assign box is checked. Killing script...';      
            return;
        }
        
        // Get a list of lead owners who will trigger auto assignment rules
        List<String> autoAssignOwnersList = new List<String>();
        if (ROUTING_AUTO_ASSIGN_OWNER_IDS != null && !ROUTING_AUTO_ASSIGN_OWNER_IDS.equals('')) {
            autoAssignOwnersList = ROUTING_AUTO_ASSIGN_OWNER_IDS.split(';');
        }
        for (String s : autoAssignOwnersList) {
            if (lead.OwnerId == null || lead.OwnerId == s) {
                routeUsingAssignmentRules = true;
                System.debug('Assign with assignment rules: ' + routeUsingAssignmentRules);
                return;
            }
        }       
        
        // Triggers are always assignment rules
        if (Trigger.isExecuting && FCCRM_AUTO_ASSIGNMENT_RULES) {
            routeUsingAssignmentRules = true;
            System.debug('Assign with assignment rules (trigger): ' + routeUsingAssignmentRules);
            return;
        }
        
        if (routedUsingApex && !routeUsingAssignmentRules && !FCCRM_AUTO_ASSIGNMENT_RULES) {
            System.debug('Lead already has an owner. Moving on to next lead...');
            resultsUrl = 'Error: Lead already has an owner. Do not assign with assignment rules or route me.';
            return;
        }
    }
    
    // Calculate all the buckets in the beginning
    public static void initializeBuckets() {
        if (allBucketsVerified == null || !allBucketsVerified) {
            // Corporate
            corporateWebTrialBuckets = calculateBucketRatios(RAMPING_CORPORATE_WEB_TRIAL_BUCKETS);
            corporateFreemiumBuckets = calculateBucketRatios(RAMPING_CORPORATE_FREEMIUM_BUCKETS);
            corporateInboundBuckets  = calculateBucketRatios(RAMPING_CORPORATE_INBOUND_BUCKETS);
            
            // Major
            majorWebTrialBuckets = calculateBucketRatios(RAMPING_MAJOR_WEB_TRIAL_BUCKETS);
            majorFreemiumBuckets = calculateBucketRatios(RAMPING_MAJOR_FREEMIUM_BUCKETS);
            majorInboundBuckets  = calculateBucketRatios(RAMPING_MAJOR_INBOUND_BUCKETS);
            
            allBucketsVerified = true;  
        }
        
        // Set default bucket
        rampingBuckets = new List<Bucket>();
        rampingBuckets.add(new Bucket(0, 9999, 100));
    }
    
    public static void assignEmployees() {
        System.debug('Assigning number of employees...');
        
        // Determine which number of employees to use
        if (lead.NumberOfEmployees != null) {
            employees = lead.NumberOfEmployees;
            employeesFieldOutput = 'Hoover\'s defined';         
        } else {
            employees = lead.Employees__c;      
            employeesFieldOutput = 'User defined';  
        }       
        
        System.debug('Employees: ' + employees);
    }
    
    public static void assignLeadType() {
        System.debug('Assigning a type...');

        // Generate a list of freemium contact methods - most recent
        List<String> webTrialValuesList = new List<String>();
        if (TYPE_WEB_TRIAL_CM_GROUPING_VALUES != null && !TYPE_WEB_TRIAL_CM_GROUPING_VALUES.equals('')) {
            webTrialValuesList = TYPE_WEB_TRIAL_CM_GROUPING_VALUES.split(';');
        }
                
        // Web Trial Check for CMO
        if (lead.Contact_Method_Original__c != null) {
            if (webTrialValuesList != null) {
                for (String s : webTrialValuesList) {
                    if (lead.Contact_Method_Original__c.toUppercase().contains(s.toUppercase())) {
                        leadType = WEB_TRIAL;
                        System.debug('Type: ' + leadType);
                        return;
                    }
                }
            }
        }       
                
        // Web Trial Check for CM Grouping
        if (lead.CleanCM__c != null) {
            if (webTrialValuesList != null) {
                for (String s : webTrialValuesList) {
                    if (lead.CleanCM__c.toUppercase().contains(s.toUppercase())) {
                        leadType = WEB_TRIAL;
                        System.debug('Type: ' + leadType);
                        return;
                    }
                }
            }
        }
        
        /*          
        // Web Trial Check for CMMR
        if (lead.Contact_Method__c != null) {
            if (webTrialValuesList != null) {
                for (String s : webTrialValuesList) {
                    if (lead.Contact_Method__c.toUppercase().contains(s.toUppercase())) {
                        leadType = WEB_TRIAL;
                        System.debug('Type: ' + leadType);
                        return;
                    }
                }
            }
        }
        */      

        // Generate list of freemium contact methods - most recent      
        List<String> freemiumValuesList = new List<String>();
        if (TYPE_FREEMIUM_CM_GROUPING_VALUES != null && !TYPE_FREEMIUM_CM_GROUPING_VALUES.equals('')) {
            freemiumValuesList = TYPE_FREEMIUM_CM_GROUPING_VALUES.split(';');
        }

        // Freemium check for CM Grouping
        if (lead.CleanCM__c != null) {
            if (freemiumValuesList != null) {
                for (String s : freemiumValuesList) {
                    if (lead.CleanCM__c.toUppercase().contains(s.toUppercase())) {
                        leadType = FREEMIUM;
                        System.debug('Type: ' + leadType);
                        return;
                    }
                }
            }
        }

        /*
        // Freemium Check
        if (lead.Contact_Method__c != null) {
            if (freemiumValuesList != null) {
                for (String s : freemiumValuesList) {
                    if (lead.Contact_Method__c.toUppercase().contains(s.toUppercase())) {
                        leadType = FREEMIUM;
                        System.debug('Type: ' + leadType);
                        return;
                    }
                }
            }
        }
        */  
        
        // Generic Lead Type
        if (leadType == null) {
            leadType = INBOUND;
            System.debug('Type: ' + leadType);
        }   
        
    }
    
    public static void assignLeadSegment() {
        if (routeUsingAssignmentRules) {
            assignLeadSegmentForAssignmentRules();
        } else {
            assignLeadSegmentForRouteMeButton();
        }
    }
    
    /**
     * Assignment Rules:
     *  1. Misc - Tests, Business Development, OBR Majors and Enterprise
     *  2. Web Trials - Corporate, Major, Enterprise (Tom Post), Unknown (Choh)
     *  3. SDRs receive all else
     */
     
    public static void assignLeadSegmentForAssignmentRules() {
        System.debug('Assigning a segment for assignment rules...');
        
        // Generate list of test email values
        List<String> testEmailValuesList = new List<String>();
        if (SEGMENT_TEST_EMAIL_VALUES != null && !SEGMENT_TEST_EMAIL_VALUES.equals('')) {
            testEmailValuesList = SEGMENT_TEST_EMAIL_VALUES.split(';');
        }
        
        // Generate list of Business Development partner program values
        List<String> partnerProgramsList = new List<String>();
        if (SEGMENT_BD_PARTER_PROGRAM_VALUES != null && !SEGMENT_BD_PARTER_PROGRAM_VALUES.equals('')) {
            partnerProgramsList = SEGMENT_BD_PARTER_PROGRAM_VALUES.split(';');
        }
        
        // Generate list of Business Development source detail values
        List<String> sourceDetailsList = new List<String>();
        if (SEGMENT_BD_SOURCE_DETAIL_VALUES != null && !SEGMENT_BD_SOURCE_DETAIL_VALUES.equals('')) {
            sourceDetailsList = SEGMENT_BD_SOURCE_DETAIL_VALUES.split(';');
        }
        
        // Null safe corporate/majors employee values
        if (SEGMENT_CORPORATE_MAX_EMPLOYEES == null) {
            SEGMENT_CORPORATE_MAX_EMPLOYEES = 500;
        }
        if (SEGMENT_MAJORS_MAX_EMPLOYEES == null) {
            SEGMENT_MAJORS_MAX_EMPLOYEES = 5000;
        }
        
        // Assign
        if (lead != null) {
            
            // Check test leads first
            if (lead.Email != null && testEmailValuesList != null) {
                for (String s : testEmailValuesList) {
                    if (lead.Email.toUppercase().contains(s.toUppercase())) {
                        segment = 'Internal QA'; 
                        System.debug('Segment: ' + segment);
                        return;
                    }
                }
            }
                        
            // Check Business Development
            if (lead.Partner_program_type__c != null) {
                for (String s : partnerProgramsList) {
                    if (lead.Partner_program_type__c.toUppercase().contains(s.toUppercase())) {
                        segment = 'Business Development';
                        System.debug('Segment: ' + segment);
                        return;
                    }
                }
            } 
            if (lead.Source_Detail__c != null) {
                for (String s : sourceDetailsList) {
                    if (lead.Source_Detail__c.toUppercase().contains(s.toUppercase())) {
                        segment = 'Business Development';
                        System.debug('Segment: ' + segment);
                        return;
                    }
                }
            }
            
            if (leadType != null && leadType.equals(WEB_TRIAL)) {
                if (employees != null && employees != 0) {
                    if (employees <= SEGMENT_CORPORATE_MAX_EMPLOYEES) {
                        segment = 'Corporate';
                        System.debug('Segment: ' + segment);
                        return;
                    } else if (employees <= SEGMENT_MAJORS_MAX_EMPLOYEES) {
                        segment = 'Major';
                        System.debug('Segment: ' + segment);
                        return;
                    } else if (employees > SEGMENT_MAJORS_MAX_EMPLOYEES){
                        segment = 'Enterprise';
                        System.debug('Segment: ' + segment);
                        return;
                    } 
                } else {
                    segment = 'Sales Ops';
                    System.debug('Segment: ' + segment);
                    return;
                }               
            } else {                
                // Generate list of OBR - Major contact methods - most recent               
                List<String> obrMajorCmmrList = new List<String>();
                if (SEGMENT_OBR_MAJOR_CMMR_VALUES != null && !SEGMENT_OBR_MAJOR_CMMR_VALUES.equals('')) {
                    obrMajorCmmrList = SEGMENT_OBR_MAJOR_CMMR_VALUES.split(';'); 
                }
                        
                // Generate list of OBR - Enterprise contact methods - most recent
                List<String> obrEnterpriseCmmrList = new List<String>();
                if (SEGMENT_OBR_ENTERPRISE_CMMR_VALUES != null && !SEGMENT_OBR_ENTERPRISE_CMMR_VALUES.equals('')) {
                    obrEnterpriseCmmrList = SEGMENT_OBR_ENTERPRISE_CMMR_VALUES.split(';');
                }               
            
                // International 
                List<String> internationalCountryCodes = new List<String>();
                if (SEGMENT_INTERNATIONAL_COUNTRY_CODES != null && !SEGMENT_INTERNATIONAL_COUNTRY_CODES.equals('')) {
                    internationalCountryCodes = SEGMENT_INTERNATIONAL_COUNTRY_CODES.split(';');
                }           
            
                // Check OBR - Major
                if (lead.Contact_Method__c != null) {
                    for (String s : obrMajorCmmrList) {
                        if (lead.Contact_Method__c.toUppercase().contains(s.toUppercase())) {
                            segment = 'OBR - Major';
                            System.debug('Segment: ' + segment);
                            return;
                        }
                    }
                }
                
                // Check OBR - Enterprise
                if (lead.Contact_Method__c != null) {
                    for (String s : obrEnterpriseCmmrList) {
                        if (lead.Contact_Method__c.toUppercase().contains(s.toUppercase())) {
                            segment = 'OBR - Enterprise';
                            System.debug('Segment: ' + segment);
                            return;
                        }
                    }
                }           
                                
                // Check International  Routing_International__c
                if (lead.Eloqua_Country_Code__c != null && !lead.Eloqua_Country_Code__c.equals('')) {
                    if (ROUTING_INTERNATIONAL_USER_ID != null && !ROUTING_INTERNATIONAL_USER_ID.equals('')) {
                        if (internationalCountryCodes != null) {
                            for (String s : internationalCountryCodes) {
                                if (lead.Eloqua_Country_Code__c.toUppercase().equals(s.toUppercase())) {
                                    segment = 'International';
                                    System.debug('Segment: ' + segment);
                                    return;
                                }
                            }
                        }
                    }
                }                                                           
            }
            
            // All else goes to SDRs
            if (segment == null) {
                segment = 'SDR';
                System.debug('Segment: ' + segment);
                return;
            }           
        }
    }
    
    public static void assignLeadSegmentForRouteMeButton() {
        System.debug('Assigning a segment for Route Me! button...');
        if (employees != null) {
            if (employees <= SEGMENT_CORPORATE_MAX_EMPLOYEES) {
                segment = 'Corporate';
            } else if (employees <= SEGMENT_MAJORS_MAX_EMPLOYEES) {
                segment = 'Major';
            } else if (employees > SEGMENT_MAJORS_MAX_EMPLOYEES) {
                segment = 'Enterprise';
            }
        } else {
            resultsUrl = 'Error: User defined and Hoover\'s employees are both null.';
        }
        System.debug('Segment: ' + segment);
    }
    
    public static void assignLeadTier() {
        if (!routeUsingAssignmentRules) {
            if (segment.equals('Corporate')) {
                assignLeadTierCorporate();
            } else if (segment.equals('Major')) {
                assignLeadTierMajor();
            } else {
                resultsUrl = 'Error: Enterprise leads cannot be routed using this button... yet!';
            }
        }
    }
    
    public static void assignLeadTierCorporate() {
        System.debug('Assigning tier for corporate...');
        
        // Choose initial tier
        if (leadType.equals(WEB_TRIAL)) {
            if (employees == null) {
                employees = 10;
                employeesFieldOutput = 'Default';
            }
            tier = 0;
        } else if (lead.Number_of_Users__c == null || lead.Number_of_Users__c <= TIER_C1_MAX_USERS) {           
            tier = 1;
        } else if (lead.Number_of_Users__c <= TIER_C2_MAX_USERS) {
            tier = 2;
        } else if (lead.Number_of_Users__c <= TIER_C3_MAX_USERS) {
            tier = 3;
        } else if (lead.Number_of_Users__c <= TIER_C4_MAX_USERS) {
            tier = 4;
        } else {
            tier = 5;
        }       
        System.debug('Preliminary tier: ' + tier);      
        assignCorporateTierUpgrades();
        System.debug('Final tier: ' + tier);
    }
    
    public static void assignCorporateTierUpgrades() {
        // Check for tier upgrades      
        if (!leadType.equals(WEB_TRIAL) && lead.Upsell_Opportunity__c) {
            System.debug('Checking for tier upgrades...');
            Boolean passedTimeFrame = false;
            Boolean passedEmployees = false;
            Boolean passedWildcards = false;                                
            
            // Purchase time criteria
            if (lead.Purchase_Time_Frame__c != null && lead.Purchase_Time_Frame__c.equals('< 1 month')) {
                passedTimeFrame = true;
            } 
            
            // Number of employees criteria
            if (employees >= TIER_CORP_MIN_EMPLOYEES_BOOST) {
                passedEmployees = true;
            }
            
            // Job title criteria
            if (lead.Title != null && !lead.Title.equals('')) {
                if (TIER_CORP_JOB_TITLE_WILDCARDS != null && !TIER_CORP_JOB_TITLE_WILDCARDS.equals('')) {
                    List<String> wildcardGroup = TIER_CORP_JOB_TITLE_WILDCARDS.split(';');
                    for (String wildcards : wildcardGroup) {
                        List<String> miniWildcards = wildcards.split(',');
                        Boolean hasAllWildcards = true;
                        for (String w : miniWildcards) {
                            if (!lead.Title.toUpperCase().contains(w.toUpperCase())) {
                                hasAllWildcards = false;
                                break;
                            }
                        }
                        if (hasAllWildcards == true) {
                            passedWildcards = true;
                            break;
                        }
                    }
                }           
            }
            
            // Upgrade queue criteria
            if (passedEmployees && tier != 5) {                 
                tier++;
                System.debug('Employees boost!');
                if (passedTimeFrame && passedWildcards && tier != 5) {
                    tier++;
                    System.debug('Time frame, employees, and wildcards boost!');
                }
            }               
        }
    }
    
    public static void assignLeadTierMajor() {
        System.debug('Assigning tier for major...');
        if (leadType.equals(WEB_TRIAL)) {
            tier = 0;
        } else if (lead.Number_of_Users__c == null || lead.Number_of_Users__c <= TIER_M1_MAX_USERS) {
            tier = 1;
        } else if (lead.Number_of_Users__c <= TIER_M2_MAX_USERS) {
            tier = 2;
        } else {
            tier = 3;
        }   
        System.debug('Final tier: ' + tier);
    }
        
    public static void selectNextRoutingCandidate() {
                
        // Generate role lists
        generateAllCandidatesListsByRole();
                
        // Generate max routed leads lists.  Calculate on the fly if Route Me! button for more accuracy.
        if (routedUsingApex) {
            System.debug('LeadAssignment cumulative query count A: ' + Limits.getQueryRows());
            generateRollingRoutedLeadsListsByChannel();
            System.debug('LeadAssignment cumulative query count B: ' + Limits.getQueryRows());          
            generateMaxRoutedLeadsListsByChannel();
            System.debug('LeadAssignment cumulative query count C: ' + Limits.getQueryRows());
        }        
        
        // Choose next user without passing
        if (segment != null && !segment.equals('')) {                       
            if (segment.equals('Internal QA')) {
                routeToUserId = ROUTING_INTERNAL_QA_USER_ID; 
            } else if (segment.equals('Business Development')) {
                routeToUserId = ROUTING_BUSINESS_DEVELOPMENT_USER_ID;
            // OBR Major
            } else if (segment.equals('International')) {
                routeToUserId = ROUTING_INTERNATIONAL_USER_ID;  
            } else if (segment.equals('OBR - Major')) {
                if (routedUsingApex) {
                    getBestCandidateInSegmentAndUpdateMapping(maxRoutedLeadsMapForObrMajor, routedLeadsListForObrMajor);
                } else {
                    getBestCandidateInChannel(allCandidatesForObrMajor, OBR_MAJOR_ROLE_WILDCARD);
                }
            // OBR Enterprise   
            } else if (segment.equals('OBR - Enterprise')) {
                if (routedUsingApex) {
                    getBestCandidateInSegmentAndUpdateMapping(maxRoutedLeadsMapForObrEnterprise, routedLeadsListForObrEnterprise);
                } else {
                    getBestCandidateInChannel(allCandidatesForObrEnterprise, OBR_ENTERPRISE_ROLE_WILDCARD);
                }
            // Corporate
            } else if (segment.equals('Corporate')) {
                if (leadType.equals(WEB_TRIAL)) {
                    rampingBuckets = corporateWebTrialBuckets.clone();
                    if (routedUsingApex) { 
                        getBestCandidateInSegmentAndUpdateMapping(maxRoutedLeadsMapForCorporateWebTrial, routedLeadsListForCorporateWebTrial);
                    } else {
                        getBestCandidateInChannel(allCandidatesForCorporate, CORPORATE_ROLE_WILDCARD);
                    }
                } else if (leadType.equals(FREEMIUM)) {
                    rampingBuckets = corporateFreemiumBuckets.clone();  
                    if (routedUsingApex) {
                        getBestCandidateInSegmentAndUpdateMapping(maxRoutedLeadsMapForCorporateFreemium, routedLeadsListForCorporateFreemium);
                    } else {
                        getBestCandidateInChannel(allCandidatesForCorporate, CORPORATE_ROLE_WILDCARD);
                    }               
                } else {
                    rampingBuckets = corporateInboundBuckets.clone();       
                    if (routedUsingApex) {
                        getBestCandidateInSegmentAndUpdateMapping(maxRoutedLeadsMapForCorporateInbound, routedLeadsListForCorporateInbound);
                    } else {
                        getBestCandidateInChannel(allCandidatesForCorporate, CORPORATE_ROLE_WILDCARD);
                    }
                }       
            // Major         
            } else if (segment.equals('Major')) {       
                if (leadType.equals(WEB_TRIAL)) {       
                    rampingBuckets = majorWebTrialBuckets.clone();  
                    if (routedUsingApex) {
                        getBestCandidateInSegmentAndUpdateMapping(maxRoutedLeadsMapForMajorWebTrial, routedLeadsListForMajorWebTrial);
                    } else {
                        getBestCandidateInChannel(allCandidatesForMajor, MAJOR_ROLE_WILDCARD);
                    }
                } else if (leadType.equals(FREEMIUM)) {
                    rampingBuckets = majorFreemiumBuckets.clone();
                    if (routedUsingApex) {
                        getBestCandidateInSegmentAndUpdateMapping(maxRoutedLeadsMapForMajorFreemium, routedLeadsListForMajorFreemium);
                    } else {
                        getBestCandidateInChannel(allCandidatesForMajor, MAJOR_ROLE_WILDCARD);
                    }
                } else {
                    rampingBuckets = majorInboundBuckets.clone();
                    if (routedUsingApex) {
                        getBestCandidateInSegmentAndUpdateMapping(maxRoutedLeadsMapForMajorInbound, routedLeadsListForMajorInbound);
                    } else {
                        getBestCandidateInChannel(allCandidatesForMajor, MAJOR_ROLE_WILDCARD);
                    }
                }
            } else if (segment.equals('Enterprise')) {
                routeToUserId = ROUTING_ENTERPRISE_DEFAULT_USER_ID;
            } else if (segment.equals('Sales Ops')) {
                routeToUserId = ROUTING_SALES_OPS_DEFAULT_USER_ID;
            // SDRs
            } else {
                if (leadType.equals(WEB_TRIAL)) {
                    if (routedUsingApex) {
                        getBestCandidateInSegmentAndUpdateMapping(maxRoutedLeadsMapForSdrWebTrial, routedLeadsListForSdrWebTrial);
                    } else {
                        getBestCandidateInChannel(allCandidatesForSdr, SDR_ROLE_WILDCARD);
                    }
                } else if (leadType.equals(FREEMIUM)) {
                    if (routedUsingApex) {
                        getBestCandidateInSegmentAndUpdateMapping(maxRoutedLeadsMapForSdrFreemium, routedLeadsListForSdrFreemium);
                    } else {
                        getBestCandidateInChannel(allCandidatesForSdr, SDR_ROLE_WILDCARD);
                    }
                } else {
                    if (routedUsingApex) {
                        getBestCandidateInSegmentAndUpdateMapping(maxRoutedLeadsMapForSdrInbound, routedLeadsListForSdrInbound);
                    } else {
                        getBestCandidateInChannel(allCandidatesForSdr, SDR_ROLE_WILDCARD);
                    }
                }                               
            }
                        
            // Make sure routeToUser is not null    
            if (routeToUser == null) {
                routeToUser = allUsersList.get(routeToUserId);
            }       
            
        }   
    }   
    
    // This is for Route Me! button.  It is the more accurate method but is the most resource intensive
    public static void getBestCandidateInChannel(List<User> usersInRole, String role) {
                
        System.debug('Getting the best candidate in this channel...');
        if (usersInRole != null && usersInRole.size() > 0) {
            // Get max routed leads list
            List<AggregateResult> maxRoutedLeadsInChannel = createMaxRoutedLeadSoqlQuery(role, leadType, tier);             
                        
            // Generate map
            Map<User, RoutedLeadSummary> maxRoutedLeadsMapInChannel = generateMaxRoutedLeadsList(usersInRole, maxRoutedLeadsInChannel);
                        
            // Get rolling routed leads list
            List<Routed_Lead__c> rollingRoutedLeadsList = createRollingRoutedLeadsList(usersInRole, role, leadType, tier);
                        
            // Choose the tenure
            calculateNextDeservingBucket(rollingRoutedLeadsList);
                        
            // Choose the user
            chooseRouteToUser(maxRoutedLeadsMapInChannel);
        }
    }
    
    // This is for assignment rules. Much more efficient but "guesses" the next routing candidate.
    public static void getBestCandidateInSegmentAndUpdateMapping(Map<User, RoutedLeadSummary> maxRoutedLeadsMapInSegment, List<Routed_Lead__c> routedLeadsInSegment) {
        System.debug('Getting the best candidate in this segment.  Update if successful...');
        
        if (maxRoutedLeadsMapInSegment != null && maxRoutedLeadsMapInSegment.size() > 0) {

            // Choose the tenure
            calculateNextDeservingBucket(routedLeadsInSegment); 
                        
            // Choose the user
            User u = chooseRouteToUser(maxRoutedLeadsMapInSegment);
                        
            // Update the map.  
            maxRoutedLeadsMapInSegment.put(u, new RoutedLeadSummary(calculateTenure(u), DateTime.now()));   
            System.debug('Updated most recent routed lead for user: ' + u.Name + '. New max routed lead created date in segment is: ' + maxRoutedLeadsMapInSegment.get(u).maxCreatedDate);
            
            // Update the list
            updateRoutedLeadsList(routedLeadsInSegment, maxRoutedLeadsMapInSegment, u);
        }
    }
    
    // Fake list that tracks the routed leads that won't be created until much later (to save resources)
    public static void updateRoutedLeadsList(List<Routed_Lead__c> routedLeadsInSegment, Map<User, RoutedLeadSummary> maxRoutedLeadsMapInSegment, User u) {
        Routed_Lead__c r = new Routed_Lead__c();
        r.Routed_To__r = u;
        r.Tenure_Days__c = Date.valueOf(getTrueCreatedDate(u)).daysBetween(Date.today());
        r.Tenure_Boost_Days__c = u.Additional_Tenure_Days__c;
        r.Type__c = leadType;
        r.Tier__c = tier;
        System.debug('Routed leads in segment: ' + routedLeadsInSegment.size());
        System.debug('Max routed leads map in segment size: ' + maxRoutedLeadsMapInSegment.size());
        if (routedLeadsInSegment.size() > 0 && routedLeadsInSegment.size() >= maxRoutedLeadsMapInSegment.size()) {
            while (routedLeadsInSegment.size() >= maxRoutedLeadsMapInSegment.size()) {
                routedLeadsInSegment.remove(routedLeadsInSegment.size()-1);
            }
            routedLeadsInSegment.add(0, r);
            System.debug('Added a routed lead to the beginning of list');
        } else {
            routedLeadsInSegment.add(r);
            System.debug('Added a routed lead to the end of list');
        }       
        for (Routed_Lead__c rl : routedLeadsInSegment) {
            System.debug(rl.Routed_To__r.Id + ': ' + calculateTotalTenure(rl));
        }
    }

    // We do not calculate these dynamically.  Saves SOQL queries in bulk uploads.  This creates lists of all potential candidates
    public static void generateAllCandidatesListsByRole() {
        System.debug('Generating all candidates lists by role...');     
        String baseSoqlQuery = ' SELECT Id, Name, CreatedDate, Email, Additional_Tenure_Days__c, UserRole.Name, Created_Date__c '
                                + ' FROM User '
                                + ' WHERE IsActive = true '
                                +   ' AND Remove_From_All_Lead_Assignment_Queues__c = false '
                                +   ' AND (NOT Profile.Name LIKE \'%Eventforce%\') AND (NOT Profile.Name LIKE \'%Chatter%\') ';
        
        if (allUsersList == null) {
            allUsersList = new Map<Id, User>();
            List<User> tmpList = Database.query(baseSoqlQuery);
            allUsersList.putAll(tmpList);
        }
                
        baseSoqlQuery += ' AND UserRole.Name LIKE ';

        if (allCandidatesForObrMajor == null) {
            allCandidatesForObrMajor = Database.query(baseSoqlQuery + OBR_MAJOR_ROLE_WILDCARD);
            System.debug('Size of all candidates for obr major: ' + allCandidatesForObrMajor.size());
        }
        
        if (allCandidatesForObrEnterprise == null) {
            allCandidatesForObrEnterprise = Database.query(baseSoqlQuery + OBR_ENTERPRISE_ROLE_WILDCARD);
            System.debug('Size of all candidates for obr enterprise: ' + allCandidatesForObrEnterprise.size());
        }
        
        if (allCandidatesForCorporate == null) {
            allCandidatesForCorporate = Database.query(baseSoqlQuery + CORPORATE_ROLE_WILDCARD);
            System.debug('Size of all candidates for corporate: ' + allCandidatesForCorporate.size());
        }
        
        if (allCandidatesForMajor == null) {
            allCandidatesForMajor = Database.query(baseSoqlQuery + MAJOR_ROLE_WILDCARD);
            System.debug('Size of all candidates for major: ' + allCandidatesForMajor.size());
        }
        
        if (allCandidatesForSdr == null) {
            allCandidatesForSdr = Database.query(baseSoqlQuery + SDR_ROLE_WILDCARD);
            System.debug('Size of all candidates for sdr: ' + allCandidatesForSdr.size());
        }               
    }
    
    // Again, these aren't calculate dynamically so we save SOQL queries.  This tracks the last X routed leads to help us choose which bucket to use
    public static void generateRollingRoutedLeadsListsByChannel() {
        System.debug('Generatin routed lead lists for each channel...');
        
        // OBR Major list
        if (routedLeadsListForObrMajor == null) {
            routedLeadsListForObrMajor = new List<Routed_Lead__c>();
            routedLeadsListForObrMajor = createRollingRoutedLeadsList(allCandidatesForObrMajor, OBR_MAJOR_ROLE_WILDCARD, null, null); 
            System.debug('routedLeadsListForObrMajor size: ' + routedLeadsListForObrMajor.size());
        }
        System.debug('LeadAssignment cumulative query count A-1: ' + Limits.getQueryRows());
        
        // OBR Enterprise list
        if (routedLeadsListForObrEnterprise == null) {
            routedLeadsListForObrEnterprise = new List<Routed_Lead__c>();
            routedLeadsListForObrEnterprise = createRollingRoutedLeadsList(allCandidatesForObrEnterprise, OBR_ENTERPRISE_ROLE_WILDCARD, null, null);
            System.debug('routedLeadsListForObrEnterprise size: ' + routedLeadsListForObrEnterprise.size());
        }
        System.debug('LeadAssignment cumulative query count A-2: ' + Limits.getQueryRows());
        
        // Corporate Web Trial list
        if (routedLeadsListForCorporateWebTrial == null) {
            routedLeadsListForCorporateWebTrial = new List<Routed_Lead__c>();
            routedLeadsListForCorporateWebTrial = createRollingRoutedLeadsList(allCandidatesForCorporate, CORPORATE_ROLE_WILDCARD, WEB_TRIAL, null);
            System.debug('routedLeadsListForCorporateWebTrial size: ' + routedLeadsListForCorporateWebTrial.size());
        }
        System.debug('LeadAssignment cumulative query count A-3: ' + Limits.getQueryRows());
        
        // Corporate Freemium list
        if (routedLeadsListForCorporateFreemium == null) {
            routedLeadsListForCorporateFreemium = new List<Routed_Lead__c>();
            routedLeadsListForCorporateFreemium = createRollingRoutedLeadsList(allCandidatesForCorporate, CORPORATE_ROLE_WILDCARD, FREEMIUM, null);
            System.debug('routedLeadsListForCorporateFreemium size: ' + routedLeadsListForCorporateFreemium.size());
        }       
        System.debug('LeadAssignment cumulative query count A-4: ' + Limits.getQueryRows());
                
        // Corporate Inbound list
        if (routedLeadsListForCorporateInbound == null) {
            routedLeadsListForCorporateInbound = new List<Routed_Lead__c>();
            routedLeadsListForCorporateInbound = createRollingRoutedLeadsList(allCandidatesForCorporate, CORPORATE_ROLE_WILDCARD, INBOUND, null);
            System.debug('routedLeadsListForCorporateInbound size: ' + routedLeadsListForCorporateInbound.size());
        }
        System.debug('LeadAssignment cumulative query count A-5: ' + Limits.getQueryRows());
        
        // Major Web Trial list
        if (routedLeadsListForMajorWebTrial == null) {
            routedLeadsListForMajorWebTrial = new List<Routed_Lead__c>();
            routedLeadsListForMajorWebTrial = createRollingRoutedLeadsList(allCandidatesForMajor, MAJOR_ROLE_WILDCARD, WEB_TRIAL, null);
            System.debug('routedLeadsListForMajorWebTrial size: ' + routedLeadsListForMajorWebTrial.size());
        }       
        System.debug('LeadAssignment cumulative query count A-6: ' + Limits.getQueryRows());
        
        // Major Freemium list
        if (routedLeadsListForMajorFreemium == null) {
            routedLeadsListForMajorFreemium = new List<Routed_Lead__c>();
            routedLeadsListForMajorFreemium = createRollingRoutedLeadsList(allCandidatesForMajor, MAJOR_ROLE_WILDCARD, FREEMIUM, null);
            System.debug('routedLeadsListForMajorFreemium size: ' + routedLeadsListForMajorFreemium.size());
        }       
        System.debug('LeadAssignment cumulative query count A-7: ' + Limits.getQueryRows());
        
        // Major Inbound list
        if (routedLeadsListForMajorInbound == null) {
            routedLeadsListForMajorInbound = new List<Routed_Lead__c>();
            routedLeadsListForMajorInbound = createRollingRoutedLeadsList(allCandidatesForMajor, MAJOR_ROLE_WILDCARD, INBOUND, null);
            System.debug('routedLeadsListForMajorInbound size: ' + routedLeadsListForMajorInbound.size());
        }       
        System.debug('LeadAssignment cumulative query count A-8: ' + Limits.getQueryRows());
        
        // Sdr Web Trial list
        if (routedLeadsListForSdrWebTrial == null) {
            routedLeadsListForSdrWebTrial = new List<Routed_Lead__c>();
            routedLeadsListForSdrWebTrial = createRollingRoutedLeadsList(allCandidatesForSdr, SDR_ROLE_WILDCARD, WEB_TRIAL, null);
            System.debug('routedLeadsListForSdrWebTrial size: ' + routedLeadsListForSdrWebTrial.size());
        }           
        System.debug('LeadAssignment cumulative query count A-9: ' + Limits.getQueryRows());    
        
        // Sdr Freemium list
        if (routedLeadsListForSdrFreemium == null) {
            routedLeadsListForSdrFreemium = new List<Routed_Lead__c>();
            routedLeadsListForSdrFreemium = createRollingRoutedLeadsList(allCandidatesForSdr, SDR_ROLE_WILDCARD, FREEMIUM, null);
            System.debug('routedLeadsListForSdrFreemium size: ' + routedLeadsListForSdrFreemium.size());
        }           
        System.debug('LeadAssignment cumulative query count A-10: ' + Limits.getQueryRows());
        
        // Sdr Inbound list
        if (routedLeadsListForSdrInbound == null) {
            routedLeadsListForSdrInbound = new List<Routed_Lead__c>();
            routedLeadsListForSdrInbound = createRollingRoutedLeadsList(allCandidatesForSdr, SDR_ROLE_WILDCARD, INBOUND, null);
            System.debug('routedLeadsListForSdrInbound size: ' + routedLeadsListForSdrInbound.size());
        }           
        System.debug('LeadAssignment cumulative query count A-11: ' + Limits.getQueryRows());
    }
    
    // These lists track the most recent routed lead per user per channel
    public static void generateMaxRoutedLeadsListsByChannel() {
        System.debug('Generating max routed lead lists for each channel...');
        
        // OBR Major map
        if (maxRoutedLeadsMapForObrMajor == null) {
            maxRoutedLeadsMapForObrMajor = new Map<User, RoutedLeadSummary>();
            List<AggregateResult> maxRoutedLeadsForObrMajor = createMaxRoutedLeadSoqlQuery(OBR_MAJOR_ROLE_WILDCARD, null, null); 
            maxRoutedLeadsMapForObrMajor = generateMaxRoutedLeadsList(allCandidatesForObrMajor, maxRoutedLeadsForObrMajor);
            System.debug('Max routed leads map size for obr major: ' + maxRoutedLeadsMapForObrMajor.size());
        }
        System.debug('LeadAssignment cumulative query count B-1: ' + Limits.getQueryRows());
        
        // OBR Enterprise map
        if (maxRoutedLeadsMapForObrEnterprise == null) {
            maxRoutedLeadsMapForObrEnterprise = new Map<User, RoutedLeadSummary>();
            List<AggregateResult> maxRoutedLeadsForObrEnterprise = createMaxRoutedLeadSoqlQuery(OBR_ENTERPRISE_ROLE_WILDCARD, null, null);
            maxRoutedLeadsMapForObrEnterprise = generateMaxRoutedLeadsList(allCandidatesForObrEnterprise, maxRoutedLeadsForObrEnterprise);
            System.debug('Max routed leads map size for obr enterprise: ' + maxRoutedLeadsMapForObrEnterprise.size());
        }
        System.debug('LeadAssignment cumulative query count B-2: ' + Limits.getQueryRows());
        
        // Corporate Web Trial map
        if (maxRoutedLeadsMapForCorporateWebTrial == null) {
            maxRoutedLeadsMapForCorporateWebTrial = new Map<User, RoutedLeadSummary>();
            List<AggregateResult> maxRoutedLeadsForCorporateWebTrial = createMaxRoutedLeadSoqlQuery(CORPORATE_ROLE_WILDCARD, WEB_TRIAL, null);
            maxRoutedLeadsMapForCorporateWebTrial = generateMaxRoutedLeadsList(allCandidatesForCorporate, maxRoutedLeadsForCorporateWebTrial);
            System.debug('Max routed leads map size for corporate web trial: ' + maxRoutedLeadsMapForCorporateWebTrial.size());
        }
        System.debug('LeadAssignment cumulative query count B-3: ' + Limits.getQueryRows());
        
        // Corporate Freemium map
        if (maxRoutedLeadsMapForCorporateFreemium == null) {
            maxRoutedLeadsMapForCorporateFreemium = new Map<User, RoutedLeadSummary>();
            List<AggregateResult> maxRoutedLeadsForCorporateFreemium = createMaxRoutedLeadSoqlQuery(CORPORATE_ROLE_WILDCARD, FREEMIUM, null);
            maxRoutedLeadsMapForCorporateFreemium = generateMaxRoutedLeadsList(allCandidatesForCorporate, maxRoutedLeadsForCorporateFreemium);
            System.debug('Max routed leads map size for corporate freemium: ' + maxRoutedLeadsMapForCorporateFreemium.size());
        }       
        System.debug('LeadAssignment cumulative query count B-4: ' + Limits.getQueryRows());
                
        // Corporate Inbound map
        if (maxRoutedLeadsMapForCorporateInbound == null) {
            maxRoutedLeadsMapForCorporateInbound = new Map<User, RoutedLeadSummary>();
            List<AggregateResult> maxRoutedLeadsForCorporateInbound = createMaxRoutedLeadSoqlQuery(CORPORATE_ROLE_WILDCARD, INBOUND, null);
            maxRoutedLeadsMapForCorporateInbound = generateMaxRoutedLeadsList(allCandidatesForCorporate, maxRoutedLeadsForCorporateInbound);
            System.debug('Max routed leads map size for corporate inbound: ' + maxRoutedLeadsMapForCorporateInbound.size());
        }
        System.debug('LeadAssignment cumulative query count B-5: ' + Limits.getQueryRows());
        
        // Major Web Trial map
        if (maxRoutedLeadsMapForMajorWebTrial == null) {
            maxRoutedLeadsMapForMajorWebTrial = new Map<User, RoutedLeadSummary>();
            List<AggregateResult> maxRoutedLeadsForMajorWebTrial = createMaxRoutedLeadSoqlQuery(MAJOR_ROLE_WILDCARD, WEB_TRIAL, null);
            maxRoutedLeadsMapForMajorWebTrial = generateMaxRoutedLeadsList(allCandidatesForMajor, maxRoutedLeadsForMajorWebTrial);
            System.debug('Max routed leads map size for major web trial: ' + maxRoutedLeadsMapForMajorWebTrial.size());
        }       
        System.debug('LeadAssignment cumulative query count B-6: ' + Limits.getQueryRows());
        
        // Major Freemium map
        if (maxRoutedLeadsMapForMajorFreemium == null) {
            maxRoutedLeadsMapForMajorFreemium = new Map<User, RoutedLeadSummary>();
            List<AggregateResult> maxRoutedLeadsForMajorFreemium = createMaxRoutedLeadSoqlQuery(MAJOR_ROLE_WILDCARD, FREEMIUM, null);
            maxRoutedLeadsMapForMajorFreemium = generateMaxRoutedLeadsList(allCandidatesForMajor, maxRoutedLeadsForMajorFreemium);
            System.debug('Max routed leads map size for major freemium: ' + maxRoutedLeadsMapForMajorFreemium.size());
        }       
        System.debug('LeadAssignment cumulative query count B-7: ' + Limits.getQueryRows());
        
        // Major Inbound map
        if (maxRoutedLeadsMapForMajorInbound == null) {
            maxRoutedLeadsMapForMajorInbound = new Map<User, RoutedLeadSummary>();
            List<AggregateResult> maxRoutedLeadsForMajorInbound = createMaxRoutedLeadSoqlQuery(MAJOR_ROLE_WILDCARD, INBOUND, null);
            maxRoutedLeadsMapForMajorInbound = generateMaxRoutedLeadsList(allCandidatesForMajor, maxRoutedLeadsForMajorInbound);
            System.debug('Max routed leads map size for major inbound: ' + maxRoutedLeadsMapForMajorInbound.size());
        }       
        System.debug('LeadAssignment cumulative query count B-8: ' + Limits.getQueryRows());
        
        // Sdr Web Trial map
        if (maxRoutedLeadsMapForSdrWebTrial == null) {
            maxRoutedLeadsMapForSdrWebTrial = new Map<User, RoutedLeadSummary>();
            List<AggregateResult> maxRoutedLeadsForSdrWebTrial = createMaxRoutedLeadSoqlQuery(SDR_ROLE_WILDCARD, WEB_TRIAL, null);
            maxRoutedLeadsMapForSdrWebTrial = generateMaxRoutedLeadsList(allCandidatesForSdr, maxRoutedLeadsForSdrWebTrial);
            System.debug('Max routed leads map size for sdr web trial: ' + maxRoutedLeadsMapForSdrWebTrial.size());
        }       
        System.debug('LeadAssignment cumulative query count B-9: ' + Limits.getQueryRows());        
        
        // Sdr Freemium map
        if (maxRoutedLeadsMapForSdrFreemium == null) {
            maxRoutedLeadsMapForSdrFreemium = new Map<User, RoutedLeadSummary>();
            List<AggregateResult> maxRoutedLeadsForSdrFreemium = createMaxRoutedLeadSoqlQuery(SDR_ROLE_WILDCARD, FREEMIUM, null);
            maxRoutedLeadsMapForSdrFreemium = generateMaxRoutedLeadsList(allCandidatesForSdr, maxRoutedLeadsForSdrFreemium);
            System.debug('Max routed leads map size for sdr freemium: ' + maxRoutedLeadsMapForSdrFreemium.size());
        }           
        System.debug('LeadAssignment cumulative query count B-10: ' + Limits.getQueryRows());
        
        // Sdr Inbound map
        if (maxRoutedLeadsMapForSdrInbound == null) {
            maxRoutedLeadsMapForSdrInbound = new Map<User, RoutedLeadSummary>();
            List<AggregateResult> maxRoutedLeadsForSdrInbound = createMaxRoutedLeadSoqlQuery(SDR_ROLE_WILDCARD, INBOUND, null);
            maxRoutedLeadsMapForSdrInbound = generateMaxRoutedLeadsList(allCandidatesForSdr, maxRoutedLeadsForSdrInbound);
            System.debug('Max routed leads map size for sdr inbound: ' + maxRoutedLeadsMapForSdrInbound.size());
        }           
        System.debug('LeadAssignment cumulative query count B-11: ' + Limits.getQueryRows());
        
    }
    
    public static Map<Id, RoutedLeadSummary> convertAggListToMap(List<AggregateResult> aggList) {
        System.debug('Converting aggregate list to map...');
        Map<Id, RoutedLeadSummary> newMap = new Map<Id, RoutedLeadSummary>();
        if (aggList != null) {
            for (AggregateResult a : aggList) { 
                newMap.put(String.valueOf(a.get('routeToId')), new RoutedLeadSummary(Integer.valueOf(a.get('Tenure')), ((DateTime)a.get('CreatedDate')).addHours(-7), Integer.valueOf((a.get('sortOrder'))))); 
            }
        }
        return newMap;
    }
    
    public static Map<User, RoutedLeadSummary> generateMaxRoutedLeadsList(List<User> usersList, List<AggregateResult> maxRoutedLeadsList) {
        Map<User, RoutedLeadSummary> returnMap = new Map<User, RoutedLeadSummary>();        
        if (usersList != null && usersList.size() != 0 && maxRoutedLeadsList != null) {
            // Convert List<AggregateResult> to map for efficiency gains
            Map<Id, RoutedLeadSummary> tmpMaxRoutedLeadsMap = convertAggListToMap(maxRoutedLeadsList);          
            // Boolean foundRoutedLead;
            for (User u : usersList) {
                returnMap.put(u, tmpMaxRoutedLeadsMap.get(u.Id));
            }
        }
        return returnMap;
    }

    public static List<Routed_Lead__c> createRollingRoutedLeadsList(List<User> usersInRole, String role, String queryType, Decimal queryTier) {
        String soqlQuery;
        if (usersInRole != null && role != null && !role.equals('')) {
            soqlQuery = ' SELECT CreatedDate, Total_Tenure_Days__c, Routed_To__r.Id ' 
                        +   ' FROM Routed_Lead__c '
                        +   ' WHERE Routed_To__r.IsActive = true '
                        +   '     AND Undo_Reason__c = null '
                        +   '     AND Opportunity__r.StageName != \'Dead/No Opp\' '
                        +   '     AND Routed_To__r.Remove_From_All_Lead_Assignment_Queues__c = false '                                  
                        +   '     AND Routed_To__r.UserRole.Name LIKE ' + role + ' ';
                        
            if (queryType != null) {
                soqlQuery +=    ' AND Type__c = \'' + queryType + '\' ';
            }
            if (LIMITS_MAX_ROUTED_LEADS_AUDIT_DAYS != null) {
                String lastNumDays = 'LAST_N_DAYS:' + LIMITS_MAX_ROUTED_LEADS_AUDIT_DAYS.intValue(); 
                soqlQuery +=    ' AND CreatedDate >= ' + lastNumDays;
            }
            /*
            if (queryTier != null) {
                soqlQuery +=    '     AND Tier__c = ' + queryTier + ' ';
            }
            */
            soqlQuery +=        ' ORDER BY CreatedDate DESC, Routed_Lead_Order__c DESC '
                            +   ' LIMIT ' + usersInRole.size();
        }
        List<Routed_Lead__c> tmpList = new List<Routed_Lead__c>();
        tmpList = Database.query(soqlQuery);
        System.debug('Rolling routed leads aggregate list size for ' + role + ', ' + queryType + ', ' + queryTier + ': ' + tmpList.size());
        return tmpList;
        
    }
    
    public static List<AggregateResult> createMaxRoutedLeadSoqlQuery(String role, String queryType, Decimal queryTier) {
        String soqlQuery;                               
        if (role != null && !role.equals('')) {
            soqlQuery = ' SELECT MAX(CreatedDate) CreatedDate, MAX(Total_Tenure_Days__c) Tenure, Routed_To__r.Id routeToId, MAX(Routed_Lead_Order__c) sortOrder ' 
                        +   ' FROM Routed_Lead__c '
                        +   ' WHERE Routed_To__r.IsActive = true '
                        +   '     AND Undo_Reason__c = null '
                        +   '     AND Opportunity__r.StageName != \'Dead/No Opp\' '
                        +   '     AND Routed_To__r.Remove_From_All_Lead_Assignment_Queues__c = false '          
                        +   '     AND Routed_To__r.UserRole.Name LIKE ' + role + ' ';
            if (queryType != null) {
                soqlQuery +=    '     AND Type__c = \'' + queryType + '\' ';
            }
            /* 
            if (queryTier != null) {
                soqlQuery +=    '     AND Tier__c = ' + queryTier + ' ';
            }
            */
            if (LIMITS_MAX_ROUTED_LEADS_AUDIT_DAYS != null) {
                String lastNumDays = 'LAST_N_DAYS:' + LIMITS_MAX_ROUTED_LEADS_AUDIT_DAYS.intValue(); 
                soqlQuery +=    ' AND CreatedDate >= ' + lastNumDays;
            }
            soqlQuery +=        ' GROUP BY Routed_To__r.Id ';
        }               
        System.debug(soqlQuery);
        List<AggregateResult> tmpList = new List<AggregateResult>();
        tmpList = Database.query(soqlQuery);
        System.debug('Max routed leads aggregate list size for ' + role + ', ' + queryType + ', ' + queryTier + ': ' + tmpList.size());
        return tmpList;
    }

    public static List<Bucket> calculateBucketRatios(String genericBucket) {
        System.debug('Calculating bucket ratios...');
         
        List<Bucket> tmpBuckets = new List<Bucket>();       
        if (genericBucket != null && !genericBucket.equals('')) {
            List<String> splitBucketList = genericBucket.split(';');
            for (Integer i = 0; i < splitBucketList.size(); i++) {
                if (i != splitBucketList.size() - 1) {
                    tmpBuckets.add(new Bucket(Integer.valueOf(splitBucketList[i].split('/')[0]), Integer.valueOf(splitBucketList[i+1].split('/')[0]), Decimal.valueOf(splitBucketList[i].split('/')[1])));
                } else {
                    tmpBuckets.add(new Bucket(Integer.valueOf(splitBucketList[i].split('/')[0]), 9999, Decimal.valueOf(splitBucketList[i].split('/')[1])));
                }
            }
            verifyTenureSegmentation(tmpBuckets);
            verifySumOfBuckets(tmpBuckets);
        } else {
            tmpBuckets.add(new Bucket(0, 9999, 100));
        }       
        return tmpBuckets;
    }
    
    public static void verifyTenureSegmentation(List<Bucket> tmpBuckets) {
        System.debug('Verifying tenure segmentation of buckets...');
                
        if (tmpBuckets != null && tmpBuckets.size() > 0) {          
            Integer lastTenureSegment = -1;         
            for (Bucket b : tmpBuckets) {
                // Check that tenure buckets are in increasing order
                if (b.minTenure <= lastTenureSegment) {
                    resultsUrl = 'Error: Buckets are incorrectly set up! Make sure the tenure days are in increasing order.';
                    return;
                }
                // Check that every tenure bucket has an associated percentage
                if (b.percentage == null) {
                    resultsUrl = 'Error: Buckets are incorrectly set up! Make sure each tenure bucket has an associated percentage.';
                    return;
                }
            }
            System.debug('Buckets are good to go!');
        } else {
            resultsUrl = 'Error setting up tenure buckets. Please contact your administrator.';
        }
    }
    
    public static void verifySumOfBuckets(List<Bucket> tmpBuckets) {
        System.debug('Verifying sum of buckets...');
        if (tmpBuckets != null && tmpBuckets.size() > 0) {
            Decimal sumOfBuckets = 0;
            for (Bucket b : tmpBuckets) {
                sumOfBuckets += b.percentage;
            }
            if (sumOfBuckets == 100) {
                System.debug('Success! Buckets add up to 100!');
            } else {
                resultsUrl = 'Buckets add up to ' + sumOfBuckets + ' =(  Fix the values in custom settings!';
            }
        } else {
            resultsUrl = 'Error setting up tenure buckets. Please contact your administrator.';
        }
    }   
    
    // Very important function.  Count the last X routed leads in segment where X is the # of potential candidates
    public static void calculateNextDeservingBucket(List<Routed_Lead__c> routedLeadsList) {
        System.debug('Finding next deserving bucket...');
        if (routedLeadsList != null) {      
                                    
            // We calculate percentages based on the lesser of the subset size & all candidates list
            candidatesListSize = routedLeadsList.size();
            
            // Flip ramping buckets so ramped reps have priority
            List<Bucket> tmpBuckets = new List<Bucket>();
            for (Integer i = (rampingBuckets.size() - 1); i >= 0; i--) {
                rampingBuckets[i].numberOfRoutedLeads = 0;
                tmpBuckets.add(rampingBuckets[i]);
            }   
            rampingBuckets.clear();
            rampingBuckets = tmpBuckets;
                        
                        
                        
            // Get # of routed leads for each bucket        
            Integer tmpTenureDays;  
            for (Routed_Lead__c r : routedLeadsList) {  
                tmpTenureDays = calculateTotalTenure(r);                                        
                for (Bucket b : rampingBuckets) {
                    // See if it's in this bucket                   
                    if (tmpTenureDays >= b.minTenure && tmpTenureDays < b.maxTenure) {
                        b.numberOfRoutedLeads = b.numberOfRoutedLeads + 1;
                        break;              
                    }                                               
                }
            }
            
            // Choose a bucket  
            Boolean foundRoutingBucket = false;
            for (Bucket b : rampingBuckets) {                   
                // Get the percentage of total candidates for this subset
                if (candidatesListSize > 0) {
                    b.percentageOfRoutedLeads = Decimal.valueOf(b.numberOfRoutedLeads) / Decimal.valueOf(candidatesListSize);
                }                   
                Decimal optimalSubsetPercentage = b.percentage / 100;
                System.debug('Subset complete. Current percentage: ' + b.percentageOfRoutedLeads + '. Optimal percentage: ' + optimalSubsetPercentage);
                
                // Check if this is the bucket we've been looking for.  If it's the last bucket, it automatically wins              
                if (!foundRoutingBucket && (b.percentageOfRoutedLeads < optimalSubsetPercentage || b.minTenure == 0)) {
                    System.debug('This is the bucket we will commit to. Tenure: ' + b.minTenure + ' to ' + b.maxTenure + ' days.');
                    foundRoutingBucket = true;
                    minBoundTenure = b.minTenure;
                    maxBoundTenure = b.maxTenure;
                    
                    // Adding one for debug purposes
                    b.numberOfRoutedLeads = b.numberOfRoutedLeads + 1;      
                }                                                       
            }           
        } else {
            resultsUrl = 'Error: No potential candidates for lead route!';
        }
    }
    
    public static Map<User, RoutedLeadSummary> generateFinalCandidatesMap(Map<User, RoutedLeadSummary> maxRoutedLeadsMap) {
        System.debug('Generating final candidates mapping...');
        Map<User, RoutedLeadSummary> finalCandidatesWithMostRecentRoutedLeadsMap = new Map<User,RoutedLeadSummary>();
        if (maxRoutedLeadsMap != null) {
            if (minBoundTenure != null && maxBoundTenure != null) {             
                Integer tmpTenure;                                                      
                for (User u : maxRoutedLeadsMap.keySet()) {
                    tmpTenure = calculateTenure(u);
                    if (tmpTenure >= minBoundTenure && tmpTenure < maxBoundTenure) {
                        finalCandidatesWithMostRecentRoutedLeadsMap.put(u, maxRoutedLeadsMap.get(u));                       
                    }                   
                }
                
                // If no potential candidate exists, choose random person.  Debug numbers will be broken
                if (finalCandidatesWithMostRecentRoutedLeadsMap.size() == 0) {
                    Integer randomNumber = (Math.random() * maxRoutedLeadsMap.size()).intValue();
                    List<User> tmpUserList = new List<User>();
                    tmpUserList.addAll(maxRoutedLeadsMap.keySet());
                    finalCandidatesWithMostRecentRoutedLeadsMap.put(tmpUserList.get(randomNumber), maxRoutedLeadsMap.get(tmpUserList.get(randomNumber)));
                }                       
                System.debug('Final candidates mapping size: ' + finalCandidatesWithMostRecentRoutedLeadsMap.size());                               
            } else {
                resultsUrl = 'Error setting up min and max tenure bounds.';
            }
        } else {
            resultsUrl = 'Error: No potential candidates for lead route!';
        }
        return finalCandidatesWithMostRecentRoutedLeadsMap;
    }   
    
    public static User chooseRouteToUser(Map<User, RoutedLeadSummary> designatedMaxRoutedLeadsMap) {
        
        // Get list of final candidates first
        Map<User, RoutedLeadSummary> finalCandidatesMap = generateFinalCandidatesMap(designatedMaxRoutedLeadsMap);
        
        System.debug('Choosing the user we will route to...');
        User bestCandidate; 
        if (finalCandidatesMap != null && finalCandidatesMap.size() != 0) {
            System.debug('Final candidates list size: ' + finalCandidatesMap.size());
            // Find the person with the oldest DateTime routed lead (or null)
            for (User u : finalCandidatesMap.keySet()) {
                // Step 1: Make sure bestCandidate isn't null for our comparisons
                if (bestCandidate == null) {
                    bestCandidate = u;
                }
                
                // Step 2: If the candidate doesn't have a DateTime, he wins
                if (finalCandidatesMap.get(u) == null || finalCandidatesMap.get(u).maxCreatedDate == null) {
                    bestCandidate = u;
                    break;
                }
                
                // Step 3: If current user DateTime is less than bestCandidate DateTime, he becomes bestCandidate
                if (finalCandidatesMap.get(u).maxCreatedDate < finalCandidatesMap.get(bestCandidate).maxCreatedDate) {
                    bestCandidate = u;
                }
                
                // Step 4: If same created date, check routed lead name
                if (finalCandidatesMap.get(u).maxCreatedDate == finalCandidatesMap.get(bestCandidate).maxCreatedDate) {
                    if (finalCandidatesMap.get(u).sortOrder != null && finalCandidatesMap.get(bestCandidate).sortOrder != null
                        && finalCandidatesMap.get(u).sortOrder < finalCandidatesMap.get(bestCandidate).sortOrder) {
                        bestCandidate = u;  
                    }
                }
            }           
            routeToUser = bestCandidate;
            System.debug('Route to user: ' + routeToUser.Name);         
        } else {
            resultsUrl = 'Error choosing next route to user. Please contact your administrator.';
        }
        return bestCandidate;
    }       
    
    public static Integer calculateTotalTenure(Routed_Lead__c r) {
        Integer realTenure;
        if (r != null) {
            realTenure = r.Total_Tenure_Days__c == null ? (r.Tenure_Days__c == null ? 0 : r.Tenure_Days__c.intValue()) + (r.Tenure_Boost_Days__c == null ? 0 : r.Tenure_Boost_Days__c.intValue()) : r.Total_Tenure_Days__c.intValue();
        }
        return realTenure;
    }
    
    public static Integer calculateTenure(User u) {
        Integer realTenure;
        if (u != null) {
            Integer additionalTenure = u.Additional_Tenure_Days__c == null ? 0 : u.Additional_Tenure_Days__c.intValue();
            DateTime trueCreatedDate = getTrueCreatedDate(u);
            realTenure = Date.valueOf(trueCreatedDate).daysBetween(Date.today()) + additionalTenure;
        }
        return realTenure;
    }
    
    // This is to compensate for the Created Date* user field 
    public static DateTime getTrueCreatedDate(User u) {
        DateTime trueCreatedDate;
        if (u != null) {
            trueCreatedDate = u.Created_Date__c == null ? u.CreatedDate : u.Created_Date__c; 
        }
        return trueCreatedDate;
    }
    
    public static void passTheLead() {
        if (routeUsingAssignmentRules) {
            passTheLeadUsingAssignmentRules();
        } else {
            lead.Assigned_By_Route_Me_Button__c = true;
            convertLead();
        }
    }
    
    public static void passTheLeadUsingAssignmentRules() {
        System.debug('Passing the lead via assignment rules...');           
        lead.OwnerId = routeToUser.Id;      
        // Email alert will be triggered via a workflow
    }
    
    public static void convertLead() {      
        System.debug('Converting lead...');                     
         
        // Check for email dupes on contact     
        Boolean noDupes = checkForEmailDupes();     
                                
        // Validate inputs              
        Boolean passedValidation = validateLeadConversionInputs();      
                
        if (noDupes && passedValidation) {      
            // No dupes. Save lead information      
            lead.OwnerId = routeToUser.Id;
            update lead;
                    
            // Attempt to convert the lead      
            System.debug('No duplicate accounts or contacts found. Converting lead...');
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lead.Id);                          
            lc.setOwnerId(routeToUser.Id);
            LeadStatus convertStatus;
            if (DEFAULT_LEAD_CONVERTED_STATUS == null || DEFAULT_LEAD_CONVERTED_STATUS.equals('')) {
                convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
            } else {
                convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true AND MasterLabel = :DEFAULT_LEAD_CONVERTED_STATUS LIMIT 1];
            }
            lc.setConvertedStatus(convertStatus.MasterLabel);       
            lc.setSendNotificationEmail(true);                  
            leadConvertResult = Database.convertLead(lc);
            if (!leadConvertResult.isSuccess()) {
                System.debug('Error converting lead.');
                String errors;
                Database.Error[] errs = leadConvertResult.getErrors();
                for (Database.Error e : errs) {
                    errors += e.getStatusCode() + ': ' + e.getMessage() + '\n';
                }
                resultsUrl = 'Error converting lead.';
            } else {
                System.debug('Successful lead conversion!');            
                accountId = LeadConvertResult.getAccountId();
                contactId = LeadConvertResult.getContactId();           
                
                // Create SDR Qual Note object
                //createSdrQualNote(lead, routeByUser.Id, accountId); 
                
                createConvertedLeadOpportunities();                 
            }
        }
    }   
    
    public static Boolean validateLeadConversionInputs() {      
        System.debug('Validating lead conversion inputs...');
        Boolean inputsValid = true;
        
        // Do not allow web trial route me
        if (lead.Business_Web_Trial__c) {
            inputsValid = false;
            resultsUrl = 'Error: Web Trials should not be routed using this button.';
        }
        
        // Require # users if not a web trial
        if (!leadType.equals(WEB_TRIAL) && (lead.Number_of_Users__c == null || lead.Number_of_Users__c == 0)) {
            inputsValid = false;
            resultsUrl = 'Error: "Number of Users" is required.';
        }
        
        // Required upsell opp fields
        if (lead.Upsell_Opportunity__c && !leadType.equals(WEB_TRIAL)) {
            if (lead.Scope_of_Deployment__c == null || lead.Number_of_Upsell_Users__c == null || lead.Number_of_Upsell_Users__c == 0) {
                inputsValid = false;
                resultsUrl = 'Error: "Scope of Deployment" and "Number of Upsell Users" is required for Upsell Opportunities.';
            }
        }
        
        System.debug('Lead conversion inputs valid status: ' + inputsValid);
        return inputsValid;
    }
    
    public static void createConvertedLeadOpportunities() {
        System.debug('Updating main conversion opp...');
        
        List<Opportunity> updateOps = new List<Opportunity>();
        if (leadConvertResult.getOpportunityId() != null) {
            opportunity = [SELECT Id, Name, (Select Id, ContactId From OpportunityContactRoles), Owner.Name FROM Opportunity WHERE Id = :leadConvertResult.getOpportunityId() LIMIT 1];
            if (opportunity != null) {              
                // Attach qual note
                if (sdrQualNote!= null && sdrQualNote.Id != null) {
                    opportunity.SDR_Qualification_Notes__c = sdrQualNote.Id;
                }
                                
                // This update call fires triggers - lead conversion skips this!
                update opportunity;
                
                // Make sure a primary contact is set!
                setPrimaryContact(opportunity);     
                                
                // Create second opp for upsell
                // createUpsellOpportunity();       
            } else {
                resultsUrl = 'Error: No opportunity found during conversion.';
            }
        } else {
            resultsUrl = 'Error: No opportunity found during conversion.';  
        }
    }
    
    /*
    public static void createUpsellOpportunity() {
        if (lead.Upsell_Opportunity__c && !leadType.equals(WEB_TRIAL)) {
            if (lead.Scope_of_Deployment__c != null && lead.Number_of_Upsell_Users__c != null) {
                System.debug('Creating upsell opportunity...');
                // Create a new list so we can clone            
                List<Opportunity> opps = new List<Opportunity>();
                opps.add(opportunity);
                List<Opportunity> clonedUpsellOpps = SObjectAllFieldCloner.cloneObjects(opps, opportunity.getsObjectType());
                upsellOpportunity = (Opportunity)clonedUpsellOpps.get(0);
                upsellOpportunity.Name = upsellOpportunity.Name + ' - SDR Identified Upsell';
                upsellOpportunity.Contact_Method_Most_Recent__c = 'Rep Upsell Existing Business Client';        
                if (sdrQualNote!= null && sdrQualNote.Id != null) {
                    upsellOpportunity.SDR_Qualification_Notes__c = sdrQualNote.Id;
                }           
                insert upsellOpportunity;
                // Create opp contact role on the upsell opp
                if (leadConvertResult.getContactId() != null) {
                    OpportunityContactRole ocr = new OpportunityContactRole();
                    ocr.OpportunityId = upsellOpportunity.Id;
                    ocr.ContactId = leadConvertResult.getContactId();
                    ocr.isPrimary = true;
                    insert ocr;
                } 
                System.debug('Upsell Opp created: ' + upsellOpportunity.name);      
            }   
        }           
    }
    */
    
    public static void setPrimaryContact(Opportunity opp) {
        System.debug('Setting primary contact on the opportunity...');
        if (opp == null || opp.OpportunityContactRoles[0] == null || opp.OpportunityContactRoles[0].Id == null) {
            resultsUrl = 'Cannot set primary contact on the opportunity. No opportunity contact role could be found.';
        } else {
            OpportunityContactRole ocr = [SELECT Id, isPrimary, ContactId FROM OpportunityContactRole WHERE Id = :opp.OpportunityContactRoles[0].Id];
            if (ocr != null) {
                ocr.isPrimary = true;
                update ocr;
                System.debug('Primary contact set: ' + ocr.ContactId);
            }                   
        }
    }   
    
    public static String createSdrQualNote(Lead l, String ownerId, String accId) { 
        System.debug('Creating qual note...');
        
        sdrQualNote = new SDR_Qualification_Notes__c();
        if (l.Company != null && l.Company.length() <= 68) {
            sdrQualNote.Name = l.Company + ' Qual Notes';
        } else {
            sdrQualNote.Name = 'Qual Notes';
        }
        /*
        sdrQualNote.About_the_Company__c       = l.About_the_Company__c;
        sdrQualNote.Business_Objective__c      = l.Business_Objective__c;
        sdrQualNote.Competition__c             = l.Competition__c;
        sdrQualNote.Decision_Makers__c         = l.Decision_Makers__c;
        sdrQualNote.How_They_Found_Box__c      = l.How_They_Found_Box__c;
        sdrQualNote.Next_Steps__c              = l.Next_Steps__c; 
        sdrQualNote.Pain__c                    = l.Pain__c;
        sdrQualNote.Number_of_Users__c         = l.Number_of_Users__c;      
        sdrQualNote.Employees_User_Defined__c  = l.Employees__c;
        sdrQualNote.NumberOfEmployees__c       = l.NumberOfEmployees;
        sdrQualNote.Scope_of_Deployment__c     = l.Scope_of_Deployment__c;
        sdrQualNote.Number_of_Upsell_Users__c  = l.Number_of_Upsell_Users__c; 
        sdrQualNote.Budget__c                  = l.Budget__c; 
        sdrQualNote.CurrencyIsoCode            = l.CurrencyIsoCode;
        sdrQualNote.OwnerId                    = ownerId;
        */
        
        // New Mapping
        sdrQualNote.Number_of_Users__c = l.Number_of_Users__c;
        sdrQualNote.Employees_User_Defined__c = l.Employees__c;
        sdrQualNote.Box_Features_of_Interest__c = l.Box_Features_of_Interest__c;
        sdrQualNote.Existing_Enterprise_Applications__c = l.Existing_Enterprise_Applications__c;
        sdrQualNote.Opp_Summary__c = l.Opp_Summary__c;
        sdrQualNote.Pain__c = l.Pain__c;
        sdrQualNote.Decision_Makers__c = l.Decision_Makers__c;
        sdrQualNote.Buying_Process__c = l.Buying_Process__c;
        sdrQualNote.Competitors__c = l.Competitors__c;
        sdrQualNote.Purchase_Time_Frame__c = l.Purchase_Time_Frame__c;
        sdrQualNote.Next_Steps__c = l.Next_Steps__c;

        /* Create Name */
        String name = '';
        if (l.FirstName != null) name += l.FirstName;
        if (name != '') name += ' ';
        if (l.LastName != null) name += l.LastName;

        sdrQualNote.Contact_Name__c = name;
        
        if (accId != null) {
            sdrQualNote.Account__c = accId;
        }
        
        // Don't make empty qual notes
        if (l.Number_of_Users__c != null || 
            l.Employees__c != null || 
            l.Box_Features_of_Interest__c != null || 
            l.Existing_Enterprise_Applications__c != null || 
            l.Opp_Summary__c != null || 
            l.Pain__c!= null ||
            l.Decision_Makers__c != null || 
            l.Buying_Process__c != null || 
            l.Competitors__c != null ||
            l.Purchase_Time_Frame__c != null ||
            l.Next_Steps__c != null) {                          
            insert sdrQualNote;         
            System.debug('Sdr qual notes inserted!');
        }
        return sdrQualNote.Id; 
    }   
    
    public static Boolean checkForEmailDupes() {
        Boolean noDupes = true;
        if (lead.Email != null && !lead.Email.equals('')) {
            System.debug('Checking for contacts matching ' + lead.Email + '...');
            List<Contact> contacts = [SELECT Id, Name, Email FROM Contact WHERE Email = :lead.Email];
            if (contacts != null && contacts.size() > 0) {
                noDupes = false;
                resultsUrl = 'Error: Duplicate email address found on contact ' + contacts[0].Id +'. Temporarily change the lead email address (add xyz) and try again.';
            }
        }   
        return noDupes;
    }   
    
    public static void createRoutedLeadObject() {
        System.debug('Creating routed lead object...');
        routedLead = new Routed_Lead__c();
        if (routeByUser != null) {
            routedLead.Routed_By__c = routeByUser.Id;
        } else {
            routedLead.Routed_By__c = routeByUserId;
        }
        routedLead.Routed_To__c = routeToUser.Id;
        routedLead.OwnerId = routeToUser.Id; 
        routedLead.Tenure_Days__c = Date.valueOf(getTrueCreatedDate(routeToUser)).daysBetween(Date.today());
        routedLead.Tenure_Boost_Days__c = routeToUser.Additional_Tenure_Days__c;            
        routedLead.Routed_by_Auto_Assignment_Rules__c = routeUsingAssignmentRules;
        routedLead.Company_Segment__c = segment;        
        routedLead.Tier__c = tier;
        routedLead.Type__c = leadType;
        if (lead != null && lead.id != null) {
            routedLead.Lead__c = lead.Id;
        }
        if (accountId != null) {
            routedLead.Account__c = accountId;
        }
        if (contactId != null) {
            routedLead.Contact__c = contactId;
        }
        if (opportunity != null) {
            routedLead.Opportunity__c = opportunity.Id;
        }
        if (upsellOpportunity != null && upsellOpportunity.Id != null) {
            routedLead.Upsell_Opportunity__c = upsellOpportunity.Id;
        }
        if (sdrQualNote!= null && sdrQualNote.Id != null) {
            routedLead.SDR_Qualification_Notes__c = sdrQualNote.Id;
        }
        
        if (!routeUsingAssignmentRules) {
            try {
                insert routedLead;
                System.debug('Routed lead inserted!');
            } catch (Exception e) {
                System.debug('Converted lead could not be associated with the Routed Lead Object. Unassociating...');
                routedLead.Lead__c = null;
                insert routedLead;
                System.debug('Routed lead inserted!');
            }
        }
    }
    
    // This is for the Route Me! button. The visualforce page parses the URL to show the results
    public static void generateReturnUrl() {
        if (!routeUsingAssignmentRules) {
            DateTime trueCreatedDate = routeToUser.Created_Date__c == null ? routeToUser.CreatedDate : routeToUser.Created_Date__c;
            tenure = Date.valueOf(trueCreatedDate).daysBetween(Date.today());
            if (routeToUser.Additional_Tenure_Days__c != null) {
                tenure = tenure + routeToUser.Additional_Tenure_Days__c.intValue();
            }
            resultsUrl = '?contact=' + lead.Name + '&contactId=' + leadConvertResult.getContactId() 
                            + '&account=' + lead.Company + '&accountId=' + leadConvertResult.getAccountId() 
                            + '&opportunity=' + opportunity.Name + '&opportunityId=' + leadConvertResult.getOpportunityId() 
                            + '&baseUrl=' + URL.getSalesforceBaseUrl().toExternalForm() 
                            + '&segment=' + segment + '&owner=' + opportunity.Owner.Name
                            + '&empField=' + employeesFieldOutput + '&employees=' + employees
                            + '&tier=' + tier + '&type=' + leadType + '&tenure=' + tenure
                            + '&routedLeadId=' + routedLead.Id + '&candidatesListSize=' + String.valueOf(candidatesListSize);
            if (upsellOpportunity != null) {                            
                resultsUrl += '&upsell=' + upsellOpportunity.Name + '&upsellId=' + upsellOpportunity.Id;
            }
            
            resultsUrl = EncodingUtil.urlEncode(resultsUrl, 'UTF-8');
            resultsURL += '&buckets=' + JSON.serialize(rampingBuckets);
        }
    }   
    
    // POJO for our maps.  maxTenure may be deprecated... 
    public class RoutedLeadSummary {
        public Integer maxTenure;
        public DateTime maxCreatedDate;
        public Integer sortOrder;

        public RoutedLeadSummary(Integer i, DateTime d) {
            maxTenure = i;
            maxCreatedDate = d;
        }
        
        public RoutedLeadSummary(Integer i, DateTime d, Integer s) {
            maxTenure = i;
            maxCreatedDate = d;
            sortOrder = s;
        }
    }
        
    // Bucket POJO  
    public class Bucket {
        public Integer minTenure;
        public Integer maxTenure;
        public Decimal percentage;
        
        public Integer numberOfRoutedLeads;
        public Decimal percentageOfRoutedLeads;
        
        public Bucket(Integer i, Integer m, Decimal d) {
            this.minTenure = i;
            this.maxTenure = m;
            this.percentage = d;
            this.numberOfRoutedLeads = 0;
            this.percentageOfRoutedLeads = 0;
        }               
    }
    
}