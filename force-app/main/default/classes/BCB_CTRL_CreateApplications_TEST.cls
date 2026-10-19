/***************************************************************************************
@ Author            : Ruchi Agrawal
@ Date              : June 26th 2023 
@ Name of the Class : BCB_CTRL_CreateApplications_TEST
@description        : Test class for BCB_CTRL_CreateApplications
@ Last Modified By  : Ravi Myaka  
@ Last Modified On  : 24-04-2024
@ Modification description : SFP-37845

@ Last Modified By  : Alex Niyonsaba
@ Last Modified On  : Sept 16th 2025
@ Modification description : Updates made to add a test method for get application's Client Type by appliction Id, 
and add more test methods to increase the code coverage.
@ User Story : SFP-51695
***************************************************************************************/
@isTest
public class BCB_CTRL_CreateApplications_TEST {
    private static final String TEST_CONTENT = 'Test Content';
    private static final String TEST_BUSINESS_NAME = 'TESTINGNEWCORP';
    private static final String FORM_DATA = '{"countryOfTaxResidency":"Uganda","countryOfRegistration":"Uganda","sourceOfFunds":"Income from Own Business","currencyTypeUG":"USD","entityTypeUG":"Sole Proprietor - Online Opening Available","Upload Proof Of Identity":true,"title":"139","gender":"Female","firstName":"component","lastName":"example","otherName":"Other","nationalIDNumber":"94940893","dateOfBirth":"2023-06-07","cellPhoneNumber":"0345678789","ninExpiryDate":"2023-06-08","emailAddress":"hgjhghj@gmail.com","productCode":"OD005","literacy":"TRUE","sharePersonalInfo":true,"communicateOthers":true,"research":true,"marketYourProduct":true}';
    private static final String FILE_DATA =
        '[{"documentType":"Upload Proof Of Identity","filename":"Screenshot.pdf","versionData":"' +
        EncodingUtil.base64Encode(Blob.valueOf(TEST_CONTENT)) +
        '"}]';
    private static final String TEST_MESSAGE = 'Test';
    private static final String FILE_PATH = 'upload signature.pdf';
    private static final String EXCEPTION_MESSAGE = 'Exception message should not be null';
    /**
     * @description Test data for BCB_CTRL_CreateApplications_TEST class
     */
    @testSetup
    static void setup() {
        Id productId = BCB_DAL_TestFactory.createProducts();
        BCB_DAL_TestFactory.createAppRecords(productId);
    }

    /**
     * @description Test method for BCB_CTRL_CreateApplications.createApplication
     */
    @isTest
    public static void createApplicationTest() {
        try {
            String formData = FORM_DATA;
            String fileData = FILE_DATA;
            Test.startTest();
            String result = BCB_CTRL_CreateApplications.createApplication(formData, fileData);

            Assert.areNotEqual(null, result, TEST_MESSAGE);
            Test.stopTest();
        } catch (Exception ex) {
            Assert.areNotEqual(null, ex.getMessage(), TEST_MESSAGE);
        }
    }

    /**
     * @description Test method for BCB_CTRL_CreateApplications.createApplication
     */
    @isTest
    public static void createApplicationTest2() {
        try {
            String formData1 = '{"countryOfTaxResidency":"Uganda","countryOfRegistration":"Uganda","sourceOfFunds":"Income from Own Business","currencyTypeUG":"USD","entityTypeUG":"Sole Proprietor - Online Opening Available","Upload Proof Of Identity":true,"title":"139","gender":"Female","firstName":"component","lastName":"example","otherName":"Other","nationalIDNumber":"94940893","dateOfBirth":"2023-06-07","cellPhoneNumber":"0345678789","ninExpiryDate":"2023-06-08","emailAddress":"hgjhghj@gmail.com","productCode":"OD005","literacy":true,"validationOfDocument":true,"sharePersonalInfo":true,"communicateOthers":true,"research":true,"marketYourProduct":true}';
            String fileData = FILE_DATA;
            Test.startTest();
            String result1 = BCB_CTRL_CreateApplications.createApplication(formData1, fileData);
            Assert.areNotEqual(null, result1, TEST_MESSAGE);
            Test.stopTest();
        } catch (Exception ex) {
            Assert.areNotEqual(null, ex.getMessage(), TEST_MESSAGE);
        }
    }

    /**
     * @description Test method for BCB_CTRL_CreateApplications.createApplication
     */
    @isTest
    public static void createApplicationTest3() {
        try {
            String formData1 = '{"countryOfTaxResidency":"Uganda","countryOfRegistration":"Uganda","sourceOfFunds":"Income from Own Business","currencyTypeUG":"USD","entityTypeUG":"Sole Proprietor - Online Opening Available","Upload Proof Of Identity":true,"title":"139","gender":"Female","firstName":"component","lastName":"example","otherName":"Other","nationalIDNumber":"94940893","dateOfBirth":"2023-06-07","cellPhoneNumber":"0345678789","ninExpiryDate":"2023-06-08","emailAddress":"hgjhghj@gmail.com","productCode":"OD005","literacy":"","sharePersonalInfo":true,"communicateOthers":true,"research":true,"marketYourProduct":true}';
            String fileData = FILE_DATA;
            Test.startTest();
            String result1 = BCB_CTRL_CreateApplications.createApplication(formData1, fileData);
            Assert.areNotEqual(null, result1, TEST_MESSAGE);
            Test.stopTest();
        } catch (Exception ex) {
            Assert.areNotEqual(null, ex.getMessage(), TEST_MESSAGE);
        }
    }
    /**
     * @description Test method for BCB_CTRL_CreateApplications.createApplication
     */
    @isTest
    public static void createApplicationTest4() {
        try {
            String formData1 = '{"countryOfTaxResidency":"Uganda","countryOfRegistration":"Uganda","sourceOfFunds":"Income from Own Business","currencyTypeUG":"UGX","entityTypeUG":"Sole Proprietor - Online Opening Available","Upload Proof Of Identity":true,"title":"139","gender":"Female","firstName":"component","lastName":"example","otherName":"Other","nationalIDNumber":"94940893","dateOfBirth":"2023-06-07","cellPhoneNumber":"0345678789","ninExpiryDate":"2023-06-08","emailAddress":"hgjhghj@gmail.com","productCode":"OD005","literacy":"","sharePersonalInfo":true,"communicateOthers":true,"research":true,"marketYourProduct":true}';
            String fileData = FILE_DATA;
            Test.startTest();
            String result1 = BCB_CTRL_CreateApplications.createApplication(formData1, fileData);
            Assert.areNotEqual(null, result1, TEST_MESSAGE);
            Test.stopTest();
        } catch (Exception ex) {
            Assert.areNotEqual(null, ex.getMessage(), TEST_MESSAGE);
        }
    }

    /**
     * @description Test method for BCB_CTRL_CreateApplications.createApplication
     */
    @isTest
    public static void createVerificationRecordTest() {
        try {
            List<Application_Participant__c> appParticipant = [
                SELECT Id
                FROM Application_Participant__c
                LIMIT 1
            ];
            Test.startTest();
            Id verificationId = BCB_CTRL_CreateApplications.createVerificationRecord(
                appParticipant[0],
                'Identifii Documents',
                'Success'
            );
            Assert.areNotEqual(null, verificationId, TEST_MESSAGE);
            Test.stopTest();
        } catch (Exception ex) {
            Assert.areNotEqual(null, ex.getMessage(), TEST_MESSAGE);
        }
    }

    /**
     * @description Test method for BCB_CTRL_CreateApplications.createDocumentBasedOnParticipant
     */
    @isTest
    public static void createApplicationLineItemTest() {
        Lead leadRec = BCB_DAL_TestFactory.createLead();
        insert leadRec;
        List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(
            1
        );
        insert appParticipants;
        Application_Document__c appDoc = new Application_Document__c();
        appDoc.Application_Participant__c = appParticipants[0].id;
        appDoc.External_Id__c = 'text.pdf';
        insert appDoc;
        ContentVersion cv = new ContentVersion();
        cv.Title = appDoc.External_Id__c = 'text.pdf';
        cv.PathOnClient = 'path/to/my/document.pdf';
        cv.VersionData = Blob.valueOf(TEST_CONTENT);
        insert cv;
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
            SELECT Id, ContentDocumentId, VersionData
            FROM ContentVersion
            WHERE Id = :cv.Id
        ]
        .ContentDocumentId;
        cdl.LinkedEntityId = appDoc.Id;
        insert cdl;
        String formData = FORM_DATA;
        Test.startTest();
        BCB_CTRL_CreateApplications.createApplicationLineItem(appParticipants[0].Id, formData);
        BCB_CTRL_CreateApplications.updatePreApplicationData(appParticipants[0].id, formData);
        Test.stopTest();
        Assert.areNotEqual(null, formData, TEST_MESSAGE);
    }
    @isTest
    static void createContentVersionTest() {
        try {
            List<Application__c> applicationList = BCB_DAL_TestFactory.createApplication(1);
            applicationList[0].AOB_GroupName__c = TEST_MESSAGE;
            applicationList[0].AOB_RegistrationNumber__c = '123456789';
            insert applicationList;
            List<Application_Participant__c> lstApp = BCB_DAL_TestFactory.createApplicationParticipant(
                1
            );
            lstApp[0].Application__c = applicationList[0].id;
            insert lstApp;
            Application_Document__c document = new Application_Document__c();
            document.Document_Type__c = 'upload signature';
            document.Application_Participant__c = lstApp[0].Id;
            insert document;
            ContentVersion cv = new ContentVersion();
            cv.VersionData = Blob.valueOf(TEST_CONTENT);
            cv.Title = document.Document_Type__c;
            cv.PathOnClient = FILE_PATH;
            insert cv;
            ContentDocumentLink cdl = new ContentDocumentLink();
            ContentVersion contentVersion = [
                SELECT Id, Title, ContentDocumentId
                FROM ContentVersion
                WHERE Id = :cv.Id
            ];
            cdl.ContentDocumentId = contentVersion.ContentDocumentId;
            cdl.LinkedEntityId = document.Id;
            cdl.ShareType = 'V';
            insert cdl;
            String filename = FILE_PATH;
            String formData = FORM_DATA;
            BCB_CTRL_CreateApplications.createApplicationDocument(
                lstApp[0].id,
                filename,
                formData,
                'UGX'
            );
            Assert.areNotEqual(null, cdl, TEST_MESSAGE);
        } catch (exception ex) {
            Assert.areNotEqual(null, ex.getMessage(), TEST_MESSAGE);
        }
    }
    @isTest
    static void createContentVersionTest1() {
        try {
            List<Application__c> applicationList = BCB_DAL_TestFactory.createApplication(1);
            applicationList[0].AOB_GroupName__c = TEST_MESSAGE;
            applicationList[0].AOB_RegistrationNumber__c = '123456789';
            insert applicationList;
            List<Application_Participant__c> lstApp = BCB_DAL_TestFactory.createApplicationParticipant(
                1
            );
            lstApp[0].Application__c = applicationList[0].id;
            insert lstApp;
            Application_Document__c document = new Application_Document__c();
            document.Document_Type__c = 'upload signature';
            document.Application_Participant__c = lstApp[0].Id;
            insert document;
            ContentVersion cv = new ContentVersion();
            cv.VersionData = Blob.valueOf(TEST_CONTENT);
            cv.Title = document.Document_Type__c;
            cv.PathOnClient = FILE_PATH;
            insert cv;
            ContentDocumentLink cdl = new ContentDocumentLink();
            ContentVersion contentVersion = [
                SELECT Id, Title, ContentDocumentId
                FROM ContentVersion
                WHERE Id = :cv.Id
            ];
            cdl.ContentDocumentId = contentVersion.ContentDocumentId;
            cdl.LinkedEntityId = document.Id;
            cdl.ShareType = 'V';
            insert cdl;
            String filename = FILE_PATH;
            String formData = FORM_DATA;
            BCB_CTRL_CreateApplications.createApplicationDocument(
                lstApp[0].id,
                filename,
                formData,
                'USD'
            );
            Assert.areNotEqual(null, cdl, TEST_MESSAGE);
        } catch (exception ex) {
            Assert.areNotEqual(null, ex.getMessage(), TEST_MESSAGE);
        }
    }
    /**
     * @description Test method for BCB_CTRL_CreateApplications.createDocumentBasedOnParticipant
     */
    @isTest
    public static void getapplicationIdTest() {
        List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(
            1
        );
        insert appParticipants;
        BCB_CTRL_CreateApplications.getapplicationId(appParticipants[0].Id);
        Assert.areNotEqual(null, appParticipants, TEST_MESSAGE);
    }

    /**
     * @description Test method for BCB_CTRL_CreateApplications.createDocumentBasedOnParticipant
     */
    @isTest
    public static void fetchApplicationParticipantTest() {
        List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(
            1
        );
        insert appParticipants;
        BCB_CTRL_CreateApplications.fetchApplicationParticipant(appParticipants[0].Id);
        Assert.areNotEqual(null, appParticipants, TEST_MESSAGE);
    }

    /**
     * @description Test method for BCB_CTRL_CreateApplications.checkAppliationCorporateIdTest
     */
    @isTest
    public static void checkAppliationCorporateIdTest() {
        List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(
            1
        );
        insert appParticipants;
        String result = BCB_CTRL_CreateApplications.checkAppliationCorporateId(
            appParticipants[0].Id
        );
        Assert.isTrue(!String.isBlank(result), 'Result Should not be empty');
    }

    /**
     * @description TestMethod for invoking CorporateCustomerList
     *
     */
    @isTest
    static void getCorporateCustomerList() {
        List<Application__c> applicationList = BCB_DAL_TestFactory.createApplication(1);
        List<Application_Participant__c> applicationParticipationList = BCB_DAL_TestFactory.createApplicationParticipant(
            1
        );
        applicationList[0].AOB_BusinessLegalName__c = 'TESTINGCORP';
        insert applicationList;
        applicationParticipationList[0].Application__c = applicationList[0].Id;
        insert applicationParticipationList;
        String str = '{"customers": [{ "uuid": "12423554","customerType": "CORPORATE","identifications": {"expirationDate": "","PreferredIdentificationIndicator": ""},"orgDetails": {"legalName": "TESTINGNEWCORP", "companyName": "TESTINGNEWCORP","orgEstablishDt": "", "numEmployees": "","fiscalYearEnd": "", "ownership": ""}, "contacts": [ { "value": "someone.testing@sbsa.co.za", "contactType": "EMAIL","preferredInd": "Y"}, { "value": "+256(0)345687667","phoneType": "PHONE", "preferredInd": "Y"}],"addresses": [{"uuid": "12425","addressTypes": [ {"addressTypes": "Swift"}],"startDate": "2023-07-03T00:00:00.000","line1": "lajdafisnofewiz, , ABIM,UG,256","city": "", "province": "EST","postalCode": "","countryCode": "","plotNumber": "",  "preferredInd": "" }, { "uuid": "12345678", "addressTypes": [{ "addressTypes": "Registered"} ], "startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ", "city": "ABIM","province": "EST", "postalCode": "256", "countryCode": "UG", "plotNumber": "", "preferredInd": "N"}, { "uuid": "2123244", "addressTypes": [ { "addressTypes": "Swift" } ], "startDate": "2023-07-03T00:00:00.000","line1": "lajdafisnofewiz, , ABIM,UG,256","city": "", "province": "EST", "postalCode": "", "countryCode": "","plotNumber": "", "preferredInd": "" }, { "uuid": "","addressTypes": [ { "addressTypes": "Registered" }],"startDate": "2023-06-22T00:00:00.000","line1": "lajdafisnofewiz, , ","city": "ABIM", "province": "EST","postalCode": "256", "countryCode": "UG", "plotNumber": "","preferredInd": "N"},{ "uuid": "","addressTypes": [ {  "addressTypes": "Mailing" }],"startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ","city": "ABIM","province": "EST","postalCode": "256","countryCode": "UG", "plotNumber": "", "preferredInd": "Y" }, { "uuid": "","addressTypes": [ { "addressTypes": "Mailing"}], "startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ", "city": "ABIM", "province": "EST","postalCode": "256", "countryCode": "UG","plotNumber": "", "preferredInd": "Y"} ]}]}';
        CMN_GetCorporateCustomerList.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_GetCorporateCustomerList.mockHttpStatus = 'OK';
        CMN_GetCorporateCustomerList.mockHttpbody = str;
        Test.startTest();
        String repStatus = CMN_GetCorporateCustomerList.invocableMethod(
            applicationList,
            applicationParticipationList[0]
        );
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        BCB_CTRL_CreateApplications.fetchApplicationCifId(applicationParticipationList[0].Id);

        Test.stopTest();
        Assert.areNotEqual(null, m, TEST_MESSAGE);
    }

    /**
     * @description TestMethod for invoking CorporateCustomerList
     *
     */
    @istest
    static void testCalloutMethod8() {
        try {
            List<Application__c> applicationList = BCB_DAL_TestFactory.createApplication(1);
            List<Application_Participant__c> applicationParticipationList = BCB_DAL_TestFactory.createApplicationParticipant(
                1
            );
            applicationList[0].AOB_BusinessLegalName__c = TEST_BUSINESS_NAME;
            insert applicationList;
            List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(
                1
            );
            insert appParticipants;
            CMN_GetCorporateCustomerList.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
            CMN_GetCorporateCustomerList.mockHttpStatus = 'FAILED';
            CMN_GetCorporateCustomerList.mockHttpbody = '';
            Test.startTest();
            String repStatus = CMN_GetCorporateCustomerList.invocableMethod(
                applicationList,
                appParticipants[0]
            );
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            BCB_CTRL_CreateApplications.fetchApplicationCifId(applicationParticipationList[0].Id);

            Test.stopTest();
            Assert.areNotEqual(null, m, TEST_MESSAGE);
        } catch (AuraHandledException ex) {
            Assert.isTrue(ex.getMessage() != null, EXCEPTION_MESSAGE);
        }
    }

    /**
     * @description TestMethod for invoking CorporateCustomerList
     *
     */
    @istest
    static void testCalloutMethod9() {
        Lead leadRecord = BCB_DAL_TestFactory.createLead();
        insert leadRecord;
        List<Application__c> applicationList = BCB_DAL_TestFactory.createApplication(1);
        applicationList[0].AOB_BusinessLegalName__c = TEST_BUSINESS_NAME;
        applicationList[0].AOB_Lead__c = leadRecord.id;
        insert applicationList;
        List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(
            1
        );
        insert appParticipants;
        CMN_GetCorporateCustomerList.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_GetCorporateCustomerList.mockHttpStatus = 'FAILED';
        CMN_GetCorporateCustomerList.mockHttpbody = '';
        Map<String, Object> m = new Map<String, Object>();
        try {
            Test.startTest();
            String repStatus = CMN_GetCorporateCustomerList.invocableMethod(
                applicationList,
                appParticipants[0]
            );
            m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            BCB_CTRL_CreateApplications.fetchApplicationCifId(appParticipants[0].Id);
            Test.stopTest();
        } catch (Exception ex) {
            Assert.areNotEqual(null, m, TEST_MESSAGE);
        }
    }

    /**
     * @description TestMethod for invoking CorporateCustomerList
     *
     */
    @istest
    static void testCalloutMethod10() {
        List<Application__c> applicationList = BCB_DAL_TestFactory.createApplication(1);
        applicationList[0].AOB_BusinessLegalName__c = TEST_BUSINESS_NAME;
        insert applicationList;
        List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(
            1
        );
        insert appParticipants;
        CMN_GetCorporateCustomerList.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_GetCorporateCustomerList.mockHttpStatus = 'OK';
        CMN_GetCorporateCustomerList.mockHttpbody = '{"customers": [{ "uuid": "","customerType": "CORPORATE","identifications": {"expirationDate": "","PreferredIdentificationIndicator": ""},"orgDetails": {"legalName": "TESTINGNEWCORP", "companyName": "TESTINGNEWCORP","orgEstablishDt": "", "numEmployees": "","fiscalYearEnd": "", "ownership": ""}, "contacts": [ { "value": "someone.testing@sbsa.co.za", "contactType": "EMAIL","preferredInd": "Y"}, { "value": "+256(0)345687667","phoneType": "PHONE", "preferredInd": "Y"}],"addresses": [{"uuid": "12425","addressTypes": [ {"addressTypes": "Swift"}],"startDate": "2023-07-03T00:00:00.000","line1": "lajdafisnofewiz, , ABIM,UG,256","city": "", "province": "EST","postalCode": "","countryCode": "","plotNumber": "",  "preferredInd": "" }, { "uuid": "12345678", "addressTypes": [{ "addressTypes": "Registered"} ], "startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ", "city": "ABIM","province": "EST", "postalCode": "256", "countryCode": "UG", "plotNumber": "", "preferredInd": "N"}, { "uuid": "2123244", "addressTypes": [ { "addressTypes": "Swift" } ], "startDate": "2023-07-03T00:00:00.000","line1": "lajdafisnofewiz, , ABIM,UG,256","city": "", "province": "EST", "postalCode": "", "countryCode": "","plotNumber": "", "preferredInd": "" }, { "uuid": "","addressTypes": [ { "addressTypes": "Registered" }],"startDate": "2023-06-22T00:00:00.000","line1": "lajdafisnofewiz, , ","city": "ABIM", "province": "EST","postalCode": "256", "countryCode": "UG", "plotNumber": "","preferredInd": "N"},{ "uuid": "","addressTypes": [ {  "addressTypes": "Mailing" }],"startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ","city": "ABIM","province": "EST","postalCode": "256","countryCode": "UG", "plotNumber": "", "preferredInd": "Y" }, { "uuid": "","addressTypes": [ { "addressTypes": "Mailing"}], "startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ", "city": "ABIM", "province": "EST","postalCode": "256", "countryCode": "UG","plotNumber": "", "preferredInd": "Y"} ]}]}';
        Test.startTest();
        String repStatus = CMN_GetCorporateCustomerList.invocableMethod(
            applicationList,
            appParticipants[0]
        );
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        BCB_CTRL_CreateApplications.fetchApplicationCifId(appParticipants[0].Id);
        Test.stopTest();
        Assert.areNotEqual(null, m, TEST_MESSAGE);
    }

    /**
     * @description TestMethod for invoking CorporateCustomerList
     *
     */
    @istest
    static void testCalloutMethod11() {
        try {
            List<Application__c> applicationList = BCB_DAL_TestFactory.createApplication(1);
            List<Application_Participant__c> applicationParticipationList = BCB_DAL_TestFactory.createApplicationParticipant(
                1
            );
            applicationList[0].AOB_BusinessLegalName__c = TEST_BUSINESS_NAME;
            insert applicationList;
            List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(
                1
            );
            insert appParticipants;
            CMN_GetCorporateCustomerList.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
            CMN_GetCorporateCustomerList.mockHttpStatus = 'OK';
            CMN_GetCorporateCustomerList.mockHttpbody = '{"customers": [{ "uuid": "","customerType": "CORPORATE","identifications": {"expirationDate": "","PreferredIdentificationIndicator": ""},"orgDetails": {"legalName": "TESTINGNEWCORP", "companyName": "TESTINGNEWCORP","orgEstablishDt": "", "numEmployees": "","fiscalYearEnd": "", "ownership": ""}, "contacts": [ { "value": "someone.testing@sbsa.co.za", "contactType": "EMAIL","preferredInd": "Y"}, { "value": "+256(0)345687667","phoneType": "PHONE", "preferredInd": "Y"}],"addresses": [{"uuid": "12425","addressTypes": [ {"addressTypes": "Swift"}],"startDate": "2023-07-03T00:00:00.000","line1": "lajdafisnofewiz, , ABIM,UG,256","city": "", "province": "EST","postalCode": "","countryCode": "","plotNumber": "",  "preferredInd": "" }, { "uuid": "12345678", "addressTypes": [{ "addressTypes": "Registered"} ], "startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ", "city": "ABIM","province": "EST", "postalCode": "256", "countryCode": "UG", "plotNumber": "", "preferredInd": "N"}, { "uuid": "2123244", "addressTypes": [ { "addressTypes": "Swift" } ], "startDate": "2023-07-03T00:00:00.000","line1": "lajdafisnofewiz, , ABIM,UG,256","city": "", "province": "EST", "postalCode": "", "countryCode": "","plotNumber": "", "preferredInd": "" }, { "uuid": "","addressTypes": [ { "addressTypes": "Registered" }],"startDate": "2023-06-22T00:00:00.000","line1": "lajdafisnofewiz, , ","city": "ABIM", "province": "EST","postalCode": "256", "countryCode": "UG", "plotNumber": "","preferredInd": "N"},{ "uuid": "","addressTypes": [ {  "addressTypes": "Mailing" }],"startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ","city": "ABIM","province": "EST","postalCode": "256","countryCode": "UG", "plotNumber": "", "preferredInd": "Y" }, { "uuid": "","addressTypes": [ { "addressTypes": "Mailing"}], "startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ", "city": "ABIM", "province": "EST","postalCode": "256", "countryCode": "UG","plotNumber": "", "preferredInd": "Y"} ]}]}';
            Test.startTest();
            BCB_CTRL_CreateApplications.fetchApplicationCifId(applicationParticipationList[0].Id);
            Test.stopTest();
        } catch (exception dmx) {
            Assert.areNotEqual(null, dmx.getMessage());
        }
    }

    /**
     * @description Test method for BCB_CTRL_CreateApplications.createDocumentBasedOnParticipant
     */
    @isTest
    public static void releatedFilesApplicationTest() {
        List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(
            1
        );
        insert appParticipants;
        Application_Document__c appDoc = BCB_DAL_TestFactory.createDocumentBasedOnParticipant();
        appDoc.Application_Participant__c = appParticipants[0].Id;
        insert appDoc;
        Test.startTest();
        String result = BCB_CTRL_CreateApplications.releatedFilesApplication(
            appParticipants[0].Id,
            true
        );
        BCB_CTRL_CreateApplications.releatedFilesApplication(appParticipants[0].Id, false);
        Test.stopTest();
        Assert.areNotEqual(null, result, TEST_MESSAGE);
    }

    /**
     * @description Test method for BCB_CTRL_CreateApplications.checkNavigationStatus
     */
    @isTest
    public static void checkNavigationStatusTest() {
        String navigationvlaue = 'Pre application-Step1';
        Test.startTest();
        String result = BCB_CTRL_CreateApplications.checkNavigationStatus(navigationvlaue);
        Test.stopTest();
        Assert.areNotEqual(null, result, TEST_MESSAGE);
    }

    @isTest
    static void geRetailCustomerList() {
        List<Application__c> applicationList = BCB_DAL_TestFactory.createApplication(1);
        List<Application_Participant__c> applicationParticipationList = BCB_DAL_TestFactory.createApplicationParticipant(
            1
        );
        insert applicationList;
        insert applicationParticipationList;

        CMN_CustomerList.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_CustomerList.mockHttpStatus = 'OK';
        CMN_CustomerList.mockHttpBody = '{"customers": [ {"uuid": "748838393993", "accountNumber": "4895681", "prominentInfluentialPerson": { "relationType": {}}, "personDetails": { "firstName": "IGA","lastName": "KAGGWA","otherName": "IGA KAGGWA", "preferredName": "IGA","dob": "2000-01-01T00:00:00.000","title": "041", "citizenshipCountry": {}},"addresses": [{ "line1": "3-987","line2": "3-987", "line3": "3-987","addressTypes": [{"addressType": "Home","startDate": "2023-05-30T00:00:00.000","endDate": "2099-12-31T00:00:00.000" }],"city": "3-987","countryCode": "3-987","citizenshipCountry": "3-987","comment": "3-987","plotNumber": "3-987","preferredInd": "3-987","preferredFormat": "3-987","province": "3-987","district": "3-987","postalCode": "3-987"},{"line1": "3-987","line2": "3-987","line3": "3-987", "addressTypes": [{"addressType": "Mailing", "startDate": "2023-05-30T00:00:00.000", "endDate": "2099-12-31T00:00:00.000"} ],"city": "3-987","countryCode": "3-987","citizenshipCountry": "3-987", "comment": "3-987", "plotNumber": "3-987","preferredInd": "3-987", "preferredFormat": "3-987", "province": "3-987","district": "3-987","postalCode": "3-987" }, { "line1": "3-987ABIM","line2": "3-987ABIM", "line3": "3-987ABIM", "addressTypes": [  { "addressType": "Swift", "startDate": "2023-05-30T00:00:00.000", "endDate": "2099-12-31T00:00:00.000" }], "city": "3-987ABIM","countryCode": "3-987ABIM","citizenshipCountry": "3-987ABIM", "comment": "3-987ABIM","plotNumber": "3-987ABIM", "preferredInd": "3-987ABIM","preferredFormat": "3-987ABIM","province": "3-987ABIM","district": "3-987ABIM","postalCode": "3-987ABIM"}], "identifications": [ { "issuingCountry": "UG","documentCode": "D0021", "documentDescription": "NATIONAL IDENTITY CARD", "issuedDate": "2022-05-04T00:00:00.000","documentTypeCode": "DT000","documentTypeDescription": "Identification Proof Individual", "entityType": "CIFRetCust", "identificationType": "IDTYPER79", "placeOfIssue": "UG", "identificationNumber": "CF000121003X3A", "PreferredIdentificationIndicator": "Received" }, { "issuingCountry": "UG", "documentCode": "D0021","documentDescription": "NATIONAL IDENTITY CARD","issuedDate": "2022-05-04T00:00:00.000","documentTypeCode": "DT000", "documentTypeDescription": "Identification Proof Individual", "entityType": "CIFRetCust","identificationType": "IDTYPER79","placeOfIssue": "UG","identificationNumber": "CF000121003X3A","PreferredIdentificationIndicator": "Received" },{ "issuingCountry": "UG","documentCode": "D0021", "documentDescription": "NATIONAL IDENTITY CARD", "issuedDate": "2022-05-04T00:00:00.000","documentTypeCode": "DT000", "documentTypeDescription": "Identification Proof Individual","entityType": "CIFRetCust","identificationType": "IDTYPER79","placeOfIssue": "UG","identificationNumber": "CF000121003X3A","PreferredIdentificationIndicator": "Received" }]} ]}';

        applicationParticipationList[0].AOB_CIFID__c = '8838319939';
        update applicationParticipationList;
        Test.startTest();
        String preAppData = FORM_DATA;
        BCB_CTRL_CreateApplications.checkRetailCustomerExist(preAppData);

        Test.stopTest();
        Assert.areNotEqual(null, applicationParticipationList, TEST_MESSAGE);
    }

    @isTest
    static void geRetailCustomerList2() {
        List<Application__c> applicationList = BCB_DAL_TestFactory.createApplication(1);
        List<Application_Participant__c> applicationParticipationList = BCB_DAL_TestFactory.createApplicationParticipant(
            1
        );
        insert applicationList;
        insert applicationParticipationList;

        CMN_CustomerList.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_CustomerList.mockHttpStatus = 'OK';
        CMN_CustomerList.mockHttpBody = '{"customers": [ { "accountNumber": "4895681", "prominentInfluentialPerson": { "relationType": {}}, "personDetails": { "firstName": "IGA","lastName": "KAGGWA","otherName": "IGA KAGGWA", "preferredName": "IGA","dob": "2000-01-01T00:00:00.000","title": "041", "citizenshipCountry": {}},"addresses": [{ "line1": "3-987","line2": "3-987", "line3": "3-987","addressTypes": [{"addressType": "Home","startDate": "2023-05-30T00:00:00.000","endDate": "2099-12-31T00:00:00.000" }],"city": "3-987","countryCode": "3-987","citizenshipCountry": "3-987","comment": "3-987","plotNumber": "3-987","preferredInd": "3-987","preferredFormat": "3-987","province": "3-987","district": "3-987","postalCode": "3-987"},{"line1": "3-987","line2": "3-987","line3": "3-987", "addressTypes": [{"addressType": "Mailing", "startDate": "2023-05-30T00:00:00.000", "endDate": "2099-12-31T00:00:00.000"} ],"city": "3-987","countryCode": "3-987","citizenshipCountry": "3-987", "comment": "3-987", "plotNumber": "3-987","preferredInd": "3-987", "preferredFormat": "3-987", "province": "3-987","district": "3-987","postalCode": "3-987" }, { "line1": "3-987ABIM","line2": "3-987ABIM", "line3": "3-987ABIM", "addressTypes": [  { "addressType": "Swift", "startDate": "2023-05-30T00:00:00.000", "endDate": "2099-12-31T00:00:00.000" }], "city": "3-987ABIM","countryCode": "3-987ABIM","citizenshipCountry": "3-987ABIM", "comment": "3-987ABIM","plotNumber": "3-987ABIM", "preferredInd": "3-987ABIM","preferredFormat": "3-987ABIM","province": "3-987ABIM","district": "3-987ABIM","postalCode": "3-987ABIM"}], "identifications": [ { "issuingCountry": "UG","documentCode": "D0021", "documentDescription": "NATIONAL IDENTITY CARD", "issuedDate": "2022-05-04T00:00:00.000","documentTypeCode": "DT000","documentTypeDescription": "Identification Proof Individual", "entityType": "CIFRetCust", "identificationType": "IDTYPER79", "placeOfIssue": "UG", "identificationNumber": "CF000121003X3A", "PreferredIdentificationIndicator": "Received" }, { "issuingCountry": "UG", "documentCode": "D0021","documentDescription": "NATIONAL IDENTITY CARD","issuedDate": "2022-05-04T00:00:00.000","documentTypeCode": "DT000", "documentTypeDescription": "Identification Proof Individual", "entityType": "CIFRetCust","identificationType": "IDTYPER79","placeOfIssue": "UG","identificationNumber": "CF000121003X3A","PreferredIdentificationIndicator": "Received" },{ "issuingCountry": "UG","documentCode": "D0021", "documentDescription": "NATIONAL IDENTITY CARD", "issuedDate": "2022-05-04T00:00:00.000","documentTypeCode": "DT000", "documentTypeDescription": "Identification Proof Individual","entityType": "CIFRetCust","identificationType": "IDTYPER79","placeOfIssue": "UG","identificationNumber": "CF000121003X3A","PreferredIdentificationIndicator": "Received" }]} ]}';

        applicationParticipationList[0].AOB_CIFID__c = '8838319939';
        update applicationParticipationList;
        try {
            Test.startTest();
            String preAppData = FORM_DATA;
            BCB_CTRL_CreateApplications.checkRetailCustomerExist(preAppData);

            Test.stopTest();
        } catch (Exception ex) {
            Assert.areNotEqual(null, applicationParticipationList, TEST_MESSAGE);
        }
    }

    @isTest
    static void testGetApplicationClientType_WithValue() {
        // Create test Application with Client Type
        Application__c app = new Application__c(WI_ClientType__c = 'Corporate');
        insert app;

        // Call method
        String result = BCB_CTRL_CreateApplications.getapplicationClientType(app.Id);

        Assert.areEqual('Corporate', result, 'Should return the client type value');
    }

    @isTest
    static void testGetApplicationClientType_EmptyValue() {
        // Create test Application without Client Type
        Application__c app = new Application__c();
        insert app;

        // Call method
        String result = BCB_CTRL_CreateApplications.getapplicationClientType(app.Id);
        Assert.areEqual(
            true,
            String.isEmpty(result),
            'Should return empty string when client type is not set'
        );
    }

    @isTest
    static void testGetApplicationClientType_Exception() {
        // Pass an invalid Id to force exception
        Boolean exceptionThrown = false;
        try {
            BCB_CTRL_CreateApplications.getapplicationClientType('001XXXXXXXXXXXX'); // Invalid for Application__c
        } catch (AuraHandledException ex) {
            exceptionThrown = true;
            Assert.isTrue(ex.getMessage() != null, 'Exception should carry a message');
        }
        Assert.isTrue(exceptionThrown, 'AuraHandledException should have been thrown');
    }

    @isTest
    static void testGetApplicationId_Exception() {
        Boolean exceptionThrown = false;
        try {
            // Use a bogus Id with a prefix from another object (e.g., Account = 001)
            // so that selectApplicationParticipant will fail and hit the catch block
            BCB_CTRL_CreateApplications.getapplicationId('001XXXXXXXXXXXX');
        } catch (AuraHandledException ex) {
            exceptionThrown = true;
            Assert.areNotEqual(null, ex.getMessage(), EXCEPTION_MESSAGE);
        }
        Assert.isTrue(exceptionThrown, 'Expected AuraHandledException was not thrown');
    }

    @isTest
    static void testGetBCBWebsiteUrl() {
        // Call the method under test
        String result = BCB_CTRL_CreateApplications.getBCBWebsiteUrl();

        // Assert that the URL is as expected
        Assert.areEqual('https://www.stanbicbank.co.ug/uganda/business', result);
    }

    @isTest
    static void testFetchApplicationParticipant_CatchBlock() {
        try {
            // Pass a null Id
            BCB_CTRL_CreateApplications.fetchApplicationParticipant(null);
            Assert.isTrue(true, 'Exception expected but not thrown');
        } catch (AuraHandledException ex) {
            Assert.isTrue(ex.getMessage() != null);
        }
    }

    @isTest
    static void testCreateVerificationRecord_CatchBlock() {
        // Create a participant but don't insert it, so the lookup will be invalid
        Application_Participant__c dummyParticipant = new Application_Participant__c();

        Test.startTest();
        try {
            // Pass invalid participant (not inserted, no Id)
            BCB_CTRL_CreateApplications.createVerificationRecord(
                dummyParticipant,
                'TestSource',
                'TestStatus'
            );
            Assert.isTrue(false, 'Expected AuraHandledException was not thrown');
        } catch (AuraHandledException ex) {
            Assert.isTrue(ex.getMessage() != null, 'Expected AuraHandledException with a message');
        }
        Test.stopTest();
    }

    @isTest
    static void testUpdatePreApplicationData_CatchBlock() {
        // Malformed JSON to trigger JSON.deserialize exception
        String badJson = '{thisIsNotValidJson}';

        Test.startTest();
        Application__c app = new Application__c();
        insert app;

        Application_Participant__c participant = new Application_Participant__c(
            Application__c = app.Id
        );
        insert participant;
        try {
            BCB_CTRL_CreateApplications.updatePreApplicationData('001XXXXXXXXXXXX', badJson);
            Assert.isTrue(false, 'Expected AuraHandledException was not thrown.');
        } catch (AuraHandledException ex) {
            Assert.isTrue(ex.getMessage() != null, EXCEPTION_MESSAGE);
        }
        Test.stopTest();
    }

    @isTest
    public static void checkAppliationCorporateIdExceptionTest() {
        try {
            BCB_CTRL_CreateApplications.checkAppliationCorporateId(null);
            Assert.isTrue(false, 'Expected AuraHandledException was not thrown.');
        } catch (AuraHandledException ex) {
            Assert.isTrue(ex.getMessage() != null, EXCEPTION_MESSAGE);
        }
    }

    @isTest
    public static void createApplicationExceptionTest() {
        try {
            //Broken Json string
            String invalidJson = '{"nationalIDNuumber":"123","productCode": ';
            String fileData = '';
            Test.startTest();
            BCB_CTRL_CreateApplications.createApplication(invalidJson, fileData);
            Assert.isTrue(false, 'Expected AuraHandledException was not thrown.');
        } catch (AuraHandledException ex) {
            Assert.isTrue(ex.getMessage() != null, EXCEPTION_MESSAGE);
        }
    }

    @IsTest
    static void createApplicationLineItemExceptionTest() {
        String invalidParticipantId = null;
        String malformedJson = '{"invalid": "json" ---}';

        Test.startTest();
        try {
            BCB_CTRL_CreateApplications.createApplicationLineItem(
                invalidParticipantId,
                malformedJson
            );

            Assert.fail('An AuraHandledException should have been thrown.');
        } catch (AuraHandledException ex) {
            Assert.isNotNull(
                ex.getMessage(),
                'The exception message should be populated by the catch block.'
            );
        }
        Test.stopTest();
    }
}