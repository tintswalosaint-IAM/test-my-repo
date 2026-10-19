/**
* @Name of the Class : ICS_CTRL_LoqateAddress
* @description Contoller used for SBO UK Loqate Address Lookup  - SFP-33996 
* @author RUCHI AGRAWAL
* @date March 5th 2024 
* @last modified on  : 17-05-2024
* @last modified by  : Ruchi Agrawal
*/
public with sharing class ICS_CTRL_LoqateAddress {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(ICS_Constants.ICS_CTRL_PreAppFormCreator);
    public static final Integer SUCCESS_STATUS_CODE = 200;
    public static final Integer FAILURE_STATUS_CODE = 500;
    private static final String ITEMS_KEY = 'Items';
    private static final String ERROR_KEY = 'Error';
    private static final String SERVICE_NAME = ICS_API_LoqateAddressSearch.SERVICE_NAME;

    @AuraEnabled
    public static String findAddress(String country, String text, String type) {
        try {
            ICS_API_LoqateAddressSearch loqateSearch = createLoqateSearch(country, text, type);
            return processLoqateResponse(loqateSearch);
        } catch (Exception e) {
           
            throw new AuraHandledException('Unsupported Loqate API type');
            
        }
    }

    @AuraEnabled
    public static String retrieveAddress(String encodeId) {
        try {
            ICS_API_LoqateAddressRetrieve addressRetriever = createAddressRetriever(encodeId);
            return processLoqateResponse(addressRetriever);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
            
        }
    }

    private static ICS_API_LoqateAddressSearch createLoqateSearch(String country, String text, String type) {
        String countries = EncodingUtil.urlEncode(country, 'UTF-8');
        String encodedText = EncodingUtil.urlEncode(text, 'UTF-8');
        return new ICS_API_LoqateAddressSearch(countries, encodedText, type);
    }

    private static ICS_API_LoqateAddressRetrieve createAddressRetriever(String encodeId) {
        String encodedText = EncodingUtil.urlEncode(encodeId, 'UTF-8');
        return new ICS_API_LoqateAddressRetrieve(encodedText);
    }

    private static String processLoqateResponse(Object loqateApi) {
        checkPermissions();
        processWebServiceCall(loqateApi);
        return createLoqateAddressResponse(loqateApi);
    }

    private static void checkPermissions() {
        Schema.DescribeSObjectResult objDescribe = CMN_WebserviceCallQueue__c.sObjectType.getDescribe();
        if (!objDescribe.isCreateable() || !objDescribe.isAccessible()) {
            LOGGER.error('Insufficient permissions for CMN_WebserviceCallQueue__c');
        }
    }

    private static void processWebServiceCall(Object loqateApi) {
        Schema.DescribeSObjectResult objDescribe = CMN_WebserviceCallQueue__c.sObjectType.getDescribe();
        if ( objDescribe.isAccessible()) {
            CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(SERVICE_NAME);
            if (loqateApi instanceof ICS_API_LoqateAddressSearch) {
                ((ICS_API_LoqateAddressSearch)loqateApi).process(obj);
            } else if (loqateApi instanceof ICS_API_LoqateAddressRetrieve) {
                ((ICS_API_LoqateAddressRetrieve)loqateApi).process(obj);
            }
                if (objDescribe.isCreateable() || objDescribe.isAccessible()) {
            	insert obj;
                }
            
        }else{
         LOGGER.error('Insufficient permissions for CMN_WebserviceCallQueue__c');
        } 
    }

    private static String createLoqateAddressResponse(Object loqateApi) {
        ICS_DTO_LoqateAddress loqateAddress = new ICS_DTO_LoqateAddress();
        Integer responseStatusCode;
        String responseBody;

        if (loqateApi instanceof ICS_API_LoqateAddressSearch) {
            ICS_API_LoqateAddressSearch search = (ICS_API_LoqateAddressSearch)loqateApi;
            responseStatusCode = search.getResponseStatusCode();
            responseBody = search.getResponseBody();
        } else if (loqateApi instanceof ICS_API_LoqateAddressRetrieve) {
            ICS_API_LoqateAddressRetrieve retriever = (ICS_API_LoqateAddressRetrieve)loqateApi;
            responseStatusCode = retriever.getResponseStatusCode();
            responseBody = retriever.getResponseBody();
        } else {
            throw new AuraHandledException('Unsupported Loqate API type');
        }

        if (responseStatusCode == SUCCESS_STATUS_CODE) {
            Map<String, Object> parsedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
            List<Object> items = (List<Object>)parsedResponse.get(ITEMS_KEY);
            if (items != null && !items.isEmpty()) {
                Map<String, Object> itemMap = (Map<String, Object>)items[0];
                loqateAddress.resStatus = itemMap.containsKey(ERROR_KEY) ? FAILURE_STATUS_CODE : SUCCESS_STATUS_CODE;
            }
        } else {
            loqateAddress.resStatus = FAILURE_STATUS_CODE;
        }
        loqateAddress.responseBody = responseBody;
        return JSON.serialize(loqateAddress);
    }

    
    public class ICS_DTO_LoqateAddress {
        String responseBody;
        Integer resStatus;  
    }
}