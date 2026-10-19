public class AOB_SRV_WebserviceCallQueue {

    /**
     * @description	Create technical cases when there are no similar cases with same Application Id, Error Code, and Service Name
     * @param 	String Current context
     * @param 	List<CMN_WebserviceCallQueue__c> List of the Api calls object related to the error
     */
    public static List < Case > createTechnicalErrorCases(String context, List < CMN_WebserviceCallQueue__c > newCalls) {
        Map < String, CMN_WebserviceCallQueue__c > webserviceMap = new Map < String, CMN_WebserviceCallQueue__c > ();
        //cases to create
        List < Case > newCases = new List < Case > ();
        List < AOB_CaseCreationSetting__mdt > caseCreationSettings = new List < AOB_CaseCreationSetting__mdt > ();
        AOB_CaseCreationSetting__mdt caseCreationSetting;
        List < SVC_ServiceType__c > serviceTypes = new List < SVC_ServiceType__c > ();
        List < Group > relatedQueues = new List < Group > ();
        Map < Id, AOB_Application__c > applicationsMap;
        Id recordTypeId;
        //Loop variables
        String currentApiErrorInfo;
        Case currentCase;
        CMN_WebserviceCallQueue__c currentWebService;

        //Build WebServices Records map
        for (CMN_WebserviceCallQueue__c newCall: newCalls) {
            currentApiErrorInfo = newCall.CMN_TriggeringObjectId__c + ':' + newCall.CMN_Service__c + ':' + newCall.CMN_StatusCode__c;
            webserviceMap.put(currentApiErrorInfo, newCall);
        }
        if (!webserviceMap.isEmpty()) {

            caseCreationSettings = [SELECT AOB_Origin__c, AOB_CaseQueueName__c, AOB_Priority__c, AOB_Status__c, AOB_RecordType__c, AOB_Subject__c, AOB_Description__c from AOB_CaseCreationSetting__mdt where DeveloperName =: context];

            if (!caseCreationSettings.isEmpty()) {
                caseCreationSetting = caseCreationSettings.get(0);
                //Get the related queue Id
                if (String.isNotBlank(caseCreationSetting.AOB_CaseQueueName__c)) {
                    relatedQueues = [SELECT Id FROM Group WHERE Type = 'Queue'
                        AND DeveloperName =: caseCreationSetting.AOB_CaseQueueName__c
                    ];
                }
                applicationsMap = AOB_Utils.getApplicationsMap(webserviceMap.values());
                //Check for duplicates and remove the unwanted webservice records from map
                for (Case eachCase: [SELECT AOB_TECH_ApiErrorCaseInfo__c FROM Case WHERE AOB_TECH_ApiErrorCaseInfo__c IN: webserviceMap.keySet() AND Status != 'Closed' AND Status != 'Merged']) {
                    if (webserviceMap.containsKey(eachCase.AOB_TECH_ApiErrorCaseInfo__c)) {
                        webserviceMap.remove(eachCase.AOB_TECH_ApiErrorCaseInfo__c);
                    }
                }
                //Get cases record type Id from settings
                if(String.isNotEmpty(caseCreationSetting.AOB_RecordType__c)){
                    List<RecordType> recTypes = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = :caseCreationSetting.AOB_RecordType__c];
                    if(!recTypes.isEmpty()){
                        recordTypeId = recTypes.get(0).Id;
                    }
                }

                //Proceed to cases building
                for (String eachExternalId: webserviceMap.keySet()) {
                    currentWebService = webserviceMap.get(eachExternalId);
                    currentCase = new Case();
                    currentCase.AOB_TECH_ApiErrorCaseInfo__c = eachExternalId;
                    currentCase.AOB_Application__c = currentWebService.CMN_TriggeringObjectId__c;
                    if (applicationsMap.containsKey(currentWebService.CMN_TriggeringObjectId__c)) {
                        currentCase.AccountId = applicationsMap.get(currentWebService.CMN_TriggeringObjectId__c).AOB_Customer__c;
                    }
                    if (String.isNotBlank(caseCreationSetting.AOB_Status__c)) {
                        currentCase.Status = caseCreationSetting.AOB_Status__c;
                    }
                    if (String.isNotBlank(caseCreationSetting.AOB_Priority__c)) {
                        currentCase.Priority = caseCreationSetting.AOB_Priority__c;
                    }
                    if (String.isNotBlank(caseCreationSetting.AOB_Origin__c)) {
                        currentCase.Origin = caseCreationSetting.AOB_Origin__c;
                    }
                    if (String.isNotBlank(caseCreationSetting.AOB_Subject__c)) {
                        currentCase.Subject = caseCreationSetting.AOB_Subject__c;
                    }
                    if (String.isNotBlank(caseCreationSetting.AOB_Description__c)) {
                        currentCase.Description = currentWebService.CMN_Service__c+': '+currentWebService.CMN_Response__c;
                    }
                    if (!relatedQueues.isEmpty()) {
                        currentCase.OwnerId = relatedQueues[0].Id;
                    }
                    if (String.isNotBlank(recordTypeId)) {
                        currentCase.RecordTypeId = recordTypeId;
                    }
                    newCases.add(currentCase);
                }
                insert newCases;
            }
        }
        return newCases;
    }
}