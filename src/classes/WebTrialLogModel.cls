public with sharing class WebTrialLogModel
{
	public Web_Trial_Log__c currentLog;
	
	public WebTrialLogModel( Web_Trial_Log__c webTrialLog )
	{
		this.currentLog = webTrialLog;
	}
	
	public void setErrorFields( String exceptionMessage, WebTrialRest.WebTrial webTrial )
	{
		currentLog.Exception_Message__c = exceptionMessage; 
		currentLog.errorMsg__c = webTrial.errorMsg;
		currentLog.Success__c = false;
	}
	
	public void setSuccess()
	{
		currentLog.Success__c = true;
	}

	public void setStatusCode( WebTrialRest.WebTrial webTrial )
	{
		currentLog.statusCode__c = webTrial.statusCode;
	}

	public void setIdFields( WebTrialRest.WebTrial webTrial )
	{
		currentLog.Account__c = webTrial.accountId;
		currentLog.accountName__c = webTrial.accountName;
		currentLog.Opportunity__c = webTrial.opportunityId;
		currentLog.ownerName__c = webTrial.ownerName;
	}
	
	public void setContactId( Id contactId )
	{
		currentLog.Contact__c = contactId;
	}
	
	public void setLeadId( Id leadId )
	{
		currentLog.Lead__c = leadId;
	}
}