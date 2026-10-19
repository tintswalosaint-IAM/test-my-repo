/**
* @description This class is used as call the SigningHUB api
* @author Dayakar Deekonda
* @date June 30th 2023
*/
public without sharing class AOB_BOTS_SRV_WelcomeLetter {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_BOTS_SRV_ESB');
    private static final String WELCOME_LETTER = 'Welcome Letter';
    private static final String COMPLETE = 'Complete';
    private static final String ONLY_OTHERS = 'ONLY_OTHERS';
    private static final String BOTTOM = 'BOTTOM';
    private static final String SIGNER = 'SIGNER';
    private static final String ELECTRONIC_SIGNATURE = 'ELECTRONIC_SIGNATURE';
    private static final String FALSE_VAL = 'false';
    private static final String MANDATORY = 'MANDATORY';
    private static final String RADIOBUTTON_GRP = 'RadioButton_Group1';
    private static final String DEPARTMENT_HEAD = 'Department Head';
    private static final String YEAR_FORMAT = 'yyyy-mm-dd';
    private static final String HELVETICA = 'HELVETICA';
    /**
* @description This method is used as get application id
* @param applicationId
* @return String
*/ 
    @AuraEnabled
    public static String getapplicationId(String applicationId){
        try{
            List<Application_Participant__c> appParticpant = new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantByApplicationId(applicationId);
            List<Application_Document__c> appDoc= [select id,Application__c,Application_Participant__c,Document_Type__c from Application_Document__c where Application__c=:appParticpant[0].Application__c and Document_Type__c=: WELCOME_LETTER];
            if(appDoc.size()>0){
                delete appDoc;
            }
            List<Application__c> filterappsList=[select Id,Status__c from Application__c where Id=:appParticpant[0].Application__c];
            
            if(filterappsList.size()>0){
                filterappsList[0].Status__c=COMPLETE;
                update filterappsList;
            }

            System.enqueueJob(new AOB_BOTS_CTRL_CallWelComeLetter(applicationId));
            return appParticpant[0].id; 
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'getapplicationId',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    /**
* @description This method is used as call the signingHUBPackages api
* @return response code
* @param applicationId
*/
    @AuraEnabled
    public static Integer signingHUBPackages(String applicationId){
        try{
            List<Application_Participant__c> appParticpant = new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantById(applicationId);
            List<Application__c> apps = new AOB_BOTS_SEL_Application().selectAppsById(appParticpant[0].Application__c);
            
            AOB_BOTS_DTO_Packages pack= new AOB_BOTS_DTO_Packages();
            pack.package_name=WELCOME_LETTER;
            pack.workflow_mode=ONLY_OTHERS;
            String jsonBody=Json.serialize(pack);
            AOB_BOTS_API_SignPackages customerServiceCall = new AOB_BOTS_API_SignPackages(jsonBody);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTS_API_SignPackages.SERVICE_NAME);
            customerServiceCall.process(obj);
            insert obj;
            if(customerServiceCall.getResponseStatusCode()==200){
                String appData=customerServiceCall.getResponseBody();
                if(!apps.isEmpty()){
                    Map<String, Object> jsonMAp ;
                    if(String.isBlank(apps[0].Inflight__c)){
                        jsonMAp = new Map<String, Object>();
                        jsonMap.put('SigningHUBPackageswelcomeletter',appData);
                        apps[0].Inflight__c='{"SigningHUBPackageswelcomeletter":'+appData+'}';
                    }
                    else{ 
                        jsonMAp = (Map<String, Object>)System.JSON.deserializeUntyped(apps[0].Inflight__c);
                        jsonMap.put('SigningHUBPackageswelcomeletter',System.JSON.deserializeUntyped(appData));
                        apps[0].Inflight__c='';
                        for(String screen:jsonMAp.keyset()){
                            if(String.isblank(apps[0].Inflight__c)){
                                apps[0].Inflight__c='{"'+screen+'":'+System.JSON.serialize(jsonMAp.get(screen))+'}';
                            }
                            else {
                                String str=apps[0].Inflight__c.SubStringAfter('{');
                                apps[0].Inflight__c='{"'+screen+'":'+System.JSON.serialize(jsonMAp.get(screen))+','+str;
                            }
                        }
                    } 
                }
                update apps;
            }
            return customerServiceCall.getResponseStatusCode();
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'signingHUBPackages',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    
    
    /**
* @description This method is used as call the sendDocumnetWelcomeletter api
* @return response code
* @param applicationId
*/
    @AuraEnabled
    public static Integer sendDocumnetWelcomeletter(String applicationId){
        try{
            List<Application_Participant__c> appParticpant = new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantById(applicationId);
            List<Application__c> apps = new AOB_BOTS_SEL_Application().selectAppsById(appParticpant[0].Application__c);
            List<Application_Document__c> appDoc= [select id,Application__c,Application_Participant__c,Document_Type__c from Application_Document__c where Application__c=:appParticpant[0].Application__c and Document_Type__c=: WELCOME_LETTER order by CreatedDate desc];
            
            ContentVersion cv;
            Blob jsonBody;
            if(appDoc.size()>0){
                List<ContentDocumentLink> conDoClist=[Select Id,ContentDocumentId from ContentDocumentLink where LinkedEntityId=:appDoc[0].id];
                cv= [select id,ContentDocumentId,VersionData ,title from ContentVersion where ContentDocumentId=:conDoClist[0].ContentDocumentId];
            }
            if(cv.VersionData != null){
                jsonBody=cv.VersionData;
            }
            String documnetId;
            String packagesData=AOB_BOTS_SRV_SigningHUB.getInflight(applicationId,'SigningHUBPackageswelcomeletter');     
            Map<String,Object> packagesMaps = (Map<String,object>) JSON.deserializeUntyped(packagesData);
            
            documnetId=String.ValueOf(packagesMaps.get('package_id'));
            AOB_BOTS_API_SigningHUBDocument customerServiceCall = new AOB_BOTS_API_SigningHUBDocument(jsonBody,documnetId);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTS_API_SigningHUBDocument.SERVICE_NAME);
            customerServiceCall.process(obj);
            insert obj;
            String appData=customerServiceCall.getResponseBody();
            if(customerServiceCall.getResponseStatusCode()==201){
                Map<String,Object> documentMaps = (Map<String,object>) JSON.deserializeUntyped(appData);
                Application_Document__c appDocument= new Application_Document__c();
                appDocument.Application__c=appParticpant[0].Application__c;
                appDocument.Application_Participant__c=applicationId;   
                appDocument.External_Id__c=String.valueOf(documentMaps.get('documentid'));   
                insert appDocument; 
                if(!apps.isEmpty()){
                    Map<String, Object> jsonMAp ;
                    if(String.isBlank(apps[0].Inflight__c)){
                        jsonMAp = new Map<String, Object>();
                        jsonMap.put('sendDocumnetWelcomeletter',appData);
                        apps[0].Inflight__c='{"sendDocumnetWelcomeletter":'+appData+'}';
                    }
                    else{ 
                        jsonMAp = (Map<String, Object>)System.JSON.deserializeUntyped(apps[0].Inflight__c);
                        jsonMap.put('sendDocumnetWelcomeletter',System.JSON.deserializeUntyped(appData));
                        apps[0].Inflight__c='';
                        for(String screen:jsonMAp.keyset()){
                            if(String.isblank(apps[0].Inflight__c)){
                                apps[0].Inflight__c='{"'+screen+'":'+System.JSON.serialize(jsonMAp.get(screen))+'}';
                            }
                            else {
                                String str=apps[0].Inflight__c.SubStringAfter('{');
                                apps[0].Inflight__c='{"'+screen+'":'+System.JSON.serialize(jsonMAp.get(screen))+','+str;
                            }
                        }
                    } 
                }
                update apps;
            }
            return customerServiceCall.getResponseStatusCode();
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'sendDocumnetWelcomeletter',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    
    
    /**
* @description This method is used as call the addWorkflowUsers api
* @return response code
* @param applicationId
*/
    @AuraEnabled
    public static Integer addWorkflowUsers(String applicationId){
        try{
            String jsonBody;
            String documnetId;
            Integer count=1;
            List<Application_Participant__c> appParticpant =[select Id,CNGCU_Email__c,Application__c,Application__r.Owner.Email,Application__r.Owner.Name from Application_Participant__c where id =:applicationId Limit 1];
            List<AOB_BOTS_DTO_AddPackages> packlist= new List<AOB_BOTS_DTO_AddPackages>();
            AOB_BOTS_DTO_AddPackages packages= new AOB_BOTS_DTO_AddPackages();
            packages.user_email=appParticpant[0].Application__r.Owner.Email;
            packages.user_name=appParticpant[0].Application__r.Owner.Name;
            packages.role=SIGNER; 
            packages.email_notification='true';
            packages.signing_order=String.valueOf(count);
            count=1;     
            packlist.add(packages);
            jsonBody=Json.serialize(packlist);
            String packagesData=AOB_BOTS_SRV_SigningHUB.getInflight(applicationId,'SigningHUBPackageswelcomeletter');     
            Map<String,Object> packagesMaps = (Map<String,object>) JSON.deserializeUntyped(packagesData);
            documnetId=String.ValueOf(packagesMaps.get('package_id'));
            AOB_BOTS_API_SigningHUBAddWorkFlowUser customerServiceCall = new AOB_BOTS_API_SigningHUBAddWorkFlowUser(jsonBody,documnetId);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTS_API_SigningHUBAddWorkFlowUser.SERVICE_NAME);
            customerServiceCall.process(obj);
            insert obj;
            return customerServiceCall.getResponseStatusCode();
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'addWorkflowUsers',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    /**
* @description This method is used as call the sendDigitalSign api
* @return response code
* @param applicationId
*/
    @AuraEnabled
    public Static Integer sendDigitalSign(String applicationId){
        try{  
            String jsonBody;
            String documnetId;
            String packageid;
            Integer responseStatusCode;
            Integer count=1;
            
            String packagesData=AOB_BOTS_SRV_SigningHUB.getInflight(applicationId,'SigningHUBPackageswelcomeletter');     
            Map<String,Object> packagesMaps = (Map<String,object>) JSON.deserializeUntyped(packagesData);
            packageid=String.ValueOf(packagesMaps.get('package_id'));
            
            String signingHUBDocumnet=AOB_BOTS_SRV_SigningHUB.getInflight(applicationId,'sendDocumnetWelcomeletter');  
            Map<String,Object> signingHUBDocumnetMaps = (Map<String,object>) JSON.deserializeUntyped(signingHUBDocumnet);
            documnetId=(String.ValueOf(signingHUBDocumnetMaps.get('documentid')));  
            
            Application_Participant__c apps = [select Id,CNGCU_Email__c,Application__c,Application__r.Owner.Email from Application_Participant__c where id =:applicationId Limit 1];
            
            AOB_BOTS_DTO_Digitalsign digitalSign= new AOB_BOTS_DTO_Digitalsign();
            digitalSign.search_text=apps.Application__r.Owner.Email;
            digitalSign.placement=BOTTOM;
            digitalSign.order=count;
            digitalSign.field_type=ELECTRONIC_SIGNATURE;
            digitalSign.multiline=FALSE_VAL;
            digitalSign.value=FALSE_VAL;
            digitalSign.max_length=100;
            digitalSign.validation_rule=MANDATORY;
            digitalSign.radio_group_name=RADIOBUTTON_GRP;
            digitalSign.placeholder=DEPARTMENT_HEAD;
            digitalSign.format=YEAR_FORMAT;
            cls_font font= new cls_font();
            font.name=HELVETICA;
            font.size=12;
            font.embedded_size=10;
            digitalSign.font=font;
            cls_dimensions dimension= new cls_dimensions();
            dimension.width=200;
            dimension.height=30;
            digitalSign.dimensions=dimension;
            jsonBody=Json.serialize(digitalSign);
            responseStatusCode=AOB_BOTS_API_DigitalSign.digitalSteps(jsonBody,documnetId, packageid);
            
            return responseStatusCode; 
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'sendDigitalSign',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    } 
    
    /**
* @description This method is used as call the shareDocument api
* @return response code
* @param applicationId
*/
    @AuraEnabled
    public static integer shareDocument(String applicationId){
        try{
            String packagesData=AOB_BOTS_SRV_SigningHUB.getInflight(applicationId,'SigningHUBPackageswelcomeletter');     
            Map<String,Object> packagesMaps = (Map<String,object>) JSON.deserializeUntyped(packagesData);
            String packageId=String.ValueOf(packagesMaps.get('package_id'));
            AOB_BOTS_API_ShareDocuments customerServiceCall = new AOB_BOTS_API_ShareDocuments(packageId);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTS_API_ShareDocuments.SERVICE_NAME);
            customerServiceCall.process(obj);
            insert obj;
            return customerServiceCall.getResponseStatusCode();
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'shareDocument',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    
    /**
* @description wrapper for AOB_BOTS_DTO_Packages
*/ 
    public class AOB_BOTS_DTO_Packages{
        
        public String package_name;
        public String workflow_mode;
        
    }
    
    /**
* @description wrapper for AOB_BOTS_DTO_AddPackages
*/
    public Class AOB_BOTS_DTO_AddPackages{
        
        public string user_email;
        Public String user_name;
        public String role;
        public String email_notification;
        public String signing_order;
        
    }
    
    /**
* @description wrapper for AOB_BOTS_DTO_Digitalsign
*/ 
    public class AOB_BOTS_DTO_Digitalsign{
        public String search_text;	
        public String placement;	
        public Integer order;	
        public String field_type;	
        public String multiline;	
        public String value;	
        public Integer max_length;	
        public String validation_rule;	
        public String radio_group_name;
        public String placeholder;
        public String format;	
        public cls_font font;
        public cls_dimensions dimensions;
        
    }
    
    /**
* @description wrapper for cls_dimensions
*/
    public class cls_font {
        public String name;	
        public Integer size;	
        public Double embedded_size;	
    }
    
    /**
* @description wrapper for cls_dimensions
*/
    public class cls_dimensions {
        public Integer width;	
        public Integer height;	
    }
    /**
* @description wrapper for AOB_BOTS_DTO_GenerateLink
*/
    public class AOB_BOTS_DTO_GenerateLink{
        public String package_id;	
        public String language;	
        public String user_email;	
        public String callback_url;	
        public String collapse_panels;	
        public String usercertificate_id;	
    }
}