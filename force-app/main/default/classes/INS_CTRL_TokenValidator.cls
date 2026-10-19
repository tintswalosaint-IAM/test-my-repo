/**
 * @description       : Controller class to validate the secure token from the experience site
 * @author            : Jaco de Lange
 * @group             : IAM : SFP - 48887 : Premium Collection Gateway - Customer Authorizes Payment
 * @created date      : 07-01-2025
 * @last modified     : Jaco de Lange : 20-10-2025
 * @Modification      : SFP-53852 - Update the paymentRequestCallOut method to also save
 *                      checkoutRequestID and merchantReferenceId
**/
public without sharing class INS_CTRL_TokenValidator {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_CTRL_TokenValidator');
    private static sbgplatform.fflib_SObjectUnitOfWork uow = (sbgplatform.fflib_SObjectUnitOfWork) ORG_Application.unitOfWork.newInstance();   

    @AuraEnabled
    public static CMN_Request__c getPaymentRequestByToken(String token) {

        List<CMN_Request__c> req = new SEL_CMN_Request().selectByToken(token);

            if (req.isEmpty() ){
                throw new AuraHandledException('No payment request found.');
            }
            else if (req[0].Secure_Access_Token_Expiration_Date__c!=null && req[0].Secure_Access_Token_Expiration_Date__c < DateTime.now()){

                 //update the payment request record
                CMN_Request__c reqUpdate = new CMN_Request__c (
                     Id = req[0].Id,
                     Status__c = 'Overdue/Expired'
                );
                try{
                    uow.registerDirty(reqUpdate);
                    uow.commitWork();
                }
                catch (Exception ex){
                    LOGGER.error('INS_CTRL_TokenValidator | getPaymentRequestByToken | exception | ' + ex.getMessage());
                    throw new AuraHandledException('An unexpected error occurred. Please contact support. ' + ex.getMessage());
                }  
                throw new AuraHandledException('This link has expired. Please call +254711068888 to request a new one and stay covered under your Flexi Protect Policy.');
            }
        return req[0];   
    }
    /*
    * @description method to prepare payload and send to mulesoft
    */
    @AuraEnabled
    public static String paymentRequestCallOut(String token){
        String jsonResStat ='';
            List<CMN_Request__c> req = new SEL_CMN_Request().selectByToken(token);

            try{
                if (!req.isEmpty()){
                INS_DTO_InstalmentRequest res = INS_API_InitiatePush.sendRequest(req[0]);
                jsonResStat = res.instalmentResponse[0].instalmentStatus;

                //update the payment request record
                    CMN_Request__c reqUpdate = new CMN_Request__c (
                            Id = req[0].Id,
                            Status__c = jsonResStat=='Success' ? 'Pending Approval' : 'Resubmitted',
                            INS_Checkout_Request_Id__c = res.instalmentResponse[0].checkoutRequestID,
                            INS_Merchant_Request_Id__c = res.instalmentResponse[0].merchantRequestID,
                            Instalment_Reference_Number__c = res.instalmentResponse[0].instalmentReferenceNumber
                    );
                    uow.registerDirty(reqUpdate);
                    uow.commitWork();
                }
                else{
                    throw new AuraHandledException('No payment request found.');
                }
            }
            catch (Exception ex){
                    LOGGER.error('INS_CTRL_TokenValidator | paymentRequestCallOut | exception | ' + ex.getMessage());
                    throw new AuraHandledException('An unexpected error occurred. Please contact support. ' + ex.getMessage());
            }     
            return jsonResStat;
    }
}