public with sharing class LimitsDiagnostics_hlpr {
	public LimitsDiagnostics_hlpr() {
		
	}

	public static void printDiagnostics()
	{
		System.debug('Script Statements Used: ' + Limits.getScriptStatements());
		System.debug('SOQL Statements Used: ' + Limits.getQueries());
		System.debug('DML Statements Used: ' + Limits.getDMLStatements());
	}
}