@isTest
private class AccountTeamUpdate_Test {

	public static final String USER_PROFILE_ID_SALES 		= '00e60000000idJI';	// 'Box: Sales' 
	public static final String USER_PROFILE_ID_SALES_EMEA 	= '00e60000000iqCA';	// 'Box: Sales (EMEA)' 
	
	public static final String ACCOUNT_TEAM_ROLE_INSIDE_REP 	= 'Inside Rep';
	public static final String ACCOUNT_TEAM_ROLE_OUTBOUND_REP	= 'Outbound Rep';
	
    static testMethod void testBatchMethod() {

        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

		Id userId2 = TestDataFactory_hlpr.createUser('Major','NATAM','Kyle V','AccountTeamUpdate_Test2@box.com');      
		Id userId3 = TestDataFactory_hlpr.createUser('Major','NATAM','Kyle V','AccountTeamUpdate_Test3@box.com');      
 
        AccountTeamMember member1 = new AccountTeamMember();
        member1.UserId = userId2;
        member1.AccountId = testAccount.Id;
        member1.TeamMemberRole = ACCOUNT_TEAM_ROLE_INSIDE_REP;
        insert member1;


        AccountTeamMember member2 = new AccountTeamMember();
        member2.UserId = userId3;
        member2.AccountId = testAccount.Id;
        member2.TeamMemberRole = ACCOUNT_TEAM_ROLE_OUTBOUND_REP;
        insert member2;


        AccountTeamUpdate batchClass = new AccountTeamUpdate();
            
        Test.startTest();
        Database.executeBatch(batchClass, 1);
        Test.stopTest();


    }

    static testMethod void testBatchMethod2() {

        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        AccountTeamUpdate batchClass = new AccountTeamUpdate();
            
        Test.startTest();
        Database.executeBatch(batchClass, 1);
        Test.stopTest();


    }


}