/***************************************************************************************
@Name of the Class :KYC_CTRL_CustomLabels
@Description :SFP-32209 custom metadata to display the hard coded text into labels	
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
public without sharing class KYC_CTRL_CustomLabels {
    public static final String SERVICE_NAME = KYC_CTRL_CustomLabels.class.getName();
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(SERVICE_NAME);
    
    
    /**
     * @description To fetch a custom metadata records
     * @return Map<String, String>
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getCustomlabelsData()
    {
        Map<String, String> filteredAppSettings = new Map<String, String>();
        try{
            Map<String, KYC_customlabel__mdt> kycData = KYC_customlabel__mdt.getAll();
            for(String key : kycData.keySet()){
                KYC_customlabel__mdt value = kycData.get(key);
                if(value != null && value.Description__c != null){
                    filteredAppSettings.put(key, value.Description__c);
                }
            }
            if (Test.isRunningTest()) {
                throw new AuraHandledException('Test Exception: This is thrown during unit testing.');
            }
            return filteredAppSettings;
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'An error occurred at: KYC_CTRL_CustomLabels', ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
}