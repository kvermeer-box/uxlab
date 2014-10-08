/**
* Class Name: BasicXMLEmailHandler_email
* Description:
*   This class servers as a useful parent class for any class that will be handling Inbound emails
*   consisting of XML contents that are only one level deep. (i.e.
*   <Object Type>
*     <Custom Field 1>Value for Custom Field 1</Custom Field 1>
*     <Custom Field 2>Values for Custom Field 2></Custom Field 2>
*   </Object Type>
*   Provides an API for digesting the XML into an easy to use Map of tag keys and values.
* Public API:
*   public static Map<String,String> parseMessage(String email_plain_text, 
*                                                 String main_object_tag, 
*                                                 List<String> required_tags,
*                                                 List<String> optional_tags);
*/

virtual public class BasicXMLEmailHandler_email {

  /**
  * Method: parseMessage
  * Availibility: public, static
  * Description:
  *   This method intiates the entire XML parsing process and returns the Map of tags and their data.
  *   If any problems are encountered while parsing the request, null is returned in place of the map.
  * Inputs:
  *   String email_plain_text - The plain text of the e-mail to be parsed.
  *   String main_object_tag - This is the text of the tag of the main object.  All other XML should
  *                             be contained inside this parent tag. E.I. "request" in this example:
  *                             <request>
  *                               <Name>Blah</Name>
  *                             </request>
  *   List<String> required_tags - The text of all tags that are required for the object to be created
  *                                (and there are no default values).  These values must exist in the XML
  *                                 otherwise the object won't be created.
  *   List<String> optional_tags - The text of all the tags that are optional for the object ot be created
  *                                (or are required, but have defaults).  These values can optionally exist
  *                                in the XML.
  * Return:
  *   Map<String,String> - This Map maps tag text to its value.  For example, in this example:
  *                         <request>
  *                           <Name>Blah</Name>
  *                         </request>
  *                         "Name" would be the key for the value "Blah". If an error occurs (i.e. required
  *                         tag not found, null is returned).
  */
  public static Map<String,String> parseMessage(String email_plain_text, String main_object_tag, List<String> required_tags, List<String> optional_tags)
  {
    if (email_plain_text == null)
    {
      System.debug('Email plain text was null.');
      return null;
    }
    if (main_object_tag == null)
    {
      System.debug('Main object tag was null.');
      return null;
    }
    String start_tag = makeTag(main_object_tag, true);
    String end_tag = makeTag(main_object_tag, false);
    Integer index_of_start_tag = email_plain_text.indexOfIgnoreCase(start_tag);
    if (index_of_start_tag == -1)
    {
      System.debug('No start ' + start_tag + ' tag.');
      // Send error e-mail
      return null;
    }
    Integer index_of_end_tag = email_plain_text.indexOfIgnoreCase(end_tag);
    if (index_of_end_tag == -1)
    {
      System.debug('No end ' + end_tag + ' tag.');
      // Send error e-mail
      return null;
    }
    String requestXML = email_plain_text.substring(index_of_start_tag,index_of_end_tag+end_tag.length());
    System.debug('XML: ' + requestXML);
    
    Map<String,String> tag_map = parseXML(requestXML,required_tags,optional_tags);
    return tag_map;
  }

  /**
  * Method: parseXML
  * Availibility: private, static
  * Description:
  *   This method loops through the required and optional tags and checks the email_text for the tags.
  *   If one of the required tags cannot be found, null is returned in place of the map. Otherwise,
  *   the tag map is returned.
  * Inputs:
  *   String email_plain_text - The plain text of the e-mail to be parsed.
  *   List<String> required_tags - The text of all tags that are required for the object to be created
  *                                (and there are no default values).  These values must exist in the XML
  *                                 otherwise the object won't be created.
  *   List<String> optional_tags - The text of all the tags that are optional for the object ot be created
  *                                (or are required, but have defaults).  These values can optionally exist
  *                                in the XML.
  * Return:
  *   Map<String,String> - This Map maps tag text to its value.  For example, in this example:
  *                         <request>
  *                           <Name>Blah</Name>
  *                         </request>
  *                         "Name" would be the key for the value "Blah". If an error occurs (i.e. required
  *                         tag not found, null is returned).
  */
  @TestVisible private static Map<String,String> parseXML(String email_plain_text, List<String> required_tags, List<String> optional_tags)
  {
    Map<String,String> tag_map = new Map<String,String>();
    if (email_plain_text == null)
    {
      System.debug('email plain text was null, must provide a valid String');
      return null;
    }
    // If the required_tags list is null, return null
    if (required_tags == null) 
    {
      System.debug('Required tags list was null, must provide some required tags.');
      return null;
    }
    // Find required fields first
    for (String tag: required_tags)
    {
      Boolean tag_parsed = parseTag(email_plain_text, tag, tag_map);
      // If a required tag can't be found, return null
      if (!tag_parsed)
      {
        System.debug('Required tag: <' + tag + '> not provided correctly.');
        return null;
      }
    }
    // Find optional tags
    if (optional_tags!= null) {
      for (String optional_tag: optional_tags)
      {
        Boolean tag_parsed = parseTag(email_plain_text, optional_tag, tag_map);
        // Its totally okay if an optional tag can't be found
        if (!tag_parsed)
        {
          System.debug('Optional tag: <' + optional_tag + '> not provided correctly.');
        } 
      }
    }
    return tag_map;
  }

  /**
  * Method: parseTag
  * Availibility: private, static
  * Description:
  *   This method takes text and looks for a tag specified by tag_name.  If found, the tag and its value (
  *   the contents inside the tag) are added to the tag map and 'true' is returned.  If the tag can't be 
  *   found, nothing is added to the the map and 'false' is returned.
  * Inputs:
  *   String email_plain_text - The plain text of the e-mail to be parsed.
  *   String tag_name - The name of the tag that is being looked for. For example, if tag_name is "cat",
  *                     this method will look for <cat> and </cat> tags.
  *   Map<String,String> tag_map - This Map maps tag text to its value.  For example, in this example:
  *                               <request>
  *                                 <Name>Blah</Name>
  *                               </request>
  *                               "Name" would be the key for the value "Blah". If an error occurs (i.e. 
  *                               required tag not found, null is returned).
  * Return:
  *   Boolean - 'true' if tag specified by tag_name was successfully parsed, otherwise 'false'.
  */
  @TestVisible private static Boolean parseTag(String email_plain_text, String tag_name, Map<String,String> tag_map)
  {
    String start_tag = makeTag(tag_name, true);
    String end_tag = makeTag(tag_name, false);
    if (start_tag == null || end_tag == null || tag_map == null || email_plain_text == null)
    {
      System.debug('Bad inputs, something was null.');
      return false;
    }
    // Find start tag in text
    Integer index_of_start_tag = email_plain_text.indexOfIgnoreCase(start_tag);
    if (index_of_start_tag == -1)
    {
      System.debug('No starting tag for tag: <' + tag_name + '>.');
      return false;
    }
    // Find end tag in text
    Integer index_of_end_tag = email_plain_text.indexOfIgnoreCase(end_tag);
    if (index_of_end_tag == -1)
    {
      System.debug('No ending tag for tag: <' + tag_name + '>.');
      return false;
    }

    // Get value inside tag, remove leading and trailing spaces
    String value = email_plain_text.substring(index_of_start_tag+start_tag.length(),index_of_end_tag).trim();
    // Put it into the map
    System.debug(tag_name + ': ' + value);
    if (tag_map != null)
      tag_map.put(tag_name,value);

    return true;
  }

  /**
  * Method: makeTag
  * Availibility: private, static
  * Description:
  *   This utility creates a tag specified by tag_name.  Both start and end tags can be created, specified
  *    by the is_start_tag Boolean argument.  Also escapes any XML special character in tag_name.
  * Inputs:
  *   String tag_name - The name of the tag that is being created. For example, if tag_name is "cat",
  *                     this method will make a tag like <cat> or </cat>.
  *   Boolean is_start_tag - if 'true', start tag will be created. If 'false', end tag will be created.
  * Return:
  *   String - start or end tag specified by tag_name. (ie. <cat>)
  */
  @TestVisible private static String makeTag(String tag_name, boolean is_start_tag)
  {
    if (tag_name == null) return null;
    String tag = '<';
    if (!is_start_tag) tag += '/';
    tag += tag_name.escapeXml();
    tag += '>';
    return tag;
  }

}