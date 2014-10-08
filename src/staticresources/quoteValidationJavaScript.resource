function isUnitedStates(country_string)
{
	var USA_pattern = "(^US$|^USA$|United States$|United States of America$|^US of A$|Guam|Northern Mariana Islands|Puerto Rico|United States Virgin Islands)";
	var USA_regex = new RegExp(USA_pattern,"i");
	return USA_regex.test(country_string);
}

function getTemplateId(quote_type, is_discounted, country_string) 
{

    // If country_string is empty, default to USA
    if (country_string === "") country_string = "United States";

    /**
     *
     * C H A N G E
     * T E M P L A T E S
     * H E R E ! ! ! ! ! ! ! ! 
     *
     */
    // Template IDs
    var new_agreement_nondiscounted_us_template_id = "a2A600000004FKZ";
    var new_agreement_nondiscounted_international_template_id = "a2A600000004FKe";
    var new_agreement_discounted_us_template_id = "a2A600000004FKj";
    var new_agreement_discounted_international_template_id = "a2A600000004FKo";
    
    // Upsells have no BSA or location info, same for domestic and international
    var upsell_nondiscounted_us_template_id = "a2A600000004FKt";
    var upsell_nondiscounted_international_template_id = "a2A600000004FKt";
    var upsell_discounted_us_template_id = "a2A600000004FKy";
    var upsell_discounted_international_template_id = "a2A600000004FKy";

    if (quote_type === "New Agreement" || quote_type === null || quote_type === "")
    {
    	// Is a new agreement
    	// NOTE: find out type of isDiscounted
    	if (is_discounted != 1)
    	{
    		// Is discounted
    		if (isUnitedStates(country_string))
    		{
    			// Is a US company
    			return new_agreement_discounted_us_template_id;
    		} else
    		{
    			// International Company
    			return new_agreement_discounted_international_template_id;
    		}
    	} else {
    		// Is not discounted
    		if (isUnitedStates(country_string))
    		{
    			// Is a US company
    			return new_agreement_nondiscounted_us_template_id;
    		} else
    		{
    			// International Company
    			return new_agreement_nondiscounted_international_template_id;
    		}
    	}

    } else
    {
    	// Is an upsell
    	if (is_discounted != 1)
    	{
    		// Is discounted
    		if (isUnitedStates(country_string))
    		{
    			// Is a US company
    			return upsell_discounted_us_template_id;
    		} else
    		{
    			// Is an international company
    			return upsell_discounted_international_template_id;
    		}
    	} else
    	{
    		// Is not discounted
    		if (isUnitedStates(country_string))
    		{
    			// Is a US company
    			return upsell_nondiscounted_us_template_id;
    		} else
    		{
    			// Is an international company
    			return upsell_nondiscounted_international_template_id;
    		}
    	}
    }
}

/*****
Returns an object with the following properties:
  error_messages : An Array of strings with the missing components for a valid quote.
  is_valid : A boolean that is true if the quote is a valid quote, false otherwise
  is_domestic : A boolean that is true if the quote has a domestic billing address, false otherwise
*****/
function checkForValidAddress(country_string, street_string, city_string, state_string, zip_string)
{
    var error_object = new Object();
    error_object.error_messages = new Array();
    error_object.is_valid = true;
    error_object.is_domestic = false; // Initialize just to have a non-null value

    // Universally Required Parameters
	if (!country_string) error_object.error_messages.push("Billing Country");
	if (!street_string) error_object.error_messages.push("Billing Steet");
	if (!city_string) error_object.error_messages.push("Billing City");

    // If any errors so far, return the error object
	if (error_object.error_messages.length !== 0)
	{
		error_object.is_valid = false;
        return error_object;
	}

    // If the address is domestic, test for state and zip
    if (isUnitedStates(country_string))
    {
        error_object.is_domestic = true;
        if (!state_string) error_object.error_messages.push("Billing State");
        if (!zip_string) error_object.error_messages.push("Billing Zip");
    } else error_object.is_domestic = false;

    if (error_object.error_messages.length !== 0) error_object.is_valid = false;

    return error_object;
}

/* Test Functions */
function testIsUnitedStates()
{
    var acceptable_value_list = ["US","uS","usa","United States","United States of america", "us of a","The United States of America", "The United States"];
    console.log("List of acceptable values being tested: " + acceptable_value_list);
    var acceptable_values_len = acceptable_value_list.length;
    for (var index = 0; index < acceptable_values_len; index++)
    {
        var acceptable_value = acceptable_value_list[index];
        if (!isUnitedStates(acceptable_value)) 
        {
            console.log("Acceptable value: " +acceptable_value + " was rejected.");
            return false;
        }
    }

    var unacceptable_value_list = ["China","Brussels","Trusa","Help us","United States of Canada"];
    console.log("List of unacceptable values being tested: " + unacceptable_value_list);
    var unacceptable_value_len = unacceptable_value_list.length;
    for (var index = 0; index < unacceptable_value_len; index++)
    {
        var unacceptable_value = unacceptable_value_list[index];
        if (isUnitedStates(unacceptable_value)) 
        {
            console.log("Unacceptable value: " +unacceptable_value + " was accepted.");
            return false;
        }
    }

    console.log("All tests passed.");
    return true;
}

function testGetTemplateId()
{
    // Template IDs
    var new_agreement_nondiscounted_us_template_id = "a2A600000004FKZ";
    var new_agreement_nondiscounted_international_template_id = "a2A600000004FKe";
    var new_agreement_discounted_us_template_id = "a2A600000004FKj";
    var new_agreement_discounted_international_template_id = "a2A600000004FKo";
    
    // Upsells have no BSA or location info, same for domestic and international
    var upsell_nondiscounted_us_template_id = "a2A600000004FKt";
    var upsell_nondiscounted_international_template_id = "a2A600000004FKt";
    var upsell_discounted_us_template_id = "a2A600000004FKy";
    var upsell_discounted_international_template_id = "a2A600000004FKy";
    
    var NEW_AGREEMENT_QUOTE_TYPE = "New Agreement";
    var UPSELL_QUOTE_TYPE = "Upsell";
    var DISCOUNTED = 0;
    var NONDISCOUNTED = 1;
    var USA = "United States";
    var INTERNATIONAL = "China";
    // New Agreement Tests
    if (new_agreement_nondiscounted_us_template_id !== getTemplateId(NEW_AGREEMENT_QUOTE_TYPE, NONDISCOUNTED, USA)) {
        console.log(getTemplateId(NEW_AGREEMENT_QUOTE_TYPE, NONDISCOUNTED, USA));
        console.log("New Agreement,No Discount, US: Fail");
        return false;
    }
    if (new_agreement_nondiscounted_international_template_id !== getTemplateId(NEW_AGREEMENT_QUOTE_TYPE, NONDISCOUNTED, INTERNATIONAL))
    {
        console.log("New Agreement, No Discount, International: Fail");
        return false;
    }
    if (new_agreement_discounted_us_template_id !== getTemplateId(NEW_AGREEMENT_QUOTE_TYPE,DISCOUNTED,USA))
    {
        console.log("New Agreement, Discount, US: Fail");
        return false;
    }
    if (new_agreement_discounted_international_template_id !== getTemplateId(NEW_AGREEMENT_QUOTE_TYPE, DISCOUNTED, INTERNATIONAL))
    {
        console.log("New Agreement, Discount, International: Fail");
        return false;
    }
    // Upsell Tests
    if (upsell_nondiscounted_us_template_id !== getTemplateId(UPSELL_QUOTE_TYPE, NONDISCOUNTED, USA))
    {
        console.log("Upsell, No Discount, US: Fail");
        return false;
    }
    if (upsell_nondiscounted_international_template_id !== getTemplateId(UPSELL_QUOTE_TYPE, NONDISCOUNTED, INTERNATIONAL))
    {
        console.log("Upsell, No Discount, International: Fail");
        return false;
    }
    if (upsell_discounted_us_template_id !== getTemplateId(UPSELL_QUOTE_TYPE, DISCOUNTED, USA))
    {
        console.log("Upsell, Discount, US: Fail");
        return false;
    }
    if (upsell_discounted_international_template_id !== getTemplateId(UPSELL_QUOTE_TYPE, DISCOUNTED, INTERNATIONAL))
    {
        console.log("Upsell, Discount, International: Fail");
        return false;
    }
    console.log("All normal inputs passed their tests");

    // Test for irregular Quote_Types
    var NULL_QUOTE_TYPE = null;
    var EMPTY_QUOTE_TYPE = "";
    if (new_agreement_nondiscounted_us_template_id !== getTemplateId(NULL_QUOTE_TYPE, NONDISCOUNTED, USA)) {
        console.log("NULL,No Discount, US: Fail");
        return false;
    }
    if (new_agreement_nondiscounted_us_template_id !== getTemplateId(EMPTY_QUOTE_TYPE, NONDISCOUNTED, USA)) {
        console.log("Empty String,No Discount, US: Fail");
        return false;
    }

    console.log("Irregular inputs passed their tests");

    return true;
}

function testCheckForValidAddress()
{
    var valid_us_country_string = "US";
    var valid_us_street_string = "100 Liberty Way";
    var valid_us_city_string = "Annapolis";
    var valid_us_state_string = "Maryland";
    var valid_us_zip_string = "94040";

    var valid_international_country_string = "Britain";
    var valid_international_street_string = "007 Crumpet Lane";
    var valid_international_city_string = "London";

    var invalid_string = "";

    // Valid US
    var error_object = checkForValidAddress(valid_us_country_string,valid_us_street_string, valid_us_city_string, valid_us_state_string, valid_us_zip_string);
    if (!error_object.is_valid || !error_object.is_domestic || error_object.error_messages.length != 0)
    {
        console.log("Valid US Address Validation Failed!");
        console.log("Error Object: " + error_object);
        return false;
    }

    // Valid International
    error_object = checkForValidAddress(valid_international_country_string, valid_international_street_string, valid_international_city_string, invalid_string, invalid_string);
    if (!error_object.is_valid || error_object.is_domestic || error_object.error_messages.length != 0)
    {
        console.log("Valid International Address Validation Failed!");
        console.log("Error Object: " + error_object);
        return false;
    }

    // All invalid
    error_object = checkForValidAddress(invalid_string,invalid_string,invalid_string,invalid_string,invalid_string)
    if (error_object.is_valid || error_object.error_messages.length === 0)
    {
        console.log("Invalid Address Validation Failed!");
        console.log("Error Object: " + error_object);
        return false;
    }

    // Missing state and zip US
    error_object = checkForValidAddress(valid_us_country_string, valid_us_street_string, valid_us_city_string, invalid_string, invalid_string);
    if (error_object.is_valid || !error_object.is_domestic || error_object.error_messages.length !== 2)
    {
        console.log("Missing State and Zip US Validation Failed!");
        console.log("Error Object: " + error_object);
        return false;
    }

    // Missing street International
    error_object = checkForValidAddress(valid_international_country_string, invalid_string, valid_international_city_string, invalid_string, invalid_string)
    if (error_object.is_valid || error_object.is_domestic || error_object.error_messages.length !== 1)
    {
        console.log("Missing street International Validation Failed!");
        console.log("Error Object: " + error_object);
        return false;
    }

    console.log("All Address Validation tests passed.");
    return true;
}
