global class Territory_MailmanUtils {

	webservice static String routeToMailman(String leadId) {
		System.debug('Territory_MailmanUtils: Routing lead ' + leadId + ' to mailman...');
		
		Lead lead = new Lead(Id = leadId);
		String ownerId = Territory_CustomSettings.getMailmanId();
		if (ownerId != null) { lead.ownerId = ownerId; }		
		lead.Status = Label.Territory_MailmanTransitStatus;
		update lead;
		return leadId;
	} 

}