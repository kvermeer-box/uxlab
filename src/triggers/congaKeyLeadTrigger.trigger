trigger congaKeyLeadTrigger on Lead (before insert, before update) {
	CongaUtils.massKeySynthesis();
}