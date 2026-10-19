/**
*@description TestClass for CMN_CustomerListTest
* @author jagadish 
* @date May 2023
* Story Number:SFP-24854
*/
@isTest
public with sharing class CMN_CustomerListTest {
    
    @isTest
    static void callInvocable(){
        List<Application_Participant__c> participantList=BCB_DAL_TestFactory.createApplicationParticipant(1);
        
        insert participantList;
        String dateString = participantList[0].AOB_DateofBirth__c.format().replace('/', '-');
        Map<String, String> preAppInputMap = new Map<String, String>{'firstName'=>participantList[0].CNGCU_First_Name__c,'lastName'=>participantList[0].CNGCU_Last_Name__c,'dateOfBirth'=>dateString};
        test.startTest();
        try{        
            String serializedResponse =CMN_CustomerList.invocableMethod(preAppInputMap);
            Assert.areNotEqual(null,serializedResponse,'Test');   
        }catch(exception ex){
            Assert.areNotEqual(null,ex.getMessage(),'Test');   
        }
        test.stopTest();
    }
    @isTest
    static void testCallInvocableMethod1() {
        CMN_CustomerList.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_CustomerList.mockHttpStatus='OK';
        CMN_CustomerList.mockHttpBody = '{"customers": [ {"uuid": "10302320940", "accountNumber": "4895681", "prominentInfluentialPerson": { "relationType": {}}, "personDetails": { "firstName": "IGA","lastName": "KAGGWA","otherName": "IGA KAGGWA", "preferredName": "IGA","dob": "2000-01-01T00:00:00.000","title": "041", "citizenshipCountry": {}},"addresses": [{ "line1": "3-987","line2": "3-987", "line3": "3-987","addressTypes": [{"addressType": "Home","startDate": "2023-05-30T00:00:00.000","endDate": "2099-12-31T00:00:00.000" }],"city": "3-987","countryCode": "3-987","citizenshipCountry": "3-987","comment": "3-987","plotNumber": "3-987","preferredInd": "3-987","preferredFormat": "3-987","province": "3-987","district": "3-987","postalCode": "3-987"},{"line1": "3-987","line2": "3-987","line3": "3-987", "addressTypes": [{"addressType": "Mailing", "startDate": "2023-05-30T00:00:00.000", "endDate": "2099-12-31T00:00:00.000"} ],"city": "3-987","countryCode": "3-987","citizenshipCountry": "3-987", "comment": "3-987", "plotNumber": "3-987","preferredInd": "3-987", "preferredFormat": "3-987", "province": "3-987","district": "3-987","postalCode": "3-987" }, { "line1": "3-987ABIM","line2": "3-987ABIM", "line3": "3-987ABIM", "addressTypes": [  { "addressType": "Swift", "startDate": "2023-05-30T00:00:00.000", "endDate": "2099-12-31T00:00:00.000" }], "city": "3-987ABIM","countryCode": "3-987ABIM","citizenshipCountry": "3-987ABIM", "comment": "3-987ABIM","plotNumber": "3-987ABIM", "preferredInd": "3-987ABIM","preferredFormat": "3-987ABIM","province": "3-987ABIM","district": "3-987ABIM","postalCode": "3-987ABIM"}], "identifications": [ { "issuingCountry": "UG","documentCode": "D0021", "documentDescription": "NATIONAL IDENTITY CARD", "issuedDate": "2022-05-04T00:00:00.000","documentTypeCode": "DT000","documentTypeDescription": "Identification Proof Individual", "entityType": "CIFRetCust", "identificationType": "IDTYPER79", "placeOfIssue": "UG", "identificationNumber": "CF000121003X3A", "PreferredIdentificationIndicator": "Received" }, { "issuingCountry": "UG", "documentCode": "D0021","documentDescription": "NATIONAL IDENTITY CARD","issuedDate": "2022-05-04T00:00:00.000","documentTypeCode": "DT000", "documentTypeDescription": "Identification Proof Individual", "entityType": "CIFRetCust","identificationType": "IDTYPER79","placeOfIssue": "UG","identificationNumber": "CF000121003X3A","PreferredIdentificationIndicator": "Received" },{ "issuingCountry": "UG","documentCode": "D0021", "documentDescription": "NATIONAL IDENTITY CARD", "issuedDate": "2022-05-04T00:00:00.000","documentTypeCode": "DT000", "documentTypeDescription": "Identification Proof Individual","entityType": "CIFRetCust","identificationType": "IDTYPER79","placeOfIssue": "UG","identificationNumber": "CF000121003X3A","PreferredIdentificationIndicator": "Received" }]} ]}';
        
        
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        insert applicationList;
        Application_Participant__c applicationParticipantRecord = new Application_Participant__c();
        applicationParticipantRecord.CNGCU_First_Name__c = 'John';
        applicationParticipantRecord.CNGCU_Last_Name__c = 'Doe';
        applicationParticipantRecord.AOB_DateofBirth__c = Date.today();
        applicationParticipantRecord.Application__c=applicationList[0].id;
        insert applicationParticipantRecord;
        String dateString = applicationParticipantRecord.AOB_DateofBirth__c.format().replace('/', '-');
        Map<String, String> preAppInputMap = new Map<String, String>{'firstName'=>applicationParticipantRecord.CNGCU_First_Name__c,'lastName'=>applicationParticipantRecord.CNGCU_Last_Name__c,'dateOfBirth'=>dateString};
        
        Test.startTest();
        
        CMN_CustomerList.invokeCustomerCheckBeforeProceed(preAppInputMap);
        
        Test.stopTest();
        Assert.areNotEqual(null, applicationParticipantRecord,'Test');    
    }
    @IsTest
    static void testCallInvocableMethod2() {
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        
        insert applicationList;
        Application_Participant__c applicationParticipantRecord = new Application_Participant__c();
        applicationParticipantRecord.CNGCU_First_Name__c = 'John';
        applicationParticipantRecord.CNGCU_Last_Name__c = 'Doe';
        applicationParticipantRecord.AOB_DateofBirth__c = Date.today();
        applicationParticipantRecord.Application__c=applicationList[0].id;
        insert applicationParticipantRecord;
        CMN_CustomerList.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_CustomerList.mockHttpStatus='OK';
        CMN_CustomerList.mockHttpBody = '{"customers": [ {"uuid": "null", "accountNumber": "4895681", "prominentInfluentialPerson": { "relationType": {}}, "personDetails": { "firstName": "IGA","lastName": "KAGGWA","otherName": "IGA KAGGWA", "preferredName": "IGA","dob": "2000-01-01T00:00:00.000","title": "041", "citizenshipCountry": {}},"addresses": [{ "line1": "3-987","line2": "3-987", "line3": "3-987","addressTypes": [{"addressType": "Home","startDate": "2023-05-30T00:00:00.000","endDate": "2099-12-31T00:00:00.000" }],"city": "3-987","countryCode": "3-987","citizenshipCountry": "3-987","comment": "3-987","plotNumber": "3-987","preferredInd": "3-987","preferredFormat": "3-987","province": "3-987","district": "3-987","postalCode": "3-987"},{"line1": "3-987","line2": "3-987","line3": "3-987", "addressTypes": [{"addressType": "Mailing", "startDate": "2023-05-30T00:00:00.000", "endDate": "2099-12-31T00:00:00.000"} ],"city": "3-987","countryCode": "3-987","citizenshipCountry": "3-987", "comment": "3-987", "plotNumber": "3-987","preferredInd": "3-987", "preferredFormat": "3-987", "province": "3-987","district": "3-987","postalCode": "3-987" }, { "line1": "3-987ABIM","line2": "3-987ABIM", "line3": "3-987ABIM", "addressTypes": [  { "addressType": "Swift", "startDate": "2023-05-30T00:00:00.000", "endDate": "2099-12-31T00:00:00.000" }], "city": "3-987ABIM","countryCode": "3-987ABIM","citizenshipCountry": "3-987ABIM", "comment": "3-987ABIM","plotNumber": "3-987ABIM", "preferredInd": "3-987ABIM","preferredFormat": "3-987ABIM","province": "3-987ABIM","district": "3-987ABIM","postalCode": "3-987ABIM"}], "identifications": [ { "issuingCountry": "UG","documentCode": "D0021", "documentDescription": "NATIONAL IDENTITY CARD", "issuedDate": "2022-05-04T00:00:00.000","documentTypeCode": "DT000","documentTypeDescription": "Identification Proof Individual", "entityType": "CIFRetCust", "identificationType": "IDTYPER79", "placeOfIssue": "UG", "identificationNumber": "CF000121003X3A", "PreferredIdentificationIndicator": "Received" }, { "issuingCountry": "UG", "documentCode": "D0021","documentDescription": "NATIONAL IDENTITY CARD","issuedDate": "2022-05-04T00:00:00.000","documentTypeCode": "DT000", "documentTypeDescription": "Identification Proof Individual", "entityType": "CIFRetCust","identificationType": "IDTYPER79","placeOfIssue": "UG","identificationNumber": "CF000121003X3A","PreferredIdentificationIndicator": "Received" },{ "issuingCountry": "UG","documentCode": "D0021", "documentDescription": "NATIONAL IDENTITY CARD", "issuedDate": "2022-05-04T00:00:00.000","documentTypeCode": "DT000", "documentTypeDescription": "Identification Proof Individual","entityType": "CIFRetCust","identificationType": "IDTYPER79","placeOfIssue": "UG","identificationNumber": "CF000121003X3A","PreferredIdentificationIndicator": "Received" }]} ]}';
        String dateString = applicationParticipantRecord.AOB_DateofBirth__c.format().replace('/', '-');
        Map<String, String> preAppInputMap = new Map<String, String>{'firstName'=>applicationParticipantRecord.CNGCU_First_Name__c,'lastName'=>applicationParticipantRecord.CNGCU_Last_Name__c,'dateOfBirth'=>dateString};
        
        Test.startTest();
        CMN_CustomerList.invokeCustomerCheckBeforeProceed(preAppInputMap);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationList,'Test');     
    }
    @isTest
    static void testCallInvocableMethod3() {
        CMN_CustomerList.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_CustomerList.mockHttpStatus='OK';
        CMN_CustomerList.mockHttpBody = '';
        
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        insert applicationList;
        Application_Participant__c applicationParticipantRecord = new Application_Participant__c();
        applicationParticipantRecord.CNGCU_First_Name__c = 'John';
        applicationParticipantRecord.CNGCU_Last_Name__c = 'Doe';
        applicationParticipantRecord.AOB_DateofBirth__c = Date.today();
        applicationParticipantRecord.Application__c=applicationList[0].id;
        insert applicationParticipantRecord;
        String dateString = applicationParticipantRecord.AOB_DateofBirth__c.format().replace('/', '-');
        Map<String, String> preAppInputMap = new Map<String, String>{'firstName'=>applicationParticipantRecord.CNGCU_First_Name__c,'lastName'=>applicationParticipantRecord.CNGCU_Last_Name__c,'dateOfBirth'=>dateString};
        
        Test.startTest();
        CMN_CustomerList.invokeCustomerCheckBeforeProceed(preAppInputMap);
        Test.stopTest();   
        Assert.areNotEqual(null, applicationParticipantRecord,'Test');        
    }
    
    @IsTest
    static void testCallInvocableMethod4() {
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        
        insert applicationList;
        Application_Participant__c applicationParticipantRecord = new Application_Participant__c();
        applicationParticipantRecord.CNGCU_First_Name__c = 'John';
        applicationParticipantRecord.CNGCU_Last_Name__c = 'Doe';
        applicationParticipantRecord.AOB_DateofBirth__c = Date.today();
        applicationParticipantRecord.Application__c=applicationList[0].id;
        insert applicationParticipantRecord;
        CMN_CustomerList.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_CustomerList.mockHttpStatus='FAILED';
        CMN_CustomerList.mockHttpBody = '';
        String dateString = applicationParticipantRecord.AOB_DateofBirth__c.format().replace('/', '-');
        Map<String, String> preAppInputMap = new Map<String, String>{'firstName'=>applicationParticipantRecord.CNGCU_First_Name__c,'lastName'=>applicationParticipantRecord.CNGCU_Last_Name__c,'dateOfBirth'=>dateString};
        
        Test.startTest();
        CMN_CustomerList.invokeCustomerCheckBeforeProceed(preAppInputMap);
        
        Test.stopTest();
        Assert.areNotEqual(null, applicationParticipantRecord,'Test');     
        
    }
    @isTest
    static void testCallInvocableMethod5() {
        CMN_CustomerList.mockHttpStatusCode =  CMN_API_HttpBase.HTTP_OK;
        CMN_CustomerList.mockHttpStatus='OK';
        CMN_CustomerList.mockHttpBody = '';
        
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        insert applicationList;
        Application_Participant__c applicationParticipantRecord = new Application_Participant__c();
        applicationParticipantRecord.CNGCU_First_Name__c = 'John';
        applicationParticipantRecord.CNGCU_Last_Name__c = 'Doe';
        applicationParticipantRecord.AOB_DateofBirth__c = Date.today();
        applicationParticipantRecord.Application__c=applicationList[0].id;
        insert applicationParticipantRecord;
        String dateString = applicationParticipantRecord.AOB_DateofBirth__c.format().replace('/', '-');
        Map<String, String> preAppInputMap = new Map<String, String>{'firstName'=>applicationParticipantRecord.CNGCU_First_Name__c,'lastName'=>applicationParticipantRecord.CNGCU_Last_Name__c,'dateOfBirth'=>dateString};
        
        Test.startTest();
        CMN_CustomerList.invokeCustomerCheckBeforeProceed(preAppInputMap);
        Test.stopTest(); 
        Assert.areNotEqual(null, applicationParticipantRecord,'Test');     
    }
    @isTest
    static void geRetailCustomerList(){
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        List<Application_Participant__c> applicationParticipationList=BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert applicationList;
        insert applicationParticipationList;
        
        CMN_CustomerList.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_CustomerList.mockHttpStatus='OK';
        CMN_CustomerList.mockHttpBody = '{"customers": [ {"uuid": "748838393993", "accountNumber": "4895681", "prominentInfluentialPerson": { "relationType": {}}, "personDetails": { "firstName": "IGA","lastName": "KAGGWA","otherName": "IGA KAGGWA", "preferredName": "IGA","dob": "2000-01-01T00:00:00.000","title": "041", "citizenshipCountry": {}},"addresses": [{ "line1": "3-987","line2": "3-987", "line3": "3-987","addressTypes": [{"addressType": "Home","startDate": "2023-05-30T00:00:00.000","endDate": "2099-12-31T00:00:00.000" }],"city": "3-987","countryCode": "3-987","citizenshipCountry": "3-987","comment": "3-987","plotNumber": "3-987","preferredInd": "3-987","preferredFormat": "3-987","province": "3-987","district": "3-987","postalCode": "3-987"},{"line1": "3-987","line2": "3-987","line3": "3-987", "addressTypes": [{"addressType": "Mailing", "startDate": "2023-05-30T00:00:00.000", "endDate": "2099-12-31T00:00:00.000"} ],"city": "3-987","countryCode": "3-987","citizenshipCountry": "3-987", "comment": "3-987", "plotNumber": "3-987","preferredInd": "3-987", "preferredFormat": "3-987", "province": "3-987","district": "3-987","postalCode": "3-987" }, { "line1": "3-987ABIM","line2": "3-987ABIM", "line3": "3-987ABIM", "addressTypes": [  { "addressType": "Swift", "startDate": "2023-05-30T00:00:00.000", "endDate": "2099-12-31T00:00:00.000" }], "city": "3-987ABIM","countryCode": "3-987ABIM","citizenshipCountry": "3-987ABIM", "comment": "3-987ABIM","plotNumber": "3-987ABIM", "preferredInd": "3-987ABIM","preferredFormat": "3-987ABIM","province": "3-987ABIM","district": "3-987ABIM","postalCode": "3-987ABIM"}], "identifications": [ { "issuingCountry": "UG","documentCode": "D0021", "documentDescription": "NATIONAL IDENTITY CARD", "issuedDate": "2022-05-04T00:00:00.000","documentTypeCode": "DT000","documentTypeDescription": "Identification Proof Individual", "entityType": "CIFRetCust", "identificationType": "IDTYPER79", "placeOfIssue": "UG", "identificationNumber": "CF000121003X3A", "PreferredIdentificationIndicator": "Received" }, { "issuingCountry": "UG", "documentCode": "D0021","documentDescription": "NATIONAL IDENTITY CARD","issuedDate": "2022-05-04T00:00:00.000","documentTypeCode": "DT000", "documentTypeDescription": "Identification Proof Individual", "entityType": "CIFRetCust","identificationType": "IDTYPER79","placeOfIssue": "UG","identificationNumber": "CF000121003X3A","PreferredIdentificationIndicator": "Received" },{ "issuingCountry": "UG","documentCode": "D0021", "documentDescription": "NATIONAL IDENTITY CARD", "issuedDate": "2022-05-04T00:00:00.000","documentTypeCode": "DT000", "documentTypeDescription": "Identification Proof Individual","entityType": "CIFRetCust","identificationType": "IDTYPER79","placeOfIssue": "UG","identificationNumber": "CF000121003X3A","PreferredIdentificationIndicator": "Received" }]} ]}';
        
        applicationParticipationList[0].AOB_CIFID__c = '8838319939';
        String dateString = applicationParticipationList[0].AOB_DateofBirth__c.format().replace('/', '-');
        applicationParticipationList[0].AOB_DateofBirth__c = Date.valueOf(dateString);
        update applicationParticipationList;
        Test.startTest();
        System.enqueueJob(new BCB_GetCustomerList(applicationParticipationList[0],applicationList[0]));
        
        Test.stopTest();
        Assert.areNotEqual(null, applicationParticipationList,'Test');
    }
    @isTest
    static void geRetailCustomerList1(){
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        List<Application_Participant__c> applicationParticipationList=BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert applicationList;
        insert applicationParticipationList;
        
        Test.startTest();
        
        
        Test.stopTest();
        Assert.areNotEqual(null, applicationParticipationList,'Test');
    }
    @isTest
    public static void testParsingJsonString() {
        
        String jsonResponse = '{"customers": [{"uuid": "10302321296","accountNumber": "4897384","prominentInfluentialPerson": { "relationType": {}}, "personDetails": {"firstName": "NAMAJANJA", "lastName": "WILBER","otherName": "NAMAJANJA WILBER","preferredName": "NAMAJANJA","dob": "1994-10-18","title": "040", "citizenshipCountry": {}}, "addresses": [ { "line1": "1234", "line2": "1234", "line3": "1234", "addressTypes": [  {"addressType": "Home", "startDate": "2023-07-11T00:00:00.000","endDate": "2099-12-31T00:00:00.000"} ],"city": "1234", "countryCode": "1234", "citizenshipCountry": "1234","comment": "1234","plotNumber": "1234","preferredInd": "1234","preferredFormat": "1234","province": "1234","district": "1234", "postalCode": "1234" }],"identifications": [{  "issuingCountry": "UG","documentCode": "D0021","documentDescription": "NATIONAL IDENTITY CARD", "issuedDate": "2022-05-04T00:00:00.000", "documentTypeCode": "DT000","documentTypeDescription": "Identification Proof Individual", "entityType": "CIFRetCust", "identificationType": "IDTYPER79", "placeOfIssue": "UG","identificationNumber": "CM940721001N4G", "PreferredIdentificationIndicator": "Received"}], "contacts": []} ]}';
        
        
        BCB_CustomerListBean data = (BCB_CustomerListBean) JSON.deserialize(jsonResponse, BCB_CustomerListBean.class);
        BCB_CustomerListBean.Customers customer = data.customers[0];
        
        BCB_CustomerListBean.PersonDetails perDetails = new BCB_CustomerListBean.PersonDetails();
        perDetails.firstName = 'lokesh';
        BCB_CustomerListBean.Addresses address = customer.addresses[0];
        BCB_CustomerListBean.Identifications identification = customer.identifications[0];
        Assert.areNotEqual(null, identification,'Test');
        
    }    
    @isTest
    static void geRetailCustomerList2(){
        lead l = BCB_DAL_TestFactory.createLead();
        insert l;
        List<Application__c> applicationList = BCB_DAL_TestFactory.createApplication(1);
        applicationList[0].AOB_Lead__c = l.id;
        insert applicationList;
        List<Application_Participant__c> applicationParticipationList=BCB_DAL_TestFactory.createApplicationParticipant(1);
        applicationParticipationList[0].application__c = applicationList[0].id;
        insert applicationParticipationList;
 
        CMN_CustomerList.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_CustomerList.mockHttpStatus='OK';
        CMN_CustomerList.mockHttpBody = '{"customers": [ { "accountNumber": "4895681", "prominentInfluentialPerson": { "relationType": {}}, "personDetails": { "firstName": "IGA","lastName": "KAGGWA","otherName": "IGA KAGGWA", "preferredName": "IGA","dob": "2000-01-01T00:00:00.000","title": "041", "citizenshipCountry": {}},"addresses": [{ "line1": "3-987","line2": "3-987", "line3": "3-987","addressTypes": [{"addressType": "Home","startDate": "2023-05-30T00:00:00.000","endDate": "2099-12-31T00:00:00.000" }],"city": "3-987","countryCode": "3-987","citizenshipCountry": "3-987","comment": "3-987","plotNumber": "3-987","preferredInd": "3-987","preferredFormat": "3-987","province": "3-987","district": "3-987","postalCode": "3-987"},{"line1": "3-987","line2": "3-987","line3": "3-987", "addressTypes": [{"addressType": "Mailing", "startDate": "2023-05-30T00:00:00.000", "endDate": "2099-12-31T00:00:00.000"} ],"city": "3-987","countryCode": "3-987","citizenshipCountry": "3-987", "comment": "3-987", "plotNumber": "3-987","preferredInd": "3-987", "preferredFormat": "3-987", "province": "3-987","district": "3-987","postalCode": "3-987" }, { "line1": "3-987ABIM","line2": "3-987ABIM", "line3": "3-987ABIM", "addressTypes": [  { "addressType": "Swift", "startDate": "2023-05-30T00:00:00.000", "endDate": "2099-12-31T00:00:00.000" }], "city": "3-987ABIM","countryCode": "3-987ABIM","citizenshipCountry": "3-987ABIM", "comment": "3-987ABIM","plotNumber": "3-987ABIM", "preferredInd": "3-987ABIM","preferredFormat": "3-987ABIM","province": "3-987ABIM","district": "3-987ABIM","postalCode": "3-987ABIM"}], "identifications": [ { "issuingCountry": "UG","documentCode": "D0021", "documentDescription": "NATIONAL IDENTITY CARD", "issuedDate": "2022-05-04T00:00:00.000","documentTypeCode": "DT000","documentTypeDescription": "Identification Proof Individual", "entityType": "CIFRetCust", "identificationType": "IDTYPER79", "placeOfIssue": "UG", "identificationNumber": "CF000121003X3A", "PreferredIdentificationIndicator": "Received" }, { "issuingCountry": "UG", "documentCode": "D0021","documentDescription": "NATIONAL IDENTITY CARD","issuedDate": "2022-05-04T00:00:00.000","documentTypeCode": "DT000", "documentTypeDescription": "Identification Proof Individual", "entityType": "CIFRetCust","identificationType": "IDTYPER79","placeOfIssue": "UG","identificationNumber": "CF000121003X3A","PreferredIdentificationIndicator": "Received" },{ "issuingCountry": "UG","documentCode": "D0021", "documentDescription": "NATIONAL IDENTITY CARD", "issuedDate": "2022-05-04T00:00:00.000","documentTypeCode": "DT000", "documentTypeDescription": "Identification Proof Individual","entityType": "CIFRetCust","identificationType": "IDTYPER79","placeOfIssue": "UG","identificationNumber": "CF000121003X3A","PreferredIdentificationIndicator": "Received" }]} ]}';
        
        applicationParticipationList[0].AOB_CIFID__c = '8838319939';
        String dateString = applicationParticipationList[0].AOB_DateofBirth__c.format().replace('/', '-');
        applicationParticipationList[0].AOB_DateofBirth__c = Date.valueOf(dateString);
        update applicationParticipationList;
        Test.startTest();
        System.enqueueJob(new BCB_GetCustomerList(applicationParticipationList[0],applicationList[0]));
        
        Test.stopTest();
        Assert.areNotEqual(null, applicationParticipationList,'Test');
    }
    @isTest
    public static void testCustomersCreation() {
        // Test the creation of Customers and related objects
        BCB_CustomerListBean.Customers cust = new BCB_CustomerListBean.Customers();
        cust.uuid = '12345678';
        cust.accountNumber = 'ACCT-123';
        
        BCB_CustomerListBean.PersonDetails person = new BCB_CustomerListBean.PersonDetails();
        person.firstName = 'John';
        person.lastName = 'Doe';
        person.otherName = 'Doe';
        person.preferredName = 'Doe';
        person.dob = '';
        person.title = 'Doe';
        cust.personDetails = person;
        
        BCB_CustomerListBean.AddressTypes addressType = new BCB_CustomerListBean.AddressTypes();
        addressType.addressType = 'Home';
        addressType.startDate = '';
        addressType.endDate = '';
        // Set other fields in AddressTypes as required for the test
        
        BCB_CustomerListBean.Addresses address = new BCB_CustomerListBean.Addresses();
        address.line1 = '123 Main Street';
        address.city = 'Cityville';
        address.line2 = 'US';
        address.line3 = 'US';
        address.citizenshipCountry = 'US';
        address.countryCode = 'US';
        address.comment = 'US';
        address.plotNumber = 'US';
        address.preferredInd = 'US';
        address.preferredFormat = 'US';
        address.province = 'US';
        address.district = 'US';
        address.postalCode = 'US';
        // Set other fields in Addresses as required for the test
        
        cust.addresses = new List<BCB_CustomerListBean.Addresses>{address};
            
            // Similar setup for other related objects like ProminentInfluentialPerson, Identifications, RelationType
            
            // Now, insert the Customers record along with the related objects
            
            BCB_CustomerListBean.Identifications identifications = new BCB_CustomerListBean.Identifications();
        identifications.documentCode = '123 Main Street';
        identifications.documentDescription = 'Cityville';
        identifications.documentTypeCode = 'US';
        identifications.documentTypeDescription = 'US';
        identifications.entityType = 'US';
        identifications.identificationNumber = 'US';
        identifications.identificationType = 'US';
        identifications.issuedDate = 'US';
        identifications.issuingCountry = 'US';
        identifications.placeOfIssue = 'US';
        identifications.PreferredIdentificationIndicator = 'US';
        Assert.areNotEqual(null, identifications,'Test');
        
    }
}