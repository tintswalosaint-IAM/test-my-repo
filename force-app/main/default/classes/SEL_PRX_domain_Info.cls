/***************************************************************************************
@ Author            :krishna.ranjan@standardbank.co.za
@ Date              :28 November 2024
@ Name of the Class :SEL_PRX_domain_Info
@description       : This Class retrieves metadata Information and Current User information.
@ Last Modified By  :krishna.ranjan@standardbank.co.za
@ Last Modified On  :28-11-2024
@ Jira Ticket       :SFP-42419
* ---------------------------------------------------------------------------
*version   Date               Developer                  
* ---------------------------------------------------------------------------
1.0   NOV 2024   		krishna.ranjan@standardbank.co.za  
***************************************************************************************/
public without Sharing class SEL_PRX_domain_Info {
	/**
    * @description Gets User Details 
    * @author Krishna Ranjan | 02-12-2024
    * @return User
    **/
  @AuraEnabled
public static User getUserDetails() {
    try {
        List<User> users = new SEL_User().selectUsersByIds(new Set<Id>{UserInfo.getUserId()});
        if (users.isEmpty()) {   throw new AuraHandledException('User details not found.');}
         return users[0]; } catch (Exception e) { throw new AuraHandledException('An error occurred while retrieving the User Details: ' + e.getMessage());}
}
    /**
    * @description Retrieves the metadata Details
    * @author Krishna Ranjan | 02-12-2024
    * @return User
    **/
    @AuraEnabled
    public static String getSiteURL(){
        try{
        List<PRX_domain_Info__mdt> mdtList =  new SEL_domainInfo().domainInfoByDeveloperName(PRX_CTRL_Constants.PRXDOMAININFO);
        return mdtList[0].Prx_URL_info__c; 
     }catch (Exception e) {throw new AuraHandledException('An error occurred while retrieving the User Details: ' + e.getMessage());
    }
    }
    /**
    * @description Gets encrypted UserIds 
    * @author Krishna Ranjan | 02-12-2024
    * @return User
    **/
@AuraEnabled      
public static string getEncryptedUserId(){
    try{
        User currentUser = new SEL_User().selectUserById(UserInfo.getUserId());
        String userDataToEncrypt = currentUser.Id;
        if(currentUser.EmployeeNumber != null) {
            userDataToEncrypt += '_' + currentUser.EmployeeNumber;
        }
        Blob userDataBlob = Blob.valueOf(userDataToEncrypt);
        Blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SEL_PRX_domain_Info.getSecretKey(), userDataBlob);
        return EncodingUtil.base64Encode(encryptedBlob);
    } catch(Exception e){throw new AuraHandledException('An error occurred while encrypting the User ID: ' + e.getMessage());
    }
}
 	/**
    * @description Retrieves the Secret Key Details
    * @author Krishna Ranjan | 02-12-2024
    * @return blob
    **/
    @AuraEnabled
public static Blob getSecretKey() {
    try{
        List<PRX_domain_Info__mdt> mdtList = new SEL_domainInfo().domainInfoByDeveloperName(PRX_CTRL_Constants.PRXDOMAININFO);
        return EncodingUtil.base64Decode(mdtList[0].AES_SecretKey__c);   
 }catch(Exception e){throw new AuraHandledException('An error occurred while encrypting the User ID: ' + e.getMessage());    }
}
/**
 * @description : Method to Retrieve Encrypted Certificate 
* @param None
* @return String 
*/
public static String getCertificate(){
       List<CMN_WebserviceSetting__mdt> mdtList = new SEL_CMN_WebserviceSetting().selectByDeveloperName(PRX_CTRL_Constants.PRXAPIFHQ);
        if (mdtList.isEmpty()) {  throw new IllegalArgumentException('No custom metadata record found for API certificate Details in IntegrationDetails record.');
    }  
       String encodedCert = mdtList[0].AOB_ClientCertificate__c;
       Blob decryptedData = EncodingUtil.base64Decode(encodedCert);
       Blob decryptedBlob = Crypto.decryptWithManagedIV('AES256',getSecretKey(), decryptedData);
    return decryptedBlob.toString();
    }   
}