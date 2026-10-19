/**
 * @description       : REST service to create CMN_Payment_Request
 * @author            : Jaco de Lange
 * @group             : IAM : SFP-48886 - Premium Collection Gateway - Initiate payment collection via Mobility
 * @created date      : 07-01-2025
 * 
 * @last modified by  : Jaco de Lange
 * @last modified on. : 20-10-2025
 * @Modification      : SFP-53852 - Include ProductId as part of the request
 *                    : Change the secure access token expiration from 21 days to 7 days
 *                    : Create HttpGet method for mulesoft to consume the payment request
 * @last modified by  : Jaco de Lange
 * @last modified on. : 16-11-2025
 * @Modification      : SFP-54406 - Add buildProductUrl method to render correct template theme for product
 * 
 * @last modified by  : Jaco de Lange
 * @last modified on. : 08-07-2026
 * @Modification      : SFP-59109 - Add product details to retrieve template id and page url
**/
@RestResource(urlMapping='/instalment-request')
global with sharing class INS_URL_CreatePaymentRequest {
    private static final sbgplatform.rflib_Logger LOGGER = 
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_URL_CreatePaymentRequest');
    private static sbgplatform.fflib_SObjectUnitOfWork uow = 
        (sbgplatform.fflib_SObjectUnitOfWork) ORG_Application.unitOfWork.newInstance(); 

    private static final String SITE_Name = 'Payment_Collection';
    
    public class InstalmentInitiateResponseDTO {
        public instalmentInitiateRequest instalmentInitiateRequest;
    }
    public class CreditNotifcationRequestDTO {
        public creditNotificationRequest creditNotificationRequest;
    }

    private class instalmentInitiateRequest {
        private String paymentReferenceId;
        private String paymentCollectionType;
        private String contractNumber;
        private String cellphoneNumber;
        private String instalmentAmount;
        private String currencyval;
        private String productId;
    }
    private class creditNotificationRequest {
        private String paymentReferenceId;
        private String paymentCollectionType;
        private String contractNumber;
        private String status;
    }   

    public static string appsFlyerTemplateId;

    private class ProductDetails {
        String templateId;
        String pageUrl;
    }

    @HttpPost
    global static void receiveInstalmentResponse() {
        try {
            InstalmentInitiateResponseDTO res =
                (InstalmentInitiateResponseDTO) JSON.deserialize(RestContext.request.requestBody.toString(), 
                    InstalmentInitiateResponseDTO.class);

            instalmentInitiateRequest paymentRequestInfo = res.instalmentInitiateRequest;

            if (paymentRequestInfo!=null) {
                ProductDetails product = getProductDetails(paymentRequestInfo.productId);

                String siteUrl = getSiteBaseUrl();
                String token = generateSecureToken();
                String longUrl = buildProductUrl(product.pageUrl, siteUrl, token);
                
                String shortUrl = INS_URL_ShorteningService.createShortUrl(longUrl,product.templateId);

                insertNewRequestRecord(paymentRequestInfo, token, shortUrl);
            }
            
        } catch (Exception ex) {
            LOGGER.error('INS_URL_CreatePaymentRequest | receiveInstalmentResponse | exception | ' + ex.getMessage());
            RestContext.response.statusCode = 400;

            RestContext.response.responseBody = Blob.valueOf(ex.getMessage());
        }
    }

    @HttpPut
    global static void updatePaymentRequest() {
        RestRequest req = RestContext.request;
        String resBody = req.requestBody.toString();

        try {
             CreditNotifcationRequestDTO res =
                (CreditNotifcationRequestDTO) JSON.deserialize(resBody, CreditNotifcationRequestDTO.class);   

                 creditNotificationRequest creditNotifyReqInfo = res.creditNotificationRequest;

                 if (creditNotifyReqInfo!=null) {
                    List<CMN_Request__c> reqRec = new SEL_CMN_Request().selectByPayRefId(creditNotifyReqInfo.paymentReferenceId);

                     if (reqRec.size()>0 ) {
                        CMN_Request__c reqUpdate = new CMN_Request__c (
                            Id = reqRec[0].Id,
                            Status__c = creditNotifyReqInfo.status=='Approved' ? 'Approved' : 'Cancelled' 
                        );
                        if (Schema.SobjectType.CMN_Request__c.isUpdateable()) {
                            uow.registerDirty(reqUpdate);
                            uow.commitWork();

                            RestContext.response.statusCode = 200;
                            RestContext.response.responseBody = Blob.valueOf('{"paymentrequeststatus":"success"}');
                        }else {
                            LOGGER.error('INS_URL_CreatePaymentRequest | updatePaymentRequest | exception | You do not have permission to update payment request records.');
                        }
                     }
                 }

        } catch (Exception ex) {
            LOGGER.error('INS_URL_CreatePaymentRequest | updatePaymentRequest | exception | ' + ex.getMessage());
            RestContext.response.statusCode = 400;

            RestContext.response.responseBody = Blob.valueOf(ex.getMessage());
        } 
    }

    private static String getSiteBaseUrl() {
        List<Site> siteList = new SEL_Site().selectByName(SITE_NAME);
        return [SELECT SecureUrl FROM SiteDetail WHERE DurableId = :siteList[0].Id].SecureUrl;
    }

    private static String generateSecureToken() {
        return EncodingUtil.convertToHex(
            Crypto.generateDigest('SHA-256', Blob.valueOf(Crypto.getRandomLong() + String.valueOf(Datetime.now())))
        );
    }

      private static String buildProductUrl(String pageUrl, String baseUrl, String token) {
        if (pageUrl == null) return null;
        return baseUrl + pageUrl + token;
    }

    private static void insertNewRequestRecord(instalmentInitiateRequest req, String token, String shortUrl) {
        String recordTypeId = Schema.SObjectType.CMN_Request__c.getRecordTypeInfosByName()
            .get('Wallet Payment Request')
            .getRecordTypeId();

        CMN_Request__c reqRec = new CMN_Request__c(
            RecordTypeId = recordTypeId,
            Status__c = 'Pending Submission',
            Contract_Number__c = req.contractNumber,
            Cellphone_Number__c = req.cellphoneNumber,
            Secure_Access_Token__c = token,
            Payment_Collection_Type__c = req.paymentCollectionType,
            Payment_Reference_Id__c = req.paymentReferenceId,
            Instalment_Amount__c = req.instalmentAmount,
            Currency__c = req.currencyval,
            Secure_Access_Token_Expiration_Date__c = DateTime.now().addHours(168),
            INS_Product_Id__c = req.productId,
            Site_URL_Link__c = shortUrl
        );

        if(Schema.SobjectType.CMN_Request__c.iscreateable()){
                uow.registerNew(reqRec);
                uow.commitWork();

                RestContext.response.statusCode = 200;
                RestContext.response.responseBody = Blob.valueOf('{"smsurl":"' + reqRec.Site_URL_Link__c+'"}');
        }
        else {
            LOGGER.error('INS_URL_CreatePaymentRequest | receiveInstalmentResponse | exception | You do not have permission to update payment request records.');
        }
    }

    public static ProductDetails getProductDetails(String productName) {
        ProductDetails details = new ProductDetails();
        if (String.isBlank(productName)) return null;
       
        for (INS_Payment_Collection_Products__mdt rec : INS_Payment_Collection_Products__mdt.getAll().values()) {
            if (rec.INS_Product_Name__c == productName) {
                details.templateId = rec.INS_Appsflyer_Template_ID__c;
                details.pageUrl = rec.INS_Theme_Page_URL__c;
                return details;
            }
        }
        return null;
    }
}