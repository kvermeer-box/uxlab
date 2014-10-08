/**
 * This class updates the Billing_Country_Classification__c on closed won ops for accounting.
 *
 * @author Kyle Vermeer ?
 * @revision Kyle Vermeer 6/13/14 Transition to ZQuotes
 */
public class OpportunityClosedWonUpdate_trgr {

  public static final String CLOSED_WON = 'Closed Won';

  /*
  * This is a helper class for figuring storing information about
  * which Opps are Closed Won.
  */
  private class ClosedWonOpportunityResult {

    private Map<ID,Opportunity> opp_map;

    private List<ID> quote_ids;
    private List<ID> opp_with_no_quote_ids;

    private List<ID> account_for_opp_with_no_quote_ids;

    public ClosedWonOpportunityResult() {
      this.quote_ids = new List<ID>();
      this.opp_with_no_quote_ids = new List<ID>();
      this.account_for_opp_with_no_quote_ids = new List<ID>();
      this.opp_map = new Map<ID,Opportunity>();
    }

    public void addQuoteId(ID new_quote_id)
    {
      this.quote_ids.add(new_quote_id);
    }

    public void addOppWithNoQuote(Opportunity opp)
    {
      this.opp_with_no_quote_ids.add(opp.Id);
      this.account_for_opp_with_no_quote_ids.add(opp.AccountId);
      this.opp_map.put(opp.Id,opp);
    }

    public List<ID> getQuoteIDs()
    {
      return this.quote_ids;
    }

    public List<ID> getOppIDs()
    {
      return this.opp_with_no_quote_ids;
    }

    public List<ID> getAccountIDsForOppsWithNoQuote()
    {
      return this.account_for_opp_with_no_quote_ids;
    }

    public Opportunity getOpp(ID opp_id)
    {
      return this.opp_map.get(opp_id);
    }

    public List<Opportunity> getAllOpps()
    {
      return this.opp_map.values();
    }

    public Map<Id,Opportunity> getOppMap()
    {
      return this.opp_map;
    }

    public void addOpp(Opportunity opp)
    {
      this.opp_map.put(opp.Id,opp);
    }
  }

  /**
  * function: updateBillingCountryClassification (public, static)
  * Description:
  *   This function updates the Billing Country Classification on all Opps that are
  *   about to be updated and are having their StageName set to 'Closed Won'.
  * Inputs:
  *   Map<Id,Opportunity> new_opps_map - Trigger.new
  *   Map<Id,Opportunity> old_opps_map - Trigger.old
  * Return:
  *   None
  */
  public static void updateBillingCountryClassification(Map<ID,Opportunity> new_opps_map,
                                                        Map<ID,Opportunity> old_opps_map)
  {
    // Get new opps
    List<Opportunity> new_values = new_opps_map.values();
    
    // Init a List for Opportunities that have no live quotes
    ClosedWonOpportunityResult closed_won_results = findOppsChangedToClosedWon(old_opps_map,new_opps_map);
    updateBillingCountryClassificationForOpps(closed_won_results,closed_won_results.getOppMap());
  }

  /**
  * function: insertBillingCountryClassification (public, static)
  * Description:
  *   This function updates the Billing Country Classification on all Opps that are
  *   inserted with their StageName set to 'Closed Won'.
  * Inputs:
  *   List<Opportunity> new_opps - A list of the newly created Opportunities
  * Return:
  *   None
  */
  public static void insertBillingCountryClassification(List<Opportunity> new_opps)
  {
    Set<ID> account_ids = new Set<ID>();
    Set<Opportunity> opp_set = new Set<Opportunity>();
    // Grabs all opps that are 'Closed Won'
    for (Opportunity cur_opp : new_opps)
    {
      if (cur_opp.StageName == CLOSED_WON) {
        account_ids.add(cur_opp.AccountId);
        opp_set.add(cur_opp);
      }
    }
    Map<ID,Account> accounts_map = new Map<ID,Account>([SELECT Id, BillingCountry 
                                                        FROM Account 
                                                        WHERE Id in :account_ids]);
    // Update Billing Country Classification for all 'Closed Won' opps
    for (Opportunity cur_opp : opp_set)
    {
      if (cur_opp.AccountId != null)
      {
        Account account = accounts_map.get(cur_opp.AccountId);
        String country_classification = LocationUtils_hlpr.determineLocation(account.BillingCountry);
        if (!String.isBlank(country_classification))
        {
          cur_opp.Billing_Country_Classification__c = country_classification;
        } else {
          System.debug('No Quote or Account Billing Country for Opp :' + cur_opp.Id);
        }
      } else System.debug('No Account for Opp');
    }
  }
    

  /**
  * function: findOppsChangedToClosedWon (private, static)
  * Description:
  *   This function returns a ClosedWonOpportunityResult that contains all the information related
  *   to any Opp with their StageName changed to 'Closed Won'.  It gathers the IDs of quotes that
  *   need to be used to update the Billing Country Classification, as well as the IDs of opps
  *   that don't have a live quote and their associated account IDs.
  * Inputs:
  *   Map<ID,Opportunity> old_opps_map - Trigger.oldMap, old opp map
  *   Map<ID,Opportunity> new_opps_map - Trigger.newMap, new opp map
  * Return:
  *   ClosedWonOpportunityResult - Contains quote IDs, Opp IDs for opps with no quotes, and Account
  *                                 IDs for accounts associated with the opps that have no quotes.
  */
  private static ClosedWonOpportunityResult findOppsChangedToClosedWon(final Map<ID,Opportunity> old_opps_map,
                                                                            final Map<ID,Opportunity> new_opps_map)
  {
      // Init our ClosedWonOpportunityResult
      ClosedWonOpportunityResult result = new ClosedWonOpportunityResult();
      List<Opportunity> opps = new_opps_map.values();
      // Loop through opps, find the ones that have their StageName changed to CLOSED_WON
      for (Opportunity new_opp: opps) {
         Opportunity old_opp = old_opps_map.get(new_opp.id);
         if (new_opp.StageName == CLOSED_WON &&
             old_opp.StageName != CLOSED_WON)
         {
              System.debug('Live ZQuote: ' + new_opp.Live_ZQuote__c);
             // If changed to CLOSED WON, add to list to get quote, otherwise get to list for account
             if (new_opp.Live_ZQuote__c != null) 
             {
              result.addQuoteId(new_opp.Live_ZQuote__c);
              result.addOpp(new_opp);
             }
             else {
                result.addOppWithNoQuote(new_opp);
             }    
         }     
      }
      return result;
  }

  /**
  * function: updateBillingCountryClassificationForOpps (private, static)
  * Description:
  *   This function takes a ClosedWonOpportunityResult that has previously parsed
  *   the trigger inputs to determine which Opps were changed to 'Closed Won' and
  *   which had live quotes.  Using that ClosedWonOpportunityResult object, this
  *   method first tries to updates the Billing Country Classification field on
  *   these Opps based on the live quotes's Billing Country.  If this does not
  *   work, these opps are added to the group of opps that will have their
  *   Billing Country Classification field populated based on the Opp's Account's
  *   Billing Country.  Does NOT call the DML update on the Opps.
  * Inputs:
  *   ClosedWonOpportunityResult closed_won_results - Contains pre-parsed Opp data from the Trigger
  *   Map<ID,Opportunity> new_opps_map - Trigger.newMap, new opp map
  * Return:
  *   None
  */
  private static void updateBillingCountryClassificationForOpps(ClosedWonOpportunityResult closed_won_results,
                                                                Map<ID,Opportunity> new_opps_map)
  {
    // Get all the Quotes whose IDs we gathered
    Map<ID,zqu__Quote__c > live_quotes_map = new Map<ID,zqu__Quote__c>([SELECT Id, zqu__BillToContact__r.MailingCountry,
                                                                        zqu__BillToContact__c
                                                               FROM zqu__Quote__c
                                                               WHERE Id in :closed_won_results.getQuoteIDs()]);
       
    // For each quote, update its opp's Billing Country Classification
    for (Opportunity opp : new_opps_map.values())
    {
      // If live quote is null, skip it.
      if (opp.Live_ZQuote__c == null) continue; 
      // Can't just use map, quotes opp could be different.  Need to look through list of opps
      zqu__Quote__c current_quote = live_quotes_map.get(opp.Live_ZQuote__c);
      // Don't accept blank values
      if (current_quote.zqu__BillToContact__c != null && !String.isBlank(current_quote.zqu__BillToContact__r.MailingCountry))
      {
        String country_classification = LocationUtils_hlpr.determineLocation(current_quote.zqu__BillToContact__r.MailingCountry);
        opp.Billing_Country_Classification__c = country_classification;
      } else {
        // If Billing Country blank, act as if there were no quote
        closed_won_results.addOppWithNoQuote(opp);
      }
    }
    
    Map<ID,Account> accounts_map = new Map<ID,Account>([SELECT Id, BillingCountry 
                                                        FROM Account 
                                                        WHERE Id in :closed_won_results.getAccountIDsForOppsWithNoQuote()]);
    // For the Opps with not Quote, populate the field based on the Account's Billing Country
    for (Id opp_Id : closed_won_results.getOppIDs())
    {
      Opportunity opp = closed_won_results.getOpp(opp_Id);
      if (opp.AccountId != null) {
        Account account = accounts_map.get(opp.AccountId);
        String country_classification = LocationUtils_hlpr.determineLocation(account.BillingCountry);
        if (!String.isBlank(country_classification))
        {
          opp.Billing_Country_Classification__c = country_classification;
        } else {
          System.debug('No Quote or Account Billing Country for Opp :' + opp.Id);
        }
      } else System.debug('No Account for Opp');
    }
  }
}