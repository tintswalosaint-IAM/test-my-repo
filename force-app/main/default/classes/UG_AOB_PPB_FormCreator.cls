/**
 * @File Name          : UG_AOB_PPB_FormCreator.cls
 * @Description        : Class for dealing with Main Flow and sending the result to the main flow and storing the values in the wrapper
 * @Author             : Gayathri Velicheti   
 * User Story ID       : SFP-28286
 * @Last Modified By   : jagadish Thummala
 * @Last Modified On   : 11-03-2025
 *==============================================================================
 * Ver | Date           | Author | Modification
 *==============================================================================
 * 1.0 | June 16, 2025  |        | Initial Version
 **/
public without sharing class UG_AOB_PPB_FormCreator {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('UG_AOB_PPB_FormCreator');
    /**description constant for ENGLISH*/
    private static final String ENGLISH_US = 'en_US';
    /**description EN*/
    private static final String ENGLISH = 'EN';
    /* description Other employername code*/
    private static final String OTHER_CODE = '2020243';

    /**
     * @description Gets sections info and builds complete form structure
     * @param screenName The name of the screen to fetch fields for
     * @return AOB_Form Complete form object with sections and fields
     * @throws AuraHandledException if screenName is blank or null
     */
    @AuraEnabled
    public static AOB_Form getFields(String screenName) {
        try {
            validateScreenName(screenName);
            
            List<AOB_FlowScreen__c> screens = new SEL_AOBScreen().selectFieldsByName(screenName);
            String language = getUserLanguage();
            
            AOB_Form form = buildFormStructure(screens[0]);
            List<AOB_DTO_Section> sections = buildSections(screenName);
            Set<Id> sectionIds = extractSectionIds(sections);
            
            Map<String, List<AOB_DTO_SelectOption>> refData = buildReferenceData(sectionIds, language);
            Map<Id, List<AOB_DTO_Field>> sectionFields = buildSectionFields(sectionIds, refData);
            
            populateSectionsWithFields(sections, sectionFields);
            form.sections = sections;
            
            return form;
        } catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FormCreator.getFields', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Validates that screenName is not blank
     * @param screenName The screen name to validate
     * @throws AuraHandledException if screenName is blank or null
     */
    private static void validateScreenName(String screenName) {
        if (String.isBlank(screenName)) {
            throw new AuraHandledException('UG_AOB_PPB_FormCreator.validateScreenName: screenName cannot be null or empty');
        }
    }

    /**
     * @description Gets user language and converts to appropriate format
     * @return String The formatted language code
     */
    private static String getUserLanguage() {
        String language = AOB_BOTS_Utils.getUserLanguage();
        return (language == ENGLISH_US) ? ENGLISH : language;
    }

    /**
     * @description Builds the base form structure from screen data
     * @param screen The flow screen record
     * @return AOB_Form The initialized form object
     */
    private static AOB_Form buildFormStructure(AOB_FlowScreen__c screen) {
        AOB_Form form = new AOB_Form();
        form.subTitle = screen.AOB_subTitle__c;
        form.title = screen.AOB_title__c;
        form.popup = screen.AOB_Pop_up__c;
        return form;
    }

    /**
     * @description Builds list of sections for the given screen
     * @param screenName The name of the screen
     * @return List<AOB_DTO_Section> List of section DTOs
     */
    private static List<AOB_DTO_Section> buildSections(String screenName) {
        List<AOB_DTO_Section> sections = new List<AOB_DTO_Section>();
        for (AOB_ScreenSection__c section : new SEL_AOBSection().selectSectionsByScreenName(screenName)) {
            sections.add(setSectionInfo(section));
        }
        return sections;
    }

    /**
     * @description Extracts section IDs from section list
     * @param sections List of section DTOs
     * @return Set<Id> Set of section IDs
     */
    private static Set<Id> extractSectionIds(List<AOB_DTO_Section> sections) {
        Set<Id> sectionIds = new Set<Id>();
        for (AOB_DTO_Section section : sections) {
            sectionIds.add(section.identifier);
        }
        return sectionIds;
    }

    /**
     * @description Builds reference data map for MRI tables
     * @param sectionIds Set of section IDs to query
     * @param language Language code for reference data
     * @return Map<String, List<AOB_DTO_SelectOption>> Map of MRI table to select options
     */
    private static Map<String, List<AOB_DTO_SelectOption>> buildReferenceData(Set<Id> sectionIds, String language) {
        List<String> mriTables = new List<String>();
        for (AOB_Field__c field : new SEL_AOBField().selectMRITablesByLanguage(sectionIds, language)) {
            if (field.AOB_MRITable__c != null) {
                mriTables.add(field.AOB_MRITable__c);
            }
        }
        return getAllPicklistEntriesCodes(mriTables);
    }

    /**
     * @description Builds section fields map with reference data
     * @param sectionIds Set of section IDs
     * @param refData Reference data map
     * @return Map<Id, List<AOB_DTO_Field>> Map of section ID to field list
     */
    private static Map<Id, List<AOB_DTO_Field>> buildSectionFields(Set<Id> sectionIds, Map<String, List<AOB_DTO_SelectOption>> refData) {
        Map<Id, List<AOB_DTO_Field>> sectionFields = new Map<Id, List<AOB_DTO_Field>>();
        List<Application__c> apps = new List<Application__c>();
        
        for (AOB_Field__c field : new SEL_AOBField().selectFieldsBySection(sectionIds)) {
            AOB_DTO_Field jsField = new AOB_DTO_Field(field, apps);
            jsField.options = refData.get(field.AOB_MRITable__c);
            
            if (sectionFields.containsKey(field.AOB_Section__c)) {
                sectionFields.get(field.AOB_Section__c).add(jsField);
            } else {
                sectionFields.put(field.AOB_Section__c, new List<AOB_DTO_Field>{jsField});
            }
        }
        return sectionFields;
    }

    /**
     * @description Populates sections with their corresponding fields
     * @param sections List of sections to populate
     * @param sectionFields Map of section ID to fields
     */
    private static void populateSectionsWithFields(List<AOB_DTO_Section> sections, Map<Id, List<AOB_DTO_Field>> sectionFields) {
        for (AOB_DTO_Section section : sections) {
            List<AOB_DTO_Field> sortedFields = sectionFields.get(section.identifier);
            if (sortedFields != null) {
                sortedFields.sort();
            }
            section.fields = sortedFields;
        }
    }

    /**
     * @description Sets section information from screen section record
     * @param section The screen section record
     * @return AOB_DTO_Section The populated section DTO
     */
    @TestVisible
    private static AOB_DTO_Section setSectionInfo(AOB_ScreenSection__c section) {
        AOB_DTO_Section sectionInfo = new AOB_DTO_Section();
        sectionInfo.identifier = section.Id;
        sectionInfo.title = section.AOB_Title__c;
        sectionInfo.sectionName = section.Name;
        sectionInfo.smallDeviceColumns = section.AOB_smallDeviceColumns__c;
        sectionInfo.mediumDeviceColumns = section.AOB_mediumDeviceColumns__c;
        sectionInfo.largeDeviceColumns = section.AOB_largeDeviceColumns__c;
        sectionInfo.rank = section.AOB_Rank__c;
        sectionInfo.gridClass = 'aob_form_input slds-p-around_small slds-small-size_1-of-' + 
            sectionInfo.smallDeviceColumns + ' slds-medium-size_1-of-' + 
            sectionInfo.mediumDeviceColumns + ' slds-large-size_1-of-' + 
            sectionInfo.largeDeviceColumns;
        return sectionInfo;
    }

    /**
     * @description Retrieves button configuration data for a given screen
     * @param screenName The name of the screen to fetch buttons for
     * @return String JSON serialized list of button wrappers
     * @throws AuraHandledException if screenName is blank or null
     */
    @AuraEnabled
    public static String getButtonData(String screenName) {
        try {
            validateButtonScreenName(screenName);
            
            String scrName = '%' + screenName + '%';
            List<Button_Configuration__c> buttonList = queryButtonConfigurations(scrName);
            List<AOB_ScreenButtonWrapper> buttons = buildButtonWrappers(buttonList);
            
            return JSON.serialize(buttons);
        } catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FormCreator.getButtonData', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Validates screenName for button data retrieval
     * @param screenName The screen name to validate
     * @throws AuraHandledException if screenName is blank
     */
    private static void validateButtonScreenName(String screenName) {
        if (String.isBlank(screenName)) {
            throw new AuraHandledException('UG_AOB_PPB_FormCreator.getButtonData: screenName cannot be null or empty');
        }
    }

    /**
     * @description Queries button configurations from database
     * @param scrName The screen name pattern for LIKE query
     * @return List<Button_Configuration__c> List of button configurations
     */
    private static List<Button_Configuration__c> queryButtonConfigurations(String scrName) {
        return [
            SELECT Id, Name, Button_Label__c, Button_Sequence__c, Flow_screen__c 
            FROM Button_Configuration__c 
            WHERE AOB_External_Field__c 
            LIKE :scrName 
            ORDER BY Button_Sequence__c
            LIMIT 30
        ];
    }

    /**
     * @description Builds button wrapper objects from configurations
     * @param buttonList List of button configurations
     * @return List<AOB_ScreenButtonWrapper> List of button wrappers
     */
    private static List<AOB_ScreenButtonWrapper> buildButtonWrappers(List<Button_Configuration__c> buttonList) {
        List<AOB_ScreenButtonWrapper> buttons = new List<AOB_ScreenButtonWrapper>();
        
        for (Button_Configuration__c button : buttonList) {
            AOB_ScreenButtonWrapper eachButton = new AOB_ScreenButtonWrapper();
            eachButton.label = button.Button_Label__c;
            eachButton.variant = 'brand';
            eachButton.buttonJSFunction = (eachButton.label == 'Back') ? 'backToPreviousPage' : 'continueToNextPage';
            eachButton.isApexCall = false;
            buttons.add(eachButton);
        }
        return buttons;
    }

    /**
     * @description Retrieves employment ID and name for application
     * @param appId List containing application record
     * @return String JSON serialized map with employer name
     * @throws AuraHandledException if appId is null or empty
     */
    @AuraEnabled
    public static String getEmploymentId(List<Application__c> appId) {
        try {
            validateApplicationList(appId);
            
            Application__c app = new SEL_Application().selectAppById(appId[0].Id);
            validateApplication(app);
            
            List<AOB_ReferencedData__c> empNames = new SEL_ReferenceData().getReferencedDataName('PPB_EMP_NAME', 'AOB_SEQUENCE__C');
            String employerName = getEmployerName(app, empNames);
            
            return buildEmploymentResponse(employerName);
        } catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FormCreator.getEmploymentId', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Validates application list parameter
     * @param appId List of applications to validate
     * @throws AuraHandledException if list is null or empty
     */
    private static void validateApplicationList(List<Application__c> appId) {
        if (appId == null || appId.isEmpty()) {
            throw new AuraHandledException('Application ID list cannot be null or empty');
        }
    }

    /**
     * @description Validates application record
     * @param app Application record to validate
     * @throws AuraHandledException if application is null
     */
    private static void validateApplication(Application__c app) {
        if (app == null) {
            throw new AuraHandledException('Application list cannot be null or empty');
        }
    }

    /**
     * @description Gets employer name, converting to code if found in reference data
     * @param app Application record
     * @param empNames List of employer reference data
     * @return String The employer name or code
     */
    private static String getEmployerName(Application__c app, List<AOB_ReferencedData__c> empNames) {
        if (empNames == null) {
            return app.AOB_Employer_Name__c;
        }
        
        for (AOB_ReferencedData__c emp : empNames) {
            if (emp.Name == app.AOB_Employer_Name__c) {
                return emp.AOB_CODE__C;
            } 
        }
        return OTHER_CODE;
    }

    /**
     * @description Builds JSON response for employment data
     * @param employerName The employer name or code
     * @return String JSON serialized response
     */
    private static String buildEmploymentResponse(String employerName) {
        Map<String, Object> responseToReturnObject = new Map<String, Object>{
            'employerName' => employerName
        };
        return JSON.serialize(responseToReturnObject);
    }

    /**
     * @description Retrieves tertiary sector reference data as label-value map
     * @param appId List containing application record (currently unused but kept for signature compatibility)
     * @return String JSON serialized map of label to code
     * @throws AuraHandledException if appId is null or empty
     */
    @AuraEnabled
    public static String getTeritorySec(List<Application__c> appId) {
        try {
            if (appId == null || appId.isEmpty()) {
                throw new AuraHandledException('Application ID list cannot be null or empty');
            }
            
            List<AOB_ReferencedData__c> empData = new SEL_ReferenceData().getReferencedDataName('PPB_TERTIARY_SEC', 'AOB_SEQUENCE__C');
            Map<String, String> labelValueMap = buildLabelValueMap(empData);
            
            return JSON.serialize(labelValueMap);
        } catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FormCreator.getTeritorySec', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Builds label-value map from reference data
     * @param empData List of reference data records
     * @return Map<String, String> Map of name to code
     */
    private static Map<String, String> buildLabelValueMap(List<AOB_ReferencedData__c> empData) {
        Map<String, String> labelValueMap = new Map<String, String>();
        for (AOB_ReferencedData__c ref : empData) {
            labelValueMap.put(ref.NAME, ref.AOB_CODE__C);
        }
        return labelValueMap;
    }

    /**
     * @description Retrieves application data by record ID
     * @param recordId The ID of the application record
     * @return List<Application__c> List containing the application record
     * @throws AuraHandledException if recordId is blank or null
     */
    @AuraEnabled
    public static List<Application__c> getApplicationData(String recordId) {
        try {
            if (String.isBlank(recordId)) {
                throw new AuraHandledException('UG_AOB_PPB_FormCreator.getApplicationData: Application ID cannot be null or empty');
            }
            return new SEL_Application().selectAppsById(recordId);
        } catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FormCreator.getApplicationData', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Fetches picklist values from Referenced Data table for given SAP fields
     * @param sapFields List of SAP field names to retrieve picklist values for
     * @return Map<String, List<AOB_DTO_SelectOption>> Map of SAP field to select options
     */
    public static Map<String, List<AOB_DTO_SelectOption>> getAllPicklistEntriesCodes(List<String> sapFields) {
        Map<String, List<AOB_DTO_SelectOption>> result = new Map<String, List<AOB_DTO_SelectOption>>();
        
        List<AOB_ReferencedData__c> referencedDataList = [
            SELECT Id, AOB_Code__c, Name, AOB_Default__c, AOB_SAPField__c
            FROM AOB_ReferencedData__c
            WHERE AOB_SAPField__c IN :sapFields 
            AND AOB_Language__c = :UserInfo.getLanguage() 
            AND AOB_isActive__c = TRUE 
            ORDER BY AOB_Sequence__c ASC
        ];
        
        for (AOB_ReferencedData__c data : referencedDataList) {
            AOB_DTO_SelectOption option = new AOB_DTO_SelectOption(data.AOB_Code__c, data.Name, data.AOB_Default__c);
            
            if (result.containsKey(data.AOB_SAPField__c)) {
                result.get(data.AOB_SAPField__c).add(option);
            } else {
                result.put(data.AOB_SAPField__c, new List<AOB_DTO_SelectOption>{option});
            }
        }
        return result;
    }

    /**
     * @description Fetches static text values from custom metadata for use in LWC
     * @return Map<String, String> Map of DeveloperName to Value__c from UG_PPB_Static_LWC_Values_Detail__mdt
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getStaticValues() {
        try {
            Map<String, String> valuesMap = new Map<String, String>();
            
            List<UG_PPB_Static_LWC_values__mdt> staticValueRecords = [
                SELECT DeveloperName, Value__c 
                FROM UG_PPB_Static_LWC_values__mdt
                WITH USER_MODE
            ];
            
            for (UG_PPB_Static_LWC_values__mdt record : staticValueRecords) {
                valuesMap.put(record.DeveloperName, record.Value__c);
            }
            
            return valuesMap;
        } catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FormCreator.getStaticValues', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
}