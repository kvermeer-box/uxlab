public with sharing class WeeklyForecastController {

	public final Weekly_Forecast__c weeklyForecast    {get;set;}
	
	public WeeklyForecastController(ApexPages.StandardController stdController) {
		this.weeklyForecast = (Weekly_Forecast__c)stdcontroller.getRecord();
		
		Date d = Date.today();
		Date weekStart = d.toStartofWeek();
		Datetime dTime = (Datetime) weekstart;
		
		//Returns Day number of week (1 = Monday, ..., 7 = Sunday)	
		String dayOfWeek = dTime.format('u');
		if (!dayofWeek.equals('1')) {
			weekStart = weekStart.addDays(1);
		}

		Integer month = weekStart.month();
		Integer day = weekStart.day();
		Integer year = weekStart.year();
		
		//Format of forecast name: MM-DD-YYYY
		String forecastName = ((month >= 10) ? String.valueOf(month) : '0' + String.valueOf(month)) + '-' +
							  ((day >= 10) ? String.valueOf(day) : '0' + String.valueOf(day)) + '-' +
							  String.valueOf(year);
		this.weeklyForecast.Name = forecastName;
		
		this.weeklyForecast.Forecast_Submission_Week__c = weekStart;
		
	}
	
}