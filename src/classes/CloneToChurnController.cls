public class CloneToChurnController {

    private static final String ID_PARAMETER = 'Id';

    /* Error Messages */
    private static final String NULL_OPP_ID_PROVIDED_ERROR_MESSAGE = 'No oppId was provided! Please access this page only by hitting the Clone to Churn button on an opp.';
    private static final String ID_PROVIDED_NOT_AN_ID_ERROR_MESSAGE = 'The oppId provided was not a valid Id.  Please access this page only by hitting the Clone to Churn button on an opp.';

    public CloneToChurnController() {}

    @RemoteAction
    public static String cloneAndChurnOpp(String oppId) {
        Id originalOppId = null;
        Id churnedOppId = null;
        ErrorTracker et = new ErrorTracker();
        if (oppId == null) {
            System.debug('oppId is null! Returning error.');
            et.addError(NULL_OPP_ID_PROVIDED_ERROR_MESSAGE);
        }
        else {
            try {
                originalOppId = oppId;
                churnedOppId = ChurnUtilities.cloneToChurn(originalOppId, et);
            }
            catch (Exception e) {
                System.debug('oppId provided as argument is not an ID!');
                et.addError(ID_PROVIDED_NOT_AN_ID_ERROR_MESSAGE);
            }
        }
        // Return JSON
        return createResponseJSON(churnedOppId, originalOppId, et);
    }

    public static String createResponseJSON(Id churnedOppId, Id originalOppId, ErrorTracker et) {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        if (churnedOppId != null) {
            gen.writeIdField('churnedOppId', churnedOppId);
        }
        if (originalOppId != null) {
            gen.writeIdField('originalOppId', originalOppId);  
        }
        gen.writeBooleanField('success', !et.hasErrors());
        gen.writeObjectField('errors', et.getErrorList());
        gen.writeEndObject();
        String jsonString = gen.getAsString();
        gen.close();
        return jsonString;
    }
}