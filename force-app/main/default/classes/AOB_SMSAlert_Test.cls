/***************************************************************************************
@ Author            :Yashwanth
@ Date              :june 2022
@ Name of the Class :AOB_SMSAlert_Test
@ Description       :Test Class to cover the code for AOB_SignatureVerification. 
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :3/14/2024.
@ Modification Description : SFP-28286
***************************************************************************************/
/** 
* @description Test Class to cover the code for AOB_SignatureVerification. 
*/
@istest
public class AOB_SMSAlert_Test {
    /**
    * @description Test Callout method for Success. 
    */
     @istest static void testCalloutSuccess() {     
		Lead ld = AOB_TestDataFactory.createLead();
        List<Lead> idList = new List<Lead>{ld};
        String str = '{"StatusDescription":"Your Response was sent Successfully to SMPP","StatusCode":200}';
        AOB_SMSAlert.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        AOB_SMSAlert.mockHttpStatus = 'OK';
        AOB_SMSAlert.mockHttpbody = str;

        Test.startTest();
        String repStatus = AOB_SMSAlert.sendSMS(idList);
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest(); 

        Assert.areEqual((Integer) responseMap.get('StatusCode'), 200, 'Status Code Check Against Response');
    }
    /* 
     * @description Test Callout method for empty body.  
    */
    @istest static void testCalloutMethodNoContent(){     
		Lead ld = AOB_TestDataFactory.createLead();
        List<Lead> idList = new List<Lead>{ld};
        
        AOB_SMSAlert.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        AOB_SMSAlert.mockHttpStatus = 'OK';
        AOB_SMSAlert.mockHttpbody = null;

        Test.startTest();
        String repStatus = AOB_SMSAlert.sendSMS(idList);
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest(); 
        Assert.areEqual((String)responseMap.get('status'), 'NO_CONTENT', 'Status Check against the response');
    }
    /* 
    * @description Test Callout method for failed response.
    */    
    @istest static void testCalloutMethodFailed(){     
		Lead ld = AOB_TestDataFactory.createLead();
        List<Lead> idList = new List<Lead>{ld};
        AOB_SMSAlert.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        AOB_SMSAlert.mockHttpStatus = 'OK';
        AOB_SMSAlert.mockHttpbody = null;

        Test.startTest();
        String repStatus = AOB_SMSAlert.sendSMS(idList);
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest(); 

        Assert.areEqual((String)responseMap.get('status'), 'FAILED', 'Status Check against the response');
    }
}