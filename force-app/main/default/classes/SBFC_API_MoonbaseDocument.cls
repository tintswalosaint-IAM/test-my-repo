/**
 * @description       : SFP-55759 - API service class that handles the outbound Moonstone (Moonbase)
 *                      Disclosure Document integration via the ESB middleware.
 *                      Builds the request payload from Lead / Account / User data,
 *                      performs the HTTP callout to Moonstone, and records the request,
 *                      response and status of every call on the CMN_WebserviceCallQueue__c
 *                      object so administrators can audit successful and failed integrations.
 * author             : Gigyasu Jain
 * @group             : SBFC
 * @last modified on  : 08-07-2026
 * @last modified by  : Gigyasu Jain
**/
public virtual with sharing class SBFC_API_MoonbaseDocument extends sbgplatform.ApiGatewayService {
    
    // Logger Constant
    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger(SBFC_API_MoonbaseDocument.class.getName());
    
    //Constants
    private static final String NAMED_CREDENTIAL = 'CHNW_PPB_SBFC_ESBConnectN';
    private static final String API_CREDENTIALS = 'CHNW_PPB_SBFC_ESBConnectAC';
    private static final String ENDPOINT = '/dropins/fitproper/ImportApi/getFile?api=1';
    public  static final String SERVICE_NAME = SBFC_API_MoonbaseDocument.class.getName();
    public  static final Integer HTTP_OK = 200;

    // Request inputs (set via initialise)
    private static Account account;
    private static User user;
    private static Lead lead;
    private static Integer chkOne;
    private static Integer chkTwo;
    private static String policyType;

    // Holds the raw response so controller can read the base64 PDF etc.
    public static String responseBody;

    public static CMN_DAL_WebserviceCallQueue.ServiceCallResult callResult =
        new CMN_DAL_WebserviceCallQueue.ServiceCallResult();
    
    /**
     * @description Constructor that initializes the API Gateway Service
     *              using the configured Named Credential and API Credentials.
     */
    public SBFC_API_MoonbaseDocument() {
        super(NAMED_CREDENTIAL,API_CREDENTIALS);
    }

    /**
     * @description Initializes the request context required to build
     *              the Moonstone disclosure request.
     * author Gigyasu
     * @param le Lead record.
     * @param acc Related Account.
     * @param u Account Owner.
     * @param cOne First disclosure option.
     * @param cTwo Second disclosure option.
     * @param pType Policy type.
     */
    public void initialise(Lead le, Account acc, User u, Integer cOne, Integer cTwo, String pType) {
        stopWatch.start();                
        SBFC_API_MoonbaseDocument.lead       = le;
        SBFC_API_MoonbaseDocument.account    = acc;
        SBFC_API_MoonbaseDocument.user       = u;
        SBFC_API_MoonbaseDocument.chkOne     = cOne;
        SBFC_API_MoonbaseDocument.chkTwo     = cTwo;
        SBFC_API_MoonbaseDocument.policyType = pType;
    }

    
    /**
     * @description Builds the Moonstone Disclosure request payload from the current Lead, Account and User context.
     * author Gigyasu
     */
    public static String getRequestBody() {
        SBFC_MoonstoneRequestDTO req = new SBFC_MoonstoneRequestDTO();
        req.fspNo    = '3825_main';
        req.fileType = 'disclosure';
        req.params   = new SBFC_MoonstoneRequestDTO.Params();
        req.params.cust_name   = account.Name;
        req.params.id_no       = account.CMN_IdentityNumber__pc;
        req.params.c_code      = user.RM_AE_Code__c;
        req.params.chk_one     = chkOne;
        req.params.chk_two     = chkTwo;
        req.params.policy      = policyType;
        req.params.hub_sign    = 0;
        req.params.manual_sign = 0;
        req.params.email_inpt  = account.PersonEmail;
        req.notifyByEmail      = '0';
        return JSON.serialize(req);
    }

    
    /**
     * @description Main process loop: makes the callout and records the result on callResult.
     *              Also populates queueItem so the caller can persist it.
     * author Gigyasu
     * @param queueItem Queue record to populate.
     * @return Webservice call result.
     */
    public CMN_DAL_WebserviceCallQueue.ServiceCallResult process(CMN_WebserviceCallQueue__c queueItem) {
        try {
            String requestBody = getRequestBody();
            callResult.url         = NAMED_CREDENTIAL + ENDPOINT;
            callResult.requestBody = requestBody;

            setExceptionOnError(false);   

            responseBody = (String) post(ENDPOINT, requestBody);

            callResult.statusCode   = String.valueOf(getStatusCode());
            callResult.responseBody = responseBody;
            callResult.completed    = true;

            if (getStatusCode() != HTTP_OK) {
                callResult.failed = true;
                callResult.status = CMN_DAL_WebserviceCallQueue.WebserviceStatus.FAILED;
            }
        } catch (Exception ex) {
            LOGGER.error('SBFC_API_MoonbaseDocument: Unhandled exception',
                new String[]{ 'Moonbase Outbound',String.valueOf(getStatusCode()),
                              lead != null ? lead.Id : null,
                              JSON.serialize(ex.getMessage()) });
            callResult.failed       = true;
            callResult.completed    = false;
            callResult.responseBody = ex.getMessage();
            callResult.errors       = new List<String>{ ex.getMessage() };
            callResult.status       = CMN_DAL_WebserviceCallQueue.WebserviceStatus.FAILED;
            setQueueItemDetails(queueItem);
        }

        // Populate the queue item with the outcome
        setQueueItemDetails(queueItem);
        return callResult;
    }

    
    /**
     * @description Populates the outbound webservice queue record with the request, response and execution details.
     * @author Gigyasu
     * @param queueItem Queue item to populate.
     */
    public static void setQueueItemDetails(CMN_WebserviceCallQueue__c queueItem) {
        queueItem.CMN_Request__c    = abbreviate(callResult.requestBody, CMN_DAL_WebserviceCallQueue.REQUEST_LEN);
        queueItem.CMN_Response__c   = abbreviate(callResult.responseBody, CMN_DAL_WebserviceCallQueue.RESPONSE_LEN);
        queueItem.CMN_Status__c     = callResult.statusText;
        queueItem.CMN_StatusCode__c = callResult.statusCode;
        queueItem.CMN_NextRetry__c  = null;
        queueItem.CMN_Errors__c     = CMN_UTIL_String.joinArray(callResult.errors, CMN_UTIL_String.CR + CMN_UTIL_String.LF);
        queueItem.CMN_URL__c        = callResult.url;
        queueItem.CMN_MockedResponse__c = callResult.mocking == null ? false : callResult.mocking;

        if (queueItem.CMN_RequestTimeTaken__c == null) {
            queueItem.CMN_RequestTimeTaken__c = stopWatch.getTime();
        }
    }

 
    /**
 * @description Truncates the response string if it exceeds the maximum field length.
 * 
 * @author Gigyasu
 * @param inputString Response string.
 * @param maxLength Maximum allowed length.
 * @return Truncated response string.
 */

    public static String abbreviate(String inputString, Integer maxLength) {
        return String.isNotBlank(inputString) && inputString.length() > maxLength
            ? CMN_UTIL_String.abbreviate(inputString, maxLength)
            : inputString;
    }

    
/**
 * @description Lazy-loaded stopwatch instance used to measure
 *              the execution time of the outbound Moonstone API request.
 * @author Gigyasu
 *
 * @return CMN_UTIL_StopWatch Stopwatch instance.
 */
    public static CMN_UTIL_StopWatch stopWatch {
        get {
            if (stopWatch == null) { stopWatch = new CMN_UTIL_StopWatch(); }
            return stopWatch;
        }
        private set;
    }
}