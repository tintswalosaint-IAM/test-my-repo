/**
 * @description Class used to Perform an API call to start ID
 * @author Mark Bailey 
 * @date 09 May 2022 
 */
@SuppressWarnings
public class AOB_API_OrchestrateIDV extends AOB_API_RestBaseOutboundPing {
	public static final String SERVICE_NAME = AOB_API_OrchestrateIDV.class.getName();
    
    /**
	 * @description constructor 
     * @param idNumber as input
  	 * @param correlationId as input
   	 * @param applicationId as input
   */
	 
	public AOB_API_OrchestrateIDV(String idNumber, String correlationId, String applicationId) {
		accessToken = AOB_Utils.getAccessToken();
		this.correlationId = correlationId;
		this.identityNumber = idNumber;
		String bcbCMApplicationId;
		Map<String, BCB_Static_Value__mdt> bcbStaticValuesMap = BCB_Static_Value__mdt.getAll();
        for(String bcbStaticVal : bcbStaticValuesMap.keySet()){
        BCB_Static_Value__mdt bcbValue = bcbStaticValuesMap.get(bcbStaticVal);
            if(bcbValue.Label == 'AOB_WFR_ApplicationId'){
                bcbCMApplicationId = bcbValue.Value__c;
            }
        }
        if (Test.isRunningTest()) {
            this.applicationId = applicationId;
		} else {
            //Hardcoding needs to be taken out by moving the value into constants class or metadata
            this.applicationId = bcbCMApplicationId;
         }
	}

	

	/**
	 * @description The name of your service to be used when looking up custom settings for you service
	 *
	 * @return SERVICE_NAME
	 */
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
		return new AOB_API_OrchestrateIDVMock();
	}

	/**
	 * @description Override to set your request and response DTO types and any other globals you may have
	 */
	protected override void initialise() {
		super.initialise();
		baseRequestDTO = new DTO_Request();
		baseResponseDTO = new DTO_Response();
	}

	/**
	 * @description Used to set the Http Request Headers
	 */
	protected virtual override void setHeaders() {
		setServiceSettings();
		if (String.isBlank(settings.CMN_ClientID__c) || String.isBlank(settings.CMN_Client_Secret__c))
        {
           throw new AuraHandledException(Label.AOB_APIError); 
        }
			
		super.setHeaders();
		request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_JSON);
		request.setHeader(HTTP_HEADER_ACCEPT, HTTP_ENCODING_JSON);
		request.setHeader(HTTP_HEADER_CERTIFICATE, AOB_Constants.API_TESTCERTIFICATE);
        //request.setClientCertificateName('SF_Account_Onboarding_and_Commerce');
		request.setHeader(HTTP_HEADER_INTERACTIONID, AOB_utils.generateGUID());
		request.setHeader(HTTP_HEADER_TRACEID, AOB_utils.generateGUID());
		//request.setHeader(HTTP_HEADER_CLIENTID_WFR, settings.CMN_ClientID__c);
        request.setHeader(HTTP_HEADER_CLIENTID_WFR, EncodingUtil.base64Decode(settings.CMN_ClientID__c ).toString());
		//request.setHeader(HTTP_HEADER_CLIENTSECRET_WFR, settings.CMN_Client_Secret__c);
         request.setHeader(HTTP_HEADER_CLIENTSECRET_WFR, EncodingUtil.base64Decode(settings.CMN_Client_Secret__c ).toString());
		request.setHeader(HTTP_HEADER_CORRELATION, AOB_utils.generateGUID());
		request.setHeader(HTTP_HEADER_CHANNELID, settings.AOB_DefaultChannel__c);
	}
   /**
	 * @description DTO_Request 
   */
	private class DTO_Request extends CMN_DTO_JsonBase {
		public override void populate(Id triggeringObjectId) {
			super.populate(triggeringObjectId);
		}
	}
   /**
	 * @description DTO_Body 
	 * @param action { get; set; }, channel { get; set; }, callBackUrl { get; set; }, String notifyUrl { get; set; }, String idNumber { get; set; }, applicationID { get; set; }
   */
	private class DTO_Body {
          /**
	     * @description action 
        */
		public String action { get; set; }
         /**
	     * @description channel 
        */
		public String channel { get; set; }
         /**
	     * @description callBackUrl 
        */
		public String callBackUrl { get; set; }
         /**
	     * @description notifyUrl 
        */
		public String notifyUrl { get; set; }
         /**
	     * @description idNumber 
        */
		public String idNumber { get; set; }
         /**
	     * @description applicationID 
        */
		public String applicationID { get; set; }
     /**
     * @description Bar
     * @param idNumber
     * @param applicationId
     */
		public DTO_Body(String idNumber, String applicationId) {
            //system.debug('*************** applicationId'+applicationId);
			this.action = AOB_Utils.getWebServiceSettingsByName(SERVICE_NAME).AOB_Action__c; //'SALESFORCE'; webServiceSetting.AOB_Action__c
			this.channel = AOB_Utils.getWebServiceSettingsByName(SERVICE_NAME).AOB_Channel__c; //'SBG'; webServiceSetting.AOB_Channel__c
			//this.callBackUrl='https://chnwcomdev-standardbankgroupltd.cs80.force.com/s/aob-application/a0r25000005VMB1AAO/a202202011957';
			this.idNumber = idNumber;
			//this.applicationID=applicationId;
			//iidentifii applicationId
			this.applicationID = 'CB5CFB27-B2D4-4C2D-B60B-BE5A67A5C806';
			this.callBackUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/s/aob-application/' + applicationId;  
			//Testing need to change for all environments
			//this.notifyUrl = 'https://chnwcomdev-standardbankgroupltd.cs80.force.com/services/data/v54.0/sobjects/AOB_Application__c/' + applicationId;
			this.notifyUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/v1/wfrNotify/' + applicationId;
			//this.callBackUrl = this.callBackUrl.replace('https://', '');
			//system.debug('*************** callBackUrl ' + this.callBackUrl);
			//system.debug('*************** idNumber ' + idNumber);
			//system.debug('*************** applicationId ' + applicationId);
		}
	}

	/**
	 * @description Overriding parent class method to use the right API Method
	 *
	 * @return 
	 */
	protected override virtual String getVerb() {
		return HTTP_VERB_POST;
	}

	/**
	 * @description Overriding parent class method to indicate that triggering object is not needed
	 *
	 * @return
	 */
	protected override virtual Boolean triggeringObjectRequired() {
		return false;
	}

    /**
	 * @description DTO_Response
	 * @param correlationId, contextId
	 */
	public class DTO_Response extends CMN_DTO_JsonBase {
        /**
	    * @description correlationId
	    */
		public String correlationId { get; set; }
          /**
	    * @description contextId
	    */
		public String contextId { get; set; }
         /**
	    * @description status
	    */
		public Status status { get; set; }
     /**
	 * @description DTO_Response
	 * @return DTO_Response.class
	 */
		protected override Type getObjectType() {
			return DTO_Response.class;
		}
	}

     /**
	 * @description Status 
	 * @param get,set
     */
	public class Status {
          /**
	    * @description code 
        */
		public String code { get; set; }
        /**
	   * @description message 
       */
		public String message { get; set; }
	}

	/**
	 * @description Will serialize requestDTO after its been populated.
	 * @return new DTO_Body
	 */
	protected virtual override String getBody() {
		super.getBody();

		populateRequestDTO();

		return JSON.serialize(new DTO_Body(this.identityNumber, this.applicationId));
	}
/**
     * @description Used to call the AOB_API_OrchestrateIDVMock extends CMN_API_HttpBaseOutboundMock
     * @param HttpRequest request, HttpResponse response
     */
	public class AOB_API_OrchestrateIDVMock extends CMN_API_HttpBaseOutboundMock {
		public final String validResponse = '';

		protected override void setResponse(HttpRequest request, HttpResponse response) {
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}
}