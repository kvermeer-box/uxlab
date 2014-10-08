// Monitor task trigger
trigger SLATaskTrigger on Task (after insert, after update) {
	List<Task> taskstoprocess = new List<Task>();
	for(Task t: trigger.new)
	{
		if(t.IsClosed)
		{
			if( (trigger.isUpdate && !trigger.oldmap.get(t.id).IsClosed) || trigger.isInsert) 
				taskstoprocess.add(t);
		}
	}
	if(taskstoprocess.size()>0)
	{
		SLA_ActivitySupport.ProcessTasks(taskstoprocess);
	}
}