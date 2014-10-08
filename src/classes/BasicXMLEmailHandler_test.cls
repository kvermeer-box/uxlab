@isTest
private class BasicXMLEmailHandler_test {
  
  @isTest static void testMakeTag() 
  {
    String tag_name = 'Test';
    String tag_name_special_chars = '<Bad>';
    Test.startTest();
    String start_tag = BasicXMLEmailHandler_email.makeTag(tag_name,true);
    String end_tag = BasicXMLEmailHandler_email.makeTag(tag_name,false);
    String start_tag_special_chars = BasicXMLEmailHandler_email.makeTag(tag_name_special_chars,true);
    String end_tag_special_chars = BasicXMLEmailHandler_email.makeTag(tag_name_special_chars,false);
    Test.stopTest();
    System.assertEquals('<Test>',start_tag,'Basic start tag test failed.');
    System.assertEquals('</Test>',end_tag,'Basic end tag test failed.');
    System.assertEquals(start_tag_special_chars,'<&lt;Bad&gt;>','Tag containing special XML chars should be handled.');
    System.assertEquals(end_tag_special_chars,'</&lt;Bad&gt;>','Tag containing special XML chars should be handled.');
  }

  @isTest static void testMakeTagMalformedInputs()
  {
    Test.startTest();
    String start_tag_null = BasicXMLEmailHandler_email.makeTag(null,true);
    String end_tag_null = BasicXMLEmailHandler_email.makeTag(null,false);
    Test.stopTest();
    System.assertEquals(start_tag_null,null,'Tag Name provided was null, should return null.');
    System.assertEquals(end_tag_null,null,'Tag Name provided was null, should return null.');
  }

  @isTest static void testParseTag()
  {
    String tag_name_1 = 'Inner1';
    String tag_value_1 = 'Hey!';
    String tag_name_2 = 'Inner2';
    String tag_value_2 = 'Woah!';
    String text = '<Outer>' +
                    '<'+tag_name_1+'>'+ tag_value_1 + '</'+tag_name_1+'>' +
                    '<'+tag_name_2+'>'+ tag_value_2 + '</'+tag_name_2+'>' +
                  '</Outer>';
    Map<String,String> tag_map = new Map<String,String>();
    Test.startTest();
    Boolean tag_one_success = BasicXMLEmailHandler_email.parseTag(text,tag_name_1,tag_map);
    Boolean tag_two_success = BasicXMLEmailHandler_email.parseTag(text,tag_name_2,tag_map);
    Test.stopTest();
    System.assert(tag_one_success,'Tag one was not parsed successfully.');
    System.assert(tag_two_success,'Tag two was not parsed successfully.');
    String tag_1_value_from_map = tag_map.get(tag_name_1);
    String tag_2_value_from_map = tag_map.get(tag_name_2);
    System.assertEquals(tag_1_value_from_map,tag_value_1,'Tag one value in map doesn\'t match value input.');
    System.assertEquals(tag_2_value_from_map,tag_value_2,'Tag two value in map doesn\'t match value input.');
  }

  @isTest static void testParseTagMalformedInputs()
  {
    String tag_name_special_chars = '<K>';
    String tag_value_special_chars = 'What is this?';
    String tag_name_doesnt_exist = '<Not There>';
    String text = '<Outer>' +
                    '<&lt;K&gt;>'+ tag_value_special_chars+ '</&lt;K&gt;>' +
                  '</Outer>';
    Map<String,String> tag_map = new Map<String,String>();
    Test.startTest();
    // Null tests
    Boolean null_text_success = BasicXMLEmailHandler_email.parseTag(null,tag_name_special_chars,tag_map);
    Boolean null_tag_name_success = BasicXMLEmailHandler_email.parseTag(text,null,tag_map);
    Boolean null_map_success = BasicXMLEmailHandler_email.parseTag(text,tag_name_special_chars,null);

    Boolean special_chars_success = BasicXMLEmailHandler_email.parseTag(text,tag_name_special_chars,tag_map);
    Boolean doesnt_exist_success = BasicXMLEmailHandler_email.parseTag(text,tag_name_doesnt_exist,tag_map);
    Test.stopTest();
    System.assert(!null_text_success,'Null text should return false.');
    System.assert(!null_tag_name_success,'Null tag_name should return false.');
    System.assert(!null_map_success,'Null map should return false.');
    System.assert(special_chars_success,'Special chars was not parsed correctly.');
    System.assert(!doesnt_exist_success, 'Tag that doesn\'t exist should return false.');
    String tag_special_chars_from_map = tag_map.get(tag_name_special_chars);
    String tag_name_doesnt_exist_from_map = tag_map.get(tag_name_doesnt_exist);
    System.assertEquals(tag_special_chars_from_map,tag_value_special_chars,'Special chars value isn\'t correct');
    System.assertEquals(tag_name_doesnt_exist_from_map,null,'Tag not found value not null.');
  }

  @isTest static void testParseXML()
  {
    String required_tag_name_1 = 'Required 1';
    String required_tag_value_1 = 'I am required';
    String required_tag_name_2 = 'Required 2';
    String required_tag_value_2 = 'I am also required';
    String optional_tag_name_1 = 'Optional 1';
    String optional_tag_value_1 = 'I am optional';
    String optional_tag_name_not_included = 'Optional Not Included';

    String text = '<'+required_tag_name_1+'>'+required_tag_value_1+'</'+required_tag_name_1+'>'+
           '<'+required_tag_name_2+'>'+required_tag_value_2+'</'+required_tag_name_2+'>'+
           '<'+optional_tag_name_1+'>'+optional_tag_value_1+'</'+optional_tag_name_1+'>';
    Test.startTest();
    Map<String,String> tag_map = BasicXMLEmailHandler_email.parseXML(text, 
                                                                     new String[] {required_tag_name_1,required_tag_name_2},
                                                                     new String[] {optional_tag_name_1,optional_tag_name_not_included});
    Test.stopTest();
    System.assertEquals(tag_map.get(required_tag_name_1),required_tag_value_1);
    System.assertEquals(tag_map.get(required_tag_name_2),required_tag_value_2);
    System.assertEquals(tag_map.get(optional_tag_name_1),optional_tag_value_1);
    System.assertEquals(tag_map.get(optional_tag_name_not_included),null);
  }

  @isTest static void testParseXMLMalformedInput()
  {
    String required_tag_included = 'Included';
    String required_tag_included_value = 'I am included!';
    String required_tag_not_included = 'Not There';
    String required_tag_not_included_value = 'Include me, bro.';

    String text= '<'+required_tag_included+'>'+required_tag_included_value+'</'+required_tag_included+'>';

    Test.startTest();

    Map<String,String> tag_map_null_text = BasicXMLEmailHandler_email.parseXML(null, 
                                                                     new String[] {required_tag_included},
                                                                     new String[] {});
    Map<String,String> tag_map_null_required_tags = BasicXMLEmailHandler_email.parseXML(text, 
                                                                     null,
                                                                     new String[] {});
    Map<String,String> tag_map_null_optional_tags = BasicXMLEmailHandler_email.parseXML(text, 
                                                                     new String[] {required_tag_included},
                                                                     null);
    Map<String,String> tag_map_required_tag_not_included = BasicXMLEmailHandler_email.parseXML(text, 
                                                                     new String[] {required_tag_included, required_tag_not_included},
                                                                     new String[] {});
    Map<String,String> tag_map_required_tag_empty_list = BasicXMLEmailHandler_email.parseXML(text, 
                                                                     new String[] {},
                                                                     new String[] {});
    Test.stopTest();

    System.assertEquals(tag_map_null_text,null,'Text was null, null should be returned.');
    System.assertEquals(tag_map_null_required_tags,null,'Required tags list was null, null should be returned.');
    System.assertNotEquals(tag_map_null_optional_tags,null,'Optional tags was null, Map should still be created and returned.');
    System.assertEquals(tag_map_null_optional_tags.get(required_tag_included),required_tag_included_value,'Optional tags was null, required tag should be in map.');
    System.assertEquals(tag_map_required_tag_not_included,null,'A required tag was missing, null should be returned');
    System.assertNotEquals(tag_map_required_tag_empty_list,null,'Required tags was empty, Map should still be created and returned.');
  }

  @isTest static void testParseMessage()
  {
    String tag_name_1 = 'Inner1';
    String tag_value_1 = 'Hey!';
    String tag_name_2 = 'Inner2';
    String tag_value_2 = 'Woah!';
    String main_object_name = 'Outer';
    String text = '<'+main_object_name+'>' +
                    '<'+tag_name_1+'>'+ tag_value_1 + '</'+tag_name_1+'>' +
                    '<'+tag_name_2+'>'+ tag_value_2 + '</'+tag_name_2+'>' +
                  '</'+main_object_name+'>';
    Test.startTest();

    Map<String,String> tag_map = BasicXMLEmailHandler_email.parseMessage(text,main_object_name,new String[] {tag_name_1}, new String[]{tag_name_2,'Not There'});
    Test.stopTest();

    System.assertEquals(tag_map.get(tag_name_1),tag_value_1,'Required tag value doesnt match.');
    System.assertEquals(tag_map.get(tag_name_2),tag_value_2,'Optional tag value doesnt match.');
    System.assertEquals(tag_map.get('Not There'),null,'Tag not in Map should return null.');
  }

  @isTest static void testParseMessageMalformedInputs()
  {
    String text = '<Outer><Test>Hey!</Test></Outer>';
    String text_no_main_object = '<Test>Hey!</Test>';
    String main_object = 'Outer';
    
    Test.startTest();
    Map<String,String> map_null_text = BasicXMLEmailHandler_email.parseMessage(null,main_object,new String[]{},new String[]{});
    Map<String,String> map_null_main_object = BasicXMLEmailHandler_email.parseMessage(text,null,new String[]{},new String[]{});
    Map<String,String> map_null_required_tags = BasicXMLEmailHandler_email.parseMessage(text,main_object,null,new String[]{});
    Map<String,String> map_null_optional_tags = BasicXMLEmailHandler_email.parseMessage(text,main_object,new String[]{},null);
    Map<String,String> map_no_main_object = BasicXMLEmailHandler_email.parseMessage(text_no_main_object,main_object,new String[]{},new String[]{});
    Test.stopTest();

    System.assertEquals(map_null_text,null,'Null text, should return null.');
    System.assertEquals(map_null_main_object,null,'Null main object, should return null.');
    System.assertEquals(map_null_required_tags,null,'Null required tags, should return null.');
    System.assertNotEquals(map_null_optional_tags,null,'Null optional tags, should still return a Map.');
    System.assertEquals(map_no_main_object,null,'No main object in text, should return null.');
  }
  
}