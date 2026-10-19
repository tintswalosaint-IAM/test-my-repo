/**
* @description class handles applications around the flow
* 
* @author mamidala Rahul
* 
* @date Jan 25th 2023 
* @last modified on  : 03-08-2023
* @last modified by  : Ramya Gurram
* @ Modification Description : added condition for solepropritor entity and for new application can create for stage complete status
*/
public without sharing class AOB_CTRL_CreateApplications {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_CTRL_CreateApplications');
    /**
* @description method used to create application based on given input
* @param preAppData
* @param productName
* @return String
*/
    @AuraEnabled
    public static String creatApplication(String preAppData,String productName){
        try{
            String applicationId;
            
            List<String> cipaRegistrationlist= new List<String>();
            List<Application__c> apps =New AOB_BOTS_SEL_Application().selectApplicationByStatusAndSchemaCode('In Progress',productName);
            for(Application__c ap:apps){
                cipaRegistrationlist.add(ap.AOB_RegistrationNumber__c);
            }
            Product2 prod=[select id,ProductCode,AOB_Memo_Code__c,CurrencyIsoCode from Product2 where AOB_Memo_Code__c=:productName and CurrencyIsoCode='BWP'];
            if(!String.isEmpty(preAppData)){
                Map<String,Object> preAppdataMap = (Map<String, Object>)JSON.deserializeUntyped(preAppData);
                String directorData;
                
                Id recordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('AOB_BotswanaBCC').getRecordTypeId();
                Id recordTypeIdindividual = Schema.SObjectType.Individual.getRecordTypeInfosByDeveloperName().get('Botswana_BCC').getRecordTypeId();
                Id recordTypeIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Botswana_BCC').getRecordTypeId();            
                ID queueId = [SELECT Queue.Id FROM queuesobject WHERE queue.name='AOB_Bots_BCC_ACQ' Limit 1].Queue.Id;
                Boolean checkExistCustomer= getExistcustomer((String)preAppdataMap.get('CIPA REGISTRATION NUMBER'));
                if(!cipaRegistrationlist.contains((String)preAppdataMap.get('CIPA REGISTRATION NUMBER')) || (String)preAppdataMap.get('ENTITY TYPE')=='Formal Body without CIPA' || (String)preAppdataMap.get('ENTITY TYPE')=='Partnership' || (String)preAppdataMap.get('ENTITY TYPE')=='Sole Proprietor' || checkExistCustomer==true){
                    Application__c app = new Application__c();
                    app.RecordTypeId=recordTypeId;
                    app.AOB_BCCEntityType__c=(String)preAppdataMap.get('ENTITY TYPE');
                    app.Entity_Type_Sub_Category__c=(String)preAppdataMap.get('Entity Type Sub-Category');
                    app.AOB_BusinessLegalName__c=(String)preAppdataMap.get('LEGAL NAME');
                    app.AOB_Product__c=prod.id;
                    app.AOB_Nationality__c='BW';
                    if(preAppdataMap.get('GROSS ANNUAL TURNOVER (GTA)') != null){
                        app.AOB_GrossAnnualTurnover__c=Decimal.valueof((String)preAppdataMap.get('GROSS ANNUAL TURNOVER (GTA)'));
                    }
                    app.AOB_RegistrationNumber__c=(String)preAppdataMap.get('CIPA REGISTRATION NUMBER');
                    app.Status__c='In Progress';
                    app.AOB_Contribution__c='Business Proceeds';
                    insert app;
                    applicationId = app.Id;
                    String leadId;
                    Integer nosignators=0;
                    List<object> objects = (List<object>)preAppdataMap.get('directordetails');
                    List<Application_Participant__c> appparticpant= new List<Application_Participant__c>();
                    
                    
                    
                    List<Individual> indlist= new List<Individual>();
                    Lead lc = new Lead();
                    for(Object error:objects){
                        Map<String, Object> directorDetailMap = (Map<String, Object>)error;
                        Directores  director= new Directores();
                        Application_Participant__c apart= new Application_Participant__c();
                        Individual ind= new Individual();
                        String indname=(String)directorDetailMap.get('fullName');
                        if(indname.contains(' ')){
                            String[] indnames = indname.split(' ');
                            ind.FirstName=indnames[0];
                            ind.LastName=indnames[1];
                        }else{
                            
                            ind.LastName= indname;
                        }
                        ind.Data_Privacy_Consent__c=true;
                        ind.AOB_Market_Your_Product_Consent__c=true;
                        ind.IndividualsAge='13 or Older';
                        ind.RecordTypeId=recordTypeIdindividual;
                        indlist.add(ind);
                        
                        director.fullName = (String)directorDetailMap.get('fullName');
                        director.omangIdNumber = (String)directorDetailMap.get('omagIDNum');
                        director.phoneNumber = (String)directorDetailMap.get('cellNumber');
                        director.emailAddress = (String)directorDetailMap.get('emailAddress');
                        if(directorDetailMap.get('directorEntity') !=null){
                            director.directorEntity = Boolean.valueof(directorDetailMap.get('directorEntity'));
                        }
                        if(directorDetailMap.get('signatory') !=null){
                            director.signatory = Boolean.valueof(directorDetailMap.get('signatory'));
                        }
                        if(directorDetailMap.get('keyContact') !=null){
                            director.keyContactPerson = Boolean.valueof(directorDetailMap.get('keyContact'));
                        }
                        if((String)directorDetailMap.get('keyContact') == 'No' && (String)preAppdataMap.get('ENTITY TYPE')=='Formal Body without CIPA'){
                            nosignators=nosignators+1;
                        }
                        
                        if(((String)directorDetailMap.get('keyContact') == 'Yes'  || (String)preAppdataMap.get('ENTITY TYPE')=='Sole Proprietor') && (productName == 'OD001' || productName == 'OD005')) {
                            String name = (String)directorDetailMap.get('fullName');
                            Set<String> keyContactPhone= new Set<String>();
                            keyContactPhone.add((String)directorDetailMap.get('omagIDNum'));
                            List<Application_Participant__c> appParticipant=[select Id,Application__r.AOB_BCCEntityType__c, Application__c,Application__r.AOB_Stage__c,Application__r.AOB_Schema_Code__c, CNGCU_Phone__c,CNGCU_Email__c,AOB_IDNumber__c from Application_Participant__c where AOB_IDNumber__c in:keyContactPhone and Application__r.AOB_Schema_Code__c=:prod.AOB_Memo_Code__c];
                            Boolean omgwithProdCodeChcek=false;
                            if(appParticipant.size()!=0){
                                for(Application_Participant__c appt:appParticipant){
                                    if(appt.Application__r.AOB_Schema_Code__c == productName){
                                       omgwithProdCodeChcek = true;
                                    }
                                }
                                     if(omgwithProdCodeChcek){
                                         if(appParticipant[0].Application__r.AOB_Stage__c !='Completed'){
                                             if(appParticipant[0].Application__r.AOB_BCCEntityType__c == 'Formal Body without CIPA'){
                                                  return '403';
                                             } else {
                                                PreaAppStatus st= new PreaAppStatus();
                                                st.status='500';
                                                if(appParticipant[0].Application__c!=null){
                                                    st.applicationid=appParticipant[0].Application__c;
                                                }
                                                return Json.serialize(st);
                                             }
                                           
                                        }
                                    }
                                   
                                
                            }
                            if((String)directorDetailMap.get('keyContact') == 'Yes') {
                                if(name.contains(' ')) {
                                String[] names = name.split(' ');
                                lc.FirstName = names[1];
                                lc.LastName = names[0];
                                
                            } else {
                                lc.LastName = name;
                            }
                            lc.MobilePhone = (String)directorDetailMap.get('cellNumber');
                            lc.Phone = (String)directorDetailMap.get('cellNumber');
                            lc.Email = (String)directorDetailMap.get('emailAddress');
                            
                            lc.Company = (String)preAppdataMap.get('LEGAL NAME');
                            lc.LeadSource = 'Website';
                            if((String)preAppdataMap.get('ENTITY TYPE')=='Formal Body without CIPA'){
                                if(Decimal.valueof((String)preAppdataMap.get('GROSS ANNUAL TURNOVER (GTA)')) >= 10000000){
                                    lc.AOB_Status__c = 'GAT>1 million BWP' ;
                                }
                                else if((((String)directorDetailMap.get('directorEntity')=='No' && (String)directorDetailMap.get('signatory')=='No'))) {
                                    lc.AOB_Status__c = 'Not a Director or a Signatory' ;
                                    lc.OwnerId = queueId;
                                }else{
                                    lc.AOB_Status__c = 'In Progress';
                                }
                                lc.OwnerId = queueId;
                            }
                            else{
                                if(Decimal.valueof((String)preAppdataMap.get('GROSS ANNUAL TURNOVER (GTA)')) < 10000000){
                                    lc.AOB_Status__c = 'GAT>1 million BWP' ;
                                }
                                if(Decimal.valueof((String)preAppdataMap.get('GROSS ANNUAL TURNOVER (GTA)')) >= 10000000){
                                    lc.AOB_Status__c = 'GAT>1 million BWP' ;
                                    lc.OwnerId = queueId;
                                }
                                else if((((String)directorDetailMap.get('directorEntity')=='No' && (String)directorDetailMap.get('signatory')=='No'))) {
                                    lc.AOB_Status__c = 'Not a Director or a Signatory' ;
                                    lc.OwnerId = queueId;
                                }
                                else{
                                    lc.AOB_Status__c ='In Progress';
                                }
                            }
                            lc.RecordTypeId = recordTypeIdLead;
                            }
                            
                        }
                        directorData=Json.serialize(director);
                        apart.Application__c=app.id;   
                        apart.AOB_FullName__c=(String)directorDetailMap.get('fullName');
                        apart.CNGCU_Phone__c=(String)directorDetailMap.get('cellNumber');
                        apart.CNGCU_Email__c=(String)directorDetailMap.get('emailAddress');
                        apart.AOB_IDNumber__c=(String)directorDetailMap.get('omagIDNum');
                        apart.AOB_Stage__c='Pre-Application';   
                        if(directorDetailMap.get('keyContact')!=null){
                            if((String)directorDetailMap.get('keyContact')=='Yes'){   
                                apart.AOB_KeyContactPerson__c=true;
                            }else{
                                apart.AOB_KeyContactPerson__c=false;
                            }
                        }
                        if(directorDetailMap.get('signatory')!=null){
                            if((String)directorDetailMap.get('signatory')=='Yes'){   
                                apart.AOB_Signatory__c=true;
                            }else{
                                apart.AOB_Signatory__c=false;
                            }
                            
                        }
                        if(directorDetailMap.get('directorEntity')!=null){
                            if((String)directorDetailMap.get('directorEntity')=='Yes'){   
                                apart.AOB_Director__c=true;
                            }else{
                                apart.AOB_Director__c=false;
                            }
                        }
                        appparticpant.add(apart);
                    }
                                        
                    insert appparticpant;
                    insert indlist;
                    List<Application_Participant__c> applist=New AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantByApplicationId(applicationId);
                    if(nosignators==applist.size() && (String)preAppdataMap.get('ENTITY TYPE')!='Sole Proprietor'){
                        String name = applist[0].AOB_FullName__c;
                        if(name.contains(' ')) {
                            String[] names = name.split(' ');
                            lc.FirstName = names[1];
                            lc.LastName = names[0];
                            
                        } else {
                            lc.LastName = name;
                        }
                        lc.MobilePhone = applist[0].CNGCU_Phone__c;
                        lc.Phone = applist[0].CNGCU_Email__c;
                        lc.Email = applist[0].CNGCU_Email__c;
                        lc.Company = applist[0].Application__r.AOB_BusinessLegalName__c;
                        lc.LeadSource = 'Website';
                        if(applist[0].Application__r.AOB_GrossAnnualTurnover__c >= 10000000){
                            lc.AOB_Status__c = 'GAT>1 million BWP' ;
                        }
                        else if(applist[0].AOB_Director__c ==false && applist[0].AOB_Signatory__c==false){
                            lc.AOB_Status__c = 'Not a Director or a Signatory' ;
                            lc.OwnerId = queueId;
                        }else{
                            lc.AOB_Status__c = 'In Progress';
                        }
                        lc.OwnerId = queueId;
                        lc.RecordTypeId = recordTypeIdLead;
                    }
                    insert lc;
                    leadId = lc.Id;
                    if(!String.isEmpty(productName)){
                        Application_Line_Item__c appline= new Application_Line_Item__c();
                        appline.Name=productName;
                        appline.AOB_Status__c='Accepted';
                        appline.Application__c=app.id;
                        appline.AOB_Main__c=true;
                        insert appline;
                    }
                    
                    Application__c application=New AOB_BOTS_SEL_Application().selectAppById(app.Id);
                    application.AOB_Lead__c=leadId;
                    Update application;
                    
                    for(Application_Participant__c appt:applist){
                        if((appt.Application__r.AOB_Schema_Code__c=='OD001' || appt.Application__r.AOB_Schema_Code__c=='OD005') && (appt.AOB_Director__c==false && appt.AOB_Signatory__c==false) ){
                            return '403';
                        }if(appt.Application__r.AOB_GrossAnnualTurnover__c>=10000000){
                            
                            return '403';
                        }
                    }
                    return applicationId;
                }else{
                    List<Application__c> appid=New AOB_BOTS_SEL_Application().selectApplicationByRegAndSchemaCodeList((String)preAppdataMap.get('CIPA REGISTRATION NUMBER'), productName);
                    PreaAppStatus st= new PreaAppStatus();
                    for(Application__c ap:appid){
                        if(ap.AOB_Stage__c!='Completed'){
                            st.status='500';
                            st.applicationid=ap.id;
                        }
                    }
                    return Json.serialize(st);
                }
            }
            return applicationId;
        }catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_CreateApplications.creatApplication',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    } 
    
    /**
* @description method used to create Matshelo application based on given input
* @param preAppData
* @param productName
* @return String
*/
    @AuraEnabled
    public static String createMatsheloAppliaction(String preAppData,String productName){
        try{
            String applicationId;
            List<String> cipaRegistrationlist= new List<String>();
            List<Application__c> apps =New AOB_BOTS_SEL_Application().selectApplicationByStatusAndSchemaCode('In Progress',productName);
            for(Application__c ap:apps){
                cipaRegistrationlist.add(ap.AOB_GroupName__c);
            }
            Product2 prod=[select id,ProductCode,AOB_Memo_Code__c from Product2 where AOB_Memo_Code__c=:productName];
            if(!String.isEmpty(preAppData)){
                Map<String,Object> preAppdataMap = (Map<String, Object>)JSON.deserializeUntyped(preAppData);
                Id recordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('AOB_BotswanaBCC').getRecordTypeId();
                Id recordTypeIdindividual = Schema.SObjectType.Individual.getRecordTypeInfosByDeveloperName().get('Botswana_BCC').getRecordTypeId();
                Id recordTypeIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Botswana_BCC').getRecordTypeId();            
                ID queueId = [SELECT Queue.Id FROM queuesobject WHERE queue.name='AOB_Bots_BCC_ACQ' Limit 1].Queue.Id;
                if(!cipaRegistrationlist.contains((String)preAppdataMap.get('GROUP NAME'))  || getExistcustomerGroup((String)preAppdataMap.get('GROUP NAME'))==true){
                    Application__c app = new Application__c();
                    app.RecordTypeId=recordTypeId;
                    app.AOB_EntityTypeCategory__c=(String)preAppdataMap.get('ENTITY TYPE CATEGORY');
                    app.AOB_BCCEntityType__c=(String)preAppdataMap.get('ENTITY TYPE');
                    app.Entity_Type_Sub_Category__c=(String)preAppdataMap.get('Entity Type Sub-Category');
                    app.AOB_Product__c=prod.id;
                    app.AOB_Nationality__c='BW';
                    app.AOB_Contribution__c='Group Contributions';
                    app.AOB_GroupName__c=(String)preAppdataMap.get('GROUP NAME');
                    if(String.isNotBlank((String)preAppdataMap.get('DATE OF REGISTRATION'))){
                        Date dateOfRegistrationStr = Date.valueOf((String)preAppdataMap.get('DATE OF REGISTRATION'));
                        if(dateOfRegistrationStr != null) {
                            app.AOB_DateofRegistration__c = dateOfRegistrationStr;
                        }
                    }
                    app.Status__c='In Progress'; 
                    insert app;
                    applicationId = app.Id;
                    String leadId;
                    Integer nosignators=0;
                    List<object> objects = (List<object>)preAppdataMap.get('directordetails');
                    List<Application_Participant__c> appparticpant= new List<Application_Participant__c>();
                    List<Individual> indlist= new List<Individual>();
                    Lead lc = new Lead();
                    
                    for(Object error:objects){
                        Map<String, Object> directorDetailMap = (Map<String, Object>)error;
                        Application_Participant__c apart= new Application_Participant__c();
                        Individual ind= new Individual();
                        String indname=(String)directorDetailMap.get('fullName');
                        if(indname.contains(' ')){
                            String[] indnames = indname.split(' ');
                            ind.FirstName=indnames[0];
                            ind.LastName=indnames[1];
                        }else{
                            
                            ind.LastName= indname;
                        }
                        ind.Data_Privacy_Consent__c=true;
                        ind.AOB_Market_Your_Product_Consent__c=true;
                        ind.IndividualsAge='13 or Older';
                        ind.RecordTypeId=recordTypeIdindividual;
                        indlist.add(ind);
                        if((String)directorDetailMap.get('signatory') == 'No'){
                            nosignators=nosignators+1;
                        }
                        if((String)directorDetailMap.get('keyContact') == 'Yes') {
                            String name = (String)directorDetailMap.get('fullName');
                            if(name.contains(' ')) {
                                String[] names = name.split(' ');
                                lc.FirstName = names[1];
                                lc.LastName = names[0];
                                
                            } else {
                                lc.LastName = name;
                            }
                            lc.MobilePhone = (String)directorDetailMap.get('cellNumber');
                            lc.Phone = (String)directorDetailMap.get('cellNumber');
                            lc.Email = (String)directorDetailMap.get('emailAddress');
                            lc.Company = (String)preAppdataMap.get('LEGAL NAME');
                            lc.LeadSource = 'Website';
                            lc.AOB_Status__c = 'In Progress';
                            lc.OwnerId = queueId;
                            lc.RecordTypeId = recordTypeIdLead;
                            
                        }
                        apart.Application__c=app.id;
                        apart.AOB_FullName__c=(String)directorDetailMap.get('fullName');
                        apart.CNGCU_Phone__c=(String)directorDetailMap.get('cellNumber');
                        apart.CNGCU_Email__c=(String)directorDetailMap.get('emailAddress');
                        apart.AOB_IDNumber__c=(String)directorDetailMap.get('omagIDNum');
                        apart.AOB_Stage__c='Pre-Application';   
                        if(directorDetailMap.get('keyContact')!=null){
                            if((String)directorDetailMap.get('keyContact')=='Yes'){   
                                apart.AOB_KeyContactPerson__c=true;
                            }else{
                                apart.AOB_KeyContactPerson__c=false;
                            }
                        }
                        if(directorDetailMap.get('signatory')!=null){
                            if((String)directorDetailMap.get('signatory')=='Yes'){   
                                apart.AOB_Signatory__c=true;
                            }else{
                                apart.AOB_Signatory__c=false;
                            }
                            
                        }
                        if(directorDetailMap.get('directorEntity')!=null){
                            if((String)directorDetailMap.get('directorEntity')=='Yes'){   
                                apart.AOB_Director__c=true;
                            }else{
                                apart.AOB_Director__c=false;
                            }
                        }
                        
                        appparticpant.add(apart);
                        
                    }
                    
                    insert appparticpant;
                    insert indlist;
                    List<Application_Participant__c> applist=New AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantByApplicationId(applicationId);
                    if(nosignators==applist.size()){
                        String name = applist[0].AOB_FullName__c;
                        if(name.contains(' ')) {
                            String[] names = name.split(' ');
                            lc.FirstName = names[1];
                            lc.LastName = names[0];
                            
                        } else {
                            lc.LastName = name;
                        }
                        lc.MobilePhone = applist[0].CNGCU_Phone__c;
                        lc.Phone = applist[0].CNGCU_Phone__c;
                        lc.Email = applist[0].CNGCU_Email__c;
                        lc.Company = applist[0].Application__r.AOB_BusinessLegalName__c;
                        lc.LeadSource = 'Website';
                        if(applist[0].Application__r.AOB_GrossAnnualTurnover__c >= 10000000){
                            lc.AOB_Status__c = 'GAT>1 million BWP' ;
                        }
                        else if(applist[0].AOB_Director__c ==false && applist[0].AOB_Signatory__c==false){
                            lc.AOB_Status__c = 'Not a Director or a Signatory' ;
                            lc.OwnerId = queueId;
                        }else{
                            lc.AOB_Status__c = 'In Progress';
                        }
                        lc.OwnerId = queueId;
                        lc.RecordTypeId = recordTypeIdLead;
                    }
                    insert lc;
                    leadId = lc.Id;
                    if(!String.isEmpty(productName)){
                        Application_Line_Item__c appline= new Application_Line_Item__c();
                        appline.Name=productName;
                        appline.AOB_Status__c='Accepted';
                        appline.Application__c=app.id;
                        appline.AOB_Main__c=true;
                        insert appline;
                    }
                    if(!String.isEmpty(leadId)){
                        Application__c application=New AOB_BOTS_SEL_Application().selectAppById(app.Id);
                        application.AOB_Lead__c=leadId;
                        Update application;
                    }
                    return applicationId;
                }else{
                    list<Application__c> appid =New AOB_BOTS_SEL_Application().selectApplicationByGroupAndSchemaCode((String)preAppdataMap.get('GROUP NAME'), productName);
                    PreaAppStatus st= new PreaAppStatus();
                    for(Application__c ap:appid){
                        if(ap.AOB_Stage__c!='Completed'){
                            st.status='500';
                            st.applicationid=ap.id;
                        }
                    }
                    return Json.serialize(st);
                }
            }
            return applicationId;
        }catch(Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_CreateApplications.createMatsheloAppliaction',ex.getMessage()}, ex);throw new AuraHandledException(ex.getMessage());  
        }
    } 
    /**
* @description method used to create application based on given input
* @param applicationId
* @param productdata
*/
    @AuraEnabled
    public static void createUserselectLineitem(String applicationId,String productdata){
        try{
            if(!String.isEmpty(applicationId) && !String.isEmpty(productdata) ){
                List<Application_Line_Item__c> applinelist= new List<Application_Line_Item__c>();
                List<Application_Participant__c> appParticpant = New AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantById(applicationId);
                List<Application_Line_Item__c>  applistItem=New AOB_BOTS_SEL_ApplicationLineItem().selectApplicationLineItemByApplicationId(appParticpant[0].Application__c);
                List<String> productNames= new List<String>(); 
                List<String> productCodes= new List<String>();
                for(Application_Line_Item__c app:applistItem){
                    productNames.add(app.Name);
                    productCodes.add(app.AOB_ProductCode__c);
                }
                List<object> objectProdut= (List<Object>)System.JSON.deserializeUntyped(productdata);
                if(objectProdut!=null){
                    for(object items:objectProdut){
                        Application_Line_Item__c  appitem=new Application_Line_Item__c();
                        LineItem_DTO lineitem= new LineItem_DTO();
                        Map<String, Object> directorDetailMap = (Map<String, Object>)items;
                        if(!productNames.Contains((String)directorDetailMap.get('cardName')) && !productCodes.Contains((String)directorDetailMap.get('cardId'))){
                            appitem.Name=(String)directorDetailMap.get('cardName');
                            appitem.AOB_ProductCode__c=(String)directorDetailMap.get('cardId');
                            appitem.AOB_Status__c='Accepted';
                            appitem.Application__c=appParticpant[0].Application__c;
                            lineitem.tag=(String)directorDetailMap.get('tag');
                            lineitem.header=(String)directorDetailMap.get('header');
                            lineitem.subTitle=(String)directorDetailMap.get('subTitle');
                            lineitem.cardLineItemIcon=(String)directorDetailMap.get('cardLineItemIcon');
                            if(directorDetailMap.get('cardLineItems') != null){    
                                lineitem.cardLineItems=(List<Object>)directorDetailMap.get('cardLineItems');
                            }
                            appitem.Details__c='{ "products":'+Json.serialize(lineitem)+'}';
                            applinelist.add(appitem);    
                        }
                    }
                }
                insert applinelist;    
            }  
        }catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_CreateApplications.createUserselectLineitem',ex.getMessage()}, ex);throw new AuraHandledException(ex.getMessage());  
        }            
    }
    /**
* @description method used to delete application line items
* @param applicationId
*/
    @AuraEnabled    
    public static void deleteLineItems(List<String> applicationId){
        try{
            List<Application_Line_Item__c>  applistItem=New AOB_BOTS_SEL_ApplicationLineItem().selectApplicationLineItemByIds(applicationId);
            Delete applistItem;
        }catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_CreateApplications.deleteLineItems',ex.getMessage()}, ex);throw new AuraHandledException(ex.getMessage());  
        }
    }
    /**
* @description ApplicationLineItem
* @param applicationId 
* @return Map<String, String>
*/
    @AuraEnabled    
    public static Map<String, String> getLineItems(String applicationId){
        try{
            Map<String, String> applineItem= new Map<String, String>();
            List<Application_Participant__c> appParticpant = [select Id,Application__c,Application__r.AOB_Schema_Code__c from Application_Participant__c where Id =:applicationId];
            List<Application_Line_Item__c>  applistItem=[select Id,Application__c,Name,AOB_Status__c,AOB_Main__c,Details__c from Application_Line_Item__c where Application__c=:appParticpant[0].Application__c and AOB_Main__c=false];
            for(Application_Line_Item__c app:applistItem){
                if(app.AOB_Main__c==false && !String.isEmpty(app.Details__c)){
                    applineItem.put('applicationItems',Json.serialize(applistItem));
                    applineItem.put('applicationCode',appParticpant[0].Application__r.AOB_Schema_Code__c);
                }
            }
            if(applistItem.size()==0){
                applineItem.put('applicationItems','null');
                applineItem.put('applicationCode',appParticpant[0].Application__r.AOB_Schema_Code__c);
            }
            return applineItem;
        }catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_CreateApplications.getLineItems',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    /**
* @description method to get the Existing customer with cipa number
* @param cipaNumber 
* @return Boolean
*/

 public Static Boolean getExistcustomer(String cipaNumber){
        Boolean existCustomer=false;
        set<String> cipaNumberList = new set<String>();
        cipaNumberList.add(cipaNumber);
        List<Application__c> appCipa = new AOB_BOTS_SEL_Application().selectApplicationByregistrationNumber(cipaNumberList);
        if(appCipa.size() > 0){
            existCustomer=true;
            for(Application__c ap:appCipa){
                if(ap.AOB_Stage__c=='Completed'){
                    existCustomer=true;
                }else{
                    existCustomer=false;
                    break;
                }
            }
        }else{
            existCustomer=false;
        }
        return existCustomer; 
    }
    
/**
* @description method to get the Existing customer with group name
* @param groupName 
* @return Boolean
*/
    public Static Boolean getExistcustomerGroup(String groupName){
        Boolean existCustomer=false;
        set<String> groupNameList = new set<String>();
        groupNameList.add(groupName);
        List<Application__c> appGroup =New AOB_BOTS_SEL_Application().selectApplicationByOnlyGroup(groupNameList);
         if(appGroup.size() > 0){
            existCustomer=true;
            for(Application__c ap:appGroup){
                if(ap.AOB_Stage__c=='Completed'){
                    existCustomer=true;
                }else{
                    existCustomer=false;
                    break;
                }
            }
        }else{
            existCustomer=false;
        }
        return existCustomer; 
    }
    
    
    /**
* @description wrapper for Directores
*/
    public class Directores{
        
        String fullName;
        String omangIdNumber;
        String phoneNumber;
        String emailAddress;
        Boolean directorEntity;
        Boolean signatory;
        Boolean keyContactPerson;
        
    }
    
    /**
* @description wrapper for LineItem_DTO
*/
    public class LineItem_DTO{
        String tag;
        String header;
        String subTitle;
        String cardLineItemIcon;
        List<object> cardLineItems;
    }
    
    /**
* @description method to get the applicatoin participant
* @param participantId 
* @return Map<String, Object>
*/
    @AuraEnabled
    public static Map<String, Object> getParticipantApplication(String participantId) {
        try{
            Map<String, Object> data = new Map<String, Object>();
            Application_Participant__c participantRecord =New AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticipant(participantId);
            Id applicationId = participantRecord.Application__c;
            Application__c applicationRecord = New AOB_BOTS_SEL_Application().selectAppById(applicationId);
            data.put('OmangId', participantRecord.AOB_IDNumber__c);
            data.put('FullName', participantRecord.AOB_FullName__c);
            data.put('CIPA REGISTRATION NUMBER', applicationRecord.AOB_RegistrationNumber__c);
            data.put('EMAIL ADDRESS', participantRecord.CNGCU_Email__c);
            data.put('ARE YOU A DIRECTOR ON THE ENTITY/BUSINESS?', String.valueOf(participantRecord.AOB_KeyContactPerson__c));
            data.put('ARE YOU GOING TO BE A SIGNATORY ON THE ACCOUNT?', String.valueOf(participantRecord.AOB_Signatory__c));
            return data;
        }catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_CreateApplications.getParticipantApplication',ex.getMessage()}, ex);throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    /**
* @description method to get the applicatoin participant
* @param applicationId 
* @param appData 
*/
    @AuraEnabled
    public static void updateInflight(Id applicationId,String appData){
        try{
            List<Application_Participant__c> appParticpant = New AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantById(applicationId);
            List<Application__c> apps =  New AOB_BOTS_SEL_Application().selectAppsById(appParticpant[0].Application__c);
            
            if(!apps.isEmpty()){
                Map<String, Object> jsonMAp ;
                if(String.isBlank(apps[0].Inflight__c)){
                    jsonMAp = new Map<String, Object>();
                    jsonMap.put('CardSelection',appData);
                    apps[0].Inflight__c='{"CardSelection":'+appData+'}';
                }
                else{ 
                    jsonMAp = (Map<String, Object>)System.JSON.deserializeUntyped(apps[0].Inflight__c);
                    jsonMap.put('CardSelection',System.JSON.deserializeUntyped(appData));
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
        catch (Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] 
            {'AOB_CTRL_CreateApplications.updateInflight',ex.getMessage()}, ex);
            throw new AuraHandledException('update exception msg'+ex.getMessage());  
        }
        
        
    }
    
    
    
    /**
* @description method to get the applicatoin participant
* @param applicationId 
* @return String 
*/
    @AuraEnabled
    public static String getEntityType(String applicationId){
        Application__c apps =New AOB_BOTS_SEL_Application().selectAppById(applicationId);
        return apps.AOB_BCCEntityType__c;
    }
    
    /**
* @description method to get the applicatoin participant
* @param applicationId 
* @return String 
*/
    @AuraEnabled
    public static String getCardSelection(Id applicationId){
        try{
            String cardSelection=AOB_BOTS_SRV_SigningHUB.getInflight(applicationId,'CardSelection');
            return cardSelection;
        }
        catch (Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_CreateApplications.getCardSelection',ex.getMessage()}, ex);
            throw new AuraHandledException('update exception msg'+ex.getMessage());  
        }
        
        
    }
    
    /**
* @description method to get the name of the selected card
* @param cardCode 
* @return String 
*/ 
    @AuraEnabled
    public static String getSelectedCardName(String cardCode){
        try{
            List<AOB_ReferencedData__c> selectedCardRecord = new AOB_BOTS_SEL_ReferencedData().getReferencedDataName('PB_CLASSIF',cardCode);
            return selectedCardRecord[0].Name;  
        } 
        catch (Exception ex){  
            LOGGER.error(ex.getMessage(), new String[] 
            {'AOB_CTRL_CreateApplications.getSelectedCardName',ex.getMessage()}, ex);
            throw new AuraHandledException('update exception msg'+ex.getMessage());  
        }
        
        
    }
    
/**
* @description This method is used as to get application id based on participant id
* @param participantId
* @return String
*/ 
    @AuraEnabled
    public static String getapplicationId(String participantId){
        try{
            Application_Participant__c appParticpant = new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticipant(participantId);
            return appParticpant.Application__c; 
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_CreateApplications.getapplicationId',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
}  
    
    
    /**
* @description method to get the applicatoin participant
* @param applicationpartId 
* @return Integer
*/
    @AuraEnabled
    public static Integer updateLeadStatusLineItems(String applicationpartId){
        try{
            Id recordTypeIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Botswana_BCC').getRecordTypeId();            
            Application_Participant__c appParticpant =New AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticipant(applicationpartId);
            ID queueId = [SELECT Queue.Id FROM queuesobject WHERE queue.name='AOB_Bots_BCC_Lending' Limit 1].Queue.Id;
            ID queueId2 = [SELECT Queue.Id FROM queuesobject WHERE queue.name='AOB_Bots_BCC_Savings' Limit 1].Queue.Id;
            List<Application_Line_Item__c> appItemlist=New AOB_BOTS_SEL_ApplicationLineItem().selectApplicationLineItemByApplicationId(appParticpant.Application__c);
            List<Lead> ldinsertList= new List<Lead>();
            for(Application_Line_Item__c ap:appItemlist){
                Lead lc= new Lead();
                if(ap.AOB_ProductCode__c=='BO001' || ap.AOB_ProductCode__c=='BO004' || ap.AOB_ProductCode__c=='BO005' || ap.AOB_ProductCode__c=='BO006'){
                    
                    String name = appParticpant.AOB_FullName__c;
                    if(name.contains(' ')) {
                        String[] names = name.split(' ');
                        lc.FirstName = names[1];
                        lc.LastName = names[0];
                        
                    } else {
                        lc.LastName = name;
                    }
                    lc.Description='ApplicationId '+appParticpant.Application__c;
                    lc.AOB_Status__c='Cross Sell selected';
                    lc.RecordTypeId = recordTypeIdLead;
                    lc.OwnerId=queueId2;
                    ldinsertList.add(lc);
                }if(ap.AOB_ProductCode__c=='BO002' || ap.AOB_ProductCode__c=='BO008' || ap.AOB_ProductCode__c=='BO009'){
                    String name = appParticpant.AOB_FullName__c;
                    if(name.contains(' ')) {
                        String[] names = name.split(' ');
                        lc.FirstName = names[1];
                        lc.LastName = names[0];
                        
                    } else {
                        lc.LastName = name;
                    }
                    lc.Description='ApplicationId '+appParticpant.Application__c;
                    lc.AOB_Status__c='Cross Sell selected';
                    lc.RecordTypeId = recordTypeIdLead;
                    lc.OwnerId=queueId;
                    ldinsertList.add(lc);
                }
            }
            insert ldinsertList;
            return 200;
        }catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_CreateApplications.updateLeadStatusLineItems',ex.getMessage()}, ex);throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    /**
* @description wrapper for PreaAppStatus
*/
    public class PreaAppStatus{
        public string status;
        public string applicationid;
    }
    
}