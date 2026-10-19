/**
* @description Class for generic form creation based on database records
*
* @author Dayakar Deekonda
*
* @date June 6th
*/ 
public  without sharing class  AOB_BOTS_SRV_DownloadDocuments {
    
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_BOTS_SRV_DownloadDocuments');
    
    
    /**
    * @description This method is used as get application id
    * @param applicationId
    * @return String
    */ 
    @AuraEnabled
    public static String getapplicationId(String applicationId){
        try{
            List<Application_Participant__c> appParticpant = new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantByApplicationId(applicationId);
            return appParticpant[0].id; 
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'getapplicationId',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    /**
    * @description This method is used as get application id
    * @param applicationId
    */
    @AuraEnabled
    public static void downloadDocuments(String applicationId){
        
        try{
            String packagesData=AOB_BOTS_SRV_SigningHUB.getInflight(applicationId,'SigningHUBPackages');     
            Map<String,Object> packagesMaps = (Map<String,object>) JSON.deserializeUntyped(packagesData);
            String packageId=String.ValueOf(packagesMaps.get('package_id'));    
            List<Application_Participant__c> appParticpant =new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantById(applicationId);
            
            AOB_BOTS_API_DownloadSigningHubDocument customerServiceCall = new AOB_BOTS_API_DownloadSigningHubDocument(packageId);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTS_API_DownloadSigningHubDocument.SERVICE_NAME);
            customerServiceCall.process(obj);
            insert obj;
            Blob document = customerServiceCall.getResponseBlobBody();
            String base64Pdf='';
            if (document != null){
                base64Pdf= EncodingUtil.Base64Encode(document);
            }
            
            Application_Document__c appdoc= new Application_Document__c();
            appdoc.Document_Type__c='Signed Documents';
            appdoc.Application__c=appParticpant[0].Application__c;
            insert appdoc;
            
            sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(new List<SObjectType> { Application_Document__c.SObjectType });
            uow = new sbgplatform.fflib_SObjectUnitOfWork(new List<SObjectType> { ContentVersion.sObjectType });
            AOB_BOTS_SRV_Application.newInstance().saveDocuments(
                appdoc.Id,
                new List<ContentVersion>{new ContentVersion(
                    Title = 'Signed Documents',
                    VersionData = EncodingUtil.base64Decode(base64Pdf),
                    Description = 'Signed Documents',
                    pathOnClient = 'Signed Documents'+'.zip'
                )}, 
                uow
            );
            uow.commitWork();
        }catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'sendDocumnetOnline',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
}