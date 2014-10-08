/**
 * This class contains helper methods for our funky handling of Conga.
 *
 * @author Kyle Vermeer <kvermeer@box.com>
 * @version 1.0
 *
 * @revision 1.0 Kyle Vermeer 2/26/2014 Intial Documentation
 */

global class CongaUtils {
    
    // Settings and Constants
    public static CongaUtilSettings__c settings = CongaUtilSettings__c.getInstance('default');
    public static String PROVISIONED_IDS = (settings == null) ? '00560000001HWN1' : settings.Provisioned_User_IDs__c;
    public static Decimal SESSION_TIMEOUT_MINUTES = (settings == null) ? 180 : settings.Session_Timeout_Minutes__c;
    
    public static Integer iteration = 0;
    
    webservice static String getBestSessionId() {
        System.debug('Attempting to get the best session id...');
        
        // Step 1: Create a set of provisioned user ids
        List<String> provisionedUserIdList = PROVISIONED_IDS.split(';');
        Set<String> provisionedUserIdSet = new Set<String>();
        provisionedUserIdSet.addAll(provisionedUserIdList);
        
        // Step 2: Get list of keys from provisioned users
        DateTime lastAcceptableLoginDateTime = DateTime.now().addMinutes(Integer.valueOf(SESSION_TIMEOUT_MINUTES * (-1)));
        List<User> provisionedUsers = [SELECT Id, Name, Secret_Key__c FROM User 
                                        WHERE Id IN :provisionedUserIdSet 
                                            // AND Provisioned_Conga_User_Last_Key_Change__c >= :lastAcceptableLoginDateTime
                                        ORDER BY Provisioned_Conga_User_Last_Key_Change__c DESC];
        System.debug('Potential keys ' + provisionedUsers.size());
        
        // Step 3: Return information
        String returnInfo;
        if (provisionedUsers != null && provisionedUsers.size() > 0) {
            System.debug('Most recent key: ' + provisionedUsers[0].Name + ' ' + provisionedUsers[0].Secret_Key__c);
            returnInfo = provisionedUsers[0].Secret_Key__c;
        } else {
            returnInfo = 'Error: Please contact salesops@box.com for assistance with generating your contract.';
        }
        return returnInfo;
    }
    
    /**
     * This method refreshes the Conga keys for provised users.
     *
     * When the running user is a provisioned Conga user, grabs the user's
     * session id and saves it in on field on the user, as well as the date
     * and time this refresh occured.
     *
     * @public
     * @static
     * @author Kyle Vermeer <kvermeer@box.com>
     * @since 1.0
     */
    public static void refreshCongaKeys() {
        if (iteration == 0) {
            iteration++;
            if (provisionedUserCheck()) {
                setSecretKeys();
            }
        }
    }

    /**
     * This method refreshes the Conga keys for provised users.
     *
     * This method lives soley to maintain backwards compatability. Calls
     * refreshCongaKeys().
     *
     * @public
     * @static
     * @author Kyle Vermeer <kvermeer@box.com>
     * @since 1.0
     */
    public static void massKeySynthesis() {
        refreshCongaKeys();
    }
    
    public static void setSecretKeys() {
        System.debug('Setting secret key(s)...');
        String sessionId = UserInfo.getSessionId();
        if (sessionId != null && !sessionId.equals('')) {           
            List<User> users = [SELECT Id, Name, Email, Secret_Key__c FROM User WHERE Id = :UserInfo.getUserId()];
            if (!sessionId.equals(users[0].Secret_Key__c)) {
                System.debug('Setting session id on user ' + users[0].Name + ' to ' + sessionId);
                users[0].Secret_Key__c = sessionId;
                users[0].Provisioned_Conga_User_Last_Key_Change__c = DateTime.now(); 
                update users[0];
            }
        }
    }
    
    public static Boolean provisionedUserCheck() {
        System.debug('Checking if user is provisioned for Conga...');
        Boolean provisioned = false;
        String currentUserId = UserInfo.getUserId().substring(0, 15);
        if (PROVISIONED_IDS != null) {
            List<String> provisionedIdList = PROVISIONED_IDS.split(';');
            if (currentUserId != null) {
                for (String s : provisionedIdList) {
                    if (currentUserId.equals(s)) {
                        System.debug('User is a provisioned Conga user!');
                        provisioned = true;
                        break;
                    }
                }
            }
            if (!provisioned) {
                System.debug('User is NOT a provisioned Conga user.');  
            }
        }
        return provisioned;
    }


    
    
    
}