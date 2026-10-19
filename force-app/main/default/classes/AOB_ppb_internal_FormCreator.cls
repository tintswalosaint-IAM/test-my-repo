/***************************************************************************************
@ Author            :Jagadish Thummala
@ Date              :june 2022
@ Name of the Class :AOB_ppb_internal_FormCreator
@ Description       :Class for dealing with Main Flow and sending the result to the main flow and storing the values in the wrapper for staff assist
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :05-03-2024
@ Modification Description : SFP-31036
***************************************************************************************/
/**
* @description Class for dealing with the field data and pass it to main container.
*/
public  class AOB_ppb_internal_FormCreator { 
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_FormCreator');
    /**description constatnt ENGLISH*/
    private static final String ENGLISH_US = 'en_US';
    /**description EN*/
    private static final String ENGLISH = 'EN';
    /**description Ttile*/
    private static final String title = 'Ttile';
    /**
    * @description gets sections info
    * @param screenName - section info
    * @return String
    */
    @AuraEnabled
    public static AOB_Form getFields(String screenName) {
        List<AOB_FlowScreen__c> screens = new SEL_AOBScreen().selectFieldsByName(screenName);
        String language=AOB_BOTS_Utils.getUserLanguage();
        if(language ==ENGLISH_US ){
            language = ENGLISH;
        }
        AOB_Form form = new AOB_Form();
        form.subTitle = screens[0].AOB_subTitle__c;
        form.title = screens[0].AOB_title__c;
        form.popup = screens[0].AOB_Pop_up__c;
        List<AOB_DTO_Field> fields=new List<AOB_DTO_Field>();
        List<AOB_DTO_Section> sections=new List<AOB_DTO_Section>();
        Set<Id> sectionIds=new Set<Id>();
        AOB_DTO_Section jsSection;
       for(AOB_ScreenSection__c  section : new SEL_AOBSection().selectSectionsByScreenName(screenName)){
            // set section infos
            jsSection = setSectionInfo(section);
            sections.add(jsSection); 
            sectionIds.add(section.id);                             
        }

        Map<Id, List<AOB_DTO_Field>> sectionFields = new Map<Id, List<AOB_DTO_Field>>();
        List<String> mriTables = new List<String>();

        for (AOB_Field__c field : new SEL_AOBField().selectMRITablesByLanguage(sectionIds, language)) {
            if (field.AOB_MRITable__c != null) {
                mriTables.add(field.AOB_MRITable__c);
            }
        }

        Map<String, List<AOB_DTO_SelectOption>> refData = getAllPicklistEntriesCodes(mriTables);
        for (AOB_Field__c field : new SEL_AOBField().selectFieldsBySection(sectionIds)) {
            List<Application__c> apps = new List<Application__c>();
            AOB_DTO_Field jsField = new AOB_DTO_Field(field, apps);
            jsField.options = refData.get(field.AOB_MRITable__c);
            if (sectionFields.containsKey(field.AOB_Section__c)) {
                sectionFields.get(field.AOB_Section__c).add(jsField);
            } else {
                sectionFields.put(field.AOB_Section__c, new List<AOB_DTO_Field>{jsField});
            } 
        }
        for (AOB_DTO_Section section : sections) {
            List<AOB_DTO_Field> sortedFields = sectionFields.get(section.identifier);
            if (sortedFields != null) {
                sortedFields.sort();
            }
            section.fields = sortedFields;
        }
        form.sections = sections;
        return form;
        
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
    sectionInfo.gridClass='aob_form_input slds-p-around_small slds-small-size_1-of-'+sectionInfo.smallDeviceColumns+' slds-medium-size_1-of-'
            +sectionInfo.mediumDeviceColumns+' slds-large-size_1-of-'
            +sectionInfo.largeDeviceColumns;
        return sectionInfo;
    }
    
/**
* @description gets Button info
* @param screenName 
* @return AOB_ScreenButtonWrapper 
*/
    @AuraEnabled
    public static String getButtonData(String screenName){
        
        string scrName = '%'+screenName+'%';
        List<AOB_ScreenButtonWrapper> buttons = new List<AOB_ScreenButtonWrapper>();
        List<Button_Configuration__c> buttonList = [Select Id,Name,Button_Label__c,Button_Sequence__c, Flow_screen__c from Button_Configuration__c where AOB_External_Field__c  like :scrName ORDER BY Button_Sequence__c ];                                         
        for(Button_Configuration__c button: buttonList){
            AOB_ScreenButtonWrapper eachButton = new AOB_ScreenButtonWrapper();
            eachButton.label = button.Button_Label__c;
            eachButton.variant = 'brand';
            if(eachButton.label=='Back'){
               eachButton.buttonJSFunction = 'backToPreviousPage'; 
            }else{
                eachButton.buttonJSFunction = 'continueToNextPage'; 
            }
            eachButton.isApexCall = false;
            buttons.add(eachButton);
        }
        return JSON.serialize(buttons);
    } 
    /**
* @description gets Employment info
* @param appId 
* @return jsonString 
*/
    @AuraEnabled
    public static String getEmploymentId(List<Application__c> appId) {
        if (appId == null || appId.isEmpty()) {
            return null;
        }
        Application__c app = new SEL_Application().selectAppById(appId[0].Id);
        if (app == null) {
            return null;
        }
        List<AOB_ReferencedData__c> empNames = new SEL_ReferenceData().getReferencedDataName('PPB_EMP_NAME', 'AOB_SEQUENCE__C');
        if (empNames == null) {
            Map<String, Object> responseToReturnObject = new Map<String, Object>{
                'employerAddress' => app.AOB_Employer_Address__c,
                'employerName' => app.AOB_Employer_Name__c
            };
            return JSON.serialize(responseToReturnObject);
        }
    
        for (AOB_ReferencedData__c emp : empNames) {
            if (emp.AOB_CODE__C == app.AOB_Employer_Name__c) {
                app.AOB_Employer_Name__c = emp.Name;
                break;
            }
        }
    
        Map<String, Object> responseToReturnObject = new Map<String, Object>{
            'employerAddress' => app.AOB_Employer_Address__c,
            'employerName' => app.AOB_Employer_Name__c
        };
        return JSON.serialize(responseToReturnObject);
    }
    /**
* @description gets TeritorySec info
* @param appId 
* @return jsonString 
*/
    @AuraEnabled
    public static String getTeritorySec(List<Application__c> appId) {

        List<AOB_ReferencedData__c> empData = new SEL_ReferenceData().getReferencedDataName('PPB_TERTIARY_SEC','AOB_SEQUENCE__C');
        Map<String, String> labelValueMap = new Map<String, String>();
        for (AOB_ReferencedData__c ref : empData) {
            labelValueMap.put(ref.NAME, ref.AOB_CODE__C);
        }
        String jsonString = JSON.serialize(labelValueMap);
        return jsonString;   
    } 
   /**
* @description gets ApplicationData info
* @param recordId 
* @return applicationList 
*/
    @AuraEnabled
    public static List<Application__c> getApplicationData(String recordId){
        List<Application__c> applicationList = new SEL_Application().selectAppsById(recordId);
          return applicationList;
    }
     /**
     * @description	method to fetch the picklist values from the refrenced Data Table
     * @param 	sapFields
     * @return	Map<String, List<AOB_DTO_SelectOption>>
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
}