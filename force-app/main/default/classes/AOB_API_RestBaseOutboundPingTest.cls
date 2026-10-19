/**
 * @description Test Class for AOB_API_RestBaseOutboundPing 
 * <p/>
 * <p></p>
 *
 * @author Maryem BOURHI (mbourhi@salesforce.com)
 * 22-01-2023 Devi Ravuri -- Removed debugs, commented code and white spaces
 *
 * @date Nov 20th 2020
 */
@isTest
public class AOB_API_RestBaseOutboundPingTest {
    private static final String TEST_JSON = '{"testKey":"testValue"}';
    private static final String TEST_ACCESS_TOKEN = 'testAccessToken';
    private static final String TEST_CORRELATION_ID = 'testCorrelationId';
    private static final String TEST_IDENTITY_NUMBER = 'testIdentityNumber';
    private static final String TEST_APPLICATION_ID = 'testApplicationId';
    private static final String HTTP_CONTENT_TYPE = 'Content-Type';
    private static final String HTTP_HEADER_ACCEPT = 'Accept';
    private static final String HTTP_HEADER_CERTIFICATE = 'Certificate';
    private static final String HTTP_HEADER_CHANNELID = 'ChannelId';
    private static final String HTTP_HEADER_CLIENTID = 'ClientId';
    private static final String HTTP_HEADER_CLIENTSECRET = 'ClientSecret';
    private static final String HTTP_HEADER_CORRELATION = 'Correlation';
    private static final String HTTP_HEADER_INTERACTIONID = 'InteractionId';
    private static final String HTTP_HEADER_TRACEID = 'TraceId';
    public static final String HTTP_HEADER_IBMClient = 'X-IBM-Client-Id';
    public static final String HTTP_HEADER_IBMSecret = 'X-IBM-Client-Secret';
    public static final String HTTP_HEADER_token = 'token';
    /**
	 * @description testmethod for getAuthorisationToken
	 */
    @isTest
    static void getAuthorisationToken() {
        AOB_API_RestBaseOutboundPing ping = new AOB_API_RestBaseOutboundPing();
        ping.accessToken = '';
        String token = ping.getAuthorisationToken();
        System.assertEquals(token, CMN_UTIL_String.EMPTY);
    }

    /**
	* @description testmethod for getAuthorisationToken
	*/
    @isTest
    static void testPopulateRequestDTO(){
        AOB_API_RestBaseOutboundPing obj = new AOB_API_RestBaseOutboundPing();
        obj.jsonBody = '{"Name": "John"}';
        obj.applicationId = 'a6h3O0000004S7hQAE';
        obj.populateRequestDTO();
    }
    /**
	* @description testmethod for SetHeadersMethod
	*/
  	@isTest
    static  void testSetHeadersMethod() {
        CMN_WebserviceSetting__mdt settings = new CMN_WebserviceSetting__mdt();
        settings.CMN_ClientID__c = 'testclientid';
        settings.CMN_Client_Secret__c = 'testclientsecret';
        settings.DeveloperName = 'CMN_API_RestOutboundExample';
        AOB_API_RestBaseOutboundPing myClass = new AOB_API_RestBaseOutboundPing();
        try{
            Test.startTest();
            myClass.setHeaders();
            Test.stopTest();
        } catch(Exception ex){
            System.debug('exception');
        }
        
    }
     /**
	* @description testmethod for getResponseStatusCode
	*/
    @isTest
    static void getResponseStatusCode() {
        AOB_API_RestBaseOutboundPing StatusCode = new AOB_API_RestBaseOutboundPing();
        Test.startTest();
        Integer statucCode=StatusCode.getResponseStatusCode();
        Test.stopTest();
        Assert.areNotEqual(null, statucCode);
    }  
}