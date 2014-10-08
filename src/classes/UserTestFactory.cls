@isTest
public class UserTestFactory {

    static Integer userCounter = 0;
    public static Profile STANDARD_USER_PROFILE
    {
        get
        {
            if( STANDARD_USER_PROFILE == NULL )
            {
                STANDARD_USER_PROFILE = [ SELECT Id From Profile WHERE Name = 'Standard User' ];
            }
            return STANDARD_USER_PROFILE;
        }
        private set;
    }
    
    public static UserRole HEAD_OF_SALES_ROLE
    {
        get
        {
            if( HEAD_OF_SALES_ROLE == NULL )
            {
                HEAD_OF_SALES_ROLE = [ SELECT Id, Name From UserRole WHERE Name = 'Head of Sales' ];
            }
            return HEAD_OF_SALES_ROLE;
        }
        private set;
    }
    
    public static UserRole BILLING_TEAM_ROLE
    {
        get
        {
            if( BILLING_TEAM_ROLE == NULL )
            {
                BILLING_TEAM_ROLE = [ SELECT Id, Name From UserRole WHERE Name = 'Billing Team' ];
            }
            return BILLING_TEAM_ROLE;
        }
        private set;
    }
    
    public static User buildUserWithProfileAndRole( Id profileId, Id roleId )
    {
        User testUser = buildUser();
        testUser.ProfileId = profileId;
        testUser.UserRoleId = roleId;
        return testUser;
    }
    
    static User buildUser()
    {
        userCounter++;
        return new User(
            TimeZoneSidKey = 'America/Chicago',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            Alias = 't3st'+ userCounter, 
            CommunityNickname = 'un1qu' + userCounter,
            Email = 't3st@t3st.c0m.t3st' + userCounter,
            IsActive = true, 
            LastName = 'Test',
            Username = 't3st@t3st.c0m.t3st' + userCounter );
    }
}