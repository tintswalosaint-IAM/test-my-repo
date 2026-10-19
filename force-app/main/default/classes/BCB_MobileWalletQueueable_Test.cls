/***************************************************************************************
@ Author            :Lokesh Bothsa 
@ Date              :June 2023
@ Name of the Class :BCB_MobileWalletQueueable_Test
@description       :Test Class for BCB_MobileWalletQueueable
@ Story Number      :SFP-26348
***************************************************************************************/
@istest
public class BCB_MobileWalletQueueable_Test { 
    /**
* @description TestMethod for invoking BCB_MobileWalletQueueable_Test
*/
    @istest static void testCalloutMethod(){     
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
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
* @description TestMethod for invoking BCB_MobileWalletQueueable_Test
*/
    @istest static void testCalloutMethod1(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
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
* @description TestMethod for invoking BCB_MobileWalletQueueable_Test
*/
    @istest static void testCalloutMethod2(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
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
* @description TestMethod for invoking BCB_MobileWalletQueueable_Test
*/
    @istest static void testCalloutMethod3(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        insert lstApp;
        List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appParticipants;
        String str='{"customers": [{ "uuid": "","customerType": "CORPORATE","identifications": {"expirationDate": "","PreferredIdentificationIndicator": ""},"orgDetails": {"legalName": "TESTINGNEWCORP", "companyName": "TESTINGNEWCORP","orgEstablishDt": "", "numEmployees": "","fiscalYearEnd": "", "ownership": ""}, "contacts": [ { "value": "someone.testing@sbsa.co.za", "contactType": "EMAIL","preferredInd": "Y"}, { "value": "+256(0)345687667","phoneType": "PHONE", "preferredInd": "Y"}],"addresses": [{"uuid": "","addressTypes": [ {"addressTypes": "Swift"}],"startDate": "2023-07-03T00:00:00.000","line1": "lajdafisnofewiz, , ABIM,UG,256","city": "", "province": "EST","postalCode": "","countryCode": "","plotNumber": "",  "preferredInd": "" }, { "uuid": "", "addressTypes": [{ "addressTypes": "Registered"} ], "startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ", "city": "ABIM","province": "EST", "postalCode": "256", "countryCode": "UG", "plotNumber": "", "preferredInd": "N"}, { "uuid": "", "addressTypes": [ { "addressTypes": "Swift" } ], "startDate": "2023-07-03T00:00:00.000","line1": "lajdafisnofewiz, , ABIM,UG,256","city": "", "province": "EST", "postalCode": "", "countryCode": "","plotNumber": "", "preferredInd": "" }, { "uuid": "","addressTypes": [ { "addressTypes": "Registered" }],"startDate": "2023-06-22T00:00:00.000","line1": "lajdafisnofewiz, , ","city": "ABIM", "province": "EST","postalCode": "256", "countryCode": "UG", "plotNumber": "","preferredInd": "N"},{ "uuid": "","addressTypes": [ {  "addressTypes": "Mailing" }],"startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ","city": "ABIM","province": "EST","postalCode": "256","countryCode": "UG", "plotNumber": "", "preferredInd": "Y" }, { "uuid": "","addressTypes": [ { "addressTypes": "Mailing"}], "startDate": "2023-06-22T00:00:00.000", "line1": "lajdafisnofewiz ", "city": "ABIM", "province": "EST","postalCode": "256", "countryCode": "UG","plotNumber": "", "preferredInd": "Y"} ]}]}';
        CMN_GetCorporateCustomerList.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_GetCorporateCustomerList.mockHttpStatus='OK';
        CMN_GetCorporateCustomerList.mockHttpbody=str;
    }
    /**
* @description TestMethod for invoking BCB_MobileWalletQueueable_Test
*/
    @istest static void testCalloutMethod4(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
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
* @description TestMethod for invoking BCB_MobileWalletQueueable_Test
*/
    @istest static void testCalloutMethod5(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
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
* @description TestMethod for invoking BCB_MobileWalletQueueable_Test
*/
    @isTest
    static void getCorporateCustomerList(){
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        List<Application_Participant__c> applicationParticipationList=BCB_DAL_TestFactory.createApplicationParticipant(1);
        applicationList[0].AOB_BusinessLegalName__c = 'TESTINGCORP';
        insert applicationList;
        insert applicationParticipationList;
       
    }
}