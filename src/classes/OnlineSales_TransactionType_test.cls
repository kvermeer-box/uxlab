@isTest
private class OnlineSales_TransactionType_test {
    
    private static final Integer EID = 123456;
    private static final String EMAIL = 'testmethod@trucksRule.com';
    private static final Long UNIX_TIMESTAMP = 1410560907; // 9/12/14

    private static OnlineSales_Message createMessage() {
        OnlineSales_Message message = new OnlineSales_Message();
        message.userLogin = EMAIL;
        message.enterpriseId = EID;
        message.userName = 'Kyle Vermeer';
        message.enterpriseName = 'Kyle\'s Hip Hop Rodeo Show';
        message.currencyCode = 'JPY';
        message.transactionDate = UNIX_TIMESTAMP;
        return message;
    }

    @isTest static void searchForRelatedDataCreateLead() {
        OnlineSales_Message message = createMessage();
        // This should just create a Lead
        OnlineSales_TransactionType transactionType = new OnlineSales_MockTransactionType(message);
        SObject dataSearchResult = transactionType.searchForRelatedData();

        System.assert(dataSearchResult instanceOf Lead); 
    }

    @isTest static void searchForRelatedDataDomainMatching() {
        Account trAccount = new Account(Name = 'TrucksRule Account');
        insert trAccount;
        Account_Domain__c accDomain = new Account_Domain__c(Account__c = trAccount.Id, Domain__c = 'trucksRule.com', Reference_Count__c = 1);
        insert accDomain;
        OnlineSales_Message message = createMessage();
        OnlineSales_TransactionType transactionType = new OnlineSales_MockTransactionType(message);
        SObject dataSearchResult = transactionType.searchForRelatedData();

        System.assert(dataSearchResult instanceOf Account);
    }

    @isTest static void searchForRelatedDataEIDAccount() {
        Account eidAccount = new Account(Name = 'TrucksRule Account', Box_Enterprise_ID__c = String.valueOf(EID));
        insert eidAccount;

        OnlineSales_Message message = createMessage();
        OnlineSales_TransactionType transactionType = new OnlineSales_MockTransactionType(message);
        SObject dataSearchResult = transactionType.searchForRelatedData();

        System.assert(dataSearchResult instanceOf Account);
    }

    @isTest static void searchForRelatedDataEIDOpp() {
        Account eidAccount = new Account(Name = 'TrucksRule Account', Box_Enterprise_ID__c = String.valueOf(EID));
        insert eidAccount;
        Opportunity eidOpp = new Opportunity(Name = 'TrucksRule Opp', CloseDate = Date.today(), StageName = 'My Stage', AccountId = eidAccount.Id, Box_Enterprise_ID__c = String.valueOf(EID));
        insert eIdOpp;

        OnlineSales_Message message = createMessage();
        OnlineSales_TransactionType transactionType = new OnlineSales_MockTransactionType(message);
        SObject dataSearchResult = transactionType.searchForRelatedData();

        System.assert(dataSearchResult instanceOf Opportunity);
    }

    @isTest static void searchForRelatedDataLead() {
        // Make sure it doesn't select one of these over the lead option
        Account eidAccount = new Account(Name = 'TrucksRule Account', Box_Enterprise_ID__c = String.valueOf(EID));
        insert eidAccount;
        Opportunity eidOpp = new Opportunity(Name = 'TrucksRule Opp', CloseDate = Date.today(), StageName = 'My Stage', AccountId = eidAccount.Id, Box_Enterprise_ID__c = String.valueOf(EID));
        insert eIdOpp;

        Lead matchingLead = new Lead(LastName = 'Tester', Company = 'Trucks Rule', Email = EMAIL);
        insert matchingLead;

        OnlineSales_Message message = createMessage();
        OnlineSales_TransactionType transactionType = new OnlineSales_MockTransactionType(message);
        SObject dataSearchResult = transactionType.searchForRelatedData();

        System.assert(dataSearchResult instanceOf Lead);
    }

    @isTest static void searchForRelatedDataContact() {
        // Make sure it doesn't select one of these over the contact option
        Account eidAccount = new Account(Name = 'TrucksRule Account', Box_Enterprise_ID__c = String.valueOf(EID));
        insert eidAccount;
        Opportunity eidOpp = new Opportunity(Name = 'TrucksRule Opp', CloseDate = Date.today(), StageName = 'My Stage', AccountId = eidAccount.Id, Box_Enterprise_ID__c = String.valueOf(EID));
        insert eIdOpp;
        Lead matchingLead = new Lead(LastName = 'Tester', Company = 'Trucks Rule', Email = EMAIL);
        insert matchingLead;

        Contact matchingContact = new Contact(LastName = 'Vster', AccountId = eidAccount.Id, Email = EMAIL);
        insert matchingContact;

        OnlineSales_Message message = createMessage();
        OnlineSales_TransactionType transactionType = new OnlineSales_MockTransactionType(message);
        SObject dataSearchResult = transactionType.searchForRelatedData();

        System.assert(dataSearchResult instanceOf Contact, 'The search should have returned a Contact!');
    }

    @isTest static void processMessageContact() {
        // Make sure it doesn't select one of these over the contact option
        Account eidAccount = new Account(Name = 'TrucksRule Account', Box_Enterprise_ID__c = String.valueOf(EID));
        insert eidAccount;
        Opportunity eidOpp = new Opportunity(Name = 'TrucksRule Opp', CloseDate = Date.today(), StageName = 'My Stage', AccountId = eidAccount.Id, Box_Enterprise_ID__c = String.valueOf(EID));
        insert eIdOpp;
        Lead matchingLead = new Lead(LastName = 'Tester', Company = 'Trucks Rule', Email = EMAIL);
        insert matchingLead;

        Contact matchingContact = new Contact(LastName = 'Vster', AccountId = eidAccount.Id, Email = EMAIL);
        insert matchingContact;

        OnlineSales_Message message = createMessage();
        OnlineSales_TransactionType transactionType = new OnlineSales_MockTransactionType(message);
        OnlineSales_TransactionType.TransactionResult tResult = transactionType.processMessage();

        System.assertNotEquals(null, tResult.opportunityId, 'Opportunity ID should not be null');
        System.assertNotEquals(null, tResult.accountId, 'Account Id should not be null');
        System.assertNotEquals(null, tResult.contactId, 'Contact id should not be null');
    }

    @isTest static void processMessageAccount() {
        Account trAccount = new Account(Name = 'TrucksRule Account');
        insert trAccount;
        Account_Domain__c accDomain = new Account_Domain__c(Account__c = trAccount.Id, Domain__c = 'trucksRule.com', Reference_Count__c = 1);
        insert accDomain;

        OnlineSales_Message message = createMessage();
        OnlineSales_TransactionType transactionType = new OnlineSales_MockTransactionType(message);
        OnlineSales_TransactionType.TransactionResult tResult = transactionType.processMessage();

        System.assertNotEquals(null, tResult.opportunityId, 'Opportunity ID should not be null');
        System.assertNotEquals(null, tResult.accountId, 'Account Id should not be null');
        System.assertNotEquals(null, tResult.contactId, 'Contact id should not be null');
    }

    @isTest static void processMessageOpportunity() {
        Account eidAccount = new Account(Name = 'TrucksRule Account', Box_Enterprise_ID__c = String.valueOf(EID));
        insert eidAccount;
        Opportunity eidOpp = new Opportunity(Name = 'TrucksRule Opp', CloseDate = Date.today(), StageName = 'My Stage', AccountId = eidAccount.Id, Box_Enterprise_ID__c = String.valueOf(EID));
        insert eIdOpp;

        OnlineSales_Message message = createMessage();
        OnlineSales_TransactionType transactionType = new OnlineSales_MockTransactionType(message);
        OnlineSales_TransactionType.TransactionResult tResult = transactionType.processMessage();

        System.assertNotEquals(null, tResult.opportunityId, 'Opportunity ID should not be null');
        System.assertNotEquals(null, tResult.accountId, 'Account Id should not be null');
        System.assertNotEquals(null, tResult.contactId, 'Contact id should not be null');
    }

    @isTest static void processMessageLead() {
        // Make sure it doesn't select one of these over the lead option
        Account eidAccount = new Account(Name = 'TrucksRule Account', Box_Enterprise_ID__c = String.valueOf(EID));
        insert eidAccount;
        Opportunity eidOpp = new Opportunity(Name = 'TrucksRule Opp', CloseDate = Date.today(), StageName = 'My Stage', AccountId = eidAccount.Id, Box_Enterprise_ID__c = String.valueOf(EID));
        insert eIdOpp;

        Lead matchingLead = new Lead(LastName = 'Tester', Company = 'Trucks Rule', Email = EMAIL);
        insert matchingLead;

        OnlineSales_Message message = createMessage();
        OnlineSales_TransactionType transactionType = new OnlineSales_MockTransactionType(message);
        OnlineSales_TransactionType.TransactionResult tResult = transactionType.processMessage();

        System.assertNotEquals(null, tResult.opportunityId, 'Opportunity ID should not be null');
        System.assertNotEquals(null, tResult.accountId, 'Account Id should not be null');
        System.assertNotEquals(null, tResult.contactId, 'Contact id should not be null');
    }

}