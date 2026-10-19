/***************************************************************************************
@ Author            :AmarNath Reddy
@ Date              :May 2022
@ Name of the Class :AOB_CustomerAlertSubscription
@description        :Class for dealing with Customeralert  api and sending the result to the main container and storing the values in the wrapper
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :29-03-2024
@ Modification Description : SFP-31036
***************************************************************************************/
public class AOB_CustomerAlertSubscription {   
	//HTTP Constants

    private static final String HTTP_METHOD = 'POST';
    private static final String PATH_CALLOUT = '/customer-alerts/subscription';    
    // Using for test classes
    @testVisible
    private static Integer mockHttpStatusCode;
    @testVisible
    private static String mockHttpStatus;
    @testVisible
    private static String mockHttpBody = '';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_CustomerAlertSubscription'); 
    public static  Map<String,Object> mData = new AOB_SEL_CustomMetaDataType().getMetadataByType('AOB_CustomerAlertSubscription');
    public static Map<String, Object> responseToReturnObject;
/** 
* @description Method to alert subscription which will be invoked from parent class 
* @param applicationList
* @return null
*/
    public static String invokeAlertSubscriptionCallout(List<Application__c> applicationList)  {
        
        if(applicationList != null && applicationList.isEmpty() == false) {
           
            Map<String, Object> response =  makeAlertSubCallout(applicationList);
            if(response != null && response.containsKey('ErrorDescription') == true) {
                AOB_FlowController.createVerificationRecord(applicationList[0], 'Customer Alert Subscription', 'Failed');
            } else {
                AOB_FlowController.createVerificationRecord(applicationList[0], 'Customer Alert Subscription', 'Success');
            }
            return JSON.serialize(response);
        }

        return null;
    }
/** 
* @description This method used for main callout that is CustomerAlertSubscription API 
* @param applicationRecords
* @return  responseToReturnObject
*/
    public static Map<String, Object> makeAlertSubCallout(List<Application__c> applicationRecords) {

        Application__c applicationRecord = applicationRecords[0];
        AOB_CustomerAlertSubscriptionBean customerAlertSub = AOB_CustomerAlertSubscription.constructRequest(applicationRecord);
        HttpRequest httpRequest = AOB_API_Utils.getHeaders(PATH_CALLOUT, HTTP_METHOD);
        httpRequest.setBody(JSON.serialize(customerAlertSub));

            //Make HTTP Request
            try {
                Http http = new Http();
                HttpResponse httpResponse = new HttpResponse();
                if (System.Test.isRunningTest()) {
                     if(mockHttpStatusCode!=null && mockHttpStatus!=null){
                        AOB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpBody);
                    }
                    
                }
                httpResponse = http.Send(httpRequest);

                if(httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
                    String responseBody = httpResponse.getBody();
                    if (string.isNotBlank(responseBody)) {
                        responseToReturnObject = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                    } else {
                        responseToReturnObject = new Map<String, Object>{
                            'status' => 'NO_CONTENT', 
                            'statusCode' => 204, 
                            'ErrorDescription' => 'No response body'
                        };
                        Logger.error('AOB_CustomerAlertSubscription:No response body',new string[] {applicationRecord.Id});
                    }
                } else {
                    String errorMessage = 'No Response From Server';
                    if(httpResponse.getBody() != null) {
                        Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                        errorMessage = (String) responseObject.get('moreInformation');
                    }

                    responseToReturnObject = new Map<String, Object>{
                        'status' => 'FAILED', 
                        'statusCode' => httpResponse.getStatusCode(), 
                        'ErrorDescription' => errorMessage
                    };
                    Logger.error('AOB_CustomerAlertSubscription:Response status: ' + httpResponse.getStatusCode(), new string[] {errorMessage, applicationRecord.Id});
                }
            } catch (Exception ex) {
                Logger.error('AOB_CustomerAlertSubscription: Some Un-Handled Exception Occurred', ex);
                responseToReturnObject = new Map<String, Object>{
                    'status' => 'FAILED', 
                    'ErrorDescription' => ex.getMessage()
                };
            }
        
        return responseToReturnObject;
    }
/** 
* @description Method to construct the request body
* @param applicationRecord
* @return customerAlertSub
*/
    private static AOB_CustomerAlertSubscriptionBean constructRequest(Application__c applicationRecord){

        AOB_CustomerAlertSubscriptionBean customerAlertSub = new AOB_CustomerAlertSubscriptionBean();
        AOB_CustomerAlertSubscriptionBean.CustomerAlertInformation customerAlert = new AOB_CustomerAlertSubscriptionBean.CustomerAlertInformation();        
        AOB_CustomerAlertSubscriptionBean.EachCustInformation easCustomerInfo = new AOB_CustomerAlertSubscriptionBean.EachCustInformation();        
        AOB_CustomerAlertSubscriptionBean.AlertInformation alertInfo = new AOB_CustomerAlertSubscriptionBean.AlertInformation();        

        easCustomerInfo.customerType = string.valueOf(mData.get('alert.customerType'))??''??'';
        easCustomerInfo.customerSubType = string.valueOf(mData.get('alert.customerSubType'))??'';
        easCustomerInfo.customerIdentity = applicationRecord.AOB_Customer_Id__c??''; 
        easCustomerInfo.customerHostIdentity = string.valueOf(mData.get('alert.customerHostIdentity'))??'';
        easCustomerInfo.alertCustomerCategory = string.valueOf(mData.get('alert.alertCustomerCategory'))??'';

        alertInfo.alertName = string.valueOf(mData.get('alert.alertName'))??'';
        alertInfo.alertDescriptionCategoryIdentity = '';

        customerAlert.easCustomerInfo = easCustomerInfo;
        customerAlert.alertInfo = alertInfo;
        customerAlert.alertFrequency = '';
        customerAlert.uniqueIdentity = applicationRecord.AOB_Account_Number__c;
        
        AOB_CustomerAlertSubscriptionBean.AlertCriticalRecordInfo alertCriticalRecord = new AOB_CustomerAlertSubscriptionBean.AlertCriticalRecordInfo();
        alertCriticalRecord.actualValue = string.valueOf(mData.get('alert.actualValue'))??'';
        alertCriticalRecord.displayType = string.valueOf(mData.get('alert.displayType'))??'';
        alertCriticalRecord.fieldName = string.valueOf(mData.get('alert.fieldName'))??'';
        alertCriticalRecord.fieldValue = string.valueOf(mData.get('alert.fieldValue'))??'';
        alertCriticalRecord.fieldType = string.valueOf(mData.get('alert.fieldType'))??'';

        customerAlert.alertCriticalRecord = new List<AOB_CustomerAlertSubscriptionBean.AlertCriticalRecordInfo>{alertCriticalRecord};

        List<AOB_CustomerAlertSubscriptionBean.ChannelInfo> channelInfoList = new List<AOB_CustomerAlertSubscriptionBean.ChannelInfo>();
        channelInfoList.add(new AOB_CustomerAlertSubscriptionBean.ChannelInfo(string.valueOf(mData.get('alert.ChannelInfo1')), string.valueOf(mData.get('alert.ChannelInfo2'))));
        customerAlert.channelInfo = channelInfoList;

        customerAlertSub.customerAlert = customerAlert;
        return customerAlertSub;
    }
  
}