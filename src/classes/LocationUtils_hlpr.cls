/**
 * Utility methods for addresses and locations
 *
 * @author Kyle Vermeer
 * @revision Kyle Vermeer 5/12/14 Added isPOBox
 */
public class LocationUtils_hlpr {
  
  public LocationUtils_hlpr() {}

  /* Static Return Values */
  public static final String US_COUNTRY = 'US';
  public static final String NON_US_COUNTRY = 'NON-US';
  public static final String INVALID_INPUT = 'INVALID_INPUT';

  /* Email Constants */
  public static final String EMAIL_ENDING_JAPAN = '.jp';

  /* Country Code Constants */
  public static final String JAPAN_COUNTRY_CODE = 'Japan';
  public static final String UNITED_STATES_COUNTRY_CODE = 'US';
  
  /* Regular Expressions */
  public static final String US_REGEX = '(^(?i)USA?$)|(^(?i)(The )?United States($| of America$))|(^(?i)US of A$)';
  private static final String PO_BOX_REGEX = '^(?i) *p\\.? *o\\.? *box.*';
  
  /**
  * This function returns a value that standardizes the value given by
  * country_string.  The possible return values are specificied in the
  * 'Static Return Value' section.
  */
  public static String determineLocation(String country_string)
  {
    if (String.isBlank(country_string)) 
    {
      return INVALID_INPUT;
    }
    LocationSettings__c location_settings = CustomSettings.getLocationSettings('default');
    if (location_settings==null || location_settings.US_Country_Names__c == null) 
    {
      return INVALID_INPUT;
    }
    List<String> us_values = location_settings.US_Country_Names__c.split(';');
    for (String sentinel_us_value : us_values)
    {
      if (sentinel_us_value == country_string)
      {
        return US_COUNTRY;
      }
    }
    return NON_US_COUNTRY;
  }

  /**
  * Method: determineLocationByEmail
  * Availability: public, static
  * Description:
  *   This function determines what country an e-mail is from, and returns the country code.
  *   If it is passed or null input or can't find a corresponding country, it returns a
  *   value for the United States.
  * Inputs:
  *   String email - The email for which we are interested to determine the country
  * Return:
  *   String       - The country that the e-mail represents.  Pontential values are listed
  *                   as constants on this class.
  */
  public static String determineLocationByEmail(String email)
  {
    // Check for null
    if (email == null)
      // If null, default US
      return UNITED_STATES_COUNTRY_CODE;
    // Check for Japan
    else if (email.endsWithIgnoreCase(EMAIL_ENDING_JAPAN)) 
      return JAPAN_COUNTRY_CODE;
    // Default US
    else return UNITED_STATES_COUNTRY_CODE;
  }

    /**
     * Determines if the address is a PO Box
     *
     * @param {String} streetAddress - address to check for po box
     * @return {Boolean} - true if address is a po box, false otherwise
     */
    public static Boolean isPOBox(String streetAddress) {
        if (streetAddress == null) { // check for null input
            return false;
        }
        Pattern poBoxPattern = Pattern.compile(PO_BOX_REGEX);
        Matcher poBoxMatcher = poBoxPattern.matcher(streetAddress);
        return poBoxMatcher.matches();
    }
}