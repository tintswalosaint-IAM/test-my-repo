/**
 * @description This is a controller class that handles the management of the api credentials common functionality
 *
 * @author Milica Milicevic(Milica.Milicevic@standardbank.co.za)
 * @description Controller Class for API Credentials Management
 * @UserStory  SFP-50927 
 * @date May 2025
 *
 */
global with sharing class Credentials_Management_CTRL implements Metadata.DeployCallback{
    
    private static final String metadataTypeName = 'sbgplatform__API_Credential__mdt';
    private static final String metadataTypeCredentialName = 'sbgplatform__API_Credential_Value__mdt';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('Credentials_Management_CTRL');
    private static final String PERMISSION_SET = 'API_Credentials_Management';
    private String testingresults;


    /**
	* @description Retrieves a list of the api credentials parent records from custom metadata
	* 
    * @return List<API_Credential__mdt> api credentials
	**/
    @AuraEnabled
    public static List<API_Credential__mdt>  retrieveAllApiCredentials() {
        if(User_PermissionSet_UTIL.userHasPermissionSet(PERMISSION_SET)){
            return sbgplatform__API_Credential__mdt.getAll().values();
        }
        else{
            throw new CredentialManagementException('No access to use: retrieveAllApiCredentials');
        }
    }

    /**
	* @description Retrieves an api credentials parent from custom metadata
	* 
    * @return API_Credential__mdt api credential
	**/
    @AuraEnabled
    public static API_Credential__mdt  retrieveSpecificApiCredentials(String label) {
        if(User_PermissionSet_UTIL.userHasPermissionSet(PERMISSION_SET)){
            return sbgplatform__API_Credential__mdt.getInstance(label);
        }
        else{
            throw new CredentialManagementException('No access to use: retrieveSpecificApiCredentials');
        }
    }

    /**
	* @description Retrieves a list of the api credentials from custom metadata
    *
    * @param parentId String
	* 
    * @return List<API_Credential_Value__mdt> api credentials
	**/
    @AuraEnabled
    public static List<API_Credential_Value__mdt> retrieveAllApiCredentialsValues(String parentId) {
        if(User_PermissionSet_UTIL.userHasPermissionSet(PERMISSION_SET)){
            return [SELECT Id, Label, sbgplatform__Header_Parameter__c, sbgplatform__API_Credential__r.Label FROM sbgplatform__API_Credential_Value__mdt WHERE sbgplatform__API_Credential__c = :parentId];
        }
        else{
            throw new CredentialManagementException('No access to use: retrieveAllApiCredentialsValues');
        }
    }

    /**
	* @description Provides a view on whether the following api credentials are found.
    *
    * @param label String
	* 
    * @return Boolean
	**/
    @AuraEnabled
    global static Boolean verifyApiCredential(String label){
        if(User_PermissionSet_UTIL.userHasPermissionSet(PERMISSION_SET)){
            try{
                Boolean valueExists = false;
                API_Credential__mdt apiCredentialParent = sbgplatform__API_Credential__mdt.getInstance(label);
                API_Credential_Value__mdt apiCredentialChild = API_Credential_Value__mdt.getInstance(label);
                if(apiCredentialParent != null){
                    valueExists = true;
                }

                if(apiCredentialChild != null){
                    valueExists = true;
                }


                return valueExists;
            }
            catch(Exception ex){
                LOGGER.error('verifyApiCredential: Unsuccesful performed metadata deployment: ', ex);
                throw new AuraHandledException(ex.getMessage());
            }
        }
        else{
            throw new CredentialManagementException('No access to use: verifyApiCredential');
        }
    }

    /**
	* @description Provides a view on whether the value for the api credentials matches the one provided.
    *
    * @param label String
    * @param value String
	* 
    * @return Boolean
	**/
    global static Boolean verifyApiCredentialValue(String label, String value){
        if(User_PermissionSet_UTIL.userHasPermissionSet(PERMISSION_SET)){
            try{
                Boolean correctValue = false;
                API_Credential_Value__mdt apiCredentialChild = API_Credential_Value__mdt.getInstance(label);

                if(apiCredentialChild != null){
                    if(apiCredentialChild.sbgplatform__Header_Value__c == value){
                        correctValue = true;
                    }else{
                        correctValue = false;
                    }
                }
                else{
                    throw new CredentialManagementException('API Credential Value provided doesnt exist based on the label.');
                }


                return correctValue;
            }
            catch(Exception ex){
                LOGGER.error('verifyApiCredential: Unsuccesful performed metadata deployment: ', ex);
                throw new AuraHandledException(ex.getMessage());
            }        
        }
        else{
            throw new CredentialManagementException('No access to use: verifyApiCredentialValue');
        }
    }

    /**
    * @description Upsert api credentials
    * @param String solutionId
    * @param String solutionId
    * @return String Results of record creation
    **/
    @AuraEnabled
    public static Id performUpsertApiCredential(String labelName, String jsonData){
        if(User_PermissionSet_UTIL.userHasPermissionSet(PERMISSION_SET)){
            Id jobId;
            try {
                Map<String,Object> fieldsToValueMap =  (Map<String, Object>) JSON.deserializeUntyped(jsonData);
                

                String localMetadataTypeName = metadataTypeName + '.' + labelName;

                Metadata.CustomMetadata metadataObj = new Metadata.CustomMetadata();
                metadataObj.fullName = localMetadataTypeName;
                metadataObj.label = labelName;
                metadataObj.protected_x = false;

                for(String fields:fieldsToValueMap.keySet()) {
                    Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
                    customField.field = fields;
                    customField.value = fieldsToValueMap.get(fields);
                    metadataObj.values.add(customField);
                }
                
                Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
                mdContainer.addMetadata(metadataObj);


                if(!Test.isRunningTest()) {
                    jobId = Metadata.Operations.enqueueDeployment(mdContainer, null);    
                }
                
            } catch (Exception ex) {
                LOGGER.error('performUpsertApiCredential: Unsuccesful performed metadata deployment: ', ex);
                throw new AuraHandledException(ex.getMessage());
            }
            return jobId; 
        }
        else{
            throw new CredentialManagementException('No access to use: performUpsertApiCredential');
        }
    }


    @AuraEnabled
    public static Id performUpsertApiCredentialValue(List<String> metadataCredentialsList){

        if(User_PermissionSet_UTIL.userHasPermissionSet(PERMISSION_SET)){
            Id jobId;
            try {
                Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
                for(String credential : metadataCredentialsList){
                    Map<String,Object> credentialMap =  (Map<String, Object>) JSON.deserializeUntyped(credential);

                    String childName = JSON.serialize(credentialMap.get('labelName')).remove('"');
                    String jsonData = JSON.serialize(credentialMap.get('jsonData'));
                    Map<String,Object> fieldsToValueMap =  (Map<String, Object>) JSON.deserializeUntyped(jsonData);
                    
                    String localMetadataTypeName = metadataTypeCredentialName + '.' + childName;

                    Metadata.CustomMetadata metadataObj = new Metadata.CustomMetadata();
                    metadataObj.fullName = localMetadataTypeName;
                    metadataObj.label = childName;
                    metadataObj.protected_x = false;

                    for(String fields:fieldsToValueMap.keySet()) {
                        Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
                        customField.field = fields;
                        customField.value = fieldsToValueMap.get(fields);
                        metadataObj.values.add(customField);
                    }
                    
                    mdContainer.addMetadata(metadataObj);
                }
        
                if(!Test.isRunningTest()) {
                    jobId = Metadata.Operations.enqueueDeployment(mdContainer, null);    
                }
                
            } catch (Exception ex) {
                LOGGER.error('performUpsertApiCredentialValue: Unsuccesful performed metadata deployment: ', ex);
                throw new AuraHandledException(ex.getMessage());
            }
            return jobId; 
        }
        else{
            throw new CredentialManagementException('No access to use: performUpsertApiCredentialValue');
        }
    }

    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
 
        if (result.status == Metadata.DeployStatus.Succeeded) {    
            this.testingresults = 'Successful';
        } else {
             this.testingresults = 'Failed';
        }
    }

    public class Data_Credential_Class{
        public String labelName;
        public String jsonData;
    }

    class CredentialManagementException extends Exception{}


}