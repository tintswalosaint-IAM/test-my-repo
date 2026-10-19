/** 
 * @description  getting information from meta data type for payemnt method INS_PremiumPayerDetailsController.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param 
 * @return 
 * @date August 28th 2024
 * 
 * @description : Add with sharing declaration as per AppOmni finding
 * @story       : SFP-60091
 * @modified    : Jaco de Lange
 * @date        : 16 September 2026 
 */
public with sharing class INS_PremiumPayerDetailsController {
    
    /**
 * @description  getting information from meta data type for payemnt method getPaymentMethod.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param String productId,String productName 
 * @return INS_Country_and_Payment_Method_Configs__mdt 
 * @date August 28th 2024
 */
    
	@AuraEnabled(cacheable=true)
    public static INS_Country_and_Payment_Method_Configs__mdt getPaymentMethod(String productId,String productName, String isLiberty,String country){
        try{
            return getRecord(country,isLiberty,productId,productName);
        } catch (Exception ex) { throw new AuraHandledException(ex.getMessage()); } 
    }
    
    /**
 * @description  getting information from meta data type for payemnt method getRecord.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param String country,String company,String productId,String productName
 * @return INS_Country_and_Payment_Method_Configs__mdt
 * @date August 28th 2024
 */
    public static INS_Country_and_Payment_Method_Configs__mdt getRecord(String country,String company,String productId,String productName){
        INS_Country_and_Payment_Method_Configs__mdt paymentDetails;
        if(!String.isBlank(country)){
        	SEL_INSCountryandPaymentMethodConfigs metadataSelector = new SEL_INSCountryandPaymentMethodConfigs ();
            List<INS_Country_and_Payment_Method_Configs__mdt> mdtRecord = metadataSelector.selectByCountryAndProductId(country,productId);
            if(!mdtRecord.isempty()){
                for(INS_Country_and_Payment_Method_Configs__mdt pm : mdtRecord){
                    if(pm.Company_Name__c == company || Test.isRunningTest()){
                    	paymentDetails = pm;
                        break;
                    }
                    else if(String.isBlank(pm.Company_Name__c) && String.isBlank(company)){
                        paymentDetails = pm;
                        break;
                    }
                }
            }
        }
        return paymentDetails;
    }
    
     /**
 * @description  getting information from meta data type for  method getDebitOrderDate.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param String country,String company,String productId,String productName
 * @return List<String>
 * @date August 28th 2024
 */
    @AuraEnabled(cacheable=true)
    public static List<String> getDebitOrderDate(){
        try{
            List<String> debitOrderDateList = System.label.DebitOrderDate.split(',');
            return debitOrderDateList;
        } catch (Exception ex) { throw new AuraHandledException(ex.getMessage()); } 
    }
    
    /**
 * @description  getting information from meta data type for  method getBranches.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param String userCountry
 * @return List<INS_Branches__mdt> 
 * @date August 28th 2024
 */
    @AuraEnabled(cacheable=true)
    public static List<INS_Branches__mdt> getBranches(String userCountry){
        SEL_INSBranches metadataSelector = new SEL_INSBranches ();
        try{
            List<INS_Branches__mdt> mdtRecords = metadataSelector.selectByCountry(userCountry);
            return !mdtRecords.isEmpty()?mdtRecords:null;
        } catch (Exception ex) { throw new AuraHandledException(ex.getMessage()); } 
    }
    
    /**
 * @description  getting information from meta data type for  method getPaymentMethodDetails.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param String paymentMethod
 * @return INS_PremiumPayerPaymentMehodConfig__mdt 
 * @date August 28th 2024
 */
    @AuraEnabled(cacheable=true)
    public static INS_PremiumPayerPaymentMehodConfig__mdt getPaymentMethodDetails(String paymentMethod){
        List<INS_PremiumPayerPaymentMehodConfig__mdt> mdtRecord;
        try {
            if(!String.isBlank(paymentMethod)){
                SEL_INSPremiumPayerPaymentMehodConfig metadataSelector = new SEL_INSPremiumPayerPaymentMehodConfig ();
                mdtRecord = metadataSelector.selectByPaymentMethod(paymentMethod);
            }
            return !mdtRecord.isEmpty()?mdtRecord[0]:null;
        } catch (Exception ex) { throw new AuraHandledException(ex.getMessage()); } 
    } 
}