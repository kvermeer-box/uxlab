public with sharing class LeadTestFactory {
    public static Lead buildLead( String enterpriseId, String email )
    {
        Lead lead = new Lead
            ( LastName = 'The Mamas & The Papas'
            , Company = 'Initech'
            , Email = email
            , Box_Enterprise_ID__c = enterpriseId
            );
        return lead;
    }

    public static Lead createLead( String enterpriseId, String email )
    {
        Lead lead = buildLead( enterpriseId, email );
        insert lead;
        return lead;
    }
}