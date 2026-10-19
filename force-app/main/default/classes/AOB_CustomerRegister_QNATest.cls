/***************************************************************************************
@ Author            :AmarNath Reddy
@ Date              :May 2022
@ Name of the Class :AOB_CustomerRegister_QNATest
@description        :test Class to cover AOB_CustomerRegister_QNA
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :29-03-2024
@ Modification Description : SFP-31036
***************************************************************************************/
@istest
public class AOB_CustomerRegister_QNATest {
    /**
    * @description TestMethod to check the Positive Response
    */
    @istest static void testsuccessResponse(){     
        List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        String str='{"customRegisterQNAResponse":{"userIdentity":"9030020359144","customerFirstName":"FAITHMIGI","Message":[{"Status":"306518","StatusCode":"306518","StatusType":"BC"},{"Status":"Password Set Successfully. Your user id is 9030020359144.","StatusCode":"107045","StatusType":"BC"},{"Status":"Registration for security questions successful.","StatusCode":"107034","StatusType":"BC"}]}}';
        AOB_CustomerRegister_QNA.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_CustomerRegister_QNA.mockHttpStatus='OK';
        AOB_CustomerRegister_QNA.mockHttpBody=str;
        String sr = '{"customLoginQNAResponse":{"userIdentity":"214954","Status":"SUCCESS","StatusCode":"0000","Questions":[{"questionIdentifier":"100","questionDescription":"What is your pets name?"},{"questionIdentifier":"101","questionDescription":"What is your favourite place?"},{"questionIdentifier":"102","questionDescription":"What is your grandfathers occupation?"}]}}';
        Test.startTest();
        String repStatus = AOB_CustomerRegister_QNA.invokeRegisterAnswerCallout(lstApp,sr);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
       Assert.areEqual((String)m.get('status'), 'SUCCESS', 'It will check satatus');
    }
    /**
    * @description TestMethod to check the  Failed Response 
    */
    @istest static void testFailedResponse(){     
        List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        AOB_CustomerRegister_QNA.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_CustomerRegister_QNA.mockHttpStatus='OK';
        AOB_CustomerRegister_QNA.mockHttpBody=null;
        String sr = '{"customLoginQNAResponse":{"userIdentity":"214954","Status":"SUCCESS","StatusCode":"0000","Questions":[{"questionIdentifier":"100","questionDescription":"What is your pets name?"},{"questionIdentifier":"101","questionDescription":"What is your favourite place?"},{"questionIdentifier":"102","questionDescription":"What is your grandfathers occupation?"}]}}';
        Test.startTest();
        String repStatus = AOB_CustomerRegister_QNA.invokeRegisterAnswerCallout(lstApp,sr);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
       Assert.areEqual((String)m.get('status'), 'NO_CONTENT', 'It will check satatus');
    }
    /**
    * @description TestMethod to cover when Internal Server error
    */
    @istest static void testInternalServer(){     
        List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        AOB_CustomerRegister_QNA.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        AOB_CustomerRegister_QNA.mockHttpStatus='OK';
        AOB_CustomerRegister_QNA.mockHttpBody=null;
        String sr = '{"customLoginQNAResponse":{"userIdentity":"214954","Status":"SUCCESS","StatusCode":"0000","Questions":[{"questionIdentifier":"100","questionDescription":"What is your pets name?"},{"questionIdentifier":"101","questionDescription":"What is your favourite place?"},{"questionIdentifier":"102","questionDescription":"What is your grandfathers occupation?"}]}}';
        Test.startTest();
        String repStatus = AOB_CustomerRegister_QNA.invokeRegisterAnswerCallout(lstApp,sr);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
       Assert.areEqual((String)m.get('status'), 'FAILED', 'It will check satatus');
    }
}