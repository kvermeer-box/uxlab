public class Territory_RoutedLeadFactory {

	private static String QUEUE_ID_PREFIX = '00G';
	private static String STAGE_1_RECORD_TYPE_ID = [SELECT Id FROM RecordType WHERE SobjectType = 'Routed_Lead__c' AND DeveloperName = 'Stage_1_Routed_Lead'].Id;  // '012J00000004TjO';
	private static String STAGE_2_RECORD_TYPE_ID = [SELECT Id FROM RecordType WHERE SobjectType = 'Routed_Lead__c' AND DeveloperName = 'Stage_2_Routed_Lead'].Id;  // '012J00000004TjT';

	public static Routed_Lead__c createStage1RoutedLead(Lead lead, Territory_Stage_1_Assignment_Rule__c rule) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_RoutedLeadFactory: Creating a stage 1 routed lead for ' + lead.Name + ' and rule ' + rule.Id);
		
		Routed_Lead__c routedLead = new Routed_Lead__c();
		routedLead.RecordTypeId = STAGE_1_RECORD_TYPE_ID;
		routedLead.Lead__c = lead.Id;
		routedLead.Territory_Stage_1_Assignment_Rule__c = rule.Id;
		routedLead.Routed_By__c = UserInfo.getUserId();
		// Sometimes these go to queues instead
		if (String.valueOf(lead.OwnerId).startsWith(QUEUE_ID_PREFIX)) {
			routedLead.Routed_To_Queue__c = lead.OwnerId;
		} else {
			routedLead.Routed_To__c = lead.OwnerId;
		}
		return routedLead;
	}
	
	public static Routed_Lead__c createStage2RoutedLead(Lead lead, Territory_Stage_2_Assignment_Rule__c rule, Territory_Employee_Segment_Field_Mapping__c fieldMapping, Database.LeadConvertResult lcr, SDR_Qualification_Notes__c sdrQualNote) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_RoutedLeadFactory: Creating a stage 2 routed lead for ' + lead.Name + ' and rule ' + rule.Id);
		
		// Normal stuff
		Routed_Lead__c routedLead = new Routed_Lead__c();
		routedLead.RecordTypeId = STAGE_2_RECORD_TYPE_ID;		
		routedLead.Territory_Stage_2_Assignment_Rule__c = rule.Id;
		routedLead.Routed_By__c = UserInfo.getUserId();		
		routedLead.Routed_To__c = lead.OwnerId;
		
		// Lead convert associations
		routedLead.Account__c = lcr.getAccountId();
		routedLead.Contact__c = lcr.getContactId();
		routedLead.Opportunity__c = lcr.getOpportunityId();
		
		// Field mapping
		routedLead.Territory_Employee_Segment_Field_Mapping__c = fieldMapping.Id;
		
		// Routing account
		routedLead.Routing_Account__c = lead.Territory_Routing_Account__c;
		
		// Stamped fields
		String employees = getFieldAndConvertToString(lead, 'Territory_Routing_Account__r.Normalized_Employees__c');
		if (employees != null)  { routedLead.Employees__c = Decimal.valueOf(employees); }
		routedLead.Street__c    = getFieldAndConvertToString(lead, 'Territory_Routing_Account__r.BillingStreet');
		routedLead.City__c      = getFieldAndConvertToString(lead, 'Territory_Routing_Account__r.BillingCity');
		routedLead.State__c     = getFieldAndConvertToString(lead, 'Territory_Routing_Account__r.BillingState');
		routedLead.Zip_Code__c  = getFieldAndConvertToString(lead, 'Territory_Routing_Account__r.BillingPostalCode');
		routedLead.Country__c   = getFieldAndConvertToString(lead, 'Territory_Routing_Account__r.BillingCountry');
				
		// Qual note bullshit
		if (sdrQualNote != null) {
			routedLead.SDR_Qualification_Notes__c = sdrQualNote.Id;
		}				
		
		return routedLead;
	}
	
	public static Set<String> getStage2RoutedLeadStampedFields() {
		System.debug(System.LoggingLevel.ERROR, 'Territory_RoutedLeadFactory: Getting fields required for stage 2 routed leads..');
		
		Set<String> fieldsForConversion = new Set<String>();		
		fieldsForConversion.add('Territory_Routing_Account__r.Normalized_Employees__c');
		fieldsForConversion.add('Territory_Routing_Account__r.BillingStreet');
		fieldsForConversion.add('Territory_Routing_Account__r.BillingCity');
		fieldsForConversion.add('Territory_Routing_Account__r.BillingState');
		fieldsForConversion.add('Territory_Routing_Account__r.BillingPostalCode');
		fieldsForConversion.add('Territory_Routing_Account__r.BillingCountry');
		
		return fieldsForConversion;
	}
	
	private static String getFieldAndConvertToString(Lead lead, String fieldName) {
		String stringValue;
		if (lead != null && fieldName != null) {
			Object obj = Territory_DynamicSoqlUtil.getFieldValueObject(lead, fieldName);
			if (obj != null) {
				stringValue = String.valueOf(obj);
			}
		}
		return stringValue;
	}
}