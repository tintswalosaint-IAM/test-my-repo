/***************************************************************************************
@ Author            : Lokesh Bothsa 
@ Date              : July 2023
@ Name of the Class : BCB_CTRL_FormCreator
@description        : Class for generic form creation based on database records
@ Last Modified By  : Ravi Myaka  
@ Last Modified On  : 03-04-2023
@ Modification description : SFP-37302
*************************************
@ Last Modified By  : Alex Niyonsaba 
@ Last Modified On  : 08-07-2025
@ Modification description : SFP-50931
*************************************
@ Last Modified By  : Alex Niyonsaba 
@ Last Modified On  : 15-10-2025
@ Modification description : Updates made to address an issue where CTRAD Account name is displaying as 'MOLLELOA ACCOUNT' instead of 'SME Trade Account Bundle' on the pre-application screen - The fix is made is by invoking selectMemoProductByProductCode(productCode) instead of selectByProductCode(productCode) inside getProductByProductCode(String productCode) block.
@ User Story: SFP-53804
***************************************************************************************/
public without sharing class BCB_CTRL_FormCreator {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('BCB_CTRL_FormCreator');
    /**description english*/
    private static final String englishUs = 'en_US';
    /**description EN*/
    private static final String english = 'EN';
    /**description Testing Subtitle*/
    private static final String testingSubtitle = 'Testing Subtitle';
    /**description Ttile*/
    private static final String title = 'Ttile';
    /**description Uganda MVP2 Personal Details*/
    private static final String personalDetailsScreen = 'Uganda MVP2 Personal Details';
    /**description Uganda MVP2 company Details Screen*/
    private static final String companyDetailsScreen  = 'Uganda MVP2 Company Details';
    /**description Uganda MVP2 account Setup Screen*/
    private static final String accountSetupScreen = 'Uganda MVP2 Account Setup';
    /**description Uganda MVP2 application Summary Screen*/
    private static final String applicationSummaryScreen = 'Uganda MVP2 Application Summary';
    /**description Product code*/
    private static final String prodOd005 = 'OD005';
    /**description Entity type*/
    private static final String entityUg = 'entityTypeUG';
    /**description Entity type*/
    private static final String soleProprietor =  'Sole Proprietor';
    /**description Currency type*/
    private static final String currencyTypeUg = 'currencyTypeUG';
    /**description Currency*/
    private static final String currencyUgx = 'UGX';
    /**description Source of funds*/
    private static final String sourceOfFunds = 'sourceOfFunds';
    /**description Income from own business*/
    private static final String incomeFromOwnBusiness = 'Income from Own Business';
    /**description mode of payment for funding*/
    private static final String modeOfPayment  = 'MODE OF PAYMENT';
    /**description mobile money*/
    private static final String mobileMoney = 'Mobile Money';
    /**description Country of registartion*/
    private static final String countryRegistration = 'countryOfRegistration';
    /**description Country*/
    private static final String ugandaCountry = 'Uganda';
    /**description Country of tax residence*/
    private static final String countryOfTaxResidency = 'countryOfTaxResidency';
    /**description invalid type of product scheme code*/
    private static final String invalidProductCode = 'Invalid product scheme code';
    /**description first name*/
    private static final String firstName = 'firstName';
    /**description last name*/
    private static final String lastName =  'lastName';
    /**description share personal info*/
    private static final String sharePersonalInfo = 'sharePersonalInfo';
    /**description communicate with others*/
    private static final String communicateOthers = 'communicateOthers';
    /**description research*/
    private static final String research = 'research';
    /**description market your product*/
    private static final String marketYourProduct = 'marketYourProduct';
    /**description literacy*/
    private static final String literacy = 'literacy';
    /**description text as true*/
    private static final String textTrue = 'TRUE';
    /**description text as false*/
    private static final String textFalse = 'FALSE';
    /**description validation document*/
    private static final String validationDocument= 'validationOfDocument';
    /**description title*/
    private static final String title1 = 'title';
    /**description gender*/
    private static final String gender = 'gender';
    /**description other name*/
    private static final String otherName= 'otherName';
    /**description national idnumber*/
    private static final String nationalIdNumber = 'nationalIDNumber';
    /**description date of birth*/
    private static final String dateOfBirth = 'dateOfBirth';
    /**description nin expiry date*/
    private static final String ninExpiryDate  = 'ninExpiryDate';
    /**description cell phonenumber*/
    private static final String cellPhoneNumber = 'cellPhoneNumber';
    /**description email address*/
    private static final String emailAddress = 'emailAddress';
    /**description legal name*/
    private static final String legalName = 'businessLegalName';
    /**description registartion number*/
    private static final String registrationNumber = 'businesRegNumber';
    /**description tax registation number*/
    private static final String taxRegistrationNumber = 'taxRegistrationNumber';
    /**description trading license number*/
    private static final String tradingLicenseNumber = 'tradingLicenseNumber';
    /**description business email*/
    private static final String businessEmail = 'businessEmail';
    /**description business contact number*/
    private static final String businessContactNumber = 'businessContactNumber';
    /**description marital status*/
    private static final String maritalStatus = 'maritalStatus';
    /**description card number*/
    private static final String cardNumber = 'cardNumber';
    /**description number of employees*/
    private static final String numOfEmployees = 'noOfEmployees';
    /**description industrial sector*/
    private static final String industrialSector = 'industrialSector';
    /**description primary sector code*/
    private static final String primarySectorCode = 'primarySectorCode';
    /**description secondary sector code*/
    private static final String secondarySectorCode = 'secondarySectorCode';
    /**description tertiory sector code*/
    private static final String tertiarySectorCode = 'tertiorySectorCode';
    /**description access to markets product*/
    private static final String accessToMarkets = 'accessToMarkets';
    /**description financial fitness training product*/
    private static final String financialFitnessTraining =  'financialFitnessTraining';
    /**description insurance Offerings product*/
    private static final String insuranceOfferings = 'insuranceOfferings';
    /**description access to Finance product*/
    private static final String accessToFinance = 'accessToFinancing';
    /**description investment Offering product*/
    private static final String investmentOffering = 'investmentOffering';
    /**description coaching medium business product*/
    private static final String coachingMediumBusiness = 'mentoringCoachingForSmallAndMediumBusinesses';
    /**description network Event product*/
    private static final String networkEvent = 'networkingEventsWithAccessToSubjectMatterIndustryExpert';
    /**description appObject*/
    private static final String appObject = 'Application__c';
     /**description participantObject*/
    private static final String participantObject = 'Application_Participant__c';
    /**description preferred branch*/
    private static final String preferredBranch = 'AOB_Preferred_Branch__c';
    /**description city*/
    private static final String city = 'AOB_City__c';
     /**description bank*/
     private static final String bankName = 'AOB_Name_Of_Bank__c';
     /**description state*/
     private static final String State = 'AOB_State__c';
    /**description primary country*/
    private static final String taxResidentCountry = 'AOB_Outside_of_Primary_Country__c';
    /**description intial Deposit*/
    private static final String intialDeposit = 'AOB_Source_of_initial_deposit__c';
    /**description company registation certificate*/
    private static final String companyRegistrationCertificate = 'UPLOAD COMPANY REGISTRATION CERTIFICATE';
    /**description upload company registration certificate*/
    private static final String uploadCompanyRegistrationCertificate = 'Upload Company Registration Certificate';
    /**description upload trade license*/
    private static final String uploadTradeLicense = 'Upload trade license';
    /**description upload statement particulars*/
    private static final String uploadStatemetParticulars = 'Upload statement of Particulars for sole props';
    /**description account number*/
    private static final String accountNumber = 'accountNumber';
    /**description selected currency*/
    private static final String selectedCurrency = 'selectedCurrency';
    /**description product object*/
    private static final String prodObj = 'product';
    /**description product scheme code*/
    private static final String schemeCode = 'schemeCode';
    /**description key contact mobile number*/
    private static final String keyContactMobile  = 'keyContactMobile';
    /**description key contact email*/
    private static final String keyContactEmail = 'keyContactEmail'
        /**description application id*/;
    private static final String appId = 'applicationId';
    /**description contact number*/
    private static final String contactNumber = 'contactNumber';
    /**description email address*/
    private static final String email = 'Email';
    /**description matching status*/
    private static final String matchingStatus = 'matchingStatus';
    /**description uploading registration document*/
    private static final String uploadRegistrationDocument = 'Upload Registration Document';
    /**description selfie tag*/
    private static final String selfTag = 'selfieTag';
    /**description signature tag*/
    private static final String signatureTag =  'signatureTag';
    /**description face image*/
    private static final String faceImage = 'FaceImage';
    /**description upload signature*/
    private static final String uploadSignature = 'upload signature';
    
    /**
* @description gets a list of fields to be displayed based on screen and product
* @param applicationId  - Id of the Community
* @param screenName - Auth Provider user data describing the User to create
* @return AOB_DTO_Form 
*/
    @AuraEnabled
    public static AOB_DTO_Form getFields(Id applicationId,String screenName) {
        String language=AOB_BOTS_Utils.getUserLanguage();
        if(language == englishUs){
            language = english;
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
* @description This method used reterive Document
* @param appId - string
* @return List < BCB_DocumentData >
*/
    @AuraEnabled
    public static List < BCB_DocumentData > relatedFiles(String appId) {
        List < BCB_DocumentData > documentlist = new List < BCB_DocumentData > ();
        Set < id > documentidlist = new set < id > ();
        Map<id,String> idVsDocTypeMap = new Map<id,String>();
        List<Application_Document__c> appDocList = [
            SELECT Id, Document_Type__c, Application_Participant__r.Name
            FROM Application_Document__c
            WHERE Application_Participant__c = :appId
        ];
        for (Application_Document__c app: appDocList) {
            documentidlist.add(app.id);
            idVsDocTypeMap.put(app.id, app.Document_Type__c);
        }
        if (documentidlist.size() > 0) {
            List < ContentDocumentLink > cdllist = [SELECT ContentDocument.Id, ContentDocument.Title, LinkedEntityId, ContentDocument.CreatedDate, ContentDocument.FileType FROM ContentDocumentLink where LinkedEntityId In: documentidlist];
            for (ContentDocumentLink cd: cdllist) {
                BCB_DocumentData mdoc = new BCB_DocumentData();
                mdoc.fileName = cd.ContentDocument.Title;
                mdoc.docName = idVsDocTypeMap.get(cd.LinkedEntityId);
                documentlist.add(mdoc);
            }
        }
        return documentlist;
    }
    /**
* @description This method used wapper BCB_DocumentData
*/
    
    public class BCB_DocumentData {
        /**
* @description This method used wapper base64
*/
        @AuraEnabled public string base64 {get;set;}
        /**
* @description This method used wapper fileName
*/
        @AuraEnabled public string fileName{get;set;}
        /**
* @description This method used wapper docName
*/
        @AuraEnabled public string docName{get;set;}
    }
    
    /**
* @description This method used reterive Document
* @param sapFields
* @return Map<String, List<AOB_DTO_SelectOption>>
*/
    public static Map<String, List<AOB_DTO_SelectOption>> getAllPicklistEntriesCodes(List<String> sapFields) {
        Map<String, List<AOB_DTO_SelectOption>> result = new Map<String, List<AOB_DTO_SelectOption>>();
        List<AOB_ReferencedData__c> referencedDataList = [
            SELECT Id, AOB_Code__c, Name, AOB_Default__c, AOB_SAPField__c
            FROM AOB_ReferencedData__c
            WHERE AOB_SAPField__c IN :sapFields AND AOB_Language__c = :UserInfo.getLanguage() AND AOB_isActive__c = TRUE
            ORDER BY AOB_Sequence__c ASC
        ];
        for (AOB_ReferencedData__c data : referencedDataList) {
            if (result.containskey(data.AOB_SAPField__c)) {
                result.get(data.AOB_SAPField__c).add(new AOB_DTO_SelectOption(data.AOB_Code__c, data.Name, data.AOB_Default__c));
            } else {
                result.put(data.AOB_SAPField__c, new List<AOB_DTO_SelectOption>{ new AOB_DTO_SelectOption(data.AOB_Code__c, data.Name, data.AOB_Default__c) });
            }
        }
        return result;
    }
    
    
    /**
* @description gets a list of fields to be displayed without application id based on screen name
* @param screenName - name of the currrent screen
* @return AOB_DTO_Form 
*/
    @AuraEnabled
    public static AOB_DTO_Form getFieldsWithoutAppId(String screenName) {
        String language=AOB_BOTS_Utils.getUserLanguage();
        if(language == englishUs){
            language = english; 
        }
        AOB_DTO_Form form = new AOB_DTO_Form();
        List<Application__c> apps;
        form.subTitle = testingSubtitle;
        form.title=title;
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
            if(field.AOB_MRITable__c != null){
                mriTables.add(field.AOB_MRITable__c );
            }
        }   
        Map<String, List<AOB_DTO_SelectOption>> refData = getAllPicklistEntriesCodes(mriTables);
        if(refData.isEmpty()){
            LOGGER.error('Unable to find any referenced data');
            throw new AuraHandledException('Unable to find any referenced data : mri tabs '+mriTables.toString()+' secid : '+sectionIds.toString()+ ' language user  '+UserInfo.getLanguage() +' ref data 2 '+[SELECT Id, AOB_Code__c, Name, AOB_Default__c, AOB_SAPField__c FROM AOB_ReferencedData__c WHERE AOB_SAPField__c IN :mriTables AND AOB_Language__c = :UserInfo.getLanguage() AND AOB_isActive__c = TRUE].toString());
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
* @description gets a SchemCode And Currency
* @param applicationId
* @return Application_Participant__c 
*/
    @AuraEnabled
    public static Application_Participant__c  getSchemCodeAndCurrency(String applicationId){ 
        List<Application_Participant__c> appParticpant = [select Id,Application__c,Application__r.AOB_Schema_Code__c,Application__r.AOB_Selected_Currency__c from Application_Participant__c where Id =:applicationId];
        return appParticpant[0];
        
    }
    
    /**
* @description gets a list of apps
* @param screens - all flow screens
* @param applicationId
* @return List<Application__c> 
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
            List<Application_Participant__c> apps = New SEL_ApplicationParticipant().selectApplicationParticpantById(applicationId);
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
            }
            update apps;
            
        }
        catch (Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] {'BCB_CTRL_FormCreator',ex.getMessage()}, ex);
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
            List<Application_Participant__c> apps = New SEL_ApplicationParticipant().selectApplicationParticpantById(applicationId);
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
                        apps[0].AOB_PreviousScreens__c = screens[screens.size()-2];  
                    } else {
                        apps[0].AOB_PreviousScreens__c = ''; 
                    }
                }
            }
            update apps;
        }
        catch (Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] {'BCB_CTRL_FormCreator: goBacktoPreviousStep',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        
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
        if(screenName == personalDetailsScreen){
            inflightData= BCB_CTRL_FormCreator.fetchPersonalDetails(appId);
        }
        else if(screenName == companyDetailsScreen){
            inflightData= BCB_CTRL_FormCreator.fetchCompanyDetails(appId);
        }
        else if(screenName == accountSetupScreen){
            inflightData= BCB_CTRL_FormCreator.fetchAccountSetup(appId);
        }
        else if(screenName == applicationSummaryScreen){
            inflightData= BCB_CTRL_FormCreator.fetchApplicationSummary(appId);
        }
        return inflightData;
    }
    
    /**
* @description fetch participant data and application data to populate on UI
* @param productSchemeCode 
* @return String
*/ 
    @AuraEnabled
    public static String fetchApplicationDefaultData(String productSchemeCode) {
        String participantdata;
        try {
            if (productSchemeCode != null && productSchemeCode.equals(prodOd005)) {
                Map<String, Object> personalDetailsMap = new Map<String, Object>();
                personalDetailsMap.put(entityUg, soleProprietor);
                personalDetailsMap.put(currencyTypeUg,currencyUgx);
                personalDetailsMap.put(sourceOfFunds,incomeFromOwnBusiness);
                personalDetailsMap.put(modeOfPayment,mobileMoney);
                personalDetailsMap.put(countryRegistration,ugandaCountry);
                personalDetailsMap.put(countryOfTaxResidency,ugandaCountry);  
                participantdata = System.JSON.serialize(personalDetailsMap);
            } else {
                participantdata = invalidProductCode;
            }
        } catch (Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'BCB_CTRL_FormCreator', ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return participantdata;
    }
    
    /**
* @description fetch participant data and application data to populate on UI
* @param participantId 
* @return String
*/ 

public static Map<String, String> maritalStatusNameVsCode = new Map<String, String> {
        'SINGLE' => '001',
        'MARRIED' => '002',
        'SEPARATED' => '003',
        'DIVORCED' => '004',
        'WIDOWED' => '005',
        'NOT GIVEN' => '008',
        'LIVE-IN RELATIONSHIP' => '009'
    };

    @AuraEnabled
    public static String fetchPreApplicationDirectorData(String participantId) {
        String participantdata;
        Id individualRecordTypeId;
        List<Individual> individualRecord;
        Individual individ;
        try {
            List<Application_Participant__c> participantList = new SEL_ApplicationParticipant().selectApplicationParticpantById(participantId);
            if (participantList != null && !participantList.isEmpty()) {
                Application_Participant__c participant = participantList[0];
                individualRecordTypeId = Schema.SObjectType.Individual.getRecordTypeInfosByDeveloperName().get('Uganda_BCB_Account_Onboarding').getRecordTypeId();
                individualRecord = [SELECT Id, AOB_Declaration_of_Literacy__c, FirstName, LastName, AOB_Documents_Validation__c,
                                    AOB_Personal_Information_Consent__c, AOB_Services_Special_Offers_Consent__c,
                                    AOB_Research_Consent__c, AOB_Market_Your_Product_Consent__c
                                    FROM Individual WHERE Application_Participant__c = :participantId];
                if (!individualRecord.isEmpty()) {
                    individ = individualRecord[0];
                    Map<String, Object> individualDataMap = new Map<String, Object>();
                    individualDataMap.put(firstName, individ.FirstName);
                    individualDataMap.put(lastName, individ.LastName);
                    individualDataMap.put(sharePersonalInfo, individ.AOB_Personal_Information_Consent__c);
                    individualDataMap.put(communicateOthers, individ.AOB_Services_Special_Offers_Consent__c);
                    individualDataMap.put(research, individ.AOB_Research_Consent__c);
                    individualDataMap.put(marketYourProduct, individ.AOB_Market_Your_Product_Consent__c);
                    individualDataMap.put(literacy, textTrue);
                    individualDataMap.put(validationDocument, textTrue);       
                    Map<String, Object> personalDetailsMap = new Map<String, Object>();
                    personalDetailsMap.put(entityUg, soleProprietor);
                    personalDetailsMap.put(currencyTypeUg,participant.CurrencyIsoCode);
                    personalDetailsMap.put(sourceOfFunds,incomeFromOwnBusiness);
                    personalDetailsMap.put(modeOfPayment,mobileMoney);
                    personalDetailsMap.put(countryRegistration,ugandaCountry);
                    personalDetailsMap.put(countryOfTaxResidency,ugandaCountry); 
                    personalDetailsMap.put(title1, participant.AOB_Title__c);
                    personalDetailsMap.put(gender, participant.AOB_Gender__c);
                    personalDetailsMap.put(firstName, participant.CNGCU_First_Name__c);
                    personalDetailsMap.put(lastName, participant.CNGCU_Last_Name__c);
                    personalDetailsMap.put(otherName, participant.AOB_Preferred_Name__c);
                    personalDetailsMap.put(nationalIdNumber, participant.AOB_IDNumber__c);
                    personalDetailsMap.put(dateOfBirth, participant.AOB_DateofBirth__c);
                    personalDetailsMap.put(ninExpiryDate, participant.AOB_National_ID_expiry_date__c);
                    personalDetailsMap.put(cellPhoneNumber, participant.CNGCU_Phone__c);
                    personalDetailsMap.put(emailAddress, participant.CNGCU_Email__c);
                    personalDetailsMap.put(sourceOfFunds, participant.AOB_Occupation__c);
                    personalDetailsMap.put(legalName, participant.Application__r.AOB_BusinessLegalName__c);
                    personalDetailsMap.put(registrationNumber,participant.Application__r.AOB_RegistrationNumber__c);
                    personalDetailsMap.put(taxRegistrationNumber, participant.Application__r.Tax_Identification_Number__c);
                    personalDetailsMap.put(tradingLicenseNumber, participant.Application__r.AOB_Document_Number__c);
                    personalDetailsMap.put(businessEmail, participant.Application__r.CNGCU_CSEmail__c);
                    personalDetailsMap.put(businessContactNumber, participant.Application__r.AOB_Phone__c);
                    personalDetailsMap.put(maritalStatus, maritalStatusNameVsCode.get(participant.AOB_MaritalStatus__c)); 
                    
                    personalDetailsMap.put(gender, participant.AOB_Gender__c);
                    string inflight =participant.Application__r.Inflight__c;
                    if(!String.isEmpty(inflight)){  
                        Map<String, Object> inflightMap = (Map<String, Object>)system.JSON.deserializeUntyped(inflight);
                        personalDetailsMap.put(cardNumber,(String)inflightMap.get(cardNumber));
                    }
                    
                    personalDetailsMap.putAll(individualDataMap);
                    participantdata = JSON.serialize(personalDetailsMap);
                } else {
                    participantdata = null;
                }
            } else {
                participantdata = null;
            }
        } catch (Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'BCB_CTRL_FormCreator', ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return participantdata;
    }
    
    /**
* @description class to form application wrapper from  screen input to create application 
*/
    public class BCB_DTO_DirectorInform{    
        String nationalIDNumber;
        String productCode;
        String firstName;
        String lastName;
        String cellPhoneNumber;
        String emailAddress;
        String currencyTypeUG;
        String title;
        String gender;
        String otherName;
        String dateOfBirth;
        String ninExpiryDate;
        String sourceOfFunds;
        String businessLegalName;
        String businesRegNumber;
        String taxRegistrationNumber;
        String tradingLicenseNumber;
        String businessEmail;
        String businessContactNumber;
    }
    
    /**
* @description fetch application  currency data based on record Id 
* @param recordId 
* @return String
*/ 
    @AuraEnabled
    public static String getApplicationCurrency(String recordId) {
        return [SELECT Id, Application__r.AOB_Selected_Currency__c
                FROM Application_Participant__c
                WHERE Id = :recordId].Application__r.AOB_Selected_Currency__c;
    } 
    
    /**
* @description fetch application data based on record Id 
* @param participantId 
* @return String
*/ 
    @AuraEnabled
    public static string fetchPersonalDetails(String participantId) {
        try{
            String personalDetails;
            BCB_DTO_PersonalDetails jsonData = new BCB_DTO_PersonalDetails();
            List<Application_Participant__c> participant = new SEL_ApplicationParticipant().selectApplicationParticpantById(participantId);
            List<Application__c> application = new SEL_Application().selectAppsById(participant[0].Application__c);
            if(!String.isBlank(participant[0].AOB_Street__c)){
                jsonData.prominentPosition = application[0].AOB_PreviouslyHeldProminentOffice__c ? textTrue : textFalse;
                jsonData.familyPromientPosition = application[0].AOB_FamilyInProminentPublicOffice__c ? textTrue : textFalse;
                jsonData.taxResident = participant[0].AOB_resident_outside_of_Primary_Country__c ? textTrue : textFalse; 
                jsonData.relatedPartiesUS = participant[0].AOB_US_Related_Parties__c ? textTrue : textFalse; 
            }
            jsonData.heldOffice = application[0].AOB_PreviouslyHeldOffice__c;
            jsonData.officeName = application[0].AOB_FamilyPreviouslyHeldOffice__c;
            jsonData.taxResidentCountry = participant[0].AOB_Outside_of_Primary_Country__c;
            jsonData.city = participant[0].AOB_City__c;
            jsonData.district = participant[0].AOB_UG_BCB_District__c;
            jsonData.plotNumberDetails = participant[0].AOB_Street__c;
            personalDetails = System.JSON.serialize(jsonData);
        
            return personalDetails;
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'BCB_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    } 
    
    /**
* @description fetch application data based on record Id 
* @param participantId 
* @return String
*/ 
    @AuraEnabled
    public static string fetchCompanyDetails(String participantId) {
        try{
            String companyDetails;
            BCB_DTO_CompanyDetails jsonData = new BCB_DTO_CompanyDetails();
            List<Application_Participant__c> participant = new SEL_ApplicationParticipant().selectApplicationParticpantById(participantId);
            List<Application__c> application = new SEL_Application().selectAppsById(participant[0].Application__c);
            string inflight =application[0].AOB_inflightData__c;
            if(!String.isEmpty(inflight)){  
                Map<String, Object> inflightmap = (Map<String, Object>)system.JSON.deserializeUntyped(inflight);
                jsonData.secondarySectorCode =((String)inflightmap.get(secondarySectorCode));
                jsonData.tertiorySectorCode =((String)inflightmap.get(tertiarySectorCode));
            }   
            if(!String.isBlank(participant[0].AOB_City__c)){
                jsonData.grossIncomeEntity = application[0].AOBEntity_earn_more_than_50_gross_income__c ? textTrue : textFalse;
                jsonData.grossAssetsEntity = application[0].AOB_Entity_hold_50_or_more_of_its_gross__c ? textTrue : textFalse;
            }
            jsonData.grossIncomeEntity = application[0].AOBEntity_earn_more_than_50_gross_income__c ? textTrue : textFalse;
            jsonData.grossAssetsEntity = application[0].AOB_Entity_hold_50_or_more_of_its_gross__c ? textTrue : textFalse;
            jsonData.registrationDate = (application[0].AOB_DateofRegistration__c == null) ? null : String.valueOf(application[0].AOB_DateofRegistration__c);
            jsonData.anticipatedAnnualTO = ((application[0].Expected_Annual_Yearly_Turnover_To__c == null) ? '' : String.valueOf(application[0].Expected_Annual_Yearly_Turnover_To__c));
            jsonData.sourceOfFunds = application[0].Intent_to_Future_Deposits_Fund__c; 
            jsonData.preferredSMContact = application[0].AOB_Preferred_Social_media_Channel__c; 
            jsonData.newAccountReason = application[0].Your_Account_Notes__c;
            jsonData.businessCity =  application[0].AOB_City__c;
            jsonData.businessDistrict = application[0].Correspondence_Province__c;
            jsonData.businessPlotDetails = application[0].AOB_Street__c;
            jsonData.State = application[0].AOB_State__c ;
            jsonData.noOfEmployees = string.valueOf(application[0].AOB_Company_employees__c);
            companyDetails = System.JSON.serialize(jsonData);
            return companyDetails;
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'BCB_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    /**
* @description fetch application data based on record Id 
* @param participantId 
* @return String
*/ 
    @AuraEnabled
    public static string fetchAccountSetup(String participantId){
        try {
            String accountSetup;
            BCB_DTO_AccountSetup jsonData = new BCB_DTO_AccountSetup();
            List<Application_Participant__c> participant = new SEL_ApplicationParticipant().selectApplicationParticpantById(participantId);
            List<Application__c> application = new SEL_Application().selectAppsById(participant[0].Application__c);
            List<Application_Line_Item__c> appLineitem = new SEL_ApplicationLineItem().selectApplicationLineItemByApplicationId(application[0].id);
            jsonData.emailStatement = application[0].CNCGU_Email_Statements__c ? textTrue : textFalse;
            jsonData.preferredBranch = application[0].AOB_Preferred_Branch__c;
            jsonData.phoneNumber = participant[0].CNGCU_Phone__c;
            jsonData.initialDeposit = application[0].AOB_Source_of_initial_deposit__c;
            jsonData.initialDepositAmount = (application[0].First_Deposit_Amount__c == null) ? null : String.valueOf(application[0].First_Deposit_Amount__c);
            jsonData.sendStatement = application[0].AOB_Email__c;
            jsonData.preferredUserName = participant[0].AOB_Preferred_Name__c;
            jsonData.modeOfPayment = (application[0].AOB_Mode_Of_Payment__c == null) ? null  : application[0].AOB_Mode_Of_Payment__c;
            jsonData.customerName = application[0].AOB_MNO_Customer_Name__c;
            jsonData.operatorName = application[0].AOB_Operator_Name__c;
            jsonData.mobileMoneyNumber = participant[0].CNGCU_Phone__c;
            jsonData.bankName =application[0].AOB_Name_Of_Bank__c;
            jsonData.registeredAccountName = application[0].AOB_Alternative_Account_Name__c;
            jsonData.accountNumber = application[0].AOB_Alternative_Account_Number__c;
            for(Application_Line_Item__c appLine: appLineitem){
                if(appLine.Name == accessToMarkets){
                    jsonData.accessToMarkets = appLine.Name;
                }
                if(appLine.Name ==financialFitnessTraining){
                    jsonData.financialFitnessTraining = appLine.Name;
                }
                if(appLine.Name == insuranceOfferings){
                    jsonData.insuranceOfferings = appLine.Name;
                }
                if(appLine.Name == accessToFinance){
                    jsonData.accessToFinancing = appLine.Name;
                }
                if(appLine.Name == investmentOffering){
                    jsonData.investmentOffering = appLine.Name;
                }
                if(appLine.Name == coachingMediumBusiness){
                    jsonData.mentoringCoachingForSmallAndMediumBusinesses = appLine.Name;
                }
                if(appLine.Name == networkEvent){
                    jsonData.networkingEventsWithAccessToSubjectMatterIndustryExpert = appLine.Name;
                }
            }
            accountSetup = System.JSON.serialize(jsonData);
            return accountSetup;
        } 
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'BCB_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    /**
* @description fetch application data based on record Id 
* @param participantId 
* @return String
*/ 
    @AuraEnabled
    public static string fetchApplicationSummary(String participantId){
        try {
            String applicationSummary;
            BCB_DTO_ApplicationSummary jsonData = new BCB_DTO_ApplicationSummary();
            List<Application_Participant__c> participant = new SEL_ApplicationParticipant().selectApplicationParticpantById(participantId);
            List<Application__c> application = new SEL_Application().selectAppsById(participant[0].Application__c);
            List<Application_Line_Item__c> appLineitem = new SEL_ApplicationLineItem().selectApplicationLineItemByApplicationId(application[0].id);
            string inflight =application[0].AOB_inflightData__c;
            Map<String, Object> inflightmap = new Map<String, Object>();
            if(!String.isEmpty(inflight)){  
                inflightmap = (Map<String, Object>)system.JSON.deserializeUntyped(inflight);
                jsonData.secondarySectorCode =((String)inflightmap.get(secondarySectorCode));
                jsonData.tertiorySectorCode =((String)inflightmap.get(tertiarySectorCode));
            }
            String objectName = appObject;
            jsonData.preferredBranch = getPicklistLabel(objectName, preferredBranch, application[0]);
            jsonData.initialDeposit = getPicklistLabel(objectName, intialDeposit, application[0]);  
            jsonData.State = getPicklistLabel(objectName, State, application[0]); 
            jsonData.prominentPosition = application[0].AOB_PreviouslyHeldProminentOffice__c ? textTrue : textFalse;
            jsonData.familyPromientPosition = application[0].AOB_FamilyInProminentPublicOffice__c ? textTrue : textFalse;
            jsonData.taxResident = participant[0].AOB_resident_outside_of_Primary_Country__c ? textTrue : textFalse; 
            jsonData.relatedPartiesUS = participant[0].AOB_US_Related_Parties__c ? textTrue : textFalse; 
            jsonData.heldOffice = application[0].AOB_PreviouslyHeldOffice__c;
            jsonData.officeName = application[0].AOB_FamilyPreviouslyHeldOffice__c;
            jsonData.taxResidentCountry =getPicklist( participantObject,taxResidentCountry ,participant[0]);
            jsonData.city = getPicklist(participantObject, city, participant[0]);
            jsonData.district = participant[0].AOB_UG_BCB_District__c;
            jsonData.plotNumberDetails = participant[0].AOB_Street__c;
            jsonData.grossIncomeEntity = application[0].AOBEntity_earn_more_than_50_gross_income__c ? textTrue : textFalse;
            jsonData.grossAssetsEntity = application[0].AOB_Entity_hold_50_or_more_of_its_gross__c ? textTrue : textFalse;
            jsonData.registrationDate = (application[0].AOB_DateofRegistration__c == null) ? null : String.valueOf(application[0].AOB_DateofRegistration__c);
            jsonData.anticipatedAnnualTO = (application[0].Expected_Annual_Yearly_Turnover_To__c == null) ? null : String.valueOf(application[0].Expected_Annual_Yearly_Turnover_To__c);
            jsonData.sourceOfFunds = application[0].Intent_to_Future_Deposits_Fund__c; 
            jsonData.preferredSMContact = application[0].AOB_Preferred_Social_media_Channel__c; 
            jsonData.newAccountReason = application[0].Your_Account_Notes__c;
            jsonData.businessCity =  getPicklistLabel(objectName, city, application[0]);
            jsonData.businessDistrict = application[0].Correspondence_Province__c;
            jsonData.businessPlotDetails = application[0].AOB_Street__c;
            jsonData.emailStatement = application[0].CNCGU_Email_Statements__c ? textTrue : textFalse;
            jsonData.phoneNumber = participant[0].CNGCU_Phone__c;
            jsonData.initialDepositAmount = (application[0].First_Deposit_Amount__c == null) ? null : String.valueOf(application[0].First_Deposit_Amount__c);
            jsonData.sendStatement = application[0].AOB_Email__c;
            jsonData.preferredUserName = participant[0].AOB_Preferred_Name__c;
            jsonData.modeOfPayment = application[0].AOB_Mode_Of_Payment__c;
            jsonData.customerName = application[0].AOB_MNO_Customer_Name__c;
            jsonData.operatorName = application[0].AOB_Operator_Name__c;
            jsonData.mobileMoneyNumber = application[0].AOB_Mobile_Money_Number__c;
            jsonData.bankName =getPicklistLabel(objectName, bankName, application[0]);
            jsonData.registeredAccountName = application[0].AOB_Alternative_Account_Name__c;
            jsonData.accountNumber = application[0].AOB_Alternative_Account_Number__c;
            jsonData.noOfEmployees = string.valueOf(application[0].AOB_Company_employees__c);
            for(Application_Line_Item__c appLine: appLineitem){
                if(appLine.Name == accessToMarkets){
                    jsonData.accessToMarkets = 'Access To Markets';
                }
                if(appLine.Name == financialFitnessTraining){
                    jsonData.financialFitnessTraining = 'Financial Fitness Training';
                }
                if(appLine.Name == insuranceOfferings){
                    jsonData.insuranceOfferings = 'Insurance Offerings';
                }
                if(appLine.Name == accessToFinance){
                    jsonData.accessToFinancing = 'Access To Financing';
                }
                if(appLine.Name == investmentOffering){
                    jsonData.investmentOffering = 'Investment Offering';
                }
                if(appLine.Name == coachingMediumBusiness){
                    jsonData.mentoringCoachingForSmallAndMediumBusinesses = 'Mentoring Coaching For Small And Medium Businesses';
                }
                if(appLine.Name == networkEvent){
                    jsonData.networkingEventsWithAccessToSubjectMatterIndustryExpert = 'Networking Events With Access To Subject Matter/Industry Expert';
                }
            }

            applicationSummary = System.JSON.serialize(jsonData);
            return applicationSummary;  
           
        } 
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'BCB_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
/**
* @description for getting picklist name
* @param objectName
* @param fieldName
* @param application 
* @return string
*/  
    public static string getPicklistLabel(string objectName, string fieldName, Application__c application){
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult r = s.getDescribe();
        Map<String, Schema.SObjectField> fields = r.fields.getMap();
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        SObject applicationRecord = application; 
        String picklistValue = (String)applicationRecord.get(fieldName);
        String preferredBranchLabel = null;
        for (Schema.PicklistEntry pickListVal : ple) {
            if (pickListVal.getValue() == picklistValue) {
                preferredBranchLabel = pickListVal.getLabel();
                break;
            }
        }
        return preferredBranchLabel;
    } 
 /**
* @description for getting picklist name
* @param objectName
* @param fieldName
* @param participant 
* @return string
*/     
    public static string getPicklist(string objectName, string fieldName, Application_Participant__c participant){
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult r = s.getDescribe();
        Map<String, Schema.SObjectField> fields = r.fields.getMap();
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> pic = fieldResult.getPicklistValues();
        SObject participantrecord = participant; 
        String picklistValue = (String)participantrecord.get(fieldName);
        String taxcountryLabel = null;
        for (Schema.PicklistEntry pickListVal : pic) {
            if (pickListVal.getValue() == picklistValue) {
                taxcountryLabel  = pickListVal.getLabel();
                break;
            }
        }
        return taxcountryLabel;
    } 
    /**
* @description class to form application wrapper from  screen input to create application 
*/
    public class BCB_DTO_ApplicationSummary{    
        String prominentPosition;
        String heldOffice;
        String familyPromientPosition;
        String officeName;
        String taxResident;
        String taxResidentCountry;
        String relatedPartiesUS;
        String city;
        String district;
        String plotNumberDetails;
        String noOfEmployees;
        String secondarySectorCode;
        String tertiorySectorCode;
        String registrationDate;
        String anticipatedAnnualTO;
        String sourceOfFunds;
        String preferredSMContact;
        String newAccountReason;
        String grossIncomeEntity;
        String grossAssetsEntity;
        String businessCity;
        String businessDistrict;
        String businessPlotDetails;
        String preferredBranch;
        String phoneNumber;
        String initialDeposit;
        String initialDepositAmount;
        String emailStatement;
        String sendStatement;
        String preferredUserName;
        String modeOfPayment;
        String customerName;
        String operatorName;
        String mobileMoneyNumber;
        String bankName;
        String registeredAccountName;
        String accountNumber;
        String accessToMarkets;
        String financialFitnessTraining;
        String insuranceOfferings;
        String accessToFinancing;
        String investmentOffering;
        String mentoringCoachingForSmallAndMediumBusinesses;
        String networkingEventsWithAccessToSubjectMatterIndustryExpert;
        String State;
    }
    /**
* @description save data of participants based on screen name
* @param participantId 
* @param formData
* @param screenName
* @return String
*/ 
    @AuraEnabled
    public static string saveFormData(String participantId, String formData, String screenName){
        
        try{
            string returnVal;
            if(screenName == personalDetailsScreen){
                returnVal =   BCB_CTRL_FormCreator.saveParticipantPersonalData(participantId,formData);
            }
            else if(screenName == companyDetailsScreen){
                BCB_CTRL_FormCreator.saveParticipantcomapanyData(participantId,formData);
            }
            else if(screenName == accountSetupScreen){
                BCB_CTRL_FormCreator.saveParticipantaccountSetup(participantId,formData);
            }
            return returnVal;
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'BCB_CTRL_FormCreator.saveFormData',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());   
        }
    }
    /**
* @description save data of participants personal info
* @param participantId 
* @param formData
* @return String
*/ 
    @AuraEnabled
    public static string saveParticipantPersonalData(String participantId, String formData){
        try{
            map<string,string> pepAndSanctionStatusVsResult = new map<string,string>();
            BCB_DTO_PersonalDetails jsonData = (BCB_DTO_PersonalDetails)system.JSON.deserialize(formData, BCB_DTO_PersonalDetails.class);
            List<Application_Participant__c> participant = new SEL_ApplicationParticipant().selectApplicationParticpantById(participantId);
            List<Application__c> application = new SEL_Application().selectAppsById(participant[0].Application__c);
            application[0].AOB_PreviouslyHeldProminentOffice__c = Boolean.valueOf(jsonData.prominentPosition);
            application[0].AOB_PreviouslyHeldOffice__c = jsonData.heldOffice;
            application[0].AOB_FamilyInProminentPublicOffice__c = Boolean.valueOf(jsonData.familyPromientPosition);
            application[0].AOB_FamilyPreviouslyHeldOffice__c = jsonData.officeName;
            participant[0].AOB_resident_outside_of_Primary_Country__c = Boolean.valueOf(jsonData.taxResident);
            participant[0].AOB_Outside_of_Primary_Country__c = jsonData.taxResidentCountry;
            participant[0].AOB_City__c = jsonData.city;
            participant[0].AOB_UG_BCB_District__c = jsonData.district;
            participant[0].AOB_Street__c = jsonData.plotNumberDetails;
            participant[0].AOB_US_Related_Parties__c = String.isNotBlank(jsonData.relatedPartiesUS) ? Boolean.valueOf(jsonData.relatedPartiesUS): false;
            if(participant[0].AOB_US_Related_Parties__c){
                List<Lead> leadRec = new SEL_Lead().selectLeadByRecId(application[0].AOB_Lead__c);
                ID queueId = [SELECT Queue.Id FROM queuesobject WHERE queue.name='UG_BCB_FATCA_Queue' Limit 1].Queue.Id;
                leadRec[0].OwnerId = queueId;
                update leadRec;
            }if(Boolean.valueOf(jsonData.prominentPosition) == true || Boolean.valueOf(jsonData.familyPromientPosition) == true){
                application[0].AOB_PEP_Status__c = 'ACTIVE';
                pepAndSanctionStatusVsResult.put('Status','CustomerDropOff');
                List<Lead> leadRec = new SEL_Lead().selectLeadByRecId(application[0].AOB_Lead__c);
                ID queueId = [SELECT Queue.Id FROM queuesobject WHERE queue.name='UG_BCB_Sanctioned Customer_Queue' Limit 1].Queue.Id;
                leadRec[0].OwnerId = queueId;
                update leadRec;
            }
            update participant;
            update application;
            return System.JSON.serialize(pepAndSanctionStatusVsResult);
        }  
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'BCB_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());   
        }
        
    }
    /**
* @description class to form application wrapper for fetching data for personal details
*/
    public class BCB_DTO_PersonalDetails{    
        String prominentPosition;
        String heldOffice;
        String familyPromientPosition;
        String officeName;
        String taxResident;
        String taxResidentCountry;
        String relatedPartiesUS;
        String city;
        String district;
        String plotNumberDetails;
    }
    /**
* @description class to form application wrapper for fetching data for company details
*/
    public class BCB_DTO_CompanyDetails{    
        String noOfEmployees;
        String registrationDate;
        String anticipatedAnnualTO;
        String sourceOfFunds;
        String preferredSMContact;
        String newAccountReason;
        String grossIncomeEntity;
        String grossAssetsEntity;
        String businessCity;
        String businessDistrict;
        String businessPlotDetails;
        String secondarySectorCode;
        String tertiorySectorCode;
        String State;
    }
    /**
* @description save data of participants company info
* @param participantId 
* @param formData
*/
    @AuraEnabled
    public static void saveParticipantcomapanyData(String participantId, String formData){
        try{
            BCB_DTO_CompanyDetails jsonData = (BCB_DTO_CompanyDetails)system.JSON.deserialize(formData, BCB_DTO_CompanyDetails.class);
            List<Application_Participant__c> participant = new SEL_ApplicationParticipant().selectApplicationParticpantById(participantId);
            List<Application__c> application = new SEL_Application().selectAppsById(participant[0].Application__c);
            Map<String, Object> inflightData = new Map<String, Object>();
            
            if (String.isNotBlank(application[0].AOB_inflightData__c)) {
                inflightData = (Map<String, Object>) JSON.deserializeUntyped(application[0].AOB_inflightData__c);
            }

            String secondarySectorCodeValue = jsonData.secondarySectorCode;
            inflightData.put(primarySectorCode,secondarySectorCodeValue.left(secondarySectorCodeValue.length() - 1));
            inflightData.put(secondarySectorCode,jsonData.secondarySectorCode);
            inflightData.put(tertiarySectorCode,jsonData.tertiorySectorCode);
            inflightData.put(industrialSector,secondarySectorCodeValue.left(secondarySectorCodeValue.length() - 3));
           
            application[0].AOB_Company_employees__c = Decimal.valueOf(jsonData.noOfEmployees);
            application[0].AOB_inflightData__c = JSON.serialize(inflightData);
            application[0].AOB_DateofRegistration__c = Date.valueOf(jsonData.registrationDate);
            application[0].Expected_Annual_Yearly_Turnover_To__c =  Decimal.valueOf(jsonData.anticipatedAnnualTO.replace(application[0].AOB_Selected_Currency__c,'')) ;
            application[0].Intent_to_Future_Deposits_Fund__c = jsonData.sourceOfFunds;
            application[0].AOB_Preferred_Social_media_Channel__c = jsonData.preferredSMContact;
            application[0].Your_Account_Notes__c = jsonData.newAccountReason;
            application[0].AOBEntity_earn_more_than_50_gross_income__c = Boolean.valueOf(jsonData.grossIncomeEntity);
            application[0].AOB_Entity_hold_50_or_more_of_its_gross__c = Boolean.valueOf(jsonData.grossAssetsEntity);
            application[0].Correspondence_Province__c = jsonData.businessDistrict;
            application[0].AOB_City__c = jsonData.businessCity;
            application[0].AOB_Street__c = jsonData.businessPlotDetails;
            application[0].AOB_State__c = jsonData.State;
            update participant;
            update application;
            
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'BCB_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        
    }
    /**
* @description save data of participants account info
* @param participantId 
* @param formData
*/
    @AuraEnabled
    public static void saveParticipantaccountSetup(String participantId, String formData){
        try{
            BCB_DTO_AccountSetup jsonData = (BCB_DTO_AccountSetup)system.JSON.deserialize(formData, BCB_DTO_AccountSetup.class);
            List<Application_Participant__c> participant = new SEL_ApplicationParticipant().selectApplicationParticpantById(participantId);
            List<Application__c> application = new SEL_Application().selectAppsById(participant[0].Application__c);
            application[0].AOB_Preferred_Branch__c= jsonData.preferredBranch;
            application[0].AOB_Phone__c= jsonData.phoneNumber;
            application[0].AOB_Source_of_initial_deposit__c= jsonData.initialDeposit !=null?jsonData.initialDeposit:'';
            application[0].First_Deposit_Amount__c= jsonData.initialDepositAmount != null?Decimal.valueOf(jsonData.initialDepositAmount):0;
            application[0].CNCGU_Email_Statements__c= Boolean.valueOf(jsonData.emailStatement);
            application[0].AOB_Email__c = jsonData.sendStatement;
            participant[0].AOB_Preferred_Name__c= jsonData.preferredUserName;
            application[0].AOB_Mode_Of_Payment__c= jsonData.modeOfPayment;
            application[0].AOB_MNO_Customer_Name__c= jsonData.customerName;
            application[0].AOB_Operator_Name__c= jsonData.operatorName;
            application[0].AOB_Mobile_Money_Number__c= jsonData.mobileMoneyNumber !=null?jsonData.mobileMoneyNumber:'';
            application[0].AOB_Name_Of_Bank__c= jsonData.bankName;
            application[0].AOB_Alternative_Account_Name__c= jsonData.registeredAccountName;
            application[0].AOB_Alternative_Account_Number__c= jsonData.accountNumber;
            
            update participant;
            update application;
            
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'BCB_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    /**
* @description class to form application wrapper for fetching data for Account Setup
*/
    public class BCB_DTO_AccountSetup{    
        String preferredBranch;
        String phoneNumber;
        String initialDeposit;
        String initialDepositAmount;
        String emailStatement;
        String sendStatement;
        String preferredUserName;
        String modeOfPayment;
        String customerName;
        String operatorName;
        String mobileMoneyNumber;
        String bankName;
        String registeredAccountName;
        String accountNumber;
        String accessToMarkets;
        String financialFitnessTraining;
        String insuranceOfferings;
        String accessToFinancing;
        String investmentOffering;
        String mentoringCoachingForSmallAndMediumBusinesses;
        String networkingEventsWithAccessToSubjectMatterIndustryExpert;
    }
    
    /**
* @description save participants documents and relate to participant's application document
* @param base64 
* @param filename 
* @param recordId 
* @param documentType 
* @return String
*/
    public static String createAndUploadFile(String base64, String filename, String recordId,string documentType) {
        try{
            List<Application_Participant__c> participant = new SEL_ApplicationParticipant().selectApplicationParticpantById(recordId);
            Application_Document__c document = new Application_Document__c();
            document.Application__c = participant[0].Application__c;
            document.External_Id__c=filename;
            if (documentType == companyRegistrationCertificate) {
                deleteExistingAppDocs(recordId,documentType);
                document.Document_Type__c = uploadCompanyRegistrationCertificate;
            } else if (documentType == uploadTradeLicense) {
                deleteExistingAppDocs(recordId,documentType);
                document.Document_Type__c = uploadTradeLicense;
            } else if (documentType == uploadStatemetParticulars) {
                deleteExistingAppDocs(recordId,documentType);
                document.Document_Type__c = uploadStatemetParticulars;
            }
            insert document;
            return document.id;
        }catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'BCB_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    /**
* @description creates contentVersion and ContentDocument for participant document
* @param versionData 
* @param filename
* @param recordId
* @param documentType
* @param i
* @return String
*/ 
    @AuraEnabled
    public static String uploadFile(String versionData, String filename, String recordId, String documentType,Integer i) {
        String recID = createAndUploadFile(versionData, filename, recordId, documentType);
        ContentVersion cv = createContentVersion(versionData, filename);
        ContentDocumentLink cdl = createContentLink(cv.Id, recID);
        if (cv == null || cdl == null) {
            return null;
        }
        return cdl.Id;
    }  
    
    /**
* @description deletes existing app Docs
* @param recordId 
* @param documentType
*/ 
    public static void deleteExistingAppDocs( String recordId,String documentType){
        
        List<Application_Participant__c> participant = new SEL_ApplicationParticipant().selectApplicationParticpantById(recordId);
        List<Application_Document__c> delAppDoc = [Select id,Document_Type__c from Application_Document__c where Application__c =: participant[0].Application__c and Document_Type__c=:documentType];
        try{
            if(!delAppDoc.isEmpty()){
                delete delAppDoc;
            }
        }catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'BCB_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    /**
* @description creates content version
* @param base64 
* @param filename
* @return ContentVersion
*/ 
@TestVisible
    private static ContentVersion createContentVersion(String base64, String filename) {
        try {
            if (base64 == null || filename == null) {
                return null; 
            }
            ContentVersion cv = new ContentVersion();
            cv.VersionData = EncodingUtil.base64Decode(base64);
            cv.Title = filename;
            cv.PathOnClient = filename;
            insert cv;
            return cv;
        } catch (DMLException ex) {
            LOGGER.error(ex.getMessage(), new String[]{'BCB_CTRL_FormCreator', ex.getMessage()}, ex);
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
            LOGGER.error(ex.getMessage(), new String[] {'BCB_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    
    /**
* @description Method to create verification record invoked from all api callouts classes 
* @param participantRecord
* @param source
* @param status
* @return Id of the created verification record
*/
    public static Id createVerificationRecord(Application_Participant__c participantRecord, String source, String status) {
        try {
            string currcode;
            if(participantRecord.CurrencyIsoCode =='UGX'){
                currcode = 'UGX';
            }else{
                currcode = 'USD';
            }
            
            Verification__c verifyInstance = new Verification__c(
                Application_Participant__c = participantRecord.Id,
                Verification_Source__c = source,
                Verification_Status__c = status
            );
            
            insert verifyInstance;
            return verifyInstance.Id;
        } catch (Exception ex) {
            throw new BCB_CustomException(ex.getMessage());
        }
    }
    
    /**
* @description Method to generate GUID used for callouts invoked from all callout classes
* @return String created unique id used for callouts
*/
    public static String createGUID() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String newGuid = h.SubString(0,8) + '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        return newGuid;
    }
/**
* @description Method to get the Image Link by ParentId
* @param parentId
* @return String
*/
    @AuraEnabled
    public static String getImageLinkByParentId(String parentId) {
        List<Application_Document__c> appDocument = new SEL_ApplicationDocument().getDocumentTypeByParticipantId(parentId,faceImage);
        if (appDocument.isEmpty() || appDocument[0] == null) {
            return null;
        }
        List<ContentDocumentLink> conDocLinks= new SEL_ContentDocumentLink().getDocumentLinkByLinkedEntityId(appDocument[0].Id);
        if (conDocLinks.isEmpty()) {
            return null;
        }    
        Id contentDocumentId = conDocLinks[0].ContentDocumentId;
        List<ContentVersion> conVer= new SEL_ContentVersion().selectContentVersionByContentDocLatest(contentDocumentId);
        if (conVer.isEmpty() || conVer[0] == null || conVer[0].VersionData == null) {
            return null;
        }
        return EncodingUtil.base64Encode(conVer[0].VersionData);
    }
    /**
* @description Method to get the Signature Link by ParentId
* @param parentId
* @return String
*/
    @AuraEnabled
    public static String getSignatureLinkByParentId(String parentId) {
        List<Application_Document__c> appDocument = new SEL_ApplicationDocument().getDocumentTypeByParticipantId(parentId,uploadSignature);
        if (appDocument.isEmpty() || appDocument[0] == null) {
            return null;
        }
        List<ContentDocumentLink> conDocLinks = new SEL_ContentDocumentLink().getDocumentLinkByLinkedEntityId(appDocument[0].Id);
        if (conDocLinks.isEmpty()) {
            return null;
        }
        Id contentDocumentId = conDocLinks[0].ContentDocumentId;
        List<ContentVersion> conVer= new SEL_ContentVersion().selectContentVersionByContentDocLatest(contentDocumentId);
        if (conVer.isEmpty() || conVer[0] == null || conVer[0].VersionData == null) {
            return null;
        }
        return EncodingUtil.base64Encode(conVer[0].VersionData);
    }
    /**
* @description Method to save account images in the files 
* @param parentId
* @param base64Data
* @param fileName
* @param docType
* @return String
*/
    @AuraEnabled
    public static String saveAccountImage(String parentId, String base64Data, String fileName,string docType) {
        
        String recordTypeName = 'Uganda_BCC_Application_Participant';
        Id applicantRecordTypeId = Schema.SObjectType.Application_Document__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        
        Application_Document__c document = new Application_Document__c();
        document.Application_Participant__c = parentId;
        document.RecordTypeId = applicantRecordTypeId;
        if (docType == selfTag) {
            document.Document_Type__c = faceImage;
            docType = faceImage;
        } else if (docType == signatureTag) {
            document.Document_Type__c = uploadSignature;
            docType = uploadSignature;
        }
        List<Application_Document__c> applicationDocumentToDelete = new List<Application_Document__c>();            
        List<Application_Document__c> existingDocuments = [SELECT Id,Document_Type__c FROM Application_Document__c WHERE Application_Participant__c = :parentId];
        set<Id> setOfDocId = new set<Id>();
        for (Application_Document__c existingDocument : existingDocuments) {
            if(existingDocument.Document_Type__c == docType){
                applicationDocumentToDelete.add(existingDocument);
                setOfDocId.add(existingDocument.Id);
            }
        }
        if(setOfDocId.size()>0){
            List<ContentDocumentLink> documentLinks = [SELECT Id,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in :setOfDocId];
            delete documentLinks;

        }
        
        delete applicationDocumentToDelete;
        insert document;
        
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = fileName; 
        conVer.Title = fileName;
        conVer.VersionData =EncodingUtil.base64Decode(base64Data) ; 
        insert conVer;    
        
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = document.id; 
        conDocLink.ContentDocumentId = conDoc; 
        conDocLink.shareType = 'V';
        insert conDocLink;
        return document.id;
    }
    
    /**
* @description Method to save account images in the files 
* @param applicationParticipantId
* @param documentType
* @return List<Application_Document__c>
*/
    public static List<Application_Document__c> fetchDocuments(String applicationParticipantId, String documentType) {
        List<Application_Document__c> documents = new List<Application_Document__c>();
        if (documentType == companyRegistrationCertificate) {
            documentType = uploadRegistrationDocument;
        } else if (documentType == uploadTradeLicense) {
            documentType = uploadTradeLicense;
        } else if (documentType == uploadStatemetParticulars) {
            documentType = uploadStatemetParticulars;
        }
        try {
        String query = 'SELECT Id, Document_Type__c, Application_Participant__r.Name FROM Application_Document__c WHERE Application_Participant__c = :applicationParticipantId AND Document_Type__c = :documentType';
            documents = Database.query(query);
        } catch (Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'BCB_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage()); 
        }
        return documents;
    }
    
    /**
* @description gets participant record based on record Id
* @param recordId
* @return Map<String,Object> 
*/
    @AuraEnabled
    public static Map<String,Object> getParticipantAppId(string recordId) {
        
        List<Application_Participant__c> participant = New AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantById(recordId);
        string applicationId = participant[0].Application__c;
        Application__c appRecord = new SEL_Application().selectAppById(applicationId);
        
        Map<String, Object> jsonMap = new Map<String, Object>();
        if (!Participant.isEmpty()) {
            jsonMap.put(appId, participant[0].Application__c);
            jsonMap.put(contactNumber, participant[0].CNGCU_Phone__c);
            jsonMap.put(email, participant[0].CNGCU_Email__c);
            jsonMap.put(matchingStatus, appRecord.AOB_MNO_Name_Matched__c);
        }
        return jsonMap;
        
        
    }
    
    /**
* @description gets OTP expiration time from Custom Metadata
* @return Integer 
*/
@AuraEnabled(cacheable=true)
public static Integer getOTPExpirationTimeInSeconds() {
    String otpExpirationTimeString;
    Map<String, BCB_Static_Value__mdt> bcbStaticValuesMap = BCB_Static_Value__mdt.getAll();
    for(String bcbStaticVal : bcbStaticValuesMap.keySet()){
    BCB_Static_Value__mdt bcbValue = bcbStaticValuesMap.get(bcbStaticVal);
        if(bcbValue.Label == 'OTP Expires in Seconds'){
            otpExpirationTimeString = bcbValue.Value__c;
        }
    }
    return String.isNotBlank(otpExpirationTimeString) ? Integer.valueOf(otpExpirationTimeString) : NULL;
}

    /**
* @description method to get schema code
* @param applicationId
* @return String
*/ 
    @AuraEnabled
    public static String getSchemCode(string applicationId){
        List<Application_Participant__c> appParticpant = [select Id,Application__c,Application__r.AOB_Schema_Code__c from Application_Participant__c where Id =:applicationId];
        return  appParticpant[0].Application__r.AOB_Schema_Code__c;
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
            participants = new SEL_ApplicationParticipant().selectApplicationParticpantByKeyContact(appId); 
            return participants[0].Id;
        } catch(Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'BCB_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage()); 
        }
        
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
            List<Application_Participant__c> participants = new SEL_ApplicationParticipant().selectApplicationParticpantById(recordId);
            if (!participants.isEmpty()) { 
                participantData.put(keyContactMobile, participants[0].CNGCU_Phone__c);
                participantData.put(keyContactEmail, participants[0].CNGCU_Email__c);
            }
            else {
                List<Application_Participant__c> part = [select id,CNGCU_Phone__c,CNGCU_Email__c,Application__c from Application_Participant__c where id=:recordId order by CreatedDate ASC]; 
                participantData.put(keyContactMobile, part[0].CNGCU_Phone__c);
                participantData.put(keyContactEmail, part[0].CNGCU_Email__c);
            }
        } catch (Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'BCB_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        return participantData;
    }
    /**
* @description get key participant data of application
* @param applicationParticipantId 
* @return Map<String, String>
*/  
    @AuraEnabled
    public static Map<String, String> fetchrecordid(String applicationParticipantId) {
        Map<String, String> participantData = new Map<String, String>();
        List<Application_Participant__c> appParticipant = new SEL_ApplicationParticipant().selectApplicationParticpantById(applicationParticipantId);
        List<Application__c> applicationList = new SEL_Application().selectAppsById(appParticipant[0].Application__c);
        try {
            if (!appParticipant.isEmpty() && !applicationList.isEmpty()) { 
                participantData.put(firstName, appParticipant[0].CNGCU_First_Name__c);
                participantData.put(lastName, appParticipant[0].CNGCU_Last_Name__c);
                participantData.put(legalName,applicationList[0].AOB_BusinessLegalName__c);
                participantData.put(accountNumber,applicationList[0].AOB_Account_Number__c);
                participantData.put(selectedCurrency,applicationList[0].AOB_Selected_Currency__c);
                participantData.put(prodObj,applicationList[0].AOB_Product__c);
                participantData.put(schemeCode,applicationList[0].AOB_Schema_Code__c);
                
            }
            
        } catch (Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'BCB_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        return participantData;
    }
    
    
    /**
* @description This method is used to update Increments attemps 
* @param applicationId
* @return decimal
*/
    @auraEnabled
    public static decimal otpCounter(id applicationId) {
        try {
            decimal returnNumber;
            List<Application_Participant__c> praticipantsToUpdate=new List<Application_Participant__c>();
            Application_Participant__c appRec=new SEL_ApplicationParticipant().selectApplicationParticpantByApplicationId(applicationId);   
            if (appRec.AOB_OTPAttempts__c == null) {
                appRec.AOB_OTPAttempts__c=0;
            }
            
            appRec.AOB_OTPAttempts__c++;
            returnNumber = appRec.AOB_OTPAttempts__c;
            if(appRec.AOB_OTPAttempts__c==4){
                appRec.AOB_OTPAttempts__c=0;
            }
            praticipantsToUpdate.add(appRec);
            if(praticipantsToUpdate.size()>0){
                update praticipantsToUpdate; 
            }
            return returnNumber;
        } catch (Exception ex) {            
            LOGGER.error(ex.getMessage(), new String[] {'BCB_CTRL_FormCreator.otpCounter',ex.getMessage()}, ex);throw new AuraHandledException(ex.getMessage());  
        }     
    }

        /**
* @description This method is used to get product by product code
* @param productCode
* @return product
*/
    @AuraEnabled
    public static Product2 getProductByProductCode(String productCode){
        try{
            List<Product2> products= new SEL_Product2().selectMemoProductByProductCode(productCode);
            Product2 product=products.get(0);
            return product;
        } catch (Exception ex) {            
            LOGGER.error(ex.getMessage(), new String[] {'BCB_CTRL_FormCreator.getProductByProductCode',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        } 
    }
}