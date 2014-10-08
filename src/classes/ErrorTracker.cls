/**
 * Class for tracking and reporting errors.
 *
 * Error: Something that causes an unrecoverable error, should be a failure
 * Warning: Warning about some issue that we CAN recover from
 *
 * @author Kyle Vermeer <kvermeer@box.com>
 * @revision 1.0 Kyle Vermeer 4/2/2014 Initial Creation
 * @revision Kyle Vermeer 8/29/2014 Added warnings
 */
public class ErrorTracker {

    // Constants
    private static final String DEFAULT_JSON_LABEL = 'errors';

    // Member variables 
    private String[] errorStrings;
    private String[] warningStrings;
    
    public ErrorTracker() { 
        errorStrings = new String[] {};
        warningStrings = new String[] {};
    }

    /**
     * Are there any errors in this error tracker?
     *
     * @return {Boolean} - true if any errors were added, false otherwise
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    public Boolean hasErrors() {
        return !errorStrings.isEmpty();
    }

    /**
     * Add an error to the error tracker.
     *
     * @param {String} errorText - text for error that occured
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    public void addError(String errorText) {
        System.debug('Error: ' + errorText);
        errorStrings.add(errorText);
    }

    /**
     * Add a warning to the error tracker
     * 
     * @param String warningText - text for warning that should be issued
     */
    public void addWarning(String warningText) {
        System.debug('Warning: ' + warningText);
        warningStrings.add(warningText);
    }

    /**
     * Converts ErrorTrack object to a JSON entry
     *
     * @return {String} - JSON string for array field
     * @author Kyle Vermeer <kvermeer@box.com>
     * @deprecated
     */
    public String JSONify() {
        return this.JSONify(null);
    }

    /**
     * Returns the error list.
     *
     * @return {List<String>} - list of errors that occured
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    public List<String> getErrorList() {
        return this.errorStrings;
    }

    /**
     * Returns the warning list.
     *
     * @return String[] - list of warnings that should be shown
     */
    public String[] getWarningList() {
        return this.warningStrings;
    }

    /**
     * Converts ErrorTrack object to a JSON entry
     *
     * @param {String} label - provide label for field name for array
     * @return {String} - JSON string for array field
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    public String JSONify(String label) {
        if (label == null) {
            label = DEFAULT_JSON_LABEL;
        }
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeObjectField(label, errorStrings);
        String jsonString = gen.getAsString();
        gen.close();
        return jsonString;
    }
}