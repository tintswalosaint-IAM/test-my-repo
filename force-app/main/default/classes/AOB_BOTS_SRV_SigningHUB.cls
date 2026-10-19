/**
* @description This class is used as call the SigningHUB api
* @author Dayakar 
* @date Jan 5th 2021
* @last modified on  : 03-08-2023
* @last modified by  : Ramya Gurram
* @ Modification Description :added new method signatory card
*/
public without sharing class AOB_BOTS_SRV_SigningHUB { 
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_BOTS_SRV_SigningHUB');
    
    /**
* @description This method is used as call the accessToken api
* @return string
*/
    public static string getAccessToken(){
        try{
            AOB_BOTS_API_GetAccessTokenSigningHUB customerServiceCall = new AOB_BOTS_API_GetAccessTokenSigningHUB();
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTS_API_GetAccessTokenSigningHUB.SERVICE_NAME);
            customerServiceCall.process(obj);
            String accesToken;
            if(customerServiceCall.getResponseStatusCode()==200){
                GetAccessToken accessToken= (GetAccessToken) System.JSON.deserialize(customerServiceCall.getResponseBody(), GetAccessToken.class);
                accesToken=accessToken.access_token;
            }
            return accesToken;
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_SigningHUB.getAccessToken',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    /**
* @description This method is used as call the signingHUBPackages api
* @param  applicationId
* @return Integer
*/
    @AuraEnabled
    public static Integer signingHUBPackages(String applicationId){
        try{
            List<Application_Participant__c> appParticpant = new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantById(applicationId);
            List<Application__c> apps = new AOB_BOTS_SEL_Application().selectAppsById(appParticpant[0].Application__c);
            
            List<Application_Document__c> appDoc= new AOB_BOTS_SEL_ApplicationDocument().selectAppsByIdAndDoctype(appParticpant[0].Application__c,'Stanbic-Bus Ac Open Application'); 
            
            AOB_BOTS_DTO_Packages pack= new AOB_BOTS_DTO_Packages();
            pack.package_name=appDoc[0].Document_Type__c;
            pack.workflow_mode='ONLY_OTHERS';
            pack.workflow_type='PARALLEL';
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
                        jsonMap.put('SigningHUBPackages',appData);
                        apps[0].Inflight__c='{"SigningHUBPackages":'+appData+'}';
                    }
                    else{ 
                        jsonMAp = (Map<String, Object>)System.JSON.deserializeUntyped(apps[0].Inflight__c);
                        jsonMap.put('SigningHUBPackages',System.JSON.deserializeUntyped(appData));
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
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_SigningHUB.signingHUBPackages',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    
     /**
* @description This method is used as call the signingHUBPackages api
* @param  applicationId
* @return Integer
*/
    @AuraEnabled
    public static Integer updateSigningHUBPackages(String applicationId){
        try{
            List<Application_Participant__c> appParticpant = new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantById(applicationId);
            List<Application__c> apps = new AOB_BOTS_SEL_Application().selectAppsById(appParticpant[0].Application__c);
            
            String packagesData=getInflight(applicationId,'SigningHUBPackages');     
            Map<String,Object> packagesMaps = (Map<String,object>) JSON.deserializeUntyped(packagesData);
            String documnetId=String.ValueOf(packagesMaps.get('package_id'));            
            AOB_BOTS_DTO_Packages pack= new AOB_BOTS_DTO_Packages();
            pack.workflow_mode='ONLY_OTHERS';
            pack.workflow_type='PARALLEL';
            String jsonBody=Json.serialize(pack);
            
            AOB_BOTS_API_UpdatePackages customerServiceCall = new AOB_BOTS_API_UpdatePackages(jsonBody,documnetId);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTS_API_UpdatePackages.SERVICE_NAME);
            customerServiceCall.process(obj);
            insert obj;
            return customerServiceCall.getResponseStatusCode();
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_SigningHUB.updateSigningHUBPackages',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    /**
* @description This method is used as call the sendDocumnetOpenApplication api
* @param  applicationId
* @return Integer 
*/
    @AuraEnabled
    public static Integer sendDocumnetOpenApplication(String applicationId){
        try{
            List<Application_Participant__c> appParticpant = new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantById(applicationId);
            List<Application__c> apps = new AOB_BOTS_SEL_Application().selectAppsById(appParticpant[0].Application__c);
            List<Application_Document__c> appDoc;
            if(appParticpant[0].Application__r.AOB_Schema_Code__c=='OD001' || appParticpant[0].Application__r.AOB_Schema_Code__c=='OD005'){    
                appDoc= new AOB_BOTS_SEL_ApplicationDocument().selectAppsByIdAndDoctype(appParticpant[0].Application__c,'Stanbic-Bus Ac Open Application'); 
            }if(appParticpant[0].Application__r.AOB_Schema_Code__c=='SOCTY'){
                
                appDoc= new AOB_BOTS_SEL_ApplicationDocument().selectAppsByIdAndDoctype(appParticpant[0].Application__c,'Mandate to open a Matshelo Savings Account'); 
                
            }
            ContentVersion cv;
            if(appDoc.size()>0){
                List<ContentDocumentLink> conDoClist=[Select Id,ContentDocumentId from ContentDocumentLink where LinkedEntityId=:appDoc[0].id];
                cv= [select id,ContentDocumentId,VersionData ,title from ContentVersion where ContentDocumentId=:conDoClist[0].ContentDocumentId];
            }
            Blob jsonBody=cv.VersionData;
            String documnetId;
            String packagesData=getInflight(applicationId,'SigningHUBPackages');     
            Map<String,Object> packagesMaps = (Map<String,object>) JSON.deserializeUntyped(packagesData);
            documnetId=String.ValueOf(packagesMaps.get('package_id'));
            AOB_BOTS_API_SigningHUBDocument customerServiceCall = new AOB_BOTS_API_SigningHUBDocument(jsonBody,documnetId);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTS_API_SigningHUBDocument.SERVICE_NAME);
            customerServiceCall.process(obj);
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
                        jsonMap.put('SigningHUBDocumnet',appData);
                        apps[0].Inflight__c='{"SigningHUBDocumnet":'+appData+'}';
                    }
                    else{ 
                        jsonMAp = (Map<String, Object>)System.JSON.deserializeUntyped(apps[0].Inflight__c);
                        jsonMap.put('SigningHUBDocumnet',System.JSON.deserializeUntyped(appData));
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
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_SigningHUB.sendDocumnetOpenApplication',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    
    /**
* @description This method is used as call the sendDocumnetOnline api
* @param  applicationId
* @return Integer
*/
    @AuraEnabled
    public static Integer sendDocumnetOnline(String applicationId){
        try{
            List<Application_Participant__c> appParticpant = new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantById(applicationId);
            List<Application__c> apps = new AOB_BOTS_SEL_Application().selectAppsById(appParticpant[0].Application__c);
            List<Application_Document__c> appDoc;
            if(appParticpant[0].Application__r.AOB_Schema_Code__c=='OD001' || appParticpant[0].Application__r.AOB_Schema_Code__c=='OD005'){     
                appDoc= new AOB_BOTS_SEL_ApplicationDocument().selectAppsByIdAndDoctype(appParticpant[0].Application__c,'online-banking-application-form'); 
            }if(appParticpant[0].Application__r.AOB_Schema_Code__c=='SOCTY'){
                
                appDoc= new AOB_BOTS_SEL_ApplicationDocument().selectAppsByIdAndDoctype(appParticpant[0].Application__c,'Resolution to open Informal Matshelo Account'); 
                
            }
            ContentVersion cv;
            if(appDoc.size()>0){
                List<ContentDocumentLink> conDoClist=[Select Id,ContentDocumentId from ContentDocumentLink where LinkedEntityId=:appDoc[0].id];
                cv= [select id,ContentDocumentId,VersionData ,title from ContentVersion where ContentDocumentId=:conDoClist[0].ContentDocumentId];
            }
            Blob jsonBody=cv.VersionData;
            String documnetId;
            String packagesData=getInflight(applicationId,'SigningHUBPackages');     
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
                        jsonMap.put('SigningHUBDocumnetonline',appData);
                        apps[0].Inflight__c='{"SigningHUBDocumnetonline":'+appData+'}';
                    }
                    else{ 
                        jsonMAp = (Map<String, Object>)System.JSON.deserializeUntyped(apps[0].Inflight__c);
                        jsonMap.put('SigningHUBDocumnetonline',System.JSON.deserializeUntyped(appData));
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
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_SigningHUB.sendDocumnetOnline',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    
    /**
* @description This method is used as call the sendDocumnetFaxEmailIndemnity api
* @param  applicationId
* @return Integer
*/
    @AuraEnabled
    public static Integer sendDocumnetFaxEmailIndemnity(String applicationId){
        try{
            List<Application_Participant__c> appParticpant = new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantById(applicationId);
            List<Application__c> apps = new AOB_BOTS_SEL_Application().selectAppsById(appParticpant[0].Application__c);
            List<Application_Document__c> appDoc;
            if(appParticpant[0].Application__r.AOB_Schema_Code__c=='OD001' || appParticpant[0].Application__r.AOB_Schema_Code__c=='OD005'){
                appDoc= new AOB_BOTS_SEL_ApplicationDocument().selectAppsByIdAndDoctype(appParticpant[0].Application__c,'Fax Email Indemnity'); 
            }else{
                return 201;
            }
            ContentVersion cv;
            if(appDoc.size()>0){
                List<ContentDocumentLink> conDoClist=[Select Id,ContentDocumentId from ContentDocumentLink where LinkedEntityId=:appDoc[0].id];
                cv= [select id,ContentDocumentId,VersionData ,title from ContentVersion where ContentDocumentId=:conDoClist[0].ContentDocumentId];
            }
            Blob jsonBody=cv.VersionData;
            String documnetId;
            String packagesData=getInflight(applicationId,'SigningHUBPackages');     
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
                        jsonMap.put('SigningHUBDocumnetFaxEmail',appData);
                        apps[0].Inflight__c='{"SigningHUBDocumnetFaxEmail":'+appData+'}';
                    }
                    else{ 
                        jsonMAp = (Map<String, Object>)System.JSON.deserializeUntyped(apps[0].Inflight__c);
                        jsonMap.put('SigningHUBDocumnetFaxEmail',System.JSON.deserializeUntyped(appData));
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
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_SigningHUB.sendDocumnetFaxEmailIndemnity',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    /**
* @description This method is used as call the signatoryCard api
* @param  applicationId
* @return Integer
*/
    @AuraEnabled
    public static Integer signatoryCard(String applicationId){
        try{
            List<Application_Participant__c> appParticpant = new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantById(applicationId);
            List<Application__c> apps = new AOB_BOTS_SEL_Application().selectAppsById(appParticpant[0].Application__c);
            List<Application_Document__c> appDoc;
             appDoc= new AOB_BOTS_SEL_ApplicationDocument().selectAppsByIdAndDoctype(appParticpant[0].Application__c,'Signature Card'); 
            
            ContentVersion cv;
            if(appDoc.size()>0){
                List<ContentDocumentLink> conDoClist=[Select Id,ContentDocumentId from ContentDocumentLink where LinkedEntityId=:appDoc[0].id];
                cv= [select id,ContentDocumentId,VersionData ,title from ContentVersion where ContentDocumentId=:conDoClist[0].ContentDocumentId];
            }
            Blob jsonBody=cv.VersionData;
            String documnetId;
            String packagesData=getInflight(applicationId,'SigningHUBPackages');     
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
                        jsonMap.put('signatoryCard',appData);
                        apps[0].Inflight__c='{"signatoryCard":'+appData+'}';
                    }
                    else{ 
                        jsonMAp = (Map<String, Object>)System.JSON.deserializeUntyped(apps[0].Inflight__c);
                        jsonMap.put('signatoryCard',System.JSON.deserializeUntyped(appData));
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
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_SigningHUB.signatoryCard',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    
    /**
* @description This method is used as call the addWorkflowUsers api
* @param  applicationId
* @return Integer
*/
    @AuraEnabled
    public static Integer addWorkflowUsers(String applicationId){
        try{
            String jsonBody;
            String documnetId;
            Integer count=1;
            List<Application_Participant__c> appParticpant =new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantById(applicationId);
            List<Application_Participant__c> directorDataList = new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantByApplicationIdSign(appParticpant[0].Application__c,true);        
            List<AOB_BOTS_DTO_AddPackages> packlist= new List<AOB_BOTS_DTO_AddPackages>();
            for(Application_Participant__c ap:directorDataList){ 
                AOB_BOTS_DTO_AddPackages packages= new AOB_BOTS_DTO_AddPackages();
                packages.user_email=ap.CNGCU_Email__c;
                packages.user_name=ap.AOB_FullName__c;
                packages.role='SIGNER';
                packages.email_notification=false;
                packages.signing_order=count;
                count=count+1;     
                packlist.add(packages);
            } 
            jsonBody=Json.serialize(packlist);
            String packagesData=getInflight(applicationId,'SigningHUBPackages');     
            Map<String,Object> packagesMaps = (Map<String,object>) JSON.deserializeUntyped(packagesData);
            documnetId=String.ValueOf(packagesMaps.get('package_id'));
            AOB_BOTS_API_SigningHUBAddWorkFlowUser customerServiceCall = new AOB_BOTS_API_SigningHUBAddWorkFlowUser(jsonBody,documnetId);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTS_API_SigningHUBAddWorkFlowUser.SERVICE_NAME);
            customerServiceCall.process(obj);
            insert obj;
            return customerServiceCall.getResponseStatusCode();
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_SigningHUB.addWorkflowUsers',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        } 
    }
    
    
    /**
* @description This method is used as call the sendDigitalSign api
* @param  applicationId
* @return Integer
*/
    @AuraEnabled
    public Static Integer sendDigitalSign(String applicationId){
        try{
            String jsonBody;
            String documnetId;
            String packageid;
            Integer responseStatusCode;
            Integer count=1;
            List<String> documentIdlist= new List<String>();
            
            Application_Participant__c apps = [select Id,CNGCU_Email__c,Application__c,Application__r.AOB_Schema_Code__c from Application_Participant__c where id =:applicationId];
            List<Application_Participant__c> appParticpant = new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantByApplicationIdSign(apps.Application__c,true);    
            
            String packagesData=getInflight(applicationId,'SigningHUBPackages');     
            Map<String,Object> packagesMaps = (Map<String,object>) JSON.deserializeUntyped(packagesData);
            packageid=String.ValueOf(packagesMaps.get('package_id'));
            
            String signingHUBDocumnet=getInflight(applicationId,'SigningHUBDocumnet');  
            Map<String,Object> signingHUBDocumnetMaps = (Map<String,object>) JSON.deserializeUntyped(signingHUBDocumnet);
            documentIdlist.add(String.ValueOf(signingHUBDocumnetMaps.get('documentid')));

            String signatoryCardDocument=getInflight(applicationId,'signatoryCard');  
            Map<String,Object> signatoryCardDocumentMaps = (Map<String,object>) JSON.deserializeUntyped(signatoryCardDocument);
            documentIdlist.add(String.ValueOf(signatoryCardDocumentMaps.get('documentid')));
            
            if(appParticpant[0].Application__r.AOB_Schema_Code__c=='OD001' || appParticpant[0].Application__r.AOB_Schema_Code__c=='OD005'){  
                String signingHUBDocumnetFaxEmail=getInflight(applicationId,'SigningHUBDocumnetFaxEmail');  
                Map<String,Object> signingHUBDocumnetFaxEmailMaps = (Map<String,object>) JSON.deserializeUntyped(signingHUBDocumnetFaxEmail);
                documentIdlist.add(String.ValueOf(signingHUBDocumnetFaxEmailMaps.get('documentid')));
            }
            
            String signingHUBDocumnetonline=getInflight(applicationId,'SigningHUBDocumnetonline');  
            Map<String,Object> signingHUBDocumnetonlineMaps = (Map<String,object>) JSON.deserializeUntyped(signingHUBDocumnetonline);
            documentIdlist.add(String.ValueOf(signingHUBDocumnetonlineMaps.get('documentid')));
            
           
            List<Integer> statusCodesdata=  new List<Integer>();
            for(String s:documentIdlist){
                documnetId=s;
                for(Application_Participant__c app:appParticpant){
                    AOB_BOTS_DTO_Digitalsign digitalSign= new AOB_BOTS_DTO_Digitalsign();
                    digitalSign.search_text='(Sig|'+app.CNGCU_Email__c+')';
                    digitalSign.placement='BOTTOM';
                    digitalSign.order=count;
                    digitalSign.field_type='ELECTRONIC_SIGNATURE';
                    digitalSign.multiline='false';
                    digitalSign.value='false';
                    digitalSign.max_length=100;
                    digitalSign.validation_rule='MANDATORY';
                    digitalSign.radio_group_name='RadioButton_Group1';
                    digitalSign.placeholder='Department Head';
                    digitalSign.format='yyyy-mm-dd';
                    cls_font font= new cls_font();
                    font.name='HELVETICA';
                    font.size=12;
                    font.embedded_size=10;
                    digitalSign.font=font;
                    cls_dimensions dimension= new cls_dimensions();
                    dimension.width=90;
                    dimension.height=50;
                    digitalSign.dimensions=dimension;
                    jsonBody=Json.serialize(digitalSign);
                    responseStatusCode=AOB_BOTS_API_DigitalSign.digitalSteps(jsonBody,documnetId, packageid);
                    count=count+1;
                    statusCodesdata.add(responseStatusCode);
                }
                count=1;
            }
            return responseStatusCode;
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_SigningHUB.sendDigitalSign',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    
    /**
* @description This method is used as call the sendDigitalSignCheckbox api
* @param  applicationId
* @return Integer
*/
    @AuraEnabled
    public Static Integer sendDigitalSignCheckbox(String applicationId){
        try{
            String jsonBody;
            String documnetId;
            String packageid; 
            Integer responseStatusCode;
            Integer count=1;
            List<String> documentIdlist= new List<String>();
            
            Application_Participant__c apps = [select Id,CNGCU_Email__c,Application__c,Application__r.AOB_Schema_Code__c from Application_Participant__c where id =:applicationId];
            List<Application_Participant__c> appParticpant = new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantByKeyContact(apps.Application__c,true);    
            
            String packagesData=getInflight(applicationId,'SigningHUBPackages');     
            Map<String,Object> packagesMaps = (Map<String,object>) JSON.deserializeUntyped(packagesData);
            packageid=String.ValueOf(packagesMaps.get('package_id'));
            
            String signingHUBDocumnet=getInflight(applicationId,'SigningHUBDocumnet');  
            Map<String,Object> signingHUBDocumnetMaps = (Map<String,object>) JSON.deserializeUntyped(signingHUBDocumnet);
            documentIdlist.add(String.ValueOf(signingHUBDocumnetMaps.get('documentid')));
            
            List<Integer> statusCodesdata=  new List<Integer>();
            for(String s:documentIdlist){
                documnetId=s;
                if(appParticpant.size()>0){
                    AOB_BOTS_DTO_Digitalsign digitalSign= new AOB_BOTS_DTO_Digitalsign();
                    digitalSign.search_text='(Chk)';
                    digitalSign.placement='BOTTOM';
                    digitalSign.order=count;
                    digitalSign.field_type='CHECKBOX';
                    digitalSign.multiline='false';
                    digitalSign.value='false';
                    digitalSign.max_length=100;
                    digitalSign.validation_rule='MANDATORY';
                    digitalSign.radio_group_name='RadioButton_Group1';
                    digitalSign.placeholder='Department Head';
                    digitalSign.format='yyyy-mm-dd';
                    cls_font font= new cls_font();
                    font.name='HELVETICA';
                    font.size=12;
                    font.embedded_size=10;
                    digitalSign.font=font;
                    cls_dimensions dimension= new cls_dimensions();
                    dimension.width=90;
                    dimension.height=50;
                    digitalSign.dimensions=dimension;
                    jsonBody=Json.serialize(digitalSign);
                    responseStatusCode=AOB_BOTS_API_DigitalSign.digitalSteps(jsonBody,documnetId, packageid);
                    statusCodesdata.add(responseStatusCode); 
                }else{
                    
                    return 200;
                }
                count=1;
            }
            return responseStatusCode;
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_SigningHUB.sendDigitalSignCheckbox',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    
    
    /**
* @description This method is used as call the shareDocument api
* @param  applicationId
* @return Integer
*/
    @AuraEnabled
    public static Integer shareDocument(String applicationId){
        try{
            String packagesData=getInflight(applicationId,'SigningHUBPackages');     
            Map<String,Object> packagesMaps = (Map<String,object>) JSON.deserializeUntyped(packagesData);
            String packageId=String.ValueOf(packagesMaps.get('package_id'));
            AOB_BOTS_API_ShareDocuments customerServiceCall = new AOB_BOTS_API_ShareDocuments(packageId);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTS_API_ShareDocuments.SERVICE_NAME);
            customerServiceCall.process(obj);
            insert obj;
            return customerServiceCall.getResponseStatusCode();
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_SigningHUB.shareDocument',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        
    }
    
    /**
* @description This method is used as call the generateLink api
* @param  applicationId
* @return Integer
*/
    @AuraEnabled
    public static Integer generateLink(String applicationId){
        try{
            String redirecturl=system.label.signingHUB;
            integer responseCode;
            List<Application_Participant__c> appParticpant =new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantById(applicationId);
            List<Application_Participant__c> directorDataList = new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantByApplicationIdSign(appParticpant[0].Application__c,true); 
            List<Application__c> apps = new AOB_BOTS_SEL_Application().selectAppsById(appParticpant[0].Application__c);
            
            String packagesData=getInflight(applicationId,'SigningHUBPackages');     
            Map<String,Object> packagesMaps = (Map<String,object>) JSON.deserializeUntyped(packagesData);
            String packageId=String.ValueOf(packagesMaps.get('package_id'));
            String signingHUBDocumnet=getInflight(applicationId,'SigningHUBDocumnet');     
            Map<String,Object> signingHUBDocumnetMaps = (Map<String,object>) JSON.deserializeUntyped(signingHUBDocumnet);
            List<AOB_BOTS_DocumentLink> docLinkList= new List<AOB_BOTS_DocumentLink>();
            for(Application_Participant__c app:directorDataList){
                AOB_BOTS_DTO_GenerateLink generate= new AOB_BOTS_DTO_GenerateLink();
                generate.package_id=packageId;
                generate.language='en-US';
                generate.user_email=app.CNGCU_Email__c;
                generate.callback_url=redirecturl+app.id;
                generate.collapse_panels='true';
                String jsonBody=Json.serialize(generate);
                AOB_BOTS_API_SignGenerateLink customerServiceCall = new AOB_BOTS_API_SignGenerateLink(jsonBody);
                CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTS_API_SignGenerateLink.SERVICE_NAME);
                customerServiceCall.process(obj);
                String responsebody=customerServiceCall.getResponseBody();
                responsebody=responsebody.removeStart('"');
                responsebody=responsebody.removeEnd('"');
                
                responseCode=customerServiceCall.getResponseStatusCode();
                if(responseCode==200){
                    AOB_BOTS_DocumentLink docLink= new AOB_BOTS_DocumentLink();
                    docLink.partid=app.id;
                    docLink.doclink=responsebody;
                    docLinkList.add(docLink);  
                }
                
            }
            if(responseCode==200){
                if(!apps.isEmpty()){
                    Map<String, Object> jsonMAp ;
                    if(String.isBlank(apps[0].Inflight__c)){
                        jsonMAp = new Map<String, Object>();
                        jsonMap.put('SigningHUBDocumnetLINK',docLinkList);
                        apps[0].Inflight__c='{"SigningHUBDocumnetLINK":'+docLinkList+'}';
                    }
                    else{ 
                        jsonMAp = (Map<String, Object>)System.JSON.deserializeUntyped(apps[0].Inflight__c);
                        jsonMap.put('SigningHUBDocumnetLINK',docLinkList);
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
            
            return responseCode;
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_SigningHUB.generateLink',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        
    } 
    
    /**
    * @description This method is used to get link from application id 
    * @param  applicationId
    * @return String
    */
    @AuraEnabled
    public static String getLink(String applicationId){
        String docLink; 
        List<Application_Participant__c> appParticpant =new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantById(applicationId);  
        List<Application__c> apps = [select Id,Inflight__c,AOB_SigningInstructions__c from Application__c where id=:appParticpant[0].Application__c ];

        String signingHUBDocumnetLINK=getInflight(applicationId,'SigningHUBDocumnetLINK');     
        List<object> objectLINK= (List<Object>)System.JSON.deserializeUntyped(signingHUBDocumnetLINK);
        for(object ob:objectLINK){ 
            Map<String, Object> m = (Map<String, Object>)ob;
            if((String)m.get('partid')==applicationId){
                docLink=(String)m.get('doclink'); 
                break;
            }
        }
        apps[0].AOB_SigningInstructions__c=docLink;
        update apps;
        return docLink;
    } 
    
    /**
    * @description This method is used to update Status 
    * @param applicationId
    */
    @AuraEnabled
    public static void updateSigningHuBStatus(String applicationId){
        Application_Participant__c appParticpant = [select Id,AOB_Stage__c,Application__c,AOB_Role__c,CNGCU_Email__c,AOB_FullName__c from Application_Participant__c where Id =:applicationId];
        if(appParticpant!=null){
            appParticpant.AOB_Stage__c='Signing Hub';
            update appParticpant;
        }
    }
    
    /**
* @description This method is used as call the getInflight api
* @param appId
* @param screenName
* @return String
*/
    @AuraEnabled
    public static String getInflight(String appId, String screenName){
        String inflightData;
        try{
            List<Application_Participant__c> appParticpant = [select Id,Application__c from Application_Participant__c where Id =:appId];
            List<Application__c> apps = [select Id,Inflight__c from Application__c where id=:appParticpant[0].Application__c ];
            if(String.isNotEmpty(apps[0].Inflight__c)){
                Map<String, Object> jsonData = (Map<String, Object>)system.JSON.deserializeUntyped(apps[0].Inflight__c);
                for(string screen : jsonData.keyset()){
                    if(screen == screenName){
                        inflightData = System.JSON.serialize(jsonData.get(screen));
                    }
                }
            }
        }
        catch (Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_SigningHUB.getInflight',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        
        return inflightData;
    }
    
    /**
    * @description gets the SchemCode  from application id 
    * @param applicationId
    * @return String
    */
    @AuraEnabled
    public static String getSchemCode(String applicationId){ 
          List<Application_Participant__c> appParticpant = [select Id,Application__c,Application__r.AOB_Schema_Code__c from Application_Participant__c where Id =:applicationId];
          return  appParticpant[0].Application__r.AOB_Schema_Code__c;
    }
    
    /**
    * @description wrapper class for packages
    */
    public class AOB_BOTS_DTO_Packages{
        
        public String package_name;
        public String workflow_mode;
        public String workflow_type;
        
    }

    /**
* @description wrapper class for add packages
*/
    
    public Class AOB_BOTS_DTO_AddPackages{
        
        public string user_email;
        Public String user_name;
        public String role;
        public Boolean email_notification;
        public Integer signing_order;
        
    }
    /**
* @description This method is used as call the getTemplateData api
* @author Dayakar 
* @date Jan 5th 2021
* @return String
*/
    @AuraEnabled
    public static String  getTemplateData(){
        try{
            Integer count=1;
            List<AOB_BOTS_Template> templatelist= new List<AOB_BOTS_Template>();
            List<DocFusionTemplates__mdt> Docmdtlist=[select id,GUID__c,Template_Name__c from DocFusionTemplates__mdt];
            for(DocFusionTemplates__mdt doc:Docmdtlist){
                AOB_BOTS_Template temp= new AOB_BOTS_Template();
                temp.guid=doc.GUID__c;
                temp.count=count;
                temp.tempName=doc.Template_Name__c;
                count=count+1;
                templatelist.add(temp);
            }      
            return Json.serialize(templatelist);
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_SigningHUB.getTemplateData',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    /**
* @description This method is used as call the docFusionCallout api
* @param  appData
* @return String
*/
    @AuraEnabled(cacheable=false)
    public static string docFusionCallout(string appData){
        try{
            Id recordTypeIdparticipant = Schema.SObjectType.Application_Document__c.getRecordTypeInfosByDeveloperName().get('AOB_BotswanaBCCApplication').getRecordTypeId();            
            Map<String,Object> appDataJSON = new Map<String,object>();
            appDataJSON = (Map<String,Object>)JSON.deserializeUntyped(appData);
            String templateGUID = String.valueOf(appDataJSON.get('templateGUID'));
            String applicationpartId = String.valueOf(appDataJSON.get('applicationId'));
            List<Application_Participant__c> appParticpant = [select Id,Application__c from Application_Participant__c where Id =:applicationpartId];
            String applicationId =appParticpant[0].Application__c;
            String response;
            List<DocFusionTemplates__mdt> Docmdtlist=[select id,GUID__c,Template_Name__c from DocFusionTemplates__mdt where GUID__c=:templateGUID];
            List<Application_Document__c> appdocumentlist=[select id,Document_Type__c,Application__c from Application_Document__c where Application__c=:applicationId];
            
            List<String> documentlist= new List<String>();
            for(Application_Document__c pd:appdocumentlist){
                documentlist.add(pd.Document_Type__c);
            }
            
            if(!documentlist.contains(Docmdtlist[0].Template_Name__c)){        
                try{
                    response = AOB_BOTS_UTIL_DocFusion.makeCallout(templateGUID,applicationId);
                    Map<string,Object> responseJSON = (Map<String,Object>)JSON.deserializeUntyped(response);
                    if(response!=null){
                        List<Application_Document__c> appDocs = new List<Application_Document__c>();
                        Application_Document__c appDocRec = new Application_Document__c(Application__c=applicationId,Document_Type__c=Docmdtlist[0].Template_Name__c,Application_Participant__c=applicationpartId,RecordTypeId=recordTypeIdparticipant);
                        appDocs.add(appDocRec);
                        insert appDocs;
                        
                        sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(new List<SObjectType> { Application_Document__c.SObjectType });
                        uow = new sbgplatform.fflib_SObjectUnitOfWork(new List<SObjectType> { ContentVersion.sObjectType });
                        AOB_BOTS_SRV_Application.newInstance().saveDocuments(
                            appDocs[0].Id,
                            new List<ContentVersion>{new ContentVersion(
                                Title = responseJSON.get('TemplateName')+'_'+applicationId,
                                VersionData = EncodingUtil.base64Decode((String)responseJSON.get('DocumentData')),
                                Description = 'docFusion',
                                pathOnClient = responseJSON.get('TemplateName')+'_'+applicationId +'.pdf'
                            )}, 
                            uow
                        );
                        uow.commitWork();
                    }
                }
                catch(exception e){
                    AuraHandledException ex = new AuraHandledException(e.getMessage());
                    ex.setMessage(e.getMessage());
                } 
            }else{
                
                return 'already Document exist';
            }
            return response;
        }catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_SRV_SigningHUB.docFusionCallout',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    /**
* @description wrapper for GetAccessToken
*/
    public class GetAccessToken{
        public String access_token;
        public String token_type;
        public Integer expires_in;
        public String refresh_token;
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
* @description wrapper for cls_font
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
    }
    /**
* @description wrapper for AOB_BOTS_Template
*/
    public class AOB_BOTS_Template{
        public String guid; 
        public Integer count;
        public String tempName;
    }
    
    /**
    * @description wrapper for AOB_BOTS_DocumentLink
    */
    public class AOB_BOTS_DocumentLink{
        public String partid;
        public String doclink;
        
    }
}