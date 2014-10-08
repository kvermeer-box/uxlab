public class WebTrialRestTestingToolController {

    @RemoteAction
    public static WebTrialRest.WebTrial processSingleWebTrialRemote(WebTrialRest.WebTrial webTrial) {
        String requestBody = JSON.serialize( webTrial );
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf( requestBody );
        RestContext.request = request;
        return WebTrialRest.processWebTrial();
    }

}