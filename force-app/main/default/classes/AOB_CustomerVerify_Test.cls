@isTest
public class AOB_CustomerVerify_Test {  

    @isTest
    static void callInvocable(){
        lead app = new lead(LastName='app', company='app');
        insert app;
        List<sobject> appList= new List<sobject>{app};
        String repStatus;
            test.startTest();
        try{
             repStatus = AOB_CustomerVerify.invocableMethod(appList);
         }catch(exception e){
            system.assertEquals(e.getMessage().contains('Invalid conversion from runtime type Lead to Application__c'), true, 'It will return result');
        }
        test.stopTest();
    }
     @istest static void testCalloutMethod(){     
		List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        String str='{"customers":[{"uuid":"10301767156","personDetails":{"firstName":"JOEL TUTU","lastName":"LEKU","initials":{},"otherName":{},"birthName":"","preferredName":"TUTU","dob":"1985-04-05T00:00:00.000","gender":"M","title":"041","maritalStatus":"001","citizenshipCountry":"Y","countryOfBirth":{},"ethnicity":{},"studentIndicator":"","studentDetails":{"Institution":"","commencedDate":"","expectedCompletionDate":"","enrollmentType":"","renewalDate":""}},"orgDetails":{"legalForm":"","orgEstablishDt":"","numEmployees":"","fiscalYearEnd":"","ownership":""}}]}';
        AOB_CustomerVerify.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_CustomerVerify.mockHttpStatus ='OK';
        AOB_CustomerVerify.mockHttpBody = str;
        Test.startTest();
        String repStatus = AOB_CustomerVerify.invocableMethod(lstApp);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        system.assertEquals((String)m.get('status'), 'SUCCESS', 'It will return status');
    }
    
     @istest static void testCalloutMethod1(){     
		List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        String str='{"customers1":[{"uuid":null,"personDetails":{"firstName":"JOEL TUTU","lastName":"LEKU","initials":{},"otherName":{},"birthName":"","preferredName":"TUTU","dob":"1985-04-05T00:00:00.000","gender":"M","title":"041","maritalStatus":"001","citizenshipCountry":"Y","countryOfBirth":{},"ethnicity":{},"studentIndicator":"","studentDetails":{"Institution":"","commencedDate":"","expectedCompletionDate":"","enrollmentType":"","renewalDate":""}},"orgDetails":{"legalForm":"","orgEstablishDt":"","numEmployees":"","fiscalYearEnd":"","ownership":""}}]}';
        AOB_CustomerVerify.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        AOB_CustomerVerify.mockHttpStatus ='OK';
        AOB_CustomerVerify.mockHttpBody = str;
        Test.startTest();
        String repStatus = AOB_CustomerVerify.invocableMethod(lstApp);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        system.assertEquals((String)m.get('status'), 'FAILED', 'It will return status');
    }
    
    @istest static void testCalloutMethod2(){     
		List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        String str='{"customers":[{"uuid":null,"personDetails":{"firstName":"JOEL TUTU","lastName":"LEKU","initials":{},"otherName":{},"birthName":"","preferredName":"TUTU","dob":"1985-04-05T00:00:00.000","gender":"M","title":"041","maritalStatus":"001","citizenshipCountry":"Y","countryOfBirth":{},"ethnicity":{},"studentIndicator":"","studentDetails":{"Institution":"","commencedDate":"","expectedCompletionDate":"","enrollmentType":"","renewalDate":""}},"orgDetails":{"legalForm":"","orgEstablishDt":"","numEmployees":"","fiscalYearEnd":"","ownership":""}}]}';
        AOB_CustomerVerify.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_CustomerVerify.mockHttpStatus ='OK';
        AOB_CustomerVerify.mockHttpBody = str;
        Test.startTest();
        String repStatus = AOB_CustomerVerify.invocableMethod(lstApp);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        system.assertEquals((String)m.get('status'), 'FAILED', 'It will return status');
       
    }
    
    @istest static void testCalloutMethod3(){     
		List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        AOB_CustomerVerify.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_CustomerVerify.mockHttpStatus ='OK';
        AOB_CustomerVerify.mockHttpBody = null;
        Test.startTest();
        String repStatus = AOB_CustomerVerify.invocableMethod(lstApp);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        system.assertEquals((String)m.get('status'), 'FAILED', 'It will return status');
       
    }
}