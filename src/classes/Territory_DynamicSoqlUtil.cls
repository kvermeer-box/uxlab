public class Territory_DynamicSoqlUtil {
	
	public static Object getFieldValueObject(SObject sObj, String fieldName) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_DynamicSoqlUtil: Getting field value object..');
		
		Object fieldValue;
		if (sObj != null && fieldName != null) {
			
			// See how many sObjects we need to traverse
			List<String> fieldPath = fieldName.split('\\.');						
						
			// Find the final sObj
			SObject finalSObject = sObj;
			if (fieldPath.size() > 1) {
				for (Integer i = 0; i < fieldPath.size() - 1; i++) {
					sObj = sObj.getSObject(fieldPath[i]);
				}
			}
			
			// We are at the final sObj, so we can do the normal get
			if (sObj != null) {			
				fieldValue = sObj.get(fieldPath[fieldPath.size() - 1]);
			}
			System.debug(System.LoggingLevel.ERROR, 'Territory_DynamicSoqlUtil: Field value is ' + fieldValue);
		}
		
		return fieldValue;
	}
	
}