public class SchedulableZuoraAccountSync implements Schedulable {
	public void execute(SchedulableContext ctx) {
		ZuoraIntegrationUtility.linkZuoraAccounts();
	}
}