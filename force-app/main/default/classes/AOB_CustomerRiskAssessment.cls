/***************************************************************************************
@ Author            :Amarnath Reddy(amarnath.reddy@standardbank.co.za)
@ Date              :june 2022
@ Name of the Class :AOB_CustomerRiskAssessment
@ Description       :Class to do API callout and check the risk status of the customer and revert the response to AOB_flowcontroller.
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :20-03-2024
@ Modification Description : SFP-31036
***************************************************************************************/

public class AOB_CustomerRiskAssessment {
    Private AOB_CustomerRiskAssessment(){}
    // HTTP Constants
    private static final String HTTP_METHOD = 'POST';
    // API specific
    private static final String PATH_CALLOUT = '/riskassessment/status';
    // Using for test classes
    @testVisible
    private static Integer mockHttpStatusCode;
    @testVisible
    private static String mockHttpStatus;
    @testVisible
    private static String mockHttpBody = '';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_CustomerRiskAssessment');
   
   /** 
   * @description This method used for main callout Risk Assessment 
   * @param applicationList
   * @param products
   * @return Returns a callout response in stringified format to process in the UI
   */
   public static String invokeRiskAssessment(List<Application__c> applicationList, List<Product2> products) {
        if(applicationList==null || applicationList.isEmpty() == true){
            throw new AuraHandledException('application is null');
        }
       if (applicationList != null && !applicationList.isEmpty() && products != null && !products.isEmpty()) {
           Map<String, Object> responseStatus = makeCustomerRiskAssessmentCallout(applicationList, products);

           if (responseStatus.containsKey('ErrorDescription')) {
               createAndLogVerificationInstance(applicationList[0].Id, 'Failed',responseStatus);
               responseStatus.put('status', 'Error');
           } else if (responseStatus.containsKey('RiskScoreStatus')) {
               createAndLogVerificationInstance(applicationList[0].Id, 'Success',responseStatus);
               responseStatus.put('status', 'Success');
               responseStatus.put('RiskScoreRating', responseStatus.get('RiskScoreRating'));
               responseStatus.put('RiskScoreStatus', responseStatus.get('RiskScoreStatus'));
           }
           
           return JSON.serialize(responseStatus);
       }
       return null;
   }
   /** 
   * @description This method used to create And LogVerificationInstance
   * @param applicationId
   * @param verificationStatus
   */
   private static void createAndLogVerificationInstance(Id applicationId, String verificationStatus,Map<String, Object>  responseStatus) {
       Verification__c verificationInstance = new Verification__c(
        Application__c = applicationId,
        Verification_Source__c = 'Customer Risk Assessment',
        AOB_DSX_Response__c = string.valueOf(responseStatus),
        Verification_Status__c = verificationStatus
        );
       AOB_FlowController.createVerificationWithInstance(verificationInstance);
        }
   
   /** 
   * @description This method used for main callout customer risk assessment API
   * @param applicationRecords
   * @param productRecords
   * @return Returns a callout response in map format for remaining processing
   */
   public static Map<String, Object> makeCustomerRiskAssessmentCallout(List<Application__c> applicationRecords, List<Product2> productRecords) {
       
       Application__c applicationRecord = applicationRecords[0]; 
       Product2 productRecord = productRecords[0];
       AOB_CustomerRiskAssessmentBean customRiskAssessmentBeanRecord = prepareRiskAssessmentBean( applicationRecord,  productRecord);

       HttpRequest httpRequest = AOB_API_Utils.getHeaders(PATH_CALLOUT, HTTP_METHOD);
       httpRequest.setBody(JSON.serialize(customRiskAssessmentBeanRecord));
       Map<String, Object> responseToReturnObject = new Map<String, Object>();
       // Make HTTP Request
       try {
        Http http = new Http();
        HttpResponse httpResponse = new HttpResponse();
        if (System.Test.isRunningTest()) {
            if(mockHttpStatusCode!=null && mockHttpStatus!=null){
                AOB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpBody);
            }
        }
        httpResponse = http.Send(httpRequest);
           if (httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
               String responseBody = httpResponse.getBody();
               if (String.isNotBlank(responseBody)) {
                   responseToReturnObject = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
               } else {
                   responseToReturnObject = new Map<String, Object>{
                       'status' => 'NO_CONTENT',
                       'statusCode' => 204,
                       'ErrorDescription' => 'No response body'
                   };
                   LOGGER.error('AOB_CustomerRiskAssessment.makeCustomerRiskAssessmentCallout: No response body', new String[] {'AOB_CustomerRiskAssessment.makeCustomerRiskAssessmentCallout', applicationRecord.Id});
               }
           } else {
               String errorMessage = 'No Response From Server';
               String responseBody = httpResponse.getBody();
               if (String.isNotBlank(responseBody)) {
                   Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                   errorMessage = (String) responseObject.get('moreInformation');
               }
   
               responseToReturnObject = new Map<String, Object>{

                        'status' => 'FAILED', 
                        'statusCode' => httpResponse.getStatusCode(), 
                        'ErrorDescription' => errorMessage

                    };
               LOGGER.error('AOB_CustomerRiskAssessment.makeCustomerRiskAssessmentCallout: FAILED', new String[] {errorMessage, applicationRecord.Id});
           }
       } catch (Exception ex) {
           LOGGER.error('AOB_CustomerRiskAssessment.makeCustomerRiskAssessmentCallout: Some Un-Handled Exception Occurred', ex);
           responseToReturnObject = new Map<String, Object>{
                    'status' => 'FAILED', 
                    'ErrorDescription'=> ex.getMessage()
                };
        }
    
        return responseToReturnObject;
    }
    
    /** 
    * @description This method used to set the parameters for payload
    * @param applicationRecords
    * @param productRecords
    * @return Returns a callout response in AOB_CustomerRiskAssessmentBean format for remaining processing
    */
     private static AOB_CustomerRiskAssessmentBean prepareRiskAssessmentBean(Application__c applicationRecord, Product2 productRecord) {
        Map<String,Object> mData = new AOB_SEL_CustomMetaDataType().getMetadataByType('AOB_CustomerRiskAssessment');
        AOB_CustomerRiskAssessmentBean customRiskAssessmentBeanRecord = new AOB_CustomerRiskAssessmentBean();
        customRiskAssessmentBeanRecord.CustomerEntityType = string.valueOf(mData.get('CustomerEntityType'))??'';
        customRiskAssessmentBeanRecord.ProductSchemeCode = productRecord.AOB_Scheme_Type__c ?? '';
        customRiskAssessmentBeanRecord.DistributionChannel = string.valueOf(mData.get('craDistributionChannel'))??'';
        customRiskAssessmentBeanRecord.NonResidentIndicator = (applicationRecord.AOB_Nationality__c == 'UG') ? 'Y' : 'N';
        customRiskAssessmentBeanRecord.ForeignCustomerIndicator = (applicationRecord.AOB_Nationality__c == 'UG') ? 'N' : 'Y';
        customRiskAssessmentBeanRecord.PEPIndicator = (applicationRecord.AOB_PEP_Status__c == 'ACTIVE') ? 'Y' : 'N';
        customRiskAssessmentBeanRecord.CustomerEmploymentType = applicationRecord.AOB_Employment_Type__c;
        customRiskAssessmentBeanRecord.HomeAddressCountryCode = applicationRecord.AOB_Country__c ?? '';
        customRiskAssessmentBeanRecord.MailingAddressCountryCode = applicationRecord.AOB_Current_Address_Country__c ?? applicationRecord.AOB_Country__c;
        customRiskAssessmentBeanRecord.NationalityOfCustomer = applicationRecord.AOB_Nationality__c ?? '';
        customRiskAssessmentBeanRecord.CountryOfBirth = applicationRecord.AOB_Nationality__c ?? '';
        customRiskAssessmentBeanRecord.SegmentOfCustomer = string.valueOf(mData.get('SegmentOfCustomer'))??'';
        customRiskAssessmentBeanRecord.SubSegmentOfCustomer = string.valueOf(mData.get('SubSegmentOfCustomer'))??'';
        return customRiskAssessmentBeanRecord;
    } 
    
 }