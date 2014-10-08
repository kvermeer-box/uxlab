trigger LeadReferrerCompanyTrigger on Lead (before insert, before update) {
	Lead[] leads = Trigger.new;
	LeadReferrerCompanyHandler.popReferrerCompany(leads);
}