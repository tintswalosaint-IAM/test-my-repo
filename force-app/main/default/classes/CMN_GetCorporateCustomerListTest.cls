/**
*@description TestClass for CMN_GetCorporateCustomerListTest
* @author Lokesh Bothsa 
* @date May 2023
* Story Number: SFP-27033
*/
@istest
public class CMN_GetCorporateCustomerListTest { 
    /**
* @description TestMethod for invoking Get CorporateCustomerList
*
*/
    @istest static void testCalloutMethod(){    
        BCB_CustomException unexpectedException;
        
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        lstApp[0].AOB_BusinessLegalName__c = 'TESTINGNEWCORP';
        insert lstApp;
        List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appParticipants;
        
        String str='{"customers": [{ "uuid": "20301168642","customerType": "CORPORATE","identifications": {"expirationDate": "","PreferredIdentificationIndicator": ""},"orgDetails": {"legalName": "TESTINGNEWCORP", "companyName": "TESTINGNEWCORP","orgEstablishDt": "", "numEmployees": "","fiscalYearEnd": "", "ownership": ""}, "contacts": [ { "value": "someone.testing@sbsa.co.za", "contactType": "EMAIL","preferredInd": "Y"}, { "value": "+256(0)345687667","phoneType": "PHONE", "preferredInd": "Y"}],"addresses": [{"uuid": "","addressTypes": [ {"addressTypes": "Swift"}],"startDate": "2023-07-03T00:00:00.000","line1": "lajdafisnofewiz, , ABIM,UG,256","city": "", "province": "EST","postalCode": "","countryCode": "","plotNumber": "",  "preferredInd": "" }, { "uuid": "", "addressTypes": [{ "addressTypes": "Registered"} ], "startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ", "city": "ABIM","province": "EST", "postalCode": "256", "countryCode": "UG", "plotNumber": "", "preferredInd": "N"}, { "uuid": "", "addressTypes": [ { "addressTypes": "Swift" } ], "startDate": "2023-07-03T00:00:00.000","line1": "lajdafisnofewiz, , ABIM,UG,256","city": "", "province": "EST", "postalCode": "", "countryCode": "","plotNumber": "", "preferredInd": "" }, { "uuid": "","addressTypes": [ { "addressTypes": "Registered" }],"startDate": "2023-06-22T00:00:00.000","line1": "lajdafisnofewiz, , ","city": "ABIM", "province": "EST","postalCode": "256", "countryCode": "UG", "plotNumber": "","preferredInd": "N"},{ "uuid": "","addressTypes": [ {  "addressTypes": "Mailing" }],"startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ","city": "ABIM","province": "EST","postalCode": "256","countryCode": "UG", "plotNumber": "", "preferredInd": "Y" }, { "uuid": "","addressTypes": [ { "addressTypes": "Mailing"}], "startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ", "city": "ABIM", "province": "EST","postalCode": "256", "countryCode": "UG","plotNumber": "", "preferredInd": "Y"} ]}]}';
        CMN_GetCorporateCustomerList.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_GetCorporateCustomerList.mockHttpStatus='OK';
        CMN_GetCorporateCustomerList.mockHttpbody=str;
        Test.startTest();
        
        String repStatus = CMN_GetCorporateCustomerList.invocableMethod(lstApp,appParticipants[0]);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        Assert.areNotEqual(null, m,'Test');
    }
    /**
* @description TestMethod for invoking Get CorporateCustomerList
*
*/
    @istest static void testCalloutMethod1(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        lstApp[0].AOB_BusinessLegalName__c = 'TESTINGNEWCORP';
        insert lstApp;
        List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appParticipants;
        String str='{"customers": [{ "uuid": "","customerType": "CORPORATE","identifications": {"expirationDate": "","PreferredIdentificationIndicator": ""},"orgDetails": {"legalName": "TESTINGNEWCORP", "companyName": "TESTINGNEWCORP","orgEstablishDt": "", "numEmployees": "","fiscalYearEnd": "", "ownership": ""}, "contacts": [ { "value": "someone.testing@sbsa.co.za", "contactType": "EMAIL","preferredInd": "Y"}, { "value": "+256(0)345687667","phoneType": "PHONE", "preferredInd": "Y"}],"addresses": [{"uuid": "","addressTypes": [ {"addressTypes": "Swift"}],"startDate": "2023-07-03T00:00:00.000","line1": "lajdafisnofewiz, , ABIM,UG,256","city": "", "province": "EST","postalCode": "","countryCode": "","plotNumber": "",  "preferredInd": "" }, { "uuid": "", "addressTypes": [{ "addressTypes": "Registered"} ], "startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ", "city": "ABIM","province": "EST", "postalCode": "256", "countryCode": "UG", "plotNumber": "", "preferredInd": "N"}, { "uuid": "", "addressTypes": [ { "addressTypes": "Swift" } ], "startDate": "2023-07-03T00:00:00.000","line1": "lajdafisnofewiz, , ABIM,UG,256","city": "", "province": "EST", "postalCode": "", "countryCode": "","plotNumber": "", "preferredInd": "" }, { "uuid": "","addressTypes": [ { "addressTypes": "Registered" }],"startDate": "2023-06-22T00:00:00.000","line1": "lajdafisnofewiz, , ","city": "ABIM", "province": "EST","postalCode": "256", "countryCode": "UG", "plotNumber": "","preferredInd": "N"},{ "uuid": "","addressTypes": [ {  "addressTypes": "Mailing" }],"startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ","city": "ABIM","province": "EST","postalCode": "256","countryCode": "UG", "plotNumber": "", "preferredInd": "Y" }, { "uuid": "","addressTypes": [ { "addressTypes": "Mailing"}], "startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ", "city": "ABIM", "province": "EST","postalCode": "256", "countryCode": "UG","plotNumber": "", "preferredInd": "Y"} ]}]}';
        CMN_GetCorporateCustomerList.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_GetCorporateCustomerList.mockHttpStatus='OK';
        CMN_GetCorporateCustomerList.mockHttpbody=str;
        Test.startTest();
        String repStatus = CMN_GetCorporateCustomerList.invocableMethod(lstApp,appParticipants[0]);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        Assert.areNotEqual(null, m,'Test');
    }
    /**
* @description TestMethod for invoking Get CorporateCustomerList
*
*/
    @istest static void testCalloutMethod2(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        lstApp[0].AOB_BusinessLegalName__c = 'TESTINGNEWCORP';
        insert lstApp;
        List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appParticipants;
        String str='{"customers": [{ "uuid": "","customerType": "CORPORATE","identifications": {"expirationDate": "","PreferredIdentificationIndicator": ""},"orgDetails": {"legalName": "TESTINGNEWCORP", "companyName": "TESTINGNEWCORP","orgEstablishDt": "", "numEmployees": "","fiscalYearEnd": "", "ownership": ""}, "contacts": [ { "value": "someone.testing@sbsa.co.za", "contactType": "EMAIL","preferredInd": "Y"}, { "value": "+256(0)345687667","phoneType": "PHONE", "preferredInd": "Y"}],"addresses": [{"uuid": "","addressTypes": [ {"addressTypes": "Swift"}],"startDate": "2023-07-03T00:00:00.000","line1": "lajdafisnofewiz, , ABIM,UG,256","city": "", "province": "EST","postalCode": "","countryCode": "","plotNumber": "",  "preferredInd": "" }, { "uuid": "", "addressTypes": [{ "addressTypes": "Registered"} ], "startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ", "city": "ABIM","province": "EST", "postalCode": "256", "countryCode": "UG", "plotNumber": "", "preferredInd": "N"}, { "uuid": "", "addressTypes": [ { "addressTypes": "Swift" } ], "startDate": "2023-07-03T00:00:00.000","line1": "lajdafisnofewiz, , ABIM,UG,256","city": "", "province": "EST", "postalCode": "", "countryCode": "","plotNumber": "", "preferredInd": "" }, { "uuid": "","addressTypes": [ { "addressTypes": "Registered" }],"startDate": "2023-06-22T00:00:00.000","line1": "lajdafisnofewiz, , ","city": "ABIM", "province": "EST","postalCode": "256", "countryCode": "UG", "plotNumber": "","preferredInd": "N"},{ "uuid": "","addressTypes": [ {  "addressTypes": "Mailing" }],"startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ","city": "ABIM","province": "EST","postalCode": "256","countryCode": "UG", "plotNumber": "", "preferredInd": "Y" }, { "uuid": "","addressTypes": [ { "addressTypes": "Mailing"}], "startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ", "city": "ABIM", "province": "EST","postalCode": "256", "countryCode": "UG","plotNumber": "", "preferredInd": "Y"} ]}]}';
        CMN_GetCorporateCustomerList.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_GetCorporateCustomerList.mockHttpStatus='OK';
        CMN_GetCorporateCustomerList.mockHttpbody=str;
        Test.startTest();
        String repStatus = CMN_GetCorporateCustomerList.invocableMethod(lstApp,appParticipants[0]);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        Assert.areNotEqual(null, m,'Test');
    }
    /**
* @description TestMethod for invoking CorporateCustomerList
*
*/
    @istest static void testCalloutMethod3(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        lstApp[0].AOB_BusinessLegalName__c = 'TESTINGNEWCORP';
        insert lstApp;
        List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appParticipants;
        String str='{"customers": [{ "uuid": "","customerType": "CORPORATE","identifications": {"expirationDate": "","PreferredIdentificationIndicator": ""},"orgDetails": {"legalName": "TESTINGNEWCORP", "companyName": "TESTINGNEWCORP","orgEstablishDt": "", "numEmployees": "","fiscalYearEnd": "", "ownership": ""}, "contacts": [ { "value": "someone.testing@sbsa.co.za", "contactType": "EMAIL","preferredInd": "Y"}, { "value": "+256(0)345687667","phoneType": "PHONE", "preferredInd": "Y"}],"addresses": [{"uuid": "","addressTypes": [ {"addressTypes": "Swift"}],"startDate": "2023-07-03T00:00:00.000","line1": "lajdafisnofewiz, , ABIM,UG,256","city": "", "province": "EST","postalCode": "","countryCode": "","plotNumber": "",  "preferredInd": "" }, { "uuid": "", "addressTypes": [{ "addressTypes": "Registered"} ], "startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ", "city": "ABIM","province": "EST", "postalCode": "256", "countryCode": "UG", "plotNumber": "", "preferredInd": "N"}, { "uuid": "", "addressTypes": [ { "addressTypes": "Swift" } ], "startDate": "2023-07-03T00:00:00.000","line1": "lajdafisnofewiz, , ABIM,UG,256","city": "", "province": "EST", "postalCode": "", "countryCode": "","plotNumber": "", "preferredInd": "" }, { "uuid": "","addressTypes": [ { "addressTypes": "Registered" }],"startDate": "2023-06-22T00:00:00.000","line1": "lajdafisnofewiz, , ","city": "ABIM", "province": "EST","postalCode": "256", "countryCode": "UG", "plotNumber": "","preferredInd": "N"},{ "uuid": "","addressTypes": [ {  "addressTypes": "Mailing" }],"startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ","city": "ABIM","province": "EST","postalCode": "256","countryCode": "UG", "plotNumber": "", "preferredInd": "Y" }, { "uuid": "","addressTypes": [ { "addressTypes": "Mailing"}], "startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ", "city": "ABIM", "province": "EST","postalCode": "256", "countryCode": "UG","plotNumber": "", "preferredInd": "Y"} ]}]}';
        CMN_GetCorporateCustomerList.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_GetCorporateCustomerList.mockHttpStatus='OK';
        CMN_GetCorporateCustomerList.mockHttpbody=str;
        Test.startTest();
        String repStatus = CMN_GetCorporateCustomerList.invocableMethod(lstApp,appParticipants[0]);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        Assert.areNotEqual(null, m,'Test');
    }
    /**
* @description TestMethod for invoking CorporateCustomerList
*
*/
    @istest static void testCalloutMethod4(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        lstApp[0].AOB_BusinessLegalName__c = 'TESTINGNEWCORP';
        insert lstApp;
        List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appParticipants;
        CMN_GetCorporateCustomerList.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_GetCorporateCustomerList.mockHttpStatus='FAILED';
        CMN_GetCorporateCustomerList.mockHttpbody='';
        Test.startTest();
        String repStatus = CMN_GetCorporateCustomerList.invocableMethod(lstApp,appParticipants[0]);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        Assert.areNotEqual(null, m,'Test');
    }
    /**
* @description TestMethod for invoking CorporateCustomerList
*
*/
    @istest static void testCalloutMethod5(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        lstApp[0].AOB_BusinessLegalName__c = 'TESTINGNEWCORP';
        insert lstApp;
        List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appParticipants;
        CMN_GetCorporateCustomerList.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_GetCorporateCustomerList.mockHttpStatus='OK';
        CMN_GetCorporateCustomerList.mockHttpbody='';
        Test.startTest();
        String repStatus = CMN_GetCorporateCustomerList.invocableMethod(lstApp,appParticipants[0]);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        Assert.areNotEqual(null, m,'Test');
    }
    /**
* @description TestMethod for invoking CorporateCustomerList
*
*/
    @isTest
    static void getCorporateCustomerList(){
        lead l = BCB_DAL_TestFactory.createLead();
        insert l;
            
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        applicationList[0].AOB_Lead__c = l.id;
        
        List<Application_Participant__c> applicationParticipationList=BCB_DAL_TestFactory.createApplicationParticipant(1);
        applicationList[0].AOB_BusinessLegalName__c = 'TESTINGCORP';
        
        insert applicationList;
        applicationParticipationList[0].Application__c = applicationList[0].Id;
        String str='{"customers": [{ "uuid": "12423554","customerType": "CORPORATE","identifications": {"expirationDate": "","PreferredIdentificationIndicator": ""},"orgDetails": {"legalName": "TESTINGNEWCORP", "companyName": "TESTINGNEWCORP","orgEstablishDt": "", "numEmployees": "","fiscalYearEnd": "", "ownership": ""}, "contacts": [ { "value": "someone.testing@sbsa.co.za", "contactType": "EMAIL","preferredInd": "Y"}, { "value": "+256(0)345687667","phoneType": "PHONE", "preferredInd": "Y"}],"addresses": [{"uuid": "12425","addressTypes": [ {"addressTypes": "Swift"}],"startDate": "2023-07-03T00:00:00.000","line1": "lajdafisnofewiz, , ABIM,UG,256","city": "", "province": "EST","postalCode": "","countryCode": "","plotNumber": "",  "preferredInd": "" }, { "uuid": "12345678", "addressTypes": [{ "addressTypes": "Registered"} ], "startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ", "city": "ABIM","province": "EST", "postalCode": "256", "countryCode": "UG", "plotNumber": "", "preferredInd": "N"}, { "uuid": "2123244", "addressTypes": [ { "addressTypes": "Swift" } ], "startDate": "2023-07-03T00:00:00.000","line1": "lajdafisnofewiz, , ABIM,UG,256","city": "", "province": "EST", "postalCode": "", "countryCode": "","plotNumber": "", "preferredInd": "" }, { "uuid": "","addressTypes": [ { "addressTypes": "Registered" }],"startDate": "2023-06-22T00:00:00.000","line1": "lajdafisnofewiz, , ","city": "ABIM", "province": "EST","postalCode": "256", "countryCode": "UG", "plotNumber": "","preferredInd": "N"},{ "uuid": "","addressTypes": [ {  "addressTypes": "Mailing" }],"startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ","city": "ABIM","province": "EST","postalCode": "256","countryCode": "UG", "plotNumber": "", "preferredInd": "Y" }, { "uuid": "","addressTypes": [ { "addressTypes": "Mailing"}], "startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ", "city": "ABIM", "province": "EST","postalCode": "256", "countryCode": "UG","plotNumber": "", "preferredInd": "Y"} ]}]}';
        CMN_GetCorporateCustomerList.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_GetCorporateCustomerList.mockHttpStatus='OK';
        CMN_GetCorporateCustomerList.mockHttpbody=str;
        Test.startTest();
        String repStatus = CMN_GetCorporateCustomerList.invocableMethod(applicationList,applicationParticipationList[0]);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        
        System.enqueueJob(new BCB_GetCorporateCustomer(applicationParticipationList[0],applicationList[0]));
        
        Test.stopTest();
        Assert.areNotEqual(null, m,'Test');
    }
    /**
* @description TestMethod for invoking CorporateCustomerList
*
*/
    @istest static void testCalloutMethod8(){    
        
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        List<Application_Participant__c> applicationParticipationList=BCB_DAL_TestFactory.createApplicationParticipant(1);
        applicationList[0].AOB_BusinessLegalName__c = 'TESTINGNEWCORP';
        insert applicationList;
        List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appParticipants;
        CMN_GetCorporateCustomerList.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_GetCorporateCustomerList.mockHttpStatus='FAILED';
        CMN_GetCorporateCustomerList.mockHttpbody='';
        Test.startTest();
        String repStatus = CMN_GetCorporateCustomerList.invocableMethod(applicationList,appParticipants[0]);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        try{
            
        }catch(Exception ex){
            System.enqueueJob(new BCB_GetCorporateCustomer(applicationParticipationList[0],applicationList[0]));
        }
        
        Test.stopTest();
        Assert.areNotEqual(null, m,'Test');
    }
    /**
* @description TestMethod for invoking CorporateCustomerList
*
*/
    @istest static void testCalloutMethod9(){    
        lead l = BCB_DAL_TestFactory.createLead();
        insert l;
        
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        applicationList[0].AOB_Lead__c = l.id;
        
        List<Application_Participant__c> applicationParticipationList=BCB_DAL_TestFactory.createApplicationParticipant(1);
        applicationList[0].AOB_BusinessLegalName__c = 'TESTINGNEWCORP';
        insert applicationList;
        List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appParticipants;
        CMN_GetCorporateCustomerList.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_GetCorporateCustomerList.mockHttpStatus='FAILED';
        CMN_GetCorporateCustomerList.mockHttpbody='';
        Test.startTest();
        String repStatus = CMN_GetCorporateCustomerList.invocableMethod(applicationList,appParticipants[0]);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        System.enqueueJob(new BCB_GetCorporateCustomer(applicationParticipationList[0],applicationList[0]));
        Test.stopTest();
        Assert.areNotEqual(null, m,'Test');
    }
    /**
* @description TestMethod for invoking CorporateCustomerList
*
*/
    @istest static void testCalloutMethod10(){    
        lead l = BCB_DAL_TestFactory.createLead();
        insert l;
        
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        applicationList[0].AOB_Lead__c = l.id;
        
        List<Application_Participant__c> applicationParticipationList=BCB_DAL_TestFactory.createApplicationParticipant(1);
        applicationList[0].AOB_BusinessLegalName__c = 'TESTINGNEWCORP';
        insert applicationList;
        List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appParticipants;
        CMN_GetCorporateCustomerList.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_GetCorporateCustomerList.mockHttpStatus='OK';
        CMN_GetCorporateCustomerList.mockHttpbody='{"customers": [{ "uuid": "","customerType": "CORPORATE","identifications": {"expirationDate": "","PreferredIdentificationIndicator": ""},"orgDetails": {"legalName": "TESTINGNEWCORP", "companyName": "TESTINGNEWCORP","orgEstablishDt": "", "numEmployees": "","fiscalYearEnd": "", "ownership": ""}, "contacts": [ { "value": "someone.testing@sbsa.co.za", "contactType": "EMAIL","preferredInd": "Y"}, { "value": "+256(0)345687667","phoneType": "PHONE", "preferredInd": "Y"}],"addresses": [{"uuid": "12425","addressTypes": [ {"addressTypes": "Swift"}],"startDate": "2023-07-03T00:00:00.000","line1": "lajdafisnofewiz, , ABIM,UG,256","city": "", "province": "EST","postalCode": "","countryCode": "","plotNumber": "",  "preferredInd": "" }, { "uuid": "12345678", "addressTypes": [{ "addressTypes": "Registered"} ], "startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ", "city": "ABIM","province": "EST", "postalCode": "256", "countryCode": "UG", "plotNumber": "", "preferredInd": "N"}, { "uuid": "2123244", "addressTypes": [ { "addressTypes": "Swift" } ], "startDate": "2023-07-03T00:00:00.000","line1": "lajdafisnofewiz, , ABIM,UG,256","city": "", "province": "EST", "postalCode": "", "countryCode": "","plotNumber": "", "preferredInd": "" }, { "uuid": "","addressTypes": [ { "addressTypes": "Registered" }],"startDate": "2023-06-22T00:00:00.000","line1": "lajdafisnofewiz, , ","city": "ABIM", "province": "EST","postalCode": "256", "countryCode": "UG", "plotNumber": "","preferredInd": "N"},{ "uuid": "","addressTypes": [ {  "addressTypes": "Mailing" }],"startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ","city": "ABIM","province": "EST","postalCode": "256","countryCode": "UG", "plotNumber": "", "preferredInd": "Y" }, { "uuid": "","addressTypes": [ { "addressTypes": "Mailing"}], "startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ", "city": "ABIM", "province": "EST","postalCode": "256", "countryCode": "UG","plotNumber": "", "preferredInd": "Y"} ]}]}';
        Test.startTest();
        String repStatus = CMN_GetCorporateCustomerList.invocableMethod(applicationList,appParticipants[0]);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        System.enqueueJob(new BCB_GetCorporateCustomer(applicationParticipationList[0],applicationList[0]));
        Test.stopTest();
        Assert.areNotEqual(null, m,'Test');
    }
    /**
* @description TestMethod for invoking CorporateCustomerList
*
*/
    @istest static void testCalloutMethod11(){  
        try{
            List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
            List<Application_Participant__c> applicationParticipationList=BCB_DAL_TestFactory.createApplicationParticipant(1);
            applicationList[0].AOB_BusinessLegalName__c = 'TESTINGNEWCORP';
            insert applicationList;
            List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
            insert appParticipants;
            CMN_GetCorporateCustomerList.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
            CMN_GetCorporateCustomerList.mockHttpStatus='OK';
            CMN_GetCorporateCustomerList.mockHttpbody='{"customers": [{ "uuid": "","customerType": "CORPORATE","identifications": {"expirationDate": "","PreferredIdentificationIndicator": ""},"orgDetails": {"legalName": "TESTINGNEWCORP", "companyName": "TESTINGNEWCORP","orgEstablishDt": "", "numEmployees": "","fiscalYearEnd": "", "ownership": ""}, "contacts": [ { "value": "someone.testing@sbsa.co.za", "contactType": "EMAIL","preferredInd": "Y"}, { "value": "+256(0)345687667","phoneType": "PHONE", "preferredInd": "Y"}],"addresses": [{"uuid": "12425","addressTypes": [ {"addressTypes": "Swift"}],"startDate": "2023-07-03T00:00:00.000","line1": "lajdafisnofewiz, , ABIM,UG,256","city": "", "province": "EST","postalCode": "","countryCode": "","plotNumber": "",  "preferredInd": "" }, { "uuid": "12345678", "addressTypes": [{ "addressTypes": "Registered"} ], "startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ", "city": "ABIM","province": "EST", "postalCode": "256", "countryCode": "UG", "plotNumber": "", "preferredInd": "N"}, { "uuid": "2123244", "addressTypes": [ { "addressTypes": "Swift" } ], "startDate": "2023-07-03T00:00:00.000","line1": "lajdafisnofewiz, , ABIM,UG,256","city": "", "province": "EST", "postalCode": "", "countryCode": "","plotNumber": "", "preferredInd": "" }, { "uuid": "","addressTypes": [ { "addressTypes": "Registered" }],"startDate": "2023-06-22T00:00:00.000","line1": "lajdafisnofewiz, , ","city": "ABIM", "province": "EST","postalCode": "256", "countryCode": "UG", "plotNumber": "","preferredInd": "N"},{ "uuid": "","addressTypes": [ {  "addressTypes": "Mailing" }],"startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ","city": "ABIM","province": "EST","postalCode": "256","countryCode": "UG", "plotNumber": "", "preferredInd": "Y" }, { "uuid": "","addressTypes": [ { "addressTypes": "Mailing"}], "startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ", "city": "ABIM", "province": "EST","postalCode": "256", "countryCode": "UG","plotNumber": "", "preferredInd": "Y"} ]}]}';
            Test.startTest();
            String repStatus = CMN_GetCorporateCustomerList.invocableMethod(applicationList,appParticipants[0]);
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            System.enqueueJob(new BCB_GetCorporateCustomer(null,null));
            Test.stopTest();    
        }catch(exception dmx){
            Assert.areNotEqual(null, dmx.getMessage());
        }     
        
        
    }
    /**
* @description TestMethod for invoking CorporateCustomerList
*
*/
    @isTest
    public static void testParsingJsonString() {
        String jsonString = '{"customers": [{ "uuid": "20301168642", "customerType": "CORPORATE", "identifications": { "expirationDate": "", "PreferredIdentificationIndicator": "" }, "orgDetails": { "legalName": "TESTINGNEWCORP", "companyName": "TESTINGNEWCORP", "orgEstablishDt": "", "numEmployees": "", "fiscalYearEnd": "", "ownership": "" }, "contacts": [ { "value": "someone.testing@sbsa.co.za", "contactType": "EMAIL", "preferredInd": "Y" }, { "value": "+256(0)345687667", "phoneType": "PHONE", "preferredInd": "Y" } ], "addresses": [{ "uuid": "", "addressTypes": [{ "addressTypes": "Swift" }], "startDate": "2023-07-03T00:00:00.000", "line1": "lajdafisnofewiz, , ABIM,UG,256", "city": "", "province": "EST", "postalCode": "", "countryCode": "", "plotNumber": "", "preferredInd": "" }, { "uuid": "", "addressTypes": [{ "addressTypes": "Registered" }], "startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ", "city": "ABIM", "province": "EST", "postalCode": "256", "countryCode": "UG", "plotNumber": "", "preferredInd": "N" }, { "uuid": "", "addressTypes": [{ "addressTypes": "Swift" }], "startDate": "2023-07-03T00:00:00.000", "line1": "lajdafisnofewiz, , ABIM,UG,256", "city": "", "province": "EST", "postalCode": "", "countryCode": "", "plotNumber": "", "preferredInd": "" }, { "uuid": "", "addressTypes": [{ "addressTypes": "Registered" }], "startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz, , ", "city": "ABIM", "province": "EST", "postalCode": "256", "countryCode": "UG", "plotNumber": "", "preferredInd": "N" }, { "uuid": "", "addressTypes": [{ "addressTypes": "Mailing" }], "startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ", "city": "ABIM", "province": "EST", "postalCode": "256", "countryCode": "UG", "plotNumber": "", "preferredInd": "Y" }, { "uuid": "", "addressTypes": [{ "addressTypes": "Mailing" }], "startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ", "city": "ABIM", "province": "EST", "postalCode": "256", "countryCode": "UG", "plotNumber": "", "preferredInd": "Y" }] }]}';
        BCB_CorporateCustomerListBean data = (BCB_CorporateCustomerListBean) JSON.deserialize(jsonString, BCB_CorporateCustomerListBean.class);
        Assert.areEqual(1, data.customers.size(), 'There should be exactly one customer in the list');
        BCB_CorporateCustomerListBean.Customers customer = data.customers[0];
        Assert.areNotEqual(null, customer.uuid, 'UUID should not be null');
        Assert.areEqual('20301168642', customer.uuid, 'UUID should match the provided value');
        Assert.areEqual('CORPORATE', customer.customerType, 'Customer type should be CORPORATE');
        Assert.areEqual('', customer.identifications.expirationDate, 'Expiration date should be empty');
        Assert.areEqual('', customer.identifications.PreferredIdentificationIndicator, 'PreferredIdentificationIndicator should be empty');
        Assert.areEqual('TESTINGNEWCORP', customer.orgDetails.legalName, 'Legal name should match the provided value');
        Assert.areEqual('TESTINGNEWCORP', customer.orgDetails.companyName, 'Company name should match the provided value');
        Assert.areEqual(2, customer.contacts.size(), 'There should be exactly two contacts');
        Assert.areEqual('someone.testing@sbsa.co.za', customer.contacts[0].value, 'First contact email should match the provided value');
        Assert.areEqual('EMAIL', customer.contacts[0].contactType, 'First contact type should be EMAIL');
        Assert.areEqual('Y', customer.contacts[0].preferredInd, 'First contact preferredInd should be Y');
        Assert.areEqual('+256(0)345687667', customer.contacts[1].value, 'Second contact phone should match the provided value');
        Assert.areEqual('Y', customer.contacts[1].preferredInd, 'Second contact preferredInd should be Y');
        Assert.areEqual(6, customer.addresses.size(), 'There should be exactly six addresses');
        Assert.areEqual('', customer.addresses[0].uuid, 'UUID for the first address should be empty');
        Assert.areEqual('Swift', customer.addresses[0].addressTypes[0].addressTypes, 'Address type for the first address should be Swift');
    } 
}