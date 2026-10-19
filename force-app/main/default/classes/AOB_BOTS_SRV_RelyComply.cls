/**
* @description This class is used as call the relaycomply api
* @author Dayakar 
* @date Jan 5th 2021
*/
public without sharing class AOB_BOTS_SRV_RelyComply{
   
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_BOTS_SRV_RelyComply');
    
 /**
* @description This method is used as call the accessToken api
* @return string
*/
    public static string getAccessToken(){
        try{
            AOB_BOTS_API_RelyComplyAccessToken customerServiceCall = new AOB_BOTS_API_RelyComplyAccessToken();
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTS_API_RelyComplyAccessToken.SERVICE_NAME);
            customerServiceCall.process(obj);
            String accesToken;
            if(customerServiceCall.getResponseStatusCode()==200){
                GetAccessToken accessToken= (GetAccessToken) System.JSON.deserialize(customerServiceCall.getResponseBody(), GetAccessToken.class);
                accesToken=accessToken.access_token;
            }
            return accesToken;
        }catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'getAccessToken',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    /**
* @description This method is used as call the relaycomply api and createBusinessRely
* @param applicationid String
* @return Integer
*/
    @AuraEnabled
    public static Integer createBusinessRely(string applicationid){
        try{
            String jsonBody;
            String businessName; 
            List<Application__c> apps = New AOB_BOTS_SEL_Application().selectAppsById(applicationid);
            String presenceCountry;
            if(String.isEmpty(presenceCountry)){
            if(apps[0].AOB_PresenceinCountry__c=='Local Company'){
                
                presenceCountry='Resident';
                
            }if(apps[0].AOB_PresenceinCountry__c=='Foreign Company'){
                
                 presenceCountry='Non-Resident';
                
            }
            }
            AOB_ReferencedData__c rference=[SELECT AOB_Code__c,AOB_CountryCode__c,AOB_ProductCategory__c,Name FROM AOB_ReferencedData__c where AOB_CountryCode__c=:presenceCountry and Name=:apps[0].Entity_Type_Sub_Category__c limit 1];
           
            AOB_ReferencedData__c rference1=[SELECT AOB_Code__c,AOB_CountryCode__c,AOB_ProductCategory__c,Name,AOB_SAPField__c FROM AOB_ReferencedData__c  where AOB_SAPField__c=:apps[0].AOB_TertiarySICCode__c limit 1];
            
            if(apps[0].AOB_Schema_Code__c=='OD001' || apps[0].AOB_Schema_Code__c=='OD005'){
                businessName=apps[0].AOB_BusinessLegalName__c;
            }else{
                
                businessName=apps[0].AOB_GroupName__c;
            }   


            AOB_BOTS_CreateBusiness createBusiness=new AOB_BOTS_CreateBusiness();
            AOB_BOTS_DTO_Detail  details= new AOB_BOTS_DTO_Detail();
            AOB_BOTS_DTO_Variables  variables=new AOB_BOTS_DTO_Variables();
            AOB_BOTS_DTO_Input  input= new AOB_BOTS_DTO_Input();
            
            
            createBusiness.event='CreateCustomer';
            input.identifier=AOB_Utils.generateGUID();
            input.type='organisation';
            input.businessName=businessName;
            input.idDocumentCode=apps[0].AOB_RegistrationNumber__c;
            input.nationality='BW';
            input.residence='BW';
            
            List<Data> listdata=new List<Data>();
            Data d= new Data();
            d.key='sbg_client_type_code'; 
            if(rference!=null){
            d.value=rference.AOB_Code__c; 
            }
            listdata.add(d); 
            Data d1= new Data();
            d1.key='sbg_industry_category';
            if(rference1!=null){
            d1.value=rference1.AOB_Code__c;   
            }
            listdata.add(d1);    
            Data d2= new Data();
            d2.key='sbg_product';    
            d2.value='Transactional';    
            listdata.add(d2);    
            Data d3= new Data();
            d3.key='sbg_approved_exchange';    
            d3.value=apps[0].AOB_ListedonanApprovedExchange__c;    
            listdata.add(d3);    
            Data d4= new Data();
            d4.key='sbg_ultimate_beneficial_owner';
            if(rference!=null){
                if(rference.AOB_ProductCategory__c=='Yes'){
                    d4.value='Yes'; 
                }else{
                    d4.value='No'; 
                }
            }
            listdata.add(d4); 
            input.data=listdata;
            variables.input=input;
            details.variables=variables;
            details.graphql='mutation(\n $input: CreateCustomerInput!\n) {\n\n  createCustomer(\n    input: $input\n  ) {\n\n    customer {\n      id\n      created\n      identifier\n      businessName\n     }\n  }\n}';
            createBusiness.detail=details;
            jsonBody=Json.serialize(createBusiness);
            AOB_BOTS_API_RelyComply customerServiceCall = new AOB_BOTS_API_RelyComply(jsonBody);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTS_API_RelyComply.SERVICE_NAME);
            customerServiceCall.process(obj);
            insert obj;
            if(customerServiceCall.getResponseStatusCode()==200){
                String appData=customerServiceCall.getResponseBody();
                Map<String,Object> customerMaps = (Map<String,object>)JSON.deserializeUntyped(appData);
                String createCustomer=json.serialize(customerMaps.get('createCustomer'));
                Map<String,Object> customerMap = (Map<String,object>)JSON.deserializeUntyped(createCustomer);
                String Customer=json.serialize(customerMap.get('customer'));
                Map<String,Object> customeriden = (Map<String,object>)JSON.deserializeUntyped(Customer);
                apps[0].AOB_GUID__c=(String)customeriden.get('identifier');
                update apps;
                updateInflightWithkey(applicationid,appData,'createBusinessRely'); 
            }
            return customerServiceCall.getResponseStatusCode(); 
        }catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'createBusinessRely',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
   /**
* @description This method is used as call the relaycomply api and createcustomerRelay
* @param applicationid String
* @return Integer
*/
    @AuraEnabled
    public static Integer createCustomerRely(string applicationid){
        try{
            List<Application_Participant__c> Directordatalist = New AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantByApplicationId(applicationId);
            List<Application_Participant__c> updatePartlist= new List<Application_Participant__c>();
            String responseBody=AOB_BOTS_DTO_CreateCustomer.createCustomer(applicationid);
            Map<String,Object> respondata = (Map<String,object>)JSON.deserializeUntyped(responseBody);
            String jsonBody=Json.serialize(respondata.get('jsonbody'));
            List<Object> updateList=(List<Object>)respondata.get('applist');
            for(Application_Participant__c ap:Directordatalist){
                for(object ob:updateList){
                    Map<String, Object> m = (Map<String, Object>)ob;
                    if((String)m.get('Id')==ap.id){
                        ap.AOB_External_GUID__c=(String)m.get('AOB_External_GUID__c');
                        updatePartlist.add(ap);
                    }
                }
            }
            AOB_BOTS_API_RelyComply customerServiceCall = new AOB_BOTS_API_RelyComply(jsonBody);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTS_API_RelyComply.SERVICE_NAME);
            customerServiceCall.process(obj);
            insert obj;
            if(customerServiceCall.getResponseStatusCode()==200){
                String appData=customerServiceCall.getResponseBody();
                updateInflightWithkey(applicationid,appData,'createCustomerRely');
                update updatePartlist;
            }
            return customerServiceCall.getResponseStatusCode(); 
        }catch(Exception ex){
           LOGGER.error(ex.getMessage(), new String[] {'createCustomerRely',ex.getMessage()}, ex);
           throw new AuraHandledException(ex.getMessage());  
        }
    }
       /**
* @description This method is used as call the relaycomply api and createRelationshipRely
* @param applicationid String
* @return Integer
*/
    @AuraEnabled
    public static Integer createRelationshipRely(String applicationid){
        try{
            String jsonBody;
            string customerdata;
            Integer responseCode;
            List<Integer> statusCodelist= new List<Integer>();
            String createBusinessRely=AOB_BOTS_SRV_RelyComply.getInflight(applicationId,'createCustomerRely');
            Map<String,Object> createBusinessRelyMaps = (Map<String,object>) JSON.deserializeUntyped(createBusinessRely);
            String upsertCustomers=json.serialize(createBusinessRelyMaps.get('upsertCustomers'));
            Map<String,Object> upsertCustomersMaps = (Map<String,object>) JSON.deserializeUntyped(upsertCustomers);
            String Inititordata=Json.serialize(upsertCustomersMaps.get('customers'));
            List<object> objects = (List<object>)System.JSON.deserializeUntyped(Inititordata);
            for(object o:objects){
                Map<String, Object> m = (Map<String, Object>)o;
                String customer=json.serialize(m.get('customer'));
                Map<String,Object> customerMaps = (Map<String,object>)JSON.deserializeUntyped(customer);
                customerdata=(String)customerMaps.get('id');
                jsonBody=AOB_BOTS_DTO_CreateRelationShipRely.createRelationship(applicationid,customerdata);
                AOB_BOTS_API_RelyComply customerServiceCall = new AOB_BOTS_API_RelyComply(jsonBody);
                CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTS_API_RelyComply.SERVICE_NAME);
                customerServiceCall.process(obj);
                responseCode=customerServiceCall.getResponseStatusCode(); 
                statusCodelist.add(responseCode);
            }
            return responseCode;  
        }catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'createRelationshipRely',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
           /**
* @description This method is used as call the relaycomply api and createAssementRely
* @param applicationid String
* @return Integer
*/
    @AuraEnabled
    public static Integer createAssementRely(String applicationid){
        try{
            String jsonBody;
            string customerdata;
            Integer responseCode;
            List<Integer> statusCodelist= new List<Integer>();
            List<String> assesmentlist= new List<String>();
            String createBusinessRely=AOB_BOTS_SRV_RelyComply.getInflight(applicationId,'createCustomerRely');
            Map<String,Object> createBusinessRelyMaps = (Map<String,object>) JSON.deserializeUntyped(createBusinessRely);
            String upsertCustomers=json.serialize(createBusinessRelyMaps.get('upsertCustomers'));
            Map<String,Object> upsertCustomersMaps = (Map<String,object>) JSON.deserializeUntyped(upsertCustomers);
            String Inititordata=Json.serialize(upsertCustomersMaps.get('customers'));
            List<object> objects = (List<object>)System.JSON.deserializeUntyped(Inititordata);
            for(object o:objects){
                Map<String, Object> m = (Map<String, Object>)o;
                String customer=json.serialize(m.get('customer'));
                Map<String,Object> customerMaps = (Map<String,object>)JSON.deserializeUntyped(customer);
                customerdata=(String)customerMaps.get('id');
                jsonBody=AOB_BOTS_DTO_createAssessmentRely.creatAssement(customerdata);
                AOB_BOTS_API_RelyComply customerServiceCall = new AOB_BOTS_API_RelyComply(jsonBody);
                CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTS_API_RelyComply.SERVICE_NAME);
                customerServiceCall.process(obj);
                responseCode=customerServiceCall.getResponseStatusCode(); 
                if(customerServiceCall.getResponseStatusCode()==200){
                    String appData=customerServiceCall.getResponseBody();
                    Map<String,Object> createassementmap = (Map<String,object>)JSON.deserializeUntyped(appData);
                    String createAssessment=json.serialize(createassementmap.get('createAssessment'));
                    Map<String,Object> assementmap = (Map<String,object>)JSON.deserializeUntyped(createAssessment);
                    String createAssessmentids=json.serialize(assementmap.get('assessment'));
                    Map<String,Object> createAssessmentidsmap = (Map<String,object>)JSON.deserializeUntyped(createAssessmentids);
                    assesmentlist.add((String)createAssessmentidsmap.get('id'));
                }
                statusCodelist.add(responseCode);
            }
            String appdatalist=Json.serialize(assesmentlist);
            updateInflightWithkey(applicationid,appdatalist,'createAssementRely');
            return responseCode; 
        }catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'createAssementRely',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
 /**
* @description This method is used as call the relaycomply api and createBusinessAssement
* @param applicationid String
* @return Integer
*/
    @AuraEnabled
    public static Integer createBusinessAssement(String applicationid){
        try{
            String customerdata;
            String createBusinessRely=AOB_BOTS_SRV_RelyComply.getInflight(applicationId,'createBusinessRely');
            Map<String,Object> customerMaps;
            if(!String.isEmpty(createBusinessRely)){
                Map<String,Object> createBusinessRelyMaps = (Map<String,object>) JSON.deserializeUntyped(createBusinessRely);
                String createCustomerBusiness=Json.serialize(createBusinessRelyMaps.get('createCustomer'));
                Map<String,Object> createCustomerBusinessMaps = (Map<String,object>) JSON.deserializeUntyped(createCustomerBusiness);
                String customer=Json.serialize(createCustomerBusinessMaps.get('customer'));
                customerMaps = (Map<String,object>) JSON.deserializeUntyped(customer);
            }
            customerdata=(String)customerMaps.get('id');
            String jsonBody=AOB_BOTS_DTO_createAssessmentRely.creatAssement(customerdata);
            AOB_BOTS_API_RelyComply customerServiceCall = new AOB_BOTS_API_RelyComply(jsonBody);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTS_API_RelyComply.SERVICE_NAME);
            customerServiceCall.process(obj);
            if(customerServiceCall.getResponseStatusCode()==200){
                String createAssementRely=AOB_BOTS_SRV_RelyComply.getInflight(applicationId,'createAssementRely');
                String appData=customerServiceCall.getResponseBody();
                Map<String,Object> createassementmap = (Map<String,object>)JSON.deserializeUntyped(appData);
                String createAssessment=json.serialize(createassementmap.get('createAssessment'));
                Map<String,Object> assementmap = (Map<String,object>)JSON.deserializeUntyped(createAssessment);
                String createAssessmentids=json.serialize(assementmap.get('assessment'));
                Map<String,Object> createAssessmentidsmap = (Map<String,object>)JSON.deserializeUntyped(createAssessmentids);
                createAssementRely=createAssementRely.removeEnd(']');
                createAssementRely=createAssementRely+',"'+(String)createAssessmentidsmap.get('id')+'"]';
                updateInflightWithkey(applicationid,createAssementRely,'createAssementRely');
                
            }
            
            return customerServiceCall.getResponseStatusCode();
        }catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'createBusinessAssement',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
 /**
* @description This method is used as call the relaycomply api and createRetriveAsRely
* @param applicationid String
* @return String
*/
    @AuraEnabled
    public static String createRetriveAsRely(String applicationid){
        
        try{
            String jsonBody;
            string assesementid;
            Integer responseCode;
            List<AOB_BOTS_DTO_RelyStatus> RelyStatusList= new List<AOB_BOTS_DTO_RelyStatus>();
            String createRetriveAsRely=AOB_BOTS_SRV_RelyComply.getInflight(applicationId,'createAssementRely');
            List<Object> objects = (List<object>)System.JSON.deserializeUntyped(createRetriveAsRely); 
            for(Object ids:objects){
                assesementid=String.valueOf(ids);
                jsonBody=AOB_BOTS_DTO_RetriveAssesment.RetriveAssement(assesementid);
                AOB_BOTS_API_RelyComply customerServiceCall = new AOB_BOTS_API_RelyComply(jsonBody);
                CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTS_API_RelyComply.SERVICE_NAME);
                customerServiceCall.process(obj);
                responseCode=customerServiceCall.getResponseStatusCode();
                String appData=customerServiceCall.getResponseBody();
                if(customerServiceCall.getResponseStatusCode()==200){
                    Map<String,Object> assessmentsmapresponse = (Map<String,object>)JSON.deserializeUntyped(appData);   
                    String assessmentsstr=Json.serialize(assessmentsmapresponse.get('assessments'));
                    Map<String,Object> assessmentsMap = (Map<String,object>)JSON.deserializeUntyped(assessmentsstr);
                    String edges=Json.serialize(assessmentsMap.get('edges'));
                    edges=edges.removeStart('[');
                    edges=edges.removeEnd(']');
                    Map<String,Object> edgesMap = (Map<String,object>)JSON.deserializeUntyped(edges);
                    String node=Json.serialize(edgesMap.get('node'));
                    Map<String,Object> nodeMap = (Map<String,object>)JSON.deserializeUntyped(node);
                    String customerid= Json.serialize(nodeMap.get('customer'));
                    Map<String,Object> customerMap = (Map<String,object>)JSON.deserializeUntyped(customerid);   
                    AOB_BOTS_DTO_RelyStatus status= new AOB_BOTS_DTO_RelyStatus();
                    status.Status=(String)nodeMap.get('status'); 
                    if(nodeMap.get('complete')!=null){
                        status.complete=String.valueof(nodeMap.get('complete'));
                    } 
                    status.customerId=(string)customerMap.get('id');
                    
                    String screenings= Json.serialize(nodeMap.get('screenings'));
                    if(!String.isEmpty(screenings)){
                        Map<String,Object> customerMaps = (Map<String,object>)JSON.deserializeUntyped(screenings);   
                        String edgesc=Json.serialize(customerMaps.get('edges'));
                        List<object> objectsc = (List<object>)System.JSON.deserializeUntyped(edgesc);
                        for(object o:objectsc){
                            Map<String, Object> m = (Map<String, Object>)o;
                            String nodesc= Json.serialize(m.get('node'));
                            Map<String,Object> nodescMap = (Map<String,object>)JSON.deserializeUntyped(nodesc);
                            String screeningConfig= Json.serialize(nodescMap.get('screeningConfig'));
                            Map<String,Object> screeningConfigMap = (Map<String,object>)JSON.deserializeUntyped(screeningConfig);
                            if((String)screeningConfigMap.get('name')=='bw_business_banking_pep_screening'){
                                status.bw_salesforce_pep_screening=(String)nodescMap.get('outcome');
                            }
                            if((String)screeningConfigMap.get('name')=='bw_business_banking_sanctions_screening'){
                                status.bw_salesforce_sanctions_screening=(String)nodescMap.get('outcome');
                            }
                            if((String)screeningConfigMap.get('name')=='bw_business_banking_cra_high_risk_review'){
                                status.bw_salesforce_cra_high_risk_review=(String)nodescMap.get('outcome');
                            }
                                
                        }
                        
                    }
                    
                    RelyStatusList.add(status);
                }
            }
            String appData=Json.serialize(RelyStatusList);
            updateInflightWithkey(applicationid,appData,'RelyStatusList');
            return appData;
        }catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'createRetriveAsRely',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
  /**
* @description This method is used as call the relaycomply api and updateInflightWithkey
* @param applicationId String
* @param appData String
* @param ScreenName String
*/  
    @AuraEnabled
    public static void updateInflightWithkey(String applicationId,String appData,String ScreenName){
        try{
            List<Application__c> apps = New AOB_BOTS_SEL_Application().selectAppsById(applicationId);
            if(!apps.isEmpty()){
                Map<String, Object> jsonMAp ;
                if(String.isBlank(apps[0].Inflight__c)){
                    jsonMAp = new Map<String, Object>();
                    jsonMap.put(ScreenName,appData);
                    apps[0].Inflight__c='{"'+ScreenName+'":'+appData+'}';
                }
                else{ 
                    jsonMAp = (Map<String, Object>)System.JSON.deserializeUntyped(apps[0].Inflight__c);
                    jsonMap.put(ScreenName,System.JSON.deserializeUntyped(appData));
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
        }catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'updateInflightWithkey',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
     /**
* @description This method is used as call the relaycomply api and getInflight
* @param appId String
* @param screenName String
* @return String
*/ 
    @AuraEnabled
    public static String getInflight(string appId, string screenName){
        try{
            String inflightData;
            try{
                List<Application__c> apps = New AOB_BOTS_SEL_Application().selectAppsById(appId);
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
                throw new AuraHandledException(ex.getMessage());  
            }
            
            return inflightData;
        }catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'getInflight',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
   /**
* @description This method is used as call the relaycomply api and updateRelyStatus
* @param applicationid string
*/  
    @AuraEnabled
    public static void updateRelyStatus(String applicationid){
        try{
            List<Application_Participant__c> Directordatalist = New AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantByApplicationId(applicationId);
            Application__c apps = New AOB_BOTS_SEL_Application().selectAppById(applicationId);
            List<Application_Participant__c> updateStatusList= new List<Application_Participant__c>();
            String createBusinessRely=AOB_BOTS_SRV_RelyComply.getInflight(applicationId,'createCustomerRely');
            Map<String,Object> createBusinessRelyMaps = (Map<String,object>) JSON.deserializeUntyped(createBusinessRely);
            String upsertCustomers=json.serialize(createBusinessRelyMaps.get('upsertCustomers'));
            Map<String,Object> upsertCustomersMaps = (Map<String,object>) JSON.deserializeUntyped(upsertCustomers);
            String Inititordata=Json.serialize(upsertCustomersMaps.get('customers'));
            List<object> objectscustomers = (List<object>)System.JSON.deserializeUntyped(Inititordata);
            String customerdata;
            String createBusinessRelys=AOB_BOTS_SRV_RelyComply.getInflight(applicationId,'createBusinessRely');
            Map<String,Object> customerMapss;
            if(!String.isEmpty(createBusinessRelys)){
                Map<String,Object> createBusinessRelyMapss = (Map<String,object>) JSON.deserializeUntyped(createBusinessRelys);
                String createCustomerBusiness=Json.serialize(createBusinessRelyMapss.get('createCustomer'));
                Map<String,Object> createCustomerBusinessMaps = (Map<String,object>) JSON.deserializeUntyped(createCustomerBusiness);
                String customer=Json.serialize(createCustomerBusinessMaps.get('customer'));
                customerMapss = (Map<String,object>) JSON.deserializeUntyped(customer);
            }
            customerdata=(String)customerMapss.get('id');
            String createRetriveAsRely=AOB_BOTS_SRV_RelyComply.getInflight(applicationId,'RelyStatusList');
            List<Object> objectsRelyStatusList = (List<object>)System.JSON.deserializeUntyped(createRetriveAsRely); 
            for(object ob:objectsRelyStatusList ){
                Map<String, Object> rely = (Map<String, Object>)ob;
                if(customerdata==rely.get('customerId')){
                    apps.AOB_Rely_Comply_Status__c=(String)rely.get('Status');
                    apps.AOB_PEP_Status__c=(String)rely.get('bw_salesforce_pep_screening');
                    apps.AOB_Sanction_Status__c=(String)rely.get('bw_salesforce_sanctions_screening');
                    apps.AOB_CRAAssessment__c=(String)rely.get('bw_salesforce_cra_high_risk_review');
                    
                }
                for(object o:objectscustomers){
                    Map<String, Object> m = (Map<String, Object>)o;
                    String customer=json.serialize(m.get('customer'));
                    Map<String,Object> customerMaps = (Map<String,object>)JSON.deserializeUntyped(customer);
                    if(rely.get('customerId')==customerMaps.get('id')){
                        for(Application_Participant__c ap:Directordatalist){
                            if(ap.AOB_External_GUID__c==customerMaps.get('identifier')){
                                ap.AOB_Rely_Comply_Status__c=(String)rely.get('Status');
                                ap.AOB_PEPStaus__c=(String)rely.get('bw_salesforce_pep_screening');
                                updateStatusList.add(ap);
                            }
                            
                        }
                        
                    }
 
                }
            }
            update apps;
            update updateStatusList;
        }catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'updateRelyStatus',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        
    }
     /**
* @description This method is used as call the relaycomply api and updateRelyStatus
* @param applicationId String
* @return Boolean
*/ 
    @AuraEnabled
    public static Boolean getStatuspdate(String applicationId){
        Boolean retriveassement;
        Application__c apps = New AOB_BOTS_SEL_Application().selectAppById(applicationId);
        
        if(apps.AOB_Rely_Comply_Status__c!=null){
            retriveassement=false;
        }else{
            retriveassement=true;
        }
        
        return retriveassement;       
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
* @description wrapper for AOB_BOTS_DTO_Variables
*/ 
    public class AOB_BOTS_DTO_Variables {
        public AOB_BOTS_DTO_Input input;
    }
    
/**
* @description wrapper for AOB_BOTS_DTO_Input
*/
    public class AOB_BOTS_DTO_Input {
        public String identifier;
        public String type;
        public String businessName;
        public String idDocumentCode;
        public String nationality;
        public String residence;
        public String birthdate;
        public List<Data> data;
    }
    
/**
* @description wrapper for Data
*/
    public class Data{
        public string key;
        public string value;
    }
    
/**
* @description wrapper for AOB_BOTS_DTO_RelyStatus
*/
    public class AOB_BOTS_DTO_RelyStatus{
        public String Status;
        public String customerId;
        public String complete;
        public String bw_salesforce_sanctions_screening;
        public String bw_salesforce_pep_screening;
        public String bw_salesforce_cra_high_risk_review;
    }
    
/**
* @description wrapper for AOB_BOTS_DTO_Detail
*/    
    public class AOB_BOTS_DTO_Detail {
        public AOB_BOTS_DTO_Variables variables;
        public String graphql;
    }
    
/**
* @description wrapper for AOB_BOTS_CreateBusiness
*/
    public class AOB_BOTS_CreateBusiness{
        public String event;
        public AOB_BOTS_DTO_Detail detail;
    }
}