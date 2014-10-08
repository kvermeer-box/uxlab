@isTest
private class Domain_Utilities_test {
    
    @isTest static void getFullDomainTest() {
        ////////////////////////////////////////////////////////////
        // Emails to Test:                  | Expected Outcome     |
        // --------------------------------------------------------|
        // kvermeer@box.com                 | box.com              |
        // blah123@mail.box.xxx             | mail.box.xxx         |
        // savyDogpp@test.long.domain.org   | test.long.domain.org |
        // kyle                             | null                 |
        // kyle@                            | null                 |
        // kyle@fox                         | null                 |      
        // ''                               | null                 |
        // null                             | null                 |
        ////////////////////////////////////////////////////////////
        System.assertEquals('box.com', Domain_Utilities.getFullDomain('kvermeer@box.com'));
        System.assertEquals('mail.box.xxx', Domain_Utilities.getFullDomain('blah123@mail.box.xxx'));
        System.assertEquals('test.long.domain.org', Domain_Utilities.getFullDomain('savyDoggpp@test.long.domain.org'));
        System.assertEquals(null, Domain_Utilities.getFullDomain('kyle'));
        System.assertEquals(null, Domain_Utilities.getFullDomain('kyle@'));
        System.assertEquals(null, Domain_Utilities.getFullDomain('kyle@fox'));
        System.assertEquals(null, Domain_Utilities.getFullDomain(''));
        System.assertEquals(null, Domain_Utilities.getFullDomain(null));
    }
    
    @isTest static void getBaseDomainTest() {
        ////////////////////////////////////////////////////////////
        // Emails to Test:                  | Expected Outcome     |
        // --------------------------------------------------------|
        // kvermeer@box.com                 | box.com              |
        // blah123@mail.box.xxx             | box.xxx              |
        // savyDogpp@test.long.domain.org   | domain.org           |
        // kyle                             | null                 |
        // kyle@                            | null                 |
        // kyle@fox                         | null                 |      
        // ''                               | null                 |
        // null                             | null                 |
        ////////////////////////////////////////////////////////////
        System.assertEquals('box.com', Domain_Utilities.getBaseDomain('kvermeer@box.com'));
        System.assertEquals('box.xxx', Domain_Utilities.getBaseDomain('blah123@mail.box.xxx'));
        System.assertEquals('domain.org', Domain_Utilities.getBaseDomain('savyDoggpp@test.long.domain.org'));
        System.assertEquals(null, Domain_Utilities.getBaseDomain('kyle'));
        System.assertEquals(null, Domain_Utilities.getBaseDomain('kyle@'));
        System.assertEquals(null, Domain_Utilities.getBaseDomain('kyle@fox'));
        System.assertEquals(null, Domain_Utilities.getBaseDomain(''));
        System.assertEquals(null, Domain_Utilities.getBaseDomain(null));
    }

}