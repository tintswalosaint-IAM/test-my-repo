/***************************************************************************************
@ Author            :Amarnath Reddy(amarnath.reddy@standardbank.co.za)
@ Date              :june 2022
@ Name of the Class :AOB_SanctionScreen
@ Description       :Test class  for AOB_SanctionScreen
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :20-03-2024
@ Modification Description : SFP-31036
***************************************************************************************/
 /** 
 * @description Test class  for AOB_SanctionScreen
*/
@isTest
public class AOB_SanctionScreenTest {
    /** 
    * @description testMethod to check the success state of response.
    */
        @isTest static void testSuccessState(){
        List<Application__c> applicationList=AOB_TestDataFactory.createApplication(1);
        insert applicationList;
        string mockResponse='{"caseId":"5jb8f6g8q9zj1guky6czii2t7","name":"Leku Joel","providerTypes":["WATCHLIST"],"customFields":[],"secondaryFields":[],"groupId":"5jb75gv0cn6q1g4q4u0643299","entityType":"INDIVIDUAL","caseSystemId":"5jb8f6g8q9zj1guky6czii2t8","caseScreeningState":{"WATCHLIST":"INITIAL"},"lifecycleState":"UNARCHIVED","creator":{"userId":"5jb75ituimr11g17bymq564i1","firstName":"Walusimbi Katungi","lastName":"Nina","fullName":"Walusimbi Katungi Nina","email":"katungin@stanbic.com","status":"ACTIVE"},"modifier":{"userId":"5jb75ituimr11g17bymq564i1","firstName":"Walusimbi Katungi","lastName":"Nina","fullName":"Walusimbi Katungi Nina","email":"katungin@stanbic.com","status":"ACTIVE"},"assignee":null,"creationDate":"2022-07-22T07:00:45.917Z","modificationDate":"2022-07-22T07:00:49.020Z","nameTransposition":false,"outstandingActions":true,"results":[{"resultId":"5jb7ukkmdn291guky6iwoh1tz","referenceId":"e_tr_wci_6581204","matchScore":89.97,"matchStrength":"EXACT", "matchedTerm":"Joel LEKU","matchedTerms":[{"term":"Joel LEKU","type":"PRIMARY"}],"submittedTerm":"Leku Joel","matchedNameType":"PRIMARY","secondaryFieldResults":[],"sources":["b_trwc_PEP N"],"categories":["PEP","Regulatory Enforcement","Sanctions"],"creationDate":"2022-07-22T07:00:49.018Z","modificationDate":"2022-07-22T07:00:49.018Z","lastAlertDate":"2022-07-22T07:00:49.021Z","resolution":null,"resultReview":{"reviewRequired":false,"reviewRequiredDate":"2021-09-03T00:00:00.000Z","reviewRemark":null,"reviewDate":null},"primaryName":"Joel LEKU","events":[],"countryLinks":[{"country":{"code":"UGA","name":"UGANDA"},"countryText":"UGANDA","type":"NATIONALITY"},{"country":{"code":"UGA","name":"UGANDA"},"countryText":"UGANDA","type":"LOCATION"}],"identityDocuments":[],"category":"POLITICAL INDIVIDUAL","providerType":"WATCHLIST","gender":"MALE","entityCreationDate":"2021-08-02T00:00:00.000Z","entityModificationDate":"2021-09-03T00:00:00.000Z","pepStatus":"ACTIVE"}]}';
        AOB_SanctionScreen.mockHttpStatusCode =CMN_API_HttpBase.HTTP_OK;
        AOB_SanctionScreen.mockHttpStatus ='OK';
        AOB_SanctionScreen.mockHttpbody = mockResponse;
        test.startTest();
        string repStatus = AOB_SanctionScreen.invokeSanctionScreening(applicationList); 
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        test.stopTest();    
        Assert.areEqual((String)m.get('status'), 'SUCCESS' ,'It will return status');
    }     
    /** 
    * @description testMethod to check the success state of response.
    */
     @isTest  static  void testSuccessStatus(){
        List<Application__c> applicationList=AOB_TestDataFactory.createApplication(1);
        insert applicationList;
        string mockResponse='{"caseId":"5jb8f6g8q9zj1guky6czii2t7","name":"Leku Joel","providerTypes":["WATCHLIST"],"customFields":[],"secondaryFields":[],"groupId":"5jb75gv0cn6q1g4q4u0643299","entityType":"INDIVIDUAL","caseSystemId":"5jb8f6g8q9zj1guky6czii2t8","caseScreeningState":{"WATCHLIST":"INITIAL"},"lifecycleState":"UNARCHIVED","creator":{"userId":"5jb75ituimr11g17bymq564i1","firstName":"Walusimbi Katungi","lastName":"Nina","fullName":"Walusimbi Katungi Nina","email":"katungin@stanbic.com","status":"ACTIVE"},"modifier":{"userId":"5jb75ituimr11g17bymq564i1","firstName":"Walusimbi Katungi","lastName":"Nina","fullName":"Walusimbi Katungi Nina","email":"katungin@stanbic.com","status":"ACTIVE"},"assignee":null,"creationDate":"2022-07-22T07:00:45.917Z","modificationDate":"2022-07-22T07:00:49.020Z","nameTransposition":false,"outstandingActions":true,"results":[{"resultId":"5jb7ukkmdn291guky6iwoh1tz","referenceId":"e_tr_wci_6581204","matchScore":89.97,"matchStrength":"EXACT", "matchedTerm":"Joel LEKU","matchedTerms":[{"term":"Joel LEKU","type":"PRIMARY"}],"submittedTerm":"Leku Joel","matchedNameType":"PRIMARY","secondaryFieldResults":[],"sources":["b_trwc_PEP N"],"categories":["Regulatory Enforcement","Sanctions"],"creationDate":"2022-07-22T07:00:49.018Z","modificationDate":"2022-07-22T07:00:49.018Z","lastAlertDate":"2022-07-22T07:00:49.021Z","resolution":null,"resultReview":{"reviewRequired":false,"reviewRequiredDate":"2021-09-03T00:00:00.000Z","reviewRemark":null,"reviewDate":null},"primaryName":"Joel LEKU","events":[],"countryLinks":[{"country":{"code":"UGA","name":"UGANDA"},"countryText":"UGANDA","type":"NATIONALITY"},{"country":{"code":"UGA","name":"UGANDA"},"countryText":"UGANDA","type":"LOCATION"}],"identityDocuments":[],"category":"POLITICAL INDIVIDUAL","providerType":"WATCHLIST","gender":"MALE","entityCreationDate":"2021-08-02T00:00:00.000Z","entityModificationDate":"2021-09-03T00:00:00.000Z","pepStatus":"ACTIVE"}]}';
        AOB_SanctionScreen.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_SanctionScreen.mockHttpStatus ='OK';
        AOB_SanctionScreen.mockHttpbody = mockResponse;
        test.startTest();
        string repStatus = AOB_SanctionScreen.invokeSanctionScreening(applicationList); 
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        test.stopTest();       
        Assert.areEqual((String)m.get('status'), 'SUCCESS' , 'It will return status');
    }
    /** 
    * @description testMethod to cover the no Response state.
    */
     @isTest static void testNoResponseState(){  
        List<Application__c> applicationList=AOB_TestDataFactory.createApplication(1);
        insert applicationList;
        string mockResponse = null;
        AOB_SanctionScreen.mockHttpStatusCode =CMN_API_HttpBase.HTTP_OK;
        AOB_SanctionScreen.mockHttpStatus ='OK';
        AOB_SanctionScreen.mockHttpbody = mockResponse;
        test.startTest();
       AOB_SanctionScreen.invokeSanctionScreening(applicationList); 
        test.stopTest();
        Assert.areEqual(null,null,'No Response');            
    }  
    /** 
    * @description testMethod to cover the Failed Response.
    */
     @isTest  static  void testFailedStatus(){
        List<Application__c> applicationList=AOB_TestDataFactory.createApplication(1);
        insert applicationList;
        string mockResponse='{"caseId":"5jb8f6g8q9zj1guky6czii2t7","name":"Leku Joel","providerTypes":["WATCHLIST"],"customFields":[],"secondaryFields":[],"groupId":"5jb75gv0cn6q1g4q4u0643299","entityType":"INDIVIDUAL","caseSystemId":"5jb8f6g8q9zj1guky6czii2t8","caseScreeningState":{"WATCHLIST":"INITIAL"},"lifecycleState":"UNARCHIVED","creator":{"userId":"5jb75ituimr11g17bymq564i1","firstName":"Walusimbi Katungi","lastName":"Nina","fullName":"Walusimbi Katungi Nina","email":"katungin@stanbic.com","status":"ACTIVE"},"modifier":{"userId":"5jb75ituimr11g17bymq564i1","firstName":"Walusimbi Katungi","lastName":"Nina","fullName":"Walusimbi Katungi Nina","email":"katungin@stanbic.com","status":"ACTIVE"},"assignee":null,"creationDate":"2022-07-22T07:00:45.917Z","modificationDate":"2022-07-22T07:00:49.020Z","nameTransposition":false,"outstandingActions":true,"results":[{"resultId":"5jb7ukkmdn291guky6iwoh1tz","referenceId":"e_tr_wci_6581204","matchScore":89.97,"matchStrength":"EXACT", "matchedTerm":"Joel LEKU","matchedTerms":[{"term":"Joel LEKU","type":"PRIMARY"}],"submittedTerm":"Leku Joel","matchedNameType":"PRIMARY","secondaryFieldResults":[],"sources":["b_trwc_PEP N"],"categories":["Regulatory Enforcement","Sanctions"],"creationDate":"2022-07-22T07:00:49.018Z","modificationDate":"2022-07-22T07:00:49.018Z","lastAlertDate":"2022-07-22T07:00:49.021Z","resolution":null,"resultReview":{"reviewRequired":false,"reviewRequiredDate":"2021-09-03T00:00:00.000Z","reviewRemark":null,"reviewDate":null},"primaryName":"Joel LEKU","events":[],"countryLinks":[{"country":{"code":"UGA","name":"UGANDA"},"countryText":"UGANDA","type":"NATIONALITY"},{"country":{"code":"UGA","name":"UGANDA"},"countryText":"UGANDA","type":"LOCATION"}],"identityDocuments":[],"category":"POLITICAL INDIVIDUAL","providerType":"WATCHLIST","gender":"MALE","entityCreationDate":"2021-08-02T00:00:00.000Z","entityModificationDate":"2021-09-03T00:00:00.000Z","pepStatus":"ACTIVE"}]}';
        AOB_SanctionScreen.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        AOB_SanctionScreen.mockHttpStatus ='OK';
        AOB_SanctionScreen.mockHttpbody = mockResponse;
        test.startTest();
        string repStatus = AOB_SanctionScreen.invokeSanctionScreening(applicationList); 
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        test.stopTest();       
        Assert.areEqual((String)m.get('status'), 'FAILED' , 'It will return status');
    }
         
}