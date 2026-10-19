/***************************************************************************************
@Author            :Lokesh Bothsa 
@Date              :July 2023
@Name of the Class :CMN_SelfRegistrationTest
@description       :Test Class for dealing with Rely Comply
@Last Modified By  :Lokesh Bothsa  
@Last Modified On  :25-05-2023
@Modification Description : SFP-26345
***************************************************************************************/
@isTest
public class CMN_SelfRegistrationTest {
    
    /**
    * @description TestMethod for CMN_SelfRegistration
    *
    */
    @istest 
    static void testCalloutMethod(){     
		List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        String str = '{"status":"SUCCESS","customLoginQNAResponse":{"userIdentity":"215061","Status":"SUCCESS","StatusCode":"0000","Questions":[{"questionIdentifier":"100","questionDescription":"What is your pets name?"},{"questionIdentifier":"101","questionDescription":"What is your favourite place?"},{"questionIdentifier":"102","questionDescription":"What is your grandfathers occupation?"}]}}'; 
        CMN_SelfRegistration.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_SelfRegistration.mockHttpStatus = 'OK';
        CMN_SelfRegistration.mockHttpbody = str;
        Test.startTest();
        String repStatus = CMN_SelfRegistration.invocableMethod(lstApp);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();  
        Assert.areNotEqual(repStatus, null,'It should Not be null');
        Assert.areNotEqual(m, null,'It should Not be null');
    }

    /**
    * @description TestMethod for CMN_SelfRegistration
    *
    */
    @istest 
    static void testCalloutMethod1(){     
		List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
		CMN_SelfRegistration.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_SelfRegistration.mockHttpStatus = 'OK';
        CMN_SelfRegistration.mockHttpbody = null;
        Test.startTest();
        String repStatus = CMN_SelfRegistration.invocableMethod(lstApp);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        Assert.areNotEqual(repStatus, null,'It should Not be null');
        Assert.areNotEqual(m, null,'It should Not be null');  
    }
    
    /**
    * @description TestMethod for CMN_SelfRegistration
    *
    */
    @istest 
    static void testCalloutMethod2(){     
		List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
		CMN_SelfRegistration.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_SelfRegistration.mockHttpStatus = 'OK';
        CMN_SelfRegistration.mockHttpbody = null;
        Test.startTest();
        String repStatus = CMN_SelfRegistration.invocableMethod(lstApp);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        Assert.areNotEqual(repStatus, null,'It should Not be null');
                Assert.areNotEqual(m, null,'It should Not be null');

    }

    /**
    * @description TestMethod for Rely Comply
    *
    */
    @istest 
    static void testCalloutMethod3(){     
		List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
		CMN_SelfRegistration.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        String str = '{"QNAReponse":{"userIdentity" : "user","Status" : "Success","StatusCode":"200","Questions":[{ "questionIdentifier": "Y", "questionDescription": "103", "answer": "34567"}]} ,"header": {"userPrincipal": "UG.VUSER4","stateMode": "N","serviceIdentifier": "LGNINT","operationFormat": "XML","machineFingerPrint": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML like Gecko) Chrome/98.0.4758.80 Safari/537.36","loginType": "SSOLOGIN","loginFlag": 2,"languageIdentifier": "001","isMultirec": "Y","ipFormat": "XML","ipAddress": "162.158.48.125","formIdentifier": "7036b33a-7407-4112-b23c-0148f1d8720b","deviceType": "77041240-02e6-4a46-b759-e6a8b582d589","deviceIdentifier": "https//smebankinguat.stanbicbank.co.ug/#/registration","channelIdentifier": "I","bankIdentifier": "UG","accessCode": "N"},"body": {"AccountNumber": "9030008461310","AccountIndicator": "S", "customerNumber": "20300542976"}}';
        CMN_SelfRegistration.mockHttpStatus = 'OK';
        CMN_SelfRegistration.mockHttpbody = str;
        
        BCB_SelfRegistrationBean data = (BCB_SelfRegistrationBean) JSON.deserialize(str, BCB_SelfRegistrationBean.class);
        Test.startTest();
        String repStatus = CMN_SelfRegistration.invocableMethod(lstApp);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        Assert.areNotEqual(repStatus, null,'It should Not be null');
        Assert.areNotEqual(m, null,'It should Not be null');

    }
 
    /**
    * @description TestMethod for Rely Comply
    *
    */
  @isTest
    static void testMainClassFunctionality() {
        BCB_SelfRegistrationBean.HeaderInfo headerInfo = new BCB_SelfRegistrationBean.HeaderInfo();
        headerInfo.serviceIdentifier = 'service123';
        headerInfo.operationFormat = 'format1';

        BCB_SelfRegistrationBean.BodyInfo bodyInfo = new BCB_SelfRegistrationBean.BodyInfo();
        bodyInfo.AccountNumber = 'account123';
        bodyInfo.AccountIndicator = 'indicator1';

        BCB_SelfRegistrationBean.QNAReponse qnaResponse = new BCB_SelfRegistrationBean.QNAReponse();
        qnaResponse.userIdentity = 'user';
        qnaResponse.Status = 'Success';
        qnaResponse.StatusCode = '200';
        List<BCB_SelfRegistrationBean.Questions> testQuestionsList = new List<BCB_SelfRegistrationBean.Questions>();

        BCB_SelfRegistrationBean.Questions question1 = new BCB_SelfRegistrationBean.Questions();
        question1.questionIdentifier = 'Q1';
        question1.questionDescription = '103';
        question1.answer = '34567';


        testQuestionsList.add(question1);

        qnaResponse.Questions = testQuestionsList;
        Test.startTest();
        BCB_SelfRegistrationBean mainClassInstance = new BCB_SelfRegistrationBean();
        mainClassInstance.header = headerInfo;
        mainClassInstance.body = bodyInfo;
        mainClassInstance.qna = qnaResponse;
        Test.stopTest();
        Assert.areNotEqual(testQuestionsList, null,'It should Not be null');

    }
}