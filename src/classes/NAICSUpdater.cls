/**
* Class: NAICSUpdater
* Description:
*   This class updates NAICS related fields on accounts based on the Primary_NAICS__c.  The web callout is done in
*   a future context, as web-callouts can not be made in a Trigger context, which is where these methods
*   will most commonly be called.
* Public API:
*   static void updateNAICSFields(Boolean isInsert, Map<Id,Account> oldAccounts, List<Account> newAccounts)
*   @future static void futureUpdateNAICSFields(Set<Id> accountIds)
*   static void updateNAICSFields(Set<Id> accountIds)
* Change Log:
*   Kyle Vermeer    12/26/2013        Initial Creation
*   Kyle Vermeer     1/8/2013         Added support for the known 2 digit ranges
*   Alan Young       7/7/2014         Removed NAICSCode and NaicsDesc after cancelling data.com
*/

public class NAICSUpdater {

  private static final String JSON_CODE_FIELD_NAME = 'code'; 
  private static final String JSON_TITLE_FIELD_NAME = 'title';
  private static final String NAICS_API_URL = (CustomSettings.getExternalServicesSettings('default') != null) ? CustomSettings.getExternalServicesSettings('default').NAICS_API_URL__c : 'http://naics.us/v0/q';
  private static final String NAICS_YEAR = (CustomSettings.getExternalServicesSettings('default') != null) ? CustomSettings.getExternalServicesSettings('default').NAICS_Year__c : '2012';

  private static final String WEB_REQUEST_FAILURE_TEXT = 'Trouble Reaching out to the NAICS server';
  private static final String DML_EXCEPTION_TEXT = 'Trouble updating accounts!';
  
  /**
  * Method: updateNAICSFields
  * Availability: public, static
  * Description:
  *   This method should be called by a trigger to update the NAICS fields on accounts that have had their
  *   NAICS code field changed.  This function will filter accounts to make sure to only process those
  *   that have had their NAICS code changed.
  * Inputs:
  *   Boolean isInsert             - is this an insert trigger?
  *   Map<Id,Account> oldAccounts  - Trigger.oldMap
  *   List<Account> newAccounts    - Trigger.new
  * Return:
  *   None
  **/ 
  public static void updateNAICSFields(Boolean isInsert, Map<Id,Account> oldAccounts, List<Account> newAccounts) {
  	
    // If it is an insert, just have it picked up in the batch job
    if (isInsert) {
      for (Account curAccount : newAccounts) {
        // Only records with something in the Primary_NAICS__c field
        if (curAccount.Primary_NAICS__c != null) {
          curAccount.updateNAICSFields__c = true;
        }        
      }
    }
    // Otherwise, only update accounts that have had their Primary_NAICS__c field changed 
    else {
      Set<Id> accountsToUpdateIds = new Set<Id>();
      for (Account curAccount : newAccounts) {
        Account oldAccount = oldAccounts.get(curAccount.Id);
        // If Primary_NAICS__c changed, add to set to be updated
        if (curAccount.Primary_NAICS__c != oldAccount.Primary_NAICS__c) {
          accountsToUpdateIds.add(curAccount.Id);
        }
      }
      // If size == 1 , process now
      if (accountsToUpdateIds != null && accountsToUpdateIds.size() == 1) {
        futureUpdateNAICSFields(accountsToUpdateIds);
      }
      // If more than 1, have the processed by batch 
      else if (accountsToUpdateIds != null && accountsToUpdateIds.size() > 1) {
        for (Account curAccount : newAccounts) {
          if (accountsToUpdateIds.contains(curAccount.Id)) {
            curAccount.updateNAICSFields__c = true;
          }
        }
      }
    }
    
  }

  /**
  * Method: futureUpdateNAICSFields
  * Availability: public, static
  * Description:
  *   This method can be called on any list of Accounts and it will update their NAICS fields.
  * Inputs:
  *   Set<Account> accounts  - List of Accounts to have their NAICS fields updated
  * Return:
  *   None
  **/
  @future(callout=true)
  public static void futureUpdateNAICSFields(Set<Id> accountIds) {
    updateNAICSFields(accountIds);
  }
  
  /**
  * Method: updateNAICSFields
  * Availability: public, static
  * Description:
  *   This method can be called on any list of Accounts and it will update their NAICS fields.
  * Inputs:
  *   Set<Account> accounts  - List of Accounts to have their NAICS fields updated
  * Return:
  *   None
  **/
  public static void updateNAICSFields(Set<Id> accountIds) {
  	
    List<Account> accounts = [SELECT Id, Primary_NAICS__c, Industry_2_Digit_NAICS_Code__c,
                                     Industry_4_Digit_NAICS_Code__c, Industry_5_Digit_NAICS_Code__c,
                                     updateNAICSFields__c
                              FROM Account
                              WHERE Id in :accountIds];
    // If null, abort
    if (accounts == null) {
      System.debug('No results returned for NAICS account query...');
      return;
    }
    // Otherwise, make a callout for each account, or null fields out if Naics was set to null
    for (Account curAccount : accounts)
    {
      // If blank (or null), null out all the fields
      if (curAccount.Primary_NAICS__c == null)
      {
        curAccount.Industry_2_Digit_NAICS_Code__c = null;
        curAccount.Industry_4_Digit_NAICS_Code__c = null;
        curAccount.Industry_5_Digit_NAICS_Code__c = null;
        curAccount.updateNAICSFields__c = false;
      } else {
        NAICSResponse responseObject = getNAICSCodeInfoFromAPI(curAccount);
        if (responseObject == null) {
          
        } else {
          updateAccountWithNAICSResponseObject(curAccount, responseObject);
          curAccount.updateNAICSFields__c = false;
        }
      }
    }

    // Update or insert the accounts
    try {
      upsert accounts;
    } catch (DmlException e) {
      List<Id> failedAccountIds = new List<Id>();
      for (Account curAccount : accounts) {
        if (curAccount.Id != null) {
          failedAccountIds.add(curAccount.Id);
        }
      }
      throw new LoggedException(e, DML_EXCEPTION_TEXT, 'NAICSUpdater', failedAccountIds);
    }
    
  }

  @TestVisible
  private static NAICSResponse getNAICSCodeInfoFromAPI(Account curAccount) {
    NAICSResponse responseObject = null;
    if (!Test.isRunningTest()) {
      // If not running Test, Create Request, Send, and Create NAICSResponse from response body
      HttpRequest req = new HttpRequest();
      // Makes sure we get the current code, not ONLY parents
      String naicsCodeWithBuffer = curAccount.Primary_NAICS__c + '0';
      String url = NAICS_API_URL + '?year=' + NAICS_YEAR + '&code=' + naicsCodeWithBuffer + '&above=1';
      req.setEndpoint(url);
      req.setMethod('GET');

      String responseBody = null;
      // Send request and get response
      try {
        Http httpObject = new Http();
        HttpResponse res = httpObject.send(req);
        responseBody = res.getBody();
      } catch (Exception e) {
        // Don't want to throw exception... done in a future context
        LoggedException logE = new LoggedException(e, WEB_REQUEST_FAILURE_TEXT, 'NAICSUpdater', new List<String> {curAccount.Id});
      }
      
      responseObject = new NAICSResponse(responseBody);
    } else {
      // Just create null response if its a test
      // IF TESTING MUST TEST THIS, CHANGE THIS VALUE
      responseObject = new NAICSResponse(DynamicTestValues.getNaicsJSONResponse());
    }
    return responseObject;
  }

  private static void updateAccountWithNAICSResponseObject(Account curAccount, NAICSResponse responseObject) {
    // Avoid null input
    if (responseObject == null) {
      System.debug('Response Object received was null!');
      return;
    }
    // Populate each code field with the appropriate title
    for (Integer curCode : responseObject.getAllCodes()) {
      NAICSObject curObject = responseObject.getObjectForCode(curCode);
      if (curObject == null) {
        // NO OBJECT FOR KEY...
        continue;
      }
      // Fill in appropriate field depending on code length
      if (curObject.getCodeLength() == 2) {
        String twoDigitCodeTitle = getNameIfCodeInRange(curObject.getCode());
        if (twoDigitCodeTitle == null) {
          twoDigitCodeTitle = curObject.getTitle();
        }
        curAccount.Industry_2_Digit_NAICS_Code__c = twoDigitCodeTitle;
      } else if (curObject.getCodeLength() == 4) {
        curAccount.Industry_4_Digit_NAICS_Code__c = curObject.getTitle();
      } else if (curObject.getCodeLength() == 5) {
        curAccount.Industry_5_Digit_NAICS_Code__c = curObject.getTitle();
      }
    }
    
  }

  private static String getNameIfCodeInRange(Integer code) {
    if (code >= 31 && code <= 33) {
      return 'Manufacturing';
    } 
    else if (code >= 44 && code <= 45) {
      return 'Retail Trade';
    } 
    else if (code >= 48 && code <= 49) {
      return 'Transportation and Warehousing';
    } 
    else {
      return null;
    }
  }
  
  
  /**
  * Class: NAICSObject
  * Description:
  *   This class is used to hold information about an NAICS code.  This object is populated by
  *   deserializing JSON, so be cognizant when changing the field names.
  * Public API:
  *   Integer getCode()
  *   Integer getCodeLength()
  *   String getTitle()
  **/
  
  @TestVisible
  private class NAICSObject {

    private Integer code;
    private Integer codeLength = null;
    private String title;

    public void setCode(Integer code) {
      this.code = code;
      String codeAsString = string.valueOf(code);
      this.codeLength = codeAsString.length();
    }

    public Integer getCode() {
      return this.code;
    }

    public Integer getCodeLength() {
      String codeAsString = string.valueOf(this.code);
      this.codeLength = codeAsString.length();
      return this.codeLength;
    }

    public void setTitle(String title) {
      this.title = title;
    }

    public String getTitle() {
      return this.title;
    }

  }
  
  /**
  * Class: NAICSResponse
  * Description:
  *   This class acts much like a Map from Naics code to NAICSObjects that contain
  *   information for that code.  The constructor takes care of parsing the JSON into
  *   NAICSObjects for the map.
  **/
  
  @TestVisible
  private class NAICSResponse {

    public Map<Integer,NAICSObject> codeToNAICSObjectMap;
    private Integer longestCodeLength = 0;
    private Integer longestCode = null;

    public NAICSResponse(String jsonString) {
      codeToNAICSObjectMap = new Map<Integer, NAICSObject>();
      // Try to parse response
      if (jsonString!= null) {
        try {
          parseJSONResponse(jsonString);
        } catch (Exception e) {
          LoggedException logE = new LoggedException(e, 'Issue parsing: ' + jsonString, 'NAICSUpdater', null);
        }
      }
    }

    public NAICSObject getObjectForCode(Integer code) {
      return codeToNAICSObjectMap.get(code);
    }

    public Set<Integer> getAllCodes() {
      return codeToNAICSObjectMap.keySet();
    }

    public Integer getLongestCodeLength() {

      return this.longestCodeLength;
    }

    public Integer getLongestCode() {
      return this.longestCode;
    }

    public void putObject(NAICSObject newNAICSObject) {
      // Place object into map, if it has the largest code so far, update longest code
      this.codeToNAICSObjectMap.put(newNAICSObject.getCode(),newNAICSObject);
      if (newNAICSObject.getCodeLength() > this.getLongestCodeLength()) {
        this.longestCodeLength = newNAICSObject.getCodeLength();
        this.longestCode = newNAICSObject.getCode();
      }
    }

    private void parseJSONResponse(String jsonString) {
      System.debug('JSON: ' + jsonString);
      JSONParser parser = JSON.createParser(jsonString);
      System.debug('First token: ' + parser.getCurrentToken());
      parser.nextToken();
      while (parser.getCurrentToken() != null) {
        System.debug('Current Token: ' + parser.getCurrentToken());
        if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
          parser.nextToken();
        } 
        if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
          parseJSONObject(parser);
        } else {
          parser.nextToken();
        }
      }
    }

    private void parseJSONObject(JSONParser parser)
    {
      // Deserialize json into NAICSObject
      NAICSObject curNAICSObject = (NAICSObject)parser.readValueAs(NAICSObject.class);
      this.putObject(curNAICSObject);
      parser.nextToken();
    }
  }
  
}