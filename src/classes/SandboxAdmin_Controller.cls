/**
 * Controller for the SandboxAdmin page
 *
 * @author Kyle Vermeer 7/23/14
 */
public class SandboxAdmin_Controller {

    public class SandboxView {
        public String name { get; set; }
        public String description { get; set; }
        public Date lastRefreshDate { get; set; }
        public String id { get; set; }
        public SandboxMemberView[] sandboxMembers { get; set; }

        public SandboxView(String id, String name, String description, Date lastRefreshDate, Sandbox_Member__c[] sandboxMembers) {
            this.id = id;
            this.name = name;
            this.description = description;
            this.lastRefreshDate = lastRefreshDate;
            this.sandboxMembers = new SandboxMemberView[] {};
            if (sandboxMembers != null) {
                for (Sandbox_Member__c currentMember : sandboxMembers) {
                    SandboxMemberView view = new SandboxMemberView(currentMember.Id, currentMember.Display_Name__c);
                    if (currentMember.User__c != null) {
                        view.photoURL = currentMember.User__r.SmallPhotoURL;
                    }
                    this.sandboxMembers.add(view);
                }
            }
        }

    }

    public class SandboxMemberView {
        public String displayName { get; set; }
        public String id { get; set; }
        public String photoURL { get; set; }

        public SandboxMemberView(String id, String displayName) {
            this.id = id;
            this.displayName = displayName;
        }
    }

    private SandboxView[] sandboxes;

	public SandboxAdmin_Controller() {
		init();
	}

    private void init() {
        // Initalize sandboxes
        sandboxes = new SandboxView[]{};
        Sandbox__c[] allSandboxes = [SELECT Id, Name, Description__c, Sandbox_Last_Refresh_Date__c, (SELECT Sandbox_Member__c.Id, Sandbox_Member__c.Display_Name__c, Sandbox_Member__c.User__c, Sandbox_Member__c.User__r.SmallPhotoURL FROM Sandbox__c.Sandbox_Members__r ORDER BY Sandbox_Member__c.CreatedDate) FROM Sandbox__c WHERE Active__c = true];
        for (Sandbox__c currentSandbox: allSandboxes) {
            SandboxView view = new SandboxView(currentSandbox.Id, currentSandbox.Name, currentSandbox.Description__c, currentSandbox.Sandbox_Last_Refresh_Date__c, currentSandbox.Sandbox_Members__r);
            sandboxes.add(view);
        }
    }

    public SandboxView[] getSandboxes() {
        return this.sandboxes;
    }

    @RemoteAction
    public static String getUsers(String prefix) {
        JSONGenerator gen = JSON.createGenerator(true);
        User[] users = new User[]{};
        if (prefix.containsWhitespace()) {
            users = [SELECT Id, Name
                       FROM User
                      WHERE Name Like :(prefix + '%')
                        AND isActive = true];
        }
        else {
            users = [SELECT Id, Name 
                          FROM User
                         WHERE (FirstName LIKE :(prefix + '%')
                                OR LastName LIKE :(prefix + '%'))
                           AND isActive = true];
        }
        String[] userNames = new String[] {};
        gen.writeStartObject();
        gen.writeStringField('search_value', prefix);
        gen.writeFieldName('results');
        gen.writeStartArray();
        for (User currentUser : users) {
            gen.writeStartObject();
            gen.writeStringField('Name', currentUser.Name);
            gen.writeStringField('Id', currentUser.Id);
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeEndObject();
        return gen.getAsString();
    }

    /**
     * Add a sandbox member to a sandbox.
     *
     * @param String userEmailSandbox - semi-colon delimited string of userId, non-user email, and sandbox id
     * @return String - json response
     */
    @RemoteAction
    public static String createSandboxMember(String userEmailSandbox) {
        Boolean success = true;
        String errorMessage = null;
        if (userEmailSandbox == null) {
            return '{ "success" : false, "error" : "Null input provided" }';
        }
        String[] inputs = userEmailSandbox.split(';');
        Integer parts = inputs.size();
        if (parts != 3) {
            return '{ "success" : false, "error" : "Input had ' + parts + ' parts.  It should have 3" }';
        }
        String userId = inputs[0];
        String nonUserEmail = inputs[1];
        String sandboxId = inputs[2];
        if( sandboxId == null || sandboxId == '' ) {
            return '{ "success" : false, "error" : "Sandbox Id was null" }';
        }
        else {
            Sandbox_Member__c newMember = new Sandbox_Member__c(Sandbox__c = sandboxId);
            if( userId != null && userId != '' && userId != 'null') {
                newMember.User__c = userId;
            }
            else if( nonUserEmail != null && nonUserEmail != '' ) {
                newMember.Non_User_Email__c = nonUserEmail;
            }
            else {
                return '{ "success" : false, "error" : "Both userId and NonUserEmail were null" }';
            }
            insert newMember;
            Sandbox_Member__c sandboxMember = [SELECT Id, Display_Name__c, User__c, User__r.SmallPhotoURL 
                                                 FROM Sandbox_Member__c 
                                                WHERE Id = :newMember.Id 
                                                LIMIT 1];
            return '{ "success" : true, "sandboxMember" : { "name" : "' + sandboxMember.Display_Name__c + '", "photoURL" : "' + sandboxMember.User__r.SmallPhotoURL + '", "id" : "' + sandboxMember.Id + '"} }';
        }
    }

    @RemoteAction
    public static String sendWarningEmail(String sandboxId) {
        Boolean success = true;
        String errorMessage = null;
        if (sandboxId == null) {
            return '{ "success" : false, "error" : "Null input provided" }';
        }
        Sandbox__c sandbox     = [SELECT Id, Name, Description__c, Sandbox_Last_Refresh_Date__c, 
                                          (SELECT Sandbox_Member__c.Id, Sandbox_Member__c.Display_Name__c, Sandbox_Member__c.Email__c
                                             FROM Sandbox__c.Sandbox_Members__r 
                                         ORDER BY Sandbox_Member__c.CreatedDate) 
                                    FROM Sandbox__c 
                                   WHERE Id = :sandboxId 
                                   LIMIT 1];
        String[] toAddresses = new String[] { UserInfo.getUserEmail() };
        for (Sandbox_Member__c currentSandboxMember : sandbox.Sandbox_Members__r) {
            if( currentSandboxMember.Email__c != null ) {
                toAddresses.add(currentSandboxMember.Email__c);
            }
        }
        // send email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setHtmlBody('<p>Hey all,</p><p style="margin-top:20px;">I\'m going to refresh the sandbox \'' + sandbox.Name + '\'.' +
                           ' Please let me know if you need to prevent this refresh for any reason!</p>' +
                           '<p style="margin-top:20px;">Thanks,</p>' +
                           '<p style="margin-top:20px;">' + UserInfo.getFirstName() +'</p>');
        email.setToAddresses( toAddresses );
        email.setSubject('Refreshing \'' + sandbox.Name + '\' Sandbox Warning');
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email }, false);   
        }
        return '{ "success" : ' + success + ' }';
    }

    @RemoteAction
    public static String refreshSandbox(String sandboxId) {
        Boolean success = true;
        String errorMessage = null;
        if (sandboxId == null) {
            return '{ "success" : false, "error" : "Null input provided" }';
        }
        Sandbox__c sandbox = [SELECT Id, Name, Active__c, Description__c FROM Sandbox__c WHERE Id = :sandboxId];
        sandbox.Active__c = false;
        update sandbox;
        Sandbox__c newSandbox = new Sandbox__c(Name = sandbox.Name, Description__c = sandbox.Description__c, Sandbox_Last_Refresh_Date__c = Date.today() );
        insert newSandbox;
        return '{ "success" : ' + success + ' }';
    }
}