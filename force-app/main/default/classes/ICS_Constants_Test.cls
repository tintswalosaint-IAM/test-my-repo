/**
* @Name of the Class : ICS_Constants_Test
* @description class used as test Class for ICS_Constants test class factory for  SBO-UK - Story:SFP-37310 
* @author Ikyatha Naidu 
* @date 13/7/2024
* @last modified on  :  13/07/2024
* @last modified by  : Ikyatha Naidu
* @Modification Description : updated to latest version 
*/
@isTest
public class ICS_Constants_Test {
    static testmethod void testConstructor(){
        test.starttest();
        ICS_Constants constantConstructor = new ICS_Constants();
        test.stoptest();
         Assert.areEqual(true, (constantConstructor != null), 'Initialized constructor.');
    }
}