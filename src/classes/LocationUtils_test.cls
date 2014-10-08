@isTest
private class LocationUtils_test {
  
  /**
    * This method gives inputs to the LocationUtils_hlpr.determineLocation() method
    * that should be interpreted as US locations, thus all calls should return
    * LocationUtils_hlpr.US_COUNTRY.
    */
  static testMethod void determineLocationTestUS() 
  {
    List<String> us_strings = new String[]{'US','us','USA','United States','The United States of america'};
    List<String> result_strings = new List<String>();
    Test.startTest();
    for (String test_country_string : us_strings) 
    {
      String result = LocationUtils_hlpr.determineLocation(test_country_string);
      result_strings.add(result);
    }
    Test.stopTest();
    Integer number_of_results = result_strings.size();
    for (Integer index=0; index < number_of_results; index++)
    {
      String result_string = result_strings.get(index);
      String us_string = us_strings.get(index);
      System.assertequals(result_string,LocationUtils_hlpr.US_COUNTRY, 
        us_string + ' was not recognized as a valid string for the US');
    }  
  }
  
  /**
  * This method gives inputs to the LocationUtils_hlpr.determineLocation() method
  * that should be interpreted as US locations, thus all calls should return
  * LocationUtils_hlpr.NON_US_COUNTRY.
  */
  static testMethod void determineLocationTestInternational()
  {
    List<String> international_strings = new String[]{'China','Brussels','Trusa','Help us','United States of Canada'};
    List<String> result_strings = new List<String>();
    Test.startTest();
    for (String test_country_string : international_strings) 
    {
      String result = LocationUtils_hlpr.determineLocation(test_country_string);
      result_strings.add(result);
    }
    Test.stopTest();
    Integer number_of_results = result_strings.size();
    for (Integer index=0; index < number_of_results; index++)
    {
      String result_string = result_strings.get(index);
      String international_string = international_strings.get(index);
      System.assertequals(result_string,LocationUtils_hlpr.NON_US_COUNTRY, 
      international_string + ' was not recognized as a valid string for the International');
    }
  }
  
  /**
  * This method gives provides null and the empty string as inputs to determineLocation
  * they should always return LocationUtils_hlpr.INVALID_INPUT.
  */
  static testMethod void determineLocationTestInvalid()
  {
    String null_string = null;
    String empty_string = '';
    String whitespace_string = '  ';
    Test.startTest();
    String null_result = LocationUtils_hlpr.determineLocation(null_string);
    String empty_result = LocationUtils_hlpr.determineLocation(empty_string);
    String whitespace_result = LocationUtils_hlpr.determineLocation(whitespace_string);
    Test.stopTest();
    System.assertequals(null_result,LocationUtils_hlpr.INVALID_INPUT,
        'Null input did not produce INVALID_INPUT');
    System.assertequals(empty_result,LocationUtils_hlpr.INVALID_INPUT,
        'Empty string did not produce INVALID_INPUT');
    System.assertequals(whitespace_result,LocationUtils_hlpr.INVALID_INPUT,
        'Whitespace string did not produce INVALID_INPUT');
  }

  static testMethod void determineLocationByEmailTest()
  {
    // Case 1: Test null input
    String null_return_value = LocationUtils_hlpr.determineLocationByEmail(null);
    System.assertEquals(LocationUtils_hlpr.UNITED_STATES_COUNTRY_CODE, null_return_value);

    // Case 2: Japan email
    String jp_email = 'kyle@japan.jp';
    String jp_return_value = LocationUtils_hlpr.determineLocationByEmail(jp_email);
    System.assertEquals(LocationUtils_hlpr.JAPAN_COUNTRY_CODE, jp_return_value);

    // Case 3: US email
    String us_email = 'kyle@unitedStates.com';
    String us_return_value = LocationUtils_hlpr.determineLocationByEmail(us_email);
    System.assertEquals(LocationUtils_hlpr.UNITED_STATES_COUNTRY_CODE, us_return_value);
  }

    @isTest static void isPOBoxTest() {
        System.assert(LocationUtils_hlpr.isPOBox('PO Box'), 'PO Box is a po box');
        System.assert(LocationUtils_hlpr.isPOBox('PO Box #123'), 'PO Box #123 is a po box');
        System.assert(LocationUtils_hlpr.isPOBox('P.O. Box'), 'P.O. Box is a po box');
        System.assert(LocationUtils_hlpr.isPOBox('P.O   Box'), 'P.O Box is a po box');
        System.assert(LocationUtils_hlpr.isPOBox('p.O box'), 'p.O box is a po box');
        System.assert(!LocationUtils_hlpr.isPOBox('CO Box'), 'CO Box is not a po box');
        System.assert(!LocationUtils_hlpr.isPOBox('Box'), 'Box is not a po box');
    }

}