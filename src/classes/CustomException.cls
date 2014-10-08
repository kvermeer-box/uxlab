global class CustomException extends Exception {

	public CustomException(String message, String[] recipients) {		
		this(message);		
		sendEmailNotification(recipients);
		System.debug('Error caught: ' + getStackTraceString() + ': ' + getMessage());				
	}

	private void sendEmailNotification(String[] recipients) {
		if (recipients != null && recipients.size() > 0) {
			String body = 'Courtesy notification: Apex script unhandled exception by user: ' + UserInfo.getName() + ', ' + UserInfo.getUserId() + '\n'
						+ getStackTraceString() + ': ' + getMessage();			
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setToAddresses(recipients);
			mail.setReplyTo(recipients[0]);
			mail.setSenderDisplayName('Apex Error');
			mail.setSubject('Salesforce APEX error');
			mail.setPlainTextBody(body);
			mail.setUseSignature(false);
			mail.setSaveAsActivity(false);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
		}
	}

}