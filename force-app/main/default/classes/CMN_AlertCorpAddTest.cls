/***************************************************************************************
@ Author            :Loksesh B
@ Date              :May 2023
@ Name of the Class :CMN_AlertCorpAddTest
@description       :Test Class for dealing with BCB_AlertCorpAddBean api and sending the result to the main container and storing the values in the wrapper
@ Last Modified By  :
@ Last Modified On  :20-05-2023
@ Modification Description : 
***************************************************************************************/
@istest
public class CMN_AlertCorpAddTest {
  /**
    * @description TestMethod for CMN_AlertCorpAdd
    *
    */
 @istest static void testCalloutMethod(){    
            List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
            String str='{ "customerAlert": {"corporateIdentity": "20301129633","customerHostId": "FIN","legalName": "Barlow","status": "Record Added Successfully"}}';
            CMN_AlertCorpAdd.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
            CMN_AlertCorpAdd.mockHttpStatus='OK';
            CMN_AlertCorpAdd.mockHttpbody=str;
            Test.startTest();
            String repStatus = CMN_AlertCorpAdd.invocableMethod(lstApp);
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            Test.stopTest();
            Assert.areEqual((String)m.get('status'), null,'It should be null');
     }
       /**
    * @description TestMethod for CMN_AlertCorpAdd
    *
    */
    @istest static void testCalloutMethod1(){    
            List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
            String str='{ "customerAlert": {"corporateIdentity": "","customerHostId": "FIN","legalName": "Barlow","status": "Record Added Successfully"}}';
            CMN_AlertCorpAdd.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
            CMN_AlertCorpAdd.mockHttpStatus='OK';
            CMN_AlertCorpAdd.mockHttpbody=str;
            Test.startTest();
            String repStatus = CMN_AlertCorpAdd.invocableMethod(lstApp);
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            Test.stopTest();
            Assert.areEqual((String)m.get('status'), null,'It should be null');
     }
  /**
    * @description TestMethod for CMN_AlertCorpAdd
    *
    */
     @istest static void testCalloutMethod2(){    
            List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
         
            String str='{ "customerAlert": {"corporateIdentity": "","customerHostId": "FIN","legalName": "Barlow","status": "Record Added Successfully"}}';
            CMN_AlertCorpAdd.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
            CMN_AlertCorpAdd.mockHttpStatus='OK';
            CMN_AlertCorpAdd.mockHttpbody=str;
            Test.startTest();
            String repStatus = CMN_AlertCorpAdd.invocableMethod(lstApp);
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            Test.stopTest();
            Assert.areEqual((String)m.get('status'), 'FAILED','It should be failed');
            Assert.areNotEqual((String)m.get('status'), 'success','It should be success');
     }
   /**
    * @description TestMethod for CMN_AlertCorpAdd
    *
    */
     @istest static void testCalloutMethod3(){    
            List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
            CMN_AlertCorpAdd.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
            CMN_AlertCorpAdd.mockHttpStatus='FAILED';
            CMN_AlertCorpAdd.mockHttpbody='';
            Test.startTest();
            String repStatus = CMN_AlertCorpAdd.invocableMethod(lstApp);
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            Test.stopTest();
            Assert.areEqual((String)m.get('status'), 'FAILED','It should be failed');
            Assert.areNotEqual((String)m.get('status'), 'success','It should be success');
     }
  /**
    * @description TestMethod for CMN_AlertCorpAdd
    *
    */
      @istest static void testCalloutMethod4(){    
            List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
            CMN_AlertCorpAdd.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
            CMN_AlertCorpAdd.mockHttpStatus='OK';
            CMN_AlertCorpAdd.mockHttpbody='';
            Test.startTest();
            String repStatus = CMN_AlertCorpAdd.invocableMethod(lstApp);
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            Test.stopTest();
           Assert.areEqual((String)m.get('status'), 'FAILED','It should be success');
            Assert.areNotEqual((String)m.get('status'), 'success','It should be success');
     }
  /**
    * @description TestMethod for CMN_AlertCorpAdd
    *
    */
     @istest static void testCalloutMethod5(){   
         String jsonString = '{"languageID": "EN_US","customerInternalID": "20301129644", "customerHostID": "FIN","legalName": "Barlow"}';
        BCB_AlertCorpAddBean data = (BCB_AlertCorpAddBean) JSON.deserialize(jsonString, BCB_AlertCorpAddBean.class);

	     Assert.areEqual( data.languageID, 'EN_US','Test');
       Assert.areEqual( data.customerInternalID, '20301129644','Test');
       Assert.areEqual(data.customerHostID, 'FIN','Test');
       Assert.areEqual( data.legalName, 'Barlow','Test'); 

     }
    
   
      

}