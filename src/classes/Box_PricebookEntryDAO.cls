public class Box_PricebookEntryDAO {

	private static Map<Id, PricebookEntry> entries;
	public static String PRODUCT_BUSINESS_ID = '01u6000000574Dr';
	public static String PRODUCT_ENTERPRISE_ID = '01u60000005X0vs';
	public static String PRODUCT_UNLIMITED_ID = '01u60000005X0w7';

	private static String getQuery() {
		System.debug('Box_PricebookEntryDAO: Getting the base SOQL query for pricebook entries...');
		
		String q = ' SELECT Id,' 
				 + '        Name, '
				 + '        UnitPrice '
			 	 + '	FROM PricebookEntry ';			 	 

		System.debug('Box_PricebookEntryDAO: Query: ' + q); 
	 	return q;
	}

	private static Map<Id, PricebookEntry> getEntries() {
		System.debug('Box_PricebookEntryDAO: Getting pricebook entries...');
		
		if (entries == null || entries.size() == 0) {
			try {
				Set<Id> productIds = getProductIds();
				String q = getQuery();
				q += ' WHERE Id IN :productIds ';
				
				System.debug('Box_PricebookEntryDAO: Query: ' + q);
				List<PricebookEntry> results = (List<PricebookEntry>)Database.query(q);
				entries = new Map<Id, PricebookEntry>();
				entries.putAll(results);
			} catch (Exception e) {
				System.debug('Box_PricebookEntryDAO: No products found!');				
			}
		} else {
			System.debug('Box_PricebookEntryDAO: Entries already queried.');
		}
		return entries;
	}
	
	public static Decimal getUnitPrice(String accountType) {
		Decimal price;
		PricebookEntry pbe;
		if (accountType.toLowerCase().equals(Box_EnterpriseAccountTypeEnum.BUSINESS.name().toLowerCase())) {
			pbe = getEntries().get(PRODUCT_BUSINESS_ID);
			if (pbe == null) {
				price = 15.00;
			} else {			
				price = getEntries().get(PRODUCT_BUSINESS_ID).UnitPrice;
			}
		} else if (accountType.toLowerCase().equals(Box_EnterpriseAccountTypeEnum.ENTERPRISE.name().toLowerCase())) {
			pbe = getEntries().get(PRODUCT_ENTERPRISE_ID);
			if (pbe == null) {
				price = 25.00;
			} else {			
				price = getEntries().get(PRODUCT_ENTERPRISE_ID).UnitPrice;
			}
		} else if (accountType.toLowerCase().equals(Box_EnterpriseAccountTypeEnum.ENTERPRISE_UNLIMITED.name().toLowerCase())) {
			pbe = getEntries().get(PRODUCT_UNLIMITED_ID);
			if (pbe == null) {
				price = 35.00;
			} else {			
				price = getEntries().get(PRODUCT_UNLIMITED_ID).UnitPrice;
			}
		}		
		return price;
	}

	private static Set<Id> getProductIds() {
		Set<Id> productIds = new Set<Id>();
		productIds.add(Id.valueOf(PRODUCT_BUSINESS_ID));
		productIds.add(Id.valueOf(PRODUCT_ENTERPRISE_ID));
		productIds.add(Id.valueOf(PRODUCT_UNLIMITED_ID));
		return productIds;
	}
	
	public static String mapEnterpriseAccountTypeToPBE(String accountType) {
		String productId;
		if (accountType.toLowerCase().equals(Box_EnterpriseAccountTypeEnum.BUSINESS.name().toLowerCase())) {
			productId = PRODUCT_BUSINESS_ID;
		} else if (accountType.toLowerCase().equals(Box_EnterpriseAccountTypeEnum.ENTERPRISE.name().toLowerCase())) {
			productId = PRODUCT_ENTERPRISE_ID;
		} else if (accountType.toLowerCase().equals(Box_EnterpriseAccountTypeEnum.ENTERPRISE_UNLIMITED.name().toLowerCase())) {
			productId = PRODUCT_UNLIMITED_ID;
		}
		return productId;
	}

}