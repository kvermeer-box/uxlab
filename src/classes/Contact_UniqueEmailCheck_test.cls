/**
 * Test class for Contact_UniqueEmailCheck
 *
 * @author Kyle Vermeer 9/25/14
 */
@isTest
private class Contact_UniqueEmailCheck_test {
    
    @isTest static void insertCheckDatabase() {
        Account acc = new Account(Name = 'Boxing Greats, Inc.');
        insert acc;

        Contact george = new Contact(LastName = 'George', Email = 'george@foreman.com', AccountId = acc.Id);
        // This should succeed
        insert george;

        Contact ali = new Contact(LastName = 'Ali', Email = 'cassius@ali.com', AccountId = acc.Id);
        // This should succeed
        insert ali;

        Test.startTest();
            Contact foreman = new Contact(LastName = 'George', Email = 'george@foreman.com', AccountId = acc.Id);
            Contact rocky = new Contact(LastName = 'Rocky', Email = 'italianStallion@balboa.com', AccountId = acc.Id);
            boolean didFail = false;
            try {
                insert new Contact[] { foreman, rocky };
            } 
            catch( Exception e ) {
                didFail = true;
            }
        Test.stopTest();

        System.assert(didFail, 'Inserting a second contact with the same e-mail should have failed!');
    }

    @isTest static void insertCheckMemory() {
        Account acc = new Account(Name = 'Boxing Greats, Inc.');
        insert acc;

        Test.startTest();
            Contact foreman = new Contact(LastName = 'George', Email = 'george@foreman.com', AccountId = acc.Id);
            Contact foreman2 = new Contact(LastName = 'George', Email = 'george@foreman.com', AccountId = acc.Id);
            boolean didFail = false;
            try {
                insert new Contact[] { foreman, foreman2 };
            } 
            catch( Exception e ) {
                didFail = true;
            }
        Test.stopTest();

        System.assert(didFail, 'Inserting a second contact with the same e-mail should have failed!');
    }

    @isTest static void updateCheckDatabase() {
        Account acc = new Account(Name = 'Boxing Greats, Inc.');
        insert acc;

        Contact george = new Contact(LastName = 'George', Email = 'george@foreman.com', AccountId = acc.Id);
        // This should succeed
        insert george;

        Contact ali = new Contact(LastName = 'Ali', Email = 'cassius@ali.com', AccountId = acc.Id);
        // This should succeed
        insert ali;

        Test.startTest();
            ali.Email = 'george@foreman.com';
            boolean didFail = false;
            try {
                update ali;
            }
            catch( Exception e ) {
                didFail = true;
            }
        Test.stopTest();

        System.assert(didFail, 'Update a contact to an exisiting email should have failed');
    }

    @isTest static void fccrmUpdateCheck() {
        Account acc = new Account(Name = 'Boxing Great, Inc.');
        insert acc;

        Contact george = new Contact(LastName = 'George', Email = 'george@foreman.com', AccountId = acc.Id);
        // This should succeed
        insert george;

        Contact ali = new Contact(LastName = 'Ali', Email = 'cassius@ali.com', AccountId = acc.Id);
        // This should succeed
        insert ali;

        Contact george2 = new Contact(LastName = 'George', Email = 'george@foreman.com', AccountId = acc.Id, FCRM__FCR_Admin_Update_Counter__c = 1);

        boolean didFail = false;
        try {
            insert george2;
        }
        catch( Exception e ) {
            didFail = true;
        }

        System.assert(!didFail, ' Inserting a copy contact should not have failed as we incremented the FCCRM Admin Counter');

        try {
            ali.Email = 'george@foreman.com';
            ali.FCRM__FCR_Admin_Update_Counter__c = 1;
            update ali;
        }
        catch( Exception e ) {
            didFail = true;
        }

        System.assert(!didFail, 'Updating an email to a already used email should not have failed as we incremented the FCCRM Admin Counter');
        
    }

    @isTest static void updateCheckMemory() {
        Account acc = new Account(Name = 'Boxing Greats, Inc.');
        insert acc;

        Contact george = new Contact(LastName = 'George', Email = 'george@foreman.com', AccountId = acc.Id);
        // This should succeed
        insert george;

        Contact ali = new Contact(LastName = 'Ali', Email = 'cassius@ali.com', AccountId = acc.Id);
        // This should succeed
        insert ali;

        Test.startTest();
            ali.Email = 'italianStallion@balboa.com';
            george.Email = 'italianStallion@balboa.com';
            boolean didFail = false;
            try {
                update new Contact[] { ali, george };
            }
            catch( Exception e ) {
                didFail = true;
            }
        Test.stopTest();

        System.assert(didFail, 'Two contacts updating to the same email should have failed!');
    }



    @isTest static void updateCheckMemoryDoubleSwitch() {
        Account acc = new Account(Name = 'Boxing Greats, Inc.');
        insert acc;

        Contact george = new Contact(LastName = 'George', Email = 'george@foreman.com', AccountId = acc.Id);
        // This should succeed
        insert george;

        Contact ali = new Contact(LastName = 'Ali', Email = 'cassius@ali.com', AccountId = acc.Id);
        // This should succeed
        insert ali;

        Test.startTest();
            george.Email = 'cassius@ali.com';
            ali.Email = 'george@foreman.com';
            boolean didFail = false;
            try {
                update new Contact[] { george, ali };
            }
            catch( Exception e ) {
                System.debug('Exception: ' + e);
                didFail = true;
            }
        Test.stopTest();

        System.assert(!didFail, 'Should not have failed, both emails were switched to unique emails!');
    }
}