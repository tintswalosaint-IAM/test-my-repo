/***************************************************************************************
@ Author            :AmarNath Reddy
@ Date              :May 2022
@ Name of the Class :AOB_SelfRegistrationTest
@description       :Class for test code coverage of AOB_SelfRegistration
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :29-03-2024
@ Modification Description : SFP-31036
***************************************************************************************/
/** 
*@description Test class for AOB_SelfRegistration
*/
@isTest 
public class AOB_SelfRegistrationTest {
    
    @istest static void testSuccessResponse(){     
		List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        String str = '{"status":"SUCCESS","customLoginQNAResponse":{"userIdentity":"215061","Status":"SUCCESS","StatusCode":"0000","Questions":[{"questionIdentifier":"100","questionDescription":"What is your pets name?"},{"questionIdentifier":"101","questionDescription":"What is your favourite place?"},{"questionIdentifier":"102","questionDescription":"What is your grandfathers occupation?"}]}}'; 
        AOB_SelfRegistration.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        AOB_SelfRegistration.mockHttpStatus = 'OK';
        AOB_SelfRegistration.mockHttpbody = str;
        Test.startTest();
        String repStatus = AOB_SelfRegistration.invokeSelfRegisterCallout(lstApp);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();  
        Assert.areEqual((String)m.get('status'), 'SUCCESS', 'Response Status Check');
    }
    
    @istest static void testNullBodyCheck(){     
		List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
		AOB_SelfRegistration.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        AOB_SelfRegistration.mockHttpStatus = 'OK';
        AOB_SelfRegistration.mockHttpbody = null;
        Test.startTest();
        String repStatus = AOB_SelfRegistration.invokeSelfRegisterCallout(lstApp);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();  
        Assert.areEqual((String)m.get('status'), 'FAILED', 'Response Status Check');
    }
    
    @istest static void testServerError(){     
		List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
		AOB_SelfRegistration.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        AOB_SelfRegistration.mockHttpStatus = 'OK';
        AOB_SelfRegistration.mockHttpbody = null;
        Test.startTest();
        String repStatus = AOB_SelfRegistration.invokeSelfRegisterCallout(lstApp);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        Assert.areEqual((String)m.get('status'), 'FAILED', 'Response Status Check');  
    }
}