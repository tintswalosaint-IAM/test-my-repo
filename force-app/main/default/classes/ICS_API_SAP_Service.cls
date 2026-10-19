/**
* @description       : API Service SAP
* @test              : ICS_API_SAP_Service
* @author            : Swapnil Walse
* @group             : API
* @last modified on  : 08-10-2024
* @last modified by  : Swapnil Walse
**/
public with sharing class ICS_API_SAP_Service extends sbgplatform.ApiGatewayService{
    
    
    public String endPoint;
    public String requestBody;
    public String method;
    public String serviceName;
    
   
    
    /**
    * @description Construct the service using a specific named credential
    * @author Ramya Gurram | 06-10-2024 
    * @param namedCredential 
    **/
    public ICS_API_SAP_Service (String namedCredential) {
        super(namedCredential);
    }
    
    /**
     * @description Prepares the Http Request by calling super for the defaults and then setting Gateway specific values
     * @author Ramya Gurram | 06-10-2024 
     * @param path 
     * @param method 
     * @param requestBody 
     * @return virtual 
     **/
    public virtual override httpRequest prepareHttpRequest (String path, String method, String requestBody) {
        HttpRequest httpRequest = super.prepareHttpRequest(path, method, requestBody);
        httpRequest.setTimeout(ICS_Constants.timeoutVal);
        string guid = AOB_Utils.generateGUID();
        if(serviceName=='ICS_API_SAPCreateCustomer'){
            httpRequest.setHeader('SystemId','002');
            httpRequest.setHeader('Systemname','SBO');
            httpRequest.setHeader('Systemcountry','SA');
            httpRequest.setHeader('x-fapi-interaction-id',guid);
        }
         if(serviceName=='ICS_API_SAPCreateRelation'){
            httpRequest.setHeader('SystemId','004');
            httpRequest.setHeader('Systemname','SBO');
            httpRequest.setHeader('Systemcountry','SA');
            httpRequest.setHeader('x-fapi-interaction-id',guid);
        }
        
         if(serviceName=='ICS_API_SAPCreateCYT'){
            httpRequest.setHeader('SystemId','001');
            httpRequest.setHeader('Systemname','SBO');
            httpRequest.setHeader('Systemcountry','SA');
            httpRequest.setHeader('x-fapi-interaction-id',guid);
        }

        if(serviceName=='ICS_API_SAPCreateAccount'){
            httpRequest.setHeader('cifCountry','OS');
            httpRequest.setHeader('channelName','Salesforce');
            httpRequest.setHeader('channelId','003');
             httpRequest.setHeader('x-fapi-interaction-id',guid);
        }
        return httpRequest;
    }

    public Object sendRequest(){
        Object response;
       
            response =post(endPoint, requestBody);
        
       
        return response;
    }
    
}