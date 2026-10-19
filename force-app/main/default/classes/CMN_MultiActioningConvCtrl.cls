/**
 * @description Controller class for multiactioning conversations
 * @author Jakub Krawczyk
 * @date May 2023
 */
public with sharing class CMN_MultiActioningConvCtrl {

    /**
    * @description  This method is doing dependencies
    * @return   smartSquare data
    **/
    @AuraEnabled
    public static Smart2Data getArrangedDependencies(){
        CheckWrapper params = new CheckWrapper();
        List<Conversation_Value__c> convValueList = [SELECT Name, Id, CurrencyIsoCode, OwnerId, Reason__c, Response__c, Sub_Category__c FROM Conversation_Value__c LIMIT :Limits.getLimitQueryRows()];
        Smart2Data smtData = new Smart2Data();
        for(Conversation_Value__c cv: convValueList){

            checkOnSubCategory(params, cv);
            checkOnResponse(params, cv);
        }
        smtData.subCategoryList = new List<String>(params.subCatMaps.keySet());
        smtData.responseMap = params.subCatMaps;
        smtData.reasonMap = params.respMaps;
        return smtData;
    }

    /**
    * @description  This method is to get an Record Id
    * @param	recId Id of the Record
    * @return   Conversation object
    **/
    @AuraEnabled
    public static  CMN_Conversation__c getRecord(Id recId){
        CMN_Conversation__c conv = [
                SELECT Id,
                        Conversation_Details__c,
                        Category__c,
                        Details__c,
                        Sub_Category__c,
                        CMN_ExpectedRevenue__c,
                        CMN_ConversationId__c,
                        CurrencyIsoCode,
                        Reason__c,
                        Response__c
                FROM CMN_Conversation__c
                WHERE Id = :recId
        ];
        return conv;
    }

    private static void checkOnResponse(CheckWrapper params, Conversation_Value__c cv) {
        if (params.respMapsTrackDups.get(cv.Response__c) == null) {
            params.smtOpts = new Smart2DataOptions();
            params.smtOpts.value = cv.Reason__c;
            params.smtOpts.label = cv.Reason__c;
            params.respMaps.put(cv.Response__c, new List<Smart2DataOptions>{
                    params.smtOpts
            });
            params.respMapsTrackDups.put(cv.Response__c, new List<String>{
                    cv.Reason__c
            });
        } else {
            params.smtOpts = new Smart2DataOptions();
            if (!params.respMapsTrackDups.get(cv.Response__c).contains(cv.Reason__c)) {
                params.smtOpts.value = cv.Reason__c;
                params.smtOpts.label = cv.Reason__c;
                params.respMaps.get(cv.Response__c).add(params.smtOpts);
                params.respMapsTrackDups.get(cv.Response__c).add(cv.Reason__c);
            }
        }
    }
    private static void checkOnSubCategory(CheckWrapper params, Conversation_Value__c cv) {
        if (params.subCatMapsTrackDups.get(cv.Sub_Category__c) == null) {
            params.smtOpts = new Smart2DataOptions();
            params.smtOpts.value = cv.Response__c;
            params.smtOpts.label = cv.Response__c;
            params.subCatMaps.put(cv.Sub_Category__c, new List<Smart2DataOptions>{
                    params.smtOpts
            });
            params.subCatMapsTrackDups.put(cv.Sub_Category__c, new List<String>{
                    cv.Response__c
            });
        } else {
            params.smtOpts = new Smart2DataOptions();
            if (!params.subCatMapsTrackDups.get(cv.Sub_Category__c).contains(cv.Response__c)) {
                params.smtOpts.value = cv.Response__c;
                params.smtOpts.label = cv.Response__c;
                params.subCatMaps.get(cv.Sub_Category__c).add(params.smtOpts);
                params.subCatMapsTrackDups.get(cv.Sub_Category__c).add(cv.Response__c);
            }
        }
    }

    private class CheckWrapper {
        Map<String,List<Smart2DataOptions>> subCatMaps;
        Map<String,List<String>> subCatMapsTrackDups;
        Map<String,List<Smart2DataOptions>> respMaps;
        Map<String,List<String>> respMapsTrackDups;
        Smart2DataOptions smtOpts;

        CheckWrapper() {
            this.subCatMaps = new Map<String,List<Smart2DataOptions>>();
            this.subCatMapsTrackDups = new Map<String,List<String>>();
            this.respMaps = new Map<String,List<Smart2DataOptions>>();
            this.respMapsTrackDups = new Map<String,List<String>>();
        }
    }

    /**
     * @description Class for Smart2Data wrapper
     */
    public class Smart2Data{
        @AuraEnabled
        public List<String> subCategoryList;
        @AuraEnabled
        public Map<String,List<Smart2DataOptions>> responseMap;
        @AuraEnabled
        public Map<String,List<Smart2DataOptions>> reasonMap;
    }

    /**
     * @description Class for Smart2DataOptions wrapper
     */
    public class Smart2DataOptions{
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String label;
    }

    /**
     * @description Custom PBBLifeStyleConversationException Exception
     */
    public class PBBLifeStyleConversationException extends Exception{}
}