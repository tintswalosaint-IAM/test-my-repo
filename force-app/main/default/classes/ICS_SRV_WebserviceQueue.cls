/***************************************************************************************
@Name of the Class :ICS_SRV_WebserviceQueue
@Description : Class used to store webservice call
@Author :Dayakar
@Created Date :oct 22 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
public class ICS_SRV_WebserviceQueue {
    private ICS_SRV_WebserviceQueue(){}
    public Static CMN_WebserviceCallQueue__c createWebserviceQueue(String serviceName,Boolean isSuccess,String request,String response,String objectId){
        CMN_WebserviceSetting__mdt	settings= CMN_WebserviceSetting__mdt.getInstance(serviceName);
        CMN_WebserviceCallQueue__c queueItem = new CMN_WebserviceCallQueue__c();
        queueItem.CMN_Service__c = serviceName;
        if(isSuccess){
            queueItem.CMN_StatusCode__c = '200'; 
            queueItem.CMN_Status__c='Completed';
        }else{
            queueItem.CMN_StatusCode__c = '500';
            queueItem.CMN_Status__c='Failed';
        }
        queueItem.CMN_URL__c=settings.CMN_NamedCredential__c+settings.CMN_Path__c;
        queueItem.CMN_Response__c=response;
        queueItem.CMN_Request__c=request;
        queueItem.CMN_TriggeringObjectId__c=objectId;
        return queueItem;
    }
    
}