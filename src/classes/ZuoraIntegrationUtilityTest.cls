@isTest
private class ZuoraIntegrationUtilityTest {
	static final String ENTERPRISE_ID = 'wabbit';

	// seeAllData used to avoid "Please upload Zuora WSDL at first"
	@isTest(seeAllData=true)
	static void zPluckStrings() {
		Zuora.zObject accountWithEnterpriseId = new Zuora.zObject('Account');
		accountWithEnterpriseId.setValue('EnterpriseID__c', ENTERPRISE_ID);

		Zuora.zObject accountWithoutEnterpriseId = new Zuora.zObject('Account');
		accountWithoutEnterpriseId.setValue('EnterpriseID__c', '');

		List<Zuora.zObject> zobjects = new List<Zuora.zObject>
			{ accountWithEnterpriseId
			, accountWithoutEnterpriseId
			};

		Test.startTest();
			Set<String> strings = ZuoraIntegrationUtility.zPluckStrings('EnterpriseID__c', zobjects);
		Test.stopTest();

		system.assertEquals(1, strings.size(), 'Only 1 account should have an enterprise id');
		system.assertEquals(ENTERPRISE_ID, new List<String>(strings)[0], 'The right enterprise id should be included');
	}

	static testMethod void getEntepriseIdToAccountId() {
		Account account = Z_TestUtils.createAccount(false);
		//account.Box_Enterprise_ID__c = ENTERPRISE_ID;

		Account anotherAccount = Z_TestUtils.createAccount(false);
		//anotherAccount.Box_Enterprise_ID__c = 'tweet';

		insert new List<Account>{account, anotherAccount};

		Opportunity opp = Z_TestUtils.createOpportunity(account.Id, false);
		opp.StageName = 'Closed Won';
		opp.Box_Enterprise_ID__c = ENTERPRISE_ID;

		Opportunity notClosedOpp = Z_TestUtils.createOpportunity(account.Id, false);
		notClosedOpp.Box_Enterprise_ID__c = ENTERPRISE_ID;

		Opportunity anotherOpp = Z_TestUtils.createOpportunity(anotherAccount.Id, false);
		anotherOpp.StageName = 'Closed Won';
		anotherOpp.Box_Enterprise_ID__c = 'tweet';
		insert new List<Opportunity>{opp, anotherOpp, notClosedOpp};

		Test.startTest();
			Map<String, Id> enterpriseIdToAccountId = ZuoraIntegrationUtility.getEntepriseIdToAccountId(new Set<String>{ENTERPRISE_ID});
		Test.stopTest();

		system.assertEquals(1, enterpriseIdToAccountId.size(), 'Only 1 account should be related');
		system.assert(enterpriseIdToAccountId.containsKey(ENTERPRISE_ID), 'We should get back the correct key');
		system.assertEquals(account.Id, enterpriseIdToAccountId.get(ENTERPRISE_ID), 'The correct account should be related');
	}

	static testMethod void getStringToId() {
		Account account = Z_TestUtils.createAccount(false);
		account.Box_Enterprise_ID__c = ENTERPRISE_ID;
		insert account;

		Test.startTest();
			Map<String, Id> stringToId = ZuoraIntegrationUtility.getStringToId(new List<Account>{account}, 'Box_Enterprise_ID__c', 'Id');
		Test.stopTest();

		system.assertEquals(1, stringToId.size(), 'There should be 1 entry');
		system.assert(stringToId.containsKey(ENTERPRISE_ID), 'We should get back the correct key');
		system.assertEquals(account.Id, stringToId.get(ENTERPRISE_ID), 'The correct account should be related');
	}

	@isTest(seeAllData=true)
	static void getChangedZobjects() {
		final String ZACCOUNTID1 = 'account id 1';
		final String ZACCOUNTID2 = 'account id 2';

		Zuora.zObject zaccount = new Zuora.zObject('Account');
		zaccount.setValue('Id', ZACCOUNTID1);
		zaccount.setValue('EnterpriseID__c', ENTERPRISE_ID);

		Zuora.zObject zaccountWithNonexistantEnterpriseId = new Zuora.zObject('Account');
		zaccountWithNonexistantEnterpriseId.setValue('Id', ZACCOUNTID2);
		zaccountWithNonexistantEnterpriseId.setValue('EnterpriseID__c', 'eid dne');

		Account account = Z_TestUtils.createAccount(false);
		//account.Box_Enterprise_ID__c = ENTERPRISE_ID;
		insert account;

		Opportunity opp = Z_TestUtils.createOpportunity(account.Id, false);
		opp.StageName = 'Closed Won';
		opp.Box_Enterprise_ID__c = ENTERPRISE_ID;
		insert opp;

		Test.startTest();
			List<Zuora.zObject> zobjects = ZuoraIntegrationUtility.getChangedZobjects(new List<Zuora.zObject>{zaccount, zaccountWithNonexistantEnterpriseId});
		Test.stopTest();

		system.assertEquals(1, zobjects.size(), 'One account should be ready to update');
		system.assertEquals(ZACCOUNTID1, zobjects[0].getValue('Id'), 'The account id should match');
		system.assertEquals(account.Id, zobjects[0].getValue('CrmId'), 'The crm id should be populated with the correct account');
	}

	@isTest(seeAllData=true)
	static void handleZuoraErrors_success() {
		Zuora.zApi.SaveResult saveResult = new Zuora.zApi.SaveResult();
		saveResult.Id = '1234567890';
		saveResult.Success = true;
		saveResult.Errors = new List<Zuora.zObject>();

		Test.startTest();
			try {
				ZuoraIntegrationUtility.handleZuoraErrors(new List<Zuora.zApi.SaveResult>{saveResult});
			} catch(ZuoraIntegrationUtility.ZuoraUpdateErrorException e) {
				system.assert(false, 'On success, no exception should occur: ' + e);
			}
		Test.stopTest();
	}

	@isTest(seeAllData=true)
	static void handleZuoraErrors_failure() {
		final String ZUORA_ID = '1234567890';
		final String ERROR_CODE = 'red';
		final String ERROR_MESSAGE = 'blue';

		Zuora.zObject error = new Zuora.zObject('Error');
		error.setValue('Code', ERROR_CODE);
		error.setValue('Message', ERROR_MESSAGE);

		Zuora.zApi.SaveResult saveResult = new Zuora.zApi.SaveResult();
		saveResult.Id = ZUORA_ID;
		saveResult.Success = false;
		saveResult.Errors = new List<Zuora.zObject>{error};

		Test.startTest();
			try {
				ZuoraIntegrationUtility.handleZuoraErrors(new List<Zuora.zApi.SaveResult>{saveResult});

				system.assert(false, 'On failure, an exception should occur');
			} catch(ZuoraIntegrationUtility.ZuoraUpdateErrorException e) {
				String message = e.getMessage();

				system.assert(message.contains(ZUORA_ID), 'Message should contain the zuora id');
				system.assert(message.contains(ERROR_CODE), 'Message should contain the error code');
				system.assert(message.contains(ERROR_MESSAGE), 'Message should contain the error message');
			}
		Test.stopTest();
	}
}