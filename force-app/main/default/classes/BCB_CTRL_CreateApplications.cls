/***************************************************************************************
@ Author            : Ruchi Agrawal
@ Date              : May 2023 
@ Name of the Class : BCB_CTRL_CreateApplications
@description        : Class handles applications around the flow
@ Last Modified By  : Ravi Myaka  
@ Last Modified On  : 23-04-2024
@ Modification description : SFP-37845

@ Last Modified By  : Alex Niyonsaba
@ Last Modified On  : Sept 16th 2025
@ Modification description : Updates made to add methods that get application's Client Type by appliction Id, and websiteUrl custom metadata type.
@ User Story : SFP-51695 
***************************************************************************************/
public without sharing class BCB_CTRL_CreateApplications {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
        .createLogger('BCB_CTRL_CreateApplications');
    private static final String inProgress = 'In Progress';
    private static final String newVal = 'New';
    private static final String existing = 'Existing';
    private static final String navigationToStrongAuth = 'NavigateToStrongAuth';
    private static final String preApplicationStep1 = 'Pre application-Step1';
    private static final String preApplicationStep2 = 'Pre-application -Step2';
    private static final String navigateToNextScreen = 'NavigateToNextScreen';
    private static final String preApplication = 'Pre-Application';
    private static final String soleProprietor = 'Sole Proprietor';
    private static final String incomeFromOwnBusiness = 'Income from Own Business';
    private static final String uploadImageOfYourNationalId = 'upload image of your national id';
    private static final String status = 'Status';
    private static final String success = 'Success';
    private static final String accepted = 'Accepted';
    private static final String confirmBox = 'Confirm Box';
    private static final String CARD_NUMBER = 'cardNumber';
    private static final String BCB_WEBSITE_CUSTOM_METADATA_TYPE_NAME = 'UG_BCB_Website_URL';
    private static final String RECORD_TYPE_NAME = 'Uganda_BCB_Account_Onboarding';
    private static final String UUID = 'uuId';
    public static Map<String, String> maritalStatusNameVsCode = new Map<String, String>{
        '001' => 'SINGLE',
        '002' => 'MARRIED',
        '003' => 'SEPARATED',
        '004' => 'DIVORCED',
        '005' => 'WIDOWED',
        '008' => 'NOT GIVEN',
        '009' => 'LIVE-IN RELATIONSHIP'
    };

    /**
     * @description method used to create application based on given input
     * @param preAppData
     * @param fileData
     * @return String
     */
    @AuraEnabled
    public static String createApplication(String preAppData, String fileData) {
        try {
            BCB_DTO_CreateApplication preAppInput = (BCB_DTO_CreateApplication) JSON.deserialize(
                preAppData,
                BCB_DTO_CreateApplication.class
            );
            String nationalIDNumber = preAppInput.nationalIDNumber;
            String productCode = preAppInput.productCode;
            List<Application_Participant__c> appParticipant = new SEL_ApplicationParticipant()
                .findParticipantByNIN(nationalIDNumber, inProgress, productCode);
            BCB_DTO_AppWrapper data = new BCB_DTO_AppWrapper();
            if (appParticipant.isEmpty()) {
                String participantId = createApplicationRecord(preAppInput);
                data.appParticipantId = participantId;
                data.appFound = newVal;
            } else {
                data.appParticipantId = appParticipant[0].Id;
                data.appFound = existing;
                data.navigationScreen = checkNavigationStatus(appParticipant[0].AOB_Stage__c);
            }
            return System.JSON.serialize(data);
        } catch (Exception ex) {
            LOGGER.error('BCB_CTRL_CreateApplications.createApplication', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description method to check which preapp screens  to navigate
     * @param appParticipantStage
     * @return String
     */
    @TestVisible
    private static String checkNavigationStatus(String appParticipantStage) {
        String navigationType = navigationToStrongAuth;
        if (
            appParticipantStage == preApplicationStep1 ||
            appParticipantStage == preApplicationStep2
        ) {
            navigationType = navigateToNextScreen;
        }
        return navigationType;
    }

    /**
     * @description	creates Lead,Application,Application Participant  with the data that has been captured in preapplication screen
     * @param preAppInput
     * @return String
     */
    @TestVisible
    private static String createApplicationRecord(BCB_DTO_CreateApplication preAppInput) {
        try {
            Lead lobj = createLeadRecord(preAppInput);
            Id applicationRecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName()
                .get(RECORD_TYPE_NAME)
                .getRecordTypeId();
            Application__c application = new Application__c();
            String prodCode = preAppInput.productCode;
            List<Product2> prod = new SEL_Product2().selectMemoProduct(prodCode);
            Schema.DescribeFieldResult applicationFieldResult = Application__c.Country_of_Tax__c.getDescribe();
            List<Schema.PicklistEntry> countryOfTaxPicklistValues = applicationFieldResult.getPicklistValues();
            Map<String, String> countryOfTaxLabelValueMap = new Map<String, String>();
            for (Schema.PicklistEntry picklistEntry : countryOfTaxPicklistValues) {
                countryOfTaxLabelValueMap.put(picklistEntry.getLabel(), picklistEntry.getValue());
            }
            application.RecordTypeId = applicationRecordTypeId;
            application.Status__c = inProgress;
            application.AOB_Lead__c = lobj.Id;
            application.AOB_Product__c = prod[0].Id;
            application.AOB_UG_BCB_Stage__c = preApplication;
            application.AOB_BCCEntityType__c = soleProprietor;
            application.AOB_Selected_Currency__c = preAppInput.currencyTypeUG;
            application.WI_ClientType__c = preAppInput.businessType;
            application.CurrencyIsoCode = preAppInput.currencyTypeUG;
            application.Intent_to_Future_Deposits_Fund__c = incomeFromOwnBusiness;
            application.AOB_BusinessLegalName__c = preAppInput.businessLegalName;
            application.AOB_RegistrationNumber__c = preAppInput.businesRegNumber;
            application.Tax_Identification_Number__c = preAppInput.taxRegistrationNumber;
            application.AOB_Document_Number__c = preAppInput.tradingLicenseNumber;
            application.CNGCU_CSEmail__c = preAppInput.businessEmail;
            application.AOB_Phone__c = preAppInput.businessContactNumber;
            String countryOfTax = preAppInput.countryOfTaxResidency;
            application.Country_of_Tax__c = countryOfTaxLabelValueMap.get(
                countryOfTax.toUpperCase()
            );
            Map<String, Object> inflightData = new Map<String, Object>();
            if (String.isNotBlank(application.Inflight__c)) {
                inflightData = (Map<String, Object>) JSON.deserializeUntyped(
                    application.Inflight__c
                );
            }
            inflightData.put(CARD_NUMBER, preAppInput.cardNumber);
            application.Inflight__c = JSON.serialize(inflightData);

            if (Schema.SObjectType.Application__c.isCreateable()) {
                Database.insert(application);
            }

            Application_Participant__c appParticipant = new Application_Participant__c();
            appParticipant.AOB_Title__c = preAppInput.title;
            appParticipant.AOB_Gender__c = preAppInput.gender;
            appParticipant.CNGCU_First_Name__c = preAppInput.firstName;
            appParticipant.CNGCU_Last_Name__c = preAppInput.lastName;
            appParticipant.AOB_Preferred_Name__c = preAppInput.otherName;
            appParticipant.AOB_IDNumber__c = preAppInput.nationalIDNumber;
            appParticipant.AOB_DateofBirth__c = Date.valueOf(preAppInput.dateOfBirth);
            appParticipant.AOB_National_ID_expiry_date__c = Date.valueOf(preAppInput.ninExpiryDate);
            appParticipant.CNGCU_Phone__c = preAppInput.cellPhoneNumber;
            appParticipant.CNGCU_Email__c = preAppInput.emailAddress;
            appParticipant.AOB_Occupation__c = preAppInput.sourceOfFunds;
            appParticipant.Application__c = application.Id;
            appParticipant.AOB_Stage__c = preApplicationStep2;
            appParticipant.CurrencyIsoCode = preAppInput.currencyTypeUG;
            appParticipant.AOB_City__c = '';
            appParticipant.AOB_Source_of_Funds__c = incomeFromOwnBusiness;
            if (preAppInput.otherName == null) {
                appParticipant.AOB_FullName__c = preAppInput.firstName + ' ' + preAppInput.lastName;
            } else {
                appParticipant.AOB_FullName__c =
                    preAppInput.firstName +
                    ' ' +
                    preAppInput.otherName +
                    ' ' +
                    preAppInput.lastName;
            }

            appParticipant.AOB_MaritalStatus__c = maritalStatusNameVsCode.get(
                preAppInput.maritalStatus
            );
            appParticipant.AOB_Card_Number__c = preAppInput.cardNumber;

            if (Schema.SObjectType.Application_Participant__c.isCreateable()) {
                Database.insert(appParticipant);
            }

            Id individualRecordTypeId = Schema.SObjectType.Individual.getRecordTypeInfosByDeveloperName()
                .get(RECORD_TYPE_NAME)
                .getRecordTypeId();
            List<Individual> individualRecord = new SEL_Individual()
                .findParticipantById(appParticipant.Id);
            Individual individ = new Individual();
            individ.AOB_Declaration_of_Literacy__c = Boolean.valueOf(preAppInput.literacy);
            individ.FirstName = appParticipant.CNGCU_First_Name__c;
            individ.LastName = appParticipant.CNGCU_Last_Name__c;
            individ.RecordTypeId = individualRecordTypeId;
            individ.AOB_Documents_Validation__c = Boolean.valueOf(preAppInput.validationOfDocument);
            if (preAppInput.sharePersonalInfo != null) {
                individ.AOB_Personal_Information_Consent__c = preAppInput.sharePersonalInfo;
            }
            if (preAppInput.communicateOthers != null) {
                individ.AOB_Services_Special_Offers_Consent__c = preAppInput.communicateOthers;
            }
            if (preAppInput.research != null) {
                individ.AOB_Research_Consent__c = preAppInput.research;
            }
            if (preAppInput.marketYourProduct != null) {
                individ.AOB_Market_Your_Product_Consent__c = preAppInput.marketYourProduct;
            }
            individ.Application_Participant__c = appParticipant.Id;
            if (!individualRecord.isEmpty()) {
                individ.Id = individualRecord[0].Id;
            }
            performGuestDML(null, individ);

            updateListOfLeadRecords(individ.Id);
            return appParticipant.Id;
        } catch (Exception ex) {
            LOGGER.error('BCB_CTRL_CreateApplications.createApplicationRecord', ex);
        }
        return null;
    }

    /**
     * @description method to creates Lead with the data that has been captured in preapplication screen
     * @param preAppInput
     * @return Lead
     */
    @TestVisible
    private static Lead createLeadRecord(BCB_DTO_CreateApplication preAppInput) {
        Id queueId = null;
        if (Schema.sObjectType.QueueSObject.isAccessible()) {
            queueId = [
                SELECT Queue.Id
                FROM queuesobject
                WHERE queue.name = 'UG_BCB_Illiterate_Queue'
                LIMIT 1
            ]
            .Queue.Id;
        }

        Id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
            .get(RECORD_TYPE_NAME)
            .getRecordTypeId();
        Lead lobj = new Lead();
        lobj.FirstName = preAppInput.firstName;
        lobj.LastName = preAppInput.lastName;
        lobj.MobilePhone = preAppInput.cellPhoneNumber;
        lobj.Email = preAppInput.emailAddress;
        lobj.CurrencyIsoCode = preAppInput.currencyTypeUG;
        if (
            Boolean.valueOf((String) preAppInput.literacy) == false ||
            Boolean.valueOf((String) preAppInput.validationOfDocument) == false
        ) {
            lobj.AOB_Status__c = newVal;
            lobj.OwnerId = queueId;
        } else {
            lobj.AOB_Status__c = inProgress;
        }
        lobj.RecordTypeId = leadRecordTypeId;

        if (Schema.sObjectType.Lead.isCreateable()) {
            insert lobj;
            return lobj;
        } else {
            return null;
        }
    }

    /**
     * @description update the Lead individualId
     * @param individId
     */
    @TestVisible
    private static void updateListOfLeadRecords(Id individId) {
        List<Lead> lstOfLeadRecords = [
            SELECT Id, IndividualId
            FROM Lead
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        lstOfLeadRecords[0].IndividualId = individId;
        performGuestDML(lstOfLeadRecords, null);
    }

    /**
     * @description	method to check the Retail Customer existing or not before proceeding
     * @param applicationParticipantId
     */
    @AuraEnabled
    public static String checkRetailCustomerExist(String preAppData) {
        try {
            BCB_DTO_CreateApplication preAppInput = (BCB_DTO_CreateApplication) JSON.deserialize(
                preAppData,
                BCB_DTO_CreateApplication.class
            );
            Map<String, String> preAppInputMap = new Map<String, String>{
                'firstName' => preAppInput.firstName,
                'lastName' => preAppInput.lastName,
                'dateOfBirth' => preAppInput.dateOfBirth
            };
            String nationalIDNumber = preAppInput.nationalIDNumber;
            String productCode = preAppInput.productCode;
            List<Application_Participant__c> appParticipant = new SEL_ApplicationParticipant()
                .findParticipantByNIN(nationalIDNumber, inProgress, productCode);
            string fetchRetailCustomerResponse = CMN_CustomerList.invocableMethod(preAppInputMap);
            BCB_DTO_AppWrapper data = new BCB_DTO_AppWrapper();
            if (fetchRetailCustomerResponse != null && fetchRetailCustomerResponse != '') {
                Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(
                    fetchRetailCustomerResponse
                );
                if (
                    responseObject.containsKey(status.toLowerCase()) == true &&
                    responseObject.containsKey(UUID)
                ) {
                    data.customerFoundInFinacle = existing;
                } else if (responseObject.containsKey('ErrorDescription') == true) {
                    LOGGER.error(
                        'BCB_CTRL_CreateApplications.checkRetailCustomerExist: Failure',
                        fetchRetailCustomerResponse
                    );
                } else if (
                    responseObject.containsKey(status.toLowerCase()) == true &&
                    responseObject.containsKey(UUID) == false
                ) {
                    data.customerFoundInFinacle = newVal;
                    if (appParticipant.isEmpty()) {
                        String participantId = createApplicationRecord(preAppInput);
                        data.appParticipantId = participantId;
                        data.appFound = newVal;
                    } else {
                        data.appParticipantId = appParticipant[0].Id;
                        data.appFound = existing;
                        data.navigationScreen = checkNavigationStatus(
                            appParticipant[0].AOB_Stage__c
                        );
                    }
                    List<Application_Participant__c> appliactionParticipants = new SEL_ApplicationParticipant()
                        .selectApplicationParticpantById(data.appParticipantId);
                    BCB_FlowController.createVerificationRecordForParticipant(
                        appliactionParticipants[0],
                        'Customer Check',
                        'Success'
                    );
                } else {
                    LOGGER.error(
                        'BCB_CTRL_CreateApplications.checkRetailCustomerExist: Failure',
                        fetchRetailCustomerResponse
                    );
                }
            }
            return System.JSON.serialize(data);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description	creates AppParticipant related Documents with the data that has been captured in preapplication screen
     * @param participantId
     * @param filename
     * @param filedata
     * @param currencyType
     */
    @AuraEnabled
    public static void createApplicationDocument(
        String participantId,
        String filename,
        string filedata,
        string currencyType
    ) {
        try {
            Application_Document__c document = new Application_Document__c();
            document.CurrencyIsoCode = currencyType;
            document.Document_Type__c = uploadImageOfYourNationalId;
            document.Application_Participant__c = participantId;
            document.External_Id__c = filename;

            if (Schema.SObjectType.Application_Document__c.isCreateable()) {
                Database.insert(document);
            }

            ContentVersion cv = new ContentVersion();
            cv.VersionData = EncodingUtil.base64Decode(filedata);
            cv.Title = filename;
            cv.PathOnClient = filename;

            if (Schema.SObjectType.ContentVersion.isCreateable()) {
                Database.insert(cv);
            }

            ContentDocumentLink cdl = new ContentDocumentLink();
            ContentVersion contentVersion = new SEL_ContentVersion()
                .selectContentVersionById(cv.Id);
            cdl.ContentDocumentId = contentVersion.ContentDocumentId;
            cdl.LinkedEntityId = document.Id;
            cdl.ShareType = 'V';

            if (Schema.SObjectType.ContentDocumentLink.isCreateable()) {
                Database.insert(cdl);
            }
        } catch (Exception ex) {
            LOGGER.error('BCB_CTRL_CreateApplications.createApplicationDocument', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description	creates AppParticipant with the data that has been captured in preapplication screen
     * @param participantId
     * @param formData
     */
    @AuraEnabled
    public static void updatePreApplicationData(String participantId, String formData) {
        try {
            BCB_DTO_CreateApplication preAppInput = (BCB_DTO_CreateApplication) JSON.deserialize(
                formData,
                BCB_DTO_CreateApplication.class
            );
            List<Application_Participant__c> appParticipant = new SEL_ApplicationParticipant()
                .selectApplicationParticpantById(participantId);
            appParticipant[0].AOB_Title__c = preAppInput.title;
            appParticipant[0].AOB_Gender__c = preAppInput.gender;
            appParticipant[0].CNGCU_First_Name__c = preAppInput.firstName;
            appParticipant[0].CNGCU_Last_Name__c = preAppInput.lastName;
            appParticipant[0].AOB_Preferred_Name__c = preAppInput.otherName;
            appParticipant[0].AOB_IDNumber__c = preAppInput.nationalIDNumber;
            appParticipant[0].AOB_DateofBirth__c = Date.valueOf(preAppInput.dateOfBirth);
            appParticipant[0].AOB_National_ID_expiry_date__c = Date.valueOf(
                preAppInput.ninExpiryDate
            );
            appParticipant[0].CNGCU_Phone__c = preAppInput.cellPhoneNumber;
            appParticipant[0].CNGCU_Email__c = preAppInput.emailAddress;
            appParticipant[0].AOB_Occupation__c = preAppInput.sourceOfFunds;
            appParticipant[0].AOB_FullName__c = preAppInput.firstName + ' ' + preAppInput.lastName;
            appParticipant[0].AOB_MaritalStatus__c = maritalStatusNameVsCode.get(
                preAppInput.maritalStatus
            );
            if (
                Schema.SObjectType.Application_Participant__c.isCreateable() ||
                Schema.SObjectType.Application_Participant__c.isUpdateable()
            ) {
                Database.upsert(appParticipant);
            }

            List<Application__c> application = new SEL_Application()
                .selectAppsById(appParticipant[0].Application__c);
            application[0].AOB_BusinessLegalName__c = preAppInput.businessLegalName;
            application[0].AOB_RegistrationNumber__c = preAppInput.businesRegNumber;
            application[0].Tax_Identification_Number__c = preAppInput.taxRegistrationNumber;
            application[0].AOB_Document_Number__c = preAppInput.tradingLicenseNumber;
            application[0].CNGCU_CSEmail__c = preAppInput.businessEmail;
            application[0].AOB_Phone__c = preAppInput.businessContactNumber;
            Map<String, Object> inflightData = new Map<String, Object>();
            if (String.isNotBlank(application[0].Inflight__c)) {
                inflightData = (Map<String, Object>) JSON.deserializeUntyped(
                    application[0].Inflight__c
                );
            }
            inflightData.put(CARD_NUMBER, preAppInput.cardNumber);
            application[0].Inflight__c = JSON.serialize(inflightData);
            if (Schema.SObjectType.Application__c.isUpdateable()) {
                Database.update(application);
            }
        } catch (Exception ex) {
            LOGGER.error('BCB_CTRL_CreateApplications.updatePreApplicationData', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description Method to create verification record invoked from all api callouts classes
     * @param applicationParticipantRecord
     * @param source
     * @param status
     * @return Id of the created verification record
     */
    public static Id createVerificationRecord(
        Application_Participant__c applicationParticipantRecord,
        String source,
        String status
    ) {
        try {
            Verification__c verifyInstance = new Verification__c(
                Application_Participant__c = applicationParticipantRecord.Id,
                Verification_Source__c = source,
                Verification_Status__c = status
            );

            if (Schema.sObjectType.Verification__c.isCreateable()) {
                insert verifyInstance;
                return verifyInstance.Id;
            } else {
                LOGGER.error('Insufficient permissions to update Application_Participant__c');
                return null;
            }
        } catch (Exception ex) {
            LOGGER.error('BCB_CTRL_CreateApplications.createVerificationRecord', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description	creates Application_Line_Item__c related Documents with the data that has been captured in preapplication screen
     * @param participantId
     * @param formData
     */
    @AuraEnabled
    public static void createApplicationLineItem(string participantId, String formData) {
        try {
            List<Application_Participant__c> appParticipant = new SEL_ApplicationParticipant()
                .selectApplicationParticpantById(participantId);
            List<Application__c> application = new SEL_Application()
                .selectAppsById(appParticipant[0].Application__c);
            List<Application_Line_Item__c> appLineitem = new SEL_ApplicationLineItem()
                .selectApplicationLineItemByApplicationId(application[0].id);
            List<QueueSobject> queuelst = (new SEL_Queue()
                .selectQueueByQueueNames(new List<string>{ 'UG_BCB_Additional_Product_Queue' }));
            Id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
                .get(RECORD_TYPE_NAME)
                .getRecordTypeId();
            Lead lobj = new Lead();
            lobj.FirstName = appParticipant[0].CNGCU_First_Name__c;
            lobj.LastName = appParticipant[0].CNGCU_Last_Name__c;
            lobj.MobilePhone = appParticipant[0].CNGCU_Phone__c;
            lobj.Email = appParticipant[0].CNGCU_Email__c;
            lobj.RecordTypeId = leadRecordTypeId;
            lobj.OwnerId = queuelst[0].QueueId;
            lobj.CurrencyIsoCode = application[0].AOB_Selected_Currency__c;
            Id individualRecordTypeId = Schema.SObjectType.Individual.getRecordTypeInfosByDeveloperName()
                .get(RECORD_TYPE_NAME)
                .getRecordTypeId();
            Individual individ = new Individual();
            individ.FirstName = appParticipant[0].CNGCU_First_Name__c;
            individ.LastName = appParticipant[0].CNGCU_Last_Name__c;
            individ.RecordTypeId = individualRecordTypeId;
            Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(formData);
            List<String> productNames = new List<String>();
            List<String> productNamesDelete = new List<String>();
            for (String key : data.keySet()) {
                Object value = data.get(key);
                if (key != confirmBox && value instanceof Boolean && (Boolean) value) {
                    productNames.add(key);
                }
                if (key != confirmBox && value == false) {
                    productNamesDelete.add(key);
                }
            }
            String selectedProductsString = String.join(productNames, ',');
            list<Application_Line_Item__c> appLineitemc = new List<Application_Line_Item__c>();
            for (string productName : productNames) {
                Application_Line_Item__c appitem = new Application_Line_Item__c();
                appitem.Name = productName;
                appitem.AOB_Status__c = accepted;
                appitem.Application__c = appParticipant[0].Application__c;
                appitem.CurrencyIsoCode = application[0].AOB_Selected_Currency__c;
                appLineitemc.add(appitem);
            }
            list<Application_Line_Item__c> appLineitemDelete = new List<Application_Line_Item__c>();
            Set<String> productNamesSet = new Set<String>(productNamesDelete);
            for (Application_Line_Item__c productNameEx : appLineitem) {
                if (productNamesSet.contains(productNameEx.Name)) {
                    appLineitemDelete.add(productNameEx);
                }
            }
            if (Schema.sObjectType.Individual.isCreateable()) {
                insert individ;
            }
            lobj.IndividualId = individ.id;
            lobj.UTM_Campaign__c = selectedProductsString;
            if (Schema.SObjectType.Application_Line_Item__c.isDeletable()) {
                Database.delete(appLineitemDelete);
            }
            if (!appLineitemc.isEmpty()) {
                insert lobj;
            }
        } catch (Exception ex) {
            LOGGER.error(
                ex.getMessage(),
                new List<String>{
                    'BCB_CTRL_CreateApplications.createApplicationLineItem',
                    ex.getMessage()
                },
                ex
            );
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description gets a list of files linked to participant
     * @param participantId
     * @param isParticipant
     * @return String
     */
    @AuraEnabled
    public static String releatedFilesApplication(String participantId, Boolean isParticipant) {
        try {
            List<AOB_BOTS_DTO_DocumnetData> documentlist = new List<AOB_BOTS_DTO_DocumnetData>();
            List<Application_Document__c> appDocLst;
            if (isParticipant) {
                appDocLst = new SEL_ApplicationDocument()
                    .selectAppsByIdApplicationParcipant(participantId);
            } else {
                appDocLst = new SEL_ApplicationDocument().selectAppsByIdApplication(participantId);
            }
            for (Application_Document__c appDoc : appDocLst) {
                AOB_BOTS_DTO_DocumnetData dd = new AOB_BOTS_DTO_DocumnetData();
                dd.docType = appDoc.Document_Type__c;
                dd.title = appDoc.External_Id__c;
                dd.id = appDoc.Id;
                documentlist.add(dd);
            }
            return Json.serialize(documentlist);
        } catch (Exception ex) {
            LOGGER.error(
                ex.getMessage(),
                new List<String>{
                    'BCB_CTRL_CreateApplications.releatedFilesApplication',
                    ex.getMessage()
                },
                ex
            );
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description to check whether director cif exists or not.
     * @param applicationParticipantId
     * @return String
     */
    @AuraEnabled
    public static string fetchApplicationParticipant(string applicationParticipantId) {
        try {
            List<Application_Participant__c> appParticipant = new SEL_ApplicationParticipant()
                .selectApplicationParticpantById(applicationParticipantId);
            map<string, string> responseMap = new Map<string, string>();
            if (appParticipant == null || appParticipant.isEmpty()) {
                responseMap.put(status, success);
                return JSON.serialize(responseMap);
            }

            Application_Participant__c participant = appParticipant[0];

            String statusValue = String.isBlank(participant.AOB_CIFID__c) ? success : 'Exist';
            responseMap.put(status, statusValue);

            return json.serialize(responseMap);
        } catch (Exception ex) {
            LOGGER.error(
                ex.getMessage(),
                new List<String>{
                    'BCB_CTRL_CreateApplications.fetchApplicationParticipant',
                    ex.getMessage()
                },
                ex
            );
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description to check whether corporate cif exists or not.
     * @param applicationParticipantId
     */
    @AuraEnabled
    public static void fetchApplicationCifId(string applicationParticipantId) {
        try {
            List<Application_Participant__c> appParticipant = new SEL_ApplicationParticipant()
                .selectApplicationParticpantById(applicationParticipantId);
            if (appParticipant[0].AOB_CIFID__c != null) {
                List<Application__c> applicationList = new SEL_Application()
                    .selectAppsById(appParticipant[0].Application__c);
                string corporateCustomerlist = CMN_GetCorporateCustomerList.invocableMethod(
                    applicationList,
                    appParticipant[0]
                );
                checkCorporateCustomerList(corporateCustomerlist, applicationList);
            }
        } catch (Exception ex) {
            LOGGER.error(
                ex.getMessage(),
                new List<String>{
                    'BCB_CTRL_CreateApplications.fetchApplicationCifId',
                    ex.getMessage()
                },
                ex
            );
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description Method to check the corporateCustomerlist and call createVerificationRecord
     * @param corporateCustomerlist
     * @param applicationList
     */
    @TestVisible
    public static void checkCorporateCustomerList(
        String corporateCustomerlist,
        List<Application__c> applicationList
    ) {
        if (corporateCustomerlist != null && corporateCustomerlist != '') {
            Map<String, Object> parsedStringMap = (Map<String, Object>) JSON.deserializeUntyped(
                corporateCustomerlist
            );
            if (
                parsedStringMap != null &&
                parsedStringMap.containsKey(status.toLowerCase()) == true &&
                parsedStringMap.containsKey(UUID)
            ) {
                applicationList[0].AOB_Customer_Id__c = (String) parsedStringMap.get(UUID);
                applicationList[0].AOB_UG_BCB_Stage__c = 'CIF';
                BCB_FlowController.createVerificationRecord(applicationList[0], 'CIF', 'Success');
            } else if (parsedStringMap.containsKey('ErrorDescription') == true) {
                BCB_FlowController.createVerificationRecord(
                    applicationList[0],
                    'Customer Check',
                    'Failed'
                );
                BCB_FlowController.assignLeadToQueue(
                    applicationList[0].AOB_Lead__c,
                    'UG_BCB_Incomplete_Customer_Verification'
                );
            } else if (
                parsedStringMap.containsKey(status.toLowerCase()) == true &&
                parsedStringMap.containsKey(UUID) == false
            ) {
                applicationList[0].AOB_Customer_Id__c = '';
                applicationList[0].AOB_UG_BCB_Stage__c = 'CIF';
                BCB_FlowController.assignLeadToQueue(
                    applicationList[0].AOB_Lead__c,
                    'UG_BCB_Incomplete_Customer_Verification'
                );
            } else {
                BCB_FlowController.createVerificationRecord(
                    applicationList[0],
                    'Customer Check',
                    'Failed'
                );
                BCB_FlowController.assignLeadToQueue(
                    applicationList[0].AOB_Lead__c,
                    'UG_BCB_Incomplete_Customer_Verification'
                );
            }
            if (!applicationList.isEmpty() && Schema.SObjectType.Application__c.isUpdateable()) {
                Database.update(applicationList);
            }
        }
    }

    /**
     * @description to check whether corporate cif exists or not.
     * @param applicationParticipantId
     * @return String
     */
    @AuraEnabled
    public static string checkAppliationCorporateId(string applicationParticipantId) {
        try {
            List<Application_Participant__c> appParticipant = new SEL_ApplicationParticipant()
                .selectApplicationParticpantById(applicationParticipantId);
            List<Application__c> applicationList = new SEL_Application()
                .selectAppsById(appParticipant[0].Application__c);
            map<string, string> responseMap = new Map<string, string>();
            if (applicationList[0].AOB_Customer_Id__c == null) {
                responseMap.put(status, success);
            } else if (applicationList[0].AOB_Customer_Id__c != '') {
                responseMap.put(status, 'Exist');
            }
            return json.serialize(responseMap);
        } catch (Exception ex) {
            LOGGER.error(
                ex.getMessage(),
                new List<String>{
                    'BCB_CTRL_CreateApplications.releatedFilesApplication',
                    ex.getMessage()
                },
                ex
            );
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description This method is used as get application id
     * @param participantId
     * @return String
     */
    @AuraEnabled
    public static String getapplicationId(String participantId) {
        try {
            return new SEL_ApplicationParticipant()
                .selectApplicationParticipant(participantId)
                .Application__c;
        } catch (Exception ex) {
            LOGGER.error('BCB_CTRL_CreateApplications.releatedFilesApplication', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description This method is used to get application client type. It is only used for Pamoja product applications.
     * @param appId
     * @return String
     */
    @AuraEnabled
    public static String getapplicationClientType(String appId) {
        try {
            String result = '';
            Application__c app = new SEL_Application().selectAppById(appId);
            String clientType = app.WI_ClientType__c;
            if (String.isNotEmpty(clientType)) {
                result = clientType;
            }
            return result;
        } catch (Exception ex) {
            LOGGER.error('BCB_CTRL_CreateApplications.getapplicationClientType', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description This method is used to get get BCB Website Url. It is used to navigate the user back to the website.
     * @return String
     */
    @AuraEnabled(cacheable=true)
    public static String getBCBWebsiteUrl() {
        try {
            return [
                SELECT Value__c
                FROM BCB_Static_Value__mdt
                WHERE DeveloperName = :BCB_WEBSITE_CUSTOM_METADATA_TYPE_NAME
                WITH USER_MODE
            ]
            .Value__c;
        } catch (Exception ex) {
            LOGGER.error('BCB_CTRL_CreateApplications.getBCBWebsiteUrl', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description This method is used to perform DML(Update and Upsert for Standard Objects)
     *  that Guest Users restricted from doing.
     */
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public static void performGuestDML(List<SObject> recordsToUpdate, SObject recordToUpsert) {
        if (recordsToUpdate != null && !recordsToUpdate.isEmpty()) {
            update recordsToUpdate;
        }
        if (recordToUpsert != null) {
            upsert recordToUpsert;
        }
    }

    /**
     * @description class to form App Wrapper for create application response
     */
    public class BCB_DTO_AppWrapper {
        String appParticipantId;
        String appFound;
        String navigationScreen;
        String customerFoundInFinacle;
    }

    /**
     * @description class to form File Wrapper for create application input
     */
    public class BCB_DTO_FileDataWrapper {
        /**
         * @description documentType
         */
        public String documentType;
        /**
         * @description filename
         */
        public String filename;
        /**
         * @description versionData
         */
        public String versionData;
    }

    /**
     * @description class to form application wrapper from  screen input to create application
     */
    public class BCB_DTO_CreateApplication {
        /*** @description nationalIDNumber*/
        String nationalIDNumber;

        /*** @description productCode*/
        String productCode;

        /*** @description firstName*/
        String firstName;

        /*** @description lastName*/
        String lastName;

        /*** @description cellPhoneNumber*/
        String cellPhoneNumber;

        /*** @description emailAddress*/
        String emailAddress;

        /*** @description currencyTypeUG*/
        String currencyTypeUG;

        /*** @description businessType*/
        String businessType;

        /*** @description title*/
        String title;

        /*** @description gender*/
        String gender;

        /*** @description otherName*/
        String otherName;

        /*** @description dateOfBirth*/
        String dateOfBirth;

        /*** @description ninExpiryDate*/
        String ninExpiryDate;

        /*** @description sourceOfFunds*/
        String sourceOfFunds;

        /*** @description businessLegalName*/
        String businessLegalName;

        /*** @description businesRegNumber*/
        String businesRegNumber;

        /*** @description taxRegistrationNumber*/
        String taxRegistrationNumber;

        /*** @description tradingLicenseNumber*/
        String tradingLicenseNumber;

        /*** @description businessEmail*/
        String businessEmail;

        /*** @description businessContactNumber*/
        String businessContactNumber;

        /*** @description maritalStatus*/
        String maritalStatus;

        /*** @description literacy*/
        String literacy;

        /*** @description cardNumber*/
        String cardNumber;

        /*** @description validationOfDocument*/
        String validationOfDocument;

        /*** @description sharePersonalInfo*/
        Boolean sharePersonalInfo;

        /*** @description communicateOthers*/
        Boolean communicateOthers;

        /*** @description research*/
        Boolean research;

        /*** @description marketYourProduct*/
        Boolean marketYourProduct;

        /*** @description countryOfTax/countryOfTaxResidency*/
        String countryOfTaxResidency;
    }

    /**
     * @description class to form application wrapper from  screen input to create application
     */
    public class AOB_BOTS_DTO_DocumnetData {
        public string title;
        public string docType;
        public string id;
    }
}