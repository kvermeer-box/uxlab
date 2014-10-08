public class AccountUpdateSalesDivision_trgr {
  public AccountUpdateSalesDivision_trgr() {}

  public static void updateSalesDivisionAndTheater(boolean is_insert, Map<ID,Account> old_map, List<Account> new_values)
  {
    // Decide opps to update, then update them
    List<Account> accounts_to_update = decideOppsToUpdate(is_insert, old_map, new_values);
    updateOpps(accounts_to_update);
  }

  private static List<Account> decideOppsToUpdate(boolean is_insert, Map<ID,Account> old_map, List<Account> new_values)
  {
    return new_values;
    // Would prefer to only check those who's ownerID has changed, but lead conversion bugs prevent this
    /*
    List<Account> accounts_to_update = new List<Account>();
    if (is_insert) accounts_to_update = new_values;
    else
    {
      // If this is an update, only get opps whose OwnerId has changed
      List<Account> changed_accounts = new List<Account>();
      for (Account new_account : new_values)
      {
        Account old_account = old_map.get(new_account.Id);
        if (old_account.OwnerId != new_account.OwnerId || new_account.Sales_Division__c == null || new_account.Theater__c == null)
        {
          changed_accounts.add(new_account);
        }
      }
      accounts_to_update = changed_accounts;
    }
    return accounts_to_update;
    */
  }

  private static void updateOpps(List<Account> accounts_to_update)
  {
  
    // Grab custom settings
    SalesDivision__c sales_division_settings = CustomSettings.getSalesDivisionSettings('Mappings');
    Theater__c theater_settings = CustomSettings.getTheaterSettings('Mappings');
    Set<String> sales_division_mappings = new Set<String>(sales_division_settings.Grouping__c.split(';'));
    Set<String> theater_mappings = new Set<String>(theater_settings.Grouping__c.split(';'));

    Set<Id> ownerIds = new Set<Id>();

    for(Account cur_account: accounts_to_update)
    {
      ownerIds.add(cur_account.ownerId);
    }
    Map<ID, User> user_map = new Map<ID, User>([SELECT Id, UserRole.Name 
                                                  FROM User 
                                                 WHERE Id IN :ownerIds]);
    for(Account cur_account: accounts_to_update)
    {
      User u = user_map.get(cur_account.OwnerId);
      String ownerRole = NULL;
      if (u!= NULL && u.userRole!=NULL)
      {
        ownerRole = u.userRole.Name;
      } else {
        System.debug('Null user or user role!');
        continue;
      }
      if (ownerRole == NULL)
      {
        continue;
      }
      //Loops thru set of Sales Division values to find matching value
      for (String s: sales_division_mappings) 
      {
        if(ownerRole.contains(s)) 
        {
          cur_account.Sales_Division__c = s;
          break;
        } 
      }
      //Loops thru set of Theater values to find matching value
      for (String t: theater_mappings) 
      {
        if(ownerRole.contains(t)) 
        {
          cur_account.Theater__c = t;
          break;
        } 
      }
    }
  }
}