public class TerritoryAssignment {

	public static boolean isEnabled(){

		boolean enabled=false;

		Territory_Settings__c territorySettings = Territory_Settings__c.getInstance();
		
		if(territorySettings!=null && territorySettings.Enabled__c){
			enabled=true;
		}


		if(Test.isRunningTest()){
			enabled = true;
		}


		return enabled;

	}
}