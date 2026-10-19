/***************************************************************************************
@ Author            :AmarNath Reddy
@ Date              :May 2022
@ Name of the Class :AOB_CustomerAlertsProfile
@description        :Class for dealing with AOB_CustomerAlertsProfile api and sending the result to the main container and storing the values in the wrapper
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :29-03-2024
@ Modification Description : SFP-31036
***************************************************************************************/
public class AOB_CustomerAlertsProfile {

    //HTTP Constants
    private static final String HTTP_METHOD = 'POST';
    private static final String PATH_CALLOUT = '/customer-alert/eas/profile'; 
    // Using for test classes
    @testVisible
    private static Integer mockHttpStatusCode;
    @testVisible
    private static String mockHttpStatus;
    @testVisible
    private static String mockHttpBody = '';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_CustomerAlertsProfile'); 
    public static  Map<String,Object> mData = new AOB_SEL_CustomMetaDataType().getMetadataByType('AOB_CustomerAlertsProfile');
    public static Map<String, Object> responseToReturnObject;
/** 
* @description Method to Profile Alerts which will be invoked from parent class 
* @param applicationList
* @return null
*/
   public static String invokeAlertsProfile(List<Application__c> applicationList)  {
        
        if(applicationList != null && applicationList.isEmpty() == false) {
           
            Map<String, Object> response =  makeAlertSubscriptionCallout(applicationList);
            if(response != null && response.containsKey('ErrorDescription') == true) {
                AOB_FlowController.createVerificationRecord(applicationList[0], 'Customer Alert Profile', 'Failed');
            } else {
                AOB_FlowController.createVerificationRecord(applicationList[0], 'Customer Alert Profile', 'Success');
            }
            return JSON.serialize(response);
        }

        return null;
    }

/** 
* @description Method to construct the request body
* @param applicationRecord
* @return customerAlertSub
*/
private static AOB_CustomerAlertsProfileBean constructRequest(Application__c applicationRecord){
    AOB_CustomerAlertsProfileBean customerAlertsProfileBeanRecord = new AOB_CustomerAlertsProfileBean();

    AOB_CustomerAlertsProfileBean.Gen generalRecord = new AOB_CustomerAlertsProfileBean.Gen();
    generalRecord.customerInternalID    = applicationRecord.AOB_Customer_Id__c??'';
    generalRecord.customerHostID    	= string.valueOf(mData.get('customerHostID'))??'';
    generalRecord.languageID   			= string.valueOf(mData.get('languageID'))??'';
    generalRecord.firstName				= applicationRecord.AOB_FirstName__c??'';
    generalRecord.lastName				= applicationRecord.AOB_LastName__c??'';
    
    AOB_CustomerAlertsProfileBean.ContactInfo contactInformationRecord = new AOB_CustomerAlertsProfileBean.ContactInfo();
    contactInformationRecord.mobileNumber   = string.valueOf(mData.get('mobilePrefix'))+ applicationRecord.AOB_Phone__c??'';
    contactInformationRecord.emailID    	= applicationRecord.AOB_Email__c??'';
    contactInformationRecord.addressLine1  	= applicationRecord.AOB_Street__c??'';
    contactInformationRecord.addressLine2	= '';
    contactInformationRecord.city			= applicationRecord.AOB_City__c??'';
    contactInformationRecord.state			= applicationRecord.AOB_State__c??'';
    contactInformationRecord.countryCode	= applicationRecord.AOB_Country__c??'';
    
    AOB_CustomerAlertsProfileBean.BillingInformation billingInformationRecord = new AOB_CustomerAlertsProfileBean.BillingInformation();
    billingInformationRecord.debitAccountNumber = applicationRecord.AOB_Account_Number__c??'';
    
    AOB_CustomerAlertsProfileBean.SchemaRec schemaRecordsRecord = new AOB_CustomerAlertsProfileBean.SchemaRec();
    schemaRecordsRecord.schemeID   			= string.valueOf(mData.get('schemeID'))??'';
    schemaRecordsRecord.billingInformation  = billingInformationRecord;
    schemaRecordsRecord.startTimestamp  	= Datetime.newInstance(System.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
    schemaRecordsRecord.endDateTimestamp	= string.valueOf(mData.get('endDateTimestamp'))??'';

    AOB_CustomerAlertsProfileBean.BillingInformation billingInformationRecord1 = new AOB_CustomerAlertsProfileBean.BillingInformation();
    billingInformationRecord1.debitAccountNumber = applicationRecord.AOB_Account_Number__c;
    
    AOB_CustomerAlertsProfileBean.SchemaRec schemaRecordsRecord1 = new AOB_CustomerAlertsProfileBean.SchemaRec();
    schemaRecordsRecord1.schemeID   		= string.valueOf(mData.get('profile.schemeID'))??'';
    schemaRecordsRecord1.billingInformation = billingInformationRecord1;
    schemaRecordsRecord1.startTimestamp  	= Datetime.newInstance(System.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
    schemaRecordsRecord1.endDateTimestamp	= string.valueOf(mData.get('profile.endDateTimestamp'))??'';

    customerAlertsProfileBeanRecord.General = GeneralRecord;
    customerAlertsProfileBeanRecord.contactInformation = contactInformationRecord;
    customerAlertsProfileBeanRecord.schemaRecords = new List<AOB_CustomerAlertsProfileBean.SchemaRec>{schemaRecordsRecord, schemaRecordsRecord1};
    
    return customerAlertsProfileBeanRecord;
}
/** 
* @description This method used for main callout that is CustomerAlertsProfile API 
* @param applicationRecords
* @return  responseToReturnObject
*/
public static Map<String, Object> makeAlertSubscriptionCallout(List<Application__c> applicationRecords) {

        Application__c applicationRecord = applicationRecords[0];
        HttpRequest httpRequest = AOB_API_Utils.getHeaders(PATH_CALLOUT, HTTP_METHOD);
        httpRequest.setBody(JSON.serialize(AOB_CustomerAlertsProfile.constructRequest(applicationRecord)));

            //Make HTTP Request
            try {
                Http http = new Http();
                HttpResponse httpResponse = new HttpResponse();
                 if (System.Test.isRunningTest()) {
                    if(mockHttpStatusCode!=null && mockHttpStatus!=null){
                    	AOB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpbody);
                    }
                }
                httpResponse = http.Send(httpRequest);

                if(httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
                    String responseBody = httpResponse.getBody();
                    if (responseBody != null) {
                        responseToReturnObject = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                    } else {
                        responseToReturnObject = new Map<String, Object>{
                            'status' => 'NO_CONTENT', 
                            'statusCode' => 204, 
                            'ErrorDescription' => 'No response body'
                        };
                       Logger.error('AOB_CustomerAlertsProfile:No response body', new string[]{ applicationRecord.Id, null});
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
                   Logger.error('AOB_CustomerAlertsProfile :Response status: ' + httpResponse.getStatusCode(), new string[] {errorMessage, applicationRecord.Id});
                }
                
            } catch (Exception ex) {
                Logger.error('AOB_CustomerAlertsProfile: Some Un-Handled Exception Occurred', ex);
                responseToReturnObject = new Map<String, Object>{
                    'status' => 'FAILED', 
                    'ErrorDescription' => ex.getMessage()
                };
            }
        
        return responseToReturnObject;
   }    
}