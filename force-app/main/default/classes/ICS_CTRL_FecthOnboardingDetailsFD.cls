/***************************************************************************************
@name of the Class : ICS_CTRL_FecthOnboardingDetailsFD.cls
@description : used as controller for  prepoulate data in future deposit section
@author : Ikyatha Naidu
@created Date : 15 May 2023
/***************************************************************************************
@last Modified By : Ikyatha Naidu
@last Modified On : 06-06-2024
@modification description: Updated to latest version
***************************************************************************************/
public without sharing class ICS_CTRL_FecthOnboardingDetailsFD {

    private static final String FUTURE_DEPOSITS = 'Future Deposits';
    private static final String FUNDING_QUESTION = 'How do you intend to fund the future deposits?';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_GBG');

    @AuraEnabled
    public static String fetchAssestListedFunds(String parentId, String screenName, String sectionName) {
        try{
            Map<String, Object> responseMap = getResponseMap(parentId);
            List<String> fundList = getFundList(responseMap);
            String result = fetchDynamicData(parentId, screenName, sectionName, fundList, responseMap);
            return result;
        }catch(exception exc){
            LOGGER.error(exc.getmessage());
            throw new AuraHandledException(exc.getmessage());
        }
    }

    private static Map<String, Object> getResponseMap(String parentId) {
        Map<String, Object> responseMap = new Map<String, Object>();
        SEL_AssesmentQuestionResponse selector = new SEL_AssesmentQuestionResponse();
        List<AssessmentQuestionResponse> responses = selector.selectByParentIdAndSectionName(parentId, FUTURE_DEPOSITS);

        for (AssessmentQuestionResponse response : responses) {
            if (response.AssessmentQuestion.QuestionText == FUNDING_QUESTION) {
                responseMap.put(FUNDING_QUESTION, response.ResponseText);
                responseMap.put(FUNDING_QUESTION + ':Id', response.Id);
            } else {
                responseMap.put(response.AssessmentQuestion.QuestionText, response.ResponseText);
            }
        }
        return responseMap;
    }

    private static List<String> getFundList(Map<String, Object> responseMap) {
        String fundResponse = (String)responseMap.get(FUNDING_QUESTION);
        return fundResponse == null ? new List<String>() : fundResponse.split(';');
    }

    private static String fetchDynamicData(String parentId, String screenName, String sectionName, List<String> fundList, Map<String, Object> responseMap) {
        Map<String, List<AOB_Field__c>> objectWithFieldAPINames = getObjectWithFieldAPINames(screenName, sectionName);
        List<SObject> objectInfoList = queryData(parentId, fundList);
        Map<String, List<SObject>> objectInfoMapByKey = groupObjectInfoByKey(objectInfoList);

        return prepareJsonResponse(objectInfoMapByKey, objectWithFieldAPINames, parentId, sectionName, responseMap);
    }

    private static Map<String, List<AOB_Field__c>> getObjectWithFieldAPINames(String screenName, String sectionName) {
        Map<String, List<AOB_Field__c>> objectWithFieldAPINames = new Map<String, List<AOB_Field__c>>();
        List<AOB_Field__c> screenFieldList = ICS_CTRL_FecthOnboardingDetails.fetchAobFields(screenName, sectionName);

        for (AOB_Field__c field : screenFieldList) {
            if (isValidField(field)) {
                if (objectWithFieldAPINames.containsKey(field.AOB_SFObject__c)) {
                    objectWithFieldAPINames.get(field.AOB_SFObject__c).add(field);
                } else {
                    objectWithFieldAPINames.put(field.AOB_SFObject__c, new List<AOB_Field__c>{field});
                }
            }
        }
        return objectWithFieldAPINames;
    }

    private static Boolean isValidField(AOB_Field__c field) {
        return field.AOB_SFObject__c != null
            && field.AOB_SFObject__c != ICS_Constants.ASSESSMENTTEXT
            && field.AOB_Type__c != 'Lookup'
            && field.AOB_Type__c != 'Empty'
            && field.AOB_Type__c != 'MasterDetail';
    }
	@testvisible
    private static List<SObject> queryData(String parentId,  List<String> typeList) {
        SEL_PartyProfile selectorPartyProfile = new SEL_PartyProfile();
        SEL_PartyAssetFunds selectorPartyAssetFunds = new SEL_PartyAssetFunds();
        String TypeListString = String.join(typeList, ':');
        TypeListString = TypeListString.replace('Other' , 'Other');
        typeList = TypeListString.split(':');
        PartyProfile profileData = selectorPartyProfile.selectByAccountAndRecordType(parentId, ICS_Constants.SBO_RECNAME);
        return selectorPartyAssetFunds.selectAssetFundsByRecordType(profileData.Id, typeList, 'future');
    }

    private static Map<String, List<SObject>> groupObjectInfoByKey(List<SObject> objectInfoList) {
        Map<String, List<SObject>> objectInfoMapByKey = new Map<String, List<SObject>>();

        for (SObject objData : objectInfoList) {
            Party_Assets_Funds__c assetFund = (Party_Assets_Funds__c)objData;
            String typeValue = (assetFund.Type__c == 'Other') ? 'Other' : assetFund.Type__c;
            String key = assetFund.RecordType.Name == 'Source of Funds' ? typeValue + ':Funds' : '';

            if (objectInfoMapByKey.containsKey(key)) {
                objectInfoMapByKey.get(key).add(objData);
            } else {
                objectInfoMapByKey.put(key, new List<SObject>{objData});
            }
        }
        return objectInfoMapByKey;
    }

    private static String prepareJsonResponse(Map<String, List<SObject>> objectInfoMapByKey, Map<String, List<AOB_Field__c>> objectWithFieldAPINames, String parentId, String sectionName, Map<String, Object> responseMap) {
        Map<String, Object> mergedMap = new Map<String, Object>(responseMap);
        mergedMap.put('objectName', 'Party_asset_Funds__c');

        for (String typeKey : objectInfoMapByKey.keySet()) {
            String typeName = typeKey.split(':')[0] + 'Vvv';
            List<String> singleJSON = ICS_CTRL_PrepareJSON.prepareJSON(objectInfoMapByKey.get(typeKey), objectWithFieldAPINames, null, parentId, sectionName, new Set<String>());
            String jsonResponse = '[' + String.join(singleJSON, ',') + ']';
            mergedMap.put('"' + typeName + '"', (Object)jsonResponse);
        }

        String normalJsonString = JSON.serialize(mergedMap)
            .replace('\\', '')
            .replace('""', '"')
            .replace('"[', '[')
            .replace(']"', ']');

        return '[' + normalJsonString + ']';
    }
    @AuraEnabled
    public static string deleteAssetsByProfile(string parentId, string type,boolean isFutureFund,string recId) {
        try {
        SEL_PartyProfile selectorPartyProfile = new SEL_PartyProfile();
        PartyProfile profileData = selectorPartyProfile.selectByAccountAndRecordType(parentId, ICS_Constants.SBO_RECNAME);
        SEL_PartyAssetFunds selectorPartyAssetFunds = new SEL_PartyAssetFunds();
        List<Party_Assets_Funds__c> assetsToDelete = selectorPartyAssetFunds.selectByPartyProfileTypewithRecordAssests(profileData.Id ,type,recId,isFutureFund);
        if (assetsToDelete.isEmpty() ==false) {
            delete assetsToDelete;
            return 'assets deleted successfully.';
        } else {
                   return 'No gift assets found to delete.';
        }
    }catch(exception exc) {
        LOGGER.error(exc.getmessage());
        throw new AuraHandledException(exc.getmessage());
}
}
}