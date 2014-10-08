@isTest
private class WeeklyForecastController_Test {

	@isTest(SeeAllData=true) 
  	static void testCreateWeeklyForecast() {
  		ApexPages.StandardController stdController = new ApexPages.StandardController(new Weekly_Forecast__c());
  		WeeklyForecastController cont = new WeeklyForecastController(stdController);
  		
 	}
  
}