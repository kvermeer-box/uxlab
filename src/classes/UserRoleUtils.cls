/**
 * UserRoleUtils
 *
 * Description:
 *   This class contains utility methods for parsing information out of a User's role name.
 *
 * Public API:
 *
 *   static String getSegment(String userRoleName)
 *   static String getTheater(String userRoleName)
 *   static String getTeam(String userRoleName)
 *   static String getSDRRoleIdentifier()
 *   static String getOBRRoleIdentifier()
 *   static String getNIRRoleIdentifier()
 *
 * Revision History:
 *
 *   Kyle Vermeer         1/16/2014        Initial Creation
 *   Kyle Vermeer         2/25/2014        Added sdr,obr,nir methods
 *
 */

public class UserRoleUtils {

    public static String RENEWAL_SALES_DIVISION = 'Renewal';

    private static User_Role_Settings__c settings = CustomSettings.getUserRoleSettings();

    /* Lazy instantiation of properties */

    private static List<String> segmentList {
        get {
            if (segmentList == null) {
                segmentList = settings.Segments__c.split(';');
            }
            return segmentList;
        }
    }

    private static List<String> theaterList {
        get {
            if (theaterList == null) {
                theaterList = settings.Theaters__c.split(';');
            }
            return theaterList;
        }
    }

    private static List<String> teamList {
        get {
            if (teamList == null) {
                teamList = settings.Teams__c.split(';');
            }
            return teamList;
        }
    }
    

    /* Public API */

    /**
     * Method: getSegment()
     * Description:
     *   Returns the segment of the provided userRoleName.
     * Inputs:
     *   String userRoleName - Name of role from which we are grabbing the segment
     * Return:
     *   String - segment from userRoleName
     */
    public static String getSegment(String userRoleName) {
        // Check for null input
        if (userRoleName == null) {
            System.debug('Null userRoleName provided.');
            return null;
        }
        // Iterate through segments looking for match
        for (String currentSegment : segmentList) {
            if (userRoleName.contains(currentSegment)) {
                // Return first match
                return currentSegment;
            }
        }
        // Nothing was found, return null
        System.debug('No Segment could be found for User Role: ' + userRoleName);
        return null;
    }

    /**
     * Method: getTheater()
     * Description:
     *   Returns the theater of the provided userRoleName.
     * Inputs:
     *   String userRoleName - Name of role from which we are grabbing the theater
     * Return:
     *   String - theater from userRoleName
     */
    public static String getTheater(String userRoleName) {
        // Check for null input
        if (userRoleName == null) {
            System.debug('Null userRoleName provided.');
            return null;
        }
        // Iterate through segments looking for match
        for (String currentTheater : theaterList) {
            if (userRoleName.contains(currentTheater)) {
                // Return first match
                return currentTheater;
            }
        }
        // Nothing was found, return null
        System.debug('No Theater could be found for User Role: ' + userRoleName);
        return null;
    }

    /**
     * Method: getTeam()
     * Description:
     *   Returns the team of the provided userRoleName.
     * Inputs:
     *   String userRoleName - Name of role from which we are grabbing the team
     * Return:
     *   String - team from userRoleName
     */
    public static String getTeam(String userRoleName) {
        String longestMatch = null;
        // Check for null input
        if (userRoleName == null) {
            System.debug('Null userRoleName provided.');
            return null;
        }
        // Iterate through teams looking for match
        for (String currentTeam : teamList) {
            if (userRoleName.contains(currentTeam)) {
                if (longestMatch == null) { // If first match, assign to longestMatch
                    longestMatch = currentTeam;
                }
                else if (currentTeam.length() > longestMatch.length()) { // More specific team
                    longestMatch = currentTeam;
                }
            }
        }
        // Return the longest match found, could be null
        return longestMatch;
    }

    /**
     * Returns the string that identifies an SDR's role.
     *
     * @return {string} String identifying SDR's role.
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    public static String getSDRRoleIdentifier() {
        return settings.SDR_Identifier__c;
    }

    /**
     * Returns the string that identifies an OBR's role.
     *
     * @return {string} String identifying OBR's role.
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    public static String getOBRRoleIdentifier() {
        return settings.OBR_Identifier__c;
    }

    /**
     * Returns the string that identifies an NIR's role.
     *
     * @return {string} String identifying NIR's role.
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    public static String getNIRRoleIdentifier() {
        return settings.NIR_Identifier__c;
    }
}