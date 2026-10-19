/**
 * @description Class used to Perform an API call to start IDV
 * <p/>
 * <p>DBP-1459</p>
 *
 * @author Maryem BOURHI (mbourhi@salesforce.com)
 *
 * @date Dec 23th 2020
 * 
 * <p>SFP-11223</p> 
 * @author Mark Bailey 
 * @date 09 May 2022 
 * @description Fix issue with NotifyIDV failing to pass valid correlationId
 */
public with sharing class AOB_API_notifyIDV extends AOB_API_RestBaseOutboundPing {
	private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
	public static final String SERVICE_NAME = AOB_API_notifyIDV.class.getName();
	public string action;
	public string description;
	public string correlationId;

	/**
	 * @description constructor used to make sure a token will be provided to authenticate to the API call
	 *      *
	 *
	 *
	 * @param correlationId
	 * @param action
	 * @param description
	 */
	public AOB_API_notifyIDV(String correlationId, String action, String description) {
		this.correlationId = correlationId;
		this.action = action;
		this.description = description;
		accessToken = AOB_Utils.getAccessToken();
	}

	protected virtual override String getServiceName() {
		return SERVICE_NAME;
	}

	/**
	 * @description Call the parent objects' method to ensure we get code coverage
	 *
	 * @return
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock() {
		super.getEndpointMock();
		return new AOB_API_notifyIDVMock();
	}

	/**
	 * @description Method is use to return the endpoint URL using in HTTP response.
	 *
	 * @return endpoint
	 */
	@TestVisible
	protected override String getWebServiceEndPoint() {
		String endPoint;
		string path = String.isNotBlank(this.correlationId) ? '/' + this.correlationId + '/notifications' : CMN_UTIL_String.EMPTY;
		if (settings != null && String.isNotBlank(settings.CMN_NamedCredential__c)) {
			path = String.isNotBlank(settings.CMN_Path__c) ? settings.CMN_Path__c + path : CMN_UTIL_String.EMPTY;
			endPoint = String.format(
				NAMED_CREDENTIAL_URL_FORMAT,
				new List<String>{
					settings.CMN_NamedCredential__c,
					String.isNotBlank(path) ? path : CMN_UTIL_String.EMPTY
				}
			);
		}

		return endPoint;
	}

	/**
	 * @description method used to initialise the api call
	 */
	protected override void initialise() {
		super.initialise();
		baseRequestDTO = new DTO_Request();
		baseResponseDTO = new DTO_Response();
	}

	private class DTO_Request extends CMN_DTO_JsonBase {
		public override void populate(Id triggeringObjectId) {
			super.populate(triggeringObjectId);
		}
	}

	private class DTO_Body {
		public String realIDRequest;
		public String reasonCode;
		public String mode;
		public String actionIndicator;
		public String reasonDesc;

		/**
	     * @description method used to format the request body
		 * @param action indicates action to perform
		 * @param description the description detailing what action to perform
	     */
		public DTO_Body(string action, string description) {
			List<Account> accs = [
				SELECT id, firstname, lastname, AOB_IdentityNumber__c
				FROM Account
				WHERE id IN (SELECT AccountId FROM user WHERE id = :UserInfo.getUserId())
			];
			realIDRequest = accs.isEmpty() ? '' : accs[0].AOB_IdentityNumber__c; //customer Id number
			reasonCode = AOB_Constants.WFR_DEFAULT_CODE;
			mode = AOB_Constants.WFR_DEFAULT_CODE; //default value
			this.actionIndicator = action;
			reasonDesc = description;
		}
	}

	/**
	 * @description method used to format the Customer ID details in request body
	 */
	public class CustomerIdentity {
		public String idType;
		public String idNumber;
		public CustomerIdentity(string idNumber) {
			this.idType = '01';
			this.idNumber = idNumber; //Id number of the customer
		}
	}
	/**
	 * @description method used to set API call Method
	 *
	 * @return HTTP_VERB_POST
	 */
	@testVisible
	protected override virtual String getVerb() {
		return HTTP_VERB_POST;
	}

	/**
	 * @description method used to indicate that there is no need for a triggering object
	 *
	 * @return boolean
	 */
	@testVisible
	protected override virtual Boolean triggeringObjectRequired() {
		return false;
	}

	/**
	* @description The Type of the DTO used when deserializing the class
	*/
	@TestVisible
	public class DTO_Response extends CMN_DTO_JsonBase {
		public string response;

		/**
		 * @description The Type of the DTO used when deserializing the class
		 *
		 * @return Class of the DTO
		 */
		protected override Type getObjectType() {
			return DTO_Response.class;
		}
	}

	/**
	 * @description Will serialize requestDTO after its been populated.
	 *
	 * @return result
	 */
	protected virtual override String getBody() {
		super.getBody();

		populateRequestDTO();

		return JSON.serialize(new DTO_Body(action, description));
	}

	/**
	 * @description Mock class to test a valid response.
	 */
	public class AOB_API_notifyIDVMock extends CMN_API_HttpBaseOutboundMock {
		public final String validResponse = '{"type":"NATIONAL IDENTITY DOCUMENT","number":"7602125236089","issuingCountry":"ZA","issuedDate":"","expirationDate":""}';

		/**
	     * @description method to set the response body.
		 * @param HttpRequest Request Structure
		 * @param HttpResponse Response Structure
	     */
		protected override void setResponse(HttpRequest request, HttpResponse response) {
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}
}