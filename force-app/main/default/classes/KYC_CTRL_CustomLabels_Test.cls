/***************************************************************************************
@Name of the Class :KYC_CTRL_CustomLabels_Test
@Description :SFP-40755 Test Class for KYC_CTRL_CustomLabels
@Author :Dayakar 
@Created Date :OCT 14 2024
***************************************************************************************
* Last Modified By : Initital Version
* Last Modified Date :Initital Version
* Last Modified Description: Initital Version
****************************************************************************************/
@IsTest
public class KYC_CTRL_CustomLabels_Test {
    /**
     * @description Test method for KYC_CTRL_CustomLabels.getCustomlabelsData
     */
     @IsTest
    static void getCustomlabelsDataTest() {
        try{
            Test.startTest();
            Map<String, String> filteredAppSettings=KYC_CTRL_CustomLabels.getCustomlabelsData();
            Test.stopTest();
            Assert.areEqual('.pdf,.png,.jpg',filteredAppSettings.get('acceptedFormats'),'The expected value should match the accepted format as defined in the custom metadata.');
        }Catch(Exception ex){
            Assert.areEqual('Script-thrown exception',ex.getMessage(),'Should receive Script-thrown exception  message');
        }
        
    }
}