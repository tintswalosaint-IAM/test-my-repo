/**
 * Class Used as a Template for All API calls Classes to Inherit from
 *
 * <p></p>
 *
 * @author Maryem BOURHI (mbourhi@salesforce.com)
 *
 * @date Nov 20th 2020
 */
public virtual class AOB_API_RestBaseOutbound extends CMN_API_HttpBaseOutbound {

  public string jsonBody;
  public string accessToken;

  /**
   * @description Method will retrieve data from SF (if necessary) and populate Request DTO with Data
   * If the flag "dummyData" is set, fill the DTO with mock information and don't do query
   * We are doing this to support unit tests
   */
  protected override void populateRequestDTO() {
    if (!String.isBlank(jsonBody))
      request.setBody(jsonBody);
  }

  /**
   * @description Used to set the Http Request Headers
   */
  protected virtual override void setHeaders() {
    super.setHeaders();
    request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_JSON);
    request.setHeader(HTTP_HEADER_ACCEPT, HTTP_ENCODING_JSON);
    request.setHeader(
      HTTP_HEADER_CERTIFICATE,
      AOB_Constants.API_TESTCERTIFICATE
    );
    request.setHeader(HTTP_HEADER_INTERACTIONID, AOB_utils.generateGUID());

  }

}