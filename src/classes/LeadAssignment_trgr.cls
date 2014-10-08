public class LeadAssignment_trgr {
  
  /* Settings and Constants */
  public static LeadAssignmentSettings__c settings = LeadAssignmentSettings__c.getInstance('default');
  public static final Boolean EMERGENCY_SHUTOFF = (settings == null) ? false : settings.Emergency_Shutoff_Button_for_Auto_Assign__c;
  public static final Boolean FCCRM_AUTO_ASSIGNMENT_RULES = (settings == null) ? true : settings.FCCRM_Auto_assignment_Rules__c; 
  
  public static void routeLeads(List<Lead> old_list, List<Lead> new_list, 
                                Map<ID,Lead> old_map, Map<ID,Lead> new_map,
                                Boolean isInsert, Boolean isUpdate)
  {
    if (!EMERGENCY_SHUTOFF) {   
      System.debug('Script limit before trigger: ' + Limits.getScriptStatements());
      
      List<Lead> leads = new List<Lead>();    
      List<Routed_Lead__c> routedLeads = new List<Routed_Lead__c>();
      List<Messaging.Email> emails = new List<Messaging.Email>();     
        
      List<Lead> leadsToEvaluate = new List<Lead>();  
      if (FCCRM_AUTO_ASSIGNMENT_RULES) {
        System.debug('FCCRM routing rules are ON.');
        for (Lead l : new_list) {
          // Leads whose Trigger_Assignment__c flips to true will be assigned
          Boolean oldAssignmentTriggerValue;
          if (isInsert) {
            oldAssignmentTriggerValue = false;
          } else {  
            oldAssignmentTriggerValue = old_map.get(l.Id).Trigger_Assignment__c;
          }
          Boolean newAssignmentTriggerValue = new_map.get(l.Id).Trigger_Assignment__c;         
          System.debug('Old trigger assignment field: ' + oldAssignmentTriggerValue + ', new: ' + newAssignmentTriggerValue);
          if (!oldAssignmentTriggerValue && newAssignmentTriggerValue) {            
            System.debug('This lead will go through assignment rules...');
            leadsToEvaluate.add(l);
          } else {
            System.debug('This lead will NOT go through assignment rules.');
          }
        }
      } else {
        System.debug('FCCRM routing rules are OFF.');
        if (isUpdate) {
          System.debug('This is an update trigger. Killing...');
          leadsToEvaluate = null;
        } else {
          System.debug('This is an insert trigger. Running assignment rules...');
          leadsToEvaluate.addAll(new_list);
        }
      }   
      
      // Set trigger assignment to false
      List<Lead> undoTriggerAssignmentList = new List<Lead>();
      for (Lead lead : new_list) {     
        if (lead.Trigger_Assignment__c) {
          Lead leadCopy = new Lead(Id=lead.Id);
          leadCopy.Trigger_Assignment__c = false;
          undoTriggerAssignmentList.add(leadCopy);
        }
      }
      if (undoTriggerAssignmentList != null && undoTriggerAssignmentList.size() > 0) {
        System.debug('Undoing ' + undoTriggerAssignmentList.size() + ' trigger assignment booleans...');
        update undoTriggerAssignmentList;
      }
      
      if (leadsToEvaluate != null && leadsToEvaluate.size() > 0) {
        // Route the lead 
        for (Lead l : [SELECT Id, NumberOfEmployees, Employees__c, Contact_Method__c, Email, Partner_program_type__c, Source_Detail__c,
                    Upsell_Opportunity__c, Purchase_Time_Frame__c, Title, Business_Web_Trial__c,
                    Do_Not_Assign__c, CreatedById, OwnerId, Contact_Method_Original__c, Company,
                    About_the_Company__c, Business_Objective__c, Competition__c, Decision_Makers__c,
                    How_They_Found_Box__c, Next_Steps__c, Pain__c, Number_of_Users__c, CleanCM__c,
                    Scope_of_Deployment__c, Number_of_Upsell_Users__c, Name, Eloqua_Country_Code__c,
                    Budget__c, Territory_Routing_Country__c
                  FROM Lead WHERE Id IN :leadsToEvaluate]) {                    
          
          Lead newLead;         
          newLead = LeadAssignment.routeLeadApex(l, UserInfo.getUserId());
          if (newLead != null) {
            leads.add(newLead);
          }   
          
          Routed_Lead__c newRoutedLead;
          if (LeadAssignment.routedLead != null) {
            newRoutedLead = LeadAssignment.routedLead;
            routedLeads.add(newRoutedLead);
          } 
        }
        
        // Bulk update leads 
        if (leads != null && leads.size() > 0) {
          update leads;
        } 
        
        // Bulk insert routed leads
        if (routedLeads != null && routedLeads.size() > 0) {
          insert routedLeads;
        }
        System.debug('Script limit after trigger: ' + Limits.getScriptStatements());
      } 
    } else {
      System.debug('The big red emergency shutoff button has been pushed!');
    }
  }

  public static void setRoutingCountry(List<Lead> old_list, List<Lead> new_list, 
                                Map<ID,Lead> old_map, Map<ID,Lead> new_map,
                                Boolean isInsert, Boolean isUpdate)
  {
    if (new_list == null)
    {
      System.debug('List provided to setRoutingCountry was null!');
      return;
    }
    System.debug('Determing Routing Country...');
    for (Lead cur_lead: new_list)
    {
      System.debug('Lead.  Should Trigger Assignment? : ' + cur_lead.Trigger_Assignment__c);
      if (cur_lead.Trigger_Assignment__c)
      {
        System.debug('Lead email: ' + cur_lead.email);
        // If email is from Japan, set Routing Country
        if (LocationUtils_hlpr.determineLocationByEmail(cur_lead.email) == LocationUtils_hlpr.JAPAN_COUNTRY_CODE)
        {
          System.debug('Setting lead Eloqua_Country_Code__c...');
          cur_lead.Eloqua_Country_Name__c = LocationUtils_hlpr.JAPAN_COUNTRY_CODE;
        }
      }
    }
  }
}