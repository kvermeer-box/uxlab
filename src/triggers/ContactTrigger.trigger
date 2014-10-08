// Centralizes code that's executed in contact trigger - available for reuse
trigger ContactTrigger on Contact (after update) {
	if (trigger.isAfter && trigger.isUpdate)
	{
		ContactReassigner.requestHandler(trigger.newMap);
	}
}