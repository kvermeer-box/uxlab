public class SelectorBoxController {

    private List<Opportunity> qualifiedOpps;

    public Boolean qualifiedOppsExist {
        public get {
            if (qualifiedOpps.size() > 0) {
                return true;
            }
            else {
                return false;
            }
        }
    }

    public class OpportunityInfoView {

        public OpportunityInfoView(String name, String id) {
            this.name = name;
            this.id = id;
        }

        public String name { get; private set; }
        public String id { get; private set; }
    }
    
    public SelectorBoxController() {
        Id userId = UserInfo.getUserId();
        List<Opportunity> opps = [SELECT Id, Name
                                    FROM Opportunity
                                   WHERE OwnerId = :userId
                                     AND isClosed = false];
        List<Opportunity> accountTeamOpps = new List<Opportunity>();
        List<Account> accountsOfWhichUserIsTeamMember = [SELECT Id
                                                           FROM Account
                                                          WHERE Id in (SELECT AccountId
                                                                         FROM AccountTeamMember
                                                                        WHERE UserId = :userId)];
        if (accountsOfWhichUserIsTeamMember != null && accountsOfWhichUserIsTeamMember.size() > 0) {
            accountTeamOpps = [SELECT Id, Name
                                 FROM Opportunity
                                WHERE AccountId in :accountsOfWhichUserIsTeamMember
                                  AND isClosed = false];
            opps.addAll(accountTeamOpps);
        }
        List<Id> oppIds = new List<Id>();
        for (Opportunity currentOpp : opps) {
            oppIds.add(currentOpp.Id);
        }
        qualifiedOpps = BoxOutUtils.getQualfiedBoxOutOpps(oppIds);
        if (qualifiedOpps == null) {
            qualifiedOpps = new List<Opportunity>();
        }
    }

    public OpportunityInfoView[] getQualifiedOppInfo() {
        List<OpportunityInfoView> oppInfoViews = new List<OpportunityInfoView>();
        for (Opportunity opp : qualifiedOpps) {
            OpportunityInfoView infoView = new OpportunityInfoView(opp.Name, opp.Id);
            oppInfoViews.add(infoView);
        }
        return oppInfoViews;
    }
}