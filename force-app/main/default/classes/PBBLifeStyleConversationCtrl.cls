/**
 * @description This class is used in a lightning Component
  * that creates Picklist dependencies
 *
 * @author		Emmanuel Mulea(Nocks)
 * @date	    April 2021
*/
public with sharing class PBBLifeStyleConversationCtrl {
    
    /**
    * @description  This method is doing dependencies
    * @return   smartSquare data
    **/    
    @AuraEnabled
    public static Smart2Data getArrangedDependancies(){
		Map<String,List<Smart2DataOptions>> subCatMaps = new Map<String,List<Smart2DataOptions>>();
        Map<String,List<Smart2DataOptions>> respMaps = new Map<String,List<Smart2DataOptions>>();
        Map<String,List<String>> subCatMapsTrackDups = new Map<String,List<String>>();
        Map<String,List<String>> respMapsTrackDups = new Map<String,List<String>>();
        List<Conversation_Value__c> convValueList = [SELECT Name, Id, CurrencyIsoCode, OwnerId, Reason__c, Response__c, Sub_Category__c FROM Conversation_Value__c LIMIT :Limits.getLimitQueryRows()];
        Smart2Data smtData = new Smart2Data();
        Smart2DataOptions smtOpts;
        for(Conversation_Value__c cv: convValueList){

            checkOnSubCategory(subCatMapsTrackDups, cv, smtOpts, subCatMaps);
            checkOnResponse(respMapsTrackDups, cv, smtOpts, respMaps);
        }
        smtData.subCat = new List<String>(subCatMaps.keySet());
        smtData.resp = subCatMaps;
        smtData.reas = respMaps;
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
                        Account__c,
                        Account__r.Name,
                        Name,
                        Conversation_Details__c,
                        Category__c,
                        Details__c,
                        CreatedBy.Name,
                        Status__c,
                        Owner.Name,
                        Owner.Id,
                        Reason__c,
                        Response__c,
                        Sub_Category__c,
                        LastModifiedBy.Name,
                        LastModifiedDate,
                        CreatedDate,
                        Client_Type__c,
                        Lead_Key__c
                FROM CMN_Conversation__c
                WHERE Id = :recId
        ];
        return conv;
    }

    /**
    * @description  This method for saving Conversation data
    * @param	conv Conversation object data
    **/
    @AuraEnabled 
    public static void saveData(CMN_Conversation__c conv){
        
        try{
            update conv;
        }
        catch(DmlException ex){
            CMN_UTIL_Logger.error(ex.getDmlMessage(0), 'PBBLifeStyleConversationCtrl.saveData');
            throw new PBBLifeStyleConversationException(ex.getDmlMessage(0));
        }
    }
    
     /**
    * @description  This method is to create a new conversation
    * @param	clientId Id of the Client
    * @return   Conversation object
    **/
    @AuraEnabled 
    public static CMN_Conversation__c newConversation(Id clientId){

        CMN_Conversation__c conv = new CMN_Conversation__c(OwnerId=UserInfo.getUserId(),
                                                   Account__c=clientId,
                                                   Category__c=null,
                                                   Reason__c=null,
                                                   Response__c=null,
                                                   Sub_Category__c=null
                                                  );
        return conv;

    }

    /**
    * @description  This method is to create a new conversation
    * @param	conv Object data
     * @return  Id of the conversation
    **/  
    @AuraEnabled 
    public static String createNewConversation(CMN_Conversation__c conv){
        try{
            insert conv;
            return conv.Id;
        }
        catch(DmlException ex){
            CMN_UTIL_Logger.error(ex.getDmlMessage(0), 'PBBLifeStyleConversationCtrl.createNewConversation');
            throw new PBBLifeStyleConversationException(ex.getDmlMessage(0));
        }
    }

    /**
    * @description  This method is to get conversations
    * @param	clientId Id of the Client
    * @return   Conversation object
    **/
    @AuraEnabled
    public static CMN_Conversation__c[] getConversations(Id clientId) {
        
        return [SELECT Id, Sub_Category__c, Response__c FROM CMN_Conversation__c WHERE Account__c = :clientId];
    }
    
    private static void checkOnResponse(Map<String, List<String>> respMapsTrackDups, Conversation_Value__c cv, Smart2DataOptions smtOpts, Map<String, List<Smart2DataOptions>> respMaps) {
        if (respMapsTrackDups.get(cv.Response__c) == null) {
            smtOpts = new Smart2DataOptions();
            smtOpts.value = cv.Reason__c;
            smtOpts.label = cv.Reason__c;
            respMaps.put(cv.Response__c, new List<Smart2DataOptions>{
                    smtOpts
            });
            respMapsTrackDups.put(cv.Response__c, new List<String>{
                    cv.Reason__c
            });
        } else {
            smtOpts = new Smart2DataOptions();
            if (!respMapsTrackDups.get(cv.Response__c).contains(cv.Reason__c)) {
                smtOpts.value = cv.Reason__c;
                smtOpts.label = cv.Reason__c;
                respMaps.get(cv.Response__c).add(smtOpts);
                respMapsTrackDups.get(cv.Response__c).add(cv.Reason__c);
            }
        }
    }
    private static void checkOnSubCategory(Map<String, List<String>> subCatMapsTrackDups, Conversation_Value__c cv, Smart2DataOptions smtOpts, Map<String, List<Smart2DataOptions>> subCatMaps) {
        if (subCatMapsTrackDups.get(cv.Sub_Category__c) == null) {
            smtOpts = new Smart2DataOptions();
            smtOpts.value = cv.Response__c;
            smtOpts.label = cv.Response__c;
            subCatMaps.put(cv.Sub_Category__c, new List<Smart2DataOptions>{
                    smtOpts
            });
            subCatMapsTrackDups.put(cv.Sub_Category__c, new List<String>{
                    cv.Response__c
            });
        } else {
            smtOpts = new Smart2DataOptions();
            if (!subCatMapsTrackDups.get(cv.Sub_Category__c).contains(cv.Response__c)) {
                smtOpts.value = cv.Response__c;
                smtOpts.label = cv.Response__c;
                subCatMaps.get(cv.Sub_Category__c).add(smtOpts);
                subCatMapsTrackDups.get(cv.Sub_Category__c).add(cv.Response__c);
            }
        }
    }

    /**
     * @description This is a wrapper class for SubCategory response and reason
     *
     * @author		Emmanuel Mulea(Nocks)
     * @date	    April 2021
    */
    public class Smart2Data{
        @AuraEnabled
        public List<String> subCat;
        @AuraEnabled
        public Map<String,List<Smart2DataOptions>>resp;
        @AuraEnabled
        public Map<String,List<Smart2DataOptions>>reas;
    }

    /**
     * @description This is a wrapper class for options
     *
     * @author		Emmanuel Mulea(Nocks) 
     * @date	    April 2021
    */
    public class Smart2DataOptions{
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String label;
    }

    /**
     * @description Exception class for unexpected errors inside PBBLifeStyleConversationCtrl
     *
     * @author		Lukasz Kojzar
     * @date	    October 2022
    */
    public class PBBLifeStyleConversationException extends Exception{}
}