/**
 * Mock class for testing the OnlineSales_TransactionType abstract class
 *
 * @author Kyle Vermeer 9/10/14
 */
public class OnlineSales_MockTransactionType extends OnlineSales_TransactionType {

    private static final String MOCK_TRANSACTION_TYPE = 'Mock';
    private static final String MOCK_OPP_NAME_ADDENDUM = ' Mock Request';

    private static Campaign defaultCampaign;

    public OnlineSales_MockTransactionType(OnlineSales_Message message) {
        this.message = message;
    }

    public String getTransactionType() {
        return MOCK_TRANSACTION_TYPE;
    }

    public String getOppNameAddendum() {
        return MOCK_OPP_NAME_ADDENDUM;
    }

    public Id getRecordOwnerId(Id accountId) {
        return UserInfo.getUserId();
    }

    public Id getDefaultCampaignId() {
        if( defaultCampaign == null ) {
            defaultCampaign = new Campaign(Name = 'Mock Transaction Type Campaign', isActive =  true);
            insert defaultCampaign;
        }
        return defaultCampaign.Id;
    }
}