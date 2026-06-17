public with sharing class HttpConstants {
  
  private static HttpConstants INSTANCE = null;

  private HttpConstants() { }

  public static HttpConstants getInstance() {
    if (INSTANCE == null) {
      INSTANCE = new HttpConstants();
    }
    return INSTANCE;
  }

  // HTTP Methods
  public final String HTTP_METHOD_GET = 'GET';
  public final String HTTP_METHOD_POST = 'POST';
  public final String HTTP_METHOD_PATCH = 'PATCH';
  public final String HTTP_METHOD_PUT = 'PUT';

  // Common HTTP Headers
  public final String HEADER_CONTENT_TYPE = 'Content-Type';
  public final String CONTENT_TYPE_JSON = 'application/json';
}