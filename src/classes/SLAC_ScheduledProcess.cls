global class SLAC_ScheduledProcess implements Schedulable 
{
    
    public interface IScheduledEntry
    {
        void Execute();
    }
    
    
    global void execute(SchedulableContext SC) 
    {   
        Type schedtype = type.forName('SLAC_ScheduledProcessSupport');
        IScheduledEntry sched = (IScheduledEntry)schedtype.newInstance();
        sched.Execute(); 
    }

}