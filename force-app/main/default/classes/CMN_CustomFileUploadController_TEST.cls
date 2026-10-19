/**
 * @description       : Test class for CMN_CustomFileUploadController class
 * @author            : NAGENDRAPRASAD MYLAVARAPU
 * @last modified on  : 06-19-2024
 * @last modified by  : Jaco de Lange
**/
@isTest
public class CMN_CustomFileUploadController_TEST {

    /**
    * @description Test method that invokes a class which implements callable interface that dynamically invoke a method to validate all positive scenarios.
    * @author NAGENDRAPRASAD MYLAVARAPU | 02-19-2024
    **/
	@isTest
    static void invokeMethodTest(){
        Test.startTest();
        Object retVal = CMN_CustomFileUploadController.invoke('SVC_Invocable','invokeAPI','123');
        Assert.areEqual('API Invoked', retVal, 'invokeAPI was not handled correctly');
        retVal = CMN_CustomFileUploadController.invoke('SVC_Invocable','getFieldData','123');
        Assert.areEqual('123', (String)((Map<String,Object>)retVal).get('recordId'), 'getFieldData was not handled correctly');
        retVal = CMN_CustomFileUploadController.invoke('SVC_Invocable','getFieldData1','123');
        Assert.areEqual(null, retVal, 'Negative Scenario failed');
        try{
            CMN_CustomFileUploadController.invoke('SVC_Invocable123','getFieldData1','123');
        }
        catch(exception e){
            Assert.areNotEqual(null, e, 'Error occurred when trying to invoke callable method in the custom file upload controller.');
        }
        Test.stopTest();
    }
}