public without sharing class WebTrialUpsell_page {

  private static String base_opp_id;
  private static String new_opp_id;
  private static String error_string;
  private static boolean success;

  // Public Constructor for controller
  public WebTrialUpsell_page() {}    

  @RemoteAction
  public static String createTrialUpsellOpp(String opp_id)
  {
    base_opp_id = opp_id;
    System.debug('Opp Id: ' + opp_id);
    String response = WebTrialUpsellController_ws.createTrialUpsellOpp(base_opp_id);
    WebTrialUpsellController_ws.TrialUpsellReponse parsed_response = new WebTrialUpsellController_ws.TrialUpsellReponse(response);
    success = parsed_response.get_success();
    error_string = parsed_response.get_error_string();
    new_opp_id = parsed_response.get_upsell_opp_id();
    if (opp_id == null)
      error_string = 'Could not grab id from url';
    return response;
  //if (success != null && success)
    //return new PageReference('/' + new_opp_id); 
  //else if (base_opp_id!=null)
    //return new PageReference('/' + base_opp_id);
  }

  public String getError_String()
  {
      return error_string;
  }

  public Boolean getSuccess()
  {
      return success;
  }

  public String getBase_opp_id()
  {
      return base_opp_id;
  }
}