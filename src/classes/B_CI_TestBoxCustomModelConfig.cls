@isTest
private class B_CI_TestBoxCustomModelConfig {

    static testMethod void testConfig() {
    	PageReference pr = Page.B_CI_BoxCustomInfluenceModelConfig;
    	Test.setCurrentPageReference(pr);
    	pr.getParameters().put('instance','0');
    	
        B_CI_BoxCustomInfluenceModelConfig config = new B_CI_BoxCustomInfluenceModelConfig();
        Test.StartTest();
        List<String> roles = config.getAvailableRoles();
        config.getRoleLabels();
        config.getTimeframeSettingByOpenSlotName();
        config.getAvailableCampaignTypes();
        config.getAvailableSalesDivisions();
        config.getOpenSlotSalesDivisions();
        config.getWeightInfoCampaign();
        config.getTimeframeInfo();
        System.Assert(config.configobject.Enabled__c==false);
        config.Save();
        system.assertEquals(roles.size(), config.getWeightInfo().size());
        
        B_CI_BoxCustomInfluenceModelConfig config2 = new B_CI_BoxCustomInfluenceModelConfig();
        config2.getAvailableRoles();
        Test.StopTest();
        
    }
}