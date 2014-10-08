public class DynamicTestValues {
  
  // Constants
  private static String EMPTY_JSON = '{}';

  private static String NaicsJSONRespose = null;

  public static String getNaicsJSONResponse() {
    if (NaicsJSONRespose == null) {
      return EMPTY_JSON;
    } else {
      return NaicsJSONRespose;
    }
  }

  public static void setNaicsJSONResponse(String JSONResponse) {
    NaicsJSONRespose = JSONResponse;
  }
}