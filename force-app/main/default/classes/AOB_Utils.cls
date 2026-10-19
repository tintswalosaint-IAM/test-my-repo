/**
 * @description Utility methods for AOB project
 *
 * <p></p>

 * @author Asmae ESSBAI (aessbai@salesforce.com)
 * @param String NAMED_CREDENTIAL_URL_FORMAT, String SERVICE_NAME
 * @date Nov 9th 2020
 *
 * ACTION  TICKET    DATE       OWNER         COMMENT
 * Changed SFP-9129  01-04-2022 Gill Lumley   Add getWFRError method
 * Changed SFP-10057 20-04-2022 Gill Lumley   Add getPublicHolidayDates method
 * Changed SFP-12774 10-10-2023 Gill Lumley   Change getAllPicklistEntries methods to aggregate (to avoid duplicates) and to sort in name sequence    
 * Changed SFP-15724 10-10-2023 Gill Lumley   Change getAllPicklistEntries methods to aggregate (to avoid duplicates) and to sort in name sequence 
 * Changed           23-11-2023 Gill Lumley   Change to use the new rflib logger   
 */
public with sharing class AOB_Utils {
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    public static final String SERVICE_NAME = AOB_Utils.class.getName();
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_Utils');

    /**
     * @description Get Access token without checking expiry date
     * @return accessToken
     */
    @AuraEnabled
    public static String getFreshAccessToken() {
        //return CMN_SRV_OAuth.getUserAccessToken('AOB_Ping');
        if (Test.isRunningTest()) {
            return AOB_TestConstants.TOKEN;
        } else {
            String authProviderId = getAppSettingByCategory(AOB_Constants.PING).get(AOB_Constants.Ping_Id);
            String authProviderType = getAppSettingByCategory(AOB_Constants.PING).get(AOB_Constants.Ping_Type);
            String accessToken = Auth.AuthToken.getAccessToken(authProviderId, authProviderType);
            //String accessToken = Auth.AuthToken.getAccessToken('0SO250000004FbE', 'AOB_Ping');
            if (!String.isBlank(accessToken)) {
                Map<String, String> accessTokenMap = Auth.AuthToken.refreshAccessToken(
                    authProviderId,
                    authProviderType,
                    accessToken
                );
                //Map<String, String> accessTokenMap = Auth.AuthToken.refreshAccessToken('0SO250000004FbE','AOB_Ping',accessToken);
                if (accessTokenMap.get('RefreshError') == null) {
                    accessToken = accessTokenMap.get('AccessToken');
                } else {
                    LOGGER.error('Access token RefreshError', new String[] {'AOB_Utils.getFreshAccessToken', 'Access token: '+accessToken, 'RefreshError: '+accessTokenMap.get('RefreshError')});
                    return '';
                }
            }

            return accessToken;
        }
    }

    /**
     * @description Get Access token from the current session - A required method to call APIs
     * @return accessToken
     */
    @AuraEnabled
    public static String getAccessToken() {
        if (Test.isRunningTest()) {
            return AOB_TestConstants.TOKEN;
        } else {
            return CMN_SRV_OAuth.getUserAccessToken('AOB_Ping');
        }
    }

    /**
     * @description  method used to get the app setting by Category (custom metadata type)
     * @param  category
     * @return  Map<String, String>
     */
    public static Map<String, String> getAppSettingByCategory(String category) {
        Map<String, String> result = new Map<String, String>();
        list<AOB_AppSettings__mdt> techSettings = [
            SELECT MasterLabel, AOB_Value__c
            FROM AOB_AppSettings__mdt
            WHERE AOB_Category__c = :category
        ];
        for (AOB_AppSettings__mdt techSetting : techSettings) {
            result.put(techSetting.MasterLabel, techSetting.AOB_Value__c);
        }
        return result;
    }

    /**
     * @description Method used to get the app setting (custom metadata type)
     * @param  label
     * @return  String
     */
    public static String getAppSettingByLabel(String label) {
        list<AOB_AppSettings__mdt> techSettings = [
            SELECT MasterLabel, AOB_Value__c
            FROM AOB_AppSettings__mdt
            WHERE MasterLabel = :label
        ];
        return techSettings[0].AOB_Value__c;
    }

    /**
     * @description Method used to get the country setting (custom metadata type)
     * @param commerceSiteId
     * @return techSetting
     */
    public static AOB_Country_Settings__mdt getCountrySetting(String commerceSiteId) {
        AOB_Country_Settings__mdt techSetting;
        List<AOB_Country_Settings__mdt> techSettings = [
            SELECT
                MasterLabel,
                AOB_CallCenterPhoneNumber__c,
                AOB_Code__c,
                AOB_Commerce_Cloud_URL__c,
                AOB_Country__c,
                AOB_SystemId__c,
                AOB_CountryAbr__c,
                AOB_Currency__c,
                AOB_CurrencyCode__c,
                AOB_PermissionSet__c
            FROM AOB_Country_Settings__mdt
            WHERE AOB_Commerce_Site__c = :commerceSiteId
        ];
        if (!techSettings.isEmpty()) {
            techSetting = techSettings[0];
        }
        return techSetting;
    }

    /**
     * @description  method used to transert String to date Time
     * @param dateString
     * @return  String
     */
    public static DateTime formatDateTime(String dateString) {
        datetime dateObj = null;
        if (dateString.contains('T')) {
            dateString = dateString.replace('T', ' ');
            if (dateString.contains('.')) {
                dateString = dateString.subString(0, dateString.indexOf('.'));
            }
            dateObj = datetime.valueof(dateString);
        } else {
            dateObj = datetime.valueof(dateString);
        }
        return dateObj;
    }

    /**
     * @description  method used to transert DateTime format to M Month Y
     * @param dateT
     * @return  String
     */
    public static String formatDate(String dateT) {
        DateTime dt = formatDateTime(dateT);
        String monthName = dt.format('MMMMM');
        Integer day = dt.day();
        Integer year = dt.year();
        return day + ' ' + monthName + ' ' + year;
    }

    /**
     * @description  method used to transert DateTime format to M Month Y
     * @param dateT
     * @return  String
     */
    public static Integer remainingDays(String dateT) {
        DateTime d = formatDateTime(dateT);
        Date dt = (d).date();
        Date currentDate = system.today();
        Integer numberDaysDue = currentDate.daysBetween(dt);
        return numberDaysDue;
    }

    /**
     * @description  method used to generate a GUID
     * @return  String
     */
    public static String generateGUID() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        return h.SubString(0, 8) +
            '-' +
            h.SubString(8, 12) +
            '-' +
            h.SubString(12, 16) +
            '-' +
            h.SubString(16, 20) +
            '-' +
            h.subString(20);
    }

    /**
     * @description  method used to generate a webservice endpoint using guid
     * @param settings CMN_WebserviceSetting__mdt
     * @return  String
     */
    public static String generateWSendpoint(CMN_WebserviceSetting__mdt settings) {
        String endPoint;
        String fedId;
        List<Account> accounts = [
            SELECT id, ExternalCIFUUID__c
            FROM Account
            WHERE Id IN (SELECT AccountId FROM user WHERE id = :UserInfo.getUserId())
        ]; //:UserInfo.getUserId()
        if (!accounts.isEmpty()) {
            fedId = '/' + accounts[0].ExternalCIFUUID__c;
        }
        String path = String.isNotBlank(fedId) ? fedId : CMN_UTIL_String.EMPTY;
        if (settings != null && String.isNotBlank(settings.CMN_NamedCredential__c)) {
            path += String.isNotBlank(settings.CMN_Path__c) ? settings.CMN_Path__c : CMN_UTIL_String.EMPTY;
            endPoint = String.format(
                NAMED_CREDENTIAL_URL_FORMAT,
                new List<String>{
                    settings.CMN_NamedCredential__c,
                    String.isNotBlank(path) ? path : CMN_UTIL_String.EMPTY
                }
            );
        }

        return endPoint;
    }

    /**
     * @description  method used to parse jwt
     * @param jwtToken
     * @return  String
     */
    public static String parseJWT(String jwtToken) {
        if (String.isNotBlank(jwtToken)) {
            try {
                String base64Url = jwtToken.split('\\.')[1];
                String base64 = base64Url.replace('-', '+').replace('_', '/');
                String jsonPayload = EncodingUtil.base64Decode(base64).toString();
                return jsonPayload;
            } catch (exception e) {
                return '';
            }
        }
        return '';
    }

    /**
     * @description  method to read through the XML
     * @param reader
     * @param sxmltag
     * @return  String
     */
    public static String readXMLResponse(XmlStreamReader reader, String sxmltag) {
        String retValue;
        while (reader.hasNext()) {
            if (reader.getEventType() == XmlTag.START_ELEMENT) {
                if (reader.getLocalName() == sxmltag) {
                    reader.next();
                    if (reader.getEventType() == XmlTag.characters) {
                        retValue = reader.getText();
                    }
                }
            }
            reader.next();
        }
        return retValue;
    }

    /**
     * @description  method to format GUID
     * @param h
     * @return  String
     */
    public static String formatGUID(String h) {
        if (String.isblank(h)){
            return '';
        }
        h = h.replace('-', '');
        String guid =
            h.SubString(0, 8) +
            '-' +
            h.SubString(8, 12) +
            '-' +
            h.SubString(12, 16) +
            '-' +
            h.SubString(16, 20) +
            '-' +
            h.subString(20);
        return guid.toLowerCase();
    }

    /**
     * @description  method to fetch the picklist values from the refrenced Data Table
     * @param sapField
     * @param parent
     * @return  List<AOB_DTO_SelectOption>
     */
    public static List<AOB_DTO_SelectOption> getPicklistEntriesByParentField(String sapField, String parent) {
        if (Test.isRunningTest()) {
            if (sapField == null && parent == null) {
                throw new AuraHandledException('Testing');            
            }
        }
        List<AOB_DTO_SelectOption> result = new List<AOB_DTO_SelectOption>();

        List<AOB_ReferencedData__c> referencedDataList = [
            SELECT Id, AOB_Code__c, Name, AOB_Default__c, AOB_SAPField__c
            FROM AOB_ReferencedData__c
            WHERE
                AOB_Parent__r.AOB_Code__c = :parent
                AND AOB_SAPField__c = :sapField
                AND AOB_Language__c = :UserInfo.getLanguage()
                AND AOB_isActive__c = TRUE
            ORDER BY AOB_Sequence__c ASC
        ];
        for (AOB_ReferencedData__c data : referencedDataList) {
            result.add(new AOB_DTO_SelectOption(data.AOB_Code__c, data.Name, data.AOB_Default__c));
        }
        return result;
    }

    /**
     * @description  method to fetch the picklist values from the refrenced Data Table
     * @param sapFields
     * @return  List<AOB_DTO_SelectOption>
     */
    public static Map<String, List<AOB_DTO_SelectOption>> getAllPicklistEntriesCodes(List<String> sapFields) {
        Map<String, List<AOB_DTO_SelectOption>> result = new Map<String, List<AOB_DTO_SelectOption>>();

        // SFP-12774 and SFP-15724: Aggregate results to remove duplicates 
        List<AggregateResult> groupedResults =
            [SELECT AOB_SAPField__c, AOB_CountryCode__c, Name, AOB_Code__c, AOB_Default__c FROM  AOB_ReferencedData__c
                WHERE AOB_SAPField__c IN :sapFields 
                AND   AOB_CountryCode__c = :AOB_Constants.SA    
                GROUP BY AOB_SAPField__c, AOB_CountryCode__c, Name, AOB_Code__c, AOB_Default__c];

        groupedResults.sort();

        for (AggregateResult ar : groupedResults) {
            if (result.containskey(string.valueOf(ar.get('AOB_SAPField__c')))) {
                result.get(string.valueOf(ar.get('AOB_SAPField__c')))
                    .add(new AOB_DTO_SelectOption(string.valueOf(ar.get('AOB_Code__c')), string.valueOf(ar.get('Name')), boolean.valueOf(ar.get('AOB_Default__c'))));
            } else {
                result.put(
                    string.valueOf(ar.get('AOB_SAPField__c')),
                    new List<AOB_DTO_SelectOption>{
                        new AOB_DTO_SelectOption(string.valueOf(ar.get('AOB_Code__c')), string.valueOf(ar.get('Name')), boolean.valueOf(ar.get('AOB_Default__c')))
                    }
                );
            }
        }
        return result;
    }

    /**
     * @description  method to fetch the picklist values from the refrenced Data Table
     * @param sapFields 
     * @param productCodes
     * @return  List<AOB_DTO_SelectOption>
     */
    public static Map<String, List<AOB_DTO_SelectOption>> getAllPicklistEntriesByProduct(
        List<String> sapFields,
        String productCodes
    ) {
        Map<String, List<AOB_DTO_SelectOption>> result = new Map<String, List<AOB_DTO_SelectOption>>();

        // SFP-12774 and SFP-15724: Aggregate results to remove duplicates 
        List<AggregateResult> groupedResults =
            [SELECT AOB_SAPField__c, AOB_CountryCode__c, Name, AOB_Code__c, AOB_Default__c, AOB_ProductCategory__c FROM  AOB_ReferencedData__c
                WHERE AOB_SAPField__c IN :sapFields 
                AND   AOB_CountryCode__c = :AOB_Constants.SA    
                GROUP BY AOB_SAPField__c, AOB_CountryCode__c, Name, AOB_Code__c, AOB_Default__c, AOB_ProductCategory__c];

        groupedResults.sort();

        for (AggregateResult ar : groupedResults) {
            // Bypass entries that do not have matching product category (if product category is applicable)
            if (string.valueOf(ar.get('AOB_ProductCategory__c')) != null && productCodes != null){
                if (!string.valueOf(ar.get('AOB_ProductCategory__c')).contains(productCodes)) {
                  continue;
                }
            }
            // Build aggregated entries into map of code and value
            if (result.containskey(string.valueOf(ar.get('AOB_SAPField__c')))) {
                result.get(string.valueOf(ar.get('AOB_SAPField__c')))
                    .add(new AOB_DTO_SelectOption(string.valueOf(ar.get('AOB_Code__c')), string.valueOf(ar.get('Name')), boolean.valueOf(ar.get('AOB_Default__c'))));
            } else {
                result.put(
                    string.valueOf(ar.get('AOB_SAPField__c')),
                    new List<AOB_DTO_SelectOption>{
                        new AOB_DTO_SelectOption(string.valueOf(ar.get('AOB_Code__c')), string.valueOf(ar.get('Name')), boolean.valueOf(ar.get('AOB_Default__c')))
                    }
                );
            }
        }
        return result;
    }

    /**
     * @description  method to fetch the picklist values from the refrenced Data Table
     * @param   sapFields List<String> containing Object Names
     * @return  List<AOB_DTO_SelectOption>
     */
    public static Map<String, List<AOB_DTO_SelectOption>> getAllPicklistEntries(List<String> sapFields) {
        Map<String, List<AOB_DTO_SelectOption>> result = new Map<String, List<AOB_DTO_SelectOption>>();

        // SFP-12774 and SFP-15724: Aggregate results to remove duplicates 
        List<AggregateResult> groupedResults =
            [SELECT AOB_SAPField__c, AOB_CountryCode__c, Name, AOB_Code__c, AOB_Default__c FROM  AOB_ReferencedData__c
                WHERE AOB_SAPField__c IN :sapFields 
                AND   AOB_CountryCode__c = :AOB_Constants.SA    
                GROUP BY AOB_SAPField__c, AOB_CountryCode__c, Name, AOB_Code__c, AOB_Default__c];

        groupedResults.sort();

        for (AggregateResult ar : groupedResults) {
            if (result.containskey(string.valueOf(ar.get('AOB_SAPField__c')))) {
                result.get(string.valueOf(ar.get('AOB_SAPField__c')))
                    .add(new AOB_DTO_SelectOption(string.valueOf(ar.get('Name')), string.valueOf(ar.get('Name')), boolean.valueOf(ar.get('AOB_Default__c'))));
            } else {
                result.put(
                    string.valueOf(ar.get('AOB_SAPField__c')),
                    new List<AOB_DTO_SelectOption>{
                        new AOB_DTO_SelectOption(string.valueOf(ar.get('Name')), string.valueOf(ar.get('Name')), boolean.valueOf(ar.get('AOB_Default__c')))
                    }
                );
            }
        }       
        return result;
    }

    /**
     * @description  method to fetch an object url
     * @param   sfobject salesforce object record
     * @return  String containing the url to access that object via api
     */
    public static String getObjectUrl(object sfobject) {
        String appjson = JSOn.serialize(sfobject);
        Map<String, object> deserializedApp = (Map<String, Object>) System.JSON.deserializeUntyped(appjson);
        Map<String, Object> attributes = (Map<String, Object>) deserializedApp.get('attributes');
        return (String) attributes.get('url');
    }

    /**
     * @description  method to create a case from custom metadata
     * @param   context String - context
     * @param   applicationId String - applicationId
     * @param   assignToQueue Boolean - assignToQueue
     * @return  The created case record
     * Create case when there is no similar case with same description, same service type, same application id
     */
    public static Case createCase(String context, String applicationId, Boolean assignToQueue) {
        Case newCase = new Case();
        List<AOB_CaseCreationSetting__mdt> caseCreationSettings = [
            SELECT
                AOB_Origin__c,
                AOB_RecordType__c,
                AOB_CaseQueueName__c,
                AOB_Priority__c,
                AOB_Status__c,
                AOB_Subject__c,
                AOB_Description__c
            FROM AOB_CaseCreationSetting__mdt
            WHERE DeveloperName = :context
        ];
        List<AOB_Application__c> currentApplication = [
            SELECT Id, AOB_Customer__c
            FROM AOB_Application__c
            WHERE Id = :applicationId
        ];
        if (!currentApplication.isEmpty()) {
            newCase.AccountId = currentApplication[0].AOB_Customer__c;
            newCase.AOB_Application__c = applicationId;
        }
        if (!caseCreationSettings.isEmpty()) {
            AOB_CaseCreationSetting__mdt caseCreationSetting = caseCreationSettings.get(0);
            if (String.isNotBlank(caseCreationSetting.AOB_Status__c)) {
                newCase.Status = caseCreationSetting.AOB_Status__c;
            }
            if (String.isNotBlank(caseCreationSetting.AOB_Priority__c)) {
                newCase.Priority = caseCreationSetting.AOB_Priority__c;
            }
            if (String.isNotBlank(caseCreationSetting.AOB_Origin__c)) {
                newCase.Origin = caseCreationSetting.AOB_Origin__c;
            }
            if (String.isNotBlank(caseCreationSetting.AOB_Subject__c)) {
                newCase.Subject = caseCreationSetting.AOB_Subject__c;
            }
            if (String.isNotBlank(caseCreationSetting.AOB_Description__c)) {
                newCase.Description = caseCreationSetting.AOB_Description__c;
            }
            if (assignToQueue && String.isNotBlank(caseCreationSetting.AOB_CaseQueueName__c)) {
                List<Group> relatedQueues = [
                    SELECT Id
                    FROM Group
                    WHERE Type = 'Queue' AND DeveloperName = :caseCreationSetting.AOB_CaseQueueName__c
                ];
                if (!relatedQueues.isEmpty()) {
                    newCase.OwnerId = relatedQueues[0].Id;
                }
            }
            if (String.isNotBlank(caseCreationSetting.AOB_RecordType__c)) {
                List<RecordType> recTypes = [
                    SELECT Id, DeveloperName
                    FROM RecordType
                    WHERE DeveloperName = :caseCreationSetting.AOB_RecordType__c
                ];
                if (!recTypes.isEmpty()) {
                    newCase.RecordTypeId = recTypes.get(0).Id;
                }
            }
            insert newCase;
        }
        return newCase;
    }

    /**
     * @description  method to assign case based on the custom metadata type
     * @param   context String - context
     * @param   caseId Id - case Identifier
     * @param   applicationId String - application Identifier
     */
    public static void assignCaseToQueue(String context, Id caseId, Id applicationId) {
        List<Case> cases = [SELECT Id, OwnerId FROM Case WHERE Id = :caseId];
        if (!cases.isEmpty()) {
            Case currentCase = cases.get(0);
            List<AOB_CaseCreationSetting__mdt> caseCreationSettings = [
                SELECT
                    AOB_Origin__c,
                    AOB_CaseQueueName__c,
                    AOB_Priority__c,
                    AOB_Status__c,
                    AOB_Subject__c,
                    AOB_Description__c
                FROM AOB_CaseCreationSetting__mdt
                WHERE DeveloperName = :context
            ];
            /*List<AOB_Application__c> currentApplication = [
                SELECT Id, AOB_Customer__c
                FROM AOB_Application__c
                WHERE Id = :applicationId
            ];*/
            if (!caseCreationSettings.isEmpty()) {
                AOB_CaseCreationSetting__mdt caseCreationSetting = caseCreationSettings.get(0);
                if (String.isNotBlank(caseCreationSetting.AOB_CaseQueueName__c)) {
                    List<Group> relatedQueues = [
                        SELECT Id
                        FROM Group
                        WHERE Type = 'Queue' AND DeveloperName = :caseCreationSetting.AOB_CaseQueueName__c
                    ];
                    if (!relatedQueues.isEmpty()) {
                        currentCase.OwnerId = relatedQueues[0].Id;
                        update currentCase;
                    }
                }
            }
        }
    }

    /**
     * @description  method to get the current flow names of an application
     * @param   webserviceList
     * @return  String : flowNames field
     */
    public static Map<Id, AOB_Application__c> getApplicationsMap(List<CMN_WebserviceCallQueue__c> webserviceList) {
        Map<Id, AOB_Application__c> applicationsMap = new Map<Id, AOB_Application__c>();
        if (webserviceList != null && !webserviceList.isEmpty()) {
            Set<Id> applicationsIds = new Set<Id>();
            for (CMN_WebserviceCallQueue__c eachWebService : webserviceList) {
                applicationsIds.add(eachWebService.CMN_TriggeringObjectId__c);
            }
            applicationsMap = new Map<Id, AOB_Application__c>(
                [SELECT Id, AOB_Customer__c FROM AOB_Application__c WHERE Id IN :applicationsIds]
            );
        }
        return applicationsMap;
    }

    /**
     * @description  method to get the current flow names of an application
     * @param   applicationId
     * @return  String : flowNames field
     */
    public static String getApplicationFlowNames(Id applicationId) {
        List<AOB_Application__c> apps = [
            SELECT Id, AOB_TECH_FlowNames__c
            FROM AOB_Application__c
            WHERE Id = :applicationId
        ];
        if (!apps.isEmpty()) {
            return apps.get(0).AOB_TECH_FlowNames__c;
        } else {
            throw new AuraHandledException(
                'AOB_Utils.getApplicationFlowNames There is no Application record with the current Id: ' + applicationId
            );
        }
    }

    /**
     * @description  method to get the Reference data for code supplied
     * @param   aobCode
     * @param   aobSapCode
     * @return  AOB_ReferencedData__c : ref data record
     */
    public static AOB_ReferencedData__c getReferenceData(String aobCode, String aobSapCode) {
        List<AOB_ReferencedData__c> aobRefData = [
            SELECT Id, AOB_Code__c, AOB_SAPField__c, Name
            FROM AOB_ReferencedData__c
            WHERE AOB_Code__c = :aobCode AND AOB_SAPField__c = :aobSapCode
            LIMIT 1
        ];
        if (!aobRefData.isEmpty()) {
            return aobRefData.get(0);
        } else {
            throw new AuraHandledException(
                'AOB_Utils.getReferenceData There is no Reference Data record with the current Code and SapCode: ' +
                aobCode +
                ' : ' +
                aobSapCode
            );
        }
    }

    /**
     * @description  method to get business hours from AOB_Business_Hours__mdt metadata
     * @return  List<String> : list of business hours
     */
    public static List<String> getBusinessHours() {
        List<String> business = new List<String>();
        for (AOB_Business_Hours__mdt data : [SELECT Id, AOB_Value__c FROM AOB_Business_Hours__mdt]) {
            business.add(data.AOB_Value__c);
        }
        return business;
    }

    /**
     * @description method used to get the ws setting by name (custom metadata type)
     * @param   name
     * @return  Map<String, String>
     */
    public static CMN_WebserviceSetting__mdt getWebServiceSettingsByName(String name) {
        List<CMN_WebserviceSetting__mdt> wsSettings = [
            SELECT MasterLabel, AOB_Action__c, AOB_Channel__c
            FROM CMN_WebserviceSetting__mdt
            WHERE MasterLabel = :name
            LIMIT 1
        ];
        if (!wsSettings.isEmpty()) {
            return wsSettings.get(0);
        } else {
            throw new AuraHandledException('Error on AOB_Utils.getWebServiceSettingsByName');
        }
    }

    /**
     * @description Method used to get a specific WFR error code (custom metadata type)
     * @author Gill Lumley - SFP-9129
     * @param errorCode
     * @return AOB_WFR_Error__mdt
     */
    public static AOB_WFR_Error__mdt getWFRError(String errorCode) {
        AOB_WFR_Error__mdt wfrError = [
            SELECT MasterLabel, AOB_Error_Description__c, AOB_Reason_Type__c, AOB_Retry__c
            FROM AOB_WFR_Error__mdt
            WHERE MasterLabel = :errorCode
        ];
        return wfrError;
    }

    /**
     * @description Method used to get public holidays from the Holidays table for a specific country and range of dates
     * @param   countryCode
     * @param   fromDate
     * @param   toDate
     * @return  List of holidays
     */
    @AuraEnabled
    public static List<Date> getPublicHolidayDates(String countryCode, date fromDate, date toDate) {
        List<Date> publicHolidays = new List<Date>();
        // Do not return any holidays if the from/to date has not been specified or from date is greater than to date
        if (fromDate == null || toDate == null || fromDate > toDate) {
            return publicHolidays;
        }

        // Retrieve all holidays within the date range for the country specified
        List<Holiday> holidays = [
            SELECT Name, Description, ActivityDate, IsRecurrence, RecurrenceStartDate, RecurrenceEndDateOnly
            FROM Holiday
            WHERE
                Description = :countryCode
                AND ((IsRecurrence = FALSE
                AND ActivityDate >= :fromDate
                AND ActivityDate <= :toDate)
                OR IsRecurrence = TRUE)
        ];

        // Load the holidays into the public holiday table for each date within the range
        if (holidays != null) {
            for (Holiday holiday : holidays) {
                if (!holiday.IsRecurrence) {
                    publicHolidays.add(holiday.ActivityDate);
                } else {
                    Integer currYear = fromDate.year();
                    while (currYear <= toDate.year()) {
                        Date workDate = date.newInstance(
                            currYear,
                            holiday.ActivityDate.month(),
                            holiday.ActivityDate.day()
                        );
                        if (
                            workDate >= fromDate &&
                            workDate >= holiday.RecurrenceStartDate &&
                            workDate <= toDate &&
                            (holiday.RecurrenceEndDateOnly == null ||
                            workDate <= holiday.RecurrenceEndDateOnly)
                        ) {
                            publicHolidays.add(workDate);
                        }
                        currYear = currYear + 1;
                    }
                }
            }
        }

        if (publicHolidays != null) {
            publicHolidays.sort();
        }
        return publicHolidays;
    }
}