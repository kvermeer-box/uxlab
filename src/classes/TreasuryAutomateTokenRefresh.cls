public class TreasuryAutomateTokenRefresh{

    public String getGetDebugText() {
        return debugTxt;
        
    }
    
    public String debugTxt = 'Start debug: ';


    public void scheduleRefresh(){
        //create instance of schedulable token refresh class, schedule for every hour at 10 and 40 minutes (every 30 min)
        scheduledTokenRefresh sTR = new scheduledTokenRefresh();
        String sch1 = '0 10 * * * ?';
        String sch2 = '0 40 * * * ?';
        String jobID1 = system.schedule('Refresh Token 10', sch1, sTR);        
        String jobID2 = system.schedule('Refresh Token 40', sch2, sTR); 
        
        debugTxt = (jobID1 + ' ' + jobID2);    
    }
       
}