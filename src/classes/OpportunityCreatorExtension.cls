public class OpportunityCreatorExtension {
    
    private final Contact ct;  
    private String m_InitialURL;

    
    public OpportunityCreatorExtension(ApexPages.StandardSetController stdController) {
        stdController.SetPageSize(10);
        PageReference pageRef = stdController.cancel();
        String PriorURL = pageRef.getURL();
        String pageid = pageRef.getParameters().get('id');
        if (pageid==null)
        {
            pageid = PriorURL.substring(PriorURL.lastIndexOf('/')+1);
            if(pageid.contains('?')) pageid = pageid.substring(0, pageid.indexOf('?'));
        }
        m_InitialURL = EncodingUtil.urlEncode(URL.getSalesforceBaseURL().toExternalForm() + '/' + pageid, 'UTF-8');

        System.debug(pageid);
        
        this.ct = [SELECT AccountId, LeadSource FROM Contact WHERE Id = :pageid LIMIT 1];
        
    }
    
    public STring getParamQuerySTring() {
        
        PageReference pageRef = ApexPages.currentPage();
        String plval='';
        if(ct.LeadSource != null)
        {
            plval = '&opp6=' + EncodingUtil.urlEncode(ct.LeadSource, 'UTF-8');
        }
        Account act = [SELECT Name from Account WHERE Id = :ct.AccountID LIMIT 1];
        String acname = '';
        if (act != null)
        {
            acname = '&opp3=' + EncodingUtil.urlEncode(act.Name + ' -', 'UTF-8');
            acname = acname += ('&accid=' + act.Id);
        }
        String finalparamstring = '&lookupcmpgn=1&conid=' + ct.id + acname + plval + '&retURL=' + m_InitialURL;
        return finalparamstring;
     }
     
}