/**
* Test class for OSB_SRB_EncryptionHelper
* <br/>SGRPT-4350
*
* @author Denys Yelchaninov (dyelchaninov@deloittece.com)
* @date March 2021
*/
@isTest
private class OSB_SRV_EncryptionHelper_TEST {

    @isTest
    private static void testEncryptionWithKey(){
        String keyCode = 'TEST_KEY';
        OSB_EncryptionKeys__c keyEntry = new OSB_EncryptionKeys__c(
                Name = keyCode,
                Value__c = 'z81CCBXananpMkDadZxsiA=='
        );
        insert keyEntry;

        Test.startTest();
        String encryptedStr = OSB_SRV_EncryptionHelper.encryptString('testStr', keyCode);
        String decryptedStr = OSB_SRV_EncryptionHelper.decryptString(encryptedStr, keyCode);
        Test.stopTest();
        System.assertEquals('testStr', decryptedStr);
    }

    @isTest
    private static void checkSettingInsert(){
        Test.startTest();
        String testKey = EncodingUtil.base64Encode(OSB_SRV_EncryptionHelper.getKey('TEST_KEY'));
        Test.stopTest();
        System.assertEquals(OSB_EncryptionKeys__c.getValues('TEST_KEY').Value__c, testKey);
    }
}