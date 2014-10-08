/**
 * An implementation of OnlineSales_TransactionType
 *
 * @author Kyle Vermeer 9/9/14
 */
public class OnlineSales_Upgrades extends OnlineSales_TransactionType {

    public OnlineSales_Upgrades(OnlineSales_Message message, ErrorTracker et) {
        this.et = et;
        this.message = message;
    }

    public String getTransactionType() {
        return OnlineSales_Constants.TRANSACTION_TYPE_UPGRADE;
    }

    public String getOppNameAddendum() {
        return OnlineSales_Constants.OPP_NAME_ADDENDUM_UPGRADE;
    }

    public Id getDefaultCampaignId() {
        return OnlineSales_Constants.getInAppUpgradeCampaignId();
    }

    public Id getOpportunityOwnerId(Id oppId) {
        return OnlineSales_Constants.getBoxOnlineSalesUserId();
    }
}