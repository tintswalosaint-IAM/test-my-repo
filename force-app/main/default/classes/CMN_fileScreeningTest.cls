/***************************************************************************************
@ Author            :jagadish thummala
@ Date              :May 2023
@ Name of the Class :CMN_fileScreeningTest
@description       :Test Class to validate the selected file for virus free.
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :20-07-2023
@ Modification Description : SFP-26350
***************************************************************************************/
@isTest
public class CMN_fileScreeningTest {
    /**
* @description TestMethod for CMN_fileScreening
*
*/
    @isTest static void verifySelectedFileTest() {
        
        List<Application_Participant__c> appList = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appList; 
        
        ContentVersion cv = BCB_DAL_TestFactory.createContentVersion();
        
        String str1 = EncodingUtil.base64Encode(cv.VersionData);
        cv.Description = str1;
        cv.Title = 'testimage.jpg';
        String str = '{"status":"SUCCESS"}';
        CMN_fileScreening.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_fileScreening.mockHttpStatus = 'OK';
        CMN_fileScreening.mockHttpbody = str;
        
        Test.startTest();
        String response = CMN_fileScreening.invocableMethodParticipantId(appList, new List<ContentVersion>{cv});
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserialize(response, Map<String, String>.class);
        
        cv.Title = 'testimage.pgm';
        CMN_fileScreening.invocableMethodParticipantId(appList, new List<ContentVersion>{cv});
        
        cv.Title = 'testimage.ppm';
        CMN_fileScreening.invocableMethodParticipantId(appList, new List<ContentVersion>{cv});
        Test.stopTest();
        
        Assert.areEqual((String) responseMap.get('status'), 'SUCCESS', 'Status Check');
    }
    /**
* @description TestMethod for CMN_fileScreening
*
*/
    
    @isTest static void verifySelectedFileTestFailure() {
        List<Application_Participant__c> appList = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appList; 
        
        ContentVersion cv = BCB_DAL_TestFactory.createContentVersion();
        
        String str1 = EncodingUtil.base64Encode(cv.VersionData);
        cv.Description = str1;
        cv.Title = 'testimage.png';
        String str = '{"status":"SUCCESS"}';
        CMN_fileScreening.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_fileScreening.mockHttpStatus = 'OK';
        CMN_fileScreening.mockHttpbody = str;
        
        Test.startTest();
        String response =  CMN_fileScreening.invocableMethodParticipantId(appList, new List<ContentVersion>{cv});
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserialize(response, Map<String, String>.class);
        Test.stopTest();
        
        Assert.areEqual((String) responseMap.get('status'), 'FAILED', 'Status Check');
    }
    /**
* @description TestMethod for CMN_fileScreening
*
*/
    @isTest static void verifySelectedFileTestException() {
        
        Test.startTest();
        try{
            CMN_fileScreening.invocableMethodParticipantId(null, null);
        } catch(Exception e) {
            Assert.isTrue(e.getMessage().contains('Attempt to de-reference a null object'), 'Exception Handling Check');
        }
        Test.stopTest();
    }
    /**
* @description TestMethod for CMN_fileScreening
*
*/
    @isTest static void verifySelectedFileTest1() {
        
        ContentVersion cv = BCB_DAL_TestFactory.createContentVersion();
        
        String str1 = EncodingUtil.base64Encode(cv.VersionData);
        cv.Description = str1;
        cv.Title = 'testimage.png';
        String str = '{"status":"SUCCESS"}';
        CMN_fileScreening.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_fileScreening.mockHttpStatus = 'OK';
        CMN_fileScreening.mockHttpbody = str;
        Test.startTest();
        String response = CMN_fileScreening.invocableMethodWithDocumentList(new List<ContentVersion>{cv});
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserialize(response, Map<String, String>.class);
        
        cv.Title = 'testimage.pgm';
        CMN_fileScreening.invocableMethodWithDocumentList(new List<ContentVersion>{cv});
        
        cv.Title = 'testimage.ppm';
        CMN_fileScreening.invocableMethodWithDocumentList(new List<ContentVersion>{cv});
        Test.stopTest();
        
        Assert.areEqual((String) responseMap.get('status'), 'FAILED', 'Status Check');
    }
}