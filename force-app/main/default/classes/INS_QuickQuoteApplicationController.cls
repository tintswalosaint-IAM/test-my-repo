/**
 * @description : INS_QuickQuoteApplicationController to fetch custom metadata.
 * @author : Shams Ul Arifeen
 * @group : Cloudsmiths
 * @last modified on  : 18-10-2024
 
 * @description : Add with sharing declaration as per AppOmni finding
 * @story       : SFP-60091
 * @modified    : Jaco de Lange
 * @date        : 16 September 2026
**/
public with sharing class INS_QuickQuoteApplicationController {

    /**
     * @description : Fetch Payment_Method_config__mdt custom metadata for current user
     * @author : Shams Ul Arifeen
     * @return : Payment_Method_config__mdt
    **/
    @AuraEnabled   
    public static Payment_Method_config__mdt getPaymentDetails(){ 
        try{ 
            List<User> userList = [Select id,User_Country__c,CompanyName from User where id=:userinfo.getUserId() WITH USER_MODE];
            if(!userList.isempty()){
                return getRecord(userList[0].User_Country__c,userList[0].CompanyName);
            } 
            else{  
                return null;
            }
        } catch (Exception ex) { throw new AuraHandledException(ex.getMessage()); }
    }

    /**
     * @description : Fetch Payment_Method_config__mdt custom metadata based on the country and company
     * @author : Shams Ul Arifeen
     * @param country
     * @param company
     * @return : Payment_Method_config__mdt
    **/
	public static Payment_Method_config__mdt getRecord(String country,String company){
        Payment_Method_config__mdt paymentDetails;
        if(!String.isBlank(country)){
        	List<Payment_Method_config__mdt> mdtRecord = [Select id,Account_to_be_Debited__c,isAddressRequired__c,isBankDetailsRequired__c,
                                                      Branch_Code__c,Branch_Name__c,isAddressDisable__c,isBankDetailsDisable__c,
                                                      Address_Type__c,AddressLineLength__c,CityLength__c,CountryLength__c,
                                                      CountryZipCodeLength__c,isPaymentMethodDisable__c,Payment_Method__c,Company__c,isBranchListRequired__c,Country__c,Bank_Name__c from Payment_Method_config__mdt
                                                      where Country__c = :country
                                                      WITH USER_MODE];
            if(!mdtRecord.isempty()){
                for(Payment_Method_config__mdt pm : mdtRecord){
                    if(pm.Company__c == company){
                    	paymentDetails = pm;
                        break;
                    } 
                    else if(String.isBlank(pm.Company__c)){
                        paymentDetails = pm;
                        break;
                    }
                }
            }
        }
        return paymentDetails;
    }

    /**
     * @description : Fetch PaymentMethod from custom label and return in the form of List<String>
     * @author : Shams Ul Arifeen
     * @return : List<String>
    **/
    @AuraEnabled(cacheable=true)
    public static List<String> getPaymentMethods(){
        try{
            List<String> paymentMethodList = System.label.PaymentMethod.split(',');
            return paymentMethodList;
        } catch (Exception ex) { throw new AuraHandledException(ex.getMessage()); }
    }

    /**
     * @description : Fetch DebitOrderDate from custom label and return in the form of List<String>
     * @author : Shams Ul Arifeen
     * @return : List<String>
    **/
    @AuraEnabled(cacheable=true)
    public static List<String> getDebitOrderDate(){
        try{
            List<String> debitOrderDateList = System.label.DebitOrderDate.split(',');
            return debitOrderDateList;
        } catch (Exception ex) { throw new AuraHandledException(ex.getMessage()); }
    }

    /**
     * @description : Fetch INS_Branches__mdt custom metadata based on the userCountry
     * @author : Shams Ul Arifeen
     * @param userCountry
     * @return : INS_Branches__mdt
    **/
    @AuraEnabled(cacheable=true)
    public static List<INS_Branches__mdt> getBranches(String userCountry){
        try{
            List<INS_Branches__mdt> mdtRecords = [Select id,Label,INS_BranchCode__c from INS_Branches__mdt
                                                where Country__c=:userCountry
                                                WITH USER_MODE];
            if(!mdtRecords.isEmpty()){
                return mdtRecords;
            }
            else{
                return null;
            }
        } catch (Exception ex) { throw new AuraHandledException(ex.getMessage()); }
    }

    /**
     * @description : Fetch BrancheCode from INS_Branches__mdt custom metadata based on the userCountry and branchName
     * @author : Shams Ul Arifeen
     * @param userCountry
     * @param branchName
     * @return : String
    **/
    @AuraEnabled(cacheable=true)
    public static String getBrancheCode(String userCountry,String branchName){
        try{
            List<INS_Branches__mdt> mdtRecords = [Select id,Label,INS_BranchCode__c from INS_Branches__mdt
                                                where Country__c=:userCountry and Label=:branchName
                                                WITH USER_MODE];
            if(!mdtRecords.isEmpty()){
                return mdtRecords[0].INS_BranchCode__c;
            }
            else{
                return null;
            }
        } catch (Exception ex) { throw new AuraHandledException(ex.getMessage());}
    }
    
}