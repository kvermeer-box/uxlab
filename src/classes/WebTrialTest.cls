@isTest
private class WebTrialTest
{
    private static testMethod void testIsClosedWon_statusCodeClosedWon()
    {
        WebTrialRest.WebTrial webTrial = new WebTrialRest.WebTrial();
        webTrial.statusCode = WebTrialRest.STATUS_CLOSED_WON;

        Test.startTest();
            Boolean isClosedWon = webTrial.isClosedWon();
        Test.stopTest();

        System.assert( isClosedWon, 'The webtrial should be considered closed won' );
    }

    private static testMethod void testIsClosedWon_statusCodeCCDeclined_MonthlyBilling()
    {
        WebTrialRest.WebTrial webTrial = new WebTrialRest.WebTrial();
        webTrial.statusCode = WebTrialRest.STATUS_CC_DECLINED;
        webTrial.billingPeriod = WebTrialRest.ZUORA_BILLING_MONTHLY;

        Test.startTest();
            Boolean isClosedWon = webTrial.isClosedWon();
        Test.stopTest();

        System.assert( isClosedWon, 'The webtrial should be considered closed won' );
    }

    private static testMethod void testIsClosedWon_statusCodeExtensionPaymentUnProcessed()
    {
        WebTrialRest.WebTrial webTrial = new WebTrialRest.WebTrial();
        webTrial.statusCode = WebTrialRest.STATUS_EXTENSION_PAYMENT_UNPROCESSED;

        Test.startTest();
            Boolean isClosedWon = webTrial.isClosedWon();
        Test.stopTest();

        System.assert( isClosedWon, 'The webtrial should be considered closed won' );
    }
    
    private static testMethod void testIsClosedWon_statusCodeClosedLost()
    {
        WebTrialRest.WebTrial webTrial = new WebTrialRest.WebTrial();
        webTrial.statusCode = WebTrialRest.STATUS_CLOSED_LOST;

        Test.startTest();
            Boolean isClosedWon = webTrial.isClosedWon();
        Test.stopTest();

        System.assertEquals( false, isClosedWon, 'The webtrial should not be considered closed won' );
    }

    private static testMethod void testIsClosedWon_statusCodeCCDeclined_AnnualBilling()
    {
        WebTrialRest.WebTrial webTrial = new WebTrialRest.WebTrial();
        webTrial.statusCode = WebTrialRest.STATUS_CC_DECLINED;
        webTrial.billingPeriod = WebTrialRest.ZUORA_BILLING_ANNUAL;

        Test.startTest();
            Boolean isClosedWon = webTrial.isClosedWon();
        Test.stopTest();

        System.assertEquals( false, isClosedWon, 'The webtrial should not be considered closed won' );
    }

    private static testMethod void testIsClosedWon_statusCodeInactiveWebTrial()
    {
        WebTrialRest.WebTrial webTrial = new WebTrialRest.WebTrial();
        webTrial.statusCode = WebTrialRest.STATUS_INACTIVE_WEBTRIAL;

        Test.startTest();
            Boolean isClosedWon = webTrial.isClosedWon();
        Test.stopTest();

        System.assertEquals( false, isClosedWon, 'The webtrial should not be considered closed won' );
    }
    
}