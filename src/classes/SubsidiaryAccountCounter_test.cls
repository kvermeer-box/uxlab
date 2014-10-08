@isTest
private class SubsidiaryAccountCounter_test {
    
    @isTest static void fullTestInsert() {
        
        Account parentAccount = new Account(Name = 'Parent Account');
        insert parentAccount;

        Id natamUser = TestDataFactory_hlpr.createUser('ESB', 'NATAM', 'abcde', 'qwertyuio@asdfgh.zxc');
        Account childAccountNATAM = new Account(Name = 'Child Account NATAM', parentId = parentAccount.Id, ownerId = natamUser);
        insert childAccountNATAM;

        //Id latamUser = TestDataFactory_hlpr.createUser('Major', 'LATAM', 'bcdef', 'prtotnsjat@cvbnt.cyt');
        Account childAccountLATAM = new Account(Name = 'Child Account LATAM', parentId = parentAccount.Id);
        insert childAccountLATAM;

        Account childAccountMisc = new Account(Name = 'Child Account Misc', parentId = parentAccount.Id);
        insert childAccountMisc;

        Account updateParentAccount = [SELECT Id, Subsidiary_Count_Total__c, Subsidiary_Count_NA__c, 
                                              Subsidiary_Count_Misc__c, Subsidiary_Count_LATAM__c
                                         FROM Account
                                        WHERE Id = :parentAccount.Id];

        // Test total count
        System.assertEquals(3, updateParentAccount.Subsidiary_Count_Total__c);
        // Test Misc Count
        System.assertEquals(3, updateParentAccount.Subsidiary_Count_Misc__c);
        // Test NATAM count
        System.assertEquals(0, updateParentAccount.Subsidiary_Count_NA__c);
                                              
    }
}