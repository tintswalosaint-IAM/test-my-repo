/**
 * @description Base Rest outbound handler for OAuth Authenticated API Handlers
 *
 * @author Accenture
 *
 * @date January 2021
 */
public inherited sharing abstract class SVC_API_OAuthOutboundBase extends SVC_API_RestOutboundBase
{
	private SVC_API_GetInsuranceOAuthTokenBase tokenHandler;

	/**
	 * @description The name of the cache key used to store the OAuth Access Token
	 */
	private static final Integer TEN_SECONDS = 10;
	private static final String ACCESS_TOKEN_SUFFIX = 'AccessToken';
	@TestVisible
	private static final String ERROR_TOKEN_REQUEST_FAILED = 'Request to retrieve Access Token Failed';

	/**
	 * @description Set this to true to simulate a call with an Auth token that's invalid
	 */
	@TestVisible
	private static Boolean simulateInvalidAuthorisationToken = false;

	/**
	 * @description Will provide the webservice name for the handler that should get the access token, must be overriden
	 *
	 * @return The name of the handler
	 */
	protected abstract String getOauthServiceName();

	/**
	 * @description Returns the hander that performs request for retrieving access token
	 *
	 * @return An instance of OAuth handler
	 */
	private SVC_API_GetInsuranceOAuthTokenBase getOAuthTokenBaseHander()
	{
		if(tokenHandler == null)
		{
			tokenHandler = (SVC_API_GetInsuranceOAuthTokenBase)CMN_FACTORY_WebserviceManager.getHandler(getOauthServiceName());
		}

		return tokenHandler;
	}

	/**
	 * @description Returns the client certificate to use (if required) when making a call, will typically read it from the Auth hander.
	 * If the Auth Handler doesn't have a certificate it will read from it own metadata
	 *
	 * @return A String containing the certificate
	 *
	 * @see SVC_API_GetInsuranceOAuthTokenBase.clientCertificate
	 * @see CMN_API_HttpBaseOutbound.getAdditionalKey
	 */
	protected String getClientCertificate()
	{
		String clientCertificate = getAdditionalKey();
		return String.isNotBlank(clientCertificate) ? clientCertificate : getOAuthTokenBaseHander().clientCertificate;

	}

	/**
	 * @description Returns the client secret to use (if required) when making a call, will typically read it from the Auth hander.
	 * If the Auth Handler doesn't have a secret it will read from it own metadata
	 *
	 * @return A String containing the certificate
	 *
	 * @see SVC_API_GetInsuranceOAuthTokenBase.getClientSecret
	 * @see CMN_API_HttpBaseOutbound.getClientSecret
	 */
	protected override String getClientSecret()
	{
		String clientSecret = super.getClientSecret();

		return String.isNotBlank(clientSecret) ? clientSecret : getOAuthTokenBaseHander().getClientSecret();
	}

	/**
	 * @description Returns the client id to use (if required) when making a call, will typically read it from the Auth hander.
	 * If the Auth Handler doesn't have a client id it will read from it own metadata
	 *
	 * @return A String containing the certificate
	 *
	 * @see SVC_API_GetInsuranceOAuthTokenBase.getClientId
	 * @see CMN_API_HttpBaseOutbound.getClientId
	 */
	protected override String getClientId()
	{
		String clientId = super.getClientId();

		return String.isNotBlank(clientId) ? clientId : getOAuthTokenBaseHander().getClientId();
	}

	/**
	 * @description Override the setting of the headers to include client certificate
	 */
	protected override void setHeaders()
	{
		super.setHeaders();

		String clientCertificate = getClientCertificate();

		if(String.isNotBlank(clientCertificate))
		{
			CMN_UTIL_Logger.info(HTTP_HEADER_X_CLIENT_CERTIFICATE + ':' + clientCertificate, getServiceName() + '/setHeaders');
			request.setHeader(HTTP_HEADER_X_CLIENT_CERTIFICATE, clientCertificate);
		}
	}

	/**
	 * @description returns the name of the cache so that we can cache access tokens per auth service
	 *
	 * @return the cache key
	 */
	@TestVisible
	private String getCacheKey()
	{
		//Remove underscores as this will exist in class names
		return CMN_UTIL_String.replace(getOauthServiceName() + ACCESS_TOKEN_SUFFIX, '_', CMN_UTIL_String.EMPTY);
	}

	/**
	 * @description Will retrieve access token either from the Cache (if token previously retrieved),
	 * if token doesn't exist in cache, retrieve from OAuth Endpoint
	 *
	 * @return A Authorisation Token (type Bearer)
	 *
	 * @see SVC_API_GetInsuranceFlexiOAuth
	 * @see Cache.Org
	 */
	@TestVisible
	private String getAccessToken()
	{
		String accessToken = (String)Cache.Org.get(getCacheKey());

		if(String.isBlank(accessToken))
		{
			SVC_API_GetInsuranceOAuthTokenBase.runAsEmbedded = true;

			CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(getOauthServiceName());

			//Ensure we commit the queue item as part of our commit; as SVC_API_GetInsuranceFlexiOAuth won't due to "runAsEmbedded" flag
			registerChange(queueItem);

			tokenHandler = (SVC_API_GetInsuranceOAuthTokenBase)CMN_FACTORY_WebserviceManager.execute(new List<CMN_WebserviceCallQueue__c> {queueItem}).iterator().next();

			if(tokenHandler.callResult.completed)
			{
				//Store the access token, subtract a few seconds to ensure cache soon enough to get refreshed
				Cache.Org.put(getCacheKey(), tokenHandler.accessToken, tokenHandler.expiresIn - TEN_SECONDS);
				accessToken = tokenHandler.accessToken;
				CMN_UTIL_Logger.info('New OAuth Token: ' + tokenHandler.accessToken + ' save to ' + getCacheKey(), getServiceName() + '/getAuthorisationToken');
			}
		}
		else
		{
			CMN_UTIL_Logger.info('Cache OAuth Token: ' + accessToken + ' retrieved from ' + getCacheKey(), getServiceName() + '/getAuthorisationToken');
		}

		return accessToken;
	}

	/**
	 * @description Will return the OAuth authorisation token by making a call to get one
	 *
	 * @return Authorisation Header value
	 *
	 * @see SVC_API_GetInsuranceFlexiOAuth.accessToken
	 */
	protected override String getAuthorisationToken()
	{
		String accessToken = getAccessToken();

		return String.isBlank(accessToken) ? null : HTTP_AUTH_TOKEN_BEARER + accessToken;
	}

	/**
	 * @description Method will send request to endpoint, and record whether successful or not
	 *
	 * @param request The HttpRequest object contain body and headers
	 *
	 * @see HttpRequest
	 */
	protected override void sendRequest(HttpRequest request)
	{
		//If we get here and realise the call to retrieve auth token failed then we should not send request but fail
		if(tokenHandler.callResult.failed)
		{
			callResult.statusCode = tokenHandler.callResult.statusCode;
			callResult.aborted = true;
			callResult.errors.add(ERROR_TOKEN_REQUEST_FAILED);
		}
		else
		{
			super.sendRequest(request);

			//If we fail the request because the key in the cache doesn't work, clear the key so we try and get another one
			if(callResult.failed && response.getStatusCode() == HTTP_UNAUTHORISED)
			{
				Cache.Org.remove(getCacheKey());

				CMN_UTIL_Logger.warn('Removed following Cache due to auth error "' + getCacheKey(), getServiceName() + '/sendRequest');

				String authorisationToken = getAuthorisationToken();

				if(String.isNotBlank(authorisationToken))
				{
					CMN_UTIL_Logger.info('Retrying API call with updated access token', getServiceName() + '/sendRequest');
					request.setHeader(HTTP_HEADER_AUTHORIZATION, authorisationToken);
					super.sendRequest(request);
				}
			}
		}
	}

	/**
	 * @description Mock class for returning test data
	 */
	public virtual inherited sharing class SVC_API_OAuthOutboundBaseMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String unAuthorizedResponse = '{ "httpCode":"401", "httpMessage":"Unauthorized", "moreInformation":"This server could not verify that you are authorized to access the URL" }';

		protected virtual override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);

			if(simulateInvalidAuthorisationToken)
			{
				response.setStatusCode(CMN_API_HttpBase.HTTP_UNAUTHORISED);
				response.setStatus(CMN_API_HttpBase.ERR_INTERNAL_UNAUTHORISED);
				response.setBody(unAuthorizedResponse);

				//Reset the flag, so that if the call is retried then it doesn't throw error again
				simulateInvalidAuthorisationToken = false;
			}
		}
	}
}