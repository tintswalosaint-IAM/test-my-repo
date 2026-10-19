/**
 * @description Class used to Perform an API call to get Access token
 * <p/>
 * <p>DBP-1279</p>
 *
 * @author Maryem BOURHI (mbourhi@salesforce.com)
 *
 * @date Nov 23th 2020
 */
public virtual class AOB_API_AccessTokenBase extends CMN_API_HttpBaseOutbound
{

	public static final String HTTP_BODY_GRATTYPE = 'client_credentials';
	public static final String HTTP_BODY_SCOPE = 'scope';
	public static final String HTTP_BODY_SCOPE_CUSTOMER = 'retail customer write prod';
	public static final String HTTP_BODY_SCOPE_QUOTE = 'retail customer prod';
	public static final String HTTP_BODY_SCOPE_BUSINESS = 'business write prod';
	public static final String HTTP_BODY_SCOPE_BRANCHES = 'vas prod';

	/**
	 * @description Method will override the parent class method to provide headers
	 */
	protected virtual override void setHeaders()
	{
		super.setHeaders();

		request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_URL);
		request.setHeader(HTTP_HEADER_ACCEPT, HTTP_ENCODING_JSON);
		request.setHeader(HTTP_HEADER_CERTIFICATE, AOB_Constants.API_TESTCERTIFICATE);

	}

}