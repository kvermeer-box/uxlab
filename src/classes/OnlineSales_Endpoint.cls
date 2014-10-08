/**
 * Endpoint for Box Online Sales
 *
 * Currently handles Web Trials, Expansions, and Upgrades
 *
 * @author Kyle Vermeer 8/20/14
 */
@RestResource(urlMapping='/onlineSales/*')
global class OnlineSales_Endpoint {
    
    @HttpPost
    global static void handlePost() {
        // First log the request
        RestRequest req = RestContext.request;
        System.debug('Request: ' + req);
        System.debug('RequestBody: ' + req.requestBody.toString());
        // Slap on the payload first
        Box_Online_Sales_Message__c loggedMessage = new Box_Online_Sales_Message__c(Payload__c = req.requestBody.toString());

        Savepoint sp = Database.setSavepoint();
        // Next deserialize it
        OnlineSales_Message message = (OnlineSales_Message) JSON.deserialize(req.requestBody.toString(), OnlineSales_Message.class); 
        message.populateParsedData(loggedMessage);

        // Finally, process it
        OnlineSales_TransactionType.TransactionResult transactionResult = processMessage(message);

        // If there were errors, rollback the whole transaction!
        if( transactionResult.et.hasErrors() ) {
            Database.rollback(sp);
        }
        else { // If successful, populate some fields on the log object
            populateLookups(loggedMessage, transactionResult);
        }

        // Log the result of the transaction
        if( transactionResult != null && transactionResult.resultCode != null ) {
            loggedMessage.Result_Code__c = transactionResult.resultCode.name();
        }
        insert loggedMessage;

        RestContext.response.responseBody = Blob.valueOf(buildResponse(transactionResult));
    }

    /**
     * Process the Online Sales JSON Message, branches depending on the transaction type
     *
     * @param OnlineSales_Message message - message from Box to process
     * @return ErrorTracker - error tracker that logs any issues that occured
     */
    private static OnlineSales_TransactionType.TransactionResult processMessage(OnlineSales_Message message) {
        OnlineSales_TransactionType transactionType = determineTransactionType(message, new ErrorTracker());

        return transactionType.processMessage();
    }

    /**
     * Build JSON response
     *
     * @param OnlineSales_TransactionType.TransactionResult transactionResult - summary of BOS transaction
     * @return String - JSON response
     */
    private static String buildResponse(OnlineSales_TransactionType.TransactionResult transactionResult) {
        ErrorTracker et = transactionResult.et;
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeBooleanField('success', !et.hasErrors());
        gen.writeObjectField('errors', et.getErrorList());
        gen.writeObjectField('warnings', et.getWarningList());
        if( transactionResult.opportunityId != null ) {
            gen.writeIdField('opportunityId', transactionResult.opportunityId);
        }
        if( transactionResult.accountId != null ) {
            gen.writeIdField('accountId', transactionResult.accountId);
        }
        if( transactionResult.contactId != null ) {
            gen.writeIdField('contactId', transactionResult.contactId);
        }
        gen.writeStringField('transactionCode', transactionResult.resultCode.name());
        gen.writeEndObject();
        String jsonString = gen.getAsString();
        gen.close();
        String unescapedString = jsonString.unescapeJava();
        System.debug('UnescapedValue: ' + unescapedString);
        return unescapedString;
    }

    /**
     * Determine and initialize an online sales transaction type
     *
     * @param OnlineSales_Message message - message that is going to be processed
     * @param ErrorTracker et - error tracker to use for monitoring errors/warnings
     */
    private static OnlineSales_TransactionType determineTransactionType(OnlineSales_Message message, ErrorTracker et) {
        // Currently, any change in tier is an upgrade.  If downgrades come, this will need to change
        if( message.tierBefore != message.tierAfter ) {
            return new OnlineSales_Upgrades(message, et);
        }
        else if( message.enterpriseSeatsPurchased > 0 ) {
            return new OnlineSales_Expansions(message, et);
        }
        else {
            et.addError('Unable to determine transaction type!');
            return null;
        }
    }

    /**
     * Populate lookups on log object. Modifies input
     *
     * @param Box_Online_Sales_Message__c loggedMessage - log object
     * @param OnlineSales_TransactionType.TransactionResult tr - result of transaction
     * @return Box_Online_Sales_Message__c - object with lookups populated
     */
    private static Box_Online_Sales_Message__c populateLookups(Box_Online_Sales_Message__c loggedMessage, OnlineSales_TransactionType.TransactionResult tr) {
        loggedMessage.Account__c = tr.accountId;
        loggedMessage.Opportunity__c = tr.opportunityId;
        loggedMessage.Contact__c = tr.contactId;
        return loggedMessage;
    }


}