/**
 * Box Online Sales Transaction Type for Web Trial Closeouts
 *
 * @author Kyle Vermeer 08/29/2014
 */
public class OnlineSales_WebTrialCloseout {
    public OnlineSales_WebTrialCloseout() {
        
    }

    public OnlineSales_Constants.TransactionResult processMessage(OnlineSales_Message message, ErrorTracker et) {
        // TODO: Implement
        return OnlineSales_Constants.TransactionResult.SUCCESS;
    }

    private void legacyCloseout(OnlineSales_Message message, ErrorTracker et) {
        createOldWebTrial(message);
    }

    private WebTrialRest.WebTrial createOldWebTrial(OnlineSales_Message message) {
        WebTrialRest.WebTrial wt = new WebTrialRest.WebTrial();
        wt.email = message.userLogin;
        wt.isDeactivated = message.isDeactivated;
        DateTime trailEndDateTime = DateTime.newInstance(message.trialEndDate);
        wt.trialEnd = Date.newInstance(trailEndDateTime.year(), trailEndDateTime.month(), trailEndDateTime.day());
        return wt;
    }
}