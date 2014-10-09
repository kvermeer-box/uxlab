/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest()
private class InAppRestTest {

    static testMethod void myUnitTest() {
    	// This is the data Eric will send over
        InAppRest.InApp i = new InAppRest.InApp();
        i.enterpriseId = String.valueOf((Math.random() * 100000000.0).intValue());
		i.email = 'e@e.com' + String.valueOf(Math.random() * 1000000000.0);
		i.readOnly = false;
		i.seatsSold = '1';
		i.gbSold = '2';
		i.priorAccountTypeCategory = 'dell_individual';
		i.arr = '450';
		i.paymentMethodType = 'CreditCard';
		i.feeFrequency = 'Three Years';
		i.subscriptionStatus = 'Active';
		i.lastTransactionStatus = 'Approved';
		i.lastPaymentDate = '05/28/1987 10:47 AM';
		i.eventDate = '05/28/1987 11:46 AM';
		i.lastPaymentStatus = 'Processed';
		
		// This is the data we will send back to Eric
		InAppRest.InApp inAppResult = InAppRest.processInAppUpgrade(i);
		
		// Make sure everything is lined up
		System.assert(inAppResult.statusCode.equals(InAppRest.CLOSED_WON_STATUS_CODE));
		//System.assert(inAppResult.errorMsg == null);
		System.assert(inAppResult.opportunityId != null);
		System.assert(inAppResult.accountId != null);
		System.assert(inAppResult.accountName.equals(i.email));
		//System.assert(inAppResult.accountOwnerId.contains(InAppRest.DEFAULT_OBJECTS_OWNER_ID));
		System.assert(inAppResult.accountOwnerName != null);
    }
}