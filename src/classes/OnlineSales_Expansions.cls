/**
 * Implementation of OnlineSales_TransactionType for Expansions
 *
 * @author Kyle Vermeer 9/12/14
 */
public class OnlineSales_Expansions extends OnlineSales_TransactionType {

    public OnlineSales_Expansions(OnlineSales_Message message, ErrorTracker et) {
        this.et = et;
        this.message = message;
    }

    public String getTransactionType() {
        return OnlineSales_Constants.TRANSACTION_TYPE_EXPANSION;
    }

    public String getOppNameAddendum() {
        return OnlineSales_Constants.OPP_NAME_ADDENDUM_EXPANSION;
    }

    public Id getOpportunityOwnerId(Id oppId) {
        Opportunity opp = [SELECT Id, Account.OwnerId FROM Opportunity WHERE Id = :oppId LIMIT 1];
        if( Id.valueOf(opp.Account.OwnerId) == OnlineSales_Constants.getSopsToReassignUserId() ) {
            return OnlineSales_Constants.getBoxOnlineSalesUserId();
        }
        else {
            return opp.Account.OwnerId;
        }
    }

    public Id getDefaultCampaignId() {
        return OnlineSales_Constants.getExpansionCampaignId();
    }
}