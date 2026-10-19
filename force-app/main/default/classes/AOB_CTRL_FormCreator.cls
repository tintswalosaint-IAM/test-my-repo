/**
* @description Class for generic form creation based on database records
*
* Story:SFP-12450
*
* @author Rahul Mamidala
*
* @date May 2022
* @last modified on  : 03-08-2023
* @last modified by  : Ramya Gurram
* @ Modification Description : used new field signing arrangement
*/
public without sharing class AOB_CTRL_FormCreator {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_CTRL_FormCreator');
    
    /**
    * @description gets a list of fields to be displayed based on screen and product
    * @param applicationId  - Id of the Community
    * @param screenName - Auth Provider user data describing the User to create
    * @return List<AOB_Field> 
    */
    @AuraEnabled
    public static AOB_DTO_Form getFields(Id applicationId,String screenName) {
        String language=AOB_BOTS_Utils.getUserLanguage();
        if(language == 'en_US'){
            language = 'EN';
        }
        List<AOB_FlowScreen__c> screens = new SEL_AOBScreen().selectFieldsByName(screenName);
        AOB_DTO_Form form = new AOB_DTO_Form();
        List<Application__c> apps;
        if(!screens.isEmpty()){
            apps = getApps(screens,applicationId);
        }
        else{
            LOGGER.error('Unable to find selected screen');
            throw new AuraHandledException('Unable to find selected screen'+screenName);
        }
        form.subTitle = getFormSubtitle(screens, apps);
        form.title=screens[0].AOB_title__c;
        List<AOB_DTO_Field> fields=new List<AOB_DTO_Field>();
        List<AOB_DTO_Section> sections=new List<AOB_DTO_Section>();
        Set<Id> sectionIds=new Set<Id>();
        AOB_DTO_Section jsSection;
        
        for(AOB_ScreenSection__c  section : new SEL_AOBSection().selectSectionsByScreenName(screenName)){
            jsSection = setSectionInfo(section);
            sections.add(jsSection); 
            sectionIds.add(section.id);                             
        }
    
        if(sectionIds.isEmpty()){
            LOGGER.error('Unable to find any sections');
            throw new AuraHandledException('Unable to find any sections');
        }
        
        Map<id,List<AOB_DTO_Field>> sectionFields=new Map<id,List<AOB_DTO_Field>>();
        List<String> mriTables=new List<String>();
        for(AOB_Field__c  field: new SEL_AOBField().selectMRITablesByLanguage(sectionIds,language)){
            mriTables.add(field.AOB_MRITable__c );
        }   
        
        Map<String, List<AOB_DTO_SelectOption>> refData = AOB_BOTS_Utils.getAllPicklistEntriesCodes(mriTables);
        if(refData.isEmpty()){
            LOGGER.error('Unable to find any referenced data');
            throw new AuraHandledException('Unable to find any referenced data');
        }
        
        for(AOB_Field__c  field : new SEL_AOBField().selectFieldsBySection(sectionIds)){
            AOB_DTO_Field jsField = new AOB_DTO_Field(field,apps);
            jsField.options=refData.get(field.AOB_MRITable__c);
            if(sectionFields.containsKey(field.AOB_Section__c)){
                sectionFields.get(field.AOB_Section__c).add(jsField);
            }
            else{
                sectionFields.put(field.AOB_Section__c,new List<AOB_DTO_Field>{jsField});
            }
        }
        if(sectionFields.isEmpty()){
            LOGGER.error('Unable to find any fields');
            throw new AuraHandledException('Unable to find any fields');
        }
        for(AOB_DTO_Section section:sections){
            List<AOB_DTO_Field> sortedFields=sectionFields.get(section.identifier);
            if(sortedFields!=null){
                sortedFields.sort();
            }
            section.fields=sortedFields;
        }
        form.sections=sections;
        return form;
    }
    
    /**
    * @description gets a list of files linked to participant
    * @param appId
    * @return list<contentversion> 
    */
    @AuraEnabled
    public static list<contentversion> releatedFiles(Id appId){
        list<Application_Document__c> appDocLst =New AOB_BOTS_SEL_ApplicationDocument().selectAppsByIdApplicationParcipant(appId);
        list<id> lstappDoxID = new list<id>();
        for(Application_Document__c appDoc: appDocLst){
            lstappDoxID.add(appDoc.id);
        }
        list<id> lstConDocs = new list<id>();
        List<ContentDocumentLink> contentDocumentList=New AOB_BOTS_SEL_ContentDocumentLink().getDocumentLinkByLinkedEntity(lstappDoxID);
        for(ContentDocumentLink cntLink : contentDocumentList) {
            lstConDocs.add(cntLink.ContentDocumentId);
        }
        if(!lstConDocs.isEmpty()) {
            return New AOB_BOTS_SEL_ContentVersion().selectContentVersionByIds(lstConDocs);
        }
        else {
            return null;
        }
    }

    
    /**
    * @description gets participant record based on record Id
    * @param recordId
    * @return Map<String,Object> 
    */
    @AuraEnabled
    public static Map<String,Object> getParticipantAppId(string recordId) {
        
        List<Application_Participant__c> participant = New AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantById(recordId);
        Map<String, Object> jsonMap = new Map<String, Object>();
        if (!Participant.isEmpty()) {
            jsonMap.put('applicationId', participant[0].Application__c);
            jsonMap.put('contactNumber', participant[0].CNGCU_Phone__c);
            jsonMap.put('Email', participant[0].CNGCU_Email__c);
            
        }
        
        return jsonMap;
        
        
    }
    
    /**
    * @description gets participant's application record based on json data
    * @param json
    * @return String 
    */
    @AuraEnabled
    public static String applicationwithId(String json) {
        string participantId;
        Map<String, Object> jsonMap = (Map<String, Object>)system.JSON.deserializeUntyped(json);
        
        String applicationId = (String)jsonMap.get('APPLICAITON ID');
        String phoneNumber = (String)jsonMap.get('CONTACT NUMBER');
        List<Application__c> applications = New AOB_BOTS_SEL_Application().selectAppsById(applicationId);
        if (applications.isEmpty()) {
            LOGGER.error('Unable to find  any applications');
            throw new AuraHandledException('Unable to find  any applications');
        }
        else if(applications[0].Status__c !='In Progress') {
            LOGGER.error('Application is Already Completed!');
            throw new AuraHandledException('Application is Already Completed!');
            
        }
        else  {
            List<Application_Participant__c> applicationParticipants = New AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantByAppAndPhone(applicationId, phoneNumber);
            if(applicationParticipants.isEmpty()){
                LOGGER.error('Unable to find any application with this phonenumber');
                throw new AuraHandledException('Unable to find any application with this phonenumber');
            }
            else if(!(applicationParticipants[0].AOB_KeyContactPerson__c )){
                List<Application_Participant__c> keyParticipant = New AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantByKeyContact(applicationId, true);
                List<Verification__c>  verify = New AOB_BOTS_SEL_Verification().selectVerificationByParticipantAndStatus(keyParticipant[0].Id, 'Completed by Customer');
                if(verify.isEmpty()){
                    LOGGER.error('KeyConatct Person doesnot complete the IDV');
                    throw new AuraHandledException('KeyConatct Person doesnot complete the IDV');   
                    
                }  
            }
            participantId=applicationParticipants[0].Id;
            
        }   
        return participantId; 
    }
    
    /**
    * @description gets a list of fields to be displayed without application id based on screen name
    * @param screenName - name of the currrent screen
    * @return AOB_DTO_Form 
    */
    @AuraEnabled
    public static AOB_DTO_Form getFieldsWithoutAppId(String screenName) {
        String language=AOB_BOTS_Utils.getUserLanguage();
        if(language == 'en_US'){
            language = 'EN'; 
        }
        AOB_DTO_Form form = new AOB_DTO_Form();
        List<Application__c> apps;
        form.subTitle = 'Testing Subtitle';
        form.title='Ttile';
        List<AOB_DTO_Field> fields=new List<AOB_DTO_Field>();
        List<AOB_DTO_Section> sections=new List<AOB_DTO_Section>();
        Set<Id> sectionIds=new Set<Id>();
        AOB_DTO_Section jsSection;
        for(AOB_ScreenSection__c  section : new SEL_AOBSection().selectSectionsByScreenName(screenName)){
            jsSection = setSectionInfo(section);
            sections.add(jsSection); 
            sectionIds.add(section.id);                             
        }
        if(sectionIds.isEmpty()){
            LOGGER.error('Unable to find any sections');
            throw new AuraHandledException('Unable to find any sections');
        }
        
        Map<id,List<AOB_DTO_Field>> sectionFields=new Map<id,List<AOB_DTO_Field>>();
        List<String> mriTables=new List<String>();
        for(AOB_Field__c  field: new SEL_AOBField().selectMRITablesByLanguage(sectionIds,language)){
            mriTables.add(field.AOB_MRITable__c );
        }   
        Map<String, List<AOB_DTO_SelectOption>> refData = AOB_BOTS_Utils.getAllPicklistEntriesCodes(mriTables);
        if(refData.isEmpty()){
            LOGGER.error('Unable to find any referenced data');
            throw new AuraHandledException('Unable to find any referenced data');
            
        }
        
        for(AOB_Field__c  field : new SEL_AOBField().selectFieldsBySection(sectionIds)){
            apps=new List<Application__c>();
            AOB_DTO_Field jsField = new AOB_DTO_Field(field,apps);
            jsField.options=refData.get(field.AOB_MRITable__c);
            if(sectionFields.containsKey(field.AOB_Section__c)){
                sectionFields.get(field.AOB_Section__c).add(jsField);
            }
            else{
                sectionFields.put(field.AOB_Section__c,new List<AOB_DTO_Field>{jsField});
            } 
        }
        if(sectionFields.isEmpty()){
            LOGGER.error('Unable to find any fields');
            throw new AuraHandledException('Unable to find any fields');
        }
        for(AOB_DTO_Section section:sections){
            List<AOB_DTO_Field> sortedFields=sectionFields.get(section.identifier);
            if(sortedFields!=null){
                sortedFields.sort();
            }
            section.fields=sortedFields;
        }
        form.sections=sections;
        return form;
    }
    
    /**
    * @description gets a list of apps
    * @param screens - all flow screens
    * @param applicationId
    * @return List<AOB_Application__c> 
    */
    @TestVisible private static List<Application__c> getApps(List<AOB_FlowScreen__c> screens,Id applicationId){
        List<Application__c> apps;
        if(applicationId!=null){
            if(String.isNotBlank(screens[0].AOB_TitleApplicationField__c) && screens[0].AOB_TitleApplicationField__c.toLowerCase()!='name'){
                apps=database.query('select id,name,'+screens[0].AOB_TitleApplicationField__c+' from Application__c where id=\''+applicationId+'\'');
            }else{
                apps=database.query('select id,name from Application__c where id=\''+applicationId+'\'');
            } 
        }
        return apps;
    }
    
    /**
    * @description gets form subtitle
    * @param screens - all flow screens
    * @param apps - all flow apps
    * @return String
    */
    @TestVisible private static String getFormSubtitle(List<AOB_FlowScreen__c> screens, List<Application__c> apps){
        String formSub;
        if(String.isNotBlank(screens[0].AOB_subTitle__c) && screens[0].AOB_subTitle__c.contains('{####}') &&!apps.isEmpty()){
            formSub=screens[0].AOB_subTitle__c.replace('{####}',String.valueOf(apps[0].get(screens[0].AOB_TitleApplicationField__c)));
        }
        else{
            formSub=screens[0].AOB_subTitle__c;
        }
        return formSub;
    }
    
    /**
    * @description gets sections info
    * @param section - section info
    * @return AOB_DTO_Section
    */
    @TestVisible private static AOB_DTO_Section setSectionInfo(AOB_ScreenSection__c section){
        AOB_DTO_Section sectionInfo;
        sectionInfo = new AOB_DTO_Section();
        sectionInfo.identifier=section.id;                               
        sectionInfo.title=section.AOB_Title__c;  
        sectionInfo.sectionName=section.Name; 
        sectionInfo.smallDeviceColumns=section.AOB_smallDeviceColumns__c;
        sectionInfo.mediumDeviceColumns=section.AOB_mediumDeviceColumns__c;
        sectionInfo.largeDeviceColumns=section.AOB_largeDeviceColumns__c;
        sectionInfo.rank=section.AOB_Rank__c;
        sectionInfo.gridClass='aob_form_input slds-col slds-m-top_small slds-small-size_1-of-'+sectionInfo.smallDeviceColumns+' slds-medium-size_1-of-'+sectionInfo.mediumDeviceColumns+' slds-large-size_1-of-'+sectionInfo.largeDeviceColumns;
        return sectionInfo;
    }
    
    
    
    /**
    * @description sets application's current and previous step
    * @param applicationId Id
    * @param currentScreen String
    * @param previousScreen String
    */
    @AuraEnabled
    public static void setApplicationStep(Id applicationId,String currentScreen,String previousScreen){
        try{
            List<Application_Participant__c> apps = New AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantById(applicationId);
            if(apps.isEmpty()){
                LOGGER.error('Unable to find  any applications');
                throw new AuraHandledException('Unable to find application '+applicationId);
            }
            if(!apps.isEmpty()){
                if(String.isNotBlank(apps[0].AOB_PreviousScreens__c)){
                    if(String.isNotBlank(previousScreen)){
                        if (!apps[0].AOB_PreviousScreens__c.contains(previousScreen)){
                            apps[0].AOB_PreviousScreens__c=apps[0].AOB_PreviousScreens__c+';'+previousScreen;
                        }
                    }
                } 
                else {
                    apps[0].AOB_PreviousScreens__c=previousScreen;
                }
                apps[0].AOB_Stage__c = currentScreen;
                apps[0].AOB_PreviousScreen__c = previousScreen; 
            }
            update apps; 
        }
        catch (Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator.setApplicationStep',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        
    }
    
    /**
    * @description sets application's current and previous step based on the information stored in previous steps
    * @param applicationId
    */
    @AuraEnabled
    public static void goBacktoPreviousStep(Id applicationId){
        try{
            List<Application_Participant__c> apps = New AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantById(applicationId);
            if(apps.isEmpty()){
                throw new AuraHandledException('Unable to find application '+applicationId);
            }
            if(!apps.isEmpty()){
                if(String.isNotBlank(apps[0].AOB_PreviousScreens__c)){
                    List<String> screens=apps[0].AOB_PreviousScreens__c.split(';');
                    if (screens.size() > 0) {
                        apps[0].AOB_Stage__c= screens[screens.size()-1];  
                        apps[0].AOB_PreviousScreens__c = apps[0].AOB_PreviousScreens__c.replace(';'+apps[0].AOB_Stage__c,'').replace(apps[0].AOB_Stage__c,'');
                    }
                    if (screens.size() > 1) {
                        apps[0].AOB_PreviousScreen__c = screens[screens.size()-2];  
                    } else {
                        apps[0].AOB_PreviousScreen__c = ''; 
                    }
                }
            }
            update apps;
        }
        catch (Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator.goBacktoPreviousStep',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        
    } 
    
    /**
    * @description method to Send Welcome Email to other Directors If Key Person Completes the IDV Successfully 
    * @param participantIds String
    */   
    @InvocableMethod(label='Send Welcome Mai to Directors')
    public static void sendWelcomeEmailToDirectors(List<String> participantIds){
        try{
            String participantId = participantIds[0];
            List<Application_Participant__c> applicationParticipant = new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantById(participantId);
            // checking if participantId who completed the IDV is a key person
            if(applicationParticipant[0].AOB_KeyContactPerson__c){ 
                //fetch all directors of the application except key person
                Id orgWideEmailAddressId = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'Botswana Account Onboarding Support'].Id;
                List<Application_Participant__c> participantsList = New AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantByKeyContact(applicationParticipant[0].Application__c, false);
                if(!participantsList.isEmpty()){
                    List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                    for(Application_Participant__c participant : participantsList){
                        if(participant.CNGCU_Email__c != null){
                            String emailBody = 'Your application ID: '+applicationParticipant[0].Application__c;
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setToAddresses(new List<String>{participant.CNGCU_Email__c});
                            mail.setSubject('Account Orginiation Welcome Mail');
                            String applicationURL = System.Label.AOB_BOTS_SiteBaseUrl; 
                            applicationURL = applicationURL+'/s/preapplication?productschemecode='+participant.Application__r.AOB_Schema_Code__c+'&participant='+participant.Id;
                            String emailHtmlBody = emailBody + '<p>Please use <a href="' + applicationURL + '">link</a> to start your application.</p>';
                            mail.setHtmlBody(emailHtmlBody); 
                            mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
                            emailList.add(mail);
                        }
                    }
                    if(!emailList.isEmpty()){
                        Messaging.sendEmail(emailList);
                    }   
                }
            }
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator.sendWelcomeEmailToDirectors',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    
    /**
    * @description get mobile number of the participant based on record Id
    * @param recordId 
    * @return Map<String, String>
    */ 
    @AuraEnabled
    public static Map<String, String> getMobileNumbers(String recordId) {
        Map<String, String> mobileNumbersByApplication = new Map<String, String>();
        try {
            Application_Participant__c participant = new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticipant(recordId);
            mobileNumbersByApplication.put('applicationId', participant.Application__c);
            mobileNumbersByApplication.put('contactNumber', participant.CNGCU_Phone__c); 
        } catch (Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator.getMobileNumbers',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        return mobileNumbersByApplication;
    }
    
    /**
    * @description get key participant data of application
    * @param recordId 
    * @return Map<String, String>
    */  
    @AuraEnabled
    public static Map<String, String> getKeyParticipantData(String recordId) {
        Map<String, String> participantData = new Map<String, String>();
        try {
            List<Application_Participant__c> participants = new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantByKeyContact(recordId,true);
            if (!participants.isEmpty()) { 
                participantData.put('keyContactMobile', participants[0].CNGCU_Phone__c);
                participantData.put('keyContactEmail', participants[0].CNGCU_Email__c);
            }
            else {
               List<Application_Participant__c> part = [select id,CNGCU_Phone__c,CNGCU_Email__c,Application__c from Application_Participant__c where Application__c=:recordId order by CreatedDate ASC]; 
               participantData.put('keyContactMobile', part[0].CNGCU_Phone__c);
               participantData.put('keyContactEmail', part[0].CNGCU_Email__c);
           }
        } catch (Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator.getKeyParticipantData',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        return participantData;
    }
    
   
    
    /**
    * @description fetch participant data and application data to populate on UI
    * @param appId 
    * @param screenName 
    * @return String
    */  
    @AuraEnabled
    public static String getExistingData(string appId, string screenName){
        
        String inflightData ;
        if(screenName == 'Application Details'){
            inflightData= AOB_CTRL_FormCreator.fetchApplicationParticipant(appId);
            
        }else if(screenName == 'Company Information'){
            inflightData= AOB_CTRL_FormCreator.fetchApplicationdata(appId);
        } 
        else if(screenName == 'Summary'){
            inflightData= AOB_CTRL_FormCreator.fetchSummary(appId);
        }else if(screenName == 'Matshelo Personal Information'){
            inflightData= AOB_CTRL_FormCreator.fetchApplicationParticipant(appId);
            
        }else if(screenName == 'Matshelo Company Information'){
             inflightData= AOB_CTRL_FormCreator.fetchApplicationdata(appId);
        }else if(screenName == 'Matshelo Summary'){
             inflightData= AOB_CTRL_FormCreator.fetchSummary(appId);
        }
        
        
        
        return inflightData;
    }
    
    /**
    * @description fetch participant data based on record Id 
    * @param participantId 
    * @return String
    */ 
    @AuraEnabled
    public static String fetchApplicationParticipant (String participantId) {
        string participantdata;
        try{
            Application_Participant__c participant = new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticipant(participantId);
            Map<String,Object> personalDetailsMap = new Map<String,Object>();
            personalDetailsMap.put('Full Name', participant.AOB_FullName__c);
            personalDetailsMap.put('Do you', participant.AOB_DebitCard__c);
            personalDetailsMap.put('Omang Id Number', participant.AOB_IDNumber__c);
            personalDetailsMap.put('Cell Phone Number', participant.CNGCU_Phone__c);
            personalDetailsMap.put('Email Address', participant.CNGCU_Email__c);
            personalDetailsMap.put('receiveNotification', participant.AOB_NotificationPreference__c);
            personalDetailsMap.put('Suburb', participant.AOB_Suburb__c);
            personalDetailsMap.put('Street', participant.AOB_Street__c);
            personalDetailsMap.put('PostalCode', participant.AOB_PostalCode__c);
            personalDetailsMap.put('businessRole', participant.AOB_Role__c);
            personalDetailsMap.put('signingArrangement', participant.Application__r.AOB_Signing_Arrangement__c);
            personalDetailsMap.put('Province', participant.AOB_State__c);
            personalDetailsMap.put('CityTown', participant.Botswana_City__c);
            personalDetailsMap.put('Marital Status', participant.AOB_MaritalStatus__c);
            personalDetailsMap.put('Gender', participant.AOB_Gender__c);
            personalDetailsMap.put('Title', participant.AOB_Title__c);
            personalDetailsMap.put('Date of Birth', participant.AOB_DateofBirth__c);
            personalDetailsMap.put('Primary Nationality', participant.AOB_PrimaryNationality__c);
            personalDetailsMap.put('Occupation', participant.AOB_Occupation__c);
            personalDetailsMap.put('Gross Annual Income', participant.AOB_GrossAnnualIncome__c);
            personalDetailsMap.put('Monthly Net Income', participant.AOB_MonthlyNetIncome__c);
            if(!String.isBlank(participant.AOB_PostalCode__c)){
                if(participant.AOB_TransactOnTheBusiness__c == true){
                    personalDetailsMap.put('businessTransact', 'TRUE');
                    personalDetailsMap.put('Do you', 'TRUE');
                }
                if(participant.AOB_TransactOnTheBusiness__c == false){
                    personalDetailsMap.put('businessTransact', 'FALSE');
                     personalDetailsMap.put('Do you', 'FALSE');
                }
            }
            participantdata =System.JSON.serialize(personalDetailsMap);
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator.fetchApplicationParticipant',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        return participantdata;
    }
    
    
    /**
    * @description fetch participant's summary data based on record Id 
    * @param participantId 
    * @return String
    */ 
    @AuraEnabled
    public static string fetchSummary(String participantId) {
        string participantdata;
        try{
            Application_Participant__c participant = new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticipant(participantId);
            string inflight =participant.Application__r.Inflight__c;
            Map<String, Object> inflightMap = (Map<String, Object>)system.JSON.deserializeUntyped(inflight);
            Map<String,Object> personalDetailsMap = new Map<String,Object>();
            personalDetailsMap.put('DATE OF RESOLUTION MEETING',(String)inflightMap.get('DATE OF RESOLUTION MEETING'));
            personalDetailsMap.put('How would like receive the message',Boolean.valueOf(inflightMap.get('How would like receive the message')));
            personalDetailsMap.put('Full Name', participant.AOB_FullName__c);
            personalDetailsMap.put('Omang Id Number', participant.AOB_IDNumber__c);
            personalDetailsMap.put('Cell Phone Number', participant.CNGCU_Phone__c);
            personalDetailsMap.put('Email Address', participant.CNGCU_Email__c);
            personalDetailsMap.put('receiveNotification', participant.AOB_NotificationPreference__c);
            personalDetailsMap.put('Do you', participant.AOB_DebitCard__c);
            personalDetailsMap.put('Suburb', participant.AOB_Suburb__c);
            personalDetailsMap.put('Street', participant.AOB_Street__c);
            personalDetailsMap.put('PostalCode', participant.AOB_PostalCode__c);
            personalDetailsMap.put('businessRole', participant.AOB_Role__c);
            personalDetailsMap.put('Province', participant.AOB_State__c);
            personalDetailsMap.put('CityTown', participant.Botswana_City__c);
            personalDetailsMap.put('Marital Status', participant.AOB_MaritalStatus__c);
            personalDetailsMap.put('Gender', participant.AOB_Gender__c);
            personalDetailsMap.put('Title', participant.AOB_Title__c);
            personalDetailsMap.put('Date of Birth', participant.AOB_DateofBirth__c);
            personalDetailsMap.put('Primary Nationality', participant.AOB_PrimaryNationality__c);
            personalDetailsMap.put('Occupation', participant.AOB_Occupation__c);
            personalDetailsMap.put('Gross Annual Income', participant.AOB_GrossAnnualIncome__c); 
            personalDetailsMap.put('Monthly Net Income', participant.AOB_MonthlyNetIncome__c);
            personalDetailsMap.put('Business Legal Name', participant.Application__r.AOB_BusinessLegalName__c);
            personalDetailsMap.put('cipa registration number', participant.Application__r.AOB_RegistrationNumber__c);
            personalDetailsMap.put('Gross annual turnover', participant.Application__r.AOB_GrossAnnualTurnover__c);
            personalDetailsMap.put('Entity type', participant.Application__r.AOB_BCCEntityType__c);
            personalDetailsMap.put('Street Number and name', participant.Application__r.AOB_Street__c);
            personalDetailsMap.put('City/Town', participant.Application__r.AOB_BotswanaCity__c);
            personalDetailsMap.put('Postal code', participant.Application__r.AOB_PostalCode__c);
            personalDetailsMap.put('Preferred branch where account is held', participant.Application__r.AOB_Preferred_Branch__c);
            personalDetailsMap.put('SUBURB', participant.Application__r.AOB_Suburb__c);
            personalDetailsMap.put('PROVINCE', participant.Application__r.AOB_State__c);
            personalDetailsMap.put('How would like receive the message', participant.Application__r.CNGCU_Email_Alerts__c);
            personalDetailsMap.put('Presence in Country', participant.Application__r.AOB_PresenceinCountry__c);
            personalDetailsMap.put('Signing Instructions', participant.Application__r.AOB_SigningInstructions__c);
            personalDetailsMap.put('What does the company do ?', participant.Application__r.AOB_Notes__c);
            personalDetailsMap.put('Incorporation Date', participant.Application__r.AOB_IncorporationDate__c);
            personalDetailsMap.put('Listed on an Approved Exchange', participant.Application__r.AOB_ListedonanApprovedExchange__c);
            personalDetailsMap.put('Business Proceeds (BCC)', participant.Application__r.AOB_BusinessProceeds__c);
             personalDetailsMap.put('Returns Classification Code', participant.Application__r.AOB_ReturnsClassificationCode__c);
             personalDetailsMap.put('Industry Classification (SARB) Code', participant.Application__r.AOB_IndustryClassificationSARBCode__c);
             personalDetailsMap.put('Industry Type (Sectorcode)', participant.Application__r.AOB_Sectorcode__c);
             personalDetailsMap.put('Address Valid From', participant.Application__r.AOB_AddressValidFrom__c);
             personalDetailsMap.put('Contribution', participant.Application__r.AOB_Contribution__c);
             personalDetailsMap.put('GROUP NAME', participant.Application__r.AOB_GroupName__c);
            personalDetailsMap.put('DATE OF REGISTRATION', participant.Application__r.AOB_DateofRegistration__c);
            personalDetailsMap.put('ENTITY TYPE CATEGORY', participant.Application__r.AOB_EntityTypeCategory__c);
            personalDetailsMap.put('signingArrangement', participant.Application__r.AOB_Signing_Arrangement__c);
             personalDetailsMap.putAll(inflightMap);
            if(participant.AOB_TransactOnTheBusiness__c == true){
                personalDetailsMap.put('businessTransact', 'TRUE');
                 personalDetailsMap.put('Do you', 'TRUE');
            }
            if(participant.AOB_TransactOnTheBusiness__c == false){
                personalDetailsMap.put('businessTransact', 'FALSE');
                personalDetailsMap.put('Do you', 'FALSE');
            }
            participantdata =System.JSON.serialize(personalDetailsMap);
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator.fetchSummary',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        return participantdata;
        
    }
    
    /**
    * @description fetch application data based on record Id 
    * @param participantId 
    * @return String
    */ 
    @AuraEnabled
    public static string fetchApplicationdata(String participantId) {
        string applicationdata;
         try{
        Application_Participant__c applicationfetch = new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticipant(participantId);
        String inflight =applicationfetch.Application__r.Inflight__c;
        Map<String,Object> companyDetailsMap = new Map<String,Object>();
        companyDetailsMap.put('GROUP NAME', applicationfetch.Application__r.AOB_GroupName__c);
        companyDetailsMap.put('DATE OF REGISTRATION', applicationfetch.Application__r.AOB_DateofRegistration__c);
        companyDetailsMap.put('ENTITY TYPE CATEGORY', applicationfetch.Application__r.AOB_EntityTypeCategory__c);
        companyDetailsMap.put('Business Legal Name', applicationfetch.Application__r.AOB_BusinessLegalName__c);
        companyDetailsMap.put('cipa registration number', applicationfetch.Application__r.AOB_RegistrationNumber__c);
        companyDetailsMap.put('Gross annual turnover', applicationfetch.Application__r.AOB_GrossAnnualTurnover__c);
        companyDetailsMap.put('Entity type', applicationfetch.Application__r.AOB_BCCEntityType__c);
        companyDetailsMap.put('Street Number and name', applicationfetch.Application__r.AOB_Street__c);
       companyDetailsMap.put('City/Town', applicationfetch.Application__r.AOB_BotswanaCity__c);
        companyDetailsMap.put('Postal code', applicationfetch.Application__r.AOB_PostalCode__c);
        companyDetailsMap.put('Preferred branch where account is held', applicationfetch.Application__r.AOB_Preferred_Branch__c);
        companyDetailsMap.put('Suburb', applicationfetch.Application__r.AOB_Suburb__c);
        companyDetailsMap.put('Province', applicationfetch.Application__r.AOB_State__c);
        companyDetailsMap.put('How would like receive the message', applicationfetch.Application__r.CNGCU_Email_Alerts__c);
        companyDetailsMap.put('Presence in Country', applicationfetch.Application__r.AOB_PresenceinCountry__c);
        companyDetailsMap.put('Signing Instructions', applicationfetch.Application__r.AOB_SigningInstructions__c);
        companyDetailsMap.put('What does the company do?', applicationfetch.Application__r.AOB_Notes__c);
        companyDetailsMap.put('Incorporation Date', applicationfetch.Application__r.AOB_IncorporationDate__c);
        companyDetailsMap.put('Listed on an Approved Exchange', applicationfetch.Application__r.AOB_ListedonanApprovedExchange__c);
        companyDetailsMap.put('Business Proceeds (BCC)', applicationfetch.Application__r.AOB_BusinessProceeds__c);
        companyDetailsMap.put('Returns Classification Code', applicationfetch.Application__r.AOB_ReturnsClassificationCode__c);
        companyDetailsMap.put('Industry Classification (SARB) Code', applicationfetch.Application__r.AOB_IndustryClassificationSARBCode__c);
        companyDetailsMap.put('Industry Type (Sectorcode)', applicationfetch.Application__r.AOB_Sectorcode__c);
        companyDetailsMap.put('Address Valid From', applicationfetch.Application__r.AOB_AddressValidFrom__c);
        companyDetailsMap.put('Contribution', applicationfetch.Application__r.AOB_Contribution__c);
                           
        if(!String.isEmpty(inflight)){  
            Map<String, Object> inflightMap = (Map<String, Object>)system.JSON.deserializeUntyped(inflight);
            companyDetailsMap.put('DATE OF RESOLUTION MEETING',(String)inflightMap.get('DATE OF RESOLUTION MEETING'));
            companyDetailsMap.put('Intended use of account',(String)inflightMap.get('Intended use of account'));
           companyDetailsMap.put('How would like receive the message',Boolean.valueOf(inflightMap.get('How would like receive the message')));
        }
        applicationdata =System.JSON.serialize(companyDetailsMap);
         } catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator.fetchApplicationdata',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        return applicationdata;
    }
    
    @AuraEnabled
    public static String getPreferredBranch(String applicationId) {
        try {
           Application_Participant__c applicationfetch = new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticipant(applicationId);
            return applicationfetch.Application__r.AOB_Preferred_Branch__c;
        } catch (Exception ex) {
              LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator.getPreferredBranch',ex.getMessage()}, ex);
            return null;
        }
    }
    
    /**
    * @description save data of participants based on screen name
    * @param participantId 
    * @param formData
    * @param screenName
    */ 
    @AuraEnabled
    public static void saveFormData(String participantId, String formData, String screenName){
        if(screenName == 'Application Details' ){
            AOB_CTRL_FormCreator.saveParticipantPersonalData(participantId,formData);
        }
        else if(screenName == 'Company Information'){
            AOB_CTRL_FormCreator.saveParticipantcomapanyData(participantId,formData);
        }
        else if(screenName == 'Matshelo Personal Information'){
           AOB_CTRL_FormCreator.saveParticipantPersonalData(participantId,formData);
        }
        else if(screenName == 'Matshelo Company Information'){
            AOB_CTRL_FormCreator.saveParticipantcomapanyData(participantId,formData);
        }  
        
    }
    
    /**
    * @description save data of participants personal info
    * @param participantId 
    * @param formData
    */ 
    @AuraEnabled
    public static void saveParticipantPersonalData(String participantId, String formData){
        try{
            Map<String, Object> jsonData = (Map<String, Object>)system.JSON.deserializeUntyped(formData);
            Application_Participant__c participant = new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticipant(participantId);
            List<Application__c>  participantpersonaldata = new AOB_BOTS_SEL_Application().selectAppsById(participant.Application__c);
            if((String)jsonData.get('signingArrangement')!=null){
                participantpersonaldata[0].AOB_Signing_Arrangement__c=(String)jsonData.get('signingArrangement');
            }
            update participantpersonaldata;
            participant.AOB_Suburb__c = (String)jsonData.get('Suburb'); 
            participant.AOB_State__c = (String)jsonData.get('Province');
            participant.AOB_Street__c = (String)jsonData.get('Street');
            participant.AOB_TransactOnTheBusiness__c = Boolean.valueOf(jsonData.get('businessTransact'));
            participant.AOB_DebitCard__c = Boolean.valueOf(jsonData.get('Do you'));
            participant.CNGCU_Phone__c = (String)jsonData.get('Cell Phone Number');
            participant.CNGCU_Email__c = (String)jsonData.get('Email Address');
            participant.AOB_IDNumber__c = (String)jsonData.get('Omang Id Number');
            participant.AOB_NotificationPreference__c = (String)jsonData.get('receiveNotification');
            participant.AOB_Role__c = (String)jsonData.get('businessRole');
            participant.Botswana_City__c= (String)jsonData.get('CityTown');
            participant.AOB_PostalCode__c = (String)jsonData.get('PostalCode'); 
            participant.AOB_MaritalStatus__c = (String)jsonData.get('Marital Status'); 
            participant.AOB_Gender__c= (String)jsonData.get('Gender');
            participant.AOB_Title__c= (String)jsonData.get('Title');
            participant.AOB_DateofBirth__c = Date.valueOf((String)jsonData.get('Date of Birth'));
            participant.AOB_PrimaryNationality__c= (String)jsonData.get('Primary Nationality');
            participant.AOB_Occupation__c= (String)jsonData.get('Occupation'); 
            participant.AOB_GrossAnnualIncome__c = Decimal.valueOf(String.valueOf(jsonData.get('Gross Annual Income')));
            participant.AOB_MonthlyNetIncome__c = Decimal.valueOf(String.valueOf(jsonData.get('Monthly Net Income')));
            update participant;
        } 
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator.saveParticipantPersonalData',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
  
    /**
    * @description save data of participants company info
    * @param participantId 
    * @param formData
    */
    @AuraEnabled
    public static void saveParticipantcomapanyData(String participantId, String formData){
        try{
            Map<String, Object> jsonData = (Map<String, Object>)system.JSON.deserializeUntyped(formData);
            Application_Participant__c participantcompanyid = new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticipant(participantId);
            List<Application__c>  participantcompanydata = new AOB_BOTS_SEL_Application().selectAppsById(participantcompanyid.Application__c);
            Map<String, Object> inflightData = new Map<String, Object>();
            map<string,Object>jsonData2 = new Map<String, Object>();  
            if(String.isNotBlank(participantcompanydata[0].Inflight__c)){
                inflightData = (Map<String, Object>)System.JSON.deserializeUntyped(participantcompanydata[0].Inflight__c);
                jsonData2.putAll(inflightData);
            }
            jsonData2.put('Intended use of account',(String)jsonData.get('Intended use of account'));
            jsonData2.put('DATE OF RESOLUTION MEETING',(String)jsonData.get('DATE OF RESOLUTION MEETING'));
            jsonData2.put('How would like receive the message',Boolean.valueOf(jsonData.get('How would like receive the message')));
            participantcompanydata[0].AOB_Street__c = (String)jsonData.get('Street Number and name');
            if((String)jsonData.get('DATE OF RESOLUTION MEETING')!=null){
                participantcompanydata[0].AOB_DateofResolutionMeeting__c=Date.valueOf((String)jsonData.get('DATE OF RESOLUTION MEETING'));
            }
            participantcompanydata[0].AOB_BotswanaCity__c= (String)jsonData.get('City/Town');
            participantcompanydata[0].AOB_PostalCode__c = (String)jsonData.get('Postal code');
            participantcompanydata[0].AOB_Preferred_Branch__c = (String)jsonData.get('Preferred branch where account is held');
            participantcompanydata[0].AOB_Suburb__c = (String)jsonData.get('Suburb');
            participantcompanydata[0].AOB_State__c = (String)jsonData.get('Province');
            participantcompanydata[0].CNGCU_Email_Alerts__c = Boolean.valueOf(jsonData.get('How would like receive the message'));
            participantcompanydata[0].Inflight__c = System.JSON.serialize(jsonData2);
            participantcompanydata[0].AOB_PresenceinCountry__c = (String)jsonData.get('Presence in Country');
            participantcompanydata[0].AOB_SigningInstructions__c = (String)jsonData.get('Signing Instructions');
            participantcompanydata[0].AOB_Notes__c = (String)jsonData.get('What does the company do?');
            participantcompanydata[0].AOB_ListedonanApprovedExchange__c = (String)jsonData.get('Listed on an Approved Exchange');
              Object incorporationDateObj = jsonData.get('Incorporation Date');
           if (incorporationDateObj != null) {
                String incorporationDateStr = (String) incorporationDateObj;
                     if (String.isNotBlank(incorporationDateStr)) {
                participantcompanydata[0].AOB_IncorporationDate__c = Date.valueOf(incorporationDateStr);
               }
             }
            participantcompanydata[0].AOB_BusinessProceeds__c = (String)jsonData.get('Business Proceeds (BCC)');
            participantcompanydata[0].AOB_ReturnsClassificationCode__c = (String)jsonData.get('Returns Classification Code');
            participantcompanydata[0].AOB_IndustryClassificationSARBCode__c = (String)jsonData.get('Industry Classification (SARB) Code');
            participantcompanydata[0].AOB_Sectorcode__c = (String)jsonData.get('Industry Type (Sectorcode)');
            participantcompanydata[0].AOB_AddressValidFrom__c = Date.valueOf((String)jsonData.get('Address Valid From'));
            update participantcompanydata;
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator.saveParticipantcomapanyData',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        
    }
    
    /**
    * @description save participants documents and relate to participant's application document
    * @param base64 
    * @param filename 
    * @param recordId 
    * @return String
    */
    public static String createAndUploadFile(String base64, String filename, String recordId) {
        try{
            Application_Document__c document = new Application_Document__c();
            document.Application_Participant__c = recordId;
            insert document;
            return document.id;
        }catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator.createAndUploadFile',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        
    }
    
    /**
    * @description creates contentVersion and ContentDocument for participant document
    * @param base64 
    * @param filename
    * @param recordId
    * @return String
    */
    @AuraEnabled
    public static String uploadFile(String base64, String filename, String recordId) {
        String recID = createAndUploadFile(base64, filename,recordId);
        ContentVersion cv = createContentVersion(base64, filename);
        ContentDocumentLink cdl = createContentLink(cv.Id, recID);
        if (cv == null || cdl == null) { return null; }
        return cdl.Id;
    }
    
    /**
    * @description creates contentVersion and ContentDocument for participant document for Matshelo
    * @param base64 
    * @param filename
    * @param omangId
    * @param recordId
    * @return String
    */ 
    @AuraEnabled
    public static String uploadFileSocty(String base64, String filename,String omangId, String recordId) {
        Application_Participant__c ap = New AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantByOmangId(omangId, recordId);
        String recID = createAndUploadFile(base64, filename,ap.id);
        ContentVersion cv = createContentVersion(base64, filename); 
        ContentDocumentLink cdl = createContentLink(cv.Id, recID);
        if (cv == null || cdl == null) { return null; }
        return cdl.Id;
    }
    /*
    * @description Creates a content version from a given file's base64 and name
    * @param base64 - base64 string that represents the file
    * @param filename - full file name with extension, i.e. 'products.csv'
    * @return {ContentVersion} - returns the newly created ContentVersion, or null
    * if there was an error inserting the record
    */
    @TestVisible private static ContentVersion createContentVersion(String base64, String filename) {
        try {
            ContentVersion cv = new ContentVersion();
            cv.VersionData = EncodingUtil.base64Decode(base64);
            cv.Title = filename;
            cv.PathOnClient = filename;
            insert cv;
            return cv;
        } catch(DMLException ex) {
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator.createContentVersion',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    /*
    * @description Creates a content link for a given ContentVersion and record
    * @param contentVersionId - Id of the ContentVersion of the file
    * @param recordId - Id of the record you want to attach this file to
    * @return ContentDocumentLink - returns the newly created ContentDocumentLink, 
    *   or null if there was an error inserting the record
    */
    @TestVisible private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        try {
            ContentDocumentLink cdl = new ContentDocumentLink();
            ContentVersion cv = new AOB_BOTS_SEL_ContentVersion().selectContentVersionById(contentVersionId);
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdl.LinkedEntityId = recordId;
            cdl.ShareType = 'V';
            insert cdl;
            return cdl;
        } catch(DMLException ex) {
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator.createContentLink',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    
    /**
    * @description method to get keyContact person record based on applicationId
    * @param appId String
    * @return String
    */   
    @AuraEnabled
    public static string getKeyContactParticipantIds(String appId) {
        List<Application_Participant__c> participants = new List<Application_Participant__c>();
        try { 
            participants = new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantByKeyContact(appId,true);
            if(!participants.isEmpty()) {
                return participants[0].Id;
            } 
            else {
                List<Application_Participant__c> part = [select id,CNGCU_Phone__c,CNGCU_Email__c,Application__c from Application_Participant__c where Application__c=:appId order by CreatedDate ASC]; 
                 return part[0].Id;
            }
        } catch(Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator.getKeyContactParticipantIds',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage()); 
        }
       
    }   
    
   
}