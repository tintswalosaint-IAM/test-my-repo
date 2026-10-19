/**
* @Name of the Class : ICS_API_LoqateAddressRetrieve
* @description API class for SBO UK Loqate to Retrieve Address for Selected Address - SFP-33996 
* @author RUCHI AGRAWAL
* @date March 5th 2024 
* @last modified on  : 17-05-2024
* @last modified by  : Ruchi Agrawal
*/

public with sharing class ICS_API_LoqateAddressRetrieve extends AOB_API_RestBaseOutboundPing {
    public String urlWithParams= 'Key={0}';
     // static variable store the apex class name
    public static final String SERVICE_NAME = ICS_API_LoqateAddressRetrieve.class.getName();
    
    //variable store the url with the params
    private string responseMock;
            //TRUE_RESPONSE
         private static final String TRUE_RESPONSE = 'true';
    //FALSE_RESPONSE
        private static final String FALSE_RESPONSE = 'false';
    //EXCEPTION_RESPONSE
        private static final String  EXPRESPONSE = 'exception';
     /**
* @description The name of your service to be used when looking up custom settings for you service
*
*/
    public ICS_API_LoqateAddressRetrieve(String stringId) {
        Super();
        urlWithParams=urlWithParams+'&Id=' + stringId;
        if(stringId == '') {
        responseMock = 'false';
        } else if(stringId == null) {
            responseMock = 'exception';
        } else {
             responseMock = 'true';
        }
    }
    
    
    /**
* @description The name of your service to be used when looking up custom settings for you service
*
* @return SERVICE_NAME
*/
    @TestVisible    
    protected virtual override String getServiceName() {
        return SERVICE_NAME;
    }
    
    /**
* @description Override to set your request and response DTO types and any other globals you may have
*/
    @TestVisible
    protected override void initialise() {
        super.initialise();
        baseRequestDTO = new DTO_Request();
        
    }
    
           /**
* @description populates triggering object
*/
    @TestVisible
    private class DTO_Request extends CMN_DTO_JsonBase {
        /**
* @description populates triggering object
*/
        public override void populate(Id triggerId) {
            super.populate(triggerId);
        }
    }
    
    /**
* @description Will serialize requestDTO after its been populated.
*
* @return result
*/
    @TestVisible
    protected virtual override String getBody() {
        super.getBody();
        
        populateRequestDTO();
        
        return jsonBody;
    }
    
    /**
* @description Overriding parent class method to use the right API Method
*/
    @TestVisible
    public override virtual String getVerb() {
        return HTTP_VERB_POST;
    }
    
    /**
* @description Method is use to return the endpoint URL using in HTTP response.
*/
    @TestVisible
    protected virtual override void setHeaders() {
        
        setServiceSettings();
        request.setMethod(getVerb());
        request.setHeader(HTTP_CONTENT_TYPE, 'application/x-www-form-urlencoded');
         request.setBody(String.format(urlWithParams, new string[]{
            '{!$Credential.ICS_API_Loqate.key}' 
        }));
        request.setTimeout(120000);
        
    }
    
    /**
* @description Method is use to return the endpoint URL using in HTTP response.
*
* @return endpoint
*/
    @TestVisible
    protected override String getWebServiceEndPoint() {
        String endPoint;
        if (settings != null) {
            endPoint = settings.CMN_Path__c;
        }
        return endPoint;
    }
    
    
    /**
* @description Call the parent objects' method to ensure we get code coverage
*
* @return
*/
    protected override CMN_API_HttpBaseOutboundMock getEndpointMock() {
        super.getEndpointMock();
        return new UpdateRPMock(responseMock);
    }
    /**
* @description Overriding parent class method to indicate that triggering object is not needed
* @return Boolean
*/
    @TestVisible
    protected override virtual Boolean triggeringObjectRequired() {
        return false;
    }
    
    /**
* @description Wrapper class for http response
*/
    public class DTO_Response extends CMN_DTO_JsonBase {
        /**
* The response from the Aura-enabled method.
*/
        @AuraEnabled
        public String response { get; set; } // response Parameter

        
        /**
* @description The Type of the DTO used when deserializing the class
* @return Class of the DTO
*/
        @TestVisible
        protected override Type getObjectType() {
            return DTO_Response.class;
        }
    }
    
       /**
* @description The Type of the DTO used when deserializing the class
* @return Class of the DTO
*/  
    public override String getResponseBody() {
        return response.getBody();
    }
    /**
* @description Mock class for Test classes
*/
    public class UpdateRPMock extends CMN_API_HttpBaseOutboundMock {
        //responseInfo
        string responseInfo;
        //validResponse
        String validResponse = '{"Items":[{"Id":"IN|LP|A|27614485|1_ENG","DomesticId":"27614485","Language":"ENG","LanguageAlternatives":"ENG","Department":"","Company":"","SubBuilding":"","BuildingNumber":"1","BuildingName":"","SecondaryStreet":"","Street":"New Mandapam Road","Block":"","Neighbourhood":"","District":"Kilpauk Garden Colony","City":"Chennai","Line1":"1 New Mandapam Road","Line2":"Kilpauk Garden Colony","Line3":"","Line4":"","Line5":"","AdminAreaName":"Chennai District","AdminAreaCode":"","Province":"TN","ProvinceName":"Tamil Nadu","ProvinceCode":"TN","PostalCode":"600010","CountryName":"India","CountryIso2":"IN","CountryIso3":"IND","CountryIsoNumber":"356","SortingNumber1":"","SortingNumber2":"","Barcode":"","POBoxNumber":"","Label":"1, New Mandapam RoadChennai600010INDIA","Type":"Unknown","DataLevel":"Premise","Field1":"","Field2":"","Field3":"","Field4":"","Field5":"","Field6":"","Field7":"","Field8":"","Field9":"","Field10":"","Field11":"","Field12":"","Field13":"","Field14":"","Field15":"","Field16":"","Field17":"","Field18":"","Field19":"","Field20":""}]}';
          /**
* @description Mock class for Test classes
*/
        Public UpdateRPMock(string responseMock) {
            Super();
            responseInfo = responseMock;
            if(responseMock == TRUE_RESPONSE) {
            validResponse = '{"Items":[{"Id":"IN|LP|A|27614485|1_ENG","DomesticId":"27614485","Language":"ENG","LanguageAlternatives":"ENG","Department":"","Company":"","SubBuilding":"","BuildingNumber":"1","BuildingName":"","SecondaryStreet":"","Street":"New Mandapam Road","Block":"","Neighbourhood":"","District":"Kilpauk Garden Colony","City":"Chennai","Line1":"1 New Mandapam Road","Line2":"Kilpauk Garden Colony","Line3":"","Line4":"","Line5":"","AdminAreaName":"Chennai District","AdminAreaCode":"","Province":"TN","ProvinceName":"Tamil Nadu","ProvinceCode":"TN","PostalCode":"600010","CountryName":"India","CountryIso2":"IN","CountryIso3":"IND","CountryIsoNumber":"356","SortingNumber1":"","SortingNumber2":"","Barcode":"","POBoxNumber":"","Label":"1, New Mandapam RoadChennai600010INDIA","Type":"Unknown","DataLevel":"Premise","Field1":"","Field2":"","Field3":"","Field4":"","Field5":"","Field6":"","Field7":"","Field8":"","Field9":"","Field10":"","Field11":"","Field12":"","Field13":"","Field14":"","Field15":"","Field16":"","Field17":"","Field18":"","Field19":"","Field20":""}]}';
            } else if(responseMock == FALSE_RESPONSE) {
                validResponse='{"Items":[{"Error":"1001"}]}'; 
            } else if(responseMock == EXPRESPONSE) {
                validResponse='{"Items":[]}'; 
            }
        }
        /**
* @description creates a mock response for http calls
* @param  request
* @param response
*/
        @TestVisible
        protected override void setResponse(HttpRequest request,HttpResponse response) {
            if(responseInfo == TRUE_RESPONSE) {
                response.setStatusCode(ICS_Constants.successResponse);
            } else {
                response.setStatusCode(ICS_Constants.failureResponse);
            }
            super.setResponse(request, response);
            response.setBody(validResponse);
        }
    }
    
    
    
}