public with sharing class TestDataFactory_hlpr {
  
  private static final String ACCOUNT_BASE_NAME = 'Account_';
  private static final String QUOTE_SUFFIX = ' Quote';

  private static final String SIMPLE_SALES_DIVISION = 'Major';
  private static final String SIMPLE_THEATER = 'NATAM';
  private static final String SIMPLE_ALIAS = 'Kyle V';
  private static final String SIMPLE_EMAIL = 'testing@test.tst';

  private static Id SIMPLE_USER_ID = null;

  /**
  * Method: createOpportunities (public, static)
  * Description:
  *   This method creates Opportunities and their attached Accounts and Quotes.  All Opps
  *   are named with the basename provided plus an index number to differentiate them.
  *   These Opps will be inserted into the database and updated to include the Quotes.
  * Inputs:
  *   String basename - The base name for each Opp.
  *   Integer number_of_opps - The number of opps to be created.
  *   Integer number_of_accounts - The number of accounts to be created.
  *   Integer number_international - The number of the accounts that should be international.
  *   Integer number_of_quotes - The number of quotes that should be created.
  *   Date close_date - The close date that should be set for each Opp.
  * Return:
  *   List<Opportunity> - A list of newly created Opportunities with Accounts and Quotes.
  */  
  public static Set<ID> createOpportunities(String basename,
                                            Integer number_of_opps,
                                            Integer number_of_accounts,
                                            Integer number_international,
                                            Integer number_of_quotes,
                                            Date close_date,
                                            String initial_stage_name)
  {
    Id test_user_id = createUserSimple();
    List<Opportunity> new_opps = new List<Opportunity>();
    Set<ID> account_ids_set = createAccounts(ACCOUNT_BASE_NAME,number_of_accounts,number_international);
    List<ID> account_ids_list = new List<ID>();
    account_ids_list.addAll(account_ids_set);
    System.debug('Number of opps: ' + number_of_opps);
    for (Integer index=0; index < number_of_opps; index++)
    {
      // Evenly spread out opps amoung without every falling off the end of the list
      ID current_account_id = account_ids_list.get(math.mod(index,account_ids_list.size()));
      String opp_name = basename + String.valueOf(index);
      new_opps.add(new Opportunity(Name=opp_name,CloseDate=close_date,AccountID=current_account_id, 
                                       Stagename=initial_stage_name, OwnerID=test_user_id,Rep_Quota_Relief__c=true,
                                       Line_Of_Business_1__c='Buying Box is Great!'));
    }
    // Try to insert the opps
    try 
    {
      insert new_opps;
    } catch (DMLException e)
    {
      for (Integer i = 0; i < e.getNumDml(); i++) {
        // Process exception here
        System.debug(e.getDmlMessage(i)); 
      }
    }
    if (number_of_quotes > 0)
    {
      List<Quote> quotes = createQuotes(new_opps,number_of_quotes);
      // Try to update the opps
      try 
      {
        update new_opps;
      } catch (DMLException e)
      {
        for (Integer i = 0; i < e.getNumDml(); i++) {
          // Process exception here
          System.debug(e.getDmlMessage(i)); 
        }
      }
    }
    Map<ID,Opportunity> opp_map = new Map<ID,Opportunity>(new_opps);
    return opp_map.keyset();
  }

  /**
  * Method: createAccounts (private, static)
  * Description:
  *   This method creates Accounts and inserts them into the database.  All accounts
  *   will be named the basename provided plus an index number to differentiate them.
  *   The final parameter decides how many of the accounts will have an international
  *   address.
  * Inputs:
  *   String basename - The base name for each Account.
  *   Integer number_of_accounts - The total number of accounts to be created.
  *   Integer number_international - The number of the accounts created that should be international.
  * Return:
  *   Set<ID> - Set of IDs for recently created Accounts
  */
  public static Set<ID> createAccounts(String basename, 
                                             Integer number_of_accounts,
                                             Integer number_international)
  {
    Id test_user_id = createUserSimple();
    List<Account> new_accounts = new List<Account>();
    for (Integer index=0; index < number_of_accounts; index++)
    {
      String account_name = basename + String.valueOf(index);
      Account new_account = new Account(name=account_name,OwnerID=test_user_id);
      // Only create a certain number of international Accounts
      if (index < number_international) {
        new_account.BillingCountry = 'United Kingdom';
      } else {
        new_account.BillingCountry = 'USA';
      }
      // Setting the Billing Street because if Billing Street is not set, quotes get contact info instead
      new_account.BillingStreet = '100 Way Lane';
      new_accounts.add(new_account);
    }
    // Attempt to insert the accounts
    try 
    {
      insert new_accounts;
    } catch (DMLException e)
    {
      for (Integer i = 0; i < e.getNumDml(); i++) {
        // Process exception here
        System.debug(e.getDmlMessage(i)); 
      }
    }
    Map<ID,Account> account_map = new Map<ID,Account>(new_accounts);
    return account_map.keySet();
  }
  
  /**
  *  method: createQuotes (private, static)
  *  Description:
  *   This method creates Quotes for the Opportunities provided in the opp_list argument.  These Quotes
  *   are then inserted into database.  The Opportunities have their Live_Quote__c field set, but are not
  *   updated via DML.  IMPORTANT: Curently does not add any Products.
  *  Inputs:
  *   List<Opportunity> opp_list - The list of opportunities the quotes are created on.
  *   Integer number_of_quotes - The number of quotes you want to create.  If this number is
  *                               greater than the number of opps in opp_list, some Opportunities
  *                               will have more than one Quote.
  *  Return:
  *   List<Quote> - Contains the Quotes that were just created and inserted into the database.
  */
  private static List<Quote> createQuotes(List<Opportunity> opp_list, Integer number_of_quotes)
  {
    List<Quote> new_quotes = new List<Quote>();
    // Create new Quotes and add them to the new_quotes list
    for (Integer index=0; index < number_of_quotes; index++)
    {
      // This line just makes sure we continually loop through the Opp list, but never fall off the end
      Opportunity current_opp = opp_list.get(math.mod(index,opp_list.size()));
      new_quotes.add(new Quote(Name=current_opp.name + QUOTE_SUFFIX, OpportunityID=current_opp.Id));
    }
    // Attempt to insert them into the database
    try 
    {
      insert new_quotes;
    } catch (DMLException e)
    {
      for (Integer i = 0; i < e.getNumDml(); i++) {
        // Process exception here
        System.debug(e.getDmlMessage(i)); 
      }
    }
    // Create a Map from Opp Ids to Opps, use to easily find Opps based on Ids
    Map<ID,Opportunity> opp_map = new Map<ID,Opportunity>(opp_list);

    // For each quote, add the quote as it's Opp's Live_Quote__c
    for (Quote quote : new_quotes)
    {
      Opportunity opp_for_quote = opp_map.get(quote.OpportunityID);
      if (opp_for_quote!=null)
      {
        opp_for_quote.Live_Quote__c = quote.Id;
      } else
      {
        System.debug('Trouble.  Opp for Opp Id on Quote: ' + quote + ' not in Opp Map');
      }
    }
    return new_quotes;
  }

  public static Id createUser(String sales_division, String theater, String alias, String email)
  {
    User sys_admin = [SELECT Id, ProfileId 
                      FROM User
                      WHERE Alias='kverm' LIMIT 1];
    User new_user = null;
    System.runAs(sys_admin)
    {
      String sales_division_safe = String.escapeSingleQuotes(sales_division);
      String theater_safe = String.escapeSingleQuotes(theater);
      try 
      {
        String roleName = sales_division_safe + ' - ' + theater_safe;
        UserRole role = new UserRole(Name = roleName);
        insert role;
        //Database.query('SELECT Id FROM UserRole WHERE Name Like \'%' + sales_division_safe +  '%\' AND Name Like \'%' + theater_safe + '%\' LIMIT 1');
        new_user = new User(Alias=alias,Email=email,EmailEncodingKey='UTF-8',LanguageLocaleKey='en_US',
        LastName='V',LocaleSidKey='en_US',ProfileId=sys_admin.ProfileId,TimeZoneSidKey='America/Los_Angeles',
        UserName=email,UserRoleId=role.Id);
        insert new_user;
      } catch (System.QueryException e)
      {
        System.debug('Query Error in TestDataFactory_hlpr.createUser()');
        System.debug('Query Error: ' + e);
        return null;
      } catch (DMLException e)
      {
        System.debug('DML Exception in TestDataFactory_hlpr.createrUser()');
        System.debug('Query Error: ' + e);
      }
    }
    return new_user.Id;
  }

  public static Id createUserSimple()
  {
    if (SIMPLE_USER_ID == null)
    {
      String sales_division = SIMPLE_SALES_DIVISION;
      String theater = SIMPLE_THEATER;
      String alias = SIMPLE_ALIAS;
      String email = SIMPLE_EMAIL;
      SIMPLE_USER_ID = createUser(sales_division,theater,alias,email);
    }
    return SIMPLE_USER_ID;
  }
}