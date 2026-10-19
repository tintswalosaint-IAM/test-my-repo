/***************************************************************************************
@ Author            :Lokesh Bothsa 
@ Date              :July 2023
@ Name of the Class :BCB_CreateAccountLockProfileTest
@ Description       :Test Class for dealing with debitfreeze api and sending the result to the main container and storing the values in the wrapper
@ Last Modified By  :Lokesh Bothsa  
@ Last Modified On  :25-07-2023
@ Modification Description : SFP-25772 
***************************************************************************************/
/**
* @description TestMethod for invoking accountLock
*
*/
@isTest 
public with sharing class CMN_CreateAccountLockProfileTest {
    /**
* @description TestMethod for invoking accountLock
*
*/
    @isTest
    static void callInvocable(){ 
        
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        insert applicationList;
        List<Application_Participant__c> appParticipants =  BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appParticipants;
        test.startTest();
        try{        
           CMN_CreateAccountLockProfile.invocableMethod(applicationList,appParticipants);            
        }catch(exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'It should Not be null'); 
        }
        test.stopTest();
    }
    /**
* @description TestMethod for invoking accountLock
*
*/
    @isTest
    static void testCallInvocableMethod1() {
        CMN_CreateAccountLockProfile.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_CreateAccountLockProfile.mockHttpStatus='OK';
        CMN_CreateAccountLockProfile.mockHttpBody = '{"customers": [ {"uuid": "10302320940", "accountNumber": "4895681", "prominentInfluentialPerson": { "relationType": {}}, "personDetails": { "firstName": "IGA","lastName": "KAGGWA","otherName": "IGA KAGGWA", "preferredName": "IGA","dob": "2000-01-01T00:00:00.000","title": "041", "citizenshipCountry": {}},"addresses": [{ "line1": "3-987","line2": "3-987", "line3": "3-987","addressTypes": [{"addressType": "Home","startDate": "2023-05-30T00:00:00.000","endDate": "2099-12-31T00:00:00.000" }],"city": "3-987","countryCode": "3-987","citizenshipCountry": "3-987","comment": "3-987","plotNumber": "3-987","preferredInd": "3-987","preferredFormat": "3-987","province": "3-987","district": "3-987","postalCode": "3-987"},{"line1": "3-987","line2": "3-987","line3": "3-987", "addressTypes": [{"addressType": "Mailing", "startDate": "2023-05-30T00:00:00.000", "endDate": "2099-12-31T00:00:00.000"} ],"city": "3-987","countryCode": "3-987","citizenshipCountry": "3-987", "comment": "3-987", "plotNumber": "3-987","preferredInd": "3-987", "preferredFormat": "3-987", "province": "3-987","district": "3-987","postalCode": "3-987" }, { "line1": "3-987ABIM","line2": "3-987ABIM", "line3": "3-987ABIM", "addressTypes": [  { "addressType": "Swift", "startDate": "2023-05-30T00:00:00.000", "endDate": "2099-12-31T00:00:00.000" }], "city": "3-987ABIM","countryCode": "3-987ABIM","citizenshipCountry": "3-987ABIM", "comment": "3-987ABIM","plotNumber": "3-987ABIM", "preferredInd": "3-987ABIM","preferredFormat": "3-987ABIM","province": "3-987ABIM","district": "3-987ABIM","postalCode": "3-987ABIM"}], "identifications": [ { "issuingCountry": "UG","documentCode": "D0021", "documentDescription": "NATIONAL IDENTITY CARD", "issuedDate": "2022-05-04T00:00:00.000","documentTypeCode": "DT000","documentTypeDescription": "Identification Proof Individual", "entityType": "CIFRetCust", "identificationType": "IDTYPER79", "placeOfIssue": "UG", "identificationNumber": "CF000121003X3A", "PreferredIdentificationIndicator": "Received" }, { "issuingCountry": "UG", "documentCode": "D0021","documentDescription": "NATIONAL IDENTITY CARD","issuedDate": "2022-05-04T00:00:00.000","documentTypeCode": "DT000", "documentTypeDescription": "Identification Proof Individual", "entityType": "CIFRetCust","identificationType": "IDTYPER79","placeOfIssue": "UG","identificationNumber": "CF000121003X3A","PreferredIdentificationIndicator": "Received" },{ "issuingCountry": "UG","documentCode": "D0021", "documentDescription": "NATIONAL IDENTITY CARD", "issuedDate": "2022-05-04T00:00:00.000","documentTypeCode": "DT000", "documentTypeDescription": "Identification Proof Individual","entityType": "CIFRetCust","identificationType": "IDTYPER79","placeOfIssue": "UG","identificationNumber": "CF000121003X3A","PreferredIdentificationIndicator": "Received" }]} ]}';
        
        
        List<Application__c> applicationList = BCB_DAL_TestFactory.createApplication(1);
        insert applicationList;
        List<Application_Participant__c> appParticipants =  BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appParticipants;
        
        Test.startTest();
        
        string str=CMN_CreateAccountLockProfile.invocableMethod(applicationList,appParticipants);
        
        Test.stopTest(); 
        Assert.areNotEqual(null,str,'It should Not be null');   
    }
    /**
* @description TestMethod for invoking accountLock
*
*/
    @isTest
    static void testCallInvocableMethod2() {
        CMN_CreateAccountLockProfile.mockHttpStatusCode = CMN_API_HttpBase.HTTP_BAD_REQUEST;
        CMN_CreateAccountLockProfile.mockHttpStatus='FAILED';
        CMN_CreateAccountLockProfile.mockHttpBody = '';
        
        BCB_HttpMockGenerator.setTestMockResponse(CMN_CreateAccountLockProfile.mockHttpStatusCode, CMN_CreateEnterpriseCustomer.mockHttpStatus, CMN_CreateEnterpriseCustomer.mockHttpBody);
        
        lead l = BCB_DAL_TestFactory.createLead();
        insert l;
        List<Application__c> applicationList = BCB_DAL_TestFactory.createApplication(1);
        applicationList[0].AOB_Lead__c = l.id;
        insert applicationList;
        List<Application_Participant__c> appParticipants=BCB_DAL_TestFactory.createApplicationParticipant(1);
        appParticipants[0].application__c = applicationList[0].id;
        insert appParticipants;



        /* List<Application__c> applicationList = BCB_DAL_TestFactory.createApplication(1);
        insert applicationList;
        List<Application_Participant__c> appParticipants =  BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appParticipants; */
        Test.startTest();
        
        string str=CMN_CreateAccountLockProfile.invocableMethod(applicationList,appParticipants);
        
        Test.stopTest();   
        Assert.areNotEqual(null,str,'It should Not be null');  
    }
    /**
* @description TestMethod for invoking accountLock
*
*/
    @isTest
    static void testCallInvocableMethod3() {
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        insert applicationList;
        List<Application_Participant__c> lstofParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstofParticipants[0].Application__c = applicationList[0].Id;
        insert lstofParticipants;
        
        CMN_CreateAccountLockProfile.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_CreateAccountLockProfile.mockHttpStatus='OK';
        CMN_CustomerList.mockHttpBody = '{"customers": [ {"uuid": "10302320940", "accountNumber": "4895681", "prominentInfluentialPerson": { "relationType": {}}, "personDetails": { "firstName": "IGA","lastName": "KAGGWA","otherName": "IGA KAGGWA", "preferredName": "IGA","dob": "2000-01-01T00:00:00.000","title": "041", "citizenshipCountry": {}},"addresses": [{ "line1": "3-987","line2": "3-987", "line3": "3-987","addressTypes": [{"addressType": "Home","startDate": "2023-05-30T00:00:00.000","endDate": "2099-12-31T00:00:00.000" }],"city": "3-987","countryCode": "3-987","citizenshipCountry": "3-987","comment": "3-987","plotNumber": "3-987","preferredInd": "3-987","preferredFormat": "3-987","province": "3-987","district": "3-987","postalCode": "3-987"},{"line1": "3-987","line2": "3-987","line3": "3-987", "addressTypes": [{"addressType": "Mailing", "startDate": "2023-05-30T00:00:00.000", "endDate": "2099-12-31T00:00:00.000"} ],"city": "3-987","countryCode": "3-987","citizenshipCountry": "3-987", "comment": "3-987", "plotNumber": "3-987","preferredInd": "3-987", "preferredFormat": "3-987", "province": "3-987","district": "3-987","postalCode": "3-987" }, { "line1": "3-987ABIM","line2": "3-987ABIM", "line3": "3-987ABIM", "addressTypes": [  { "addressType": "Swift", "startDate": "2023-05-30T00:00:00.000", "endDate": "2099-12-31T00:00:00.000" }], "city": "3-987ABIM","countryCode": "3-987ABIM","citizenshipCountry": "3-987ABIM", "comment": "3-987ABIM","plotNumber": "3-987ABIM", "preferredInd": "3-987ABIM","preferredFormat": "3-987ABIM","province": "3-987ABIM","district": "3-987ABIM","postalCode": "3-987ABIM"}], "identifications": [ { "issuingCountry": "UG","documentCode": "D0021", "documentDescription": "NATIONAL IDENTITY CARD", "issuedDate": "2022-05-04T00:00:00.000","documentTypeCode": "DT000","documentTypeDescription": "Identification Proof Individual", "entityType": "CIFRetCust", "identificationType": "IDTYPER79", "placeOfIssue": "UG", "identificationNumber": "CF000121003X3A", "PreferredIdentificationIndicator": "Received" }, { "issuingCountry": "UG", "documentCode": "D0021","documentDescription": "NATIONAL IDENTITY CARD","issuedDate": "2022-05-04T00:00:00.000","documentTypeCode": "DT000", "documentTypeDescription": "Identification Proof Individual", "entityType": "CIFRetCust","identificationType": "IDTYPER79","placeOfIssue": "UG","identificationNumber": "CF000121003X3A","PreferredIdentificationIndicator": "Received" },{ "issuingCountry": "UG","documentCode": "D0021", "documentDescription": "NATIONAL IDENTITY CARD", "issuedDate": "2022-05-04T00:00:00.000","documentTypeCode": "DT000", "documentTypeDescription": "Identification Proof Individual","entityType": "CIFRetCust","identificationType": "IDTYPER79","placeOfIssue": "UG","identificationNumber": "CF000121003X3A","PreferredIdentificationIndicator": "Received" }]} ]}';
        
        BCB_HttpMockGenerator.setTestMockResponse(CMN_CreateAccountLockProfile.mockHttpStatusCode, CMN_CreateEnterpriseCustomer.mockHttpStatus, CMN_CreateEnterpriseCustomer.mockHttpBody);
        
        Test.startTest();
        
        string response  = BCB_FlowController.invokeAccountLockProfile(lstofParticipants[0].Id);
        
        Test.stopTest();   
        Assert.areNotEqual(null,response,'It should Not be null');
    }
    
}