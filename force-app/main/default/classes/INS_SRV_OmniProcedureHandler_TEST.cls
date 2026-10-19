/**
 * @description Test class for Omniscript integration procedure handler
 * @author Alexandr Goryachko
 * @date 2025/01/23
* @ Last Modified By:Ihtishaam Mohammoodally
* @ Last Modified On  :08-07-2025
* @ Modification Description : SFP-32522,PR comments on formatting and coverage updates.
*/

@isTest
public class INS_SRV_OmniProcedureHandler_TEST {
    /**
     * @description To check handler calling omniscript procedure 
     */
    @isTest
    private static void callOmniProcedurePositiveTest() {
        Map<String, Object> ipInput = new Map<String, Object>();
        Map<String, Object> ipOptions = new Map<String, Object>();
        Map<String, Object> params = new Map<String, Object>{
            'procedureName' => 'InsIpSrv_SendConfirmationEmail'
        };
        Test.startTest();
        Map<String, Object> result = (Map<String, Object>)INS_SRV_OmniProcedureHandler.callOmniProcedure(ipInput, ipOptions, params);
        Assert.isNotNull(result, 'call to integration procedure successful');
        Test.stopTest();
    }

    /**
     * @description To check exception in handler calling omniscript procedure 
     */
    @isTest
    private static void callOmniProcedureExceptionTest() {
        Map<String, Object> ipInput = new Map<String, Object>();
        Map<String, Object> ipOptions = new Map<String, Object>();
        Map<String, Object> params = new Map<String, Object>();
        Map<String, Object> result;
        Test.startTest();
        try {
            result = (Map<String, Object>)INS_SRV_OmniProcedureHandler.callOmniProcedure(ipInput, ipOptions, params);
        } catch (Exception ex) {
            Assert.areEqual('Script-thrown exception', ex.getMessage(), 'Exception wasn\'t thrown');
        }
        Assert.isNull(result, 'Error when passing empty procedure name');
        Test.stopTest();
    }
}