global class SLA_ScheduledProcess implements Schedulable 
{
	// This rather awkward approach for calling the underlying functionality is required
	// to allow other classes to update even when this class is scheduled.
	
	public interface IScheduledEntry
	{
		void Execute();
	}
	
	
	global void execute(SchedulableContext SC) 
	{	
		Type schedtype = type.forName('SLA_ScheduledProcessSupport');
		IScheduledEntry sched = (IScheduledEntry)schedtype.newInstance();
		sched.Execute(); 
	}

}