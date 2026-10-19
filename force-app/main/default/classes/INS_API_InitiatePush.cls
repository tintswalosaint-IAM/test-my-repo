/**
 * @description       : Call out class for the payment collection request approve payment
 * @author            : Jaco de Lange
 * @group             : IAM : SFP - 48887 : Premium Collection Gateway - Customer Authorizes Payment
 * @created date      : 07-01-2025
 * @last modified     : Jaco de Lange : 20-10-2025
 * @Modification      : SFP-53852 - Add the productId to the instalment response  object
**/
public without sharing class INS_API_InitiatePush {

        private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_API_InitiatePush');  
        private static Map<String, Generic_Config__mdt> configMap = Generic_Config__mdt.getAll();
        private static final String REQUEST_ENV = configMap.get('Payment_Collection').Value__c;
        private static final String HTTP_METHOD_POST = 'POST';
        private static final String HEADER_COUNTRY_CODE = 'country_code';
        private static final String HEADER_CLIENT_ID = 'client_id';
        private static final String HEADER_CLIENT_SECRET = 'client_secret';
        private static final String HEADER_TRANSACTION_ID = 'transaction_id';
        private static final String HEADER_ORG_CLIENT_ID = 'org_client_id';
        private static final String HEADER_CHANNEL = 'channel';
        private static final String HEADER_AUTHORIZATION = 'Authorization';
        private static final String AUTHORIZATION_TYPE_BEARER = 'Bearer ';
        private static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
        private static final String HEADER_ACCEPT = 'accept';
        private static final String HEADER_CONTENT_TYPE = 'content-type';

        public static INS_DTO_InstalmentRequest sendRequest(CMN_Request__c req){

         try {
                String accessToken = CMN_Generate_Token_Helper.getAccessToken();

                INS_DTO_InstalmentRequest.InstalmentRequest InstalReq = new INS_DTO_InstalmentRequest.InstalmentRequest();
                InstalReq.paymentReferenceId = req.Payment_Reference_Id__c;
                InstalReq.paymentCollectionType = req.Payment_Collection_Type__c;
                InstalReq.contractNumber = req.Contract_Number__c;
                InstalReq.cellphoneNumber = req.Cellphone_Number__c;
                InstalReq.instalmentAmount = String.valueOf(req.Instalment_Amount__c);
                InstalReq.productId = req.INS_Product_Id__c;
               
                INS_DTO_InstalmentRequest.InstalReq Ireq = new INS_DTO_InstalmentRequest.InstalReq();
                Ireq.instalmentRequest = InstalReq;

                String payLoad = JSON.serialize(Ireq);
                
                HttpRequest request = new HttpRequest();
                request.setEndpoint('callout:INS_PaymentCollection'+'/' + REQUEST_ENV + '-sbg-exp-paymentcollection-api/api/contracts/'+req.Contract_Number__c +'/'+'payment-order');
                request.setMethod(HTTP_METHOD_POST);
                request.setHeader(HEADER_AUTHORIZATION, AUTHORIZATION_TYPE_BEARER + accessToken);
                request.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
                request.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
                request.setHeader(HEADER_CLIENT_ID, '{!$Credential.INS_Payment_Collection.client_id}');
                request.setHeader(HEADER_CLIENT_SECRET, '{!$Credential.INS_Payment_Collection.client_secret}');
                request.setHeader(HEADER_TRANSACTION_ID, '{!$Credential.INS_Payment_Collection.transaction_id}');
                request.setHeader(HEADER_ORG_CLIENT_ID, '{!$Credential.INS_Payment_Collection.org_client_id}');
                request.setHeader(HEADER_COUNTRY_CODE, '{!$Credential.INS_Payment_Collection.country_code}');
                request.setHeader(HEADER_CHANNEL, '{!$Credential.INS_Payment_Collection.channel}');
                
                request.setBody(payLoad);

                Http http = new Http();
                //Send HTTP request
                HttpResponse response = http.send(request);
                INS_DTO_InstalmentRequest res;
      
               if (response.getStatusCode() == 201 || response.getStatusCode() == 200) {
                  res = (INS_DTO_InstalmentRequest)JSON.deserialize(response.getBody(), INS_DTO_InstalmentRequest.class);
                }  
                else {
                    LOGGER.error('INS_API_InitiatePush | sendRequest | No response body', new String[] {'INS_API_InitiatePush.sendRequest', response.getBody()});
                    throw new INS_CustomException(response.getBody());
                }
                return res;
            }
            catch(Exception ex){
                LOGGER.error('INS_API_InitiatePush | sendRequest | exception | ' + ex.getMessage());
                throw new INS_CustomException(ex);
        }   
    }
}