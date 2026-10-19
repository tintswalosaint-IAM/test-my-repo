/***************************************************************************************
@Author            :Lokesh Bothsa 
@Date              :July 2023
@Name of the Class :BCB_FlowController
@description       :Class for dealing with Rely Comply
@Last Modified By  :Lokesh Bothsa  
@Last Modified On  :03-04-2024
@Modification Description : SFP-37302
***************************************************************************************/
public without sharing class BCB_FlowController {
/**
* @description Method to document and kyc name map
* @return Map<String, String>
*/ 
public static Map<String, String> sourceQueueMap = new Map<String, String> {
    'Mobile Wallet Status Check' => 'UG_BCB_Unfunded_Accounts_Queue',
    'Mobile Wallet' => 'UG_BCB_Unfunded_Accounts_Queue',
    'Customer Alert Profile' => 'BCB_Frozen_accounts',
    'OD Account Create' => 'UG_BCB_Incomplete_Account_Opened_Queue',
    'Rely Comply' => 'UG_BCB_Sanctioned_Customer_Queue',
    'Customer Risk Assessment' => 'UG_BCB_Incomplete_Customer_Verification',
    'CIF' => 'UG_BCB_Incomplete_Customer_Verification',
    'Customer Check' => 'UG_BCB_Incomplete_Customer_Verification'
};
private static Map<String, String> documentAndKYCNameMap = new Map<String, String>{
        'FrontImage' => 'KYC Documents Proof of Identity',
            'Proof Of Income' => 'KYC Documents Proof of Income',
            'BackImage' => 'KYC Documents Proof of Residence',
            'DocImage' => 'Account Administration Passport Sized Photos',
            'FaceImage' => 'Account Administration Passport Sized Photos',
            'TC_for_electronicBanking' => 'Account Administration Account Maintenance',
            'Signature File' => 'Mandates Signature Card',
            'literacyProtectionPdf' => 'Mandatory Bank Documents Declaration Of Literacy'
};
private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('BCB_FlowController');              
/**
* @description Method to invoke Risk Assessment check invoked from bcb_comp_signLegalAgreement lwc component 
* @param applicationParticipantId
* @param productcode
* @return Stringified Response of Customer Risk Assessment callout
*/
@AuraEnabled
    public static String invokeRiskAssessmentCallout(string applicationParticipantId, string productcode) {
        try {
            List<Application_Participant__c> appParticipant = new SEL_ApplicationParticipant().selectApplicationParticpantById(applicationParticipantId);
            List<Application__c> applicationList = new SEL_Application().selectAppsById(appParticipant[0].Application__c);
            List<Product2> productList=[select id,ProductCode,AOB_Memo_Code__c,AOB_Scheme_Type__c from Product2 where AOB_Memo_Code__c=:productcode];           
            String returnString = CMN_CustomerRiskAssessment.invocableMethod(applicationList, productList,appParticipant);
            if(String.isNotBlank(returnString) == true && returnString != null) {
                Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(returnString);
                updateApplicationRecord(responseObject,applicationList, appParticipant);
                return returnString;
            }
        } catch (Exception ex) {
            LOGGER.error('BCB_FlowController.invokeRiskAssessmentCallout', ex);
            throw new BCB_CustomException(ex.getMessage());
        }
        return null;
    }

/**
* @description Method to update the Application Record 
* @param responseObject 
* @param applicationList 
* @param appParticipant 
*/
 
@TestVisible
public static void updateApplicationRecord(Map<String, Object> responseObject, List<Application__c> applicationList, List<Application_Participant__c> appParticipant){
    if(responseObject.containsKey('RiskScoreStatus') == true && responseObject.containsKey('RiskScoreRating')) {
        Application__c applicationRecord = new Application__c();
        applicationRecord.Id = applicationList[0].Id;
        applicationRecord.AOB_Risk_Score_Rating__c = ((String) responseObject.get('RiskScoreRating'));
        applicationRecord.AOB_Risk_Score_Status__c = ((String) responseObject.get('RiskScoreStatus'));
        applicationRecord.AOB_UG_BCB_Stage__c = 'CRA';
        if(applicationRecord != null){
            update applicationRecord;
        }
        BCB_FlowController.createVerificationRecordForParticipant(appParticipant[0], 'Customer Risk Assessment', 'Success');
    }
}

/**
* @description Method to invoke Customer Creation into finacle system invoked from bcb_comp_signLegalAgreement lwc component 
* @param applicationParticipantId 
* @return Stringified Response of Retail Customer Creation callout
*/
@AuraEnabled
    public static String invokeCustomerCreation(string applicationParticipantId) {
        try {
            List<Application_Participant__c> appParticipant = new SEL_ApplicationParticipant().selectApplicationParticpantById(applicationParticipantId);
            List<Application__c> applicationList = new SEL_Application().selectAppsById(appParticipant[0].Application__c);
            List<Individual> individualRecords = new SEL_Individual().findParticipantById(applicationParticipantId);
            String returnString;
            Map<String, Object> parsedStringMap = new Map<String, Object>();
            if(appParticipant[0].AOB_CIFID__c == null){
                returnString = CMN_CreateRetailCif.invocableMethod(applicationList,appParticipant,individualRecords);
                parsedStringMap = (Map<String, Object>) JSON.deserializeUntyped(returnString);
                if(parsedStringMap != null && (String) parsedStringMap.get('Status') == 'SUCCESS') {
                    parsedStringMap.put('AOB_Customer_Id__c', (String) parsedStringMap.get('CustId'));
                    appParticipant[0].AOB_CIFID__c = (String) parsedStringMap.get('CustId');
                    appParticipant[0].UG_BCB_Stage__c = 'CIF';
                    update appParticipant;        
                    returnString = JSON.serialize(parsedStringMap);
                    BCB_FlowController.createVerificationRecordForParticipant(appParticipant[0], 'CIF', 'Success');
                }

            }else{
                parsedStringMap.put('Status','RetailCustomerExist');
                returnString = JSON.serialize(parsedStringMap);   
            }
            return returnString;
        } catch (Exception ex) { 
            LOGGER.error('BCB_FlowController.invokeCustomerCreation', ex);
            throw new BCB_CustomException(ex.getMessage());
        }
    }
    
/**
* @description Method to invoke Corporate Customer Creation into finacle system invoked from bcb_comp_signLegalAgreement lwc component 
* @param applicationParticipantId 
* @return Stringified Response of Corporate Customer Creation callout
*/
 @AuraEnabled
    public static String invokeCustomerCreationCorporate(string applicationParticipantId) {
        try {
            List<Application_Participant__c> appParticipant = new SEL_ApplicationParticipant().selectApplicationParticpantById(applicationParticipantId);
            List<Application__c> applicationList = new SEL_Application().selectAppsById(appParticipant[0].Application__c);
            String returnString;
            Map<String, Object> parsedStringMap = new Map<String, Object>();
            if(applicationList[0].AOB_Customer_Id__c == null ){
                returnString = CMN_CreateCorporateCif.invocableMethod(applicationList,appParticipant);
                parsedStringMap = (Map<String, Object>) JSON.deserializeUntyped(returnString);
                if(parsedStringMap != null && (String) parsedStringMap.get('status') == 'SUCCESS') {
                    parsedStringMap.put('AOB_Customer_Id__c', (String) parsedStringMap.get('uuid'));
                    applicationList[0].AOB_Customer_Id__c = (String) parsedStringMap.get('uuid');
                    applicationList[0].AOB_UG_BCB_Stage__c = 'CIF';
                    update applicationList;
                    BCB_FlowController.createVerificationRecord(applicationList[0], 'CIF', 'Success');
                    returnString = JSON.serialize(parsedStringMap);
                }
            }else{
                parsedStringMap.put('Status','CorporateCustomerExist');
                returnString = JSON.serialize(parsedStringMap); 
            }
            return returnString;
        } catch (Exception ex) {
            LOGGER.error('BCB_FlowController.invokeCustomerCreationCorporate', ex);
            throw new BCB_CustomException(ex.getMessage());
        }
    }
    /**
* @description Method to invoke Customer Creation into finacle system invoked from bcb_comp_signLegalAgreement lwc component 
* @param applicationParticipantId 
* @param productcode 
* @return Stringified Response of Retail Customer Creation callout
*/
 @AuraEnabled
    public static String invokeGETCustomerAccountNumber(string applicationParticipantId,string productcode) {
        try {
            List<Application_Participant__c> appParticipant = new SEL_ApplicationParticipant().selectApplicationParticpantById(applicationParticipantId);
            List<Application__c> applicationList = new SEL_Application().selectAppsById(appParticipant[0].Application__c);
            List<Product2> productList=[select id,ProductCode,AOB_Memo_Code__c,AOB_Scheme_Type__c,AOB_Pricing_Option__c from Product2 where AOB_Memo_Code__c=:productcode LIMIT 1 ];
            Map<String, Object> parsedStringMap = new Map<String, Object>();
            String returnString;
            if(applicationList[0].AOB_Account_Number__c == null){
                returnString = CMN_ODAccountCreation.invocableMethod(applicationList,productList,appParticipant);
                returnString = checkODAccountCreation(returnString, applicationList);
            }else{
                parsedStringMap.put('AccountExist','Success');
                returnString = JSON.serialize(parsedStringMap);
            }
            return returnString;
        } catch (Exception ex) {
            LOGGER.error('BCB_FlowController.invokeGETCustomerAccountNumber', ex);
            throw new BCB_CustomException(ex.getMessage());
        }
    }

    /**
* @description Method to update Application record, create Verification Record. 
* @param returnString
* @param applicationList 
* @return String
*/
@TestVisible
public static String checkODAccountCreation(String returnString, List<Application__c> applicationList){
    Map<String, Object> parsedStringMap = (Map<String, Object>) JSON.deserializeUntyped(returnString);
    if(parsedStringMap != null && (String) parsedStringMap.get('status') == 'SUCCESS') {
        applicationList[0].AOB_Account_Number__c = (String) parsedStringMap.get('accountNumber');
        applicationList[0].AOB_UG_BCB_Stage__c = 'Account created';
        update applicationList;
        if(applicationList[0].CNGCU_CSEmail__c != null) {
            try {
                CMN_Email_Send.sendEmailTemplateWithTemplate(applicationList);
            } catch (Exception ex) {
                parsedStringMap.put('Message', ex.getMessage());
            }
        }
        BCB_FlowController.createVerificationRecord(applicationList[0], 'OD Account Create', 'Success');
        returnString = JSON.serialize(parsedStringMap);
    }
    return returnString;
}

    /**
* @description Method to invoke Customer Creation into finacle system invoked from bcb_comp_signLegalAgreement lwc component 
* @param applicationParticipantId 
* @return String Response of Retail Customer Creation callout
*/
@AuraEnabled
    public static String invokeAccountLockProfile(String applicationParticipantId) {
        try {
            List<Application_Participant__c> appParticipant = new SEL_ApplicationParticipant().selectApplicationParticpantById(applicationParticipantId);
            List<Application__c> applicationList = new SEL_Application().selectAppsById(appParticipant[0].Application__c);
            string returnString =  CMN_CreateAccountLockProfile.invocableMethod(applicationList,appParticipant);
            Map<String, Object> parsedStringMap = (Map<String, Object>) JSON.deserializeUntyped(returnString); 
            if(parsedStringMap != null && parsedStringMap.containsKey('ErrorDescription') == false) {
                Application__c application = new Application__c();
                application.id =  applicationList[0].Id;
                application.AOB_UG_BCB_Stage__c = 'Debit freeze';
                if(application != null){
                    update application;
                }
                parsedStringMap.put('status','Success');
                parsedStringMap.put('selectedCurrency',applicationList[0].AOB_Selected_Currency__c);
                BCB_FlowController.createVerificationRecord(applicationList[0], 'Debit freeze', 'Success');
                returnString = JSON.serialize(parsedStringMap);
            }
            return returnString;
        } catch(Exception ex) {
            LOGGER.error('BCB_FlowController.invokeAccountLockProfile', ex);
            throw new BCB_CustomException(ex.getMessage());
        }
    }

/**
* @description Method to invoke Customer Creation into finacle system invoked from bcb_comp_signLegalAgreement lwc component 
* @param applicationParticipantId 
* @return String
*/
@AuraEnabled
    public static String invokeMobileWalletCallout(string applicationParticipantId) {
        try {
            List<Application_Participant__c> appParticipant = new SEL_ApplicationParticipant().selectApplicationParticpantById(applicationParticipantId);
            List<Application__c> applicationList = new SEL_Application().selectAppsById(appParticipant[0].Application__c);
            String mobileWalletResponse = CMN_MobileWallet.invocableMethod(applicationList,appParticipant);
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(mobileWalletResponse);
            if(responseMap != null && responseMap.get('statusCode') == '01') {
                BCB_FlowController.createVerificationRecordForParticipant(appParticipant[0], 'Mobile Wallet', 'Success');              
            } else {
                BCB_FlowController.createVerificationRecordForParticipant(appParticipant[0], 'Mobile Wallet', 'Failed');
                BCB_FlowController.assignLeadToQueue(applicationList[0].AOB_Lead__c, 'UG_BCB_Unfunded_Accounts_Queue');           
            } 
            return json.serialize(responseMap);
        } catch (Exception ex) { 
            LOGGER.error('BCB_FlowController.invokeMobileWalletCallout', ex);
            throw new BCB_CustomException(ex.getMessage());
        }
    }
    /**
* @description Method to invoke Customer Creation into finacle system invoked from bcb_comp_signLegalAgreement lwc component 
* @param applicationParticipantId 
* @param mobileWalletResponse 
* @return String
*/
@AuraEnabled
public static String invokeMobileWalletStatusCallout(string applicationParticipantId,string mobileWalletResponse) {
    try {
        List<Application_Participant__c> appParticipant = new SEL_ApplicationParticipant().selectApplicationParticpantById(applicationParticipantId);
        List<Application__c> applicationList = new SEL_Application().selectAppsById(appParticipant[0].Application__c);
        String returnString = CMN_MobileWalletStatus.invocableMethod(applicationList, mobileWalletResponse);
        Map<String, Object> parsedStringMap = (Map<String, Object>) JSON.deserializeUntyped(returnString);
        if(parsedStringMap != null &&(parsedStringMap.get('statusCode')  == 00)) {
            applicationList[0].AOB_UG_BCB_Stage__c = 'Congratulations';
            update applicationList;
            parsedStringMap.put('Status','Success');
            BCB_FlowController.createVerificationRecordForParticipant(appParticipant[0], 'Mobile Wallet Status Check', 'Success');
        }else{
            parsedStringMap.put('Status','Failed');
            BCB_FlowController.createVerificationRecordForParticipant(appParticipant[0], 'Mobile Wallet Status Check', 'Failed');
            BCB_FlowController.assignLeadToQueue(applicationList[0].AOB_Lead__c, 'UG_BCB_Unfunded_Accounts_Queue');  
        }
        return json.serialize(parsedStringMap);
    } catch (Exception ex) { 
        LOGGER.error('BCB_FlowController.invokeMobileWalletCallout', ex);
        throw new BCB_CustomException(ex.getMessage());
    }
}
    /**
* @description Method to invoke alert corpadd invoked from bcb_comp_signLegalAgreement lwc component 
* @param applicationParticipantId 
* @return Stringified Response of alert corpadd callout
*/
@AuraEnabled
public static String invokeAlertCorpAdd(string applicationParticipantId) {
        try {
            List<Application_Participant__c> appParticipant = new SEL_ApplicationParticipant().selectApplicationParticpantById(applicationParticipantId);
            List<Application__c> applicationList = new SEL_Application().selectAppsById(appParticipant[0].Application__c);
            String returnString = CMN_AlertCorpAdd.invocableMethod(applicationList);
            Map<String, Object> parsedStringMap = (Map<String, Object>) JSON.deserializeUntyped(returnString);
            map<string,object> customerAlertMap = new  map<string,object>();
            if(parsedStringMap.containsKey('customerAlert')){
               customerAlertMap = (map<string,object>)parsedStringMap.get('customerAlert');
            }
            if(parsedStringMap != null && (string)customerAlertMap.get('corporateIdentity') != null) {
                parsedStringMap.put('AOB_Customer_Id__c', (string)customerAlertMap.get('corporateIdentity'));
                parsedStringMap.put('Status', 'Success');
               
                applicationList[0].AOB_Customer_Id__c = (string)customerAlertMap.get('corporateIdentity');
                update applicationList;
                BCB_FlowController.createVerificationRecord(applicationList[0], 'Alert Corp Add', 'Success');
                returnString = JSON.serialize(parsedStringMap);    
            }
            return returnString;
        } catch (Exception ex) {
            LOGGER.error('BCB_FlowController.invokeAlertCorpAdd', ex);
            throw new BCB_CustomException(ex.getMessage());
        }
    }

/**
* @description Method to invoke profile alert callout invoked from aob_form_Creator lwc component 
* @param applicationParticipantId 
* @return String
*/
@AuraEnabled
    public static String invokeProfileAlertCallout(string applicationParticipantId) {
        try {
            List<Application_Participant__c> appParticipant = new SEL_ApplicationParticipant().selectApplicationParticpantById(applicationParticipantId);
            List<Application__c> applicationList = new SEL_Application().selectAppsById(appParticipant[0].Application__c);
            string customerAlertProfileResponse  = CMN_CustomerAlertsProfile.invocableMethod(applicationList,appParticipant);
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(customerAlertProfileResponse);
            if(responseMap != null && responseMap.containsKey('ErrorDescription') == true){
                BCB_FlowController.createVerificationRecord(applicationList[0], 'Customer Alert Profile', 'Failed');
                BCB_FlowController.assignLeadToQueue(applicationList[0].AOB_Lead__c, 'UG_BCB_Incomplete_Account_Opened_Queue'); 
            } 
            else{
                BCB_FlowController.createVerificationRecord(applicationList[0], 'Customer Alert Profile', 'Success');
                responseMap.put('alertProfileApi','Success');
            }
            return json.serialize(responseMap);
        } catch (Exception ex) {
            LOGGER.error('BCB_FlowController.invokeProfileAlertCallout', ex);
            throw new BCB_CustomException(ex.getMessage());
        }
    }
    /**
* @description Method to invoke alert subscription callout invoked from bcb_form_Creator lwc component 
* @param applicationParticipantId 
* @return String
*/
    @AuraEnabled
    public static String invokeAlertSubscriptionCallout(string applicationParticipantId){
        try {
            List<Application_Participant__c> appParticipant = new SEL_ApplicationParticipant().selectApplicationParticpantById(applicationParticipantId);
            List<Application__c> applicationList = new SEL_Application().selectAppsById(appParticipant[0].Application__c);
            string alertSubscriptionResponse =CMN_CustomerAlertSubscription.invocableMethod(applicationList);
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(alertSubscriptionResponse);
            if(responseMap != null && responseMap.containsKey('ErrorDescription') == true){
                BCB_FlowController.createVerificationRecord(applicationList[0], 'Customer Alert Subscription', 'Failed');
                BCB_FlowController.assignLeadToQueue(applicationList[0].AOB_Lead__c, 'UG_BCB_Incomplete_Account_Opened_Queue');
            }else{
                applicationList[0].AOB_UG_BCB_Stage__c = 'Customer Alert Subscription';
                responseMap.put('AlertSubscription','Success');
                update applicationList;
                BCB_FlowController.createVerificationRecord(applicationList[0], 'Customer Alert Subscription', 'Success');
            }
            return json.serialize(responseMap);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
/**
* @description Method to get identifii URL to rendered invoked from identifii lwc component 
* @param applicationParticipantId 
* @return Stringified Response of Identifii callout
*/
 @AuraEnabled
public static String invokeIdentifiiCallout(String applicationParticipantId) {
    try {
        List<Application_Participant__c> appliactionParticipant =New SEL_ApplicationParticipant().selectApplicationParticpantById(applicationParticipantId);
            return CMN_IdentifiiApplicant.invocableMethod(appliactionParticipant);
    } catch (Exception ex) {
        LOGGER.error('BCB_FlowController.invokeIdentifiiCallout', ex);
        throw new BCB_CustomException(ex.getMessage());
    }
}  
 /**
* @description Method to generate GUID used for callouts invoked from all callout classes
* @return  String created unique id used for callouts
*/
    public static String createGUID() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String newGuid = h.SubString(0,8) + '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        return newGuid;
    }

/**
* @description Method to create verification with instance
* @param verificationInstance 
* @return Id
*/
public static Id createVerificationWithInstance(Verification__c verificationInstance) {
        try {
            insert verificationInstance;
            return verificationInstance.Id;
        } catch (Exception ex) {
            LOGGER.error('BCB_FlowController.createVerificationWithInstance', ex);
            throw new BCB_CustomException(ex.getMessage());
        }
    }
/**
* @description Method to create verification with instance
* @param applicationRecord 
* @param source 
* @param status 
* @return Id
*/
public static Id createVerificationRecord(Application__c applicationRecord, String source, String status) {
        try {
            string currencyCode;
            if(applicationRecord.AOB_Selected_Currency__c == 'UGX'){
                currencyCode = 'UGX';
            }else if(applicationRecord.AOB_Selected_Currency__c == 'USD'){
                currencyCode = 'USD';
            }
            Verification__c verifyInstance = new Verification__c(
                Application__c = applicationRecord.Id,
                Verification_Source__c = source,
                Verification_Status__c = status,
                CurrencyIsoCode = currencyCode
            );
            insert verifyInstance;
            return verifyInstance.Id;
        } catch (Exception ex) {
            LOGGER.error('BCB_FlowController.createVerificationRecord', ex);
            throw new BCB_CustomException(ex.getMessage());
        }
    }
/**
* @description Method to create verification with instance
* @param partcipantRecord 
* @param source 
* @param status 
* @return Id
*/
public static Id createVerificationRecordForParticipant(Application_Participant__c partcipantRecord, String source, String status) {
        try {
            List<Application_Participant__c> appParticipant = new SEL_ApplicationParticipant().selectApplicationParticpantById(partcipantRecord.Id);
            string currecyCode;
            if(appParticipant[0].CurrencyIsoCode =='UGX'){
                currecyCode = 'UGX';
            }else if(appParticipant[0].CurrencyIsoCode =='USD'){
                currecyCode = 'USD';
            }
            Verification__c verifyInstance = new Verification__c(
                Application_Participant__c = appParticipant[0].Id,
                Verification_Source__c = source,
                Verification_Status__c = status,
                CurrencyIsoCode = currecyCode
            );
            
            insert verifyInstance;
            return verifyInstance.Id;
        } catch (Exception ex) {
            LOGGER.error('BCB_FlowController.createVerificationRecordForParticipant', ex);
            throw new BCB_CustomException(ex.getMessage());
        }
    }
/**
* @description Method to create verification with instance
* @param appParticipantId 
*/
@AuraEnabled
public static void createVerificationRecordforInCorrectOTP(String appParticipantId) {
    try {
        Application_Participant__c appParticipant = new SEL_ApplicationParticipant().selectApplicationParticpantByApplicationId(appParticipantId);
        Id VerificationId = createVerificationRecordForParticipant(appParticipant, 'NIRA', 'Failed');
    }
    catch (Exception ex) {
        LOGGER.error('BCB_FlowController.createVerificationRecordforInCorrectOTP', ex);
        throw new BCB_CustomException(ex.getMessage());
    }
}
 /**
* @description Method to create verification with instance
* @param leadId 
* @param queueName 
*/   
    public static void assignLeadToQueue(Id leadId, String queueName) {
        try {
            ID queueId = [SELECT Queue.Id FROM queuesobject WHERE queue.name=:queueName].Queue.Id;
            Lead leadRecordToReAssign = [select id , OwnerId from lead where id=:leadId ];
            leadRecordToReAssign.OwnerId=queueId;
            update leadRecordToReAssign;
        } catch (Exception ex) {
            LOGGER.error('BCB_FlowController.assignLeadToQueue', ex);
            throw new BCB_CustomException(ex.getMessage());
        }
    }
/**
* @description Method to verify MNO invoked from  lwc component 
* @param applicationParticipantId 
* @return String Response of MNO callout
*/
@AuraEnabled
    public static String invokeMobileMoneyNumberValidate(String applicationParticipantId) {
        try {
            List<Application_Participant__c> appliactionParticipant =New SEL_ApplicationParticipant().selectApplicationParticpantById(applicationParticipantId);
            string appid = appliactionParticipant[0].Application__c;
            Application__c appRecord = new SEL_Application().selectAppById(appid);
            List<Lead> leadList = new SEL_Lead().selectLeadByRecId(appRecord.AOB_Lead__c);
            String returnString = CMN_MobileNumberValidate.invocableMethod(appliactionParticipant);
            if(returnString != null) {
                String customerName = updateApplicationOnMNOValidate(returnString, appRecord, leadList[0].Name);
                if(customerName != leadList[0].Name){
                    BCB_FlowController.assignLeadToQueue(appRecord.AOB_Lead__c, 'UG_BCB_Incomplete_Customer_Verification'); 
                    BCB_CTRL_FormCreator.createVerificationRecord(appliactionParticipant[0], 'MNO', 'Failed');
                }else{
                BCB_CTRL_FormCreator.createVerificationRecord(appliactionParticipant[0], 'MNO', 'Success');
                }
            }
            return returnString;
        } catch (Exception ex) {
            LOGGER.error('BCB_FlowController.invokeMobileMoneyNumberValidate', ex);
            throw new BCB_CustomException(ex.getMessage());
        }
    }
/**
* @description Method to update the Application Record and create Verification Method on MNO Validate
* @param returnString 
* @param appRecord 
* @param leadName 
* @return String
*/  
    @TestVisible
    public static String updateApplicationOnMNOValidate(String returnString, Application__c appRecord, String leadName){
        Map<String, Object> parsedStringMap = (Map<String, Object>) JSON.deserializeUntyped(returnString);
        String customerName = (String) parsedStringMap.get('CustomerName');
        application__c apprec = new Application__c();
        apprec.id = appRecord.id;
        if(customerName != null) {
            customerName = customerName.trim();
            apprec.AOB_MNO_Customer_Name__c = customerName;
            apprec.AOB_MNO_Name_Matched__c = (
                    customerName == leadName
            );
            update apprec;
        }
        return customerName;
    }
/**
* @description Method to verify customer to match with NIRA from BCB_CTRL_FormCreator lwc component 
* @param applicationParticipantId 
* @return String Response of NIRA callout
*/
 @AuraEnabled
    public static String verifyThroughNIRA(String applicationParticipantId) {  
        try {
            List<Application_Participant__c> appliactionParticipant =New SEL_ApplicationParticipant().selectApplicationParticpantById(applicationParticipantId);
            Application__c appRecord = new SEL_Application().selectAppById( appliactionParticipant[0].Application__c);
            String returnString = CMN_NIRA.invocableMethod(appliactionParticipant);
            if(String.isNotBlank(returnString)) {
                Map<String, Object> parsedStringMap = (Map<String, Object>) JSON.deserializeUntyped(returnString);
                if(parsedStringMap != null && parsedStringMap.containsKey('matchingStatus') 
                   && parsedStringMap.get('matchingStatus') === 'true') {
                       update new Application__c(Id = appliactionParticipant[0].Application__c, AOB_Stage__c = 'NIRA');
                   }else{
                    BCB_FlowController.assignLeadToQueue(appRecord.AOB_Lead__c, 'UG_BCB_Incomplete_Customer_Verification'); 
                   }
            return returnString; }return null;
        }catch (Exception ex) {
            LOGGER.error('BCB_FlowController.verifyThroughNIRA', ex);
            throw new BCB_CustomException(ex.getMessage());
        }
        }
      /**
* @description Method to invoke Signature Verification Callout  
* @param applicationParticipantId 
* @return Stringified Response of Signature Verification Callout
*/
@AuraEnabled
public static String invokeSignatureVerify(String applicationParticipantId) {
    try {  
        list<Application_Document__c> appDoc = [SELECT Id, Document_Type__c FROM Application_Document__c WHERE Application_Participant__c =: applicationParticipantId AND (Document_Type__c = 'upload signature' OR Document_Type__c = 'FaceImage') LIMIT 2];
        List<ContentDocumentLink> docLinks;
        if(appDoc[0].Document_Type__c == 'upload signature'){
            docLinks = new SEL_ContentDocumentLink().getDocumentLinkByLinkedEntityId(appDoc[0].id); 
            docLinks.addAll(new SEL_ContentDocumentLink().getDocumentLinkByLinkedEntityId(appDoc[1].Id));
        }
        else{
            docLinks = new SEL_ContentDocumentLink().getDocumentLinkByLinkedEntityId(appDoc[1].id); 
            docLinks.addAll(new SEL_ContentDocumentLink().getDocumentLinkByLinkedEntityId(appDoc[0].Id));
        }
        List<ContentVersion> signatureList = new SEL_ContentVersion().selectApplicationById(docLinks[0].ContentDocumentId);
        signatureList.addAll(new SEL_ContentVersion().selectApplicationById(docLinks[1].ContentDocumentId)); 
        List<Application_Participant__c> appliactionParticipant =New SEL_ApplicationParticipant().selectApplicationParticpantById(applicationParticipantId);
        String returnString = CMN_SignatureVerify.invocableMethod(appliactionParticipant, signatureList);
        Map<String, Object> parsedStringMap = (Map<String, Object>) JSON.deserializeUntyped(returnString);
    
        if(parsedStringMap != null && (String) parsedStringMap.get('status') == 'SUCCESS') {
            update new Application__c(Id = appliactionParticipant[0].Application__c, AOB_Stage__c = 'Signature');
        }     
        return returnString; 
    } catch (Exception ex) {
        LOGGER.error('BCB_FlowController.invokeSignatureVerify', ex);
        throw new BCB_CustomException(ex.getMessage());
    }
}
/**
* @description Method to get inserted identifii documents invoked from identifii lwc component 
* @param appParticipantId
* @param documentId
* @return Stringified Response of GET Identifii Documents callout
*/
@AuraEnabled
    public static String invokeIdentifiiGETDocumentsCallout(string appParticipantId, String documentId) {
        try {          
            List<Application_Participant__c> appParticipant = new SEL_ApplicationParticipant().selectApplicationParticpantById(appParticipantId);
            List<Application__c> applicationList = new SEL_Application().selectAppsById(appParticipant[0].Application__c);
            String returnString = CMN_IdentifiiApplicant.invocableGETMethod(applicationList, documentId);
            Map<String,Object> parsedStringMap = (map<string,object>)json.deserializeUntyped(returnString);
            if(String.isNotBlank(returnString) == true) {
                BCB_Identify_BodyBean.Response responseMap =  (BCB_Identify_BodyBean.Response) JSON.deserialize(returnString, BCB_Identify_BodyBean.Response.class);
                if(responseMap != null  && responseMap.IdentityImages != null && responseMap.IdentityImages.isEmpty() == false && !applicationList.isEmpty()&& responseMap.DateOfExpiry !=null) {
                    String dateofExp = responseMap.DateOfExpiry;
                    String personalNumber =  responseMap.PersonalNumber.trim();
                    List<String> dateComponents = dateofExp.split('\\.');
                    Integer day = Integer.valueOf(dateComponents[0]);
                    Integer month = Integer.valueOf(dateComponents[1]);
                    Integer year = Integer.valueOf(dateComponents[2]);
                    Date dt = Date.newInstance(year, month, day);                  
                    applicationList[0].AOB_Identifii_Expire_Date__c= date.valueOf(dt);
                    if(personalNumber ==  appParticipant[0].AOB_IDNumber__c){
                        parsedStringMap.put('IdNumber',appParticipant[0].AOB_IDNumber__c);
                        applicationList[0].AOB_Liveness_Matched__c = responseMap.LivenessFRMatch;
                    }else{
                        applicationList[0].AOB_Liveness_Matched__c = false;
                    }
                    applicationList[0].AOB_Liveness_Matched__c = responseMap.LivenessFRMatch != null ?responseMap.LivenessFRMatch : false;
                    applicationList[0].AOB_Liveness_Score__c = (responseMap.LivenessFRScore != null ? responseMap.LivenessFRScore : 0);
                    appParticipant[0].UG_BCB_Stage__c = (( applicationList[0].AOB_Liveness_Matched__c == true && responseMap.DateOfExpiry != null && responseMap.LivenessFRScore >70)? 'Application Details': 'IIDENTIFII');
                    update applicationList;
                    update appParticipant;
                    
                    if(applicationList[0].AOB_Liveness_Matched__c == true){
                        insertContentDocLinks(responseMap, applicationList[0].Id);
                    }
            }
            return json.serialize(parsedStringMap);
            }
        } catch (Exception ex) {
            LOGGER.error('BCB_FlowController.invokeIdentifiiGETDocumentsCallout', ex);
            throw new BCB_CustomException(ex.getMessage());
        }
        return null;
    }

 /**
* @description method to check which preapp screens  to navigate 
* @param responseMap
* @param applicationId
*/
@TestVisible
    private static void insertContentDocLinks(BCB_Identify_BodyBean.Response responseMap, Id applicationId){
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        if(responseMap.IdentityImages.size() > 0){
            for(BCB_Identify_BodyBean.IdentityImages identityImage : responseMap.IdentityImages) {
                String fileName = documentAndKYCNameMap.containsKey(identityImage.ImageType.Description) ? documentAndKYCNameMap.get(identityImage.ImageType.Description) : identityImage.ImageType.Description;
                ContentVersion contentVersionToCreate = new ContentVersion();
                contentVersionToCreate.ContentLocation = 'S';
                contentVersionToCreate.PathOnClient = fileName +'.png';
                contentVersionToCreate.Title = fileName;
                contentVersionToCreate.Description = identityImage.ImageType.Description; 
                contentVersionToCreate.VersionData = identityImage.Image;
                contentVersionList.add(contentVersionToCreate);
            }
        }
        if(!contentVersionList.isEmpty()){
            insert contentVersionList;
        }
        List<ContentDocumentLink> documentLinkList = new List<ContentDocumentLink>();
        for(ContentVersion versionInstance : [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersionList]) {
            ContentDocumentLink documentLink = new ContentDocumentLink();
            documentLink.ContentDocumentId = versionInstance.ContentDocumentId;
            documentLink.LinkedEntityId = applicationId;
            documentLink.ShareType = 'I'; 
            documentLink.Visibility = 'AllUsers';
            documentLinkList.add(documentLink);
        }
        if(!documentLinkList.isEmpty()){
            insert documentLinkList;
        }
    }    

/**
* @description Method to get inserted identifii documents invoked from identifii lwc component 
* @param verificationRecordId
* @param status
* @param documentId
*/
    @AuraEnabled
    public static void updateVerificationStatus(String verificationRecordId, String status, String documentId){
        try {
            Verification__c verificationRecord=new Verification__c(
                Id = verificationRecordId,
                Verification_Status__c = status,
                AOB_Identifii_Document_Id__c = documentId
            );
            update verificationRecord;
        } catch (Exception ex) {
            LOGGER.error('BCB_FlowController.updateVerificationStatus', ex);
            throw new BCB_CustomException(ex.getMessage());
        }
    }    
/**
* @description Method to validate the whether the file is virus free ot not
* @param applicationParticipantId
* @param documentList
* @return String Reponse of file status check
*/
@AuraEnabled
    public static String  fileScreeningByParticipantId(String applicationParticipantId, List<ContentVersion> documentList ) {
        try{
           
            List<Application_Participant__c> appliactionParticipant =New SEL_ApplicationParticipant().selectApplicationParticpantById(applicationParticipantId);
            String returnString= CMN_fileScreening.invocableMethodParticipantId(appliactionParticipant,documentList);     
            return returnString;
        }catch (Exception ex) {
            LOGGER.error('BCB_FlowController.fileScreeningByParticipantId', ex);
            throw new BCB_CustomException(ex.getMessage());
        }}
    /**
* @description Method to validate the whether the file is virus free ot not
* @param documentList
* @return String Reponse of file status check
*/
@AuraEnabled
    public static String fileScreeningByDocumentList(List<ContentVersion> documentList) {
        try {
            return CMN_fileScreening.invocableMethodWithDocumentList(documentList);
        } catch(Exception ex) {
            LOGGER.error('BCB_FlowController.fileScreeningByDocumentList', ex);
            throw new BCB_CustomException(ex.getMessage());
        }
    }
/** 
* @description Method to test the BCB_SelfRegistration callout
* @param applicationParticipantId
* @return String Reponse of selfRegistration
*/
@AuraEnabled
public static String selfRegistration(string applicationParticipantId){
    try {
        List<Application_Participant__c> appParticipants = new SEL_ApplicationParticipant().selectApplicationParticpantById(applicationParticipantId);
        List<Application__c> applicationList = new SEL_Application().selectAppsById(appParticipants[0].Application__c);
        String response = CMN_SelfRegistration.invocableMethod(applicationList);
        Map<String, Object> parsedStringMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        Map<String, Object> customLoginQNAResponse = new  Map<String, Object>();
        if(parsedStringMap.containsKey('customLoginQNAResponse')){
            customLoginQNAResponse = (map<string,object>)parsedStringMap.get('customLoginQNAResponse');
        }
        if(customLoginQNAResponse  != null && (string)customLoginQNAResponse.get('Status') == 'SUCCESS'){
            parsedStringMap.put('Status', 'Success');
            BCB_FlowController.createVerificationRecord(applicationList[0], 'Self Registration_Questions', 'Success');
        }else{
            BCB_FlowController.createVerificationRecord(applicationList[0], 'Self Registration_Questions', 'Failed');
        }
        return json.serialize(parsedStringMap);
    } catch(Exception ex) {
        LOGGER.error('BCB_FlowController.selfRegistration', ex);
        throw new BCB_CustomException(ex.getMessage());
    }
}
/** 
* @description Method to test the CMN_CreateEnterpriseCustomer callout
* @param applicationParticipantId
* @param qnaString
* @return string Reponse of CreateEnterpriseCustomer
*/
@AuraEnabled
public static string createEnterpriseCustomer(string applicationParticipantId, string qnaString){
    try {
        List<Application_Participant__c> appParticipants = new SEL_ApplicationParticipant().selectApplicationParticpantById(applicationParticipantId);
        String response = CMN_CreateEnterpriseCustomer.invocableMethod(appParticipants, qnaString );
        return response;
    }catch(Exception ex) {
        LOGGER.error('BCB_FlowController.createEnterpriseCustomer', ex);
        throw new BCB_CustomException(ex.getMessage());
    }
} 
 /** 
* @description Method to test the CMN_CreateEnterpriseCustomer callout
* @return string returns Reponse of CreateEnterpriseCustomer
*/   
    @AuraEnabled
    public static string fetchingVerificationRecord(){
        try{
            Verification__c verificationRecord = [SELECT Id,Verification_Source__c,Verification_Status__c FROM Verification__c ORDER BY createddate DESC LIMIT 1];
            if(verificationRecord != null){
                return JSON.serialize(verificationRecord);
            }
        }catch(Exception ex){ 
            LOGGER.error('BCB_FlowController.fetchingVerificationRecord', ex);
            throw new BCB_CustomException(ex.getMessage());
        }
        return null;
    }
/** 
* @description Method to test the CMN_RelyComply callout
* @param applicationParticipantId
* @return string Reponse of CMN_RelyComply
*/
@AuraEnabled
    public static string relyComplyIndivididualScreening(string applicationParticipantId){
        try {
            List<Application_Participant__c> appParticipants = new SEL_ApplicationParticipant().selectApplicationParticpantById(applicationParticipantId);
            List<Application__c> applicationList = new SEL_Application().selectAppsById(appParticipants[0].Application__c);
            String response =CMN_RelyComply.invocableMethod(applicationList,appParticipants);

            Map<String, Object> parsedStringMap = (Map<String, Object>) JSON.deserializeUntyped(response);
            if(parsedStringMap != null  && parsedStringMap.containsKey('ErrorDescription') == false) {
                appParticipants[0].AOB_Rely_Comply_Status__c = (string)parsedStringMap.get('assessmentStatus') ; 
                appParticipants[0].Inflight__c ='{ "individualAssessmentId" : "'+(string)parsedStringMap.get('assessmentId')+'" }';
          
                update appParticipants;
                BCB_FlowController.createVerificationRecordForParticipant(appParticipants[0], 'Rely Comply', 'Success');
                
                parsedStringMap.put('assessmentStatus', appParticipants[0].AOB_Rely_Comply_Status__c);
                return JSON.serialize(parsedStringMap) ;  
            }
            return response;
        }catch (Exception ex) {
            LOGGER.error('BCB_FlowController.relyComplyIndivididualScreening', ex);
            throw new BCB_CustomException(ex.getMessage());
        }
    }
/** 
* @description Method to test the CMN_RelyComplyFetchAssessment callout
* @param applicationParticipantId
* @param screenName
* @return string string Reponse of relyComplyFetchAssessment
*/
    @AuraEnabled
    public static string relyComplyFetchAssessment(string applicationParticipantId, string screenName){
       try {
            List<Application_Participant__c> appParticipants = new SEL_ApplicationParticipant().selectApplicationParticpantById(applicationParticipantId);
            List<Application__c> applicationList = new SEL_Application().selectAppsById(appParticipants[0].Application__c);
            String response =CMN_RelyComplyFetchAssessment.invocableMethod(applicationList,appParticipants,screenName);

            Map<String, Object> parsedStringMap = (Map<String, Object>) JSON.deserializeUntyped(response);
            if(parsedStringMap != null  && parsedStringMap.containsKey('ErrorDescription') == false) {
                if(screenName == 'IDV'){
                    appParticipants[0].AOB_Rely_Comply_Status__c = (string)parsedStringMap.get('assessmentStatus') ; 
                    appParticipants[0].Inflight__c ='{ "individualAssessmentId" : "'+(string)parsedStringMap.get('assessmentId')+'" }';
                }else if(screenName == 'Uganda MVP2 Company Details'){
                    applicationList[0].AOB_Rely_Comply_Status__c = (string)parsedStringMap.get('assessmentStatus') ; 
                    applicationList[0].Inflight__c ='{ "businessAssessmentId" : "'+(string)parsedStringMap.get('assessmentId')+'" }';
                }
                
               if(!appParticipants.isEmpty()  || !applicationList.isEmpty()){
                 update appParticipants;
                 update applicationList;
               }  
               
                BCB_FlowController.createVerificationRecordForParticipant(appParticipants[0], 'Rely Comply', 'Success');
                
                parsedStringMap.put('assessmentStatus', (string)parsedStringMap.get('assessmentStatus'));
             
                return JSON.serialize(parsedStringMap) ;  
            }
            return response;
      }catch (Exception ex) {
        LOGGER.error('BCB_FlowController.relyComplyFetchAssessment', ex);
        throw new BCB_CustomException(ex.getMessage());
       }
       
    }

/** 
* @description Method to test the CMN_RelyComplyBusinessScreening callout
* @param applicationParticipantId
* @return string Reponse of relyComplyBusinessScreening
*/
    @AuraEnabled
    public static string relyComplyBusinessScreening(string applicationParticipantId){
        try {
            List<Application_Participant__c> appParticipants = new SEL_ApplicationParticipant().selectApplicationParticpantById(applicationParticipantId);
            List<Application__c> applicationList = new SEL_Application().selectAppsById(appParticipants[0].Application__c);
            String response = CMN_RelyComplyBusinessScreening.invocableMethod(applicationList,appParticipants);

            Map<String, Object> parsedStringMap = (Map<String, Object>) JSON.deserializeUntyped(response);
            if(parsedStringMap != null  && parsedStringMap.containsKey('ErrorDescription') == false) {

              
                applicationList[0].AOB_Rely_Comply_Status__c = (string)parsedStringMap.get('assessmentStatus') ; 
                applicationList[0].Inflight__c ='{ "businessAssessmentId" : "'+(string)parsedStringMap.get('assessmentId')+'" }';
                    
                update applicationList;
                BCB_FlowController.createVerificationRecord(applicationList[0], 'Rely Comply', 'Success');

                parsedStringMap.put('assessmentStatus', (string)parsedStringMap.get('assessmentStatus'));
                
                return JSON.serialize(parsedStringMap) ;  
            }
            return response;
        }catch (Exception ex) {
            LOGGER.error('BCB_FlowController.relyComplyBusinessScreening', ex);
            throw new BCB_CustomException(ex.getMessage());
        }
       
    }
/** 
* @description Method to invoke the CMN_DSX callout
* @param participantId
* @return string Reponse of CMN_DSX
**/
        @AuraEnabled
        public static string invokeDSXparticipantId(string participantId){
            try{ 
                String returnString= CMN_DSX.invocableMethodParticipant( participantId);   
            return returnString;
        }catch (Exception ex) {
            LOGGER.error('BCB_FlowController.invokeDSXparticipantId', ex);
            throw new BCB_CustomException(ex.getMessage());
        }

        }
/** 
* @description Method to invoke the CMN_DSX callout
* @param appId
* @return string Reponse of CMN_DSX
**/

        @AuraEnabled
        public static string invokeDSXapplicationId(string appId){
            List<Application_Participant__c> appParticipants = new SEL_ApplicationParticipant().selectApplicationParticpantById(appId);
            List<Application__c> applicationList = new SEL_Application().selectAppsById(appParticipants[0].Application__c); 
            try{
          
             String returnString=CMN_DSX.invocableMethodApplicationId( applicationList[0].id);
             
             return returnString;
        }catch (Exception ex) {
            LOGGER.error('BCB_FlowController.invokeDSXapplicationId', ex);
            throw new BCB_CustomException(ex.getMessage());
        }

        }
   
}