/**
* @description class handles applications around the flow
* 
* @author Ruchi Agrawal
* 
* @date May 2023 
*/
@isTest
public class AOB_APIHandler_Test {
/**
* @description test method used to create application based on given input
*/ 
    @isTest
    static void nameCred(){
        Test.startTest();
            NamedCredential nCrd = AOB_APIHandler.credentials();
      NamedCredential nCrd1 =  AOB_APIHandler.getMcAfeeCredentials();
            CMN_WebserviceSetting__mdt mdt = AOB_APIHandler.webservices();
         CMN_WebserviceSetting__mdt mdt1 = AOB_APIHandler.relyComplyWebServices();
        
        	HttpRequest httpRequest = AOB_APIHandler.clientToken('Bearer', mdt);
        HttpRequest httpRequest2 = AOB_APIHandler.clientToken('Bearer', mdt1);
            HttpRequest httpRequest1 = AOB_APIHandler.assignAccessToken('Bearer', 'jkhfrf438f4hfiu4hf894i45hf8954ghg54g');
        Test.stopTest();
        System.assertEquals(nCrd!=null, true, 'It will return result');
        System.assertEquals(mdt!=null, true, 'It will return result');
        System.assertEquals(httpRequest!=null, true, 'It will return result');
        System.assertEquals(httpRequest1!=null, true, 'It will return result');
        System.assertEquals(nCrd1!=null, true, 'It will return result');
        System.assertEquals(httpRequest2!=null, true, 'It will return result');


    }
}