global class QuoteMachine_DateUtils {

	public static Date calculateEndDateFromStartDateAndTerm(Date startDate, Integer term) {
    	System.debug('Calculating the end date based on start date ' + startDate + ' and term ' + term);
        Date endDate;
        if (startDate != null && term != null) {
            Date tmpDate = startDate.addMonths(term);
            while (tmpDate < startDate || tmpDate < Date.today()) {
                System.debug('Adding another term to the start date...');
                tmpDate = tmpDate.addMonths(term);
            }
            endDate = tmpDate;
        }
        System.debug('End date: ' + endDate);
        return endDate;
    }	

}