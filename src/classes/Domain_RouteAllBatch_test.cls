/**
 * Test class for Domain_RouteAllBatch
 *
 * @author Kyle Vermeer 7/24/14
 */
@isTest
private class Domain_RouteAllBatch_test {
    
    @isTest static void batch_test() {
        // Implement test code
        Lead l = new Lead(LastName = 'Cat', Company= 'Cat Co.', Email = 'Kyle@cat.com');
        insert l;
        Test.startTest();
        Domain_RouteAllBatch batch = new Domain_RouteAllBatch();
        Database.executeBatch(batch);
        Test.stopTest();
    }
    
}