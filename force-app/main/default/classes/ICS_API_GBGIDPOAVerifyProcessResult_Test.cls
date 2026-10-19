/**
* @description SFP-32986 Class used for test class ICS_API_GBGPOAVerification
*  
* @author Ikyatha Naidu
* 
* @date 11/05/2024
* @Last Modified By  IKYATHA NAIDU
* @Last Modified Date 01/07/2024
* @Last Modified Description: updated to latest version
*/
@isTest
public class ICS_API_GBGIDPOAVerifyProcessResult_Test { 
    static testmethod void processMethod() {
        test.starttest();
        try{
        	CMN_FACTORY_WebserviceManager.processInboundService('ICS_API_GBGIDPOAVerifyProcessResult');
        }catch(exception ex){
         Assert.arenotEqual(true,( ex !=null),'Error Occured');
        }
            test.stoptest();
    }
}