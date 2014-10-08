public class SLAC_ScheduledProcessSupport implements SLAC_ScheduledProcess.IScheduledEntry {

    public void Execute()
    {
        while (!HandleSLAExpiredContacts());
    }

    public static DateTime ForceExpirationFortest = null;

    public static Boolean HandleSLAExpiredContacts() 
    {
        DateTime expiration = (Test.isRunningTest() && ForceExpirationForTest!=null)? ForceExpirationForTest: DateTime.Now();
                
        String querystring = 'Select ID, First_SLA_End__c, Second_SLA_End__c, FCRM__FCR_Status__c, Disqualified_Reason__c ' +
            'from Contact Where ' +
            '(FCRM__FCR_Status__c = \'Open - Not Contacted\' or FCRM__FCR_Status__c = \'Attempting Contact\' or FCRM__FCR_Status__c = \'Working\' ) ' +
            'And SLA_Expiration_Date__c <= :expiration Limit 200';  
        system.debug('xx' + querystring);     
        Map<ID, Contact> expiredcontacts = new Map<ID, Contact>((List<Contact>)Database.query(querystring));
        
        if (expiredcontacts.size() > 0)
        {
            for (Contact ct : expiredcontacts.values())
            {
                // Clear SLA fields for contacts with Second (Long-Term) SLA expiration     
                if (ct.FCRM__FCR_Status__c == 'Attempting Contact' || ct.FCRM__FCR_Status__c == 'Working')
                {
                    ct.Second_SLA_End__c = null;
                    ct.SLA_Type__c = null;
                }               
                
                // Disqualify contacts with both First (Short-Term) and Second (Long-Term) SLA expiration
                ct.FCRM__FCR_Status__c = 'Disqualified';
                ct.Disqualified_Reason__c = 'SLA Expired';                      
            }           
            update expiredcontacts.values();    
        }   
        
        if (expiredcontacts.size()==200) return false;
        return true;        
    } 

}