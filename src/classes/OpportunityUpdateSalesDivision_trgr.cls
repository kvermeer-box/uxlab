public with sharing class OpportunityUpdateSalesDivision_trgr {
  
  public OpportunityUpdateSalesDivision_trgr() {}

  public static void updateSalesDivisionAndTheater(boolean is_insert, Map<ID,Opportunity> old_map, List<Opportunity> new_values)
  {
    // Decide opps to update, then update them
    List<Opportunity> opps_to_update = decideOppsToUpdate(new_values, old_map, is_insert);
    updateOpps(opps_to_update);
  }

  private static List<Opportunity> decideOppsToUpdate(List<Opportunity> opps,  Map<ID,Opportunity> old_map, Boolean is_insert)
  {
    return opps;
    // Would prefer to only get those who's ownerID changed, but lead conversion errors with Salesforce prevents this
    /*
    List<Opportunity> opps_to_update = new List<Opportunity>();
    if (is_insert) 
    {
      System.debug('First time insert opps!');
      opps_to_update = opps;
    }
    else
    {
      // If this is an update, only get opps whose OwnerId has changed
      List<Opportunity> changed_opps = new List<Opportunity>();
      for (Opportunity new_opp : opps)
      {
        Opportunity old_opp = old_map.get(new_opp.Id);
        System.debug('Old opp owner: ' + old_opp.OwnerId);
        System.debug('New opp owner: ' + new_opp.OwnerId);
        if (old_opp.OwnerId != new_opp.OwnerId) //|| new_opp.Sales_Division__c == null || new_opp.Theater__c == null)
        {
          System.debug('Owner Changed!');
          changed_opps.add(new_opp);
        }
      }
      opps_to_update = changed_opps;
    }
    return opps_to_update;
    */
  }

  private static void updateOpps(List<Opportunity> opps_to_update)
  {
    // Grab all users to have ready for later --> Heap Size vs. Script Lines Tradeoff
    Map<ID, User> user_map = new Map<ID, User>([SELECT Id, UserRole.Name FROM User WHERE (NOT Profile.Name LIKE '%Eventforce%') AND (NOT Profile.Name LIKE '%Chatter%')]);

    // Grab custom settings
    SalesDivision__c sales_division_settings = SalesDivision__c.getInstance('Mappings');
    if (sales_division_settings == null) sales_division_settings = new SalesDivision__c(Grouping__c='');
    Theater__c theater_settings = Theater__c.getInstance('Mappings');
    if (theater_settings == null) theater_settings = new Theater__c(Grouping__c='');
    
    Set<String> sales_division_mappings = new Set<String>(sales_division_settings.Grouping__c.split(';'));
    Set<String> theater_mappings = new Set<String>(theater_settings.Grouping__c.split(';'));

    for(Opportunity o: opps_to_update)
    {
      System.debug('Opp to update: ' + o);
      //Selects user information about the oppty owner
      User u = user_map.get(o.OwnerId);
      System.debug('User: ' + u);
      String ownerRole = NULL;
      if (u!=NULL && u.UserRole!=NULL)
      {
        ownerRole = u.UserRole.Name;
      } else {
        System.debug('Null user or userRole');
        continue;
      }
      System.debug('User Role: ' + ownerRole);
      //System.debug('Owner Role: ' + ownerRole);
      if (ownerRole == NULL)
      {
        //System.debug('Null User Role for User: ' + u);
        continue;
      }
      //Loops thru set of Sales Division values to find matching value
      for (String s: sales_division_mappings) 
      {
        if(ownerRole.contains(s)) 
        {
          o.Sales_Division__c = s;
          break;
        } 
      }
      //Loops thru set of Theater values to find matching value
      for (String t: theater_mappings) 
      {
        if(ownerRole.contains(t)) 
        {
          o.Theater__c = t;
          break;
        } 
      }
    }
  }
}