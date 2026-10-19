/**
* @Name of the Class : ICS_API_LoqateAddressSearch
* @description API class for SBO UK Loqate to Find Address with Text - SFP-33996 
* @author RUCHI AGRAWAL
* @date Jan 18th 2024
* @last modified on  : 17-05-2024
* @last modified by  : Ruchi Agrawal
*/
public with sharing class ICS_API_LoqateAddressSearch extends AOB_API_RestBaseOutboundPing {
   
	 public String urlWithParams= 'Key={0}';
     // static variable store the apex class name
    public static final String SERVICE_NAME = ICS_API_LoqateAddressSearch.class.getName();
   
    //variable store the url with the responseMock
    private  boolean responseMock;
    //variable store the url with the validResponse
    public static final String VALIDRESPONSE = '{ "Items":[ {"Id": "IN|LP|A|27614485|1_ENG","Type": "Address","Text": "1 New Mandapam Road Chennai 600010","Highlight": "","Description": ""}, {"Id": "IN|LP|A|27614487|2_ENG","Type": "Address","Text": "2 New Mandapam Road Chennai 600010","Highlight": "","Description": ""} ] }';
    //variable store the url with the containerParam
    public static final String containerParam = '&Container=';
    //variable store the url with the textParam
    public static final String textParam = '&Text=';
	
    /**
* @description Will serialize ICS_API_LoqateAddressSearch after its been populated.
*
*/
    public ICS_API_LoqateAddressSearch(String countries, String text, String type) {
        super();
        urlWithParams=urlWithParams+'&Countries=' + countries ;
        if('Container'.equals(type)) {
            urlWithParams += containerParam + text;
        } else {
            urlWithParams += textParam + text;
            
        }
        if(countries == '') {
            responseMock = false;
        } else {
            responseMock = true;
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
* @description Override to set your request and response DTO types and any other globals you may have
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
    protected override virtual String getVerb() {
        return HTTP_VERB_POST;
    }
    
    /**
* @description Overriding parent class method to use the right API Method
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
        //endPoint
        String endPoint;
        if (settings != null) {
            endPoint = settings.CMN_Path__c;
            
        }
        return endPoint ;
    }
    
    
    /**
* @description Call the parent objects' method to ensure we get code coverage
*
* @return
*/
    @TestVisible
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
* @description Wrapper class for http response
*/
        @AuraEnabled
        public String response { get; set; } //reponse of the body
        
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
        
        //Validates Response
        private  String responseJson = '{"Items":[{"Id":"IN|LP|A|27614485|1_ENG","DomesticId":"27614485","Language":"ENG","LanguageAlternatives":"ENG","Department":"","Company":"","SubBuilding":"","BuildingNumber":"1","BuildingName":"","SecondaryStreet":"","Street":"New Mandapam Road","Block":"","Neighbourhood":"","District":"Kilpauk Garden Colony","City":"Chennai","Line1":"1 New Mandapam Road","Line2":"Kilpauk Garden Colony","Line3":"","Line4":"","Line5":"","AdminAreaName":"Chennai District","AdminAreaCode":"","Province":"TN","ProvinceName":"Tamil Nadu","ProvinceCode":"TN","PostalCode":"600010","CountryName":"India","CountryIso2":"IN","CountryIso3":"IND","CountryIsoNumber":"356","SortingNumber1":"","SortingNumber2":"","Barcode":"","POBoxNumber":"","Label":"1, New Mandapam RoadChennai600010INDIA","Type":"Unknown","DataLevel":"Premise","Field1":"","Field2":"","Field3":"","Field4":"","Field5":"","Field6":"","Field7":"","Field8":"","Field9":"","Field10":"","Field11":"","Field12":"","Field13":"","Field14":"","Field15":"","Field16":"","Field17":"","Field18":"","Field19":"","Field20":""}]}';
        /**
* @description Mock class for Test classes
*/
        Public UpdateRPMock(boolean responseMock) {
            super();
            if(responseMock == true) {
                responseJson = '{"Items":[{"Id":"IN|LP|A|27614485|1_ENG","DomesticId":"27614485","Language":"ENG","LanguageAlternatives":"ENG","Department":"","Company":"","SubBuilding":"","BuildingNumber":"1","BuildingName":"","SecondaryStreet":"","Street":"New Mandapam Road","Block":"","Neighbourhood":"","District":"Kilpauk Garden Colony","City":"Chennai","Line1":"1 New Mandapam Road","Line2":"Kilpauk Garden Colony","Line3":"","Line4":"","Line5":"","AdminAreaName":"Chennai District","AdminAreaCode":"","Province":"TN","ProvinceName":"Tamil Nadu","ProvinceCode":"TN","PostalCode":"600010","CountryName":"India","CountryIso2":"IN","CountryIso3":"IND","CountryIsoNumber":"356","SortingNumber1":"","SortingNumber2":"","Barcode":"","POBoxNumber":"","Label":"1, New Mandapam RoadChennai600010INDIA","Type":"Unknown","DataLevel":"Premise","Field1":"","Field2":"","Field3":"","Field4":"","Field5":"","Field6":"","Field7":"","Field8":"","Field9":"","Field10":"","Field11":"","Field12":"","Field13":"","Field14":"","Field15":"","Field16":"","Field17":"","Field18":"","Field19":"","Field20":""}]}';
            } else {
                responseJson='{"Items":[{"Error":"1001"}]}'; 
            }
        }
        /**
* @description creates a mock response for http calls
* @param  request
* @param response
*/
        protected override void setResponse(HttpRequest request,HttpResponse response) {
            super.setResponse(request, response);
            response.setBody(responseJson);
        }
    }
    
    
    
}