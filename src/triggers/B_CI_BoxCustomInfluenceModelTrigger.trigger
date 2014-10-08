trigger B_CI_BoxCustomInfluenceModelTrigger on FCRM__FCR_APIHookTrigger__c (after insert) {
    FCRM__FCR_APIHookTrigger__c hookobject = trigger.new[0];
    if(hookobject.FCRM__Hook_Type__c == 'campaigninfluence')
    {
        B_CI_BoxCustomInfluenceModel plugin = new B_CI_BoxCustomInfluenceModel();
        FCRM.FCR_CampaignInfluenceAPI.RegisterPlugin(plugin);    
    }
}