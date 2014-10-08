public class Territory_EntryValueFieldUtils {
	
	public static List<String> convertEntryValueFieldListToStrings(List<Territory_EntryValueField> entryValueFields) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_EntryValueFieldUtils: Converting List<Territory_EntryValueField> to List<String>...');
		List<String> stringList = new List<String>();
		for (Territory_EntryValueField field : entryValueFields) {
			stringList.add(field.fieldName);
		}
		return stringList;
	}
	
	public static String getEntryValue(Lead lead, Territory_EntryValueField entryValueField) {
		String value;
		Object obj = Territory_DynamicSoqlUtil.getFieldValueObject(lead, entryValueField.fieldName); 		
		
		// lead.get(entryValueField.fieldName);
		if (obj != null) {
			value = String.valueOf(obj).mid(0, entryValueField.truncateSize);
		}
		return value;
	}

}