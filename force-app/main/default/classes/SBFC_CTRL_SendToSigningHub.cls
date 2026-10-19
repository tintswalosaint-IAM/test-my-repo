/**
 * @description       : SFP-54443 - Controller class for lawTrust integration
 * @author            : Amlendu Bajpai
 * @group             : 
 * @last modified on  : 17-11-2025
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   17-11-2025   Amlendu Bajpai   Initial Version
**/
public with sharing class SBFC_CTRL_SendToSigningHub {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SBFC_CTRL_SendToSigningHub');
   
     /**
    * @description processes the response from the API and gives a proper response to front end
    * @param applicationId 
    * @param applicationDocumentString 
    * @return SBFC_DTO_Response 
    **/
    @AuraEnabled
    public static SBFC_DTO_Response sendDocument(
        Id recordId,
        String applicationDocumentString
    ) {
        SBFC_DTO_Response responseDto = new SBFC_DTO_Response();

        try {
            InfoAuthorizationRequest infoAuthReq;
            Account account;
            Id accountId;

            String objectType = recordId.getSObjectType().getDescribe().getName();

            if (objectType == 'InfoAuthorizationRequest') {

                infoAuthReq = new SEL_InfoAuthorizationRequest()
                    .selectById(recordId);

                if (infoAuthReq == null) {
                    throw new AuraHandledException('Info Authorization Request not found.');
                }

                accountId = infoAuthReq.SourceRecordId;

            } else if (objectType == 'Account') {

                accountId = recordId;

                infoAuthReq = new SEL_InfoAuthorizationRequest()
                    .selectBySourceRecordId(accountId);

                if (infoAuthReq != null) {
                    recordId = infoAuthReq.Id;
                }

            } else {
                responseDto.status = 'FAILED';
                responseDto.message = 'Unsupported record type.';
                return responseDto;
            }

            account = new SEL_Account().selectById(accountId);
            if(account == NULL){
                throw new AuraHandledException('No Account found.');
            }

            List<SBFC_DTO_DocumentManagement.DTO_ApplicationDocument> applicationDocuments;

                applicationDocuments =
                    (List<SBFC_DTO_DocumentManagement.DTO_ApplicationDocument>)
                        JSON.deserialize(
                            applicationDocumentString,
                            List<SBFC_DTO_DocumentManagement.DTO_ApplicationDocument>.class
                        );

            SBFC_API_SendToSigningHub sendWorkflowCallout = new SBFC_API_SendToSigningHub();
            sendWorkflowCallout.initialise(
                applicationDocuments,
                infoAuthReq,
                account
            );

            CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(SBFC_API_SendToSigningHub.SERVICE_NAME );

            queueItem.CMN_TriggeringObjectId__c = accountId;

            CMN_DAL_WebserviceCallQueue.ServiceCallResult callResult = sendWorkflowCallout.process(queueItem);

            sbgplatform.fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
            uow.registerNew(queueItem);
            uow.commitWork();

            return processResponse(callResult);
            
        } catch (Exception e) {

            LOGGER.error(
                e.getMessage(),
                new String[]{
                    SBFC_CTRL_SendToSigningHub.class.getName(),
                    e.getMessage()
                },
                e
            );

            responseDto.status = 'FAILED';
            responseDto.message = 'Error : ' + e.getMessage();
            return responseDto;
        }
    }

    /**
    * @description processes the response from the API and gives a proper response to front end
    * @param callOut 
    * @return SBFC_DTO_Response 
    **/
    private static SBFC_DTO_Response processResponse(CMN_DAL_WebserviceCallQueue.ServiceCallResult callResult) {
        SBFC_DTO_Response responseDto = new SBFC_DTO_Response();
    
        if (callResult.statusCode == String.valueOf(CMN_API_HttpBase.HTTP_OK)) {
            responseDto.statusCode = String.valueOf(CMN_API_HttpBase.HTTP_OK);
            responseDto.status = 'SUCCESS';
            responseDto.message = 'Document sent successfully';        
        }
        else {
            String message = callResult?.errors != null && !callResult.errors.isEmpty() ?callResult?.errors[0] : null;
            responseDto.status ='FAILED';
            responseDto.message = 'Error : API failed try again';
        }

        return responseDto;
    }
    public class SBFC_DTO_Response {
        @AuraEnabled public String statusCode;
        @AuraEnabled public String status;
        @AuraEnabled public String message;
    }

    
}