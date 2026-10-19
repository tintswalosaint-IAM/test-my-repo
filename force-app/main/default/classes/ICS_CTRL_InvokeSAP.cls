/***************************************************************************************
@Name of the Class :ICS_CTRL_InvokeSAP
@Description : Class used to Call SAP service based on Service Name
@Author :Dayakar
@Created Date :oct 22 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
public without sharing class ICS_CTRL_InvokeSAP { 
    public static final String SERVICE_NAME = ICS_CTRL_InvokeSAP.class.getName();
    public static Map<String,String> labelInfo = new Map<String,String>();
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(SERVICE_NAME);
    private static Set<String> VALID_SERVICES = new Set<String>();
    private static string currencyCode='';
    public class SAPServiceException extends Exception {}
    
    private ICS_CTRL_InvokeSAP() {}

    public static Object callSapService(String serviceName, String opportunityId, String accountId, Boolean isJoint) {
       
           
            ics_customlabel__mdt labelData = ICS_CTRL_PreAppFormCreator.getLandingPageJSON('ICS_SAPAPIClassNames');
            VALID_SERVICES.addAll(labelData.Description__c.split(','));
            if(serviceName == 'ICS_API_SAPCreateAccount'){
                currencyCode = opportunityId;
            }
            
            String request = generateRequest(serviceName, accountId, isJoint);
            if (String.isBlank(request)) {
                throw new SAPServiceException('Failed to generate request for service: ' + serviceName);
            }
            
            Object responseBody = executeSapCall(serviceName, request);
             Object webserviceBody=createCallLog(serviceName,request,responseBody,accountId,true);
          //  insert (CMN_WebserviceCallQueue__c)webserviceBody;
            return webserviceBody;
            
        
    }
    
   
 
         @TestVisible
        private static String generateRequest(String serviceName, String accountId, Boolean isJoint) {
            
              try {
            // Process based on service name
            switch on serviceName {
                when 'ICS_API_SAPCreateCustomer' {
                    return ICS_API_SAPCreateCustomer.createCustomerRequest(accountId, isJoint);
                }
                when 'ICS_API_SAPCreateRelation' {
                    return new ICS_API_SAPCreateRelation(accountId, isJoint).jsonRequest;
                }
                when 'ICS_API_SAPCreateCYT' {
                    return new ICS_API_SAPCreateCYT(accountId, isJoint).jsonRequest;
                }
                when 'ICS_API_SAPCreateAccount' {
                    return new ICS_API_SAPCreateAccount(accountId,currencyCode).jsonRequest;
                }
                when else {
                    throw new SAPServiceException('Unsupported service name: ' + serviceName);
                }
            }
                  } catch (Exception e) {
            LOGGER.error('Failed to generate request', new String[]{ SERVICE_NAME, e.getMessage() }, e);
            throw new SAPServiceException('Request generation failed: ' + e.getMessage(),e);
        }
        }


    @TestVisible
    private static Object executeSapCall(String serviceName, String request) {
        try {
            CMN_WebserviceSetting__mdt settings = CMN_WebserviceSetting__mdt.getInstance(serviceName);
            if (settings == null) {
                throw new SAPServiceException('Web service settings not found for: ' + serviceName);
            }
            
            ICS_API_SAP_Service sapService = new ICS_API_SAP_Service(settings.CMN_NamedCredential__c);
            sapService.endPoint = settings.CMN_Path__c;
            sapService.requestBody = request;
            sapService.method = settings.AOB_Action__c;
            sapService.serviceName = serviceName;
            
            return sapService.sendRequest();
        } catch (Exception e) {
            LOGGER.error('SAP service call failed', new String[]{ SERVICE_NAME, e.getMessage() }, e);
            throw new SAPServiceException('SAP service call failed: ' + e.getMessage(),e);
        }
    }
    
    @TestVisible
    private static CMN_WebserviceCallQueue__c createCallLog(String serviceName, String request, Object response, 
                                    String opportunityId, Boolean isSuccess) {
        
            CMN_WebserviceCallQueue__c logEntry = ICS_SRV_WebserviceQueue.createWebserviceQueue(
                serviceName,
                isSuccess,
                request,
                String.valueOf(response),
                opportunityId
            );
         //  insert logEntry;
          return logEntry;
      
    }
}